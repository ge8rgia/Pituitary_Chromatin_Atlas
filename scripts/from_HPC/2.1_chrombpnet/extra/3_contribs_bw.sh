#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/3_contribs_bw.out
#SBATCH --job-name=contribs_bw
#SBATCH --gres=gpu
#SBATCH --exclude=erc-hpc-comp038,erc-hpc-comp039,erc-hpc-comp040
#SBATCH --cpus-per-task=8
#SBATCH --mem=200G
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

# Run deepLIFT contribution score pipeline
chrombpnet contribs_bw \
	-m ChromBPnet/Models/Lactotrophs_model/models/chrombpnet_nobias.h5 \
	--regions ChromBPnet/data/consensus_chromatin_landscape_modified.bed.gz \
	-g genome/mm10.fa \
	-c genome/mm10.chrom.subset.sizes \
	-op ChromBPnet/outputs/Lactotrophs/contribs_bw/lactotrophs_contribs
