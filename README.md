# PyToMotion Gateway

Flask-based IoT gateway for serial device management with scheduling.

**Deployment**: OrangePi | **Port**: 3767

## Requirements

- Python 3.5+
- OrangePi board with USB serial device
- See `requirements.txt`

## Quick Start

```bash
git clone https://github.com/rocx-wrangler/pytomotion.git
cd pytomotion
pip install -r requirements.txt
export SERIAL_PORT=/dev/ttyACM0
python backend/app.py
```

## Configuration

- `SERIAL_PORT`: Serial port device (default: `/dev/ttyACM0`)
- `BAUD_RATE`: Baud rate (default: `115200`)
- **Port 3767** opens on OrangePi device for API access

## Deployment on OrangePi

For detailed deployment guides and auto-updater settings, see [DEPLOYMENT.md](DEPLOYMENT.md).

### Quick Systemd Service Setup

1. Copy or create the service file:
```bash
sudo cp switches.service /etc/systemd/system/
```

2. Standard service configuration:
```ini
[Unit]
Description=Edomotics Switch Gateway
After=systemd-udevd.service

[Service]
Type=simple
WorkingDirectory=/home/pytomotion
Environment=SERIAL_PORT=/dev/serial/by-id/usb-Legrand_OpenWebNet_ZigBee_Gateway_16A075000074040-if00
ExecStart=/usr/bin/python3 /home/pytomotion/backend/app.py
Restart=always
RestartSec=30
User=root

[Install]
WantedBy=multi-user.target
```

3. Enable and start service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable switches.service
sudo systemctl start switches.service
```

### Auto-Updates
The gateway includes a weekly git-based auto-updater setup using a systemd timer (configured in `pytomotion-updater.timer`). See [DEPLOYMENT.md](DEPLOYMENT.md) for full instructions on configuring SSH Deploy Keys and installing the auto-updater.

## Logging

Logs are written to the `logs/` directory with 10-day rotation and daily roll.

