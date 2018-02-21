#!/bin/sh

QUIET=0

echoerr() {
  if [ "$QUIET" -ne 1 ]; then printf "%s\n" "$*" 1>&2; fi
}

usage() {
  exitcode="$1"
  cat << USAGE >&2
Usage:
  $cmdname -d directory [-u url] [-- command args]
  -d directory                        MBtiles directory
  -q | --quiet                        Do not output any status messages
  -u url | --url=url                  URL to download mbtiles file if mbtiles folder is empty
  -- COMMAND ARGS                     Execute command with args after the test finishes
USAGE
  exit "$exitcode"
}

check_folder() {
    if [ ! -d "$DIRECTORY" ]; then
        mkdir -p "$DIRECTORY"
    fi
    if [ "$(ls -A $DIRECTORY)" ]; then
        echo "Directory already contains files, starting tileserver now."
        exit 0
    else
        echo "Empty directory, start downloading $MBTILES_URL."
        wget -O "$DIRECTORY""/auto-downloaded.mbtiles" "$MBTILES_URL" --no-check-certificate
        exit 0
    fi
}

while [ $# -gt 0 ]
do
  case "$1" in
    -d)
    DIRECTORY="$2"
    shift 2
    ;;
    -q | --quiet)
    QUIET=1
    shift 1
    ;;
    -u)
    MBTILES_URL="$2"
    if [ "$MBTILES_URL" = "" ]; then break; fi
    shift 2
    ;;
    --)
    shift
    break
    ;;
    --help)
    usage 0
    ;;
    *)
    echoerr "Unknown argument: $1"
    usage 1
    ;;
  esac
done

if [ "$DIRECTORY" = "" ]; then
  echoerr "Error: you need to provide a directory to test."
  usage 2
fi

check_folder "$@"
