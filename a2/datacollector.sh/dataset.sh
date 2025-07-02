#!/bin/bash

# Escape if something goes wrong (usually due to missing libraries, so make sure unzip is installed).
set -e

# Grasp url
read -p "Enter dataset URL: " url
# Create a temp folder to store the extracted files from url
mkdir -p dataset_temp
cd dataset_temp
# Use curl and download data
filename=$(basename "$url")
echo "Downloading  $filename..."
curl -LO "$url"
# If zip, unzip
if [[ "$filename" == *.zip ]]; then
    echo "Zip file detected, unzipping..."
    unzip -o "$filename"
fi
# Look for csv files
csv_files=$(find . -type f -iname "*.csv")

# If csv files empty, escape
if [[ -z "$csv_files" ]]; then
    echo "No CSV located, ending the script..."
    exit 1
fi

# Create another directory for the summaries
mkdir -p ../summaries

# Loop through each CSV
for file in $csv_files; do
    echo ""
    echo "Reading file: $file"

    # Use first line as the header (I hope it's the header).
    header=$(head -n 1 "$file")

    # Detect delimiter type (could be , or ;).
    if [[ "$header" == *";"* ]]; then
        DELIM=';'
    else
        DELIM=','
    fi
    # Form columns in header using chosen delimeter
    IFS="$DELIM" read -ra columns <<< "$header"
    # Print the features first
    echo ""
    echo "Features found in header:"
    for i in "${!columns[@]}"; do
        # Use sed to clean the features from quotes
	colname=$(echo "${columns[$i]}" | sed 's/^["'\'']//; s/["'\'']$//')
        echo "[$i] $colname"
        columns[$i]=$colname
    done

    # Knwoing what the features columns are, ask user which columns are numerical
    echo ""
    read -p "Enter indices of numerical columns, separated with commas (ex. 0,1,2,3): " num_input
    IFS=',' read -ra num_cols <<< "$num_input"

    # Prepare output summary file
    base_name=$(basename "$file" .csv)
    summary_file="../summaries/${base_name}_summary.md"

    # Write header to the summary file
    echo "# Feature Summary for $base_name.csv" > "$summary_file"
    echo "" >> "$summary_file"
    echo "## Feature Index and Names" >> "$summary_file"
    for i in "${!columns[@]}"; do
        index=$((i + 1))
        echo "$index. ${columns[$i]}" >> "$summary_file"
    done

    echo "" >> "$summary_file"
    echo "## Statistics (Numerical Features)" >> "$summary_file"
    echo "| Index | Feature                | Min    | Max    | Mean    | StdDev   |" >> "$summary_file"
    echo "|-------|------------------------|--------|--------|---------|----------|" >> "$summary_file"

    # Loop through each column and calculate the stats
    for col_index in "${num_cols[@]}"; do
        colname=${columns[$col_index]}
        display_index=$((col_index + 1))

        # Use awk to calculate stats using scripting
        awk -v FS="$DELIM" -v idx=$((col_index + 1)) -v name="$colname" -v colnum="$display_index" '
        BEGIN { # variable initialization
            sum = 0;
            sumsq = 0;
            count = 0;
            min = "";
            max = "";
        }
	# skip the header line
        NR > 1 {
            val = $idx + 0;  # typecast to numeric
            if (val == val) {  # check if numeric
                sum += val;
                sumsq += val * val;
                if (min == "" || val < min) min = val;
                if (max == "" || val > max) max = val;
                count++;
            }
        }
        END {
            if (count > 0) {
                mean = sum / count;
                std = sqrt((sumsq - (sum * sum) / count) / count);
                printf "| %-5s | %-22s | %6.2f | %6.2f | %7.4f | %8.4f |\n", colnum, name, min, max, mean, std;
            }
    	# redirect all stats to this var
        }' "$file" >> "$summary_file"

    done

    echo "Summary saved to $summary_file"
done
# Take out the csv files (we don't need them anymore I think).
cd ..
rm -rf dataset_temp

