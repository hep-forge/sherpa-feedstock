#! /usr/bin/bash
set -e

# For Sherpa v2, remove '--as-needed' from LDFLAGS so all libraries keep
# their symbols defined after the packaging step
export LDFLAGS="$(echo "${LDFLAGS}" | sed 's/ -Wl,--as-needed//g')"

autoreconf --install

# Sherpa v2 is Python 2 only, so disable Python
# Upstream's bundled .texi manual has broken @ref/@menu cross-references
# that a modern strict makeinfo treats as a hard error rather than a
# warning -- disable node validation for the docs; it's the manual, not
# functionality.
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
# MAKEINFO="prog flags" isn't reliably honored (automake's rule is
# $(MAKEINFO) $(MAKEINFOFLAGS), and MAKEINFO is expected to be just the
# program name) -- pass the flag via MAKEINFOFLAGS at make time instead.
make --jobs="${NPROC}" MAKEINFOFLAGS=--no-validate
make install
