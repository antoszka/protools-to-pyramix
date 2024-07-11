#!/bin/bash

### naming structure (sample source files)
#
# 1-03.52_52.wav
# 2-05.21_22.wav
# 3-38.01_01.wav -> 03_take_01_01_##038##_.wav
# | |  +----------> take number
# | +-------------> lane (track) name
# +---------------> piece number
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
ls -1 "${SRCDIR}" | cut -d- -f1 | sort -u
echo

echo "Found the following tracks:"
ls -1 "${SRCDIR}" | cut -d- -f2 | cut -d. -f1 | sort -u
echo

# Change directory to SRCDIR
echo "Changing directory to ${SRCDIR}."
cd "${SRCDIR}"

for piece in $(ls -1 "${SRCDIR}" | cut -d- -f1 | sort -u); do
  tracknoraw=1
  
  for track in $(ls -1 "${SRCDIR}" | cut -d- -f2 | cut -d. -f1 | sort -u); do
    trackno_l=$(printf "%03d" $((${tracknoraw}*2-1))) ### * 2 - 1
    trackno_r=$(printf "%03d" $((${tracknoraw}*2)))   ### * 2

    for src in ${piece}-${track}.*_*.wav; do
      # Get L/R destination names
      dst_l=$(echo "${src}" | sed -r 's/^.*\.([0-9]+_[0-9]+)\.wav$/'${piece}'_take_\1_##'${trackno_l}'##_.wav/')
      dst_r=$(echo "${src}" | sed -r 's/^.*\.([0-9]+_[0-9]+)\.wav$/'${piece}'_take_\1_##'${trackno_r}'##_.wav/')

      # Make tmpfile holders for split src
      src_l=$(mktemp)
      src_r=$(mktemp)
      mv ${src_l}{,.wav}
      mv ${src_r}{,.wav}
      src_l=${src_l}.wav
      src_r=${src_r}.wav
   
      # Split src
      ffmpeg -y -loglevel 8 -i "${src}" -filter_complex "channelsplit[left][right]" -map "[left]" -c:a pcm_s24le ${src_l} -map "[right]" -c:a pcm_s24le ${src_r} || { echo "Error converting ${src}; exiting..."; exit 127; }

      # copy/move the tmpfiles
      if   [[ "$3" == "doit" ]];   then
        echo -n "$(basename ${src}:) "; mv -fv "${src_l}" "${DSTDIR}/${dst_l}"
        echo -n "$(basename ${src}:) "; mv -fv "${src_r}" "${DSTDIR}/${dst_r}"
      else
        echo REAL SRC IS: " ${src}"
        echo WOULD MOVE L: "${src_l}" "${DSTDIR}/${dst_l}" ### DEBUG
        echo WOULD MOVE R: "${src_r}" "${DSTDIR}/${dst_r}" ### DEBUG
        rm -f ${src_l}
        rm -f ${src_r}
      fi
    done
    ((tracknoraw++)) # increase stereo source lane number
  done
done

# return to original CWD
cd "${CWD}"
