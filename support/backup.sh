#!/bin/bash

sudo rm /home/ubuntu/valheim.tar.gz
sudo tar -czvf /home/ubuntu/valheim.tar.gz /home/steam/.config/
# shellcheck disable=SC2154
# shellcheck disable=SC2086

curl -i -X PUT -T /home/ubuntu/valheim.tar.gz https://s3.${aws_region}.amazonaws.com/${route53_subdomain}-backups-next/
