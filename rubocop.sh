#! /bin/sh
if [ $# -eq 1 -a x"$1" = x--version ]; then
  rubocop "$@" 2>&1 | sed '/^warning:/ d'
elif [ ! -f .rubocop.yml ]; then
    return 0
else
  exec rubocop "$@"
fi
