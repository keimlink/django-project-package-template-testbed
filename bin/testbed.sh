#!/usr/bin/env bash
# This file:
#
#  Run different commands in testbed.
#
# Usage:
#
#  testbed.sh [COMMAND]
#
# Based on a template by BASH3 Boilerplate v2.3.0
# http://bash3boilerplate.sh/#authors
#
# The MIT License (MIT)
# Copyright (c) 2013 Kevin van Zonneveld and contributors
# You are not obligated to bundle the LICENSE file with your b3bp projects as long
# as you leave these references intact in the header comments of your source files.

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
# set -o xtrace

# Add WhiteNoiseMiddleware to be used with Gunicorn
write_settings() {
    cat <<EOF >.deploy/lib/python3.7/site-packages/settings.py
from ${DJANGO_PACKAGE}.conf.settings import *

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "whitenoise.middleware.WhiteNoiseMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]
EOF
}

configure_django() {
    export DJANGO_ALLOWED_HOSTS="localhost, 127.0.0.1, [::1]"
    export DJANGO_DEBUG=False
    DJANGO_PACKAGE=$(../.venv/bin/python3 setup.py --name)
    export DJANGO_PACKAGE
    export DJANGO_SETTINGS_MODULE=settings
    DJANGO_STATIC_ROOT=$(pwd)/staticfiles
    export DJANGO_STATIC_ROOT
}

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
cd "${DIR}/../testbed"

case $1 in
    setup)
        ../.venv/bin/python3 -m pip install --upgrade pip setuptools wheel
        ../.venv/bin/python3 -m pip install --editable .[dev]
        ;;
    migrate)
        ../.venv/bin/python3 ./manage.py migrate
        ;;
    createsuperuser)
        ../.venv/bin/python3 ./manage.py createsuperuser --email ada@example.com --username ada
        ;;
    runserver)
        ../.venv/bin/python3 ./manage.py runserver
        ;;
    git-init)
        git init
        git add --all
        git commit --message="Initial commit"
        ;;
    wheel)
        ../.venv/bin/python3 -m check_manifest
        ../.venv/bin/python3 ./setup.py bdist_wheel
        ;;
    deploy)
        configure_django
        python3 -m venv .deploy
        .deploy/bin/python3 -m pip install --upgrade pip setuptools wheel
        .deploy/bin/python3 -m pip install --find-links=dist "${DJANGO_PACKAGE}" gunicorn whitenoise
        write_settings
        .deploy/bin/django-project migrate
        .deploy/bin/django-project createsuperuser --email ada@example.com --username ada
        ;;
    collectstatic)
        configure_django
        .deploy/bin/django-project collectstatic --no-input
        ;;
    server)
        configure_django
        .deploy/bin/gunicorn --access-logfile - "${DJANGO_PACKAGE}.conf.wsgi"
        ;;
esac
