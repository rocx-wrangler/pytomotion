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
├── pytomotion-updater.service   # Systemd service wrapper for auto-updater
├── pytomotion-updater.timer     # Systemd timer file for weekly updates (Sun 2AM)
├── updater.sh                   # Git-based weekly auto-updater script
├── run.sh                       # Linux startup script
├── run.bat                      # Windows startup script
├── run_tests.sh                 # Linux test runner
├── run_tests.ps1                # Windows test runner
│
├── .env.example                 # Environment variables template
├── .gitignore                   # Git ignore rules
├── .gitattributes               # Line ending normalization
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

### Auto-Updater System
- 🔄 **`updater.sh`**: Fetches changes, validates python file syntax, resets to the remote head, cleans untracked files (preserving customer config in `data/`), and restarts/verifies the service.
- ⏰ **`pytomotion-updater.timer`**: Schedules the update checks weekly on Sundays at 2:00 AM. It includes staggered delays to spread api traffic, and boot persistence so checks are run immediately upon boot if a scheduled run was missed.
