#!/bin/bash
export SERIAL_PORT=/dev/serial/by-id/usb-Legrand_OpenWebNet_ZigBee_Gateway_16A075000074040-if00
cd $(dirname "$0")
export FLASK_APP=backend/app.py
python -m flask run --host=[IP_ADDRESS]