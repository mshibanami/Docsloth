#!/bin/bash

set -eu

PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SOURCE_DIR="$PROJECT_ROOT/dist"
TARGET_BASE_DIR="$PROJECT_ROOT/../Sources"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: Source directory '$SOURCE_DIR' not found." >&2
  echo "Please build the JavaScript part first (e.g., 'npm run build' in the 'js' directory)." >&2
  exit 1
fi

LINK_TARGETS=(
  "markdown-it.iife.js MarkdownIt"
  "markdown-it-gfm.iife.js MarkdownItGFM"
  "markdown-it-gfm-cjk-friendly.iife.js MarkdownItGFMCJKFriendly"
  "asciidoctor.iife.js Asciidoctor"
)
# -------------------------------------------------------------------

for entry in "${LINK_TARGETS[@]}"; do
  set -- $entry
  filename_with_ext="$1"
  module_name="$2"

  source_file="$SOURCE_DIR/$filename_with_ext"
  target_dir="$TARGET_BASE_DIR/$module_name/Resources"

  if [ ! -f "$source_file" ]; then
    echo "Warning: '$source_file' not found. Skipping."
    continue
  fi

  if [ ! -d "$target_dir" ]; then
    echo "Warning: Target directory '$target_dir' does not exist. Skipping."
    continue
  fi

  relative_path_to_source="../../../js/dist/$filename_with_ext"
  target_link_path="$target_dir/$filename_with_ext"

  echo "Linking: '$target_link_path' -> '$relative_path_to_source'"
  ln -sf "$relative_path_to_source" "$target_link_path"
done

echo "Done."
