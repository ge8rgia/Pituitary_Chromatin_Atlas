# Pituitary Chromatin Atlas

(add abstract once written in here)

Base-resolution deep learning framework for mapping transcription factor (TF) binding dynamics in the single-cell and bulk ATAC-seq atlas of the mouse and rat pituitary gland.

This repository contains the custom pipeline, downstream analysis scripts, and metadata 
developed for the MSc Applied Bioinformatics dissertation *"Applying deep learning to map TF-binding patterns 
in the single-cell ATAC-seq atlas of the pituitary gland"* (Georgia Goddard, King's College London, 2026),
supervised by Cynthia Andoniadou, Grace Hui-Chun Lu, and Bence Kövér, Andoniadou Lab.

The pipeline applies [ChromBPNet](https://github.com/kundajelab/chrombpnet) — a
bias-factorised, base-resolution deep learning model of chromatin accessibility — to the
Andoniadou Lab's Consensus Pituitary Atlas (CPA) and complementary bulk ATAC-seq as well as [BPNet](https://github.com/jmschrei/bpnet-lite) models on ChIP-seq
and CUT&RUN datasets, in order to identify TF binding events de novo and characterise
regulatory dynamics across pituitary lineage commitment.

---
 
## Contents
 
- [Overview](#overview)
- [Repository structure](#repository-structure)
- [Pipeline workflow](#pipeline-workflow)
  - [ChromBPNet pipeline (ATAC-seq)](#chrombpnet-pipeline-atac-seq)
  - [BPNet pipeline (ChIP-seq/CUT&RUN)](#bpnet-pipeline-chip-seqcutrun)
  - [Downstream analyses](#downstream-analyses)
- [Data](#data)
- [Environment & installation](#environment--installation)
- [Reproducing the analysis](#reproducing-the-analysis)
- [Model availability](#model-availability)
- [Acknowledgements](#acknowledgements)

---

## Overview 

Two aims motivated this research and are outlined within this repository:

1. **Aim 1** — Identify TF binding events de novo and characterise the key TFs associated
   with regulatory dynamics across pituitary lineage transitions and cell types.
2. **Aim 2** — Establish a framework for identifying regulatory sites near genes of
   interest, using the prolactin (*Prl*) locus as a candidate gene.

To do this, ChromBPNet models were trained per cell type / experimental condition on:
 
- **Single-cell ATAC-seq** from the Consensus Pituitary Atlas (adult and neonatal mouse,
  ~350,000 cells, 59 datasets), including a stem cell → gonadotroph pseudotime trajectory.
- **Bulk ATAC-seq** from pituitary cell lines (GH3, AtT-20, LβT2, TaT1), including a GH3
  Nfia/Nfib and Sox2 overexpression panel.
- **ChIP-seq / CUT&RUN** (POU1F1, TBX19, SOX2), modelled with the related BPNet
  architecture for orthogonal validation of ChromBPNet's de novo motifs.
Model interpretation used DeepLIFT contribution scores, TF-MoDISco de novo motif discovery,
and marginal footprinting, benchmarked against the JASPAR 2026 vertebrate motif database.

---

## Repository structure

```
Pituitary_Chromatin_Atlas/
├── README.md
├── BPNet_pipeline/                  # BPNet models trained on ChIP-seq/CUT&RUN data
│   ├── 0_negatives_bpnet.sh         #   GC-matched background region generation
│   ├── 1_generate_JSON.sh           #   Pipeline configurations
│   └── 2_run_bpnet.sh               #   Training, evaluation, DeepLIFT attribution (contribution scores)
│
├── ChromBPNet_pipeline/             # Custom ChromBPNet pipeline)
│   ├── README.md                    #   ChromBPNet pipeline workflow
│   ├── 1_Preprocessing/             #   Stage 1: fragment splitting, merging, peak/non-peak prep
│   ├── 2_Model_Training/            #   Stage 2: Tn5 bias + bias-factorised ChromBPNet training
│   ├── 3_Data_Generation/           #   Stage 3: predicted BigWigs, footprints, contributions, motifs
│   ├── functions/                   #   Shared/custom pipeline functions
│   └── PipelineDiagram.png          #   Schematic of the full workflow
│
├── Downstream_Analyses/
│   ├── contribution_score_analysis/      # IGV locus plots, correlations, MotifMatchr/FIMO scanning of high-contribution loci
│   ├── marginal_footprint_analysis/      # Plot footprints, PCA of footprint changes, pseudotime comparisons
│   ├── motif_analysis/                   # TF-MoDISco output parsing, JASPAR comparison, novel motif identification
│   └── other/                            # RNA-seq integration, expression filtering, miscellaneous notebooks
│
├── Example_Model_Evaluations/
│   ├── Tn5_bias_model_fold_0_mm10_adult_0.5/       # Example trained bias model + logs
│   ├── ChromBPNet_model_mm10_adult_lactotrophs/    # Example trained ChromBPNet model + logs
│   ├── bias_model_metrics.csv                      # Pearson r / JSD metrics, all bias models
│   └── chrombpnet_metrics.csv                      # Pearson r / JSD metrics, all ChromBPNet models
│
└── Metadata/
    ├── consensus_chromatin_landscape_mm10_adult.bed     # Adult mm10 consensus peak set
    ├── consensus_chromatin_landscape_mm10_neonatal.bed  # Neonatal mm10 consensus peak set
    ├── consensus_chromatin_landscape_hg38.bed           # hg38 consensus peak set
    ├── JASPAR_CORE_2026_non-redundant.meme              # JASPAR 2026 vertebrate motifs (2059 motifs)
    ├── JASPAR_CORE_2026_redundant.meme                  # JASPAR 2026 vertebrate reduced list of motifs (951 motifs)
    ├── JASPAR_CORE_2026_with_novel_POU1F1.meme          # JASPAR 2026 vertebrate motifs + de novo POU1F1 motif (2060 motifs)
    ├── motif_sequences.tsv                              # Curated motif sequences from JASPAR_CORE_2026_non-redundant.meme
    ├── atac_grouping_lineage_markers.csv                # Curated lineage-marker TF list (CPA)
    ├── median_RNAexpression_per_celltype.csv            # Pseudobulk expression, used for TF filtering
    └── pituitary_epigenomics.xlsx                       # Sample/dataset metadata sheet
```

## Pipeline workflow
 
### ChromBPNet pipeline (ATAC-seq)

The custom `ChromBPNet_pipeline/` is organised into three sequential stages (see
`PipelineDiagram.png`), each implemented as a set of custom functions wrapping the
[`chrombpnet`](https://github.com/kundajelab/chrombpnet) command-line pipeline. This adapts and expands the original 
pipeline to accomodate the large scale Consensus Pituitary Atlas. 

See `ChromBPNet_pipeline/README.md` for the organisation and functions of the workflow. 

### BPNet pipeline (ChIP-seq/CUT&RUN)
 
`BPNet_pipeline/` mirrors the ChromBPNet workflow for orthogonal validation datasets
(POU1F1 CUT&RUN, TBX19 and SOX2 ChIP-seq), using
[`bpnet-lite`](https://github.com/jmschrei/bpnet-lite) v1.0.0 (no bias-correction step, as
ChIP/CUT&RUN data does not use the Tn5 transposase enzyme).

### Downstream analyses
 
- **`contribution_score_analysis/`** — locus-level IGV inspection, FIMO/MotifMatchr scanning
  of high-contribution sequences (e.g. the *Prl* upstream regulatory regions).
- **`marginal_footprint_analysis/`** — PCA-based quantification of footprint shape/amplitude
  across pseudotime, cell types, and age.
- **`motif_analysis/`** — TF-MoDISco motif parsing, cross-referencing with JASPAR, curation
  of the novel POU1F1 motif.
- **`other/`** — RNA-seq/scRNA-seq integration for TF expression filtering and validation, as well as other miscellaneous scripts.

---

## Data
 
| Dataset | Description | Source |
|---|---|---|
| Consensus Pituitary Atlas (CPA) | scATAC-seq/scRNA-seq, ~1.3M cells, 59 datasets | Kövér et al., 2026 (Andoniadou Lab) |
| Bulk ATAC-seq, GH3 lines | CTRL, Nfia+b OE (AB), Sox2 OE (SOX2), Nfia+b+Sox2 OE (ABS) | Andoniadou Lab (unpublished) |
| Bulk ATAC-seq, AtT-20 (Neo/Pax7), LβT2, TaT1 | Corticotroph/melanotroph, gonadotroph, thyrotroph cell lines | Mayran et al. 2019; Ruf-Zamojski et al. 2018; Daly et al. 2021 |
| POU1F1 CUT&RUN | TaT1 cell line | Daly et al. 2021 |
| TBX19 ChIP-seq | AtT-20 cell line | Zhang et al. 2015 |
| SOX2 ChIP-seq | AtT-20 cell line | Drouin Laboratory (unpublished) |
| JASPAR CORE 2026 vertebrates | 2059 non-redundant motifs | JASPAR |
| Reference genomes | mm10 (mouse), rn6 (rat) + ENCODE blacklist | UCSC / ENCODE |
 
Raw sequencing data and full-size trained models are not hosted in this repository due to
size; see [Model availability](#model-availability) below. Consensus peak sets and curated
motif/metadata files needed to reproduce downstream analyses are provided in `Metadata/`. All 
data described above that is not included within the Consensus Pituitary Atlas are retrievable from 
the `Metadata/pituitary_epigenomics.xlsx` database. 

---

## Environment & installation

Core dependencies (see `Supplementary Table 1` of the dissertation for the complete,
version-pinned list):

ADD ENVIRONMENT .YML FILES!!!!

**R (v4.5.1)** environment (for motif matching, plotting, GenomicRanges-based workflows):
```r
install.packages(c("universalmotif", "ggplot2"))
BiocManager::install(c("motifmatchr", "TFBSTools", "GenomicRanges",
                        "SummarizedExperiment", "rhdf5", "BiocParallel",
                        "BSgenome.Mmusculus.UCSC.mm10",
                        "BSgenome.Rnorvegicus.UCSC.rn6"))
```

All deep learning models were trained on NVIDIA A100 GPU nodes; GPU access (CUDA-enabled)
is required for model training steps (Stage 2), though inference/downstream analysis
(Stages 3, `Downstream_Analyses/`) can run on CPU.

---

## Reproducing the analysis

MAKE A HTML FILE EXPLAINING FUNCTIONS OF THE CHROMBPNET PIPELINE!!!

The ChromBPNet and BPNet pipelines are annotated numerically, and should be reproduced following this structure. All downstream analyses can be conducted in any order, 
separately or in combination depending on the research expected. All downstream analysis notebooks describe the inputs required, which link to one of the steps in the `ChromBPNet_pipeline/3_Data_Generation` workflow. 

Each script directory contains its own header documentation describing required inputs, expected outputs, and adjustable parameters (e.g. `bias_threshold_factor`, seqlet counts, PCA distance thresholds), all of which can be adapted based on the required analysis. 

---

## Model availability
 
- **Code & configuration**: this repository.
- **Trained models** (all 40 bias and ChromBPNet models): hosted on [Hugging Face](https://huggingface.co/ge8rgia)
- **Example model + evaluation outputs**: `Example_Model_Evaluations/` (adult mm10
  lactotroph ChromBPNet model and its corresponding Tn5 bias model, provided as worked
  examples of expected directory structure and QC metrics).

---

## Acknowledgements

ADD ACKNOWLEDGEMENTS !!!!

