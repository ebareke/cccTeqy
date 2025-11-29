# Dockerfile for cccTeqy — Autonomous ChIP-seq / CUT&RUN / CUT&Tag Pipeline
#
# Build:
#   docker build -t cccteqy:latest .
#
# Run (example):
#   docker run --rm -v /data:/data -v $PWD:/work \
#       cccteqy:latest ./run.sh -c config.yaml -s samples.tsv

FROM mambaorg/micromamba:1.5.0

# Make micromamba environment available in all subsequent RUN/CMD
ARG MAMBA_DOCKERFILE_ACTIVATE=1

# Install core bioinformatics stack via conda/bioconda
RUN micromamba install -y -n base -c conda-forge -c bioconda \
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
    && micromamba clean -a -y

# Create working directory for the pipeline
WORKDIR /opt/cccTeqy

# Copy pipeline scripts and default config/sample files (if present)
# You can omit config.yaml and samples.tsv if you want to provide them at runtime.
COPY run.sh /opt/cccTeqy/run.sh
COPY config.yaml /opt/cccTeqy/config.yaml
COPY samples.tsv /opt/cccTeqy/samples.tsv

RUN chmod +x /opt/cccTeqy/run.sh

# Environment variables for the pipeline
ENV PATH=/opt/conda/bin:$PATH
ENV PHANTOMPEAK_RSCRIPT=/opt/conda/bin/run_spp.R
ENV RSCRIPT=Rscript
ENV PICARD=picard

# Default entrypoint: call the pipeline. You can override CMD/arguments at runtime.
WORKDIR /opt/cccTeqy
ENTRYPOINT ["./run.sh"]
CMD ["-h"]
