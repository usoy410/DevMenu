# DevMenu - Fast Fullstack Development Suite

A fast rofi-based development environment for instant project creation, management, and deployment with local npm registry, pre-built templates, and GitHub integration.

**🗻 Perfect for Arch Linux + Hyprland setups!** Works with any Linux distribution and window manager.

## ⚡ Ultra-Fast Project Creation
## 🚀 Features

- **⚡ Ultra-Fast Templates**: Pre-configured project templates
- **🌐 Local NPM Registry**: No internet downloads needed
- **📋 One-Click Creation**: Select type → Enter name → Done!
- **🔧 Auto-Configuration**: TypeScript, Tailwind, Git all ready
- **📱 Rofi Integration**: Beautiful menu with custom themes
- **🛠️ Error Handling**: Smart fallbacks and notifications
- **💾 Auto-Open**: VSCodium/VS Code opens automatically
- **🚀 GitHub Integration**: Auto-create repositories with private/public option
- **🗑️ Project Management**: Delete projects with confirmation
- **🔄 Fullstack Projects**: Create React + NestJS in one command
- **📦 Smart Naming**: Auto-update package.json names

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Usage](#usage)
- [Project Types](#project-types)
- [Advanced Features](#advanced-features)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)

## 🎯 Prerequisites

### Required Software
- **Linux** with bash shell (Arch, Ubuntu, Debian, Fedora, openSUSE, etc.)
- **Node.js** (v16 or higher)
- **npm** (comes with Node.js)
- **Git** (for version control)
- **rofi** (for the menu interface)

### 💡 Window Manager Compatible
Works with **any window manager** or desktop environment:
- ✅ **Hyprland** (Wayland compositor)
- ✅ **i3wm / Sway** (Tiling window managers)
- ✅ **KDE Plasma** (Traditional desktop)
- ✅ **GNOME** (Default Ubuntu/Fedora)
- ✅ **Xfce, LXQt, Cinnamon** (Lightweight desktops)
- ✅ **Any X11 or Wayland** environment

### Optional Software
- **VSCodium** or **VS Code** (auto-opens projects)
- **GitHub CLI** (`gh`) - for GitHub integration

### Install Prerequisites

**Works with any Linux distribution!** (Arch, Ubuntu, Debian, Fedora, openSUSE, etc.)

#### Arch Linux / Arch-based (Manjaro, EndeavourOS, etc.):
```bash
# Update package list
sudo pacman -Syu

# Install required packages
sudo pacman -S rofi git nodejs npm

# Optional: Install VSCodium (AUR)
yay -S vscodium-bin
# OR: trizen -S vscodium-bin
# OR: paru -S vscodium-bin

# Optional: Install GitHub CLI
yay -S github-cli-bin
```

#### Ubuntu / Debian:
```bash
# Update package list
sudo apt update

# Install required packages
sudo apt install -y rofi git nodejs npm

# Optional: Install VSCodium
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list
sudo apt update && sudo apt install -y codium

# Optional: Install GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/githubcli.list > /dev/null
sudo apt update && sudo apt install -y gh
```

#### Fedora / RHEL / CentOS:
```bash
# Update package list
sudo dnf update

# Install required packages
sudo dnf install -y rofi git nodejs npm

# Optional: Install VSCodium
sudo rpm --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
sudo dnf config-manager --add-repo https://download.vscodium.com/rpms/
sudo dnf install -y codium

# Optional: Install GitHub CLI
sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
sudo dnf install -y gh
```

#### openSUSE:
```bash
# Update package list
sudo zypper refresh

# Install required packages
sudo zypper install -y rofi git nodejs npm

# Optional: Install VSCodium
sudo rpm --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
sudo zypper addrepo https://download.vscodium.com/rpms/ vscodium
sudo zypper install -y codium

# Optional: Install GitHub CLI
sudo zypper addrepo https://cli.github.com/packages/rpm/gh-cli.repo gh-cli
sudo zypper install -y gh
```

#### Universal Alternative (if your distro packages are outdated):
```bash
# Install Node.js (LTS version) - works on any Linux distro
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# OR using Node Version Manager (nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install --lts
nvm use --lts

# Install rofi from source (if not in repos)
git clone https://github.com/davatorium/rofi.git
cd rofi
autoreconf -i
mkdir build && cd build
../configure
make
sudo make install
```

## 🚀 Quick Start

### One-Time Setup (5 minutes)
```bash
# 1. Clone or download the project
git clone <repository-url>
cd devmenu

# 2. Set up templates and local registry
./setup-fast-projects.sh

# 3. Start local npm registry (in one terminal)
./start-registry.sh

# 4. Create your first project (in another terminal)
./devmenu.sh
```

### Daily Usage
```bash
# Start registry once per session
./start-registry.sh

# Create as many projects as you want!
./devmenu.sh
# → Select project type
# → Enter project name
# → Project ready in 2-10 seconds! ⚡
```

## 📦 Installation

1. **Download/Clone** the repository
2. **Make scripts executable**:
   ```bash
   chmod +x *.sh
   ```
3. **Run setup**:
   ```bash
   ./setup-fast-projects.sh
   ```

## 🎮 Usage

### Main Menu Options

Launch the main menu with:
```bash
./devmenu.sh
```

**Available Options:**
- **React Project** - Frontend web application
- **Expo Project** - React Native mobile app
- **NestJS Project** - Backend API server
- **Fullstack Project** - React frontend + NestJS backend
- **Open Project** - Open existing project in editor
- **Delete Project** - Safely delete projects with confirmation
- **Create GitHub Repo** - Create GitHub repository for any git project
- **Registry Management** - Switch between local/public npm registries

### Project Creation Flow

1. **Select project type** from the rofi menu
2. **Enter project name** (supports uppercase, lowercase, numbers, hyphens, underscores)
3. **Choose GitHub options** (create repo, private/public)
4. **Project is created** and opened in your editor automatically!

### Project Naming Rules

✅ **Valid names:**
- `MyProject`
- `my-project`
- `Project123`
- `my_project`
- `React-NestJS-App`

❌ **Invalid names:**
- `My Project` (spaces not allowed)
- `MyProject!` (special characters except `-` and `_`)
- `123Project` (cannot start with number)

## 🏗️ Project Types

### ⚛️ React Projects
- **Framework**: React 18 + TypeScript + Vite
- **Styling**: Tailwind CSS pre-configured
- **Features**: Hot reload, optimized build, React Router ready
- **Size**: ~1MB template

### 📱 Expo Projects
- **Framework**: Expo + React Native + TypeScript
- **Styling**: NativeWind (Tailwind for React Native)
- **Features**: Hot reload, native debugging, Expo Router ready
- **Size**: ~1MB template

### 🏗️ NestJS Projects
- **Framework**: NestJS + TypeScript
- **Features**: Controllers, services, modules ready
- **Auth**: JWT Authentication pre-configured
- **Database**: TypeORM ready (install separately)
- **Size**: ~1MB template

### 🔄 Fullstack Projects
- **Frontend**: React + TypeScript + Tailwind
- **Backend**: NestJS + TypeScript + Auth
- **Structure**: Separate frontend/backend directories
- **Auto-config**: CORS, environment variables ready

## 🌐 Local NPM Registry

**Verdaccio** eliminates internet downloads for blazing-fast project creation.

### Why It's Amazing
```
🌐 Public NPM Registry:
Internet → npmjs.org → Download → Install (30-180 seconds)

⚡ Local NPM Registry + Template Cache:
Your Computer → localhost:4873 → Template → Ultra-fast (1-5 seconds)
```

### 🚀 **Ultra-Fast Template Technology**

**Smart Dependency Detection:**
- **Template Validation**: Uses `npm ci` for instant validation when `node_modules` exists
- **Package-lock Leverage**: Uses `npm ci` for reproducible, faster installs
- **Fallback Safety**: Falls back to `npm install` if validation fails
- **Zero Redundancy**: Skips installation when dependencies are already present

### Registry Management
```bash
# Start registry (keep running in terminal)
./start-registry.sh

# Check status
curl http://localhost:4873

# Stop registry
pkill -f verdaccio

# Clear cache (nuclear option)
rm -rf verdaccio-storage/
```

## 🚀 Advanced Features

### GitHub Integration

**Automatic Repository Creation:**
- Prompts during project creation
- Choose private or public repository
- Auto-pushes initial commit
- Configures remote origin

**Standalone Repository Creation:**
```bash
# Create GitHub repository for any project
./devmenu.sh → "Create GitHub Repo"
# OR
./github_create.sh

# Select from list of git projects:
# → Shows all projects with git repositories
# → Select project to create GitHub repo for
# → Choose private or public
# → Repository created automatically!
```

**Directory Selection:**
- ✅ **Interactive selection** from all git projects
- ✅ **Shows project types** for easy identification
- ✅ **Validates git repository** before creation
- ✅ **Auto-navigates** to selected project directory

### Project Management

**Open Existing Projects:**
```bash
./devmenu.sh → "Open Project" → Select from list:
# Shows all project types:
# → MyReactApp [React]
# → MyBackend [NestJS]
# → MyFullstack [React + NestJS]  ← Fullstack detected!
# → AnyProject [Project]
```

**Delete Projects Safely:**
```bash
./devmenu.sh → "Delete Project" → Select project → Confirm deletion
```

### Fullstack Project Structure

```
MyProject/
├── frontend/           # React app
│   ├── src/
│   ├── package.json    # Name: "MyProject-frontend"
│   └── ...
├── backend/            # NestJS API
│   ├── src/
│   ├── package.json    # Name: "MyProject-backend"
│   └── ...
└── .env.example        # Environment variables template
```

## ⚙️ Configuration

### Project Location
Projects are created in: `$HOME/Desktop/Development/`

**To change location:**
1. Edit `helpers.sh`
2. Modify `BASE_DIR` variable
3. Update all project paths accordingly

### Editor Integration
- **VSCodium** opens automatically (if installed)
- **VS Code** fallback if Codium not found
- **Terminal instructions** if no editor found

### NPM Registry Settings
```bash
# Use local registry (fast)
npm config set registry http://localhost:4873

# Use public registry (fallback)
npm config set registry https://registry.npmjs.org/
```

## 🔧 Troubleshooting

### Common Issues

**"Rofi not found"**
```bash
# Arch Linux
sudo pacman -S rofi

# Ubuntu/Debian
sudo apt install rofi

# Fedora
sudo dnf install rofi

# openSUSE
sudo zypper install rofi
```

**"Hyprland compatibility"**
- ✅ **Works perfectly** with Hyprland and other Wayland compositors
- ✅ **No additional configuration** needed
- ✅ **Rofi works** with any window manager (X11/Wayland)

**"Permission denied"**
```bash
chmod +x *.sh  # Make all scripts executable
```

**Registry not starting**
```bash
# Kill any existing processes
pkill -f verdaccio

# Clear storage and restart
rm -rf verdaccio-storage/
./start-registry.sh
```

**GitHub integration not working**
```bash
# Install GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo apt update && sudo apt install gh

# Authenticate
gh auth login
```

**Projects not opening in editor**
```bash
# Install VSCodium
sudo apt install codium

# Or install VS Code
sudo apt install code
```

### Debug Mode
```bash
# Run scripts with verbose output
bash -x devmenu.sh

# Check logs
tail -f verdaccio.log
```

## 📁 File Structure

```
├── 🚀 Core Scripts
│   ├── devmenu.sh              # Main menu launcher
│   ├── create_project.sh       # Individual project creation
│   ├── create_fullstack.sh     # Fullstack project creation
│   ├── open_project.sh         # Open existing projects
│   ├── delete_project.sh       # Safe project deletion
│   ├── github_create.sh        # GitHub repository creation
│   ├── helpers.sh              # Shared functions
│   └── setup-fast-projects.sh  # One-time setup
│
├── 🌐 Registry
│   ├── verdaccio.yaml          # Registry configuration
│   ├── start-registry.sh       # Registry launcher
│   └── verdaccio-storage/      # Local package cache
│
├── 📋 Templates
│   ├── react/                  # React + TS + Tailwind
│   ├── expo/                   # Expo + TS + NativeWind
│   └── nestjs/                 # NestJS + TS + Auth
│
└── 🎨 Themes
    ├── devmenu.rasi           # Main menu theme
    ├── devmenu-input.rasi     # Input field theme
    └── devmenu-folder.rasi    # Folder selection theme
```

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch
3. **Make** your changes
4. **Test** thoroughly
5. **Submit** a pull request

### Adding New Project Types
1. Create template in `templates/`
2. Add case in `create_project.sh`
3. Update this README
4. Test thoroughly

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- **Verdaccio** - Local NPM registry
- **Rofi** - Beautiful menu system
- **React/NestJS/Expo teams** - Amazing frameworks

---
