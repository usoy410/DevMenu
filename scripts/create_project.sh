#!/usr/bin/env bash
# create_project.sh
# Usage: ./create_project.sh [ProjectType]
# ProjectType: "React", "Expo + NativeWind", "NestJS"
# Called by devmenu.sh with project type as argument

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(dirname "$(dirname "$0")")"
source "$(dirname "$0")/helpers.sh"

# Signal handling for clean exit
cleanup() {
  echo ""
  notify "Cancelled" "Project creation cancelled by user"
  exit 130
}

trap cleanup INT TERM

# Progress logging for rofi users
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# Fast operation without spinner overhead
fast_spinner() {
  local pid=$1
  local message=$2
  echo -n "$message"
  # Simple completion indicator without process monitoring overhead
  while [ "$(ps a | awk '{print $1}' | grep -E "^${pid}$")" ]; do
    sleep 0.1
  done
  printf "    \b\b\b\b"
  echo "✅"
}

# Accept project type as first parameter (from devmenu.sh)
if [ -n "${1-}" ]; then
  menu_choice="$1"
else
  notify "Error" "No project type specified"
  exit 1
fi

# Get project name from user via rofi
project_name=$(text_input "Project name:")
if [ -z "$project_name" ]; then
  notify "Cancelled" "No project name provided"
  exit 1
fi

notify "Creating Project" "🚀 Creating $menu_choice project: $project_name"

# menu_choice is already set from the argument

# All projects use TypeScript by default
# Set vite template for React
vite_template="react-ts"

# Set project_name for backward compatibility
# project_name is already set above with generated name

# Ask about git initialization and commit
if [ -d "$SCRIPT_DIR/templates" ]; then
  notify "Git Setup" "📋 Project ready. Configure git?"
  git_setup=$(text_input "git and commit?(y/n):")
  if [[ "$git_setup" =~ ^[Yy](es)?$ ]]; then
    commit_msg=$(text_input "initial message:")
    if [ -z "$commit_msg" ]; then
      commit_msg="Initial commit"
    fi
    DO_GIT_INIT=true
    GIT_COMMIT_MSG="$commit_msg"
    notify "Git" "✅ Git will be initialized with commit: '$commit_msg'"
  else
    DO_GIT_INIT=false
    notify "Git" "⏭️ Skipping git initialization"
  fi
else
  # Fallback mode - no templates, ask about git
  notify "Git Setup" "📋 Configure git for project?"
  git_setup=$(text_input "git and commit? (y/n):")
  if [[ "$git_setup" =~ ^[Yy](es)?$ ]]; then
    commit_msg=$(text_input "Commit message: ")
    if [ -z "$commit_msg" ]; then
      commit_msg="Initial commit"
    fi
    DO_GIT_INIT=true
    GIT_COMMIT_MSG="$commit_msg"
    notify "Git" "✅ Git will be initialized with commit: '$commit_msg'"
  else
    DO_GIT_INIT=false
    notify "Git" "⏭️ Skipping git initialization"
  fi
fi

# Check if directory already exists
if [ -d "$BASE_DIR/$project_name" ]; then
  notify "Directory Exists" "⚠️ Directory $BASE_DIR/$project_name already exists!"
  if ! command -v gh >/dev/null 2>&1; then
    echo "Error: Project directory already exists and GitHub CLI not available for remote operations."
    exit 1
  fi
  notify "Proceeding" "ℹ️ Will proceed with existing directory..."
fi
mkdir -p "$BASE_DIR"
cd "$BASE_DIR" || exit 1

