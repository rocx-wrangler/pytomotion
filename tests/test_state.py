"""Test state management functions"""
import os
import sys
import json
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(__file__)), 'backend'))

import app


def test_init_state_empty(tmp_path):
    """Test loading state when file doesn't exist"""
    original_state_file = app.STATE_FILE
    app.STATE_FILE = str(tmp_path / "test_state.json")
    
    # Save original in-memory state and clear it
    original_in_memory = app.in_memory_state.copy()
    app.in_memory_state = {"dummy": "data"}
    
    try:
        app.init_state()
        # Should initialize to empty dict
        assert app.in_memory_state == {}
        # Should flush the empty dict to disk
        assert os.path.exists(app.STATE_FILE)
        with open(app.STATE_FILE, "r") as f:
            data = json.load(f)
            assert data == {}
    finally:
        app.STATE_FILE = original_state_file
        app.in_memory_state = original_in_memory


def test_init_state_existing(tmp_path):
    """Test loading state from an existing state file"""
    original_state_file = app.STATE_FILE
    app.STATE_FILE = str(tmp_path / "test_state.json")
    
    # Write existing state to file
    test_state = {"device1": {"what": "1"}, "device2": {"what": "0"}}
    with open(app.STATE_FILE, "w") as f:
        json.dump(test_state, f)
        
    original_in_memory = app.in_memory_state.copy()
    app.in_memory_state = {}
    
    try:
        app.init_state()
        # Should load the state from file
        assert app.in_memory_state == test_state
    finally:
        app.STATE_FILE = original_state_file
        app.in_memory_state = original_in_memory


def test_update_device_state(tmp_path):
    """Test device state updates modify only the RAM cache (not disk)"""
    original_state_file = app.STATE_FILE
    app.STATE_FILE = str(tmp_path / "test_state.json")
    
    original_in_memory = app.in_memory_state.copy()
    app.in_memory_state = {}
    
    try:
        app.update_device_state("TEST_DEVICE", "ON")
        # Should update RAM cache
        assert "TEST_DEVICE" in app.in_memory_state
        assert app.in_memory_state["TEST_DEVICE"]["what"] == "1"
        # Should NOT automatically save to disk (so file doesn't exist)
        assert not os.path.exists(app.STATE_FILE)
    finally:
        app.STATE_FILE = original_state_file
        app.in_memory_state = original_in_memory


def test_flush_state_to_disk(tmp_path):
    """Test flushing the in-memory state to disk manually"""
    original_state_file = app.STATE_FILE
    app.STATE_FILE = str(tmp_path / "test_state.json")
    
    original_in_memory = app.in_memory_state.copy()
    test_state = {"device_a": {"what": "1"}, "device_b": {"what": "0"}}
    app.in_memory_state = test_state.copy()
    
    try:
        app.flush_state_to_disk()
        # Check that file exists and contains correct state
        assert os.path.exists(app.STATE_FILE)
        with open(app.STATE_FILE, "r") as f:
            data = json.load(f)
            assert data == test_state
    finally:
        app.STATE_FILE = original_state_file
        app.in_memory_state = original_in_memory
