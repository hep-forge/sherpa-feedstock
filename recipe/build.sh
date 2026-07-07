#! /usr/bin/bash
set -e

# For Sherpa v2, remove '--as-needed' from LDFLAGS so all libraries keep
# their symbols defined after the packaging step
export LDFLAGS="$(echo "${LDFLAGS}" | sed 's/ -Wl,--as-needed//g')"

autoreconf --install

# Sherpa v2 is Python 2 only, so disable Python
./configure \
    --prefix="${PREFIX}" \
    --enable-hepmc2="${PREFIX}" \
    --enable-lhapdf="${PREFIX}" \
    --with-sqlite3="${PREFIX}" \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    PYTHON=""

NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu)
make --jobs="${NPROC}"
make install
