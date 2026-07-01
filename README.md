# Pituitary Chromatin Atlas: ChromBPNet TF-Binding Analysis

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
  - [1. Preprocessing](#1-preprocessing)
  - [2. Model training](#2-model-training)
  - [3. Data generation](#3-data-generation)
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
│   ├── 0_negatives_bpnet.sh         #   GC-matched background region genera
│   ├── 1_generate_JSON.sh           #   Pipeline configura
│   └── 2_run_bpnet.sh               #   Training, evaluation, DeepLIFT attribu (contribution scores)
│
├── ChromBPNet_pipeline/             # Custom ChromBPNet pipelon)
│   ├── 1_Preprocessing/             #   Stage 1: fragment splitting, merging, peak/non-peak prep
│   ├── 2_Model_Training/            #   Stage 2: Tn5 bias + bias-factorised ChromBPNet training
│   ├── 3_Data_Generation/           #   Stage 3: predicted BigWigs, footprints, contributions, motifs
│   ├── functions/                   #   Shared/custom pipeline functow)
│   └── PipelineDiagram.png          #   Schematic of the full worw
│
├── Downstream_Analyses/
│   ├── contribution_score_analysis/ # locus plotsaccorrelations, ks, MotifMatchr/FIMO scanning of high-contribution loci
│   ├── marginal_footprint_analysisPlot footprints, / # PCA of footprint s changes, pe, pseudo nse comparisons
│   ├── motif_analysis/              # TF-MoDISco output parsing, JASPAR comparison, novel moidentification
│   └── other/                       # RNA-seq integration, expression filtering, miscellaneous noteb
│
├── Example_Model_Evaluations/
│   ├── Tn5_bias_model_fold_0_mm10_adult_0.5/       # Example trained bias model + logs
│   ├── ChromBPNet_model_mm10_adult_lactotrophs/    # Example trained ChromBPNet model + logs
│   ├── bias_model_metrics.csv                      # Pearson r / JSD metrics, all bias mo
│   └── chrombpnet_metrics.csv                      # Pearson r / JSD metrics, all ChromBPNet mo
│
└── Metadata/
    ├── consensus_chromatin_landscape_mm10_adult.bed     # Adult mm10 consensus peak set
    ├── consensus_chromatin_landscape_mm10_neonatal.bed  # Neonatal mm10 consensus peak set
    ├── consensus_chromatin_landscape_hg38.bed          hg38 consensus peak set
    ├── JASPAR_CORE_2026_non-redundant.meme              # JASPAR 2026 vertebrate motifs (2,0motifsTFs)
    ├── JASPAR_CORE_2026_redundant.meme               # JASPAR 2026 vertebrate reduced list of motifs (951 motifs)
    ├── JASPAR_CORE_2026_with_novel_POU1F1.meme          # JASPAR 2026 + de novo POU1F1 mo
    ├── motif_sequences.tsv                             C# Curated de novo motif PFMs from TF-MoDISco
    ├── atac_grouping_lineage_markers.csv                # Curated lineage-marker TF list (CPA)
    ├── median_RNAexpression_per_celltype.csv            # Pseudobulk expression, used for TF filtering
    └── pituitary_epigenomics.xlsx                        # Sample/dataset metadata sheet
```
 
