#!/usr/bin/env python

"""Prepare some Dockerfiles"""

from __future__ import division
from __future__ import print_function

import os
import re
import sys
import json
import time
import datetime

from collections import OrderedDict

try:
    import requests
    from packaging import version
except ImportError:
    raise SystemExit("Please install requests and packaging")


PACKAGE = 'Seurat' # type: str
CRANDB = 'http://crandb.r-pkg.org/%(package)s/all' # type: str
VERSION_FORMAT = '%Y-%m-%d %H:%M:%S' # type: str
TIMELINE_FORMAT = '%Y-%m-%dT%H:%M:%S+00:00' # type: str
UBUNTU_VERSION = os.getenv('SEURAT_DOCKER_UBUNTU', 'xenial') # type: str
DOCKER_IMAGE = 'rstudio/r-base:%(version)s-%(ubuntu)s' # type: str
R_CMD = 'R --slave --no-restore --no-save -e'
SYSTEM_DEPENDENCIES = ( # type: Tuple[str]
    'libhdf5-dev',
    'libcurl4-openssl-dev',
    'libssl-dev',
    'libxml2-dev',
    'libpng-dev',
    'openjdk-8-jdk',
    'python3-dev',
    'python3-pip',
    'wget'
)

NOT_CRAN = set() # type: Set[unicode]
DEPENDENCIES = dict() # type: Dict[unicode, collections.OrderedDict[unicode, unicode]]
DEPENDENCY_VERSIONS = dict() # type: Dict[unicode, Tuple[unicode]]

def get_nearest_dependency(package, pkg_version, global_version): # type: (str, str, str) -> None
    """Recursively build a nearest-dependency graph"""
    print("Getting dependencies for %(package)s v%(version)s" % {'package': package, 'version': pkg_version}, file=sys.stderr)
    #   Get the CRAN DB entry for this package
    resp = requests.get(CRANDB % {'package': package}) # type: requests.models.Response
    if not resp.ok:
        raise SystemExit('blah')
    try:
        pkg_content = json.loads(resp.text)['versions'][pkg_version] # type: Dict[unicode, Any]
    except KeyError:
        print("Cannot find version %(version)s of %(package)s" % {'version': pkg_version, 'package': package}, file=sys.stderr)
        NOT_CRAN.add(package)
        DEPENDENCIES[global_version].pop(package, None)
        return None
    #   Get the date this version of the package went to CRAN
    pkg_time = time.strptime(pkg_content['crandb_file_date'].strip().split('<')[0], VERSION_FORMAT) # type: time.struct_time
    pkg_date = datetime.datetime.fromtimestamp(time.mktime(pkg_time)) # type: datetime.datetime
    #   Get the dependencies for this version of the package
    dependencies = OrderedDict() # type: collections.OrderedDict[unicode, unicode]
    for dep, ver in pkg_content.get('Depends', {}).items(): # type: unicode, unicode
        dependencies[dep] = ver.split(' ')[-1]
    for dep, ver in pkg_content.get('Imports', {}).items(): # type: unicode, unicode
        dependencies[dep] = ver.split(' ')[-1]
    #   Remove dependencies not on CRAN
    for d in NOT_CRAN: # type: unicode
        try:
            dependencies.pop(d)
        except KeyError:
            pass
    #   Filter out dependencies older than our global version
    deps = dependencies.keys() # type: Iterable[unicode]
    for d in deps: # type: unicode
        if d in DEPENDENCIES[global_version] and d != u'R':
            gdv = DEPENDENCIES[global_version].pop(d) # type: unicode
            DEPENDENCIES[global_version][d] = gdv
        if d in DEPENDENCY_VERSIONS:
            try:
                dver = DEPENDENCY_VERSIONS[d].index(dependencies[d]) # type: int
            except ValueError:
                dver = -1 # type: int
            try:
                gdver = DEPENDENCY_VERSIONS[d].index(DEPENDENCIES[global_version].get(d, u'*')) # type: int
            except ValueError:
                gdver = -1 # type: int
            if dver < gdver:
                print("Not getting dependencies for %s as it's lower than what we have" % d, file=sys.stderr)
                dependencies.pop(d)
    #   Get the nearest build for each dependency
    for d in dependencies: # type: unicode
        dependencies[d] = dependencies[d].split()[-1]
        dresp = requests.get(CRANDB % {'package': d}) # type: requests.models.Response
        if not dresp.ok:
            if d != 'R':
                print("No CRANDB for %s" % d, file=sys.stderr)
                NOT_CRAN.add(d)
            continue
        print("Getting closest version of %s" % d, file=sys.stderr)
        timeline = json.loads(dresp.text)['timeline'].copy() # type: Dict[unicode, unicode]
        timeline = {k: time.mktime(time.strptime(v, TIMELINE_FORMAT)) for k, v in timeline.items()} # type: Dict[unicode, float]
        if not d in DEPENDENCY_VERSIONS or len(timeline) > len(DEPENDENCY_VERSIONS[d]):
            DEPENDENCY_VERSIONS[d] = (u'*',) + tuple(sorted(timeline, key=lambda x: timeline[x])) # type: Tuple[unicode]
        timeline = filter(lambda x: datetime.datetime.fromtimestamp(x[-1]) <= pkg_date, timeline.items()) # type: Tuple[unicode, float]
        timeline = max(timeline, key=lambda x: x[-1]) # type: Tuple[unicode, float]
        try:
            dver = DEPENDENCY_VERSIONS[d].index(timeline[0]) # type: int
        except ValueError:
            dver = -1 # type: int
        try:
            ddver = DEPENDENCY_VERSIONS[d].index(dependencies[d]) # type: int
        except ValueError:
            ddver = -1 # type: int
        if dver > ddver:
            dependencies[d] = timeline[0]
    #   Clean out dependencies not on CRAN
    for d in NOT_CRAN: # type: unicode
        try:
            dependencies.pop(d)
        except KeyError:
            pass
    #   Update global dependencies
    deps = dependencies.keys() # type: Iterable[unicode]
    for d in deps: # type: unicode
        # max_ver = max((dependencies[d], DEPENDENCIES[global_version].get(d, u'&')), key=version.parse) # type: unicode
        if d == u'R':
            max_ver = max((dependencies[d], DEPENDENCIES[global_version].get(d, u'&')), key=version.parse) # type: unicode
        else:
            max_ver = max((dependencies[d], DEPENDENCIES[global_version].get(d, u'*')), key=DEPENDENCY_VERSIONS[d].index) # type: unicode
        DEPENDENCIES[global_version][d] = max_ver
        dependencies[d] = max_ver
    for d in deps: # type: unicode
        if d == 'R':
            continue
        get_nearest_dependency(package=d, pkg_version=dependencies[d], global_version=global_version) # type: OrderedDict[unicode, unicode]
    return None


