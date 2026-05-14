#!/bin/bash

# Depends on conda environment: kingfisher (see .env/kingfisher.yml)

set -euo pipefail

storage_path=/data/share/data/Zhou_lab_seq_data/20260401_lzy_sc_fastq # Please modify this path according to your needs.
project_name=""
aria2c_j=10
aria2c_x=5
aria2c_s=5
threads=8
pigz_threads=16


while getopts "p:j:x:s:t:z:" opt; do
    case $opt in
        p) project_name=$OPTARG ;;
        j) aria2c_j=$OPTARG ;;
        x) aria2c_x=$OPTARG ;;
        s) aria2c_s=$OPTARG ;;
        t) threads=$OPTARG ;;
        z) pigz_threads=$OPTARG ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Error: Option -$OPTARG requires a parameter value." >&2
            exit 1
            ;;
    esac
done

if [ -z "$project_name" ]; then
    echo "Error: The project name must be specified using -p."
    exit 1
fi

if ! [[ "$aria2c_j" =~ ^[0-9]+$ ]]; then
    echo "Error: -j must be a positive integer."
    exit 1
fi

if ! [[ "$aria2c_x" =~ ^[0-9]+$ ]]; then
    echo "Error: -x must be a positive integer."
    exit 1
fi

if ! [[ "$aria2c_s" =~ ^[0-9]+$ ]]; then
    echo "Error: -s must be a positive integer."
    exit 1
fi

if ! [[ "$threads" =~ ^[0-9]+$ ]]; then
    echo "Error: -t must be a positive integer."
    exit 1
fi

if ! [[ "$pigz_threads" =~ ^[0-9]+$ ]]; then
    echo "Error: -z must be a positive integer."
    exit 1
fi

if ! command -v srapath >/dev/null 2>&1; then
    echo "Error: srapath command not found."
    echo "Activate the kingfisher conda environment first."
    exit 1
fi

if ! command -v aria2c >/dev/null 2>&1; then
    echo "Error: aria2c command not found."
    echo "Activate the kingfisher conda environment first."
    exit 1
fi

if ! command -v fasterq-dump >/dev/null 2>&1; then
    echo "Error: fasterq-dump command not found."
    echo "Activate the kingfisher conda environment first."
    exit 1
fi

project_dir="./${project_name}"
metadata_dir="./${project_dir}/metadata"
srr_list="./${metadata_dir}/SRR_list"
sra_path_list="${metadata_dir}/SRA_path_list"
fastq_dir="${storage_path}/${project_name}"
sra_dir="${fastq_dir}/.sra"

########################################
# Directory / file checks
########################################

# storage path
if [[ ! -d "$storage_path" ]]; then
    echo "Error: storage path does not exist:"
    echo "  $storage_path"
    exit 1
fi

# project directory
if [[ ! -d "$project_dir" ]]; then
    echo "Error: project directory not found:"
    echo "  $project_dir"
    exit 1
fi

# metadata directory
if [[ ! -d "$metadata_dir" ]]; then
    echo "Error: metadata directory not found:"
    echo "  $metadata_dir"
    exit 1
fi

# SRR list
if [[ ! -f "$srr_list" ]]; then
    echo "Error: SRR_list file not found:"
    echo "  $srr_list"
    exit 1
fi

if [[ ! -s "$srr_list" ]]; then
    echo "Error: SRR_list exists but empty."
    exit 1
fi

########################################
# Create output directory safely
########################################

mkdir -p "$sra_dir"

########################################
# Get sra file path
########################################

cat "$srr_list" | xargs -I {} srapath {} > "$sra_path_list"

########################################
# Get sra file
########################################

aria2c -i "$sra_path_list" -d "$sra_dir" -j $aria2c_j -x $aria2c_x -s $aria2c_s

########################################
# Run Fasterq-Dump
########################################


for SRR in $(cat "$srr_list"); do
    mkdir -p "${fastq_dir}/${SRR}" # 之所以新建了一个$SRR目录, 是为了pigz压缩时匹配方便, 因为无法保证不同文章fastq文件一定都是 $SRR*.fastq格式
    fasterq-dump "${sra_dir}/${SRR}.lite.1" \
        --split-files \
        --include-technical \
        --threads "$threads" \
        --outdir "${fastq_dir}/${SRR}" \
        --temp "${fastq_dir}/.tmp/${SRR}" \
        --progress

    wait
    pigz -p "$pigz_threads" "${fastq_dir}/${SRR}/"*.fastq &  # Wait for the previous pigz to finish before starting the new one.
    
    rm -rf "${fastq_dir}/.tmp/${SRR}"
    rm "${sra_dir}/${SRR}.lite.1"
done
wait


find "$fastq_dir" -type f -name "*.fastq.gz" -print0 \
| while IFS= read -r -d '' file; do
    ln -s "$file" "${project_dir}/fastq/$(basename $file)" # 待后续将这些链接依据Samples和lane的关系打包进目录里
done