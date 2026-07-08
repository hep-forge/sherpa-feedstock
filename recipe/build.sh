#! /usr/bin/bash
set -e

# For Sherpa v2, remove '--as-needed' from LDFLAGS so all libraries keep
# their symbols defined after the packaging step
export LDFLAGS="$(echo "${LDFLAGS}" | sed 's/ -Wl,--as-needed//g')"

# Upstream's bundled .texi manual has real syntax errors beyond just
# broken @ref/@menu cross-references (e.g. an unbalanced @verbatim /
# @end smallformat in Sherpa.texi) that no makeinfo flag can paper over
# -- it's the manual, not functionality, so skip building it entirely.
sed -i '/^\t\tManual \\$/d' Makefile.am

# Sherpa's own m4/acinclude.m4 builds CONDITIONAL_LHAPDFLIBS from
# `lhapdf-config --ldflags`, but modern LHAPDF's lhapdf-config documents
# --ldflags as '-L only' (the -lLHAPDF flag is only added by --libs).
# That drops libLHAPDF.so from libSherpaTools.la's link line entirely,
# so LHAPDF symbols end up unresolved shared-lib-undefined and Sherpa
# fails at runtime with "undefined symbol: ...LHAPDF6Config3getEv".
sed -i 's/lhapdf-config --ldflags/lhapdf-config --libs/' m4/acinclude.m4

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
