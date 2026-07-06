"""Test device management functions"""
import os
import json
import sys
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

import app


def test_load_devices_empty(tmp_path):
    """Test loading devices when file doesn't exist"""
    original_devices_file = app.DEVICES_FILE
    app.DEVICES_FILE = str(tmp_path / "test_devices.json")
    
    try:
        devices = app.load_devices()
        assert isinstance(devices, dict)
        assert "groups" in devices
    finally:
        app.DEVICES_FILE = original_devices_file


def test_load_devices_valid(tmp_path):
    """Test loading valid devices structure"""
    original_devices_file = app.DEVICES_FILE
    app.DEVICES_FILE = str(tmp_path / "test_devices.json")
    
    try:
        devices = app.load_devices()
        assert isinstance(devices.get("groups", {}), dict)
    finally:
        app.DEVICES_FILE = original_devices_file


def test_get_known_switches(tmp_path):
    """Test retrieving known switch list"""
    original_devices_file = app.DEVICES_FILE
    app.DEVICES_FILE = str(tmp_path / "test_devices.json")
    
    try:
        switches = app.get_known_switches()
        assert isinstance(switches, list)
    finally:
        app.DEVICES_FILE = original_devices_file
