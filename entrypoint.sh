#!/bin/sh

# Global variables
DIR_CONFIG="/etc/v2ray"
DIR_RUNTIME="/usr/bin"
DIR_TMP="$(mktemp -d)"

# Write V2Ray configuration
cat << EOF > ${DIR_TMP}/heroku.json
{
    "inbounds": [{
        "port": ${PORT},
        "protocol": "vmess",
        "settings": {
            "clients": [{
                "id": "${ID}"
            }]
        },
        "streamSettings": {
            "network": "ws",
            "wsSettings": {
                "path": "${WSPATH}"
            }
        }
    }],
    "outbounds": [{
        "protocol": "freedom"
    }]
}
EOF

# Get V2Ray executable release
echo "Downloading V2Ray..."
curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip -o ${DIR_TMP}/v2ray_dist.zip

# Check if the download was successful
if [ ! -f "${DIR_TMP}/v2ray_dist.zip" ]; then
  echo "Failed to download V2Ray."
  exit 1
fi

# Unzip V2Ray
echo "Unzipping V2Ray..."
busybox unzip ${DIR_TMP}/v2ray_dist.zip -d ${DIR_TMP}

# Check if unzip was successful
if [ ! -f "${DIR_TMP}/v2ray" ] || [ ! -f "${DIR_TMP}/v2ctl" ]; then
  echo "Failed to unzip V2Ray."
  exit 1
fi

# Convert to protobuf format configuration
mkdir -p ${DIR_CONFIG}
${DIR_TMP}/v2ctl config ${DIR_TMP}/heroku.json > ${DIR_CONFIG}/config.pb

# Install V2Ray
echo "Installing V2Ray..."
install -m 755 ${DIR_TMP}/v2ray ${DIR_RUNTIME}
install -m 755 ${DIR_TMP}/v2ctl ${DIR_RUNTIME}
rm -rf ${DIR_TMP}

# Run V2Ray
echo "Starting V2Ray..."
${DIR_RUNTIME}/v2ray -config=${DIR_CONFIG}/config.pb