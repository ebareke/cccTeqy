# 📘 cccTeqy User Guide
A comprehensive guide for running, understanding, and extending the **cccTeqy** pipeline for ChIP-seq, CUT&RUN, and CUT&Tag analysis.

---

# 📦 1. Introduction
**cccTeqy** is a fully automated epigenomic processing pipeline built around a single Bash script (`run.sh`). It efficiently processes raw FASTQ files into:
- Alignments (BAM)
- Filtered reads
- Peak calls (MACS2)
- bigWig tracks
- QC summaries
- MultiQC reports

It supports **local execution**, **SLURM**, **PBS**, **Docker**, **Singularity**, and provides an easy YAML-based configuration.

---

# ⚙️ 2. Installation
You may run cccTeqy in three modes:
- **Native (local machine)**
- **HPC cluster (SLURM/PBS)**
- **Containers (Docker/Singularity)**

## 2.1 Native Installation
Install dependencies manually or via Conda:
```bash
mamba env create -f environment.yml
mamba activate cccteqy
```

## 2.2 Container Installation
### Docker
```bash
docker pull ebareke/cccteqy:latest
```
### Singularity
```bash
singularity build cccteqy.sif Singularity
```

---

# 🧬 3. Preparing Your Input Files
cccTeqy requires:
- A **config.yaml** file
- A **samples.tsv** sheet
- FASTQ files listed in the sample sheet
- Reference genome files (BWA index + blacklist BED)

---

# 📑 4. Configuration File (`config.yaml`)
Below is a minimal working configuration:
```yaml
project_name: MyProject
outdir: outputs
run_mode: local
threads: 16
bwa_index: /path/to/bwa/index
blacklist_bed: /path/to/blacklist.bed
rscript: Rscript
phantompeak_rscript: /opt/tools/run_spp.R
```

A container-optimized example is also available (`config.container.example.yaml`).

---

# 📄 5. Sample Sheet (`samples.tsv`)
Example:
```
SAMPLE_ID FASTQ1 FASTQ2 ASSAY MARK CONTROL_ID LIBTYPE
S1 R1.fq.gz R2.fq.gz CUTTAG H3K27me3 None PE
```

Column meanings:
- **FASTQ1/FASTQ2**: Paths to read files
- **ASSAY**: CUTTAG, CUTRUN, ChIPseq
- **MARK**: Histone/TF mark
- **CONTROL_ID**: Matched control or `None`
- **LIBTYPE**: SE or PE

---

# 🚀 6. Running the Pipeline
## 6.1 Basic Run
```bash
./run.sh -c config.yaml -s samples.tsv
```

## 6.2 Single-sample Mode
```bash
./run.sh -c config.yaml -s samples.tsv --run-single S1
```

## 6.3 SLURM Execution
Set in `config.yaml`:
```yaml
run_mode: slurm
```
Then run normally: cccTeqy will generate SBATCH scripts.

## 6.4 PBS Execution
```yaml
run_mode: pbs
```
Same execution behavior as SLURM.

---

# 🔬 7. Workflow Outputs
cccTeqy automatically produces:
- `align/` – aligned BAM files
- `qc/` – QC metrics: FastQC, Picard, preseq, phantomPeak, fragment size
- `peaks/` – MACS2 peak calls
- `bigwig/` – normalized coverage tracks
- `multiqc/` – integrated project-wide QC
- `logs/` – runtime logs

---

# 🧪 8. QC Modules Explained
### FastQC
Per-read quality summaries.

### Picard Duplication Metrics
Estimates duplication levels.

### Preseq
Library complexity projections.

### deepTools
Fragment-length distribution and coverage tracks.

### PhantomPeakQualTools
Cross‑correlation QC: NSC, RSC, estimated fragment length.

### FRiP
Fraction of reads that fall in MACS2 peaks.

---

# 🗂 9. Advanced Usage
## 9.1 Using Custom QC Modules
Add new blocks to `process_sample()` in `run.sh`.

## 9.2 Adding New Assays
Duplicate an existing assay logic block and modify MACS2 options.

## 9.3 Editing HPC Templates
Modify the SLURM/PBS generation functions in the script.

---

# 👩‍💻 10. Tips for Optimal Results
- Always ensure reference files match your genome build.
- Prefer container mode for reproducibility.
- Use at least **8–12 threads** for medium datasets.
- Always verify **fragment size** and **cross-correlation** metrics.
- Avoid mixing SE/PE libraries within the same sample sheet.

---

# 🛠 11. Troubleshooting
### FastQC not found
Install or ensure it’s in PATH.

### MACS2 peak files missing
Likely due to low coverage or wrong genome size.

### PhantomPeak fails
Ensure Rscript + run_spp.R are installed and executable.

### BAM empty
Alignment failed or reference mismatch.

---

# 🤝 12. Support & Community
- Issues: https://github.com/ebareke/cccTeqy/issues
- Wiki: Included under `wiki/`
- Pull requests welcome!

---

# 🪐 Final Note
cccTeqy is built for long-term reproducibility and scalability in epigenomic workflows.

<p align="center"><b>Welcome to the future of automated epigenomics.</b></p>

