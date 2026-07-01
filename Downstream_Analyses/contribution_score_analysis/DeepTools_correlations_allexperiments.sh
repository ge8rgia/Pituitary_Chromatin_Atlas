#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/deeptools.out
#SBATCH --job-name=deeptools
#SBATCH --cpus-per-task=8
#SBATCH --mem=50G
#SBATCH --time=04:00:00

cd /scratch/prj/stem_cells_pituitary/Georgia

# Activate chrombpnet environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate deeptools

echo "Hostname: $(hostname)"
echo "Beginning deeptools pipeline: $(date)"

OUTPUT_DIR="/scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/plots/contribution_correlation/all_tracks_comparison"
mkdir -p "$OUTPUT_DIR"

echo "Running multiBigwigSummary for all tracks..."

multiBigwigSummary BED-file \
    --bwfiles \
	/scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/outputs/experiments/experiment_10_AtT20_NEO/contribs_bw/experiment_10_AtT20_NEO_consensus_chromatin_landscape_modified_contribs.profile_scores.bw \
        /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/outputs/mouse/Corticotrophs/contribs_bw/Corticotrophs_contribs.profile_scores.bw \
        /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/outputs/experiments/experiment_10_AtT20_PAX7/contribs_bw/experiment_10_AtT20_PAX7_consensus_chromatin_landscape_modified_contribs.profile_scores.bw \
        /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/outputs/mouse/Melanotrophs/contribs_bw/Melanotrophs_contribs.profile_scores.bw \
        /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/outputs/experiments/experiment_15/contribs_bw/experiment_15_consensus_chromatin_landscape_modified_contribs.profile_scores.bw \
        /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/outputs/mouse/Gonadotrophs/contribs_bw/Gonadotrophs_contribs.profile_scores.bw \
    --BED /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/data/mm10/peaks/consensus_chromatin_landscape_modified.bed \
    --labels "AtT20-NEO" "Corticotrophs" "AtT20-PAX7" "Melanotrophs" "Lbt2" "Gonadotrophs" \
    -o "$OUTPUT_DIR/multibw_summary_tracks_group_peaks_simplifiednames.npz" \
    -p 8

echo "Generating Pearson correlation heatmap"

plotCorrelation \
    -in "$OUTPUT_DIR/multibw_summary_tracks_group_peaks_simplifiednames.npz" \
    --corMethod pearson \
    --skipZeros \
    --whatToPlot heatmap \
    --colorMap coolwarm \
    --plotNumbers \
    --labels "AtT20-NEO" "Corticotrophs" "AtT20-PAX7" "Melanotrophs" "Lbt2" "Gonadotrophs" \
    --plotTitle "Pearson Correlation of Profile Scores" \
    -o "$OUTPUT_DIR/correlation_pearson_tracks_final_plot.svg"

#echo "Generating Spearman correlation heatmap"

#plotCorrelation \
#    -in "$OUTPUT_DIR/multibw_summary_tracks_group_peaks.npz" \
#    --corMethod spearman \
#    --skipZeros \
#    --whatToPlot heatmap \
#    --colorMap coolwarm \
#    --plotNumbers \
#    --labels "Bulk-ATAC AtT20-NEO" "scATAC Corticotrophs" "Bulk-ATAC AtT20-PAX7" "scATAC Melanotrophs" "Bulk-ATAC Lbt2" "scATAC Gonadotrophs" \
#    --plotTitle "Spearman Correlation of Profile Scores" \
#    -o "$OUTPUT_DIR/correlation_spearman_tracks_group_peaks.pdf"

#echo "All plots generated successfully in $OUTPUT_DIR!"








