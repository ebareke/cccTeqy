# 🖥️ HPC Execution Guide — cccTeqy

This guide provides a complete reference for running the **cccTeqy** pipeline on High-Performance Computing (HPC) clusters using **SLURM** or **PBS** job schedulers.

cccTeqy is designed for large-scale processing of ChIP-seq, CUT&RUN, and CUT&Tag samples and includes **native HPC automation** through batch script generation.

---

# 🚀 1. Overview

cccTeqy supports three execution environments:

- **Local** (workstation/server)
- **SLURM** (sbatch)
- **PBS/Torque** (qsub)

To enable HPC execution, simply set in your `config.yaml`:

```yaml
run_mode: slurm
```

or

```yaml
run_mode: pbs
```

cccTeqy will automatically generate 1 job **per sample**, with all dependencies handled internally.

---

# ⚙️ 2. Requirements for HPC Execution

Your HPC environment must provide:

- A job scheduler (SLURM or PBS)
- Node access with required bioinformatics tools **or** container support (Singularity recommended)
- Sufficient compute resources:
  - CPUs: 4–32 per job
  - RAM: 8–32 GB per job
  - Scratch storage or fast I/O

For best reproducibility, use the **containerized execution** (Singularity).

---

# 🧩 3. SLURM Execution Mode

Set in `config.yaml`:

```yaml
run_mode: slurm
threads: 12
mem: 32G
```

## 3.1 Launching the Pipeline

From the repository root:

```bash
./run.sh -c config.yaml -s samples.tsv
```

cccTeqy will generate per-sample scripts in:

```
slurm_jobs/<sample>.sbatch
```

## 3.2 Example Generated SBATCH Script

```bash
#!/bin/bash
#SBATCH --job-name=S1
#SBATCH --output=logs/S1.%j.out
#SBATCH --error=logs/S1.%j.err
#SBATCH --cpus-per-task=12
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --partition=standard

bash run.sh --internal-run S1
```

## 3.3 Submitting All Jobs

cccTeqy automatically submits jobs unless disabled. If disabled:

```bash
find slurm_jobs -name "*.sbatch" -exec sbatch {} \;
```

---

# 📡 4. PBS Execution Mode

In `config.yaml`:

```yaml
run_mode: pbs
threads: 8
mem: 16G
```

## 4.1 Launch

```bash
./run.sh -c config.yaml -s samples.tsv
```

Generated scripts appear under:

```
pbs_jobs/<sample>.pbs
```

## 4.2 Example Generated PBS Script

```bash
#!/bin/bash
#PBS -N S1
#PBS -o logs/S1.out
#PBS -e logs/S1.err
#PBS -l nodes=1:ppn=8,mem=16gb,walltime=24:00:00

cd $PBS_O_WORKDIR
bash run.sh --internal-run S1
```

## 4.3 Submitting All Jobs

```bash
find pbs_jobs -name "*.pbs" -exec qsub {} \;
```

---

# 🧬 5. Recommended HPC Settings

### CPU Threads

- CUT&RUN/CUT&Tag: **8–16 threads** per sample
- TF ChIP-seq: **12–24 threads** per sample

### Memory

- FASTQ QC: 2–4 GB
- BWA alignment: 8–24 GB
- MACS2: 4–16 GB

### Runtime

- CUT&Run: 1–6 hours
- CUT&Tag: 1–3 hours
- ChIP-seq (deep): up to 12–24 hours

---

# 🐳 6. Using Singularity on HPC

Singularity is the **recommended** way to run cccTeqy on HPC.

## Example Command

```bash
singularity exec \
  -B $PWD:/work -B /data:/data \
  cccteqy.sif \
  ./run.sh -c config.yaml -s samples.tsv
```

## Within SLURM

```bash
singularity exec -B $PWD:/work cccteqy.sif bash run.sh --internal-run S1
```

## Within PBS

```bash
apptainer exec -B $PWD:/work cccteqy.sif bash run.sh --internal-run S1
```

---

# 📁 7. Directory Structure on HPC

cccTeqy creates organized folders:

```
outputs/
 ├── align/
 ├── qc/
 ├── peaks/
 ├── bigwig/
 ├── logs/
 ├── slurm_jobs/   (if slurm)
 └── pbs_jobs/     (if pbs)
```

---

# 🧠 8. Tips for Large Projects (>50 samples)

### Use an HPC-friendly filesystem:

- Lustre / GPFS / BeeGFS recommended
- Avoid NFS for alignment I/O

### Stagger submissions:

```bash
sleep 0.5
```

between submissions if needed.

### Avoid overloading login nodes:

Always run from compute nodes when testing.

---

# 🛠️ 9. Troubleshooting (HPC-specific)

### Jobs fail immediately

- Wrong partition or queue
- Missing resource limits in config

### Slow performance

- Network filesystem bottleneck
- Too many simultaneous I/O jobs

### Singularity errors

- Use `--containall` or `--cleanenv`
- Missing bind mounts (`-B`)

### MACS2 memory errors

- Increase `mem:` in config.yaml

---

