"""Test schedule management functions"""
import os
import sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(__file__)), 'backend'))

import app


def test_load_schedules_empty(tmp_path):
    """Test loading schedules when file doesn't exist"""
    original_schedules_file = app.SCHEDULES_FILE
    app.SCHEDULES_FILE = str(tmp_path / "test_schedules.json")
    
    try:
        schedules = app.load_schedules()
        assert isinstance(schedules, list)
        assert schedules == []
    finally:
        app.SCHEDULES_FILE = original_schedules_file


def test_save_and_load_schedules(tmp_path):
    """Test saving and loading schedules"""
    original_schedules_file = app.SCHEDULES_FILE
    app.SCHEDULES_FILE = str(tmp_path / "test_schedules.json")
    
    try:
        test_schedules = [
            {"id": "sch1", "device_id": "dev1", "action": "ON", "active": True}
        ]
        app.save_schedules(test_schedules)
        loaded = app.load_schedules()
        assert len(loaded) == 1
        assert loaded[0]["id"] == "sch1"
    finally:
        app.SCHEDULES_FILE = original_schedules_file


def test_save_empty_schedules(tmp_path):
    """Test saving empty schedules"""
    original_schedules_file = app.SCHEDULES_FILE
    app.SCHEDULES_FILE = str(tmp_path / "test_schedules.json")
    
    try:
        app.save_schedules([])
        loaded = app.load_schedules()
        assert loaded == []
    finally:
        app.SCHEDULES_FILE = original_schedules_file
