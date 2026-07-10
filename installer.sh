#!/bin/bash
echo "======================================"
echo " Installing Legrand HomeAutomation Python Gateway "
echo "======================================"

# 1. Download and Extract Source
echo "[1/5] Downloading latest code..."
# NOTE: If repo is private, add: --header="Authorization: token YOUR_TOKEN"
wget --header="Authorization: token github_pat_11.." https://api.github.com/repos/rocx-wrangler/pytomotion/zipball/main -O pytomotion.z
ip
unzip -o pytomotion.zip
cd pytomotion-main

# 2. Create Required Directories
echo "[2/5] Creating directory structure..."
mkdir -p backend public data logs
chmod 755 backend data logs

# 3. Install Dependencies
echo "[3/5] Installing Python requirements..."
pip3 install -r requirements.txt
# Fallback if requirements.txt isn't available
pip3 install Flask==1.1.2 pyserial==3.5 APScheduler==3.6.0 python-dotenv==0.20.0

# 4. Environment Variables & Serial Port Mapping
echo "[4/5] Configuring Hardware Mapping..."

# Find the exact path of the connected Legrand USB stick dynamically
DYNAMIC_PORT=$(ls /dev/serial/by-id/usb-Legrand_OpenWebNet_ZigBee_Gateway* 2>/dev/null | head -n 1)
if [ -z "$DYNAMIC_PORT" ]; then
    DYNAMIC_PORT="/dev/ttyACM0"
    echo " -> Serial port not found, using default: $DYNAMIC_PORT"
else
    echo " -> Found serial port: $DYNAMIC_PORT"
fi

cat << EOF > .env
SERIAL_PORT=$DYNAMIC_PORT
BAUD_RATE=115200
EOF

# 5. Auto-Generate Legacy Mapping
echo "[5/5] Migrating Legacy Devices..."
python3 << 'PYTHON_EOF'
import json
import os

legacy_file = '/home/edomotics/currentVersion/device.json'
new_file = 'data/devices.json'

if os.path.exists(legacy_file):
    with open(legacy_file, 'r') as f:
        legacy_data = json.load(f)
    
    final_groups = {}
    group_idx = 1
    sw_idx = 1
    current_group = "Zone {0}".format(group_idx)
    final_groups[current_group] = {}
    
    for dev_id, dev_info in legacy_data.items():
        final_groups[current_group]["{0:02d}".format(sw_idx)] = {
            "device_id": dev_id,
            "name": "Switch {0}".format(dev_id[-4:])
        }
        sw_idx += 1
        if sw_idx > 3:
            sw_idx = 1
            group_idx += 1
            current_group = "Zone {0}".format(group_idx)
            final_groups[current_group] = {}
            
    if not final_groups[current_group]:
        del final_groups[current_group]

    with open(new_file, 'w') as f:
        json.dump({"groups": final_groups}, f, indent=4)
    print(" -> Successfully migrated legacy devices.json")
else:
    print(" -> Legacy deviceStore.json not found. Creating empty devices.json")
    with open(new_file, 'w') as f:
        json.dump({"groups": {}}, f, indent=4)
PYTHON_EOF

echo "======================================"
echo " Installation Complete! "
echo " Run: python3 backend/app.py to start."
echo "======================================"