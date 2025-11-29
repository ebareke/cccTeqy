# 🧬 ChIP‑seq vs CUT&RUN vs CUT&Tag — Comparative Guide
A technical and biological comparison of the three main epigenomic profiling assays supported by **cccTeqy**.

Use this document to understand assay differences, expected outputs, QC behavior, and how the pipeline adapts to each method.

---

# 🏁 Overview Table
| Feature | **ChIP‑seq** | **CUT&RUN** | **CUT&Tag** |
|---------|--------------|-------------|-------------|
| Sample size | Medium–high | Low | Very low |
| Background noise | High | Very low | Very low |
| Resolution | ~150–300 bp | ~20–80 bp | ~20–80 bp |
| Cell input | 10⁵–10⁷ | 10³–10⁵ | 10²–10⁴ |
| Fragmentation | Sonication | Enzyme (MNase) | Tn5 tagmentation |
| Workflow complexity | High | Medium | Low |
| Peak quality | Medium | High | Very high |
| Cost | Moderate | Low | Low |
| Best for | TF & histone marks | Histone marks & TFs | TFs, histones, single-cell |
| Typical read depth | 20–40M | 5–15M | 3–10M |

---

# 🔬 1. ChIP‑seq
Chromatin Immunoprecipitation followed by sequencing.

## ⚙️ Mechanism
1. Crosslink protein–DNA interactions.
2. Fragment chromatin **via sonication**.
3. Immunoprecipitate target protein with antibody.
4. Reverse crosslinks → purify DNA.

## ⭐ Strengths
- Highly established & widely used.
- Robust for transcription factors.
- Supports both narrow & broad peaks.

## ⚠️ Weaknesses
- High background noise.
- Requires large cell numbers.
- Sonication introduces bias.

## 🧪 Expected QC Behavior
- Fragment size: broad distribution (~200 bp)
- Duplicates: moderate to high (20–60%)
- FRiP: ~1–15% for TF, ~10–40% for histones
- Cross-correlation: NSC 1.05–1.3, RSC ≥0.8

## 🧰 cccTeqy settings
- Uses **MACS2 narrow peaks** by default.
- `shift_extend_cutrun` and `shift_extend_cuttag` disabled.

---

# 🧬 2. CUT&RUN
Cleavage Under Targets and Release Using Nuclease.

## ⚙️ Mechanism
1. Antibody binds target protein inside permeabilized nuclei.
2. Protein A-MNase binds antibody.
3. MNase digests nearby chromatin.
4. Released fragments diffuse out for sequencing.

## ⭐ Strengths
- Extremely low background.
- Requires very few cells.
- High signal-to-noise.
- Strong nucleosome positioning information.

## ⚠️ Weaknesses
- MNase digestion conditions must be tightly controlled.
- QC varies across labs.

## 🧪 Expected QC Behavior
- Fragment size: clear mono‑ and di‑nucleosome peaks
- Low duplicates (<40%)
- High FRiP (20–60%)
- Strong cross‑correlation signal

## 🧰 cccTeqy settings
- Uses **MACS2 narrow or broad peaks** depending on mark.
- No shift/extension unless user overrides.

---

# 🧬 3. CUT&Tag
Cleavage Under Targets and Tagmentation.

## ⚙️ Mechanism
1. Antibody binds target protein.
2. Protein A‑Tn5 transposase binds antibody.
3. Tn5 simultaneously cuts & inserts sequencing adapters.

## ⭐ Strengths
- Ultra‑low background.
- Works from very few cells (even single‑cell).
- Very high resolution (Tn5 footprint).
- Gentle on chromatin.

## ⚠️ Weaknesses
- Very sensitive to adapter dimers.
- Short fragments require proper shift correction.

## 🧪 Expected QC Behavior
- Fragment size: short (50–200 bp)
- Duplication: can be high (>50%) due to over‑tagmentation
- FRiP: often very high (30–70%)
- Alignment rates: excellent (>90%)

## 🧰 cccTeqy settings
CUT&Tag requires **shift+extension**:
```yaml
shift_extend_cuttag: --shift -75 --extsize 150
```
cccTeqy applies this automatically unless overridden.

---

# 🎛 How cccTeqy Chooses Peak Types
cccTeqy automatically applies **broad peak mode** for:
- H3K27me3
- H3K9me3

All other marks default to **narrow peaks**.

---

# 📈 Recommended Read Depth
| Assay | TF Targets | Histone Marks |
|-------|------------|----------------|
| ChIP‑seq | 20–40M | 30–50M |
| CUT&RUN | 5–10M | 10–15M |
| CUT&Tag | 3–6M | 5–10M |

---

# 🧠 Summary Comparison
### ChIP‑seq
Oldest, robust, but noisy.
### CUT&RUN
Cleaner and lower‑input than ChIP.
### CUT&Tag
Fastest, highest resolution, lowest input.

For high‑resolution TF mapping or single‑cell: **CUT&Tag**.  
For histone marks and nucleosome profile: **CUT&RUN**.  
For legacy consistency or very specific TF antibodies: **ChIP‑seq**.

---

<p align="center"><b>cccTeqy adapts intelligently to each assay—ensuring optimal QC, peak calling, and downstream metrics.</b></p>

