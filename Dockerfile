FROM ubuntu:20.04

# Initial system
RUN apt-get -y update \
    && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -q --no-install-recommends \
    ca-certificates curl unzip zip \
    nano python3 python3-pip sudo wget cmake git xvfb ghostscript imagemagick \
    bc dc file libfontconfig1 libfreetype6 libgl1-mesa-dev \
    libgl1-mesa-dri libglu1-mesa-dev libgomp1 libice6 \
    libopenblas-base libxcursor1 libxft2 libxinerama1 libxrandr2 libxrender1 \
    libxt6 language-pack-en \
    && \
    apt-get clean

# ANTS snippet from neurodocker
ENV ANTSPATH="/opt/ants-2.5.4/" \
    PATH="/opt/ants-2.5.4:$PATH"
RUN echo "Downloading ANTs ..." \
    && curl -fsSL -o ants.zip https://github.com/ANTsX/ANTs/releases/download/v2.5.4/ants-2.5.4-ubuntu-20.04-X64-gcc.zip \
    && unzip ants.zip -d /opt \
    && mv /opt/ants-2.5.4/bin/* /opt/ants-2.5.4 \
    && rm ants.zip

# FSL snippet from neurodocker
ENV FSLDIR="/opt/fsl-6.0.7.16" \
    PATH="/opt/fsl-6.0.7.16/bin:$PATH" \
    FSLOUTPUTTYPE="NIFTI_GZ" \
    FSLMULTIFILEQUIT="TRUE" \
    FSLTCLSH="/opt/fsl-6.0.7.16/bin/fsltclsh" \
    FSLWISH="/opt/fsl-6.0.7.16/bin/fslwish" \
    FSLLOCKDIR="" \
    FSLMACHINELIST="" \
    FSLREMOTECALL="" \
    FSLGECUDAQ="cuda.q"
RUN echo "Installing FSL ..." \
    && curl -fsSL https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fslinstaller.py | \
        python3 - -d /opt/fsl-6.0.7.16 -V 6.0.7.16


# Python3 setup
RUN pip3 install pandas fpdf

# ImageMagick policy update to allow PDF creation
COPY ImageMagick-policy.xml /etc/ImageMagick-6/policy.xml

# Script and info install
COPY src /opt/tbss-enigma/src
COPY enigma /opt/tbss-enigma/enigma
COPY README.md /opt/tbss-enigma/

# Path
ENV PATH="/opt/tbss-enigma/src:$PATH"

# Entrypoint
ENTRYPOINT ["entrypoint.sh"]
