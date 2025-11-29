#!/usr/bin/env bash
#
# chipseq_cutrun_cuttag_pipeline.sh
#
# Generalized, ready-to-run ChIP-seq / CUT&Run / CUT&Tag pipeline.
#
# Uses a YAML configuration file (config.yaml) and a tab-delimited
# sample sheet (samples.tsv).
#
# ------------------------------------------------------------
# YAML CONFIG EXAMPLE (config.yaml)
# ------------------------------------------------------------
# project_name: CUTTAG_H3K27me3_Project
# outdir: /lb/project/GRID/projects/cuttag_h3k27me3_out
#
# # Execution mode: local | slurm | pbs
# run_mode: local
#
# # Resources
# threads: 16
# max_jobs: 50
#
# # Reference / genome resources
# bwa_index: /ref/hg38/bwa/hg38
# genome_size: hs                        # or mm, 3.2e9, etc.
# chroms_keep_list: ""                   # optional file with chrom names (one per line)
# mito_chr: chrM                         # mitochondrial chromosome name (or empty to keep)
# blacklist_bed: /ref/hg38/blacklist/hg38-blacklist.v2.bed
#
# # Tool paths (or let them be found on PATH)
# bwa: bwa
# samtools: samtools
# bedtools: bedtools
# macs2: macs2
# fastqc: fastqc
# bamcoverage: bamCoverage               # optional, deepTools
# multiqc: multiqc                       # optional
# picard: picard                         # e.g. 'picard' or 'java -jar /path/picard.jar'
# rscript: Rscript                       # for phantomPeakQualTools
# phantompeak_rscript: /opt/phantompeakqualtools/run_spp.R
#
# # Filtering parameters
# min_mapq: 30                           # minimum mapping quality
# remove_duplicates: 1                   # 1 = remove duplicates, 0 = keep
#
# # MACS2 generic params
# macs2_qval: 0.01
# macs2_broad_qval: 0.1
# shift_extend_cutrun: ""
# shift_extend_cuttag: --shift -75 --extsize 150
#
# # SLURM defaults (RUN_MODE=slurm)
# slurm_partition: general
# slurm_time: 24:00:00
# slurm_mem: 32G
#
# # PBS defaults (RUN_MODE=pbs)
# pbs_queue: batch
# pbs_time: 24:00:00
# pbs_mem: 32gb
#
# # Path to this pipeline script (absolute path, needed for HPC modes)
# pipeline_script: /home/your_user/bin/chipseq_cutrun_cuttag_pipeline.sh
#
# ------------------------------------------------------------
# SAMPLE SHEET EXAMPLE (samples.tsv)
# ------------------------------------------------------------
# Columns (tab-delimited):
# SAMPLE_ID  FASTQ1  FASTQ2  ASSAY  MARK  CONTROL_ID  LIBTYPE
# ASSAY: ChIPseq | CUTRUN | CUTTAG
# MARK: e.g. H3K27me3, H3K4me3, H3K27ac, IgG, Input
# CONTROL_ID: sample_id of control/input or "None"
# LIBTYPE: PE | SE
#
# SAMPLE_ID\tFASTQ1\tFASTQ2\tASSAY\tMARK\tCONTROL_ID\tLIBTYPE
# T_706_9553L\t/path/to/fastq/T_706_9553L_H3K27me3_R1.fastq.gz\t/path/to/fastq/T_706_9553L_H3K27me3_R2.fastq.gz\tCUTTAG\tH3K27me3\tNone\tPE
# T_706_C0311L\t/path/to/fastq/T_706_C0311L_H3K27me3_R1.fastq.gz\t/path/to/fastq/T_706_C0311L_H3K27me3_R2.fastq.gz\tCUTTAG\tH3K27me3\tNone\tPE
# T_718_11950L\t/path/to/fastq/T_718_11950L_H3K27me3_R1.fastq.gz\t/path/to/fastq/T_718_11950L_H3K27me3_R2.fastq.gz\tCUTTAG\tH3K27me3\tNone\tPE
# T_718_9574L\t/path/to/fastq/T_718_9574L_H3K27me3_R1.fastq.gz\t/path/to/fastq/T_718_9574L_H3K27me3_R2.fastq.gz\tCUTTAG\tH3K27me3\tNone\tPE
# T_718_MB1679L\t/path/to/fastq/T_718_MB1679L_H3K27me3_R1.fastq.gz\t/path/to/fastq/T_718_MB1679L_H3K27me3_R2.fastq.gz\tCUTTAG\tH3K27me3\tNone\tPE
# T_779_12855L\t/path/to/fastq/T_779_12855L_H3K27me3_R1.fastq.gz\t/path/to/fastq/T_779_12855L_H3K27me3_R2.fastq.gz\tCUTTAG\tH3K27me3\tNone\tPE
# T_779_MB0197L\t/path/to/fastq/T_779_MB0197L_H3K27me3_R1.fastq.gz\t/path/to/fastq/T_779_MB0197L_H3K27me3_R2.fastq.gz\tCUTTAG\tH3K27me3\tNone\tPE
# ------------------------------------------------------------

