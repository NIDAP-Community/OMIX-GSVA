ARG REGISTRY_HOST
FROM $REGISTRY_HOST/codeocean/omix-r-pathway:r4.4.3-bioconductor3.20-v2

ARG DEBIAN_FRONTEND=noninteractive
COPY postInstall /
RUN /postInstall
