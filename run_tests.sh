#!/bin/bash
# Run test suite
python -m pytest tests/ -v --cov=. --cov-report=html
