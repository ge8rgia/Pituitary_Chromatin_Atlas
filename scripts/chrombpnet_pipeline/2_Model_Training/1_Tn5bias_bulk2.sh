#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/1_Tn5bias_exp22_1.5.out
#SBATCH --job-name=Tn5b_exp22_1.5
#SBATCH --gres=gpu
#SBATCH --exclude=erc-hpc-comp040,erc-hpc-comp034,erc-hpc-comp039,erc-hpc-comp035
#SBATCH --cpus-per-task=1
#SBATCH --mem=125G
#SBATCH --time=24:00:00

cd /scratch/prj/stem_cells_pituitary/Georgia

# Activate chrombpnet environment
source /software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/anaconda3-2022.10-5wy43yh5crcsmws4afls5thwoskzarhe/etc/profile.d/conda.sh
conda activate chrombpnet_new

# Load dependencies for GPU to work
module load cuda/11.8.0-gcc-13.2.0
module load cudnn

export CUDA_HOME=/software/spackages_v0_21_prod/apps/linux-ubuntu22.04-zen2/gcc-13.2.0/cuda-11.8.0-k4tnio54miofdxttjlj6iilwqj7djrlz
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
export PATH="/scratch/users/k25055720/conda_envs/chrombpnet_new/bin:$PATH"

echo "--- Diagnostic Check ---"
echo "Hostname: $(hostname)"
echo "Sbatch GPU request: $CUDA_VISIBLE_DEVICES"
python -c "import tensorflow as tf; print('Num GPUs:', len(tf.config.list_physical_devices('GPU'))); print('Details:', tf.config.list_physical_devices('GPU'))"
nvidia-smi
echo "------------------------"

export TMPDIR=/scratch/prj/stem_cells_pituitary/tmp

echo "Beginning chrombpnet bias pipeline"

exp="22"
genome="mm10"
experimentDir="/scratch/prj/stem_cells_pituitary/Bence/atacseq_results/$exp/bwa/merged_replicate"
peaksDir="/scratch/prj/stem_cells_pituitary/Bence/atacseq_results/$exp/bwa/merged_replicate/macs2/broad_peak"
genomeDir="/scratch/prj/stem_cells_pituitary/Georgia/genome/$genome"
chromDir="/scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet"

# Run bias model training pipeline - no direct shift
chrombpnet bias pipeline \
        -ibam "$experimentDir/TaT1.mRp.clN.sorted2.bam" \
        -d "ATAC" \
        -g "$genomeDir/${genome}.fa" \
        -c "$genomeDir/${genome}.chrom.sizes" \
        -p "$peaksDir/TaT1_peaks_no_blacklist_2_2.bed" \
        -n "$peaksDir/TaT1_output_negatives2.bed" \
        -fl "$chromDir/splits/$genome/fold_0.json" \
        -b 1.5 \
        -o "$chromDir/Bias_Models/Tn5_bias_model_experiment_${exp}_bias1.5" \

echo "Complete."
