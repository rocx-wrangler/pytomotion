cat > /home/pytomotion/run.sh << 'EOF'
#!/bin/bash
export SERIAL_PORT=/dev/serial/by-id/usb-Legrand_OpenWebNet_ZigBee_Gateway_16A075000074040-if00
exec python3 /home/pytomotion/app.py
EOF
chmod +x /home/pytomotion/run.sh