#!/usr/bin/env bash

command -v php >/dev/null 2>&1 || { echo >&2 "PHP is requried, but is not installed.  Aborting."; exit 1; }
DIR="`dirname \"$0\"`"
chmod 666 $DIR/InitializerExtension.swift
php $DIR/Scripts/Init.php $1
