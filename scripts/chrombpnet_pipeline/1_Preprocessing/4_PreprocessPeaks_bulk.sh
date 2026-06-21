#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/0_prep_nonpeaks_exp24_2.out
#SBATCH --job-name=nonpeaks
#SBATCH --cpus-per-task=2
#SBATCH --mem=30G
#SBATCH --time=2:00:00

cd /scratch/prj/stem_cells_pituitary/Georgia

# Activate chrombpnet environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate chrombpnet_new

echo "Running 0_prep_nonpeaks command"

exp="22"
exp_type="atacseq_results"
genome="mm10"
peaksDir="/scratch/prj/stem_cells_pituitary/Bence/$exp_type/$exp/bwa/merged_replicate/macs2/broad_peak"
genomeDir="/scratch/prj/stem_cells_pituitary/Georgia/genome/$genome"
splitsDir="/scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/splits/$genome"

cd $peaksDir

# Peaks should already be generated and end with broadPeak name

#echo "Convert .broadPeak to .bed for consistency."
cp Lbt2_ctrl.mRp.clN_peaks.broadPeak Lbt2_ctrl.mRp.clN_peaks_copy.broadPeak
mv Lbt2_ctrl.mRp.clN_peaks_copy.broadPeak Lbt2_ctrl.mRp.clN_peaks.bed
gzip Lbt2_ctrl.mRp.clN_peaks.bed

# Now we have to make background peaks for the Tn5 Bias model
echo "Generate background peaks file and nonpeaks outputs."
bedtools intersect -v -a Lbt2_ctrl.mRp.clN_peaks.bed.gz -b "$genomeDir/temp.bed" > Lbt2_peaks_no_blacklist.bed
# peaks_no_blacklist file needs a 10th peak column, that the broadPeaks usually misses or doesn't include
awk -v OFS='\t' '{ summit_offset = int(($3 - $2) / 2); print $1, $2, $3, $4, $5, $6, $7, $8, $9, summit_offset }' Lbt2_peaks_no_blacklist.bed > Lbt2_peaks_no_blacklist_2.bed
echo "Done generating background peaks file."

# Then generate nonpeaks
chrombpnet prep nonpeaks \
	-g "$genomeDir/${genome}.fa" \
	-p Lbt2_peaks_no_blacklist_2.bed \
	-c "$genomeDir/${genome}.chrom.sizes" \
	-fl "$splitsDir/fold_0.json" \
	-br "$genomeDir/${genome}_blacklist.bed.gz" \
	-o Lbt2_output

echo "Complete."


