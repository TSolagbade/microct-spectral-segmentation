# Quantitative Micro-CT Analysis & Spectral Unmixing of Resin-Embedded Inclusions

An automated computational imaging and computer vision pipeline for non-destructive segmentation, multi-energy spectral unmixing, and taphonomic kinetics tracking in micro-computed tomography (µCT).

Developed as part of an MSc Physics Dissertation at Nottingham Trent University.

---

## 📌 Problem Overview

Resolving internal biological structures encapsulated within synthetic resins or fossil amber using micro-CT faces fundamental physical bottlenecks:
1. **Linear Attenuation Parity (Δµ ≈ 0):** Hydrated visceral tissues share nearly identical X-ray attenuation coefficients with synthetic epoxy matrices, leading to complete structural erasure under conventional global thresholding.
2. **Dominant Matrix Bias:** Bulk resin accounts for >90% of the reconstructed volume, swamping subtle biological signals in intensity histograms.
3. **Detector & Flux Drift:** Scanner baseline thermal shifts across long temporal acquisitions obscure physical densification measurements.

This repository provides an unsupervised pipeline combining dynamic continuous density modeling, additive calibration, and multi-energy covariance diagonalization to recover obscured soft tissue without destructive chemical staining.

---

## 🚀 Key Features

* **Additive Drift Calibration:** Standardizes raw 16-bit slice intensities against invariant background air references ($I_{\text{cal}} = I_{\text{raw}} - \Delta I_{\text{air}}$) to decouple sensor baseline fluctuations from physical matrix densification.
* **Automated Spatial Masking:** Removes container boundaries and peripheral mold walls using dynamic circular radial cutoffs.
* **Dynamic Mode Suppression (KDE):** Employs Gaussian Kernel Density Estimation on axial slice histograms to dynamically detect and suppress bulk matrix attenuation peaks (±2,000 A.U. window) without manual user bias.
* **Multi-Energy Spectral PCA:** Computes cross-channel covariance matrices across multi-voltage stacks (40–120 kV) to isolate coherent biological signal in PC1 while discarding uncorrelated photon noise.
* **Taphonomic Kinetics Analysis:** Quantitative framework for tracking fluid loss, tissue cavitation, and matrix curing across time-resolved CT series (0–117 h).

---

## 📊 Core Quantitative Results

| Metric | Single-Energy CT (90–120 kV) | Multi-Energy PC1 | Information Gain |
| :--- | :--- | :--- | :--- |
| **Tissue Information Recovery** | 0.64% – 1.02% | **54.30%** | **60.95×** |
| **Resin Peak Suppression** | Manual / Incomplete | Dynamic Mode Suppression | Fully Unsupervised |
| **Contrast Expansion Ratio (CER)** | Baseline (IQR = 526.2) | Desiccated Void Contrast (IQR = 409.0) | CER = 0.7773 |

---

## 🛠 Pipeline Architecture

1. **Reconstruction:** 16-bit slice stacks reconstructed via Feldkamp (FDK) filtered backprojection.
2. **Air-Reference Calibration:** Baseline intensity stabilization across energy and temporal series.
3. **Circular Spatial Masking:** Automated extraction of sample volume; rejection of mold boundaries.
4. **Gaussian KDE Density Modeling:** Dynamic peak isolation and background suppression.
5. **Spectral PCA Unmixing:** Cross-channel covariance diagonalization concentrating shared biological tissue signal into Principal Component 1.

---

## 🔬 Academic Attribution

If you utilize this pipeline or methodology in academic research, please cite:

```bibtex
@mastersthesis{solagbade2026microct,
  author       = {Temisola T. Solagbade},
  title        = {Quantitative Micro-CT Analysis of Insects in Resin},
  school       = {Nottingham Trent University},
  year         = {2026},
  supervisor   = {Professor Martin Bencsik}
}
