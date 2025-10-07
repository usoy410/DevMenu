#!/usr/bin/env bash
# devmenu.sh - main rofi menu
source "$(dirname "$0")/scripts/helpers.sh"

# Check current npm registry
current_registry=$(npm config get registry 2>/dev/null | tr -d '\n')
if [[ "$current_registry" == "http://localhost:4873" ]]; then
  registry_option="Use Public Registry"
else
  registry_option="Start Local Registry"
fi

options=(
  "React Project"
  "Expo Project"
  "NestJS Project"
  "Fullstack Project"
  "$registry_option"
  "Make It Fullstack"
  "Open Project"
  "Delete Project"
  "Create GitHub Repo"
)

choice=$(printf "%s\n" "${options[@]}" | rofi -dmenu -i -theme "$(dirname "$0")/themes/devmenu.rasi" -p "DevMenu:")

case "$choice" in
  *"React Project"*) bash "$(dirname "$0")/scripts/create_project.sh" "React" ;;
   *"Expo Project"*) bash "$(dirname "$0")/scripts/create_project.sh" "Expo + NativeWind" ;;
   *"NestJS Project"*) bash "$(dirname "$0")/scripts/create_project.sh" "NestJS" ;;
   *"Fullstack Project"*) bash "$(dirname "$0")/scripts/create_fullstack.sh" ;;
  *"Start Local Registry"*) bash "$(dirname "$0")/registry/start-registry.sh" ;;
  *"Use Public Registry"*)
    npm config set registry https://registry.npmjs.org/
    notify "Registry" "✅ Switched to public npm registry"
    ;;
  *"Make It Fullstack"*) bash "$(dirname "$0")/scripts/move_projects.sh" ;;
   *"Open Project"*) bash "$(dirname "$0")/scripts/open_project.sh" ;;
   *"Delete Project"*) bash "$(dirname "$0")/scripts/delete_project.sh" ;;
   *"Create GitHub Repo"*) bash "$(dirname "$0")/scripts/github_create.sh" ;;
  *) exit 0 ;;
esac
