# Run test suite on Windows
python -m pytest tests/ -v --cov=. --cov-report=html
Write-Host "Coverage report generated in htmlcov\index.html"
