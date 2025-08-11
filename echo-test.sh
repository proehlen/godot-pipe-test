#!/bin/bash

# This script reads lines from stdin.
# If it receives "ping", it echoes "pong" to stdout.
# If it receives "quit", it exits.
# If it receives anything else, it just echoes it.
# It continues indefinitely for other inputs until "quit" is received.

echo "ready"

while IFS= read -r line; do
  if [[ "$line" == "ping" ]]; then
    echo "pong"
  elif [[ "$line" == "quit" ]]; then
    echo "stopped"
    break # Exit the loop
  else
    echo "$line?"
  fi
done
