#!/bin/bash -l

SplitTSV() {
	local sampleDir="$1"
	local outDir="$2"
	local barcodes="$3"

	# Check all inputs have been provided
	if [[ -z "$sampleDir" || -z "$outDir" || -z "$barcodes" ]]; then
        	echo "SplitTSV: <sampleDir> <outDir> <barcodes_csv>"
        	return 1
    	fi

        # Make output directory
        if [ ! -d "$outDir" ]; then
                mkdir -p "$outDir"
        fi

        # Get the sample IDs
        cd $sampleDir
        find . -mindepth 1 -maxdepth 1 -type d | sed 's|^\./||' | sort > "$outDir/sample_sheet.txt"
	samples=($(cat "$outDir/sample_sheet.txt"))

	echo ${samples[@]}
	echo "Number of samples: ${#samples[@]}"

	# Iterate split through each sample
	for sample in "${samples[@]}"
	do
		IN=$sampleDir/$sample

		cd $outDir
		if [ ! -d "$outDir/$sample" ]; then
                	mkdir -p "$outDir/$sample"
        	fi
        	cd $outDir/$sample

		# Get the fragment file
		FRAG_FILES=($IN/*fragments*.tsv.gz)
        	FRAGMENTS="${FRAG_FILES[0]}"

	        echo "Processing $sample using the $FRAGMENTS file"

		# Filter barcode file for barcodes only associated with the sample
		barcodes_filtered="temp_${sample}_metadata.csv"
        	head -n 1 "$barcodes" > "$barcodes_filtered"
        	grep ",${sample}," "$barcodes" >> "$barcodes_filtered"

		# Extract barcodes and map to cell_type name
		zcat "$FRAGMENTS" | awk -v barcodefile="$barcodes_filtered" -v s="$sample" '
	                BEGIN {
        	           while ((getline < barcodefile) > 0) {
                	        if ($0 !~ /sample|Sex/) {
                       		split($0, csv, ",")
                        	split(csv[1], bc_parts, ":")
                        	barcode = bc_parts[2]
                        	map[barcode] = csv[7]
                        	 }
                  	 }
                	close(barcodefile)
                	FS = "\t"
                	OFS = "\t"
	                }
	                {
	                   $1=$1
        	           ctype = map[$4]
                	   if (ctype != "") {
                        	gsub(/ /, "_", ctype)
                        	outfile = s "_" ctype ".tsv"
                        	print $0 >> outfile
                  	 }
			}'

       		echo "Begin the sort, zip, and index for $sample"

		# Sort, zip, and index output files
        	for file in "${sample}"_*.tsv; do
                	[ -e "$file" ] || continue
                	echo "Sorting and indexing $file..."
                	sort -k1,1 -k2,2n "$file" | bgzip > "${file}.gz"
                	tabix -p bed "${file}.gz"
                	rm "$file"
        	done

		echo "Done processing $sample : $(date)"

	done

	echo "Cell type separation complete : $(date)"

}

# Function:
#SplitTSV mouse/ mouse_split/ cell_metadata.csv

SplitTSV_scprint() {
        local sampleDir="$1"
        local outDir="$2"
        local barcodes="$3"

        # Check all inputs have been provided
        if [[ -z "$sampleDir" || -z "$outDir" || -z "$barcodes" ]]; then
                echo "SplitTSV: <sampleDir> <outDir> <barcodes_csv>"
                return 1
        fi

        # Make output directory
        if [ ! -d "$outDir" ]; then
                mkdir -p "$outDir"
        fi

        # Get the sample IDs
        cd $sampleDir
        find . -mindepth 1 -maxdepth 1 -type d | sed 's|^\./||' | sort > "$outDir/sample_sheet.txt"
        samples=($(cat "$outDir/sample_sheet.txt"))

        echo ${samples[@]}
        echo "Number of samples: ${#samples[@]}"

        # Iterate split through each sample
        for sample in "${samples[@]}"
        do
                IN=$sampleDir/$sample

                cd $outDir
                if [ ! -d "$outDir/$sample" ]; then
                        mkdir -p "$outDir/$sample"
                fi
                cd $outDir/$sample

                # Get the fragment file
                FRAG_FILES=($IN/*fragments*.tsv.gz)
                FRAGMENTS="${FRAG_FILES[0]}"

                echo "Processing $sample using the $FRAGMENTS file"

                # Filter barcode file for barcodes only associated with the sample
                barcodes_filtered="temp_${sample}_metadata.csv"
                head -n 1 "$barcodes" > "$barcodes_filtered"
                grep ",${sample}," "$barcodes" >> "$barcodes_filtered"

                # Extract barcodes and map to cell_type name
                zcat "$FRAGMENTS" | awk -v barcodefile="$barcodes_filtered" -v s="$sample" '
                        BEGIN {
                           while ((getline < barcodefile) > 0) {
                                if ($0 !~ /sample|Sex/) {
                                split($0, csv, ",")
                                split(csv[1], bc_parts, ":")
                                barcode = bc_parts[2]
                                map[barcode] = csv[7]
                                 }
                         }
                        close(barcodefile)
                        FS = "\t"
                        OFS = "\t"
                        }
                        {
                           $1=$1
                           ctype = map[$4]
                           if (ctype != "") {
                                $4 = s ":" $4
                                gsub(/ /, "_", ctype)
                                outfile = s "_" ctype ".tsv"
                                print $0 >> outfile
                         }
                        }'

                echo "Begin the sort, zip, and index for $sample"

                # Sort, zip, and index output files
                for file in "${sample}"_*.tsv; do
                        [ -e "$file" ] || continue
                        echo "Sorting and indexing $file..."
                        sort -k1,1 -k2,2n "$file" | bgzip > "${file}.gz"
                        tabix -p bed "${file}.gz"
                        rm "$file"
                done

                echo "Done processing $sample : $(date)"

        done

        echo "Cell type separation complete : $(date)"

}

# Function:
#SplitTSV_scprint mouse/ mouse_split_scprint/ cell_metadata.csv
qq
