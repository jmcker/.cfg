#!/bin/bash

# Fix file permission errors
sudo chmod -R u+r /var/lib/lxcfs/cgroup/*
sudo systemback-cli
