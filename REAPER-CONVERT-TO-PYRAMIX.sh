#!/bin/bash

### naming structure (sample source files)
#
# dupa-cz-1-03-052.wav
# jest-cz-2-05-021.wav
# cala-cz-3-38-101.wav ---> cala-cz-3_take_101_##038##_.wav
# |         |  +----------> take number
# |         +-------------> lane (track) name
# +-----------------------> piece number
#
# OUTPUT: ${piece}_take_${take}_##${lane}##_.wav

SRCDIR=$(realpath "$1")
DSTDIR=$(realpath "$2")

[[ -d "$SRCDIR" ]] || { echo 'SRCDIR does not exist or is not a directory'; exit 1; }
[[ -d "$DSTDIR" ]] || { echo 'DSTDIR does not exist or is not a directory'; exit 1; }

# remember current working dir
CWD="$(pwd)"

# show some debug:
echo "Found the following pieces:"
ls -1 "${SRCDIR}"/*-???.wav | gsed -r 's/^.*\/(.*)-([0-9][0-9])-([0-9][0-9][0-9])\.wav/\1/' | sort -u
echo

echo "Found the following tracks:"
ls -1 "${SRCDIR}"/*-???.wav | gsed -r 's/^.*\/(.*)-([0-9][0-9])-([0-9][0-9][0-9])\.wav/\2/' | sort -u
echo

# Change directory to SRCDIR
echo "Changing directory to ${SRCDIR}."
cd "${SRCDIR}"

for piece in $(ls -1 "${SRCDIR}"/*-???.wav | gsed -r 's/^.*\/(.*)-([0-9][0-9])-([0-9][0-9][0-9])\.wav/\1/' | sort -u); do
  tracknoraw=1
  for track in $(ls -1 "${SRCDIR}"/*-???.wav | gsed -r 's/^.*\/(.*)-([0-9][0-9])-([0-9][0-9][0-9])\.wav/\2/' | sort -u); do
    trackno=$(printf "%03d" ${tracknoraw})
      for src in ${piece}-${track}-???.wav; do
        # kwartet-cz-1-03-048.wav
        dst=$(echo "${src}" | sed -r 's/^.*\-([0-9]+)\.wav$/'${piece}'_take_\1_##'${trackno}'##_.wav/')
        if   [[ "$3" == "doit" ]];   then
          gcp --update=older -iv "${src}" "${DSTDIR}/${dst}"
        elif [[ "$3" == "doitmv" ]]; then
          gmv --update=older -iv "${src}" "${DSTDIR}/${dst}"
        else
          echo cp -iv "${src}" "${DSTDIR}/${dst}"
          echo -n "${track}:${trackno} "
        fi
      done
    ((tracknoraw++))
  done
done

# return to original CWD
cd "${CWD}"
