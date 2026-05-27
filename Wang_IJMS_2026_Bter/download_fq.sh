#!/bin/bash

storage_path=/data/share/data/Zhou_lab_seq_data/20260401_lzy_sc_fastq
project_name="Wang_IJMS_2026_Bter"
target_path="${storage_path}/${project_name}"
mkdir -p $target_path
# aria2c -i "./metadata/brain_fq_links.txt" -d $target_path -j 16 -x 5 -s 5
aria2c \
    --continue=true \
    --max-tries=0 \
    --retry-wait=30 \
    --connect-timeout=120 \
    --timeout=300 \
    -x 4 -s 4 \
    --auto-file-renaming=false \
    -d $target_path \
    -i "./metadata/brain_fq_links.txt"