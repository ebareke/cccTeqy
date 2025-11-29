# 🛰️ cccTeqy — Singularity Hub README

**Image:** `cccteqy.sif`  
**Repository:** https://github.com/ebareke/cccTeqy

cccTeqy is a **next-generation autonomous pipeline** for processing **ChIP-seq**, **CUT&RUN**, and **CUT&Tag** datasets. The Singularity image provides a secure, reproducible, and HPC-friendly execution environment for running the entire workflow.

This document describes how to build and use the **Singularity version** of cccTeqy.

---

# 🚀 Features
- Fully automated epigenomics pipeline
- Includes all required bioinformatics tools:
  - `bwa`, `samtools`, `bedtools`
  - `fastqc`, `macs2`
  - `picard`, `preseq`
  - `deepTools` (`bamCoverage`, `bamPEFragmentSize`)
  - `phantompeakqualtools` (`run_spp.R`)
  - `Rscript`, `multiqc`
- Optimized for HPC clusters using Singularity/Apptainer
- Clean, isolated runtime environment
- BYO-config (mount your own config.yaml, samples.tsv, FASTQs)

---

# 📦 Building the Image
Build the image from the repository root:
```bash
singularity build cccteqy.sif Singularity
```

Using Apptainer:
```bash
apptainer build cccteqy.sif Singularity
```

---

# 📁 Recommended Project Structure
```
/your/project/
 ├── config.yaml
 ├── samples.tsv
 ├── run.sh                    # Not required if using container's
 ├── data/
 │    ├── fastq/
 │    └── ref/
 └── outputs/
```

---

# 🧬 Example `config.yaml`
```yaml
project_name: DemoSingularityRun
outdir: /work/outputs
run_mode: local
threads: 8
bwa_index: /data/ref/hg38/bwa/hg38
blacklist_bed: /data/ref/hg38/blacklist/hg38-blacklist.v2.bed
bwa: bwa
samtools: samtools
bedtools: bedtools
macs2: macs2
fastqc: fastqc
picard: picard
preseq: preseq
bamcoverage: bamCoverage
multiqc: multiqc
rscript: Rscript
phantompeak_rscript: /opt/conda/bin/run_spp.R
```

---

# 📄 Example `samples.tsv`
```
SAMPLE_ID FASTQ1 FASTQ2 ASSAY MARK CONTROL_ID LIBTYPE
ex1 /data/fastq/ex1_R1.fq.gz /data/fastq/ex1_R2.fq.gz CUTTAG H3K27me3 None PE
ex2 /data/fastq/ex2_R1.fq.gz /data/fastq/ex2_R2.fq.gz CUTTAG H3K27me3 None PE
```

---

# ⚙️ Running the Pipeline
### Basic execution
```bash
singularity exec \
  -B $PWD:/work \
  -B /data:/data \
  cccteqy.sif \
  ./run.sh -c config.yaml -s samples.tsv
```

### Notes:
- `/work` becomes your project working directory inside the container
- `/data` is where reference files or large datasets live
- All outputs appear under `/work/outputs`

---

# 🧪 Quick Test
Verify that the container responds:
```bash
singularity exec cccteqy.sif fastqc --version
```
Or check MACS2:
```bash
singularity exec cccteqy.sif macs2 --help
```

---

# 🧹 Cleaning Up
Remove leftover temporary Singularity build files:
```bash
rm -f cccteqy.sif.tmp
```

---

# 🧭 Troubleshooting
### Cannot find FASTQ or reference files
You must bind-mount directories (`-B host:container`).

### Permission denied
Use:
```bash
apptainer exec --fakeroot ...
```
(if your system supports it)

### Missing tools
Ensure you built the image from the repository root.

---

# 🔗 Related Docs
- Full pipeline documentation: **GitHub Wiki**
- Main repository README
- Docker instructions: `dockerhub-README.md`

---

<p align="center"><b>cccTeqy — Fully Reproducible Epigenomics at HPC Scale</b></p>

