#!/usr/bin/env python3
"""Prepare a private native preview directory, without changing SDDM or system files."""
import argparse
from pathlib import Path
import shutil
from theme_tools import blurred_wallpapers,validate_theme

HERE=Path(__file__).resolve().parent

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--wallpaper',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True,help='New directory; existing paths are refused')
    args=parser.parse_args()
    files={name:(HERE/'theme'/name).read_bytes() for name in ['Main.qml','metadata.desktop','theme.conf']}
    files.update(blurred_wallpapers(args.wallpaper))
    validate_theme(files)
    args.output.mkdir(mode=0o700,parents=False,exist_ok=False)
    try:
        for name,data in files.items():(args.output/name).write_bytes(data)
    except Exception:
        shutil.rmtree(args.output)
        raise
    print('Prepared and validated:',args.output.resolve())

if __name__=='__main__':main()
