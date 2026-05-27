**Note: To run the bash scripts in this .md file, you need to download the Markdown Execute plugin.**

**Due to the specific environmental dependencies of dnbc4tools, this project does not utilize conda or pip for installation; instead, following the instructions at https://mgi-tech-bioinformatics.github.io/DNBelab_C_Series_HT_scRNA-analysis-software/Document/site/doc/quickstart.html, the executable file is downloaded directly from ftp://ftp.cngb.org/pub/CNSA/data7/CNP0008672/Single_Cell/CSE0000574/dnbc4tools-3.1.tar.gz, and its path is subsequently added to the system's PATH environment variable.**

## Wang_IJMS_2026_Bter

- This dataset is hosted on CNGB rather than NCBI; therefore, it cannot be downloaded using fasterq-dump. The fastq files are downloaded using the script `Bter_download`, located within the `Wang_IJMS_2026_Bter` directory.
- Download fastq metadata manually from https://ftp.cngb.org/pub/CNSA/data7/public_info/CNP0006161/
  ```bash
  wget -c ftp://ftp.cngb.org/pub/CNSA/data7/public_info/CNP0006161/data_download_links_CNP0006161_ftp.txt -O "./Wang_IJMS_2026_Bter/metadata/data_download_links_CNP0006161_ftp.txt"
  wget -c ftp://ftp.cngb.org/pub/CNSA/data7/public_info/CNP0006161/metadata_CNP0006161_experiment.tsv -O "./Wang_IJMS_2026_Bter/metadata/metadata_CNP0006161_experiment.tsv"
  wget -c ftp://ftp.cngb.org/pub/CNSA/data7/public_info/CNP0006161/metadata_CNP0006161_sample_Model_organism_or_animal_sample.tsv -O "./Wang_IJMS_2026_Bter/metadata/metadata_CNP0006161_sample_Model_organism_or_animal_sample.tsv"
  ```
- Extract only the brain-specific entries from the complete list of fastq links using [analyse_metadata](./Wang_IJMS_2026_Bter/analyse_metadata.py)
- Dowanload fastq using [download_fq.sh](./Wang_IJMS_2026_Bter/download_fq.sh)
  ```bash
  cd Wang_IJMS_2026_Bter
  ./download_fq.sh
  ```