case "$menu_choice" in
"React")
  dest="$BASE_DIR/$project_name"
  notify "Setting Up" "⚛️ Setting up React project..."

  # Check if template exists, otherwise fallback to npm create
  if [ -d "$SCRIPT_DIR/templates/react" ]; then
    notify "Copying" "📋 Copying React template..."
    (
      cp -r "$SCRIPT_DIR/templates/react" "$project_name"
      cd "$project_name"

      # Update package.json name (fast method)
      if [ -f "package.json" ]; then
        sed -i "s/\"name\": \"react-template\"/\"name\": \"$project_name\"/" package.json
      fi

      # Ultra-fast path: if template has complete node_modules, skip all npm operations
      if [ -d "node_modules" ] && [ -f "package-lock.json" ]; then
        notify "Ultra-Fast" "⚡ Template complete, no installation needed!"
      else
        # Fallback: only install if dependencies are missing
        if [ -f "package-lock.json" ]; then
          notify "Installing" "📦 Installing dependencies (using package-lock.json)..."
          npm ci >/dev/null 2>&1 || npm install >/dev/null 2>&1
        else
          notify "Installing" "📦 Installing dependencies..."
          npm install >/dev/null 2>&1
        fi
      fi
    ) &
    fast_spinner $! "Creating React project"
    wait $!
    notify "Success" "✅ React project created successfully"
  else
    notify "Warning" "⚠️ React template not found, using npm create..."
    # Fallback to original npm create method
    (
      npm create vite@latest "$project_name" -- --template "react-ts" --yes 2>/dev/null
      cd "$project_name"

      notify "Installing" "🎨 Installing Tailwind CSS..."
      npm install -D tailwindcss postcss autoprefixer >/dev/null 2>&1
      npx tailwindcss init -p >/dev/null 2>&1

      # Configure Tailwind
      if [ -f "tailwind.config.js" ]; then
        cat <<'EOF' >tailwind.config.js
/** @type {import('tailwindcss').Config} */
export default {
content: [
 "./index.html",
 "./src/**/*.{js,ts,jsx,tsx}",
],
theme: {
 extend: {},
},
plugins: [],
}
EOF
      fi

      # Add Tailwind directives to CSS
      if [ -f "src/index.css" ]; then
        cat <<'EOF' >src/index.css
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF
      fi

      # Update main.tsx to use Tailwind
      if [ -f "src/main.tsx" ]; then
        if ! grep -q "index.css" src/main.tsx; then
          sed -i '1a import "./index.css";' src/main.tsx
        fi
      fi

      notify "Installing" "📦 Installing additional dependencies..."
      deps=$(get_deps react)
      if [ -n "$deps" ]; then
        if install_deps npm $deps; then
          notify "Success" "✅ Additional dependencies installed successfully"
        else
          notify "Warning" "⚠️ Some dependencies failed to install"
        fi
      fi
    ) &
    spinner $! "Creating React project"
    wait $!
    notify "Success" "✅ React project created successfully (using npm create)"
  fi
  ;;

"Expo + NativeWind")
  dest="$BASE_DIR/$project_name"
  notify "Setting Up" "📱 Setting up React Native project..."

  # Check if template exists, otherwise fallback to npm create
  if [ -d "$SCRIPT_DIR/templates/expo" ]; then
    notify "Copying" "📋 Copying Expo template..."
    (
      cp -r "$SCRIPT_DIR/templates/expo" "$project_name"
      cd "$project_name"

      # Update package.json name
      sed -i "s/expo-template/$project_name/" package.json

      # Ultra-fast path: if template has complete node_modules, skip all npm operations
      if [ -d "node_modules" ] && [ -f "package-lock.json" ]; then
        notify "Ultra-Fast" "⚡ Template complete, no installation needed!"
      else
        # Fallback: only install if dependencies are missing
        if [ -f "package-lock.json" ]; then
          notify "Installing" "📦 Installing dependencies (using package-lock.json)..."
          npm ci >/dev/null 2>&1 || npm install >/dev/null 2>&1
        else
          notify "Installing" "📦 Installing dependencies..."
          timeout 30 npm install >/dev/null 2>&1 || notify "Warning" "⚠️ Installation failed"
        fi
      fi
    ) &
    fast_spinner $! "Creating React Native project"
    wait $!
    notify "Success" "✅ React Native project created successfully"
  else
    notify "Warning" "⚠️ Expo template not found, using npm create..."
    # Fallback to original npm create method
    (
      npx create-expo-app "$project_name" --template blank-typescript --yes >/dev/null 2>&1
      cd "$project_name"

      # required NativeWind deps
      notify "Installing" "📦 Installing NativeWind and dependencies..."
      npm install nativewind tailwindcss react-native-reanimated react-native-safe-area-context >/dev/null 2>&1

      # additional deps from config
      deps=$(get_deps expo)
      if [ -n "$deps" ]; then
        if install_deps npm $deps; then
          notify "Success" "✅ Additional dependencies installed successfully"
        else
          notify "Warning" "⚠️ Some dependencies failed to install"
        fi
      fi

      # ensure tailwind config exists
      if [ ! -f "tailwind.config.js" ]; then
        cat <<'EOF' >"tailwind.config.js"
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./App.{js,jsx,ts,tsx}", "./src/**/*.{js,jsx,ts,tsx}"],
  theme: { extend: {} },
  plugins: [],
};
EOF
      fi

      # ensure babel.config.js includes nativewind plugin if not present
      if [ ! -f "babel.config.js" ]; then
        cat <<'EOF' >"babel.config.js"
