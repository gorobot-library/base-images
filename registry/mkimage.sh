#!/bin/sh

set -e

image_name="registry"

usage() {
	cat 1>&2 <<EOUSAGE

This script builds the $image_name base image.

   usage: $script [-t tag] [-l | --latest] [-e | --edge]
      ie: $script -t somerepo/$image_name:2.6.1 -l

  builds: somerepo/$image_name:2.6.1
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
  if [ -n ${repo} ]; then
    build_base="${repo}/${image}"
  else
    build_base="${image}"
  fi

  build_name="${build_base}:${tag}"
}

check_deps() {
  alpine_image_exists=$( docker images | grep alpine )

  if [ ! "${alpine_image_exists}" ]; then
    cat 1>&2 <<-EOF
    Error: Could not find alpine image.
    Build the alpine:latest base image before building other images.
		EOF
    exit 1
  fi
}

make_image() {

  tmp=$( mktemp -d /tmp/${image_name}.XXXXXX )

  # Get the system architecture.
  arch=$( uname -m )

  # Test the architecture of the system to make sure that there is an available
  # release.
  case "${arch}" in
    'armv6l'|'armv7l' )
      # If the architecture is ARM, we need to use the armhf release.
      arch='armhf' ;;
    'x86' )
      arch='x86' ;;
    'x86_64' )
      arch='x86_64' ;;
    * )
      # If the current architecture is not a part of the above list, the image
      # cannot be built.
      cat 1>&2 <<-EOF
      Error: Architecture not supported.
      ${arch} is not currently supported.
			EOF
      exit 1
      ;;
  esac

  if [ ${tag} == "latest" ]; then
    cat 1>&2 <<-EOF
    Error: Invalid tag.
    To tag the image as 'latest', use the '-l' flag.
		EOF
    exit 1
  elif [ ${tag} == "edge" ]; then
    cat 1>&2 <<-EOF
    Error: Invalid tag.
    To tag the image as 'edge', use the '-e' flag.
		EOF
    exit 1
  fi

  semver_parse $tag

  # ----------------------------------------
  # Build the registry image.
  # ----------------------------------------

  dist="v${version_major}.${version_minor}"

  cp ./Dockerfile ${tmp}/Dockerfile

  # Docker build.
  docker build --build-arg DISTRIBUTION_VER=${dist} -t ${build_name} ${tmp}
  docker_exit_code=$?

  if [ "$docker_exit_code" = "0" ]; then
    cat 1>&2 <<-EOF
    Error: Docker build failed with exit code ${docker_exit_code}
		EOF
    exit 1
  fi

  if [ ("${latest}") ]; then
    docker tag ${build_name} "${build_base}:latest"
  fi

  if [ ("${edge}") ]; then
    docker tag ${build_name} "${build_base}:edge"
  fi
}

# Placeholder to determine if the version is the latest tag.
latest=0
edge=0

# Handle arguments/flags.
while true; do
	case "$1" in
		-t|--tag )
      image_parse $tag ; shift 2 ;;
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

mkimg="$(basename "$0")"

# Check for dependencies.
check_deps

# Build the image.
make_image
