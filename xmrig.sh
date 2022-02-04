#! /bin/bash
echo ----Xmrig installation script by Toomas633----
echo ----------------------------------------------
echo
echo Wallet address:
read wallet_address

echo Pool address:
read pool_address

echo Miner name:
read pass

echo ----Starting installation----

echo ----Installing packets----

sudo apt install -y git build-essential cmake libuv1-dev libssl-dev libhwloc-dev

echo ----Creating user miner----

sudo adduser miner --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
echo "miner:miner" | sudo chpasswd

echo ----Cloning xmrig ----

cd /home/miner
sudo git clone https://github.com/xmrig/xmrig.git
sudo mkdir xmrig/build && cd xmrig/build

echo ----Starting installation----

sudo cmake ..
sudo make 

echo ----Creating config file----

sudo cat > config.json << EOF
{
    "autosave": true,
    "cpu": {
        "enabled": true,
        "priority": 0,
        "max-threads-hint": 100,
    },
    "opencl": false,
    "cuda": false,
    "pools": [
        {
            "coin": "monero",
            "algo": "rx/0",
            "url": "$pool_address",
            "user": "$wallet_address",
            "pass": "$pass",
            "tls": false,
            "keepalive": false,
            "nicehash": false
        }
    ]
}
EOF
fi

echo ----Enabling autostart service---- 

sudo cat > /etc/systemd/system/xmrig.service << EOF 
[Unit]
Description=XMRig Daemon
After=network.target

[Service]
Type=forking
GuessMainPID=no
ExecStart=/home/miner/xmrig/build/xmrig -c /home/miner/xmrig/build/config.json -l /home/miner/xmrig.log -B
Restart=always
User=miner

[Install]
WantedBy=multi-user.target
EOF
fi

sudo systemctl enable xmrig.service

echo ----Starting xmrig service----

sudo service xmrig start

echo ----Done----
