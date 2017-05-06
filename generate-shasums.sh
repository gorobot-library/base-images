#!/bin/bash

set -e

script="$(basename "$0")"
script_dir="$(dirname "$0")"

usage() {
	cat 1>&2 <<EOUSAGE
This script generates the SHASUMS256.txt files used by the Dockerfiles.

   usage: ./$script [-i image] [-a all]

 example: ./$script -i golang   - Generate SHASUMS256.txt for golang.
          ./$script             - Generate all SHASUMS256.txt files.

EOUSAGE
exit 1
}

golang_shasums() {
  tmp=$( mktemp -d /tmp/go_sha.XXXXXX )
  golang_shasum_file="${script_dir}/golang/SHASUMS256.txt"

  golang_download_url="https://storage.googleapis.com/golang"

  golang_versions=(
    "1.8.1" "1.8" "1.7.5" "1.7.4" "1.7.3" "1.7.1" "1.7" "1.6.4" "1.6.3" "1.6.2"
    "1.6.1" "1.6" "1.5.4"
  )

  if [ -f "${golang_shasum_file}" ]; then
    rm -f "${golang_shasum_file}"
  fi

  touch "${golang_shasum_file}"
  echo "### Golang Official Checksums" > ${golang_shasum_file}

  for go_ver in "${golang_versions[@]}"; do
    curl -sSL "$golang_download_url/go$go_ver.src.tar.gz.sha256" \
      -o ${tmp}/go$go_ver.src.tar.gz.sha256

    echo "$(cat ${tmp}/go$go_ver.src.tar.gz.sha256)  go$go_ver.src.tar.gz" >> ${golang_shasum_file}

    rm "${tmp}/go$go_ver.src.tar.gz.sha256"
  done
}

node_shasums() {
  tmp=$( mktemp -d /tmp/node_sha.XXXXXX )
  node_shasum_file="${script_dir}/node/SHASUMS256.txt"

  node_download_url="https://nodejs.org/download/release"

  node_versions=(
    "v7.9.0" "v7.8.0" "v7.7.4" "v7.7.3" "v7.7.2" "v7.7.1" "v7.7.0" "v7.6.0"
    "v7.5.0" "v7.4.0" "v7.3.0" "v7.2.1" "v7.2.0" "v7.1.0" "v7.0.0" "v6.10.2"
    "v6.10.1" "v6.10.0" "v6.9.5" "v6.9.4" "v6.9.3" "v6.9.2" "v6.9.1" "v6.9.0"
    "v6.8.1" "v6.8.0" "v6.7.0" "v6.6.0" "v6.5.0" "v6.4.0" "v6.3.1" "v6.3.0"
    "v6.2.2" "v6.2.1" "v6.2.0" "v6.1.0" "v6.0.0" "v5.12.0" "v5.11.1" "v5.11.0"
    "v5.10.1" "v5.10.0" "v5.9.1" "v5.9.0" "v5.8.0" "v5.7.1" "v5.7.0" "v5.6.0"
    "v5.5.0" "v5.4.1" "v5.4.0" "v5.3.0" "v5.2.0" "v5.1.1" "v5.1.0" "v5.0.0"
    "v4.8.2" "v4.8.1" "v4.8.0" "v4.7.3" "v4.7.2" "v4.7.1" "v4.7.0" "v4.6.2"
    "v4.6.1" "v4.6.0" "v4.5.0" "v4.4.7" "v4.4.6" "v4.4.5" "v4.4.4" "v4.4.3"
    "v4.4.2" "v4.4.1" "v4.4.0" "v4.3.2" "v4.3.1" "v4.3.0" "v4.2.6" "v4.2.5"
    "v4.2.4" "v4.2.3" "v4.2.2" "v4.2.1" "v4.2.0" "v4.1.2" "v4.1.1" "v4.1.0"
    "v4.0.0" "v0.12.18" "v0.12.17" "v0.12.16" "v0.12.15" "v0.12.14" "v0.12.13"
    "v0.12.12" "v0.12.11" "v0.12.10" "v0.12.9" "v0.12.8" "v0.12.7" "v0.12.6"
    "v0.12.5" "v0.12.4" "v0.12.3" "v0.12.2" "v0.12.1" "v0.12.0" "v0.11.16"
    "v0.11.15" "v0.11.14" "v0.11.13" "v0.11.12" "v0.11.11" "v0.11.10" "v0.11.9"
    "v0.11.8" "v0.11.7" "v0.11.6" "v0.11.5" "v0.11.4" "v0.11.3" "v0.11.2"
    "v0.11.1" "v0.11.0" "v0.10.48" "v0.10.47" "v0.10.46" "v0.10.45" "v0.10.44"
    "v0.10.43" "v0.10.42" "v0.10.41" "v0.10.40" "v0.10.39" "v0.10.38"
    "v0.10.37" "v0.10.36" "v0.10.35" "v0.10.34" "v0.10.33" "v0.10.32"
    "v0.10.31" "v0.10.30" "v0.10.29" "v0.10.28" "v0.10.27" "v0.10.26"
    "v0.10.25" "v0.10.24" "v0.10.23" "v0.10.22" "v0.10.21" "v0.10.20"
    "v0.10.19" "v0.10.18" "v0.10.17" "v0.10.16" "v0.10.15" "v0.10.14"
    "v0.10.13" "v0.10.12" "v0.10.11" "v0.10.10" "v0.10.9" "v0.10.8" "v0.10.7"
    "v0.10.6" "v0.10.5" "v0.10.4" "v0.10.3" "v0.10.2" "v0.10.1" "v0.10.0"
  )

  if [ -f "${node_shasum_file}" ]; then
    rm -f "${node_shasum_file}"
  fi

  touch "${node_shasum_file}"
  echo "### Node Official Checksums" > ${node_shasum_file}

  node_keys=(
    9554F04D7259F04124DE6B476D5A82AC7E37093B
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5
    FD3A5288F042B6850C66B31F09FE44734EB7990E
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D
    B9AE9905FFD7803F25714661B63B535A4C206CA9
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8
    56730D5401028683275BD23C23EFEFE93C4CFFFE
  )

  for node_key in "${node_keys[@]}"; do
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$node_key" || \
    gpg --keyserver pgp.mit.edu --recv-keys "$node_key" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$node_key"
  done

  for node_ver in "${node_versions[@]}"; do
    curl -sSL "$node_download_url/$node_ver/SHASUMS256.txt.asc" \
      -o ${tmp}/SHASUMS256.txt.asc

    gpg --batch --decrypt --output ${tmp}/SHASUMS256.txt ${tmp}/SHASUMS256.txt.asc

    grep -i " node-$node_ver.tar.xz\$" ${tmp}/SHASUMS256.txt >> ${node_shasum_file}

    rm ${tmp}/SHASUMS256.txt.asc
    rm ${tmp}/SHASUMS256.txt
  done
}

