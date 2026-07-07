# Project Structure

## New Organization (Secure)

```
pytomotion/
├── backend/
│   └── app.py                  # Main Flask application (NOT accessible via HTTP)
│
├── public/
│   └── index.html              # Web UI (only this is served to browsers)
│
├── data/                        # Configuration and state files
│   ├── state.json              # Current device states
│   ├── devices.json            # Device configuration
│   └── schedules.json          # Scheduled tasks
│
├── logs/                        # Application logs (auto-created)
│   └── edomo_gateway.log       # Main log file with 10-day rotation
│
├── tests/                       # Unit tests
│   ├── test_state.py
│   ├── test_devices.py
│   ├── test_schedules.py
│   ├── test_flask_app.py
│   └── __init__.py
│
├── .github/
│   └── workflows/
│       └── python-app.yml      # GitHub Actions CI/CD
│
├── README.md                    # Quick start guide
├── DEPLOYMENT.md                # OrangePi deployment guide
├── CHANGELOG.md                 # Version history
├── CONTRIBUTING.md              # Contribution guidelines
├── LICENSE                      # MIT License
├── VERSION                      # Current version (1.0.0)
│
├── requirements.txt             # Production dependencies
├── requirements-dev.txt         # Development/test dependencies
├── setup.py                     # Package setup
├── pyproject.toml               # Build configuration
│
├── switches.service             # Systemd service file (OrangePi)
├── run.sh                       # Linux startup script
├── run.bat                      # Windows startup script
├── run_tests.sh                 # Linux test runner
├── run_tests.ps1                # Windows test runner
│
├── .env.example                 # Environment variables template
├── .gitignore                   # Git ignore rules
├── .gitattributes               # Line ending normalization
│
├── sftp.json                    # SFTP configuration (legacy)
└── devices.json                 # (DEPRECATED - moved to data/)
```

## Why This Structure?

### Security
- ✅ `app.py` is in `backend/` directory
- ✅ Only `public/` directory is served to web browsers
- ✅ **Users cannot access source code** by modifying URLs
- ✅ API endpoints remain accessible at `/api/*`

### Organization
- ✅ Separates backend logic from frontend assets
- ✅ Configuration and state files in dedicated `data/` directory
- ✅ Logs in dedicated `logs/` directory (daily rotation, 10-day retention)
- ✅ Clean separation of concerns

### Migration from Old Structure

If updating from the old structure:

1. **Old location** → **New location**
   - `app.py` → `backend/app.py`
   - `index.html` → `public/index.html`
   - `state.json` → `data/state.json`
   - `devices.json` → `data/devices.json`
   - `schedules.json` → `data/schedules.json`
   - `edomo_gateway.log*` → `logs/edomo_gateway.log*`

2. **File paths are handled automatically** by `backend/app.py`:
   - Calculates `BASE_DIR` based on backend location
   - Creates required directories if missing
   - Manages all file operations with new paths

3. **Update systemd service**:
   ```bash
   sudo systemctl stop switches.service
   sudo cp switches.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl start switches.service
   ```

4. **Verify new structure**:
   ```bash
   cd /home/pytomotion
   ls -la backend/
   ls -la public/
   ls -la data/
   ls -la logs/
   ```
