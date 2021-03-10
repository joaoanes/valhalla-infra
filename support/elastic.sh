#!/bin/bash
set -euxo pipefail

curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
apt update

apt install elasticsearch

mv /home/ubuntu/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
chown -Rf elasticsearch:elasticsearch /usr/share/elasticsearch
chown -Rf elasticsearch:elasticsearch /etc/elasticsearch

systemctl enable elasticsearch

apt install kibana

mv /home/ubuntu/kibana.yml /etc/kibana/kibana.yml
chown root:kibana /etc/kibana/kibana.yml

systemctl enable kibana

apt install logstash
mv /home/ubuntu/*.conf /etc/logstash/conf.d/
chown -Rf root:root /etc/logstash/conf.d/

sudo -u logstash /usr/share/logstash/bin/logstash --path.settings /etc/logstash -t

systemctl enable logstash

apt install filebeat

mv /home/ubuntu/filebeat.yml /etc/filebeat/filebeat.yml
sudo chown root:root /etc/filebeat/filebeat.yml

filebeat modules enable system
filebeat setup --template -E output.logstash.enabled=false -E 'output.elasticsearch.hosts=["localhost:9200"]'
# shellcheck disable=SC2154
# shellcheck disable=SC2086
{
    filebeat setup -e -E output.logstash.enabled=false -E output.elasticsearch.hosts=['localhost:9200'] -E setup.kibana.host=${instance_address}:5601
}

systemctl enable filebeat

systemctl start elasticsearch
systemctl start logstash
systemctl start kibana
systemctl start filebeat
