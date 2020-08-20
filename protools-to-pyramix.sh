#!/bin/bash

[[ $# -lt 5 ]] && { echo "Usage: $0 <MAPFILE> <NO_OF_TAKES> <SRC_DIR> <DST_DIR> <NAME> [yes]"; exit 2; }

MAPFILE="$1"
TAKES="$2"
SRCDIR="$3"
DSTDIR="$4"
NAME="$5"
NO_REALLY="$5"

for take in $(seq -w 01 $2); do
  tracknoraw=1
  cat "${MAPFILE}" | while read pttrackname; do
    trackno=$(printf "%02d" ${tracknoraw})
    src="${pttrackname}_${take}.wav"
    dst=$(echo "${src}" | sed -r 's/^.*_(..)\.wav$/'${NAME}'_'0${take}'_##'${trackno}'##_.wav/')
    [[ $5 == "yes" ]] \
      &&      mv -iv "${SRCDIR}/${src}" "${DSTDIR}/${dst}" \
      || echo mv -iv "${SRCDIR}/${src}" "${DSTDIR}/${dst}"
    ((tracknoraw++))
  done
done
