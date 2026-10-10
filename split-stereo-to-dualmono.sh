#!/usr/bin/env bash
# split-stereo-to-dualmono.sh
#
# Fixes take-aligner/Pyramix multi-mono media that got converted from stereo
# sources without splitting to mono: each "_##00N##_.wav" file here is
# actually a stereo pair and needs to become two mono files, renumbered so
# the whole take runs ##001## - ##008##.
#
# Renumbering: old stereo channel N -> new mono channels (2N-1) and (2N).
#   ##001## (stereo) -> ##001## (L) + ##002## (R)
#   ##002## (stereo) -> ##003## (L) + ##004## (R)
#   ##003## (stereo) -> ##005## (L) + ##006## (R)
#   ##004## (stereo) -> ##007## (L) + ##008## (R)
#
# Channels are processed HIGH-TO-LOW (004 first, ..., 001 last) so a new
# filename never clobbers a not-yet-processed source — only an already-split
# one. Channel 1 is the only case where a destination name equals its own
# source name; ffmpeg finishes reading the source into temp files before the
# temp files are moved into place, so that's safe too.
#
# Usage:
#   ./split-stereo-to-dualmono.sh DIR              # dry run (default)
#   ./split-stereo-to-dualmono.sh DIR --doit       # actually convert
#
# Requires: ffmpeg, ffprobe.
#
# Bit depth / sample format is preserved per-take (queried via ffprobe), not
# assumed — a session recorded at 16-bit won't silently get inflated to 24,
# and vice versa. Sample rate is untouched (channelsplit doesn't resample).
#
# Note: this does not carry over any BWF `bext` chunk from the stereo
# sources — ffmpeg's channelsplit doesn't preserve it, and at this stage
# (pre-alignment) that's fine: take-aligner's `apply` step writes a fresh,
# correct TimeReference into every file later.

set -euo pipefail

DIR="${1:-}"
MODE="${2:-dryrun}"

if [[ -z "$DIR" || ! -d "$DIR" ]]; then
  echo "usage: $0 DIR [--doit]" >&2
  exit 1
fi

pick_codec() {
  # Map ffprobe's sample_fmt/bits_per_raw_sample to a matching pcm_* codec so
  # the split files keep the source's bit depth.
  local fmt="$1" bits="$2"
  case "$fmt" in
    u8)   echo pcm_u8 ;;
    s16)  echo pcm_s16le ;;
    s32)
      if [[ "$bits" == "24" ]]; then echo pcm_s24le
      else echo pcm_s32le
      fi
      ;;
    flt)  echo pcm_f32le ;;
    dbl)  echo pcm_f64le ;;
    *)    echo pcm_s24le ;;  # sane fallback for an unrecognized format
  esac
}

shopt -s nullglob
bases=()
for f in "$DIR"/*_##001##_.wav; do
  bases+=("${f%_##001##_.wav}")
done

if [[ ${#bases[@]} -eq 0 ]]; then
  echo "no *_##001##_.wav files found in $DIR" >&2
  exit 1
fi

echo "found ${#bases[@]} take(s) in: $DIR"
[[ "$MODE" != "--doit" ]] && echo "(dry run — pass --doit to actually convert)"
echo

any_fail=0

for base in "${bases[@]}"; do
  name="$(basename "$base")"
  echo "== $name =="

  missing=0
  for ch in 001 002 003 004; do
    [[ -f "${base}_##${ch}##_.wav" ]] || { echo "  ! missing ##${ch}## — skipping this take"; missing=1; }
  done
  if [[ $missing -eq 1 ]]; then any_fail=1; continue; fi

  if [[ -f "${base}_##005##_.wav" ]]; then
    echo "  ! ##005## already exists — looks already split, skipping"
    continue
  fi

  ok=1
  for ch in 4 3 2 1; do
    src=$(printf "%s_##%03d##_.wav" "$base" "$ch")
    channels=$(ffprobe -v error -select_streams a:0 -show_entries stream=channels -of csv=p=0 "$src" 2>/dev/null || true)
    if [[ "$channels" != "2" ]]; then
      echo "  ! $(basename "$src") is not 2-channel (got '${channels:-?}') — skipping this take"
      ok=0
      break
    fi
  done
  [[ $ok -eq 0 ]] && { any_fail=1; continue; }

  for ch in 4 3 2 1; do
    src=$(printf "%s_##%03d##_.wav" "$base" "$ch")
    newL=$(( ch * 2 - 1 ))
    newR=$(( ch * 2 ))
    dstL=$(printf "%s_##%03d##_.wav" "$base" "$newL")
    dstR=$(printf "%s_##%03d##_.wav" "$base" "$newR")

    fmt=$(ffprobe -v error -select_streams a:0 -show_entries stream=sample_fmt -of csv=p=0 "$src")
    bits=$(ffprobe -v error -select_streams a:0 -show_entries stream=bits_per_raw_sample -of csv=p=0 "$src")
    codec=$(pick_codec "$fmt" "$bits")

    echo "  $(basename "$src")  ->  $(basename "$dstL")  +  $(basename "$dstR")  [$codec]"

    if [[ "$MODE" == "--doit" ]]; then
      tmpL=$(mktemp); mv "$tmpL" "${tmpL}.wav"; tmpL="${tmpL}.wav"
      tmpR=$(mktemp); mv "$tmpR" "${tmpR}.wav"; tmpR="${tmpR}.wav"

      if ! ffmpeg -y -loglevel error -i "$src" \
            -filter_complex "channelsplit[left][right]" \
            -map "[left]"  -c:a "$codec" "$tmpL" \
            -map "[right]" -c:a "$codec" "$tmpR"; then
        echo "    ffmpeg failed on $(basename "$src") — aborting this take"
        rm -f "$tmpL" "$tmpR"
        any_fail=1
        continue 2
      fi
      mv -f "$tmpL" "$dstL"
      mv -f "$tmpR" "$dstR"
    fi
  done
done

echo
if [[ "$MODE" != "--doit" ]]; then
  echo "dry run only — re-run with --doit to actually convert."
fi
exit $any_fail
