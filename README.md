# 🚀 **cccTeqy — Autonomous ChIP-seq / CUT&RUN / CUT&Tag Pipeline**

> **NGS data — Processing Automation Engine**\
> Full-stack, production-grade, HPC-enabled epigenomics automation pipeline.

**cccTeqy** is a **fully automated**, **modular**, and **high-performance** pipeline designed to process **ChIP-seq**, **CUT&RUN**, and **CUT&Tag** datasets at scale — from raw FASTQ to publication-ready QC metrics, peak calls, bigWigs, and consolidated MultiQC reports.

This README reflects the **latest full pipeline implementation**, built around the main Bash script:\
📌 **run.sh**** — the central engine of cccTeqy**

---

# 🧬 Futuristic Pipeline Banner


<svg width="1000" height="260" viewBox="0 0 1000 260" xmlns="http://www.w3.org/2000/svg">
  <defs><linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stop-color="#00eaff"/><stop offset="100%" stop-color="#7f00ff"/></linearGradient></defs>
  <rect width="1000" height="260" rx="22" fill="#0b0f19" stroke="url(#grad)" stroke-width="4"/>
  <text x="500" y="70" font-size="40" fill="url(#grad)" text-anchor="middle">cccTeqy Pipeline</text>
  <text x="500" y="115" font-size="18" fill="#cfd8dc" text-anchor="middle">Autonomous Epigenomic Processing Engine</text>
  <circle cx="150" cy="180" r="45" fill="#111827" stroke="#00eaff" stroke-width="3"/><text x="150" y="186" fill="#00eaff" text-anchor="middle">QC</text>
  <circle cx="350" cy="180" r="45" fill="#111827" stroke="#06d6a0" stroke-width="3"/><text x="350" y="186" fill="#06d6a0" text-anchor="middle">Align</text>
  <circle cx="550" cy="180" r="45" fill="#111827" stroke="#ffb703" stroke-width="3"/><text x="550" y="186" fill="#ffb703" text-anchor="middle">Filter</text>
  <circle cx="750" cy="180" r="45" fill="#111827" stroke="#ff007f" stroke-width="3"/><text x="750" y="186" fill="#ff007f" text-anchor="middle">Peaks</text>
  <circle cx="900" cy="180" r="45" fill="#111827" stroke="#8cff00" stroke-width="3"/><text x="900" y="186" fill="#8cff00" text-anchor="middle">Reports</text>
</svg>


---

# ✨ Features

- **Full Workflow Automation:** FASTQ → Peaks/QC/bigWigs/MultiQC
- **Supports ChIP-seq, CUT&RUN, CUT&Tag**, SE & PE
- **Unified YAML-based configuration** (no code editing)
- **Local + HPC support:** SLURM & PBS
- **Advanced QC suite:**
  - FastQC
  - Picard duplication metrics
  - Preseq library complexity
  - deepTools fragment profiling
  - PhantomPeak cross-correlation (NSC, RSC)
  - FRiP scoring
  - MultiQC
- **Peak Calling:** MACS2 (narrow/broad)
- **Container-ready:** Docker & Singularity configurations included
- **Production documentation stack:** README, CHANGELOG, WIKI

---

# 📁 Repository Structure

```
cccTeqy/
│
├── run.sh                         # Main pipeline script
├── config.yaml                    # Example config
├── config.container.example.yaml  # Container-optimized config
├── samples.tsv                    # Example sample sheet
│
├── Dockerfile                     # Docker build file
├── Singularity                    # Singularity definition file
├── environment.yml                # Conda environment
├── Makefile                       # Docker/Singularity build automation
│
├── README.md                      # Main documentation (this file)
├── CHANGELOG.md                   # Version history
└── wiki/                          # Exported GitHub Wiki pages
```

---

# 🔧 Requirements (Native Execution)

Install system tools if not using containers:

- **bwa**, **samtools**, **bedtools**
- **fastqc**, **macs2**
- **picard**, **preseq**
- **deepTools**: `bamCoverage`, `bamPEFragmentSize`
- **Rscript**, **phantompeakqualtools** (`run_spp.R`)
- **multiqc**

### Conda option

```bash
mamba env create -f environment.yml
mamba activate cccteqy
```

---

# ⚙️ Quick Start (Native Mode)

### 1. Configure the pipeline

A minimal working `config.yaml`:

```yaml
project_name: MyProject
outdir: outputs
run_mode: local
threads: 16
bwa_index: /path/to/hg38/bwa/index
blacklist_bed: /path/to/hg38/blacklist.bed
rscript: Rscript
phantompeak_rscript: /opt/tools/run_spp.R
```

### 2. Prepare your sample sheet

```
SAMPLE_ID FASTQ1 FASTQ2 ASSAY MARK CONTROL_ID LIBTYPE
S1 R1.fq.gz R2.fq.gz CUTTAG H3K27me3 None PE
```

### 3. Run pipeline

```bash
./run.sh -c config.yaml -s samples.tsv
```

### 4. Single-sample processing

```bash
./run.sh -c config.yaml -s samples.tsv --run-single S1
```

---

# 🐳 Docker Execution

The repository includes a **BYO-config Dockerfile**.

### Build

```bash
docker build -t cccteqy:latest .
```

### Run

```bash
docker run --rm \
  -v $PWD:/work -v /data:/data -w /work \
  cccteqy:latest ./run.sh -c config.yaml -s samples.tsv
```

More details: **dockerhub-README.md**

---

# 📦 Singularity Execution

### Build

```bash
singularity build cccteqy.sif Singularity
```

### Run

```bash
singularity exec -B $PWD:/work -B /data:/data cccteqy.sif \
  ./run.sh -c config.yaml -s samples.tsv
```

More details: **singularityhub-README.md**

---

# 🧪 Workflow Overview

```
FASTQ → FastQC → BWA → Filtering → Picard → Preseq → Fragment Size → Cross-Correlation
       → MACS2 → FRiP → bigWig → MultiQC
```

---

# 📚 Documentation

Full documentation available in the **GitHub Wiki**, including:

- Installation
- Configuration guide
- Sample sheet guide
- QC module explanations
- Developer documentation
- Troubleshooting

Wiki pages also included locally under `wiki/`.

---

# 🔥 Changelog

See [`CHANGELOG.md`](./CHANGELOG.md).

---

# 🧱 Container-Based Configuration Example

A lightweight configuration specifically for use inside Docker/Singularity:

```yaml
project_name: DemoContainerRun
outdir: /work/outputs
run_mode: local
threads: 8
bwa_index: /data/ref/hg38/bwa/hg38
blacklist_bed: /data/ref/hg38/blacklist/hg38-blacklist.v2.bed
rscript: Rscript
phantompeak_rscript: /opt/conda/bin/run_spp.R
```

---

# 🤝 Contributing

We welcome:

- New QC modules
- New peak callers
- Workflow optimizations
- Container enhancements
- Documentation improvements

Contribute here:\
👉 [https://github.com/ebareke/cccTeqy/issues](https://github.com/ebareke/cccTeqy/issues)

---

# 🪐 License

MIT License — open, reusable, extensible.

---

