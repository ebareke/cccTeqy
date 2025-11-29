# 🏗️ cccTeqy Architecture
A technical overview of the internal structure, logic, and modular design of the **cccTeqy** pipeline.

This document is intended for developers, power users, and contributors who want to understand how the pipeline works internally or extend it with new features.

---

# 🔬 1. Architectural Philosophy
**cccTeqy** is built around four core principles:

1. **Transparency** — Everything controlled via a single Bash script (`run.sh`).
2. **Modularity** — QC modules, peak callers, and processing steps are plug‑and‑play.
3. **Reproducibility** — Deterministic execution via YAML configs, containers, and logs.
4. **Scalability** — Seamless execution on local machines or HPC (SLURM/PBS).

---

# 🧱 2. High-Level Pipeline Structure
```
run.sh
 ├── parse_config()
 ├── parse_samples()
 ├── validate_tools()
 ├── process_sample()               # Main per-sample engine
 ├── run_local()                    # Local execution mode
 ├── run_slurm()                    # SLURM job generator
 ├── run_pbs()                      # PBS job generator
 └── generate_multiqc()             # Final QC consolidation
```

---

# 🧩 3. Core Components
## 3.1 Configuration Layer (YAML)
cccTeqy uses a **minimal internal YAML parser**:
- Reads `config.yaml`
- Converts keys → environment variables
- No external dependencies (`yq` **not** required)

Configuration controls:
- Paths to tools
- HPC behavior
- QC modules
- Genome reference
- MACS2 parameters
- Output directories

---

## 3.2 Sample Parsing Engine (`samples.tsv`)
- Accepts **tab‑separated** format
- Supports SE and PE libraries
- Detects missing or malformed lines
- Builds an internal array of job specifications

Example parsed into memory:
```
sample_id = "T_706_9553L"
r1 = "...R1.fq.gz"
r2 = "...R2.fq.gz"
assay = "CUTTAG"
mark = "H3K27me3"
control = "None"
libtype = "PE"
```

---

# ⚙️ 4. The `process_sample()` Engine
This function executes **everything** for each sample.

## Modules executed internally:
### 4.1 FASTQ QC
- FastQC
- Output → `qc/<sample>/fastqc/`

### 4.2 Alignment
- BWA‑MEM (PE/SE detection)
- Sorting + indexing

### 4.3 Filtering
- Chromosome keep list
- Mitochondrial removal
- MAPQ filtering
- Blacklist removal
- Duplicate marking/removal

### 4.4 QC Modules
- Picard duplication metrics
- Preseq complexity estimation
- Fragment size (deepTools)
- PhantomPeak cross‑correlation (run_spp.R)
- FRiP score calculation

### 4.5 Peak Calling
- MACS2 narrow peaks
- MACS2 broad peaks (auto‑selected for H3K27me3/H3K9me3)

### 4.6 bigWig Generation
- Uses deepTools: `bamCoverage`

---

# 🧵 5. MultiQC Integration
Once all samples finish:
- MultiQC scans: FASTQ, BAM, peaks, QC metrics
- Summaries saved to: `outputs/multiqc/`

---

# 🧰 6. HPC Backends
cccTeqy dynamically generates job scripts when `run_mode` is set to **slurm** or **pbs**.

## 6.1 SLURM Mode
Generates for each sample:
```
#SBATCH --job-name=<sample>
#SBATCH --cpus-per-task=<threads>
#SBATCH --mem=<mem>
...
```
Then runs the same `process_sample()` logic inside each HPC job.

## 6.2 PBS Mode
Generates:
```
#PBS -N <sample>
#PBS -l nodes=1:ppn=<threads>,mem=<mem>
...
```
Also executes the sample internally.

---

# 🐳 7. Container Architecture
cccTeqy supports both Docker and Singularity.

## 7.1 Docker
- Based on `mambaorg/micromamba`
- Installs: bwa, samtools, bedtools, macs2, fastqc, picard, preseq, deepTools, phantomPeak, Rscript
- Only `run.sh` is copied
- Users bind‑mount configs/data

## 7.2 Singularity
- Built from Docker base
- Same package stack
- Runs pipeline via runscript

---

# 📡 8. Directory Structure (Runtime)
```
outputs/
 ├── align/
 ├── qc/
 ├── peaks/
 ├── bigwig/
 ├── multiqc/
 └── logs/
```
Each module writes outputs to its designated folder for maximum clarity.

---

# 🧬 9. Extending the Pipeline
### Adding a new QC module:
1. Implement logic inside `process_sample()`
2. Add tool detection in `validate_tools()`
3. Save outputs to `qc/<sample>/`
4. Update MultiQC config (optional)

### Adding new peak callers:
- Copy MACS2 block
- Modify parameters/tool invocations
- Adjust output folder naming

### Adding new execution backends:
- Follow the structure of SLURM/PBS wrappers
- Bind to same `process_sample()` core

---

# 🛰️ 10. Design Choices
- **Single Bash driver** → universal portability
- **Minimal dependencies** → no external YAML parser required
- **Container-first** philosophy → reproducibility
- **HPC‑aware** logic → efficient scaling on clusters
- **Modular QC** → easy to extend and maintain

---

# 🪐 Final Notes
cccTeqy’s architecture balances flexibility, reproducibility, and raw performance.

This document should serve as the reference for developers and contributors working to expand or optimize the pipeline.

<p align="center"><b>The future of automated epigenomics is modular.</b></p>

