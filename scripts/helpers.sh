#!/usr/bin/env bash

BASE_DIR="$HOME/Desktop/Development"

notify() {
  local title="$1"
  local msg="$2"
  notify-send "🧠 $title" "$msg"
}

run_cmd() {
  echo "▶️ $*" && eval "$@"
  if [ $? -ne 0 ]; then
    notify "Error" "❌ Command failed: $*"
    exit 1
  fi
}

ask_yes_no() {
  choice=$(printf "Yes\nNo" | rofi -dmenu -i -p "$1" -theme "$(dirname "$(dirname "$0")")/themes/devmenu.rasi")
  [[ "$choice" == "Yes" ]]
}

text_input() {
  rofi -dmenu -p "$1" -theme "$(dirname "$(dirname "$0")")/themes/devmenu-input.rasi"
}

# Get additional dependencies for project type
get_deps() {
  case "$1" in
    "react")
      echo "react-router-dom @types/react @types/react-dom axios"
      ;;
    "expo")
      echo "expo-router @expo/vector-icons expo-constants"
      ;;
    "nestjs")
      echo "@nestjs/config @nestjs/jwt @nestjs/passport passport passport-jwt passport-local @types/passport-jwt @types/passport-local bcryptjs @types/bcryptjs class-validator class-transformer"
      ;;
    *)
      echo ""
      ;;
  esac
}

# Install dependencies with error handling
install_deps() {
  local package_manager="$1"
  shift
  local deps="$*"

  if [ -n "$deps" ]; then
    log "📦 Installing additional dependencies: $deps"
    if ! $package_manager install $deps >/dev/null 2>&1; then
      log "⚠️ Failed to install some dependencies: $deps"
      return 1
    fi
  fi
}

# Apply template to project directory
apply_template() {
  local template_name="$1"
  local target_dir="$2"

  if [ -d "$SCRIPT_DIR/templates/$template_name" ]; then
    notify "Applying Template" "📋 Applying $template_name template to $target_dir..."
    if cp -r "$SCRIPT_DIR/templates/$template_name/." "$target_dir/"; then
      notify "Success" "✅ Template applied successfully"
      return 0
    else
      notify "Warning" "⚠️ Failed to apply template"
      return 1
    fi
  else
    notify "Warning" "⚠️ Template $template_name not found"
    return 1
  fi
}
