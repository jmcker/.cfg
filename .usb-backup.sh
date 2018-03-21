sudo mkdir /media/usb-backup
sudo mount -t vfat -o uid=pi,gid=pi /dev/sda1 /media/usb-backup/
rsync -ravP --delete --ignore-existing --exclude .config/chromium --exclude .cache ~/ /media/usb-backup/$HOSTNAME-backup/
sudo umount /media/usb-backup
