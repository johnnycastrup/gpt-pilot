#!/bin/bash

set -e  # Exit on error

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "$( dirname "${BASH_SOURCE[0]}" )" )" && pwd )"

# Update Git submodules
if ! git submodule update --init --recursive --remote; then
  echo "Failed to update Git submodules."
  exit 1
fi

# Install Poetry
if ! curl -sSL https://install.python-poetry.org | python3 -; then
  echo "Failed to install Poetry."
  exit 1
fi

if ! poetry install; then
  echo "Failed to install project dependencies with Poetry."
  exit 1
fi

# Install requirements.txt plugin
(
  source "$(poetry env info --path)/bin/activate"

  if ! cd "${SCRIPT_DIR}/submodules/poetry-add-requirements.txt"; then
    echo "Failed to cd into submodules directory."
    exit 1
  fi

  if ! poetry install; then
    echo "Failed to install requirements.txt plugin."
    exit 1
  fi
)

# Import requirements.txt
(
  if ! cd "$SCRIPT_DIR"; then
    echo "Failed to cd into project root directory."
    exit 1
  fi

  if ! poetry-add-requirements.txt "$SCRIPT_DIR/requirements.txt"; then
    echo "Failed to import requirements.txt."
    exit 1
  fi
)

# Install project dependencies
if ! poetry install; then
  echo "Failed to install project dependencies."
  exit 1
fi

echo "Setup successful."

