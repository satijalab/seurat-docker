#!/bin/bash

# Set up error handling
set -e

# Variables
CRAN_REPO="https://cloud.r-project.org/bin/linux/ubuntu"
R2U_REPO="https://r2u.stat.illinois.edu/ubuntu"
R_VERSION="4.0"
USER="docker"
HOME_DIR="/home/$USER"
R_HOME="/usr/local/lib/R"
LANG="en_US.UTF-8"
TZ="UTC"

# Update and install necessary packages
apt-get update && apt-get upgrade -y
apt-get install -y --no-install-recommends \
    ca-certificates \
    locales \
    wget \
    python3-dbus \
    python3-gi \
    python3-apt

# Configure locale
echo "$LANG UTF-8" >> /etc/locale.gen
locale-gen "$LANG"
update-locale LANG="$LANG"
export LC_ALL="$LANG"
export LANG="$LANG"
export DEBIAN_FRONTEND=noninteractive
export TZ="$TZ"

# Add CRAN and R2U repositories
wget -qO- "$CRAN_REPO/marutter_pubkey.asc" | tee /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/cran_ubuntu_key.asc] $CRAN_REPO jammy-cran$R_VERSION/" > /etc/apt/sources.list.d/cran.list

wget -qO- "$R2U_REPO/dirk_eddelbuettel_pubkey.asc" | tee /etc/apt/trusted.gpg.d/dirk_eddelbuettel_pubkey.asc
echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/dirk_eddelbuettel_pubkey.asc] $R2U_REPO jammy main" > /etc/apt/sources.list.d/r2u.list

# Set pin preferences for R2U repo
cat <<EOF > /etc/apt/preferences.d/99r2u
Package: *
Pin: release o=CRAN-Apt Project
Pin: release l=CRAN-Apt Packages
Pin-Priority: 700
EOF

# Install R and required R packages
apt-get update
apt-get install -y --no-install-recommends \
    r-base \
    r-base-dev \
    r-recommended \
    r-cran-bspm \
    r-cran-docopt \
    r-cran-littler \
    r-cran-remotes

# Set up directory permissions for R package installations
chown root:staff "$R_HOME/site-library"
chmod g+ws "$R_HOME/site-library"

# Install utility scripts using littler
ln -s /usr/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r
ln -s /usr/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r
ln -s /usr/lib/R/site-library/littler/examples/update.r /usr/local/bin/update.r

# Configure bspm for automatic package installation and disable version check
echo "options(bspm.version.check=FALSE)" >> /etc/R/Rprofile.site
echo "suppressMessages(bspm::enable())" >> /etc/R/Rprofile.site
echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/90local-no-recommends

# Clean up unnecessary files to reduce disk usage
rm -rf /var/lib/apt/lists/* /tmp/*

# Check installation
echo "R setup complete!"
R -q -e "sessionInfo()"
