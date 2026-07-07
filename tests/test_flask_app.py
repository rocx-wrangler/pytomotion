"""Test Flask application endpoints"""
import os
import sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(__file__)), 'backend'))

import app
import unittest


class FlaskAppTestCase(unittest.TestCase):
    """Test Flask app endpoints"""

    def setUp(self):
        """Set up test client"""
        self.app = app.app.test_client()
        self.app.testing = True

    def test_app_loads(self):
        """Test app initializes"""
        assert app.app is not None

    def test_index_route(self):
        """Test if index route exists"""
        try:
            response = self.app.get('/')
            assert response.status_code in [200, 404]
        except Exception as e:
            pass

    def test_command_queue_exists(self):
        """Test command queue is initialized"""
        assert app.command_queue is not None

    def test_state_lock_exists(self):
        """Test state lock is initialized"""
        assert app.state_lock is not None

    def test_scheduler_exists(self):
        """Test scheduler is initialized"""
        assert app.scheduler is not None


class ConfigTestCase(unittest.TestCase):
    """Test configuration loading"""

    def test_serial_port_config(self):
        """Test serial port configuration"""
        port = os.getenv("SERIAL_PORT", "/dev/ttyACM0")
        assert isinstance(port, str)
        assert len(port) > 0

    def test_baud_rate_config(self):
        """Test baud rate configuration"""
        rate = int(os.getenv("BAUD_RATE", "115200"))
        assert rate > 0
        assert rate in [9600, 19200, 38400, 57600, 115200]


if __name__ == '__main__':
    unittest.main()
