#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/0_test_Tn5_model_1lacto.out
#SBATCH --job-name=bias
#SBATCH --gres=gpu
#SBATCH --cpus-per-task=4
#SBATCH --mem=40G
#SBATCH --time=48:00:00

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

#echo "Beginning call_peaks bias pipeline: $(date)"

# Run bias model training pipeline
#chrombpnet bias pipeline \
#        -ifrag ChromBPnet/peak_validation/GSM4594382_Lactotrophs.tsv.gz \
#        -d "ATAC" \
#        -g genome/mm10/mm10.fa \
#        -c genome/mm10/mm10.chrom.subset.sizes \
#        -p ChromBPnet/peak_validation/call_peaks/peaks_no_blacklist.bed \
#        -n ChromBPnet/peak_validation/call_peaks/output_negatives.bed \
#        -fl ChromBPnet/splits/mm10/fold_0.json \
#        -b 0.5 \
#        -o ChromBPnet/peak_validation/bias_models/call_peaks_bias_model \
#
#echo "Complete: $(date)"

echo "Beginning custom_peaks bias pipeline: $(date)"

# Run bias model training pipeline
chrombpnet bias pipeline \
        -ifrag ChromBPnet/peak_validation/GSM4594382_Lactotrophs.tsv.gz \
        -d "ATAC" \
        -g genome/mm10/mm10.fa \
        -c genome/mm10/mm10.chrom.subset.sizes \
        -p ChromBPnet/peak_validation/custom_peaks/peaks_no_blacklist.bed \
        -n ChromBPnet/peak_validation/custom_peaks/output_negatives.bed \
        -fl ChromBPnet/splits/mm10/fold_0.json \
        -b 0.5 \
        -o ChromBPnet/peak_validation/bias_models/custom_peaks_bias_model \

echo "Complete: $(date)"
