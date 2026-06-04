#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/0_negatives_bpnet.out
#SBATCH --job-name=negs_bpnet
#SBATCH --cpus-per-task=1
#SBATCH --mem=50G
#SBATCH --time=05:00:00

cd /scratch/prj/stem_cells_pituitary/Georgia

# Activate chrombpnet environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate bpnet_lite

export PATH="/scratch/users/k25055720/conda_envs/bpnet_lite/bin:$PATH"

echo "--- Diagnostic Check ---"
echo "Hostname: $(hostname)"
echo "------------------------"

# Make files compatible
echo "Convert .narrowPeak to .bed for consistency."
cd /scratch/prj/stem_cells_pituitary/Bence/atacseq_chip_results/26/bwa/merged_library/macs2/narrow_peak
cp SOX2_REP1.mLb.clN_peaks.narrowPeak SOX2_REP1.mLb.clN_peaks_copy.narrowPeak
mv SOX2_REP1.mLb.clN_peaks_copy.narrowPeak SOX2_REP1.mLb.clN_peaks.bed
gzip SOX2_REP1.mLb.clN_peaks.bed

# Run command
echo "Run negatives for bpnet: $(date)"

base_dir="/scratch/prj/stem_cells_pituitary"

bpnet negatives \
	-i "$base_dir/Bence/atacseq_chip_results/16/bwa/merged_library/macs2/narrow_peak/TPIT_REP1.mLb.clN_peaks.bed" \
	-f "$base_dir/Georgia/genome/mm10/mm10.standard_chroms.fa" \
	-o "$base_dir/Bence/atacseq_chip_results/16/bwa/merged_library/macs2/narrow_peak/TPIT_negatives_bpnet.bed" \
	-v

echo "Done: $(date)"