module.exports = function (api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: ['nativewind/babel'],
  };
};
EOF
      fi
    ) &
    spinner $! "Creating React Native project"
    wait $!
    notify "Success" "✅ React Native project created successfully (using npm create)"
  fi
  ;;

"NestJS")
  dest="$BASE_DIR/$project_name"
  notify "Setting Up" "🏗️ Setting up NestJS project..."

  # Check if template exists, otherwise fallback to nest CLI
  if [ -d "$SCRIPT_DIR/templates/nestjs" ]; then
    notify "Copying" "📋 Copying NestJS template..."
    (
      cp -r "$SCRIPT_DIR/templates/nestjs" "$project_name"
      cd "$project_name"

      # Update package.json name
      sed -i "s/nestjs-template/$project_name/" package.json

      # Ultra-fast path: if template has complete node_modules, skip all npm operations
      if [ -d "node_modules" ] && [ -f "package-lock.json" ]; then
        notify "Ultra-Fast" "⚡ Template complete, no installation needed!"
      else
        # Fallback: only install if dependencies are missing
        if [ -f "package-lock.json" ]; then
          notify "Installing" "📦 Installing dependencies (using package-lock.json)..."
          npm ci >/dev/null 2>&1 || npm install >/dev/null 2>&1
        else
          notify "Installing" "📦 Installing dependencies..."
          npm install >/dev/null 2>&1
        fi
      fi
    ) &
    fast_spinner $! "Creating NestJS project"
    wait $!
    notify "Success" "✅ NestJS project created successfully"
  else
    notify "Warning" "⚠️ NestJS template not found, using nest CLI..."
    # Fallback to original nest CLI method
    if command -v nest >/dev/null 2>&1; then
      (
        # --package-manager npm and --skip-git to avoid prompts
        nest new "$project_name" --package-manager npm --skip-git --yes >/dev/null 2>&1
        cd "$project_name"

        # additional nestjs presets from config
        deps=$(get_deps nestjs)
        if [ -n "$deps" ]; then
          notify "Installing" "📦 Installing additional dependencies..."
          if install_deps npm $deps; then
            notify "Success" "✅ Additional dependencies installed successfully"
          else
            notify "Warning" "⚠️ Some dependencies failed to install"
          fi
        fi
      ) &
      spinner $! "Creating NestJS project"
      wait $!
      notify "Success" "✅ NestJS project created successfully (using nest CLI)"
    else
      notify "Warning" "⚠️ NestJS CLI not found, using fallback method..."
      # fallback: scaffold minimal package.json and install deps
      mkdir -p "$dest" && cd "$dest" || exit
      cat <<EOF >package.json
{
  "name": "$project_name",
  "version": "0.0.1",
  "private": true
}
EOF
      deps=$(get_deps nestjs)
      if [ -n "$deps" ]; then
        if install_deps npm $deps; then
          notify "Success" "✅ Dependencies installed successfully"
        else
          notify "Warning" "⚠️ Some dependencies failed to install"
        fi
      fi
      notify "Success" "✅ NestJS project created successfully (fallback method)"
    fi
  fi
  ;;

