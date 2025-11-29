# 🌟 Best Practices for Running cccTeqy

A curated collection of recommendations to help you obtain the **highest‑quality results** from the cccTeqy autonomous ChIP‑seq / CUT&RUN / CUT&Tag pipeline.

Whether you are generating new data or reprocessing existing datasets, these guidelines ensure reproducibility, optimal performance, and scientifically trustworthy outcomes.

---

# 🧬 1. Experimental Best Practices

High‑quality computational output begins with high‑quality wet‑lab input.

### Do:

- Use **fresh, high‑quality nuclei** or chromatin preparations.
- Target **10–30 million reads** for TF ChIP‑seq.
- Target **5–15 million reads** for CUT&RUN.
- Target **3–10 million reads** for CUT&Tag.
- Use proper **negative controls**:
  - IgG (ChIP‑seq)
  - No‑antibody (CUT&RUN)
  - Tn5‑only (CUT&Tag)
- Validate antibody specificity (ENCODE‑validated if possible).

### Avoid:

- Over‑fixation → kills epitope accessibility.
- Under‑fixation → high noise.
- Over‑amplification → excessive duplicates.
- Very low input (<10k cells) without optimization.

---

# 🧹 2. File & Reference Best Practices

### Reference Genome

- Use genome builds matching your organism: hg38, mm10, etc.
- Avoid mixing builds (e.g., hg19 peaks vs hg38 FASTQs).
- Ensure BWA index was built on the **same FASTA** you're using.

### Blacklist Regions

- Always provide the correct species blacklist.
- Never skip blacklist removal.

### FASTQ Management

- Use `.fastq.gz` only.
- Avoid hidden whitespace or illegal characters in filenames.
- Ensure R1 and R2 are properly paired.

---

# ⚙️ 3. Configuration Best Practices

### General Guidelines

- Always run with **threads: ≥ 8** if possible.
- Ensure all tool paths are correct in `config.yaml`.
- Keep a separate config file per project for reproducibility.

### CUT&Tag / CUT&RUN Shift & Extension

Correct settings:

```yaml
shift_extend_cuttag: --shift -75 --extsize 150
shift_extend_cutrun: ""
```

CUT&Tag requires Tn5‑based shift correction. CUT&RUN typically does **not**.

### QC Thresholds to Monitor

| Metric         | Good   | Warning  | Bad            |
| -------------- | ------ | -------- | -------------- |
| Alignment Rate | >80%   | 60–80%   | <60%           |
| Duplicates     | <40%   | 40–70%   | >70%           |
| FRiP           | varies | depends  | <1% always bad |
| RSC            | >1.0   | 0.5–1.0  | <0.5           |
| NSC            | >1.1   | 1.05–1.1 | <1.05          |

---

# 🖥️ 4. Runtime & System Best Practices

### Local Execution

- Use SSD storage for FASTQ and BAM files.
- Avoid running on laptops with low RAM (<16 GB).

### HPC Execution

- Use `run_mode: slurm` or `run_mode: pbs` for large batches.
- Submit **one job per sample** via generated job scripts.
- Bind reference data from fast network storage.

### Container Execution

- Prefer Singularity for HPC clusters.
- Always mount paths explicitly:

```bash
-B $PWD:/work -B /data:/data
```

---

# 📈 5. QC Interpretation Best Practices

### When in doubt, combine:

- **Cross‑correlation (NSC/RSC)** → signal strength
- **FRiP** → biological success
- **Preseq** → library complexity
- **Picard** → duplication health
- **Fragment size** → nucleosomal patterns

### Common Scenarios

- High duplicates + flat Preseq → library collapse.
- Low alignment + low FRiP → contamination or antibody failure.
- Strong nucleosome peaks + low noise → excellent CUT&RUN.
- Very short fragments + high enrichment → good CUT&Tag.

---

# 🧪 6. Peak Calling Best Practices

### For TF ChIP‑seq

Use narrow peaks:

```yaml
macs2_qval: 0.01
```

### For broad histone marks (H3K27me3/H3K9me3)

Enable broad mode (cccTeqy does this automatically):

```yaml
macs2_broad_qval: 0.1
```

### For CUT&RUN / CUT&Tag

Shift‑corrected alignment improves peak shape.

---

# 🧬 7. Reproducibility Best Practices

- Version‑lock your:
  - container image
  - config.yaml
  - genome files
- Document:
  - software versions
  - reference genome sources
  - command line inputs
- Deposit configurations for publication.

### Always archive:

```
config.yaml
samples.tsv
outputs/multiqc/*
logs/*
```

---

# 💡 8. Troubleshooting Best Practices

### Few peaks

- Increase sequencing depth.
- Check antibody quality.
- Verify correct assay mode.

### Bad QC metrics

- Re‑evaluate library preparation.
- Ensure genome build correctness.
- Check for contamination.

### PhantomPeak failure

- Install run\_spp.R properly.
- Ensure Rscript path is correct.

---

# 🪐 Final Thoughts

High‑quality epigenomic analysis relies on **good experimental design**, **careful QC review**, and **consistent computational workflow settings**.

cccTeqy provides all the structure you need—these best practices ensure you get the most out of it.

