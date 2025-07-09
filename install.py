#!/bin/python

import sys
import os
import shutil

# All directories in `DotFiles`
dir_names = []
# `DotFiles` absolute path
cur_path = os.getcwd()
# ${HOME}/.config/ path
config_dir_path = os.path.join(os.path.expanduser('~'), '.config')

# Get all config dirctories in `DotFiles`
def get_dir_names() -> None:
    for filename in os.listdir(cur_path):
        # Only visible directories can be added
        if os.path.isdir(filename) and not filename.startswith('.'):
            dir_names.append(filename)

# Copy single config directory to `${HOME}/.config/`
def copy_to_config(dir_name: str) -> None:
    src_dir = os.path.join(cur_path, dir_name)
    dst_dir = os.path.join(config_dir_path, dir_name)

    # .config/{dir_name} not exist, create it
    if not os.path.exists(dst_dir):
        os.mkdir(dst_dir)

    # If config directory is existed, cover it
    shutil.copytree(src_dir, dst_dir, symlinks=True, dirs_exist_ok=True)

# Copy all config directories to `${HOME}/.config/`
def copy_all() -> None:
    for dir in dir_names:
        copy_to_config(dir)

if __name__ == '__main__':
    get_dir_names()
    args = sys.argv

    # No argument provided, copy all config directory to `${HOME}/.config/`
    if len(args) == 1: 
        copy_all()
        sys.exit()
    
    # Match config directory name in `dir_names`
    for arg in args:
        if arg in dir_names:
            copy_to_config(arg)