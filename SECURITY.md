# SECURITY.md — Security Policy for cccTeqy

The **cccTeqy** project aims to provide a secure, reliable, and reproducible pipeline for epigenomic data processing. This document outlines how security issues should be reported, how they are handled, and what users should expect.

---

# 🔐 1. Supported Versions
Security updates apply to the **latest stable release** of cccTeqy.

| Version | Supported | Notes |
|---------|-----------|--------|
| v1.1.x  | ✔ Yes     | Actively maintained |
| v1.0.x  | ⚠ Partial | Bug fixes only; security patches if trivial |
| < v1.0  | ❌ No      | Pre-release / deprecated |

---

# 🛡 2. Reporting a Vulnerability
If you discover a potential security issue, please report it **privately**.

## Contact:
📧 **eb.bioinfo@pm.me**

Please include:
- Description of the issue
- Steps to reproduce
- Potential impact
- Suggested fix (if known)
- Your environment (OS, container use, HPC system)

We aim to acknowledge reports within **120 hours**.

---

# 🔍 3. What Is a Security Issue?
Security vulnerabilities may include:
- Pipeline execution leading to arbitrary code execution
- Malicious FASTQ or configuration file vectors
- Unsafe temporary file handling
- Insecure YAML parsing behavior
- Inadvertent data leakage during HPC or container execution
- Unsafe permissions or world-writable directories
- Misconfigured containers with exposed entrypoints

Not considered security issues:
- Incorrect pipeline results
- Missing features
- Resource overuse due to configuration
- Typos in documentation

---

# 🧪 4. Responsible Disclosure
We practice **coordinated disclosure**:
1. Issue reported privately
2. Maintainers investigate and patch
3. CVE requested if appropriate
4. Fix published
5. Public disclosure made **only after** user protection

---

# 🛠 5. Security Hardening (Best Practices)
Users should:
- Prefer **container execution** for isolation
- Avoid running as root unless required
- Bind-mount only what is needed
- Keep tools updated (bwa, samtools, macs2, Rscript, etc.)
- Use secure clusters / HPC authentication
- Avoid editing `run.sh` without understanding execution flow

---

# 🧱 6. Maintainer Responsibilities
cccTeqy maintainers will:
- Review vulnerability reports promptly
- Patch viable issues as soon as possible
- Coordinate safe disclosure
- Update the CHANGELOG with security patches

---

# 🪐 7. Final Note
Security is a shared responsibility. With your help, **cccTeqy** remains a safe and reliable pipeline for the epigenomics community.

Thank you for your vigilance.

<p align="center"><b>— The cccTeqy Maintainers</b></p>

