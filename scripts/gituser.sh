#!/bin/bash

NAME="$(grep "git_user" .env | sed -r 's/.*=//')"
MAIL="$(grep "git_mail" .env | sed -r 's/.*=//')"

git config user.name "$NAME"
git config user.email "$MAIL"

git config --local --list
