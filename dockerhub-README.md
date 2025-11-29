# 🐳 cccTeqy — Docker Hub README

**Image:** `ebareke/cccteqy:latest`  
**Repository:** https://github.com/ebareke/cccTeqy

cccTeqy is a **fully autonomous**, **HPC-ready**, and **container-friendly** pipeline for processing **ChIP-seq**, **CUT&RUN**, and **CUT&Tag** datasets. This Docker image bundles all required tools and provides a reproducible environment for executing the pipeline.

---

# 🚀 Features
- Complete end-to-end processing:
  - FASTQ → BAM → Peaks → QC → bigWigs → MultiQC
- Includes:
  - `bwa`, `samtools`, `bedtools`
  - `fastqc`, `macs2`
  - `picard`, `preseq`
  - `deepTools` (`bamCoverage`, `bamPEFragmentSize`)
  - `phantompeakqualtools` (`run_spp.R`)
  - `Rscript`, `multiqc`
- Lightweight & reproducible
- BYO-config (bring-your-own config.yaml & samples.tsv)
- Supports SE & PE libraries
- Works identically across Linux, HPC, and cloud environments

---

# 📦 Pulling the Image
```bash
docker pull ebareke/cccteqy:latest
```

---

# 📁 Recommended Directory Layout
```
/your/project/
 ├── config.yaml
 ├── samples.tsv
 ├── run.sh           # optional: only needed if overriding container's
 ├── data/
 │    ├── fastq/
 │    └── ref/
 └── outputs/
```

---

# ⚙️ Running the Pipeline (Recommended)
Run from inside your local project directory:
```bash
docker run --rm \
  -v $PWD:/work \
  -v /data:/data \
  -w /work \
  ebareke/cccteqy:latest \
  ./run.sh -c config.yaml -s samples.tsv
```

### Folder bindings explained:
- `-v $PWD:/work` → Your project directory appears inside the container at `/work`
- `-v /data:/data` → Mounts reference genome & large shared datasets
- `-w /work` → Ensures pipeline executes relative to your project

---

# 🧬 Example config.yaml (Inside Container)
```yaml
project_name: DemoContainerRun
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

# 📄 Example samples.tsv
```
SAMPLE_ID FASTQ1 FASTQ2 ASSAY MARK CONTROL_ID LIBTYPE
ex1 /data/fastq/ex1_R1.fq.gz /data/fastq/ex1_R2.fq.gz CUTTAG H3K27me3 None PE
ex2 /data/fastq/ex2_R1.fq.gz /data/fastq/ex2_R2.fq.gz CUTTAG H3K27me3 None PE
```

---

# 🔬 Quick Test
To verify that the container works:
```bash
docker run --rm cccteqy:latest fastqc --version
```
Or:
```bash
docker run --rm cccteqy:latest macs2 --help
```

---

# 🛠 Overriding the Pipeline Script
If you want to use a custom version of `run.sh`:
```bash
docker run --rm \
  -v $PWD:/work -w /work \
  ebareke/cccteqy:latest \
  bash my_run.sh -c config.yaml -s samples.tsv
```

---

# 🧹 Cleaning Up
Remove all stopped containers:
```bash
docker container prune
```
Remove unused layers:
```bash
docker system prune -a
```

---

# 🧭 Troubleshooting
### "Tool not found"
Ensure that you are running commands **inside** the container.

### Slow performance
Bind directories using local SSDs instead of network drives.

### Cannot find FASTQ or reference files
Verify that you mounted the correct host paths.

---

# 🔗 Further Documentation
- Full pipeline documentation: **GitHub Wiki**
- Main README: included in repository
- Singularity documentation: `singularityhub-README.md`

---

<p align="center"><b>cccTeqy — The Future of Automated Epigenomics</b></p>

