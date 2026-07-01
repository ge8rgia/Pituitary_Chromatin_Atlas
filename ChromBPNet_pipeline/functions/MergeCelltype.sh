#!/bin/bash

MergeCelltype() {
	local -n _cell_types="$1"
	local samples="$2"
        local sampleDir="$3"
        local outDir="$4"
	local -n _exclude_samples="$5"
	local KO_name="$6"

	# Check first two inputs have been provided
	if [[ -z "$1" || ! -f "$samples" || -z "$sampleDir" || -z "$outDir" ]]; then
        	echo "Error: Missing mandatory inputs or samples file not found."
        	return 1
    	fi

	# Filter samples
	all_samples=($(cat "$samples"))
	final_samples=()

	# If function includes samples to exclude
	for sample_name in "${all_samples[@]}"; do
        	local skip=0
        	for exclude in "${_exclude_samples[@]}"; do
            		[[ "$sample_name" == "$exclude" ]] && skip=1 && break
        	done
	        [[ $skip -eq 0 ]] && final_samples+=("$sample_name")
    	done
	echo "==> Samples to process: ${#final_samples[@]} (Excluded: ${#_exclude_samples[@]}) <=="

	# Iterate merge, sort, and index pipeline through samples and cell_types
	for cell_type in "${_cell_types[@]}"
	do
		echo "Beginning cell type: $cell_type"

		CELL_FRAGMENTS=()

		for sample in "${final_samples[@]}"
		do
		  IN="$sampleDir/$sample"
		  FILE=$(ls $IN/*${cell_type}.tsv.gz 2>/dev/null | head -n 1)
		  if [ -f "$FILE" ]; then
                  	echo "Fragment file selected for $sample : $FILE"
                   	CELL_FRAGMENTS+=("$FILE")
                  fi
		done

		echo "=> Total files selected for $cell_type : ${#CELL_FRAGMENTS[@]} <="

		if [ ${#CELL_FRAGMENTS[@]} -eq 0 ]; then
			echo "No files found for $cell_type — skipping"
			continue
		fi

		# Define the output name
		SUFFIX=""
		[[ -n "$KO_name" ]] && SUFFIX="_${KO_name}"
		MERGED_FILENAME="$outDir/${cell_type}${SUFFIX}_merged"

		# Merge, sort, and index file
		echo "Merging $cell_type"
		zcat "${CELL_FRAGMENTS[@]}" | bgzip -c > "${MERGED_FILENAME}.tsv.gz"

		echo "Sorting $cell_type"
		zcat "${MERGED_FILENAME}.tsv.gz" \
	           | sort -k1,1 -k2,2n -T "$outDir" \
		   > "${MERGED_FILENAME}_sorted.tsv"

		echo "Compress and Index $cell_type"
		bgzip "${MERGED_FILENAME}_sorted.tsv"
		tabix -p bed "${MERGED_FILENAME}_sorted.tsv.gz"

		# Remove unsorted file
		rm "${MERGED_FILENAME}.tsv.gz"

		echo "=> Completed merging of $cell_type <="

	done
echo "==> ALL CELL TYPES MERGED <=="
}

# Call function
#cell_types=("Corticotrophs" "Lactotrophs")
#exclude=("GSM5712761" "GSM5712762" "GSM5712763" "GSM5959924")

#MergeCelltype \
#	cell_types \
#	/scratch/prj/stem_cells_pituitary/georgia_atac/sample_sheet.txt \
#	/scratch/prj/stem_cells_pituitary/georgia_atac/mouse_split/ \
#	/scratch/prj/stem_cells_pituitary/georgia_atac/mouse_merged \
#	exclude \
#	""

