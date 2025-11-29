# 📘 cccTeqy — GitHub Wiki (Full Bundle)
This document contains **the complete GitHub Wiki** for the cccTeqy pipeline.  
Each section corresponds to a **separate page** that you should copy into GitHub → Wiki.

You may split these into multiple pages:
- Home
- Installation
- Configuration Guide
- Sample Sheet Guide
- Workflow Internals
- QC Modules
- Developers Guide
- FAQ
- Troubleshooting

---

# 🏠 Home
Welcome to the **cccTeqy Wiki**, the official documentation for the futuristic, autonomous ChIP-seq / CUT&RUN / CUT&Tag pipeline.

This Wiki includes:
- Installation & Setup
- Execution Modes
- Configuration Guide
- Sample Sheet Guide
- Workflow Internals
- QC Modules Explained
- Developer Documentation
- FAQ & Troubleshooting

---

# ⚙️ Installation
cccTeqy supports three execution methods:
- Native (local machine)
- HPC (SLURM/PBS)
- Containers (Docker/Singularity)

## 1. Clone repository
```bash
git clone https://github.com/ebareke/cccTeqy.git
cd cccTeqy
chmod +x run.sh
```

## 2. Install dependencies
### Conda
```bash
mamba env create -f environment.yml
mamba activate cccteqy
```

### Docker
```bash
docker pull ebareke/cccteqy:latest
```

### Singularity
```bash
singularity build cccteqy.sif Singularity
```

---

# 📑 Configuration Guide
cccTeqy uses a single YAML file for all settings.

### Minimal Example
```yaml
project_name: ProjectX
outdir: outputs
run_mode: local
threads: 16
bwa_index: /path/to/hg38/bwa
blacklist_bed: /path/to/hg38-blacklist.bed
rscript: Rscript
phantompeak_rscript: run_spp.R
```

### Key Sections
- Execution Mode: `local`, `slurm`, `pbs`
- Tools: BWA, MACS2, Picard, Preseq…
- Genome settings: mito chr, blacklist
- Shift/extension settings for CUT&Tag/CUT&RUN

---

# 📄 Sample Sheet Guide
The file `samples.tsv` defines all input samples.

### Example
```
SAMPLE_ID FASTQ1 FASTQ2 ASSAY MARK CONTROL_ID LIBTYPE
S1 R1.fq.gz R2.fq.gz CUTTAG H3K27me3 None PE
S2 R1.fq.gz - CUTRUN H3K4me3 None SE
```

### Columns
| Column | Meaning |
|--------|---------|
| SAMPLE_ID | Unique name |
| FASTQ1 | Read 1 |
| FASTQ2 | Read 2 or `-` |
| ASSAY | CUTTAG / CUTRUN / ChIPseq |
| MARK | H3K27me3, H3K4me3, TF, etc. |
| CONTROL_ID | Matched control |
| LIBTYPE | PE or SE |

---

# 🔬 Workflow Internals
cccTeqy performs the following steps per sample:

1. **FastQC** — raw FASTQ QC
2. **BWA-MEM** alignment
3. **Filtering:**
   - Remove unwanted chromosomes
   - Remove mitochondria
   - MAPQ filtering
   - Blacklist filtering
   - Duplicate marking/removal
4. **QC Module Suite:**
   - Picard duplication metrics
   - Preseq complexity
   - deepTools fragment sizes
   - PhantomPeak cross-correlation (NSC/RSC)
   - FRiP score
5. **MACS2** peak calling
6. **deepTools bigWigs**
7. **MultiQC** report assembly

---

# 🧪 QC Modules Explained
### FastQC
Basic read quality metrics.

### Picard
Duplicate rates, optical duplicates.

### Preseq
Library complexity curves.

### deepTools
Coverage, fragment length distribution.

### PhantomPeakQualTools
Cross-correlation quality metrics (NSC, RSC) + fragment length estimation.

### FRiP
Fraction of reads in peaks.

---

# 👩‍💻 Developers Guide
cccTeqy is designed for easy extension.

### Add a new QC module
1. Add logic in `process_sample()`.
2. Validate tool presence in `validate_tools()`.
3. Store outputs in `qc/<sample>/`.
4. Optionally integrate with MultiQC.

### Add new peak caller
Copy MACS2 block → modify.

### Add new HPC backend
Use `run_slurm()` and `run_pbs()` as templates.

### Improve containers
Update Dockerfile + Singularity.

---

# ❓ FAQ
**Q: Does cccTeqy support SE and PE?**  
Yes.

**Q: Does it auto-detect marks for broad peaks?**  
Yes — e.g., H3K27me3 → MACS2 broad mode.

**Q: Can I disable certain QC modules?**  
If tools are missing, the module is skipped automatically.

**Q: Can it run on Windows?**  
Only through WSL2 or Docker.

---

# 🆘 Troubleshooting
**MACS2 outputs no peaks**  
- Low coverage?  
- Wrong genome size?  
- Wrong assay?  

**PhantomPeak errors**  
- Rscript not found  
- run_spp.R missing

**BWA can't find index**  
- Wrong path in `config.yaml`

**Pipeline stops early**  
- Check: `logs/<sample>.log`

---

<p align="center"><b>This completes the full GitHub Wiki bundle for cccTeqy.</b></p>