set -euo pipefail

#############################################
# Argument parsing
#############################################

CONFIG_YAML=""
SAMPLES=""
RUN_SINGLE_ID=""
DRYRUN=0

usage() {
  cat <<EOF
Usage: $0 -c CONFIG_YAML -s SAMPLES [--run-single SAMPLE_ID] [--dry-run]

  -c, --config       Path to config.yaml
  -s, --samples      Path to sample sheet (TSV)
      --run-single   Process only one SAMPLE_ID (used by HPC jobs)
      --dry-run      Print commands instead of executing
EOF
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--config)
      CONFIG_YAML="$2"; shift 2;;
    -s|--samples)
      SAMPLES="$2"; shift 2;;
    --run-single)
      RUN_SINGLE_ID="$2"; shift 2;;
    --dry-run)
      DRYRUN=1; shift;;
    -h|--help)
      usage; exit 0;;
    *)
      echo "[ERROR] Unknown argument: $1" >&2
      usage
      exit 1;;
  esac
done

if [[ -z "${CONFIG_YAML}" || -z "${SAMPLES}" ]]; then
  echo "[ERROR] CONFIG_YAML and SAMPLES are required." >&2
  usage
  exit 1
fi

if [[ ! -f "$CONFIG_YAML" ]]; then
  echo "[ERROR] Config file not found: $CONFIG_YAML" >&2
  exit 1
fi

if [[ ! -f "$SAMPLES" ]]; then
  echo "[ERROR] Sample sheet not found: $SAMPLES" >&2
  exit 1
fi

#############################################
# Load YAML config (simple scalar key: value only)
#############################################

