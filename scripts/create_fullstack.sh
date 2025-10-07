#!/usr/bin/env bash
# create_fullstack.sh - creates parent folder with React frontend + NestJS backend using npm

source "$(dirname "$0")/helpers.sh"

project_name=$(text_input "Fullstack project name:")
if [ -z "$project_name" ]; then
  notify "Cancelled" "No project name provided";
  exit 1;
fi

# Validate project name
if [[ ! "$project_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  notify "Invalid Name" "Use letters (upper/lower case), numbers, hyphens, and underscores only"
  exit 1
fi

parent="$BASE_DIR/$project_name"
mkdir -p "$parent"

### --- FRONTEND ---
frontend_name="${project_name}-frontend"
notify "Creating Frontend" "Setting up React project ($frontend_name)..."

bash "$(dirname "$0")/create_project.sh" <<EOF
React
$frontend_name
EOF

# Move and apply template if found
if [ -d "$BASE_DIR/$frontend_name" ]; then
  run_cmd mv "$BASE_DIR/$frontend_name" "$parent/frontend" || true
  apply_template "react" "$parent/frontend" || true

  # Update package.json name for frontend
  if [ -f "$parent/frontend/package.json" ]; then
    run_cmd sed -i "s/react-template/$frontend_name/" "$parent/frontend/package.json" || true

    # Fast dependency validation for frontend
    cd "$parent/frontend"
    if [ -d "node_modules" ] && [ -f "package-lock.json" ]; then
      run_cmd npm ci >/dev/null 2>&1 && notify "Speed" "⚡ Frontend dependencies validated" || run_cmd npm install >/dev/null 2>&1 || true
    else
      run_cmd npm install >/dev/null 2>&1 || true
    fi
  fi
else
  notify "Warning" "Frontend folder $frontend_name not found. Please move it manually."
fi

### --- BACKEND ---
backend_name="${project_name}-backend"
notify "Creating Backend" "Setting up NestJS project ($backend_name)..."

bash "$(dirname "$0")/create_project.sh" <<EOF
NestJS
$backend_name
EOF

if [ -d "$BASE_DIR/$backend_name" ]; then
  run_cmd mv "$BASE_DIR/$backend_name" "$parent/backend" || true
  apply_template "nestjs" "$parent/backend" || true

  # Update package.json name for backend
  if [ -f "$parent/backend/package.json" ]; then
    run_cmd sed -i "s/nestjs-template/$backend_name/" "$parent/backend/package.json" || true

    # Fast dependency validation for backend
    cd "$parent/backend"
    if [ -d "node_modules" ] && [ -f "package-lock.json" ]; then
      run_cmd npm ci >/dev/null 2>&1 && notify "Speed" "⚡ Backend dependencies validated" || run_cmd npm install >/dev/null 2>&1 || true
    else
      run_cmd npm install >/dev/null 2>&1 || true
    fi
  fi
else
  notify "Warning" "Backend folder $backend_name not found. Please move it manually."
fi

### --- OPTIONAL .ENV FILE ---
if ask_yes_no "Create .env.example for parent?"; then
  {
    echo "API_URL=http://localhost:4000"
    echo "FRONTEND_URL=http://localhost:3000"
  } > "$parent/.env.example"
  notify "Created" ".env.example created in $parent"
fi

### --- GIT SETUP ---
cd "$parent" || exit
if ask_yes_no "Init parent git repo?"; then
  run_cmd git init || true
  run_cmd git add . || true
  run_cmd git commit -m "Initial fullstack scaffold" || true

  if ask_yes_no "Create GitHub repository for '$project_name'?"; then
    if ! command -v gh >/dev/null 2>&1; then
      notify "GitHub CLI Missing" "❌ GitHub CLI (gh) is not installed.\n\nInstall it first:\n  https://cli.github.com/"
    else
      # Ask for privacy setting
      privacy=$(printf "Public\nPrivate" | rofi -dmenu -i -theme "$(dirname "$(dirname "$0")")/themes/devmenu.rasi" -p "Repository type:")

      case "$privacy" in
        "Private")
          if gh repo create "$project_name" --private --source=. --remote=origin --push >/dev/null 2>&1; then
            notify "GitHub Success" "✅ Private repository created and pushed successfully"
          else
            notify "GitHub Failed" "❌ Failed to create private repository"
          fi
          ;;
        "Public")
          if gh repo create "$project_name" --public --source=. --remote=origin --push >/dev/null 2>&1; then
            notify "GitHub Success" "✅ Public repository created and pushed successfully"
          else
            notify "GitHub Failed" "❌ Failed to create public repository"
          fi
          ;;
        *)
          notify "GitHub Cancelled" "Repository creation cancelled"
          ;;
      esac
    fi
  fi
fi

### --- FINAL SUMMARY ---
notify "Fullstack Ready 🚀" "✅ React frontend\n✅ NestJS backend\n📁 Location: $parent\n💡 Package manager: npm"

# Open in Codium if available, fallback to code
if command -v codium >/dev/null 2>&1; then
  notify "Opening Editor" "🚀 Opening fullstack project in VSCodium..."
  codium "$parent" &
elif command -v code >/dev/null 2>&1; then
  notify "Opening Editor" "🚀 Opening fullstack project in VS Code..."
  code "$parent" &
else
  notify "No Editor" "❌ No editor found\n\nInstall codium or code to auto-open projects.\nProject location: $parent"
fi
