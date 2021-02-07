# -*- mode: bash -*-

set -e

BOOT_END=128MiB

fatal() {
  printf "\033[1m\033[31m"
  echo "$@"
  printf "\033[0m"
  exit 255
}

wait() {
  for _ in $(seq 1 10000); do
    if [ -e "$1" ]; then
      return
    fi
    sleep 0.01
  done
  fatal "File $1 didn't appear"
}

mbr() {
  mbr_device="$1"
  parted -s "$mbr_device" -- mklabel msdos
}

gpt() {
  gpt_device="$1"
  parted -s "$gpt_device" -- mklabel gpt
}

part_mbr_boot() {
  pmb_device="$1"
  parted -s "$pmb_device" -- mkpart primary 1MiB "$BOOT_END"
}

part_gpt_boot() {
  pgb_device="$1"
  parted -s "$pgb_device" -- mkpart ESP 1MiB "$BOOT_END"
  # Expects this partition to be created first
  parted -s "$pgb_device" -- set 1 esp on
}

part_data() {
  pd_device="$1"
  pd_start="${2:-${BOOT_END}}"
  pd_end="${3:--0}"
  parted -s "$pd_device" -- mkpart primary "$pd_start" "$pd_end"
}

mbr_boot() {
  mb_device="$1"
  mb_name="$2"
  mkfs.ext4 -F -L "$mb_name" "$mb_device"
}

uefi_boot() {
  ub_device="$1"
  ub_name="$2"
  mkfs.vfat -F32 -n "$ub_name" "$ub_device"
}

btrfs() {
  b_device="$1"
  b_label="$2"
  mkfs.btrfs -f -L "$b_label" "$b_device"
}

encrypted_btrfs() {
  eb_device="$1"
  eb_name="$2"
  eb_label="$3"

  cryptsetup luksFormat --batch-mode --verify-passphrase --type=luks2 --label="$eb_name"-raw "$eb_device"
  cryptsetup luksOpen "$eb_device" "$eb_name"
  btrfs /dev/mapper/"$eb_name" "$eb_label"
}

refresh_partitions() {
  rp_device="$1"
  partprobe "$rp_device"
  sleep 1
}

mount_root() {
  mr_label="$1"
  mr_f=/dev/disk/by-label/"$mr_label"
  wait "$mr_f"
  mount "$mr_f" /mnt
}

mount_boot() {
  mb_label="$1"
  mb_f=/dev/disk/by-label/"$mb_label"
  wait "$mb_f"

  mkdir /mnt/boot
  mount "$mb_f" /mnt/boot
}

parts() {
  case "$1" in
    /dev/nvme*)
      echo "$1"p;;
    *)
      echo "$1";;
  esac
}

mbr_plain() {
  mbrp_device="$1"
  mbrp_name="$2"

  mbrp_p=$(parts "$mbrp_device")

  mbr "$mbrp_device"
  part_data "$mbrp_device" 1MiB

  btrfs "$mbrp_p"1 "$mbrp_name"-root

  refresh_partitions "$mbrp_device"
  mount_root "$mbrp_name"-root
}

mbr_encrypted() {
  mbre_device="$1"
  mbre_name="$2"

  mbre_p=$(parts "$mbre_device")

  mbr "$mbre_device"
  part_mbr_boot "$mbre_device"
  part_data "$mbre_device"

  mbr_boot "$mbre_p"1 "$mbre_name"-boot
  encrypted_btrfs "$mbre_p"2 "$mbre_name"-data "$mbre_name"-root

  refresh_partitions "$mbre_device"

  mount_root "$mbre_name"-root
  mount_boot "$mbre_name"-boot
}

gpt_encrypted() {
  ge_device="$1"
  ge_name="$2"

  ge_p=$(parts "$ge_device")

  gpt "$ge_device"
  part_gpt_boot "$ge_device"
  part_data "$ge_device"

  uefi_boot "$ge_p"1 "$ge_name"-boot
  encrypted_btrfs "$ge_p"2 "$ge_name"-data "$ge_name"-root

  refresh_partitions "$ge_device"
  mount_root "$ge_name"-root
  mount_boot "$ge_name"-boot
}

confirm_repartition() {
  if [ -z "$(lsblk -n -o pttype "$1")" ]; then
    return
  fi

  lsblk -f "$1"
  printf "Partition table detected, overwrite (enter YES to continue)? "
  read -r cr_confirm
  if [ "$cr_confirm" != YES ]; then
    exit 0
  fi
}

partition() {
  p_layout="$1"
  p_device="$2"
  p_name="$3"

  confirm_repartition "$p_device"
  "$p_layout" "$p_device" "$p_name"
}

coinstall_p1() {
  cp1_device=/dev/nvme0n1
  cp1_name=p1

  confirm_repartition "$cp1_device"

  cp1_win_end=$(parted -s "$cp1_device" "unit B print" | awk '/^ 3/ { sub(/B/, "", $3); print $3 }')
  cp1_recovery_begin=$(parted -s "$cp1_device" "unit B print" | awk '/^ 4/ { sub(/B/, "", $2); print $2 }')

  part_data "$cp1_device" $((cp1_win_end+1))B $((cp1_recovery_begin-1))B

  encrypted_btrfs "${cp1_device}p5" "$cp1_name"-data "$cp1_name"-root

  refresh_partitions "$cp1_device"
  mount_root "$cp1_name"-root
  mount_boot SYSTEM
}

DF=/mnt/home/dottedmag/.deploy

copy_dotfiles() {
  mkdir -p "$(dirname $DF)"
  cp -a /tmp/dotfiles $DF
}

TARGET=

if dmidecode | grep -q "Product Name: Parallels Virtual Platform"; then
  printf "Parallels VM. Hostname: "
  read -r hostname

  partition mbr_plain /dev/sda "$hostname"

  copy_dotfiles

  printf '{networking.hostName = "%s";fileSystems."/"={device="/dev/disk/by-label/%s-root";fsType="btrfs";};}' "$hostname" "$hostname" > $DF/overlay.nix
  cd $DF
  git add overlay.nix
  git config user.email "root@$hostname"
  git config user.name "Autoinstaller"
  git commit -m "Add Parallels configuration"
  chown -R 1000:100 $DF

  TARGET=parallels
elif dmidecode | grep -q "Product Name: MacBookAir5,1"; then
  printf "MacBook Air 11\n"

  partition gpt_encrypted /dev/sda air11

  copy_dotfiles

  TARGET=air11
elif dmidecode | grep -q "Product Name: Librem 13 v2"; then
  printf "Librem\n"

  partition mbr_encrypted /dev/sda librem

  copy_dotfiles

  TARGET=librem
elif dmidecode | grep -q "Product Name: X62"; then
  printf "Thinkpad X62\n"

  partition gpt_encrypted /dev/nvme0n1 x62

  copy_dotfiles

  TARGET=x62
elif dmidecode | grep -q "Product Name: 20QTCTO1WW"; then
  printf "Thinkpad P1\n"

  coinstall_p1

  copy_dotfiles

  TARGET=p1
elif dmidecode | grep -q "Product Name: Aspire V5-121"; then
  printf "Aspire V5\n"

  partition gpt_encrypted /dev/sda v5

  copy_dotfiles

  TARGET=v5
else
  fatal "Unable to detect hardware"
fi

nixos-install --verbose --flake $DF#$TARGET --no-root-passwd

reboot
