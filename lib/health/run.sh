#!/bin/bash 

cp $scripts_dir/lib/health/health.service /etc/systemd/system/health.service
cp $scripts_dir/lib/health/health.timer /etc/systemd/system/health.timer
cp $scripts_dir/lib/health/health.sh /usr/local/bin/health.sh

systemctl daemon-reload

systemctl enable health.service
systemctl enable health.timer

systemctl start health.service
systemctl start health.timer

systemctl list-timers
