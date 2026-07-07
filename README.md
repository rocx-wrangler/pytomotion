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

### Systemd Service Setup

1. Create service file:
```bash
sudo vi /etc/systemd/system/switches.service
```

2. Add configuration:
```ini
[Unit]
Description=Edomotics Switch Gateway
After=systemd-udevd.service

[Service]
Type=simple
WorkingDirectory=/home/pytomotion
Environment=SERIAL_PORT=/dev/serial/by-id/usb-Legrand_OpenWebNet_ZigBee_Gateway_16A075000074040-if00
ExecStart=/usr/bin/python3 /home/pytomotion/app.py
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

4. Check status:
```bash
sudo systemctl status switches.service
```

5. View logs:
```bash
sudo journalctl -u switches.service -f
```

## Logging

Logs written to `logs/` directory with 10-day rotation.
