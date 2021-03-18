#!/bin/sh

# Download and install xRay
mkdir /tmp/xray
curl -L -H "Cache-Control: no-cache" -o /tmp/xray/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip /tmp/xray/xray.zip -d /tmp/xray
install -m 755 /tmp/xray/xray /usr/local/bin/xray

# Remove temporary directory
rm -rf /tmp/xray

# XRay new configuration
install -d /usr/local/etc/xray
cat << EOF > /usr/local/etc/xray/config.json
{
    // 4_入站设置
    // 4.1 这里只写了一个最简单的vless+xtls的入站，因为这是Xray最强大的模式。如有其他需要，请根据模版自行添加。
    "inbounds": [
        {
            "port": 443,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "$UUID", // 填写你的 UUID
                        "flow": "xtls-rprx-direct",
                        "level": 0
                    }
                ],
                "decryption": "none",
            },
            "streamSettings": {
                "network": "tcp",
                "security": "xtls",
                "xtlsSettings": {
                    "allowInsecure": false,    // 正常使用应确保关闭
                    "minVersion": "1.2",       // TLS最低版本设置
                    "alpn": [
                        "http/1.1"
                    ],
                }
            }
        }
    ],
       
    // 5_出站设置
    "outbounds": [
        // 5.1 第一个出站是默认规则，freedom就是对外直连（vps已经是外网，所以直连）
        {
            "tag": "direct",
            "protocol": "freedom"
        },
        // 5.2 屏蔽规则，blackhole协议就是把流量导入到黑洞里（屏蔽）
    ]
}
EOF

# Run XRay
/usr/local/bin/xray -config /usr/local/etc/xray/config.json
