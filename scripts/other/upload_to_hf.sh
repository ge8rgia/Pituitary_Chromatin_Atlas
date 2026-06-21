#!/bin/bash

## upload_to_hf.sh
## Run from: /scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet

HF_USER="ge8rgia"
BASE="/scratch/prj/stem_cells_pituitary/Georgia/ChromBPnet"

upload_model() {
    local local_path="$1"
    local repo_name="$2"
    local repo_id="${HF_USER}/${repo_name}"

    echo ""
    echo "========================================="
    echo "Uploading: $repo_name"
    echo "========================================="

    python3 - <<EOF
from huggingface_hub import HfApi
import os

api = HfApi()
repo_id = "${repo_id}"
local_models_dir = "${local_path}/models"

# Create repo if it doesn't exist
try:
    api.create_repo(repo_id=repo_id, repo_type="model", exist_ok=True)
    print(f"  Repo ready: {repo_id}")
except Exception as e:
    print(f"  Repo creation note: {e}")

# Upload all files in models/ folder
for fname in os.listdir(local_models_dir):
    fpath = os.path.join(local_models_dir, fname)
    if os.path.isfile(fpath):
        size_mb = os.path.getsize(fpath) / (1024*1024)
        print(f"  -> {fname} ({size_mb:.1f} MB)")
        api.upload_file(
            path_or_fileobj=fpath,
            path_in_repo=fname,
            repo_id=repo_id,
            repo_type="model",
            commit_message=f"Upload {fname}"
        )

print(f"  Done: https://huggingface.co/{repo_id}")
EOF
}

# ── BIAS MODELS ────────────────────────────────────────────────────────────────
BIAS="$BASE/Bias_Models"
upload_model "$BIAS/Tn5_bias_model_fold_0_mm10_Lbt2_0.9"      "Tn5-bias-mm10-Lbt2"
upload_model "$BIAS/Tn5_bias_model_fold_0_mm10_adult_0.5"     "Tn5-bias-mm10-adult"
upload_model "$BIAS/Tn5_bias_model_fold_0_rn6_GH3_0.9"        "Tn5-bias-rn6-GH3"
upload_model "$BIAS/Tn5_bias_model_fold_0_mm10_AtT20_1.5"     "Tn5-bias-mm10-AtT20"
upload_model "$BIAS/Tn5_bias_model_fold_0_mm10_TaT1_0.9"      "Tn5-bias-mm10-TaT1"
upload_model "$BIAS/Tn5_bias_model_fold_0_mm10_neonatal_0.5"  "Tn5-bias-mm10-neonatal"

# ── MOUSE SINGLE CELL ─────────────────────────────────────────────────────────
MOUSE="$BASE/Models/mouse"
upload_model "$MOUSE/Corticotrophs_model"          "ChromBPNet-Corticotrophs"
upload_model "$MOUSE/Gonadotrophs_model"           "ChromBPNet-Gonadotrophs"
upload_model "$MOUSE/Gonadotrophs_Gata2_KO_model"  "ChromBPNet-Gonadotrophs-Gata2-KO"
upload_model "$MOUSE/Gonadotrophs_SF1_KO_model"    "ChromBPNet-Gonadotrophs-SF1-KO"
upload_model "$MOUSE/Lactotrophs_model"            "ChromBPNet-Lactotrophs"
upload_model "$MOUSE/Melanotrophs_model"           "ChromBPNet-Melanotrophs"
upload_model "$MOUSE/Somatotrophs_model"           "ChromBPNet-Somatotrophs"
upload_model "$MOUSE/Stem_cells_model"             "ChromBPNet-Stem-cells"
upload_model "$MOUSE/Thyrotrophs_model"            "ChromBPNet-Thyrotrophs"

# ── MOUSE SINGLE CELL NEONATAL ────────────────────────────────────────────────
YOUNG="$BASE/Models/mouse_young"
upload_model "$YOUNG/Corticotrophs_model"   "ChromBPNet-neonatal-Corticotrophs"
upload_model "$YOUNG/Gonadotrophs_model"    "ChromBPNet-neonatal-Gonadotrophs"
upload_model "$YOUNG/Lactotrophs_model"     "ChromBPNet-neonatal-Lactotrophs"
upload_model "$YOUNG/Melanotrophs_model"    "ChromBPNet-neonatal-Melanotrophs"
upload_model "$YOUNG/Somatotrophs_model"    "ChromBPNet-neonatal-Somatotrophs"
upload_model "$YOUNG/Stem_cells_model"      "ChromBPNet-neonatal-Stem-cells"
upload_model "$YOUNG/Thyrotrophs_model"     "ChromBPNet-neonatal-Thyrotrophs"
upload_model "$YOUNG/0.0_model"             "ChromBPNet-neonatal-pseudotime-0.0"
upload_model "$YOUNG/1.0_model"             "ChromBPNet-neonatal-pseudotime-1.0"
upload_model "$YOUNG/2.0_model"             "ChromBPNet-neonatal-pseudotime-2.0"
upload_model "$YOUNG/3.0_model"             "ChromBPNet-neonatal-pseudotime-3.0"
upload_model "$YOUNG/4.0_model"             "ChromBPNet-neonatal-pseudotime-4.0"
upload_model "$YOUNG/5.0_model"             "ChromBPNet-neonatal-pseudotime-5.0"
upload_model "$YOUNG/6.0_model"             "ChromBPNet-neonatal-pseudotime-6.0"

# ── BULK EXPERIMENTS ──────────────────────────────────────────────────────────
EXP="$BASE/Models/experiments"
upload_model "$EXP/experiment_10_AtT20_NEO_model"  "ChromBPNet-AtT20-NEO"
upload_model "$EXP/experiment_10_AtT20_PAX7_model" "ChromBPNet-AtT20-PAX7"
upload_model "$EXP/experiment_15_model"            "ChromBPNet-Lbt2-exp15"
upload_model "$EXP/experiment_22_TaT1_model"       "ChromBPNet-TaT1"
upload_model "$EXP/experiment_24_AB_model"         "ChromBPNet-GH3-AB"
upload_model "$EXP/experiment_24_ABS_model"        "ChromBPNet-GH3-ABS"
upload_model "$EXP/experiment_24_CTRL_model"       "ChromBPNet-GH3-CTRL"
upload_model "$EXP/experiment_24_SOX2_model"       "ChromBPNet-GH3-SOX2"
upload_model "$EXP/experiment_4_model"             "ChromBPNet-Lbt2-exp4"

echo ""
echo "========================================="
echo "All uploads complete!"
echo "========================================="
