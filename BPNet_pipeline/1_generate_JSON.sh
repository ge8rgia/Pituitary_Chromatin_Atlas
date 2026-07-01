#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/1_generate_JSON.out
#SBATCH --job-name=json_bpnet
#SBATCH --cpus-per-task=1
#SBATCH --mem=10G
#SBATCH --time=01:00:00

cd /scratch/prj/stem_cells_pituitary/Georgia

# Activate chrombpnet environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate bpnet_lite

export PATH="/scratch/users/k25055720/conda_envs/bpnet_lite/bin:$PATH"

echo "--- Diagnostic Check ---"
echo "Hostname: $(hostname)"
echo "------------------------"

# Paths for experiment 16
base_dir="/scratch/prj/stem_cells_pituitary"
out_dir="$base_dir/Georgia/bpnet/exp16_ChIPseq_TPIT"

genome_fasta="$base_dir/Georgia/genome/mm10/mm10.fa"
signals="$base_dir/Bence/atacseq_chip_results/16/bwa/merged_library/TPIT_REP1.mLb.clN.sorted.bam"
peaks="$base_dir/Bence/atacseq_chip_results/16/bwa/merged_library/macs2/narrow_peak/TPIT_REP1.mLb.clN_peaks.bed"
negatives="$base_dir/Bence/atacseq_chip_results/16/bwa/merged_library/macs2/narrow_peak/TPIT_negatives_bpnet.bed"

motifs="$base_dir/Georgia/genome/JASPAR_CORE_2026_non-redundant.meme"

if [ ! -d "$out_dir" ]; then
	mkdir -p "$out_dir"
fi

cd $out_dir

echo "Generating JSON file: $(date)"

bpnet pipeline-json \
	-s "$genome_fasta" \
	-p "$peaks" \
	-i "$signals" \
	-neg "$negatives" \
	-n exp16_TPIT \
	-o exp16_TPIT_pipeline_nomodiscoreport.json \
	-u
#	-m "$motifs" \
#	-u

echo "JSON file generated: $(date)"


