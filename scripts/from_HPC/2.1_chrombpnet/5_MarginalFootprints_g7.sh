#!/bin/bash -l
#SBATCH --output=/scratch/prj/stem_cells_pituitary/Georgia/scripts/0_outputs/5_g7.out
#SBATCH --job-name=g7
#SBATCH --gres=gpu
#SBATCH --cpus-per-task=2
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

# Generate a motif_sequences_subset.tsv file on python (PWM_to_sequence.ipynb)

# Function
source /scratch/prj/stem_cells_pituitary/Georgia/scripts/functions/MarginalFootprints.sh

# Run pipeline
cell_types_list=("Somatotrophs" "Lactotrophs" "Melanotrophs" "Corticotrophs" "Gonadotrophs" "Gonadotrophs_Gata2_KO" "Gonadotrophs_SF1_KO" "Thyrotrophs" "Stem_cells")

for cell in "${cell_types_list[@]}"
do
     MarginalFootprints \
           "mm10" \
           "fold_0" \
           /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/data/motif_sequences_g7_up.tsv \
           /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet/outputs \
           "$cell" \
	   "g7_up"
done
