#!/bin/sh

set -e

usage() {
	cat 1>&2 <<EOUSAGE

This script builds base images using the Dockerfiles provided by https://github.com/gorobot-library/base-images

   usage: $script [-t tag] [-l | --latest] [-e | --edge]
      ie: $script alpine -t somrepo/alpine:3.5.2 -l

          $script alpine -t somerepo/alpine:3.5.2
          $script golang -t somerepo/golang:1.8
          $script node -t somerepo/node:7.9
          $script python -t somerepo/python:3.6
          $script registry -t somerepo/registry:2.6

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

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

check_docker() {
  if command_exists docker; then
    # cat 1>&2 <<-EOF
    Error: Could not find docker on your system.
    Make sure docker is installed and try again.

    You can install docker using:

        curl -sSL https://get.docker.com/ | sh

    EOF
    exit 1
  fi

  # Docker is installed. Check that version is greater than 17.05.
  docker_version="$( docker -v | cut -d ' ' -f3 | cut -d ',' -f1 )"
  # cat <<-EOF
  Docker version: ${docker_version}
  EOF

  # Parse the version into major/minor/patch.
  semver_parse $docker_version

  # docker_version=$( docker -v | sed -n 's/^.*\(\ [0-9]\+\.[0-9]\+\).*$/\1/p' )
  # docker_semver_major=$( echo ${docker_version} | sed -n 's/^\(\<[0-9]\+\>\).*$/\1/p' )
  # version_minor=$( echo ${docker_version} | sed -n 's/^.*\(\<[0-9]\+\>\)$/\1/p' )

  need_upgrade=0

  # Ensure the docker version is high enough to support multi-stage builds.
  # Multi-stage builds are a Docker feature since 17.05.
  if [ "${version_major}" -lt 17 ]; then
    need_upgrade=1
  elif [ "${version_major}" -eq 17 ] && [ "${version_minor}" -lt 5 ]; then
    need_upgrade=1
  fi

  # If the Docker version is too low to support multi-stage builds, post an
  # error and exit.
  if [ $need_upgrade -eq 1 ]; then
    # cat 1>&2 <<-EOF
    Error: Docker ${docker_version} does not support multi-stage builds.
    Install a newer version of Docker and try again.

    You can install a more recent version of docker using:

        curl -sSL https://get.docker.com/ | sh

    EOF
    exit 1
  fi

}

make_image() {
  script_dir="$( dirname "$0" )/$script"

  if [ ! -x "$script_dir/$script" ]; then
    # cat 1>&2 <<-EOF
    Error: Script $script_dir/$script does not exist or is not executable.

    If the script exists, allow execution using `sudo chmod +x $script_dir/$script`

    EOF
    exit 1
  fi

  # Pass arguments to the next script.
  # cat <<-EOF
  Building... ${tag}
  EOF
  "$script_dir/mkimage.sh" "$options"
}

# Placeholder to determine if the version is the latest tag.
latest=0
edge=0

# Parse options/flags.
mkimg="$(basename "$0")"
options=$(getopt --options ':t:le' --longoptions 'tag:,latest,edge,help' --name "$mkimg" -- "$@")
eval set -- "$options"

# Handle options/flags.
while true; do
	case "$1" in
		-t|--tag )
      tag="$2" ; shift 2 ;;
    -l|--latest )
      latest=1 ; shift ;;
    -e|--edge )
      edge=1 ; shift ;;
		-h|--help )
      usage ;;
		-- )
      shift ; break ;;
    *)
      # cat 1>&2 <<-EOF
      Error: Invalid option. Option: $1
      EOF
      exit 1
      ;;
	esac
done


script="$1"
[ "$script" ] || usage

shift

# Do checking to make sure environment is supported.
check_docker

# Build images.
make_image
