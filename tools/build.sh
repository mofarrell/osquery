#!/usr/bin/env bash

#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/lib.sh

threads THREADS

cd $SCRIPT_DIR/../

function cleanUp() {
  # Cleanup kernel
  make kernel-unload/fast || sudo reboot
}

# Run build host provisions and install library dependencies.
make deps

# Clean previous build artifacts.
make clean

# Build osquery.
make -j$THREADS

# Build osquery kernel (optional).
make kernel-build

# Setup cleanup code for catastrophic test failures.
trap cleanUp EXIT INT TERM

# Load osquery kernel (optional).
make kernel-load/fast

# Run code unit and integration tests.
make test/fast

# Run kernel unit and integration tests (optional).
make kernel-test/fast

exit 0
