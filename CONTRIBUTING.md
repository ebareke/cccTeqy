# CONTRIBUTING.md — Contributing to cccTeqy

Thank you for your interest in contributing to **cccTeqy**, the autonomous ChIP‑seq / CUT&RUN / CUT&Tag pipeline. We welcome contributions from bioinformaticians, developers, researchers, and engineers.

This document outlines the guidelines and workflow for contributing.

---

# 🧱 How to Contribute

There are many ways to contribute:

- Reporting bugs
- Requesting new features
- Improving documentation
- Optimizing code
- Adding new QC modules
- Adding support for new assays or file formats
- Enhancing HPC integration (SLURM/PBS)
- Extending container support

---

# 🐛 1. Reporting Issues

Open a GitHub issue at: 👉 [https://github.com/ebareke/cccTeqy/issues](https://github.com/ebareke/cccTeqy/issues)

When reporting a bug, include:

- Pipeline version (`run.sh` header + CHANGELOG entry)
- Execution mode (local / slurm / pbs / container)
- System type (Linux distro, cluster environment)
- Full command used
- Relevant logs (`outputs/logs/*.log`)
- config.yaml and samples.tsv (if possible)

---

# 💡 2. Requesting New Features

Feature requests are welcome. Please provide:

- Motivation
- Expected behavior
- Whether the feature affects workflow logic, QC, or containerization
- Example datasets (optional)

---

# 🔧 3. Submitting Code Changes (Pull Requests)

Follow these steps:

### **A. Fork the repository**

```bash
git clone https://github.com/YOUR_USERNAME/cccTeqy.git
```

### **B. Create a feature branch**

```bash
git checkout -b feature/my-enhancement
```

### **C. Make changes**

Commit early and often.

### **D. Ensure code passes validation**

- Run `shellcheck` on `run.sh`
- Validate YAML structures
- Test on a minimal FASTQ dataset
- Run at least one containerized execution

### **E. Submit Pull Request**

Explain:

- What you changed
- Why the change is needed
- How it was tested

PRs must be linked to an Issue whenever possible.

---

# 🧪 4. Adding a New QC Module

New QC modules are welcome. Include:

- Tool name and version
- Output files
- Where in the workflow it executes
- Required command-line flags
- How it integrates with MultiQC (optional)

---

# 🐳 5. Contributing to Containers

If modifying: `Dockerfile`, `Singularity`, or `environment.yml`:

- Ensure all tools are pinned to specific versions
- Verify image builds successfully
- Run test jobs
- Update container README files if necessary

---

# 🧬 6. Documentation Improvements

You can improve:

- README.md
- Wiki pages
- In‑code comments
- Example configs
- Troubleshooting guides

Documentation contributions are **highly appreciated**.

---

# 🤝 Code of Conduct

All contributors must follow the repository’s Code of Conduct.

---

# 🪐 Thank You

Every contribution — small or large — helps strengthen the cccTeqy pipeline.

Let’s build the future of autonomous epigenomics together.

