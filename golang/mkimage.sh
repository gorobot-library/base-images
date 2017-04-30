#!/bin/sh

set -e

image_name="golang"

usage() {
	cat 1>&2 <<EOUSAGE

This script builds the $image_name base image.

   usage: $mkimg [-t tag] [-l | --latest] [-e | --edge]
      ie: $mkimg -t somerepo/$image_name:1.8.1 -l

  builds: somerepo/$image_name:1.8.1
          somerepo/$image_name:latest

WARNING: This script is meant to be run using the mkimage script in the
parent directory.

EOUSAGE
exit 1
}

semver_parse() {
  version_major="${1%%.*}"
	version_minor="${1#$version_major.}"
	version_minor="${version_minor%%.*}"
	version_patch="${1#$version_major.$version_minor.}"
	version_patch="${version_patch%%[-.]*}"
}

image_parse() {
  repo="${1%%\/*}"
  image="${1#$repo\/}"
  image="${image%%\:*}"
  tag="${1#$repo\/$image\:}"

  build_base=''
  if [ -n "${repo}" ]; then
    build_base="${repo}/${image}"
  else
    build_base="${image}"
  fi

  build_name="${build_base}:${tag}"
}

check_deps() {
  # Make sure a base/alpine image is available and usable on the system.
  alpine_image_exists=$( docker images | grep base/alpine )

  if [ ! "${alpine_image_exists}" ]; then
    cat 1>&2 <<-EOF
		Error: Could not find alpine base image.
		Build the base/alpine:3.5.0 base image before building other images.

				sh mkimage.sh alpine -t base/alpine:3.5.0

		EOF
    exit 1
  fi
}

make_image() {

  tmp=$( mktemp -d /tmp/${image_name}.XXXXXX )

  if [ "${tag}" = "latest" ]; then
    cat 1>&2 <<-EOF
		Error: Invalid tag.
		To tag the image as 'latest', use the '-l' flag.
		EOF
    exit 1
  elif [ "${tag}" = "edge" ]; then
    cat 1>&2 <<-EOF
		Error: Invalid tag.
		To tag the image as 'edge', use the '-e' flag.
		EOF
    exit 1
  fi

  semver_parse "${tag}"

  dist="${version_major}.${version_minor}.${version_patch}"

  # ----------------------------------------
  # Build the golang image.
  # ----------------------------------------

  cp ${mkimg_dir}/Dockerfile ${tmp}/Dockerfile
  cp ${mkimg_dir}/go-wrapper ${tmp}/go-wrapper

  # Docker build.
  docker build \
    --build-arg GOLANG_VERSION=${tag} \
    -t ${build_name} ${tmp}
  docker_exit_code=$?

  if [ "${docker_exit_code}" -ne 0 ]; then
    cat 1>&2 <<-EOF
		Error: Docker build failed.
		Docker failed with exit code ${docker_exit_code}
		EOF
    exit 1
  fi

  if [ "${latest}" -eq 1 ]; then
    docker tag ${build_name} "${build_base}:latest"
  fi

  if [ "${edge}" -eq 1 ]; then
    docker tag ${build_name} "${build_base}:edge"
  fi
}

# Placeholder to determine if the version is the latest tag.
latest=0
edge=0

# Parse options/flags.
mkimg="$(basename "$0")"
mkimg_dir="$(dirname "$0")"

options=$(getopt --options ':t:le' --longoptions 'tag:,latest,edge,help' --name "${mkimg}" -- "$@")
eval set -- "${options}"

# Handle arguments/flags.
while true; do
	case "$1" in
		-t|--tag )
      image_parse "$2" ; shift 2 ;;
    -l|--latest )
      latest=1 ; shift ;;
    -e|--edge )
      edge=1 ; shift ;;
		-h|--help )
      usage ;;
		-- )
      shift ; break ;;
	esac
done

# Check for dependencies.
check_deps

# Build the image.
make_image
