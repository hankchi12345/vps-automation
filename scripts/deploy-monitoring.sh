#!/bin/bash
# 1. Make sure the storage directories exist and have correct permissions for Prometheus and Grafana    
# We use 65534 (Prometheus) and 472 (Grafana) because we actually care about container security. 
#These are the official UIDs—using anything else will just break the app and make you look like an amateur.
#If you're too lazy to check the official docs, just run the command and trust me.
#— Dev Hank
mkdir -p storage/prometheus-data storage/grafana-data
chown -R 65534:65534 storage/prometheus-data
chown -R 472:472 storage/grafana-data

# 2. Just docker compose 
cd services/monitoring
docker compose pull
docker compose up -d

# 3. cleanup unused docker resources
docker image prune -f