#!/bin/bash
echo "======================================"
echo " Installing Edomotics Python Gateway "
echo "======================================"

# 1. Download and Extract Source
echo "[1/4] Downloading latest code..."
# NOTE: If repo is private, add: --header="Authorization: token YOUR_TOKEN"
wget https://github.com/rocx-wrangler/pytomotion/archive/refs/heads/main.zip -O pytomotion.zip
unzip -o pytomotion.zip
cd pytomotion-main

# 2. Install Dependencies
echo "[2/4] Installing Python requirements..."
pip3 install -e .
# Fallback if setup.py isn't used
pip3 install Flask==1.1.2 pyserial==3.5 APScheduler==3.6.0 python-dotenv==0.20.0

# 3. Environment Variables & Serial Port Mapping
# 3. Environment Variables & Serial Port Mapping
echo "[3/4] Configuring Hardware Mapping..."

# Find the exact path of the connected Legrand USB stick dynamically
DYNAMIC_PORT=$(ls /dev/serial/by-id/usb-Legrand_OpenWebNet_ZigBee_Gateway* | head -n 1)
cat << EOF > .env
SERIAL_PORT=$DYNAMIC_PORT
BAUD_RATE=115200
EOF

# 4. Auto-Generate Legacy Mapping
echo "[4/4] Migrating Legacy Devices..."
python3 << 'EOF'
import json
import os

legacy_file = '/home/edomotics/currentVersion/deviceStore.json'
new_file = 'devices.json'

if os.path.exists(legacy_file):
    with open(legacy_file, 'r') as f:
        legacy_data = json.load(f)
    
    final_groups = {}
    group_idx = 1
    sw_idx = 1
    current_group = f"Zone {group_idx}"
    final_groups[current_group] = {}
    
    for dev_id, dev_info in legacy_data.items():
        # Strip ID to last 4 digits for placeholder name
        final_groups[current_group][f"{sw_idx:02d}"] = {
            "device_id": dev_id,
            "name": f"Switch {dev_id[-4:]}"
        }
        sw_idx += 1
        if sw_idx > 3:
            sw_idx = 1
            group_idx += 1
            current_group = f"Zone {group_idx}"
            final_groups[current_group] = {}
            
    # Cleanup empty trailing group
    if not final_groups[current_group]:
        del final_groups[current_group]

    with open(new_file, 'w') as f:
        json.dump({"groups": final_groups}, f, indent=4)
    print(" -> Successfully migrated legacy devices.json")
else:
    print(" -> Legacy deviceStore.json not found. Creating empty devices.json")
    with open(new_file, 'w') as f:
        json.dump({"groups": {}}, f, indent=4)
EOF

echo "======================================"
echo " Installation Complete! "
echo " Run: python3 app.py to start."
echo "======================================"