#!/usr/bin/python
import sys
import os
import urlparse

def resolve(origin, relative):
    origin = urlparse.urlparse(origin)
    relative = urlparse.urlparse(relative)
    if relative.path == '':
        raise ValueError('path part of URL is empty.') 
    resolved = (
        relative.scheme if relative.scheme != '' else origin.scheme,
        relative.netloc if relative.netloc != '' else origin.netloc,
        os.path.normpath(os.path.join(os.path.dirname(origin.path),relative.path)),
        '','',''
    )
    return urlparse.urlunparse(resolved)

# python relative_path.py http://www.stbbs.net/hoge/foo.json bar.tar.xz
if __name__ == '__main__':
    print resolve(sys.argv[1],sys.argv[2])
