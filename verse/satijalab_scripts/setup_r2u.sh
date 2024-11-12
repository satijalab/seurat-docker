#!/bin/bash

# Set up error handling
set -e

# Variables
CRAN=${1:-${CRAN:-"https://cran.r-project.org"}}
R2U_REPO="https://r2u.stat.illinois.edu/ubuntu"
R_VERSION="4.0"
USER="docker"
HOME_DIR="/home/$USER"
R_HOME="/usr/local/lib/R"
LANG="en_US.UTF-8"
TZ="UTC"
ARCH=$(uname -m)
PURGE_BUILDDEPS=${PURGE_BUILDDEPS:-"true"}

# Function to install apt packages only if they are not installed
function apt_install() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            apt-get update
        fi
        apt-get install -y --no-install-recommends "$@"
    fi
}

# Update and install essential packages
apt-get update && apt-get upgrade -y
apt_install ca-certificates locales wget python3-dbus python3-gi python3-apt

# Configure locale
echo "$LANG UTF-8" >> /etc/locale.gen
locale-gen "$LANG"
update-locale LANG="$LANG"
export LC_ALL="$LANG"
export LANG="$LANG"
export DEBIAN_FRONTEND=noninteractive
export TZ="$TZ"

# Add CRAN and R2U repositories
wget -qO- "${CRAN}/bin/linux/ubuntu/marutter_pubkey.asc" | tee /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/cran_ubuntu_key.asc] ${CRAN} jammy-cran${R_VERSION}/" > /etc/apt/sources.list.d/cran.list

wget -qO- "$R2U_REPO/dirk_eddelbuettel_pubkey.asc" | tee /etc/apt/trusted.gpg.d/dirk_eddelbuettel_pubkey.asc
echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/dirk_eddelbuettel_pubkey.asc] $R2U_REPO jammy main" > /etc/apt/sources.list.d/r2u.list

# Set pin preferences for R2U repo
cat <<EOF > /etc/apt/preferences.d/99r2u
Package: *
Pin: release o=CRAN-Apt Project
Pin: release l=CRAN-Apt Packages
Pin-Priority: 700
EOF

# Configure R default CRAN repository in Rprofile.site
echo "options(repos = c(CRAN = '${CRAN}'), download.file.method = 'libcurl')" >> "${R_HOME}/etc/Rprofile.site"

# Set HTTPUserAgent for RSPM compatibility
cat <<EOF >>"${R_HOME}/etc/Rprofile.site"
options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))
EOF

# Install R and essential R packages
apt-get update
apt_install r-base r-base-dev r-recommended r-cran-bspm r-cran-docopt r-cran-littler r-cran-remotes

# Set up directory permissions for R package installations
chown root:staff "$R_HOME/site-library"
chmod g+ws "$R_HOME/site-library"

# Check for `libopenblas-dev` and configure it if missing
if ! dpkg -l | grep -q libopenblas-dev; then
    apt_install libopenblas-dev
    update-alternatives --set "libblas.so.3-${ARCH}-linux-gnu" "/usr/lib/${ARCH}-linux-gnu/openblas-pthread/libblas.so.3"
fi

# Configure bspm for automatic package installation and disable version check
echo "options(bspm.version.check=FALSE)" >> /etc/R/Rprofile.site
echo "suppressMessages(bspm::enable())" >> /etc/R/Rprofile.site
echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/90local-no-recommends

# Check if littler is installed and install additional dependencies if needed
if ! command -v r >/dev/null 2>&1; then
    BUILDDEPS="libpcre2-dev libdeflate-dev liblzma-dev libbz2-dev zlib1g-dev libicu-dev"
    apt_install $BUILDDEPS
    Rscript -e "install.packages(c('littler', 'docopt'), repos='${CRAN}')"
    
    # Clean up build dependencies
    if [ "${PURGE_BUILDDEPS}" != "false" ]; then
        apt-get remove --purge -y $BUILDDEPS
    fi
    apt-get autoremove -y
    apt-get autoclean -y
fi

# Link littler scripts to make them globally accessible
ln -sf "${R_HOME}/site-library/littler/bin/r" /usr/local/bin/r
ln -sf "${R_HOME}/site-library/littler/examples/installGithub.r" /usr/local/bin/installGithub.r
ln -sf "${R_HOME}/site-library/littler/examples/install2.r" /usr/local/bin/install2.r
ln -sf "${R_HOME}/site-library/littler/examples/update.r" /usr/local/bin/update.r

# Clean up unnecessary files to reduce disk usage
rm -rf /var/lib/apt/lists/* /tmp/*

# Check installation
echo -e "Check the littler info...\n"
r --version

echo -e "Check the R info...\n"
R -q -e "sessionInfo()"

echo "R setup complete!"