# NOTE: As of 05/01/17, Python does not publish general sha256 checksums for
# their releases. They publish the `.asc` files needed to verify their
# downloads, but do not publish the shasums independently. Therefore, this
# process does not work as desired. For now, the individual files need to be
# downloaded so that the shasums can be generated. In the future, it would be
# good to figure out how to do this without downloading each individual version
# so that bandwidth is conserved.
python_shasums() {
  tmp=$( mktemp -d /tmp/python_sha.XXXXXX )
  python_shasum_file="${script_dir}/python/SHASUMS256.txt"

  python_download_url="https://www.python.org/ftp/python"

  python_versions=(
    "3.6.1" "3.5.3" "3.4.6" "3.3.6" "2.7.13"
  )

  # "3.6.0" "3.4.5" "3.5.2" "2.7.12" "3.4.4" "3.5.1" "2.7.11" "3.5.0" "2.7.10"
  # "3.4.3" "2.7.9" "3.4.2"  "3.2.6" "2.7.8" "2.7.7" "3.4.1" "3.4.0" "3.3.5"
  # "3.3.4" "3.3.3" "2.7.6" "2.6.9" "3.2.5" "3.3.2" "2.7.5" "3.2.4" "3.3.1"
  # "2.7.4" "3.3.0" "3.2.3" "2.6.8" "2.7.3" "3.1.5" "3.2.2" "3.2.1" "2.7.2"
  # "3.1.4" "2.6.7" "2.5.6" "3.2.0" "2.7.1" "3.1.3" "2.6.6" "2.7.0" "3.1.2"
  # "2.6.5" "2.5.5" "2.6.4" "2.6.3" "3.1.1" "3.1.0"

  if [ -f "${python_shasum_file}" ]; then
    rm -f "${python_shasum_file}"
  fi

  touch "${python_shasum_file}"
  echo "### Python Official Checksums" > ${python_shasum_file}

  python_keys=(
    6A45C816
    36580288
    7D9DC8D2
    18ADD4FF
    A4135B38
    A74B06BF
    EA5BBD71
    ED9D77D5
    E6DF025C
    AA65421D
    6F5E1540
    F73C700D
    487034E5
  )

  # for python_key in "${python_keys[@]}"; do
  #   gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$python_key" || \
  #   gpg --keyserver pgp.mit.edu --recv-keys "$python_key" || \
  #   gpg --keyserver keyserver.pgp.com --recv-keys "$python_key"
  # done

  for python_ver in "${python_versions[@]}"; do
    curl -sSL "$python_download_url/${python_ver%%[a-z]*}/Python-$python_ver.tar.xz" \
      -o ${tmp}/Python-$python_ver.tar.xz

    sha256sum "${tmp}/Python-$python_ver.tar.xz" >> ${python_shasum_file}

    rm ${tmp}/Python-$python_ver.tar.xz
  done

  # NOTE: Currently, the script does not replace the temporary directory in the
  # generated `SHASUMS256.txt` file. It needs to be removed manually before
  # committing.
  sed -e "s@${tmp}/@@g" ${python_shasum_file}
}

# Placeholder to determine if the script should generate all shasum files.
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