def get_R_range(min_ver): # type: (str) -> Tuple[str]
    """Get a range of R versions"""
    #   Get max R version
    repo_resp = requests.get('https://api.github.com/repos/rstudio/r-docker/contents') # type: requests.models.Response
    if not repo_resp.ok:
        print('Using R 3.6 as maximal R version', file=sys.stderr)
        max_r = '3.6' # type: str
    else:
        repo_dir = json.loads(repo_resp.text) # type: List[Dict[unicode, Any]]
        repo_dir = filter(lambda x: x['type'] == 'dir', repo_dir) # type: Iterable[Dict[unicode, Any]]
        repo_dir = map(lambda x: x['name'], repo_dir) # type: Iterable[unicode]
        repo_dir = tuple(filter(lambda x: re.search(r'^\d', x), repo_dir)) # type: Tuple[unicode]
        max_r = max(repo_dir, key=version.parse)
    while min_ver.count('.') > 1:
        min_ver = '.'.join(min_ver.split('.')[:-1])
    if min_ver.split('.')[0] not in set(x.split('.')[0] for x in repo_dir):
        print("Wrong major version for minimum version specified", file=sys.stderr)
        return repo_dir
    versions = list() # type: List[str]
    versions.append(min_ver)
    while version.parse(versions[-1]) < version.parse(max_r):
        next_ver = list(map(int, versions[-1].split('.'))) # type: List[int]
        next_ver[-1] += 1
        versions.append('.'.join(map(str, next_ver)))
    versions = sorted(set(versions).intersection(set(repo_dir)), key=version.parse) # type: List[unicode]
    if not versions:
        print("Warn", file=sys.stderr)
        return repo_dir
    return tuple(versions)


