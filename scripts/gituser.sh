#!/bin/bash

NAME="$(grep "git_user" .env | sed -r 's/.{,9}//')"
MAIL="$(grep "git_mail" .env | sed -r 's/.{,9}//')"

git config user.name "$NAME"
git config user.email "$MAIL"

git config --local --list
