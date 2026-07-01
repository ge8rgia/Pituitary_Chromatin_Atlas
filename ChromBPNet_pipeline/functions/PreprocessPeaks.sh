#!/bin/bash

PreprocessPeaks() {
        local BEDfile="$1"
	local inputDir="$2"
	local genome="$3"
	local outName="$4"

	# Check all inputs have been provided
        if [[ -z "$BEDfile" || -z "$inputDir" || -z "$genome" ]]; then
                echo "Beginning PreprocessPeaks"
                return 1
        fi

	# Define paths
	outDir="$inputDir/ChromBPnet/data/$genome/$outName"
	genome_fasta="$inputDir/genome/$genome/${genome}.fa"
	genome_blacklist="$inputDir/genome/$genome/${genome}_blacklist.bed.gz"
	genome_chrom_sizes="$inputDir/genome/$genome/${genome}.chrom.sizes"
	genome_chrom_subset="$inputDir/genome/$genome/${genome}.chrom.subset.sizes"
	splits="$inputDir/ChromBPnet/splits/$genome"

	# Generate fold splits
	echo "Generating fold splits for $genome"
	case $genome in
		mm10) chr_number=21 ;;
		hg38) chr_number=24 ;;
		rn6)  chr_number=22 ;;
		*)    echo "Error: Unknown genome $genome"; exit 1 ;;
	esac

	if [ ! -d "$inputDir/ChromBPnet/splits/$genome" ]; then
		mkdir -p "$inputDir/ChromBPnet/splits/$genome"
        fi

	head -n "$chr_number" "$genome_chrom_sizes" > "$genome_chrom_subset"

	if [[ "$genome" == "mm10" ]]; then
	   chrombpnet prep splits -c "$genome_chrom_subset" -tcr chr1 chr3 chr6 -vcr chr8 chr14 -op "$splits/fold_0"
	   chrombpnet prep splits -c "$genome_chrom_subset" -tcr chr2 chr8 chr9 chr16 -vcr chr12 chr17 -op "$splits/fold_1"
	   chrombpnet prep splits -c "$genome_chrom_subset" -tcr chr4 chr11 chr12 chr15 chrY -vcr chr19 chr7 -op "$splits/fold_2"
	   chrombpnet prep splits -c "$genome_chrom_subset" -tcr chr5 chr10 chr14 chr18 -vcr chr6 chr15 -op "$splits/fold_3"
	   chrombpnet prep splits -c "$genome_chrom_subset" -tcr chr7 chr13 chr17 chr19 chrX -vcr chr10 chr18 -op "$splits/fold_4"
	elif [[ "$genome" == "hg38" ]]; then
	   chrombpnet prep splits -c "$genome_chrom_subset" -tcr chr1 chr3 chr6 -vcr chr8 chr20 -op "$splits/fold_0"
	   chrombpnet prep splits -c "$genome_chrom_subset" -tcr chr2 chr8 chr9 chr16 -vcr chr12 chr17 -op "$splits/fold_1"
	   chrombpnet prep splits -c "$genome_chrom_subset" -tcr chr4 chr11 chr12 chr15 chrY -vcr chr22 chr7 -op "$splits/fold_2"
	   chrombpnet prep splits -c "$genome_chrom_subset" -tcr chr5 chr10 chr14 chr18 chr20 chr22 -vcr chr6 chr21 -op "$splits/fold_3"
	   chrombpnet prep splits -c "$genome_chrom_subset" -tcr chr7 chr13 chr17 chr19 chr21 chrX -vcr chr10 chr18 -op "$splits/fold_4"
	elif [[ "$genome" == "rn6" ]]; then
	   chrombpnet prep splits -c "$genome_chrom_subset" -tcr chr1 chr3 chr6 -vcr chr8 chr20 -op "$splits/fold_0"
	   chrombpnet prep splits -c "$genome_chrom_subset" -tcr chr2 chr8 chr9 chr16 -vcr chr12 chr17 -op "$splits/fold_1"
	   chrombpnet prep splits -c "$genome_chrom_subset" -tcr chr4 chr11 chr12 chr15 chrY -vcr chr19 chr7 -op "$splits/fold_2"
	   chrombpnet prep splits -c "$genome_chrom_subset" -tcr chr5 chr10 chr14 chr18 chr20 -vcr chr6 chr15 -op "$splits/fold_3"
	   chrombpnet prep splits -c "$genome_chrom_subset" -tcr chr7 chr13 chr17 chr19 chrX -vcr chr10 chr18 -op "$splits/fold_4"
	fi

	echo "Done generating fold splits."

	# Change peak file provided from 3 columns to 10 (required input)
	echo "Beginning conversion of bed file: 3 columns to 10"
	base_name=$(basename "$BEDfile" .bed)
	modified_bed="$outDir/${base_name}_modified.bed"
	awk -v OFS='\t' '{
	    summit_offset = int(($3 - $2) / 2);
	    print $1, $2, $3, "peak_"NR, ".", ".", ".", ".", ".", summit_offset
	}' "$BEDfile" > "$modified_bed"

	# Generate peaks_no_blacklist.bed
	echo "Generate peaks_no_blacklist bed file"
	gzip "$modified_bed"
	bedtools slop -i "$genome_blacklist" -g "$genome_chrom_sizes" -b 1057 > $outDir/temp.bed
	bedtools intersect -v -a "${modified_bed}.gz" -b $outDir/temp.bed > $outDir/peaks_no_blacklist.bed

	# Generate nonpeaks per fold
	echo "Generate nonpeaks (one output per fold split)"
	for fold in "$splits"/*.json
	do
		fold_name=$(basename "$fold")
		fold_id="${fold_name%.json}"

		echo "Starting non-peaks for $fold_id"
		chrombpnet prep nonpeaks \
			-g "$genome_fasta" \
			-p "$outDir/peaks_no_blacklist.bed" \
			-c "$genome_chrom_sizes" \
			-fl "$fold" \
			-br "$genome_blacklist" \
			-o "$outDir/output_${fold_id}"
		echo "Done."
	done

	echo "PreprocessPeaks complete."
}

# Call Function
# PreprocessPeaks \
#	$BEDfile
#	$inputDir
#	$genome
