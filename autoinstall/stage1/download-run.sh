# -*- mode: bash -*-
set -e

# It takes some time to bring up network, so wait a bit to avoid needlessly
# retrying to download code
sleep 10

chvt 7

info() {
  printf "\033[1m\033[31m"
  echo "$@"
  printf "\033[0m\n"
}

notice() {
  printf "\033[1m\033[35m"
  echo "$@"
  printf "\033[0m"
}

O=/tmp/dotfiles
U=http://newton.local:8080/

info "Downloading $U..."

dl() {
  rm -rf "$O" newton.local:8080
  wget --no-verbose --recursive "$U" && mv newton.local:8080 "$O"
}

trydl() {
  for _ in $(seq 10); do
    if dl; then
      return
    fi
    sleep 1
  done
  while ! dl; do
    notice "No internet connection? Connect and press any key to continue."
    read -r
  done
}

trydl

info "Running autoinstall in $O..."

cd "$O"

chmod -R +x .
exec nix run .#autoinstall
