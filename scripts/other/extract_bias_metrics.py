"""
Extract bias model metrics from overall_report.pdf files.
 
Usage:
    python extract_bias_metrics.py /path/to/parent/directory
 
This script walks all subdirectories, finds evaluation/overall_report.pdf,
extracts the 8 metrics from the tables, and writes a CSV.
"""
 
import sys
import os
import re
import csv
import pdfplumber
 
METRICS = [
    "nonpeaks.pearsonr",
    "nonpeaks.mse",
    "peaks.pearsonr",
    "peaks.mse",
    "nonpeaks.median_jsd",
    "nonpeaks.median_norm_jsd",
    "peaks.median_jsd",
    "peaks.median_norm_jsd",
]
 
 
def extract_metrics_from_pdf(pdf_path):
    """Extract the 8 metrics from an overall_report.pdf."""
    results = {m: None for m in METRICS}
 
    with pdfplumber.open(pdf_path) as pdf:
        full_text = ""
        for page in pdf.pages:
            full_text += (page.extract_text() or "") + "\n"
 
    # The counts_metrics row contains: nonpeaks.pearsonr, nonpeaks.mse, peaks.pearsonr, peaks.mse
    # The profile_metrics row contains: nonpeaks.median_jsd, nonpeaks.median_norm_jsd, peaks.median_jsd, peaks.median_norm_jsd
    #
    # Text layout looks like:
    #   counts_metrics  0.64  1.51  0.18  1.13
    #   profile_metrics  0.59  0.19  0.51  0.26
 
    counts_match = re.search(
        r'counts_metrics\s+([\d.\-]+)\s+([\d.\-]+)\s+([\d.\-]+)\s+([\d.\-]+)',
        full_text
    )
    profile_match = re.search(
        r'profile_metrics\s+([\d.\-]+)\s+([\d.\-]+)\s+([\d.\-]+)\s+([\d.\-]+)',
        full_text
    )
 
    if counts_match:
        results["nonpeaks.pearsonr"] = counts_match.group(1)
        results["nonpeaks.mse"]      = counts_match.group(2)
        results["peaks.pearsonr"]    = counts_match.group(3)
        results["peaks.mse"]         = counts_match.group(4)
    else:
        print(f"  WARNING: could not parse counts_metrics in {pdf_path}")
 
    if profile_match:
        results["nonpeaks.median_jsd"]      = profile_match.group(1)
        results["nonpeaks.median_norm_jsd"] = profile_match.group(2)
        results["peaks.median_jsd"]         = profile_match.group(3)
        results["peaks.median_norm_jsd"]    = profile_match.group(4)
    else:
        print(f"  WARNING: could not parse profile_metrics in {pdf_path}")
 
    return results
 
 
def main(base_dir):
    base_dir = os.path.abspath(base_dir)
    rows = []
 
    # Find all subdirectories that contain evaluation/overall_report.pdf
    for entry in sorted(os.listdir(base_dir)):
        model_dir = os.path.join(base_dir, entry)
        if not os.path.isdir(model_dir):
            continue
        pdf_path = os.path.join(model_dir, "evaluation", "overall_report.pdf")
        if not os.path.isfile(pdf_path):
            print(f"Skipping {entry} — no evaluation/overall_report.pdf found")
            continue
 
        print(f"Processing {entry} ...")
        try:
            metrics = extract_metrics_from_pdf(pdf_path)
        except Exception as e:
            print(f"  ERROR: {e}")
            metrics = {m: None for m in METRICS}
 
        row = {"model_name": entry}
        row.update(metrics)
        rows.append(row)
 
    if not rows:
        print("No PDFs found. Check the base directory path.")
        return
 
    output_csv = os.path.join(base_dir, "bias_model_metrics.csv")
    fieldnames = ["model_name"] + METRICS
    with open(output_csv, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
 
    print(f"\nDone! CSV written to: {output_csv}")
    print(f"Rows: {len(rows)}")
 
 
if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python extract_bias_metrics.py /path/to/parent/directory")
        sys.exit(1)
    main(sys.argv[1])