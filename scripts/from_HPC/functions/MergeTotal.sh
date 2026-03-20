#!/bin/bash

MergeTotal() {
        local sampleDir="$1"
        local outDir="$2"

	if [[ -f "$outDir/all_cells_merged_sorted.tsv.gz" ]]; then
                	echo "File $outDir/all_cells_merged_sorted.tsv.gz already exists."
                	return 0
        fi

	ALL_FRAGMENTS=($(ls $sampleDir/*_merged_sorted.tsv.gz | grep -v "all_merged"))

	echo "Files identified for merging:"
	printf '%s\n' "${ALL_FRAGMENTS[@]}"
	echo "Number of samples: ${#ALL_FRAGMENTS[@]}"
	echo "Total size of files: $(du -ch "${ALL_FRAGMENTS[@]}" | grep total$ | cut -f1)"

	echo "Merging and sorting the merged fragment files: $(date)"

	LC_ALL=C
	zcat "${ALL_FRAGMENTS[@]}" | \
	sort -k1,1 -k2,2n --parallel=6 -S 28G -T "$outDir" | \
	bgzip -@ 6 -c > "$outDir/all_cells_merged_sorted.tsv.gz"

	echo "Done merging and sorting the fragment files: $(date)"

	echo "Starting to compress and zip the sorted fragment file: $(date)"
	tabix -p bed "$outDir/all_cells_merged_sorted.tsv.gz"

	echo "===> DONE SORTING AND INDEXING FILES $(date) <==="
}
