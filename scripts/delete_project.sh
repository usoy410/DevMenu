#!/usr/bin/env bash
# delete_project.sh - safely delete projects with confirmation

source "$(dirname "$0")/helpers.sh"
# Function to detect project type based on package.json dependencies
detect_project_type() {
  local project_dir="$1"
  local package_json="$BASE_DIR/$project_dir/package.json"
  if [ ! -f "$package_json" ]; then
    echo "Unknown"
    return
  fi

  # Check for Expo/React Native (frontend)
  if jq -e '.dependencies.expo or .dependencies."react-native"' "$package_json" >/dev/null 2>&1; then
    echo "React-Native"
    return
  fi
  # Check for React (frontend)
  if jq -e '.dependencies.react or .devDependencies.react' "$package_json" >/dev/null 2>&1; then
    echo "React"
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

# Function to detect fullstack project type
detect_fullstack_type() {
  local project_dir="$1"
  local frontend_dir="$BASE_DIR/$project_dir/frontend"
  local backend_dir="$BASE_DIR/$project_dir/backend"

  local frontend_type=""
  local backend_type=""

  # Check frontend subdirectory
  if [ -d "$frontend_dir" ]; then
    if [ -f "$frontend_dir/package.json" ]; then
      frontend_type=$(detect_project_type "$frontend_dir")
    elif [ -f "$frontend_dir/package-lock.json" ]; then
      # If no package.json, try to detect from package-lock.json
      frontend_type=$(detect_project_type "$frontend_dir")
    fi
  fi

  # Check backend subdirectory
  if [ -d "$backend_dir" ]; then
    if [ -f "$backend_dir/package.json" ]; then
      backend_type=$(detect_project_type "$backend_dir")
    elif [ -f "$backend_dir/package-lock.json" ]; then
      # If no package.json, try to detect from package-lock.json
      backend_type=$(detect_project_type "$backend_dir")
    fi
  fi

  # Return formatted fullstack type if both directories exist and have content
  if [ -d "$frontend_dir" ] && [ -d "$backend_dir" ]; then
    if [ -n "$frontend_type" ] && [ -n "$backend_type" ] && [ "$frontend_type" != "Unknown" ] && [ "$backend_type" != "Unknown" ]; then
      echo "$frontend_type + $backend_type"
      return
    elif [ -d "$frontend_dir" ] && [ -d "$backend_dir" ]; then
      # If directories exist but detection fails, assume it's fullstack
      echo "Fullstack"
      return
    fi
  fi

  echo ""
}

# Function to list all projects with their types
list_all_projects_with_types() {
  local folders=()
  while IFS= read -r -d '' folder; do
    local folder_name=$(basename "$folder")

    # Check if it's a fullstack project first (has frontend/ and backend/ directories)
    local fullstack_type=$(detect_fullstack_type "$folder_name")
    if [ -n "$fullstack_type" ]; then
      folders+=("$folder_name [$fullstack_type]")
      continue
    fi

    # Check for regular single projects
    if [ -f "$BASE_DIR/$folder_name/package.json" ]; then
      local project_type=$(detect_project_type "$folder_name")
      if [ "$project_type" != "Unknown" ]; then
        folders+=("$folder_name [$project_type]")
      fi
    elif [ -d "$BASE_DIR/$folder_name/.git" ]; then
      # If no package.json but has .git, consider it a project
      folders+=("$folder_name [Project]")
    fi
  done < <(find "$BASE_DIR" -maxdepth 1 -type d -not -path "$BASE_DIR" -print0 | sort -z)

  if [ ${#folders[@]} -eq 0 ]; then
    notify "No Projects Found" "No projects found in $BASE_DIR"
    exit 1
  fi

  printf "%s\n" "${folders[@]}"
}
# Function to get project size for confirmation
get_project_size() {
  local project_dir="$1"
  if [ -d "$BASE_DIR/$project_dir" ]; then
    du -sh "$BASE_DIR/$project_dir" 2>/dev/null | cut -f1
  else
    echo "Unknown"
  fi
}

notify "Delete Project" "⚠️ Select project to delete"
proj_selection=$(list_all_projects_with_types | rofi -dmenu -i -theme "$(dirname "$(dirname "$0")")/themes/devmenu.rasi" -p "Delete:")
[ -n "$proj_selection" ] || { notify "Cancelled" "No project selected"; exit 1; }

# Extract folder name from selection (remove [Type] suffix)
proj=$(echo "$proj_selection" | sed 's/ \[[^]]*\]$//')
proj_path="$BASE_DIR/$proj"

[ -d "$proj_path" ] || { notify "Error" "Project folder not found: $proj"; exit 1; }

# Get project size for confirmation
project_size=$(get_project_size "$proj")

# Confirmation dialog
if [ -n "$project_size" ]; then
  confirm_msg="Delete project '$proj'?\n\nSize: $project_size\nLocation: $proj_path"
else
  confirm_msg="Delete project '$proj'?\n\nLocation: $proj_path"
fi

if ask_yes_no "Confirm Deletion"; then
  notify "Deleting" "🗑️ Deleting project: $proj"
  # if mv "$proj_path" ~/.local/share/Trash/files ; then
  if rm -rf "$proj_path"; then
    notify "Trash" "✅ Project '$proj' Deleted successfully"
  else
    notify "Error" "❌ Failed to delete project '$proj'"
    exit 1
  fi
else
  notify "Cancelled" "Project deletion cancelled"
fi
