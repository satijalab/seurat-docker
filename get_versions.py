#!/usr/bin/env python

"""Get versions of a package"""

from __future__ import print_function

# import sys
import json
# import logging
# import argparse
import requests

# if sys.version_info.major == 2:
#     import ConfigParser
# elif sys.version_info.major == 3:
#     import configparser as ConfigParser
# else:
#     sys.exit("Unknown Python version, please use Python 2 or Python 3")

package = 'Seurat'

url = 'http://crandb.r-pkg.org/%s/all' % package

if __name__ == '__main__':
    x = requests.get(url)
    if not x.ok:
        raise SystemExit("Failed to get data for package %s" % package)
    # import code; code.interact(local=locals()); sys.exit()
    for i in sorted(json.loads(x.text)['versions']):
        print(str(i))
