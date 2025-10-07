#!/usr/bin/env bash
# github_create.sh - create GitHub repositories with private/public option

source "$(dirname "$0")/helpers.sh"

# Function to detect project type based on package.json dependencies
detect_project_type() {
  local project_dir="$1"
  local package_json="$project_dir/package.json"
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

# Function to detect fullstack project type
detect_fullstack_type() {
  local project_dir="$1"
  local frontend_dir="$BASE_DIR/$project_dir/frontend"
  local backend_dir="$BASE_DIR/$project_dir/backend"

  local frontend_type=""
  local backend_type=""

  # Check frontend subdirectory
  if [ -d "$frontend_dir" ] && [ -f "$frontend_dir/package.json" ]; then
    frontend_type=$(detect_project_type "$frontend_dir")
  fi

  # Check backend subdirectory
  if [ -d "$backend_dir" ] && [ -f "$backend_dir/package.json" ]; then
    backend_type=$(detect_project_type "$backend_dir")
  fi

  # Return formatted fullstack type if both exist
  if [ -n "$frontend_type" ] && [ -n "$backend_type" ] && [ "$frontend_type" != "Unknown" ] && [ "$backend_type" != "Unknown" ]; then
    echo "$frontend_type + $backend_type"
    return
  fi

  echo ""
}

# Function to create GitHub repository
create_github_repo() {
  local repo_name="$1"
  local is_private="$2"
  local project_dir="$3"

  # Check if GitHub CLI is installed
  if ! command -v gh >/dev/null 2>&1; then
    notify "GitHub CLI Missing" "❌ GitHub CLI (gh) is not installed.\n\nInstall it first:\n  https://cli.github.com/"
    return 1
  fi

  # Check if user is authenticated with GitHub
  if ! gh auth status >/dev/null 2>&1; then
    notify "GitHub Auth Required" "❌ Please authenticate with GitHub CLI first:\n  gh auth login"
    return 1
  fi

  # Set privacy flag
  local privacy_flag=""
  if [ "$is_private" = "true" ]; then
    privacy_flag="--private"
    privacy_text="Private"
  else
    privacy_flag="--public"
    privacy_text="Public"
  fi

  notify "Creating GitHub Repo" "🚀 Creating $privacy_text repository: $repo_name"

  # Create repository on GitHub
  if gh repo create "$repo_name" $privacy_flag --source="$project_dir" --remote=origin --push >/dev/null 2>&1; then
    notify "GitHub Repo Created" "✅ $privacy_text repository '$repo_name' created successfully!\n🌐 Remote origin configured and pushed"
    return 0
  else
    notify "GitHub Creation Failed" "❌ Failed to create repository '$repo_name'\n\nThis might be because:\n• Repository already exists\n• Invalid repository name\n• Network issues"
    return 1
  fi
}

# Function to prompt for GitHub repo creation
prompt_github_creation() {
  local project_name="$1"
  local project_dir="$2"

  if ask_yes_no "Create GitHub repository for '$project_name'?"; then
    # Ask for privacy setting
    privacy=$(printf "Public\nPrivate" | rofi -dmenu -i -theme "$(dirname "$(dirname "$0")")/themes/devmenu.rasi" -p "Repository type:")

    case "$privacy" in
      "Private")
        create_github_repo "$project_name" "true" "$project_dir"
        ;;
      "Public")
        create_github_repo "$project_name" "false" "$project_dir"
        ;;
      *)
        notify "Cancelled" "GitHub repository creation cancelled"
        ;;
    esac
  else
    notify "Skipped" "GitHub repository creation skipped"
  fi
}

# Function to list all projects with git repositories
list_git_projects() {
  local folders=()
  while IFS= read -r -d '' folder; do
    local folder_name=$(basename "$folder")

    # Check if it's a fullstack project first
    local fullstack_type=$(detect_fullstack_type "$folder_name")
    if [ -n "$fullstack_type" ]; then
      folders+=("$folder_name [$fullstack_type]")
      continue
    fi

    # Check for regular projects with git repos
    if [ -d "$BASE_DIR/$folder_name/.git" ]; then
      local project_type=$(detect_project_type "$BASE_DIR/$folder_name")
      if [ "$project_type" != "Unknown" ]; then
        folders+=("$folder_name [$project_type]")
      fi
    fi
  done < <(find "$BASE_DIR" -maxdepth 1 -type d -not -path "$BASE_DIR" -print0 | sort -z)

  if [ ${#folders[@]} -eq 0 ]; then
    notify "No Git Projects Found" "No git repositories found in $BASE_DIR"
    exit 1
  fi

  printf "%s\n" "${folders[@]}"
}

# Standalone mode - create repo for selected directory
if [ $# -eq 0 ]; then
  notify "GitHub Repo Creation" "Select project to create GitHub repository for"
  proj_selection=$(list_git_projects | rofi -dmenu -i -theme "$(dirname "$(dirname "$0")")/themes/devmenu-folder.rasi" -p "Create GitHub Repo:")

  [ -n "$proj_selection" ] || { notify "Cancelled" "No project selected"; exit 1; }

  # Extract folder name from selection (remove [Type] suffix)
  proj=$(echo "$proj_selection" | sed 's/ \[[^]]*\]$//')
  project_dir="$BASE_DIR/$proj"

  [ -d "$project_dir" ] || { notify "Error" "Project folder not found: $proj"; exit 1; }
  [ -d "$project_dir/.git" ] || { notify "Error" "Project is not a git repository: $proj"; exit 1; }

  notify "GitHub Repo Creation" "📁 Selected project: $proj"

  # Change to project directory and create repo
  cd "$project_dir" || exit 1
  prompt_github_creation "$proj" "$project_dir"
fi

# Integrated mode - called from other scripts
if [ $# -eq 3 ]; then
  project_name="$1"
  project_dir="$2"
  auto_create="$3"

  if [ "$auto_create" = "true" ]; then
    prompt_github_creation "$project_name" "$project_dir"
  fi
fi
