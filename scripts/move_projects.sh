#!/usr/bin/env bash
# move_projects.sh - choose frontend and backend folder then move into parent

source "$(dirname "$0")/helpers.sh"

mkdir -p "$BASE_DIR"

# Function to detect project type based on package.json dependencies
detect_project_type() {
  local project_dir="$1"
  local package_json="$BASE_DIR/$project_dir/package.json"

  if [ ! -f "$package_json" ]; then
    echo "Unknown"
    return
  fi

  # Check for React (frontend)
  if jq -e '.dependencies.react or .devDependencies.react' "$package_json" >/dev/null 2>&1; then
    echo "React"
    return
  fi

  # Check for Expo/React Native (frontend)
  if jq -e '.dependencies.expo or .dependencies."react-native"' "$package_json" >/dev/null 2>&1; then
    echo "Expo"
    return
  fi

  # Check for NestJS (backend)
  if jq -e '.dependencies."@nestjs/core" or .dependencies."@nestjs/common"' "$package_json" >/dev/null 2>&1; then
    echo "NestJS"
    return
  fi

  # Check for Vue (frontend)
  if jq -e '.dependencies.vue or .devDependencies.vue' "$package_json" >/dev/null 2>&1; then
    echo "Vue"
    return
  fi

  # Check for Angular (frontend)
  if jq -e '.dependencies."@angular/core"' "$package_json" >/dev/null 2>&1; then
    echo "Angular"
    return
  fi

  # Check for Express (backend)
  if jq -e '.dependencies.express' "$package_json" >/dev/null 2>&1; then
    echo "Express"
    return
  fi

  # Check for Fastify (backend)
  if jq -e '.dependencies.fastify' "$package_json" >/dev/null 2>&1; then
    echo "Fastify"
    return
  fi

  echo "Unknown"
}

# Function to list folders with project types
list_projects_with_types() {
  local folders=()
  while IFS= read -r -d '' folder; do
    local folder_name=$(basename "$folder")
    local project_type=$(detect_project_type "$folder_name")

    if [ "$project_type" != "Unknown" ]; then
      folders+=("$folder_name [$project_type]")
    fi
  done < <(find "$BASE_DIR" -maxdepth 1 -type d -not -path "$BASE_DIR" -print0 | sort -z)

  if [ ${#folders[@]} -eq 0 ]; then
    notify "No Projects Found" "No projects with detectable types found in $BASE_DIR"
    exit 1
  fi

  printf "%s\n" "${folders[@]}"
}

# Get frontend project
notify "Frontend Project" "Select frontend project"
frontend_selection=$(list_projects_with_types | rofi -dmenu -i -theme "$(dirname "$(dirname "$0")")/themes/devmenu-folder.rasi" -p "Frontend:")
[ -n "$frontend_selection" ] || { notify "Aborted" "No frontend chosen"; exit 1; }

# Extract folder name from selection (remove [Type] suffix)
frontend=$(echo "$frontend_selection" | sed 's/ \[[^]]*\]$//')
[ -d "$BASE_DIR/$frontend" ] || { notify "Error" "Frontend folder not found: $frontend"; exit 1; }

# Get backend project
notify "Backend Project" "Select backend project"
backend_selection=$(list_projects_with_types | rofi -dmenu -i -theme "$(dirname "$(dirname "$0")")/themes/devmenu-folder.rasi" -p "Backend:")
[ -n "$backend_selection" ] || { notify "Aborted" "No backend chosen"; exit 1; }

# Extract folder name from selection (remove [Type] suffix)
backend=$(echo "$backend_selection" | sed 's/ \[[^]]*\]$//')
[ -d "$BASE_DIR/$backend" ] || { notify "Error" "Backend folder not found: $backend"; exit 1; }

# Ensure frontend and backend are different
if [ "$frontend" = "$backend" ]; then
  notify "Error" "Frontend and backend cannot be the same project"
  exit 1
fi

project_name=$(text_input "Parent name:")
[ -n "$project_name" ] || { notify "Aborted" "No parent name"; exit 1; }

parent="$BASE_DIR/$project_name"
mkdir -p "$parent"

run_cmd mv "$BASE_DIR/$frontend" "$parent/frontend" || true
run_cmd mv "$BASE_DIR/$backend" "$parent/backend" || true

notify "Done" "Organized $frontend_selection and $backend_selection into $parent"
codium "$parent" &
notify "Opening codium now"
