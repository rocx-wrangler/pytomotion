# Deployment Guide

## OrangePi Setup

### Prerequisites
- OrangePi with Armbian OS
- USB ZigBee Gateway: `usb-Legrand_OpenWebNet_ZigBee_Gateway_16A075000074040-if00`
- Port 3767 open for API access

### Installation Steps

1. **Clone repository to OrangePi:**
```bash
cd /home
git clone https://github.com/rocx-wrangler/pytomotion.git
cd pytomotion
```

2. **Install dependencies:**
```bash
pip3 install -r requirements.txt
```

3. **Systemd Service Installation:**

Copy service file:
```bash
sudo cp switches.service /etc/systemd/system/
```

Or create manually:
```bash
sudo vi /etc/systemd/system/switches.service
```

**Service Configuration:**
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

4. **Enable and Start Service:**
```bash
sudo systemctl daemon-reload
sudo systemctl enable switches.service
sudo systemctl start switches.service
```

### Service Management

**Check status:**
```bash
sudo systemctl status switches.service
```

**View real-time logs:**
```bash
sudo journalctl -u switches.service -f
```

**View last 50 lines:**
```bash
sudo journalctl -u switches.service -n 50
```

**Restart service:**
```bash
sudo systemctl restart switches.service
```

**Stop service:**
```bash
sudo systemctl stop switches.service
```

**Disable service (prevent auto-start):**
```bash
sudo systemctl disable switches.service
```
### Auto-Updater Installation

To keep the Orange Pi devices up to date automatically, a weekly auto-updater can be configured using a systemd timer.

1. **Deploy Key Setup**:
   - Generate an SSH key pair (without a passphrase):
     ```bash
     ssh-keygen -t ed25519 -f /home/pytomotion/.ssh/deploy_key -N ""
     ```
   - Change ownership of the `.ssh` folder and key files to the user running the app:
     ```bash
     chmod 700 /home/pytomotion/.ssh
     chmod 600 /home/pytomotion/.ssh/deploy_key
     ```
   - Copy the public key content:
     ```bash
     cat /home/pytomotion/.ssh/deploy_key.pub
     ```
   - Go to your private GitHub repository **Settings > Deploy Keys**, click **Add deploy key**, paste the public key, and name it (e.g., `Orange Pi Shared Deploy Key`). Ensure it has read-only access.
   - Configure Git to use the SSH remote instead of HTTPS:
     ```bash
     git remote set-url origin git@github.com:rocx-wrangler/pytomotion.git
     ```

2. **Install Service & Timer**:
   - Copy the service and timer files to the systemd directory:
     ```bash
     sudo cp pytomotion-updater.service /etc/systemd/system/
     sudo cp pytomotion-updater.timer /etc/systemd/system/
     ```
   - Make the updater script executable:
     ```bash
     chmod +x /home/pytomotion/updater.sh
     ```
   - Reload systemd and enable the timer:
     ```bash
     sudo systemctl daemon-reload
     sudo systemctl enable pytomotion-updater.timer
     sudo systemctl start pytomotion-updater.timer
     ```

3. **Check Updater Status & Logs**:
   - Check timer schedule and next runs:
     ```bash
     systemctl list-timers --all | grep pytomotion
     ```
   - View updater execution logs:
     ```bash
     tail -f /home/pytomotion/logs/updater.log
     ```
   - Or view systemd journal log:
     ```bash
     sudo journalctl -u pytomotion-updater.service
     ```

### Troubleshooting

**Service fails to start:**
- Check serial port is connected: `ls /dev/serial/by-id/`
- Verify permissions: `sudo systemctl status switches.service`
- Check logs: `sudo journalctl -u switches.service -n 100`

**Check serial port:**
```bash
dmesg | grep ttyACM
ls -la /dev/serial/by-id/
```

**Restart systemd:**
```bash
sudo systemctl daemon-reload
```

### Project Structure

```
pytomotion/
├── backend/
│   └── app.py              # Main application (protected from web access)
├── public/
│   └── index.html          # Web UI (only static files served)
├── data/
│   ├── state.json          # Device states
│   ├── devices.json        # Device configuration
│   └── schedules.json      # Scheduled tasks
├── logs/
│   └── edomo_gateway.log   # Application logs (10-day rotation)
├── tests/                  # Unit tests
└── requirements.txt        # Dependencies
```

### API Access

Gateway available at:
- **Local**: `http://localhost:3767`
- **Network**: `http://orangepi-ip:3767`

### Log Files

Located in: `/home/pytomotion/logs/`
- Main log: `edomo_gateway.log`
- 10-day rotation retention
- Daily backup files: `edomo_gateway.log.YYYY-MM-DD`