*)
  notify "Unknown" "No valid option: $menu_choice"
  exit 1
  ;;
esac

# Ensure we are in project directory
cd "$BASE_DIR/$project_name" || exit 1

# Initialize git repo if user requested it
if [ "$DO_GIT_INIT" = true ]; then
  # Initialize git repo and setup
  cd "$BASE_DIR/$project_name" || exit 1

  notify "Git" "🔧 Initializing git repository..."
  if git init; then
    notify "Success" "✅ Git repository initialized"

    # Create .gitignore with essential entries
    notify "Git" "📝 Creating .gitignore..."
    cat <<EOF >.gitignore
node_modules
dist
build
.env
.env.local
.env.production
.env.development
.vscode
.DS_Store
*.log
EOF
    notify "Success" "✅ .gitignore created"

    # Add all files and commit
    notify "Git" "💾 Creating initial commit..."
    if git add . && [ -n "$(git status --porcelain)" ]; then
      if git commit -m "$GIT_COMMIT_MSG"; then
        notify "Success" "✅ Initial commit created: '$GIT_COMMIT_MSG'"
      else
        notify "Error" "❌ Git commit failed"
      fi
    else
      notify "Warning" "⚠️ No files to commit"
    fi
  else
    notify "Error" "❌ Failed to initialize git repository"
  fi
else
  notify "Git" "⏭️ Git initialization skipped by user"
fi

# GitHub repository creation
if command -v gh >/dev/null 2>&1; then
  if ask_yes_no "Create GitHub repository for '$project_name'?"; then
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
  else
    notify "GitHub Skipped" "You can manually create a repository later:\n💡 gh repo create $project_name --source=. --private"
  fi
else
  notify "GitHub CLI Missing" "⚠️ GitHub CLI (gh) not found.\n\nInstall it to enable GitHub integration:\n  https://cli.github.com/"
  notify "GitHub Manual" "💡 You can manually create a repository at https://github.com/new"
fi

# Success message with project details
notify "Project Complete" "🎉 Project '$project_name' created and ready!"
echo ""
echo "🎉 Project '$project_name' created successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 Location: $(pwd)"
echo "🔧 Type: $menu_choice"

if command -v gh >/dev/null 2>&1 && git remote get-url origin >/dev/null 2>&1; then
  echo "🌐 GitHub: $(git remote get-url origin)"
fi

echo ""
echo "🚀 Next steps:"
echo "  cd $BASE_DIR/$project_name"
if [ -f "package.json" ]; then
  echo "  npm install"
  if [ "$menu_choice" = "React" ]; then
    echo "  npm run dev    # Start development server"
  elif [ "$menu_choice" = "Expo + NativeWind" ]; then
    echo "  npm start      # Start Expo development server"
  elif [ "$menu_choice" = "NestJS" ]; then
    echo "  npm run start:dev  # Start NestJS development server"
  fi
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
notify "Next Steps" "📋 Check terminal for next steps to run the project"

# Open in editor (background)
if command -v codium >/dev/null 2>&1; then
  notify "Opening Editor" "🚀 Opening $project_name in VSCodium..."
  if codium . >/dev/null 2>&1 & then
    notify "Success" "✅ VSCodium opened successfully"
  else
    notify "Error" "❌ Failed to open VSCodium"
  fi
elif command -v code >/dev/null 2>&1; then
  notify "Opening Editor" "🚀 Opening $project_name in VS Code..."
  if code . >/dev/null 2>&1 & then
    notify "Success" "✅ VS Code opened successfully"
  else
    notify "Error" "❌ Failed to open VS Code"
  fi
else
  notify "No Editor" "❌ No editor found\n\nInstall codium or code to auto-open projects.\nProject location: $(pwd)"
fi

exit 0
