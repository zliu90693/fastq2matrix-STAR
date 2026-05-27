# %%
import pandas as pd
import subprocess
# %%
meta_experiment = pd.read_csv("./metadata/metadata_CNP0006161_experiment.tsv", sep="\t")
meta_experiment
# %%
brains_df = meta_experiment[meta_experiment["sample_name"].str.contains("brain")]
brains_df
# %%
# brains_df
# %%
# Bb_d7_a_brain = brains_df[brains_df["sample_name"] == "Bb_d7_a_brain"]
# Bb_d7_a_brain.to_csv("./metadata/Bb_d7_a_brain.tsv", sep="\t")
# Bb_d7_a_brain[["sample_name", "experiment_accession", "run_accession", "library_name", "file_name", "file2_name"]].to_csv("./metadata/Bb_d7_a_brain_simplify.tsv", sep="\t")
# %%
brains_df["file_prefix"] = brains_df["file_name"].apply(lambda x: "_".join(x.split("_")[0:-1]))
brains_df
# %%
brains_df_simplify = brains_df[["sample_name", "library_name", "file_prefix"]]
brains_df_simplify
# %%
fq_link = pd.read_csv("./metadata/data_download_links_CNP0006161_ftp.txt", sep=" ", header=None)
fq_link.drop(columns=[0], inplace=True)
fq_link["prefix_key"] = fq_link[1].apply(lambda x: "_".join(x.split("/")[-1].split("_")[0:-1]))
fq_link
# %%
fq_link_merged = pd.merge(brains_df_simplify, fq_link, left_on="file_prefix", right_on="prefix_key", how="left")
fq_link_merged
# %%
brain_link = fq_link_merged[1]
brain_link.to_csv("./metadata/tmp.txt", index=False, header=False)
# %%
subprocess.run("sed 's/ftp:/https:/g' ./metadata/tmp.txt > ./metadata/brain_fq_links.txt", shell=True) # ftp不适用后续使用aria2c下载，替换为https
# %%
