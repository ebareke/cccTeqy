# 🐳 Container Execution Guide — cccTeqy
This guide explains how to run the **cccTeqy** pipeline using **Docker** or **Singularity/Apptainer**. Container-based execution ensures full reproducibility, consistent software versions, and seamless deployment across workstations, servers, and HPC clusters.

---

# 🚀 1. Why Use Containers?
Containers provide:
- Fully pinned versions of all tools
- Identical behavior across systems
- No dependency conflicts
- Easy integration with HPC (Singularity)
- Fast setup for local testing

cccTeqy provides:
- **Dockerfile** (bring-your-own-config version)
- **Singularity definition file**
- **Container-optimized config.yaml example**

---

# 📦 2. Files Provided in This Repository
```
Dockerfile
Singularity
config.container.example.yaml
Makefile
```

### Containers include:
- bwa
- samtools
- bedtools
- fastqc
- macs2
- picard
- preseq
- deeptools
- Rscript
- phantompeakqualtools (run_spp.R)
- multiqc

Everything needed for the entire pipeline.

---

# 🐳 3. Running cccTeqy with Docker
Docker is ideal for local machines, development servers, or cloud.

## 3.1 Build the image
```bash
docker build -t cccteqy:latest .
```

Or pull a future public copy:
```bash
docker pull ebareke/cccteqy:latest
```

## 3.2 Recommended project layout
```
project/
 ├── config.yaml
 ├── samples.tsv
 ├── data/
 │    ├── fastq/
 │    └── ref/
 ├── outputs/
 └── run.sh     (optional override)
```

## 3.3 Running the pipeline
```bash
docker run --rm \
  -v $PWD:/work \
  -v /data:/data \
  -w /work \
  cccteqy:latest \
  ./run.sh -c config.yaml -s samples.tsv
```

### Explanation
- `/work` = mounted working directory
- `/data` = mounted FASTQs, references, large datasets

## 3.4 Quick tool test
```bash
docker run --rm cccteqy:latest fastqc --version
```

---

# 🛰️ 4. Running cccTeqy with Singularity/Apptainer
This is the **recommended** method for HPC clusters.

## 4.1 Build the image
```bash
singularity build cccteqy.sif Singularity
```

Apptainer version:
```bash
apptainer build cccteqy.sif Singularity
```

## 4.2 Running the pipeline
```bash
singularity exec \
  -B $PWD:/work \
  -B /data:/data \
  cccteqy.sif \
  ./run.sh -c config.yaml -s samples.tsv
```

### Inside SLURM jobs
```bash
singularity exec -B $PWD:/work cccteqy.sif bash run.sh --internal-run SAMPLEID
```

### Inside PBS jobs
```bash
apptainer exec -B $PWD:/work cccteqy.sif bash run.sh --internal-run SAMPLEID
```

---

# 🧬 5. Container-Specific Configuration File
### `config.container.example.yaml`
This config uses container paths (`/work`, `/data`):
```yaml
project_name: DemoContainerRun
outdir: /work/outputs
threads: 8
bwa_index: /data/ref/hg38/bwa/hg38
blacklist_bed: /data/ref/hg38/blacklist/hg38-blacklist.v2.bed
fastqc: fastqc
macs2: macs2
rscript: Rscript
phantompeak_rscript: /opt/conda/bin/run_spp.R
```

Adjust `/data/...` depending on reference locations.

---

# 📁 6. Working With Mounted Paths
### Good mounting strategy
```bash
-B $PWD:/work
-B /fastq:/fastq
-B /ref:/ref
```

### Important rules
- Never write inside the container → always write to `/work`
- Reference genomes should be on fast storage
- Avoid networked mounts for large jobs (if possible)

---

# 🔬 7. Common Container Issues & Solutions
### Problem: "FASTQ not found"
✔ Paths in samples.tsv must exist **inside** the container.  
Mount them accordingly.

### Problem: "MACS2 not found"
✔ Build the image again: `singularity build ...`

### Problem: "Permission denied"
✔ Use Apptainer with `--fakeroot` if needed.

### Problem: "Slow I/O"
✔ Ensure large files are on local SSDs or HPC fast storage.

---

# 🧠 8. Recommendations for Optimal Container Use
- Use Singularity on multi-user clusters
- Use Docker for reproducible dev/test on local workstations
- Keep `config.yaml` and `samples.tsv` version-controlled
- Always document container version used
- For large projects, store references in `/data/ref/`

---

# 🪐 Final Notes
Containers provide the most reliable and reproducible way to run the cccTeqy pipeline.

<p align="center"><b>Run anywhere. Reproduce everywhere.</b></p>

