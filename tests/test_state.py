"""Test state management functions"""
import os
import json
import tempfile
import sys
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

import app


def test_load_state_empty(tmp_path):
    """Test loading state when file doesn't exist"""
    # Temporarily override STATE_FILE
    original_state_file = app.STATE_FILE
    app.STATE_FILE = str(tmp_path / "test_state.json")
    
    try:
        state = app.load_state()
        assert isinstance(state, dict)
        assert state == {}
    finally:
        app.STATE_FILE = original_state_file


def test_save_and_load_state(tmp_path):
    """Test saving and loading state"""
    original_state_file = app.STATE_FILE
    app.STATE_FILE = str(tmp_path / "test_state.json")
    
    try:
        test_state = {"device1": {"what": "1"}, "device2": {"what": "0"}}
        app.save_state(test_state)
        loaded = app.load_state()
        assert loaded == test_state
    finally:
        app.STATE_FILE = original_state_file


def test_update_device_state(tmp_path):
    """Test device state updates"""
    original_state_file = app.STATE_FILE
    app.STATE_FILE = str(tmp_path / "test_state.json")
    
    try:
        app.update_device_state("TEST_DEVICE", "ON")
        state = app.load_state()
        assert "TEST_DEVICE" in state
        assert state["TEST_DEVICE"]["what"] == "1"
    finally:
        app.STATE_FILE = original_state_file


def test_state_persistence(tmp_path):
    """Test state persists across calls"""
    original_state_file = app.STATE_FILE
    app.STATE_FILE = str(tmp_path / "test_state.json")
    
    try:
        state1 = {"device1": {"what": "1"}}
        app.save_state(state1)
        state2 = {"device2": {"what": "0"}}
        state2.update(app.load_state())
        app.save_state(state2)
        final = app.load_state()
        assert "device1" in final
        assert "device2" in final
    finally:
        app.STATE_FILE = original_state_file
