#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/deeptools.out
#SBATCH --job-name=deeptools
#SBATCH --cpus-per-task=8
#SBATCH --mem=26G
#SBATCH --time=04:00:00

cd /scratch/prj/stem_cells_pituitary/Georgia

# Activate chrombpnet environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate deeptools

echo "Hostname: $(hostname)"

echo "Beginning deeptools pipeline: $(date)"

# Run computeMatrix
computeMatrix scale-regions \
    -S /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/outputs/experiments/experiment_10_AtT20_NEO/contribs_bw/experiment_10_AtT20_NEO_consensus_chromatin_landscape_modified_contribs.profile_scores.bw \
       /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/outputs/mouse/Corticotrophs/contribs_bw/Corticotrophs_contribs.profile_scores.bw \
    -R /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/outputs/mouse/Corticotrophs/contribs_bw/Corticotrophs_contribs.interpreted_regions.bed \
    --regionBodyLength 500 \
    -p 8 \
    -o /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/plots/contribution_correlation/AtT20-NEO_Corticotrophs/contrib_matrix_allpeaks.gz

multiBigwigSummary BED-file \
    --bwfiles \
	/scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/outputs/experiments/experiment_10_AtT20_NEO/contribs_bw/experiment_10_AtT20_NEO_consensus_chromatin_landscape_modified_contribs.profile_scores.bw \
	/scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/outputs/mouse/Corticotrophs/contribs_bw/Corticotrophs_contribs.profile_scores.bw \
    --BED /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/outputs/mouse/Corticotrophs/contribs_bw/Corticotrophs_contribs.interpreted_regions.bed \
    --labels "Bulk corticotrophs" "scATAC corticotrophs" \
    -o /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/plots/contribution_correlation/AtT20-NEO_Corticotrophs/multibw_summary_allpeaks.npz \
    -p 8

echo "Complete computMatrix. $(date)"

cd /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/plots/contribution_correlation/AtT20-NEO_Corticotrophs

plotCorrelation \
    -in multibw_summary_allpeaks.npz \
    --corMethod pearson \
    --skipZeros \
    --whatToPlot heatmap \
    --colorMap coolwarm \
    --plotNumbers \
    --labels "Bulk gonadotrophs" "scATAC gonadotrophs" \
    -o correlation_between_tracks_allpeaks.pdf

plotCorrelation \
    -in multibw_summary_allpeaks.npz \
    --corMethod spearman \
    --skipZeros \
    --whatToPlot heatmap \
    --colorMap coolwarm \
    --plotNumbers \
    --labels "Bulk gonadotrophs" "scATAC gonadotrophs" \
    -o correlation_spearman_allpeaks.pdf


