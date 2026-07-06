#!/usr/bin/env python
from setuptools import setup
import os

version_file = os.path.join(os.path.dirname(__file__), 'VERSION')
with open(version_file, 'r') as f:
    version = f.read().strip()

setup(
    name='pytomotion-gateway',
    version=version,
    description='IoT Gateway for serial device management',
    author='rocx-wrangler',
    url='https://github.com/rocx-wrangler/pytomotion',
    license='MIT',
    install_requires=[
        'Flask==1.1.2',
        'pyserial==3.5',
        'APScheduler==3.6.0',
        'python-dotenv==0.20.0',
    ],
    python_requires='>=3.5',
    classifiers=[
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
    ],
)
