#!/bin/bash 

cp $scripts_dir/lib/health/health.service /etc/systemd/system/health.service
cp $scripts_dir/lib/health/health.timer /etc/systemd/system/health.timer
cp $scripts_dir/lib/health/health.sh /usr/local/bin/health.sh

systemctl daemon-reload

systemctl enable backup.service
systemctl enable backup.timer

systemctl start backup.service
systemctl start backup.timer

systemctl list-timers