load_yaml_config() {
  local yaml_file="$1"
  if [[ ! -f "$yaml_file" ]]; then
    echo "[ERROR] YAML config not found: $yaml_file" >&2
    exit 1
  fi

  # Minimal YAML reader for key: value pairs on one line.
  # Ignores blank lines and lines starting with '#'.
  while IFS= read -r line || [[ -n "$line" ]]; do
    # trim leading whitespace
    line="${line#${line%%[![:space:]]*}}"
    # skip empty or comment
    [[ -z "$line" || "$line" == \#* ]] && continue

    if [[ "$line" =~ ^([A-Za-z0-9_]+)[[:space:]]*:[[:space:]]*(.*)$ ]]; then
      local key="${BASH_REMATCH[1]}"
      local value="${BASH_REMATCH[2]}"

      # strip inline comment
      value="${value%%#*}"
      # trim trailing whitespace
      value="${value%${value##*[![:space:]]}}"

      # strip surrounding quotes if present
      if [[ "$value" =~ ^\"(.*)\"$ ]]; then
        value="${BASH_REMATCH[1]}"
      elif [[ "$value" =~ ^'(.*)'$ ]]; then
        value="${BASH_REMATCH[1]}"
      fi

      local key_up
      key_up="$(echo "$key" | tr '[:lower:]' '[:upper:]')"
      eval "$key_up=\"$value\""
    fi
  done < "$yaml_file"
}

load_yaml_config "$CONFIG_YAML"

# Provide a fallback for PIPELINE_SCRIPT if not defined
if [[ -z "${PIPELINE_SCRIPT:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PIPELINE_SCRIPT="${SCRIPT_DIR}/$(basename "$0")"
fi

RUN_MODE="${RUN_MODE:-local}"
THREADS="${THREADS:-4}"
MAX_JOBS="${MAX_JOBS:-50}"
PROJECT_NAME="${PROJECT_NAME:-chip_project}"
OUTDIR="${OUTDIR:-./chipseq_out}"

mkdir -p "$OUTDIR" "$OUTDIR/logs" "$OUTDIR/fastq" "$OUTDIR/align" "$OUTDIR/qc" "$OUTDIR/peaks" "$OUTDIR/bigwig"

#############################################
# Utility helpers
#############################################

run_cmd() {
  local cmd="$1"
  if [[ "$DRYRUN" -eq 1 ]]; then
    echo "[DRYRUN] $cmd"
  else
    echo "[RUN] $cmd"
    eval "$cmd"
  fi
}

require_tool() {
  local name="$1"; local bin="${2:-$1}"
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "[ERROR] Required tool '$name' ('$bin') not found in PATH." >&2
    exit 1
  fi
}

#############################################
# Check required tools (using YAML-configured names if present)
#############################################

BWA_BIN="${BWA:-${bwa:-bwa}}"
SAMTOOLS_BIN="${SAMTOOLS:-${samtools:-samtools}}"
BEDTOOLS_BIN="${BEDTOOLS:-${bedtools:-bedtools}}"
MACS2_BIN="${MACS2:-${macs2:-macs2}}"
FASTQC_BIN="${FASTQC:-${fastqc:-fastqc}}"
BAMCOVERAGE_BIN="${BAMCOVERAGE:-${bamcoverage:-bamCoverage}}"
MULTIQC_BIN="${MULTIQC:-${multiqc:-multiqc}}"
PICARD_BIN="${PICARD:-${picard:-picard}}"          # optional
RSCRIPT_BIN="${RSCRIPT:-${rscript:-Rscript}}"       # optional
RUN_SPP_R="${PHANTOMPEAK_RSCRIPT:-""}"             # optional path to run_spp.R

require_tool "bwa" "$BWA_BIN"
require_tool "samtools" "$SAMTOOLS_BIN"
require_tool "bedtools" "$BEDTOOLS_BIN"
require_tool "macs2" "$MACS2_BIN"
require_tool "fastqc" "$FASTQC_BIN"

#############################################
# MACS2 parameter helper based on assay/mark
#############################################

get_macs2_opts() {
  local assay="$1"; local mark="$2"; local libtype="$3"

  local format="BAM"
  if [[ "$libtype" == "PE" ]]; then
    format="BAMPE"
  fi

  local broad="0"
  local qval="${MACS2_QVAL:-${macs2_qval:-0.01}}"
  local broad_qval="${MACS2_BROAD_QVAL:-${macs2_broad_qval:-0.05}}"

  # Very broad marks: H3K27me3, H3K9me3, etc.
  if [[ "$mark" =~ H3K27me3|H3K9me3 ]]; then
    broad="1"
  fi

  local extra=""
  case "$assay" in
    CUTRUN)
      extra="${SHIFT_EXTEND_CUTRUN:-${shift_extend_cutrun:-}}"
      ;;
    CUTTAG)
      extra="${SHIFT_EXTEND_CUTTAG:-${shift_extend_cuttag:-}}"
      ;;
    *)
      : ;; # ChIPseq default
  esac

  local gsize="${GENOME_SIZE:-${genome_size:-hs}}"

  if [[ "$broad" == "1" ]]; then
    echo "-f $format -g ${gsize} --bdg --broad --broad-cutoff ${broad_qval} $extra"
  else
    echo "-f $format -g ${gsize} --bdg -q ${qval} $extra"
  fi
}

#############################################
# Per-sample pipeline
#############################################

process_sample() {
  local sample_id="$1" fastq1="$2" fastq2="$3" assay="$4" mark="$5" control_id="$6" libtype="$7"

  echo "[INFO] Processing sample: $sample_id (assay=$assay, mark=$mark, libtype=$libtype)"

  local sample_dir_align="$OUTDIR/align/$sample_id"
  local sample_dir_qc="$OUTDIR/qc/$sample_id"
  local sample_dir_peaks="$OUTDIR/peaks/$sample_id"
  local sample_dir_bw="$OUTDIR/bigwig/$sample_id"

  mkdir -p "$sample_dir_align" "$sample_dir_qc" "$sample_dir_peaks" "$sample_dir_bw"

  ###########################################
  # 1. FastQC
  ###########################################

  run_cmd "$FASTQC_BIN -t ${THREADS} -o '$sample_dir_qc' '$fastq1'"
  if [[ "$libtype" == "PE" && "$fastq2" != "-" && -n "$fastq2" ]]; then
    run_cmd "$FASTQC_BIN -t ${THREADS} -o '$sample_dir_qc' '$fastq2'"
  fi

  ###########################################
  # 2. Alignment with BWA-MEM and sorting
  ###########################################

  local bwa_index="${BWA_INDEX:-${bwa_index:-}}"
  if [[ -z "$bwa_index" ]]; then
    echo "[ERROR] bwa_index/BWA_INDEX not set in config.yaml; cannot align." >&2
    exit 1
  fi

  local rg="@RG\tID:${sample_id}\tSM:${sample_id}\tPL:ILLUMINA"
  local bam_sorted="$sample_dir_align/${sample_id}-sorted.bam"

  if [[ "$libtype" == "PE" && "$fastq2" != "-" && -n "$fastq2" ]]; then
    run_cmd "$BWA_BIN mem -M -t ${THREADS} -R '$rg' '$bwa_index' '$fastq1' '$fastq2' | $SAMTOOLS_BIN sort -@ ${THREADS} -O BAM -o '$bam_sorted' -"
  else
    run_cmd "$BWA_BIN mem -M -t ${THREADS} -R '$rg' '$bwa_index' '$fastq1' | $SAMTOOLS_BIN sort -@ ${THREADS} -O BAM -o '$bam_sorted' -"
  fi

  run_cmd "$SAMTOOLS_BIN index -@ ${THREADS} '$bam_sorted'"

  ###########################################
  # 3. Filtering: chromosomes, mitochondrial, MAPQ, duplicates
  ###########################################

  local chroms_keep_list="${CHROMS_KEEP_LIST:-${chroms_keep_list:-}}"
  local mito_chr="${MITO_CHR:-${mito_chr:-}}"
  local blacklist_bed="${BLACKLIST_BED:-${blacklist_bed:-}}"
  local min_mapq="${MIN_MAPQ:-${min_mapq:-30}}"
  local remove_duplicates="${REMOVE_DUPLICATES:-${remove_duplicates:-1}}"

  local bam_chrom="$sample_dir_align/${sample_id}-chrom.bam"
  local bam_filtered="$sample_dir_align/${sample_id}-filtered.bam"
  local bam_nodup="$sample_dir_align/${sample_id}-filtered-nodup.bam"

  # 3a. Keep only listed chromosomes if CHROMS_KEEP_LIST defined
  if [[ -n "$chroms_keep_list" && -f "$chroms_keep_list" ]]; then
    local chroms
    chroms=$(tr '\n' ' ' < "$chroms_keep_list")
    run_cmd "$SAMTOOLS_BIN view -bh -@ ${THREADS} '$bam_sorted' $chroms > '$bam_chrom'"
  else
    bam_chrom="$bam_sorted"
  fi

  # 3b. Remove mitochondrial chromosome
  if [[ -n "$mito_chr" ]]; then
    run_cmd "$SAMTOOLS_BIN idxstats '$bam_chrom' | cut -f1 | grep -v -w '$mito_chr' | xargs $SAMTOOLS_BIN view -@ ${THREADS} -b '$bam_chrom' > '$bam_filtered'"
  else
    bam_filtered="$bam_chrom"
  fi

  # 3c. Filter by mapping quality
  local bam_qc="$sample_dir_align/${sample_id}-filtered-mapq.bam"
  run_cmd "$SAMTOOLS_BIN view -b -@ ${THREADS} -q $min_mapq '$bam_filtered' > '$bam_qc'"

  # 3d. Remove blacklist regions (optional)
  local bam_blacklist_out="$sample_dir_align/${sample_id}-filtered-mapq-blacklist.bam"
  if [[ -n "$blacklist_bed" && -f "$blacklist_bed" ]]; then
    run_cmd "$BEDTOOLS_BIN intersect -v -abam '$bam_qc' -b '$blacklist_bed' > '$bam_blacklist_out'"
  else
    bam_blacklist_out="$bam_qc"
  fi

  # 3e. Picard duplication metrics (optional, on pre-dedup BAM)
  if command -v "${PICARD_BIN%% *}" >/dev/null 2>&1; then
    local dup_metrics="$sample_dir_qc/${sample_id}-picard_duplication_metrics.txt"
    run_cmd "$PICARD_BIN CollectDuplicationMetrics I='$bam_blacklist_out' O='$dup_metrics' ASSUME_SORTED=true VALIDATION_STRINGENCY=SILENT"
  else
    echo "[INFO] picard not found; skipping Picard duplication metrics for $sample_id" >&2
  fi

  # 3f. Remove duplicates if requested
  local final_bam="$bam_blacklist_out"
  if [[ "$remove_duplicates" -eq 1 ]]; then
    local bam_markdup="$sample_dir_align/${sample_id}-markdup.bam"
    local bam_markdup_tmpns="$sample_dir_align/${sample_id}-markdup.ns.bam"
    run_cmd "$SAMTOOLS_BIN sort -n -@ ${THREADS} -O BAM -o '$bam_markdup_tmpns' '$bam_blacklist_out'"
    run_cmd "$SAMTOOLS_BIN fixmate -m -@ ${THREADS} '$bam_markdup_tmpns' '$bam_markdup_tmpns.fixmate.bam'"
    run_cmd "$SAMTOOLS_BIN sort -@ ${THREADS} -O BAM -o '$bam_markdup' '$bam_markdup_tmpns.fixmate.bam'"
    run_cmd "$SAMTOOLS_BIN markdup -r -@ ${THREADS} '$bam_markdup' '$bam_nodup'"
    run_cmd "$SAMTOOLS_BIN index -@ ${THREADS} '$bam_nodup'"
    final_bam="$bam_nodup"
  fi

  ###########################################
  # 4. Alignment QC (idxstats, stats)
  ###########################################

  run_cmd "$SAMTOOLS_BIN idxstats '$final_bam' > '$sample_dir_qc/${sample_id}-idxstats.txt'"
  run_cmd "$SAMTOOLS_BIN stats -@ ${THREADS} '$final_bam' > '$sample_dir_qc/${sample_id}-stats.txt'"

  ###########################################
  # 5. Peak calling with MACS2 + FRiP
  ###########################################

  local macs2_opts
  macs2_opts=$(get_macs2_opts "$assay" "$mark" "$libtype")

  local control_arg=""
  if [[ -n "$control_id" && "$control_id" != "None" && "$control_id" != "NONE" ]]; then
    local control_bam="$OUTDIR/align/$control_id/${control_id}-filtered-nodup.bam"
    if [[ ! -f "$control_bam" ]]; then
      control_bam="$OUTDIR/align/$control_id/${control_id}-filtered-mapq-blacklist.bam"
    fi
    if [[ -f "$control_bam" ]]; then
      control_arg="-c '$control_bam'"
    else
      echo "[WARN] Control BAM for $control_id not found; running MACS2 without control." >&2
    fi
  else
    control_arg="-c None"
  fi

  local macs2_prefix="$sample_dir_peaks/${sample_id}"
  run_cmd "$MACS2_BIN callpeak -t '$final_bam' $control_arg -n '${macs2_prefix##*/}' $macs2_opts --outdir '$sample_dir_peaks'"

  # 5b. FRiP (Fraction of Reads in Peaks)
  local peaks_bed=""
  if [[ -f "${sample_dir_peaks}/${sample_id}_peaks.narrowPeak" ]]; then
    peaks_bed="${sample_dir_peaks}/${sample_id}_peaks.narrowPeak"
  elif [[ -f "${sample_dir_peaks}/${sample_id}_peaks.broadPeak" ]]; then
    peaks_bed="${sample_dir_peaks}/${sample_id}_peaks.broadPeak"
  fi

  if [[ -n "$peaks_bed" ]]; then
    local total_reads
    local in_peak_reads
    local frip

    total_reads=$($SAMTOOLS_BIN view -c "$final_bam")
    in_peak_reads=$($BEDTOOLS_BIN intersect -u -abam "$final_bam" -b "$peaks_bed" | $SAMTOOLS_BIN view -c -)

    if [[ "$total_reads" -gt 0 ]]; then
      frip=$(awk -v a="$in_peak_reads" -v b="$total_reads" 'BEGIN{ if (b>0) printf "%.6f\n", a/b; else print "NA"; }')
      {
        echo -e "sample\ttotal_reads\treads_in_peaks\tFRiP"
        echo -e "${sample_id}\t${total_reads}\t${in_peak_reads}\t${frip}"
      } > "$sample_dir_qc/${sample_id}-frip.txt"
    else
      echo "[WARN] total_reads = 0 for $sample_id; FRiP not computed" >&2
    fi
  else
    echo "[WARN] No MACS2 peak file found for FRiP calculation in $sample_id" >&2
  fi

  ###########################################
  # 6. bigWig generation (optional)
  ###########################################

  if command -v "$BAMCOVERAGE_BIN" >/dev/null 2>&1; then
    local bw_file="$sample_dir_bw/${sample_id}.RPKM.bw"
    run_cmd "$BAMCOVERAGE_BIN -b '$final_bam' -o '$bw_file' --normalizeUsing RPKM -p ${THREADS}"
  else
    echo "[INFO] bamCoverage not found; skipping bigWig generation for $sample_id" >&2
  fi

  ###########################################
  # 7. Fragment length estimation (paired-end, optional)
  ###########################################

  if [[ "$libtype" == "PE" ]] && command -v bamPEFragmentSize >/dev/null 2>&1; then
    local frag_hist="$sample_dir_qc/${sample_id}-fragmentSize-hist.txt"
    local frag_txt="$sample_dir_qc/${sample_id}-fragmentSize-summary.txt"
    run_cmd "bamPEFragmentSize -b '$final_bam' \
      -hist '$frag_hist' \
      -T '${sample_id} fragment size' \
      --samplesLabel '$sample_id' \
      --numberOfProcessors ${THREADS} > '$frag_txt'"
  else
    if [[ "$libtype" == "PE" ]]; then
      echo "[INFO] bamPEFragmentSize not found; skipping fragment size estimation for $sample_id" >&2
    fi
  fi

  ###########################################
  # 8. Library complexity estimation (preseq, optional)
  ###########################################

  if command -v preseq >/dev/null 2>&1; then
    local preseq_ns="$sample_dir_align/${sample_id}-preseq.ns.bam"
    local preseq_out="$sample_dir_qc/${sample_id}-preseq_lc_extrap.txt"
    run_cmd "$SAMTOOLS_BIN sort -n -@ ${THREADS} -O BAM -o '$preseq_ns' '$final_bam'"
    run_cmd "preseq lc_extrap -B -o '$preseq_out' '$preseq_ns'"
  else
    echo "[INFO] preseq not found; skipping library complexity estimation for $sample_id" >&2
  fi

  ###########################################
  # 9. ChIP cross-correlation (phantomPeakQualTools style, optional)
  ###########################################

  if [[ -n "$RUN_SPP_R" ]] && command -v "$RSCRIPT_BIN" >/dev/null 2>&1; then
    local spp_out="$sample_dir_qc/${sample_id}-phantompeak_spp.txt"
    local spp_pdf="$sample_dir_qc/${sample_id}-phantompeak_spp.pdf"
    local spp_extra=""
    if [[ "$libtype" == "PE" ]]; then
      spp_extra="-rf"
    fi
    run_cmd "$RSCRIPT_BIN '$RUN_SPP_R' -c='$final_bam' -p=${THREADS} -savp -out='$spp_out' $spp_extra"
    # The PDF will be created in current directory; move it if needed.
    if [[ -f "Rplots.pdf" ]]; then
      run_cmd "mv Rplots.pdf '$spp_pdf'"
    fi
  else
    echo "[INFO] phantomPeakQualTools (run_spp.R) not configured; skipping cross-correlation for $sample_id" >&2
  fi

  echo "[INFO] Sample completed: $sample_id"
}

#############################################
# HPC job creation
#############################################

submit_slurm_job() {
  local sample_id="$1"; shift
  local jobdir="$OUTDIR/jobs/slurm"
  mkdir -p "$jobdir"
  local jobfile="$jobdir/${sample_id}.slurm.sh"

  cat > "$jobfile" <<EOF
#!/usr/bin/env bash
#SBATCH -J ${PROJECT_NAME}_${sample_id}
#SBATCH -p ${SLURM_PARTITION:-${slurm_partition:-general}}
#SBATCH -c ${THREADS}
#SBATCH --time=${SLURM_TIME:-${slurm_time:-24:00:00}}
#SBATCH --mem=${SLURM_MEM:-${slurm_mem:-16G}}
#SBATCH -o $OUTDIR/logs/${sample_id}.slurm.out
#SBATCH -e $OUTDIR/logs/${sample_id}.slurm.err

set -euo pipefail

"${PIPELINE_SCRIPT}" -c "${CONFIG_YAML}" -s "${SAMPLES}" --run-single "${sample_id}"
EOF

  if [[ "$DRYRUN" -eq 1 ]]; then
    echo "[DRYRUN] sbatch $jobfile"
  else
    sbatch "$jobfile"
  fi
}

submit_pbs_job() {
  local sample_id="$1"; shift
  local jobdir="$OUTDIR/jobs/pbs"
  mkdir -p "$jobdir"
  local jobfile="$jobdir/${sample_id}.pbs.sh"

  cat > "$jobfile" <<EOF
#!/usr/bin/env bash
#PBS -N ${PROJECT_NAME}_${sample_id}
#PBS -q ${PBS_QUEUE:-${pbs_queue:-batch}}
#PBS -l walltime=${PBS_TIME:-${pbs_time:-24:00:00}}
#PBS -l mem=${PBS_MEM:-${pbs_mem:-16gb}}
#PBS -l nodes=1:ppn=${THREADS}
#PBS -o $OUTDIR/logs/${sample_id}.pbs.out
#PBS -e $OUTDIR/logs/${sample_id}.pbs.err

cd \$PBS_O_WORKDIR
set -euo pipefail

"${PIPELINE_SCRIPT}" -c "${CONFIG_YAML}" -s "${SAMPLES}" --run-single "${sample_id}"
EOF

  if [[ "$DRYRUN" -eq 1 ]]; then
    echo "[DRYRUN] qsub $jobfile"
  else
    qsub "$jobfile"
  fi
}

#############################################
# Main driver: iterate over sample sheet
#############################################

# SAMPLE SHEET format reminder:
# SAMPLE_ID  FASTQ1  FASTQ2  ASSAY  MARK  CONTROL_ID  LIBTYPE

process_all_samples() {
  local mode="$1"  # local | slurm | pbs

  while IFS=$'\t' read -r SAMPLE_ID FASTQ1 FASTQ2 ASSAY MARK CONTROL_ID LIBTYPE || [[ -n "${SAMPLE_ID:-}" ]]; do
    [[ -z "${SAMPLE_ID:-}" ]] && continue
    if [[ "$SAMPLE_ID" == SAMPLE_ID || "$SAMPLE_ID" =~ ^# ]]; then
      continue
    fi

    if [[ -n "$RUN_SINGLE_ID" && "$RUN_SINGLE_ID" != "$SAMPLE_ID" ]]; then
      continue
    fi

    case "$mode" in
      local)
        process_sample "$SAMPLE_ID" "$FASTQ1" "$FASTQ2" "$ASSAY" "$MARK" "${CONTROL_ID:-None}" "$LIBTYPE"
        ;;
      slurm)
        submit_slurm_job "$SAMPLE_ID"
        ;;
      pbs)
        submit_pbs_job "$SAMPLE_ID"
        ;;
      *)
        echo "[ERROR] Unknown RUN_MODE: $mode" >&2
        exit 1
        ;;
    esac
  done < "$SAMPLES"
}

#############################################
# MultiQC (optional, only for local mode)
#############################################

run_multiqc_if_available() {
  if command -v "$MULTIQC_BIN" >/dev/null 2>&1; then
    run_cmd "$MULTIQC_BIN '$OUTDIR' -o '$OUTDIR/multiqc'"
  else
    echo "[INFO] multiqc not found; skipping global QC report" >&2
  fi
}

#############################################
# Execute
#############################################

case "$RUN_MODE" in
  local)
    process_all_samples "local"
    run_multiqc_if_available
    ;;
  slurm)
    process_all_samples "slurm"
    ;;
  pbs)
    process_all_samples "pbs"
    ;;
  *)
    echo "[ERROR] RUN_MODE must be one of: local, slurm, pbs (current: $RUN_MODE)" >&2
    exit 1
    ;;
esac

echo "[INFO] Pipeline finished (mode=$RUN_MODE)."
