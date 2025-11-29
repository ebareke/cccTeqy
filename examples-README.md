# 📁 Examples — cccTeqy Example Dataset & Usage Guide
This directory contains example files and instructions to help you quickly test and validate the **cccTeqy** pipeline.

These examples are **synthetic / placeholder** demonstrations designed to show how to structure your files, not to be used for real biological inference.

---

# 🎯 Purpose of This Examples Folder
- Provide a **minimal runnable dataset** for pipeline testing
- Demonstrate correct `samples.tsv` formatting
- Show expected directory structure
- Enable rapid validation of HPC and container modes
- Allow developers to test modifications to `run.sh`

---

# 📁 1. Example Folder Structure
Place the following inside `examples/` in the repository:

```
examples/
 ├── data/
 │    ├── fastq/
 │    │     ├── sample1_R1.fastq.gz
 │    │     ├── sample1_R2.fastq.gz
 │    │     ├── sample2_R1.fastq.gz
 │    │     └── sample2_R2.fastq.gz
 │    └── ref/
 │          ├── hg38.fa
 │          ├── bwa_index/    # bwa index files
 │          └── hg38-blacklist.v2.bed
 │
 ├── config.example.yaml
 └── samples.example.tsv
```

---

# 📄 2. Example `samples.example.tsv`
```
SAMPLE_ID	FASTQ1	FASTQ2	ASSAY	MARK	CONTROL_ID	LIBTYPE
example1	./data/fastq/sample1_R1.fastq.gz	./data/fastq/sample1_R2.fastq.gz	CUTTAG	H3K27me3	None	PE
example2	./data/fastq/sample2_R1.fastq.gz	./data/fastq/sample2_R2.fastq.gz	CUTTAG	H3K27me3	None	PE
```

---

# ⚙️ 3. Example `config.example.yaml`
This config is ready to run inside the repository (with minimal edits to paths):

```yaml
project_name: cccTeqyExample
outdir: ./outputs_examples
run_mode: local
threads: 4
max_jobs: 10

bwa_index: ./examples/data/ref/bwa_index/hg38
blacklist_bed: ./examples/data/ref/hg38-blacklist.v2.bed
genome_size: hs
mito_chr: chrM
chroms_keep_list: ""

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
phantompeak_rscript: run_spp.R

min_mapq: 30
remove_duplicates: 1
macs2_qval: 0.01
macs2_broad_qval: 0.1
shift_extend_cutrun: ""
shift_extend_cuttag: --shift -75 --extsize 150

pipeline_script: ./run.sh
```

---

# 🚀 4. Running the Example Dataset
Run from repository root:

```bash
./run.sh -c examples/config.example.yaml -s examples/samples.example.tsv
```

Output will appear in:
```
outputs_examples/
```

---

# 🧪 5. Expected Outputs
After running the example dataset, you should see:

```
outputs_examples/
 ├── align/
 ├── qc/
 ├── peaks/
 ├── bigwig/
 ├── logs/
 └── multiqc/
```

Each module should run successfully, providing confidence that:
- YAML parsing works
- Sample sheet parsing works
- FASTQ → BAM alignment works
- QC modules work
- MACS2 runs correctly
- Containers (if used) are functional

---

# ⚠️ Notes
- Example FASTQs should be **tiny ZIP compressed mock datasets** (<100 kB each).
- Example reference (`hg38.fa`) should be **truncated** for lightweight testing.
- **Do not** use these files for biological analysis.

---

# 🪐 Final Note
The examples folder provides a simple, standardized test environment that ensures cccTeqy runs correctly before executing full datasets.

<p align="center"><b>Happy testing!</b></p>

