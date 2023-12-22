#!/bin/bash

set -ex; \
# Check if PUBLIC_IP environment variable is set and non-empty; if so, use it, otherwise retrieve it via curl
if [ -n "$PUBLIC_IP" ]; then
  export host_ip=$PUBLIC_IP
else
  export host_ip=$(curl -s https://domains.google.com/checkip)
fi

echo "Check if PRIVATE_IP environment variable is set and non-empty; if so, use it"
if [ -n "$PRIVATE_IP" ]; then
  export private_ip=$PRIVATE_IP

echo "If PRIVATE_IP is not set, try to retrieve the private IP using curl with a timeout"
elif private_ip=$(curl --connect-timeout 10 --max-time 10 -s http://169.254.169.254/latest/meta-data/local-ipv4) && [ -n "$private_ip" ]; then
  export private_ip

echo "If the curl command fails or times out, use the first IP from hostname -I as a fallback"
else
  export private_ip=$(hostname -I | cut -d' ' -f1)
fi
export master_ip=$MASTER_NODE

echo "Config files for Janus are being generated..."

cat /opt/janus/etc/janus/janus.tmplt.jcfg | envsubst > /opt/janus/etc/janus/janus.jcfg
cat /opt/janus/etc/janus/janus.transport.rabbitmq.tmplt.jcfg | envsubst > /opt/janus/etc/janus/janus.transport.rabbitmq.jcfg



/opt/janus/bin/janus