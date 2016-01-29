#!/usr/bin/env bash

command -v php >/dev/null 2>&1 || { echo >&2 "PHP is requried, but is not installed.  Aborting."; exit 1; }
chmod 666 InitializerExtension.swift
php Scripts/Init.php $1
