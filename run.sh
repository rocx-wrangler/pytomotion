#!/bin/bash
export SERIAL_PORT=/dev/serial/by-id/usb-Legrand_OpenWebNet_ZigBee_Gateway_16A075000074040-if00
cd $(dirname "$0")
exec python3 backend/app.py