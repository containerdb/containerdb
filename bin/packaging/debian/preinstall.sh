#!/usr/bin/env bash

if hash containerdb 2>/dev/null; then
  echo 'ALREADY INSTALLED'
else
  echo 'FIRST INSTALLATION'
fi
