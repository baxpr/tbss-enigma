FROM ubuntu:24.04

# Initial system
RUN apt-get -y update \
    && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
    sudo wget curl cmake git unzip zip xvfb ghostscript imagemagick \
    bc dc file libfontconfig1 libfreetype6 libgl1-mesa-dev \
    libgl1-mesa-dri libglu1-mesa-dev libgomp1 libice6 libxt6 \
    libxcursor1 libxft2 libxinerama1 libxrandr2 libxrender1 \
    libopenblas-dev language-pack-en \
    python3-pip \
    && \
    apt-get clean

# Script and info install
COPY src /opt/tbss-enigma/
COPY README.md /opt/tbss-enigma/
COPY enigma /opt/tbss-enigma/

# ImageMagick policy update to allow PDF creation
COPY ImageMagick-policy.xml /etc/ImageMagick-6/policy.xml

# ANTS snippet from neurodocker
ENV ANTSVER="2.5.4"
ENV ANTSPATH="/opt/ants-$ANTSVER"
ENV PATH="${ANTSPATH}/bin:$PATH"
RUN echo "Installing ANTs ..." \
    && mkdir -p /opt/ants-build \
    && curl -fsSL --retry 5 https://github.com/ANTsX/ANTs/archive/refs/tags/v${ANTSVER}.tar.gz \
       | tar -xz -C /opt/ants-build --strip-components 1 \
    && cd /opt/ants-build && mkdir build install && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=$ANTSPATH \
       -DBUILD_TESTING=OFF -DRUN_LONG_TESTS=OFF -DRUN_SHORT_TESTS=OFF .. 2>&1 \
    && make -j 4 2>&1 \
    && cd ANTS-build \
    && make install 2>&1 \
    && cd /opt && rm -r /opt/ants-build

# FSL environment vars before FSL install
ENV FSLDIR="/opt/fsl" \
    PATH="/opt/fsl/bin:$PATH" \
    FSLOUTPUTTYPE="NIFTI_GZ" \
    FSLMULTIFILEQUIT="TRUE" \
    FSLTCLSH="/opt/fsl/bin/fsltclsh" \
    FSLWISH="/opt/fsl/bin/fslwish" \
    FSLLOCKDIR="" \
    FSLMACHINELIST="" \
    FSLREMOTECALL=""

# Main FSL download. See https://fsl.fmrib.ox.ac.uk/fsldownloads/manifest.csv
RUN wget -nv -O /opt/fsl.tar.gz \
        "https://fsl.fmrib.ox.ac.uk/fsldownloads/fsl-6.0.5.2-centos7_64.tar.gz" && \
    cd /opt && \
    tar -zxf fsl.tar.gz && \
    rm /opt/fsl.tar.gz

# FSL python installer
RUN ${FSLDIR}/etc/fslconf/fslpython_install.sh

# Python3 setup
RUN pip3 install pandas fpdf

# Path
ENV PATH="/opt/tbss-enigma/src:$PATH"

# Entrypoint
ENTRYPOINT ["entrypoint.sh"]
