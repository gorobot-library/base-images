#!/bin/sh

set -e

script="$(basename "$0")"
script_dir="$(dirname "$0")"

usage() {
	cat 1>&2 <<EOUSAGE

This script generates the SHASUMS256.txt files used by the Dockerfiles.

   usage: $script [-i image] [-a all]

 example: $script -i golang   - Generates SHASUMS256.txt for golang downloads only.
          $script             - Generates all SHASUMS256.txt files.

EOUSAGE
exit 1
}

golang_shasums() {
  tmp=$( mktemp -d /tmp/go_sha.XXXXXX )
  shasum_file="${script_dir}golang/SHASUMS256.txt"

  go_download_url="https://storage.googleapis.com/golang"

  go_versions=("1.8.1" "1.8" "1.7.5" "1.7.4" "1.7.3" "1.7.1" "1.7" "1.6.4" "1.6.3" "1.6.2" "1.6.1" "1.6" "1.5.4" "1.5.3" "1.5.2" "1.5.1" "1.5" "1.4.3" "1.4.2" "1.4.1" "1.4" "1.3.3" "1.3.2" "1.3.1" "1.3" "1.2.2")

  if [ -f "${shasum_file}" ]; then
    rm -f "${shasum_file}"
    echo "### Golang Official Shasums." > ${shasum_file}
  fi

  for go_ver in "${go_versions[@]}"; do
    curl -sSL "$go_download_url/go$go_ver.src.tar.gz" \
      -o ${tmp}/go$go_ver.src.tar.gz
    curl -sSL "$go_download_url/go$go_ver.src.tar.gz.sha256" \
      -o ${tmp}/go$go_ver.src.tar.gz.sha256

    echo "$(cat go$go_ver.src.tar.gz.sha256)  go$go_ver.src.tar.gz" | sha256sum -c -
    if [ $? -ne 1 ]; then
      echo "$(cat go$go_ver.src.tar.gz.sha256)  go$go_ver.src.tar.gz" >> ${shasum_file}
    fi

  done
}

build_all=0

# Parse options/flags.
options=$(getopt -u --options ':i:ah' --longoptions 'image:,all,help' --name "${script}" -- "$@")
eval set -- "${options}"

# Handle options/flags.
while true; do
	case "$1" in
		-i|--image )
      image="$2" ; shift 2 ;;
    -a|--all )
      build_all=1 ; shift ;;
		-h|--help )
      usage ;;
		-- )
      shift ; break ;;
    *)
      cat 1>&2 <<-EOF
			Error: Invalid option. Option: $1
			EOF
      exit 1
      ;;
	esac
done

if [ -z "${image}" ] && [ "${build_all}" -eq 0 ]; then
  build_all=1
fi

if [ "${build_all}" -ne 0 ]; then
  golang_shasums
  node_shasums
  python_shasums
else
  ${image}_shasums
fi
