# 📜 CHANGELOG — cccTeqy Pipeline
All notable changes to the **cccTeqy** autonomous epigenomics pipeline are documented here.

This project follows **semantic versioning** and a structured changelog format.

---

## 🚀 **v1.1.0 — Complete Pipeline Expansion & Documentation Overhaul**
**Release Date:** 2025-02-01

### ✨ Major Enhancements
- Fully rewritten `README.md` with futuristic visuals, diagrams, and complete documentation.
- Added comprehensive **GitHub Wiki** (Installation, Configuration, Workflow, QC Modules, FAQ…).
- Added **Dockerfile** (BYO-config) and **Singularity definition** for reproducible container execution.
- Added **config.container.example.yaml** optimized for container use.
- Added **Makefile** for automated Docker/Singularity builds.
- Added **environment.yml** for Conda users.
- Added full set of SVG diagrams and banners.

### 🧪 Pipeline Improvements
- Improved integration of:
  - Picard duplication metrics
  - Preseq library complexity
  - deepTools fragment size profiles
  - PhantomPeak cross-correlation QC
  - FRiP scoring (automatic peak-type detection)
- Smarter mark classification (auto-broad for H3K27me3/H3K9me3).
- Expanded error handling and validation for missing tools.
- Improved SLURM and PBS job generation stability.

### 📚 Documentation Additions
- Complete Wiki bundle added to repository.
- Container README pages generated:
  - `dockerhub-README.md`
  - `singularityhub-README.md`
- New comprehensive repository README.

---

## 🧬 **v1.0.0 — Initial Public Release**
**Release Date:** 2024-12-19

### 🎉 Initial Features
- End-to-end support for **ChIP-seq**, **CUT&RUN**, and **CUT&Tag** workflows.
- Input sample sheet parsing with SE/PE support.
- Core processing modules:
  - FastQC
  - BWA-MEM alignment
  - Read filtering + mito removal
  - Blacklist exclusion
  - MACS2 peak calling (narrow/broad)
  - bigWig generation
  - MultiQC summary
- HPC support:
  - SLURM job generation
  - PBS job generation
- YAML-based configuration system (no code editing required).

---

## 🌌 **Planned Features (v1.2+ Roadmap)**
### 🔮 Pipeline Features
- Optional **AI-based peak QC** (deep learning noise classifier for CUT&Tag).
- ENCODE-style QC metrics: NRF, PBC1, PBC2.
- Support for additional aligners (Bowtie2, HISAT2).
- Optional output packaging into HTML report.

### 📦 Containerization
- Pre-built Docker Hub container (`ebareke/cccTeqy`).
- Additional testing pipeline for container versions.

### 📘 Documentation
- Full **User Guide PDF**
- Dedicated **Developer Documentation** (`docs/architecture.md`)

---

> For bug reports, feature requests, and contributions:
> 👉 https://github.com/ebareke/cccTeqy/issues