def write_docker(global_version, r_version): # type: (...) -> None
    """Write a Docker file for installing Seurat"""
    continue_line = ' \\\n    ' # type: str
    devtools_cmd = "remotes::install_version('%(package)s', version = '%(version)s', upgrade = FALSE)" # type: str
    if global_version == 'latest':
        header = '# Docker image for the latest build of Seurat (v%s)' % global_version # type: str
    else:
        header = '# Docker image for Seurat v%s' % global_version # type: str
    docker = DOCKER_IMAGE % {'version': r_version, 'ubuntu': UBUNTU_VERSION} # type: str
    outdir = os.path.join(global_version, r_version, UBUNTU_VERSION) # type: str
    if not os.path.isdir(outdir):
        os.makedirs(outdir)
    with open(os.path.join(outdir, 'Dockerfile'), 'wt') as ofile:
        print("Writing %s" % ofile.name, file=sys.stderr)
        #   Use Rstudio's docker image as a base
        ofile.write(header + '\n')
        ofile.write('FROM %s\n\n' % docker)
        #   Steps for setting global R options
        rprofile = '$(%s "cat(Sys.getenv(\'R_HOME\'))")/etc/Rprofile.site' % R_CMD # type: str
        ofile.write('# Set global R options\n')
        ofile.write('RUN echo "options(repos = \'https://cloud.r-project.org\')" > %s\n\n' % rprofile)
        #   Steps for Seurat's system dependencies
        ofile.write("# Install Seurat's system dependencies\n")
        ofile.write('RUN apt-get update\n')
        ofile.write('RUN apt-get install -y%s' % continue_line)
        ofile.write(continue_line.join(SYSTEM_DEPENDENCIES))
        ofile.write('\n\n')
        if global_version == 'latest':
            ofile.write('# Install the latest version of Seurat\n')
            ofile.write('RUN %s "isntall.packages(\'Seurat\')"\n\n' % R_CMD)
        else:
            #   Steps for installing remotes
            ofile.write('# Install remotes\n')
            ofile.write('RUN %s "install.packages(\'remotes\')"\n\n' % R_CMD)
            #   Steps for installing UMAP
            ofile.write('# Install UMAP\n')
            ofile.write('RUN pip3 install umap-learn\n\n')
            #   Steps for installing dependencies
            if global_version in DEPENDENCIES:
                version_use = global_version # type: str
            else:
                version_use = max(DEPENDENCIES.keys(), key=version.parse)
            ofile.write('# Install depdencies for Seurat\n')
            for d in DEPENDENCIES[version_use].keys()[::-1]: # type: unicode
                if d == 'R':
                    continue
                dcmd = devtools_cmd % {'package': d, 'version': DEPENDENCIES[version_use][d]} # type: str
                ofile.write('RUN %(rcmd)s "%(dcmd)s"\n' % {'rcmd': R_CMD, 'dcmd': dcmd})
            ofile.write('\n')
            #   Steps for installing Seurat
            dcmd = devtools_cmd % {'package': PACKAGE, 'version': global_version} # type: str
            ofile.write('# Install Seurat v%s\n' % global_version)
            ofile.write('RUN %(rcmd)s "%(dcmd)s"\n\n' % {'rcmd': R_CMD, 'dcmd': dcmd})
        #   Add CMD
        ofile.write('CMD [ "R" ]\n')


if __name__ == '__main__':
    response = requests.get(CRANDB % {'package': PACKAGE}) # type: requests.models.Response
    if not response.ok:
        raise SystemExit("Cannot find package information for %s" % PACKAGE)
    content = json.loads(response.text) # type: Dict[unicode, Any]
    for v in content['timeline']: # type: unicode
        DEPENDENCIES[v] = OrderedDict() # type: OrderedDict[unicode, unicode]
    latest = max(content['timeline'], key=lambda x: time.mktime(time.strptime(content['timeline'][x], TIMELINE_FORMAT))) # type: unicode
    get_nearest_dependency(package=PACKAGE, pkg_version=latest, global_version=latest)
    write_docker(
        global_version='latest',
        r_version=get_R_range(DEPENDENCIES[latest]['R'])[0]
    )
    sys.exit()
