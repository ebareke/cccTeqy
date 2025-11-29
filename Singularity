# Singularity definition file for cccTeqy
#
# Build from this repo (containing run.sh, config.yaml, samples.tsv):
#   singularity build cccteqy.sif Singularity
#
# Run:
#   singularity exec cccteqy.sif ./run.sh -c config.yaml -s samples.tsv

Bootstrap: docker
From: mambaorg/micromamba:1.5.0

%labels
    Author Ethan Bareke
    Version v1.0.0
    Description "cccTeqy — Autonomous ChIP-seq / CUT&RUN / CUT&Tag Pipeline"

%environment
    export PATH=/opt/conda/bin:$PATH
    export PHANTOMPEAK_RSCRIPT=/opt/conda/bin/run_spp.R
    export RSCRIPT=Rscript
    export PICARD=picard

%post
    echo "[Singularity] Setting up cccTeqy environment" \
      && micromamba install -y -n base -c conda-forge -c bioconda \
            bwa \
            samtools \
            bedtools \
            macs2 \
            fastqc \
            picard \
            preseq \
            deeptools \
            phantompeakqualtools \
            r-base \
            r-argparse \
            multiqc \
      && micromamba clean -a -y \
      && mkdir -p /opt/cccTeqy

%files
    run.sh /opt/cccTeqy/run.sh
    config.yaml /opt/cccTeqy/config.yaml
    samples.tsv /opt/cccTeqy/samples.tsv

%runscript
    cd /opt/cccTeqy
    echo "[cccTeqy] Executing pipeline inside Singularity container" >&2
    exec ./run.sh "$@"
