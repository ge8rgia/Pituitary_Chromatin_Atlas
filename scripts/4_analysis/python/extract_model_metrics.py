"""
Extract ChromBPNet model metrics from overall_report.pdf files.
 
Directory structure:
  <base>/
    <group>/          e.g. mouse, mouse_young, experiments
      <model>/        e.g. Corticotrophs_model
        evaluation/
          overall_report.pdf
 
Usage:
    python extract_chrombpnet_metrics.py /path/to/Models
 
Output CSV: <base>/chrombpnet_metrics.csv
"""
 
import sys, os, re, csv
import pdfplumber
 
COLS = [
    "bias.peaks.pearsonr",
    "bias.peaks.mse",
    "bias.peaks.median_jsd",
    "bias.peaks.median_norm_jsd",
    "model.peaks.pearsonr",
    "model.peaks.mse",
    "model.peaks.median_jsd",
    "model.peaks.median_norm_jsd",
]
 
 
def extract_metrics(pdf_path):
    with pdfplumber.open(pdf_path) as pdf:
        full_text = "\n".join(page.extract_text() or "" for page in pdf.pages)
 
    counts_hits  = re.findall(r'counts_metrics\s+([\d.\-]+)\s+([\d.\-]+)', full_text)
    profile_hits = re.findall(r'profile_metrics\s+([\d.\-]+)\s+([\d.\-]+)', full_text)
 
    result = {c: None for c in COLS}
 
    if len(counts_hits) >= 2 and len(profile_hits) >= 2:
        result["bias.peaks.pearsonr"]        = counts_hits[0][0]
        result["bias.peaks.mse"]             = counts_hits[0][1]
        result["bias.peaks.median_jsd"]      = profile_hits[0][0]
        result["bias.peaks.median_norm_jsd"] = profile_hits[0][1]
        result["model.peaks.pearsonr"]       = counts_hits[1][0]
        result["model.peaks.mse"]            = counts_hits[1][1]
        result["model.peaks.median_jsd"]     = profile_hits[1][0]
        result["model.peaks.median_norm_jsd"]= profile_hits[1][1]
    else:
        print(f"  WARNING: expected 2 tables, found counts={len(counts_hits)}, profile={len(profile_hits)} in {pdf_path}")
 
    return result
 
 
def main():
    if len(sys.argv) != 2:
        print("Usage: python extract_chrombpnet_metrics.py /path/to/Models")
        sys.exit(1)
 
    base_dir = os.path.abspath(sys.argv[1])
    rows = []
 
    for group in sorted(os.listdir(base_dir)):
        group_path = os.path.join(base_dir, group)
        if not os.path.isdir(group_path):
            continue
        for model in sorted(os.listdir(group_path)):
            model_path = os.path.join(group_path, model)
            pdf = os.path.join(model_path, "evaluation", "overall_report.pdf")
            if not os.path.isfile(pdf):
                continue
            print(f"Processing {group}/{model} ...")
            try:
                metrics = extract_metrics(pdf)
            except Exception as e:
                print(f"  ERROR: {e}")
                metrics = {c: None for c in COLS}
 
            row = {"group": group, "model_name": model}
            row.update(metrics)
            rows.append(row)
 
    if not rows:
        print("No PDFs found. Check the path and directory structure.")
        return
 
    output_csv = os.path.join(base_dir, "chrombpnet_metrics.csv")
    with open(output_csv, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["group", "model_name"] + COLS)
        writer.writeheader()
        writer.writerows(rows)
 
    print(f"\nDone! {len(rows)} models → {output_csv}")
 
 
if __name__ == "__main__":
    main()