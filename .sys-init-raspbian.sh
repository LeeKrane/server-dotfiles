#!/bin/bash

# -------------------------------------------------------------------------------------------------
# /////////////////////////////////////////////////////////////////////////////////////////////////
# ///////////////////////////////////// *** Definitions *** ///////////////////////////////////////
# /////////////////////////////////////////////////////////////////////////////////////////////////
# -------------------------------------------------------------------------------------------------

NC="\033[0m" # no color
BLUE="\033[1;34m"
GREEN="\033[1;32m"
RED="\033[1;31m"
CLEAR_LINE="\r\033[K"
CLEAR_5_LINES="\033[5A${CLEAR_LINE%K}J"
CLEAR_7_LINES="\033[7A${CLEAR_LINE%K}J"

# Function to display help message
show_help() {
	echo -e "${BLUE}Usage: $0 [options]${NC}"
	echo -e "${BLUE}Options:${NC}"
	echo -e "  -d, --dry-run   Perform a dry run, showing commands without executing them."
	echo -e "  -h, --help      Display this help message."
}

# Check for dry-run / help options
dry_run=false
while [[ $# -gt 0 ]]; do
	case "$1" in
	-d | --dry-run)
		dry_run=true
		shift
		;;
	-h | --help)
		show_help
		exit 0
		;;
	*)
		# Unknown option
		echo -e "${RED}Unknown option: $1${NC}"
		show_help
		exit 1
		;;
	esac
done

# Trap the SIGINT signal (CTRL+C)
trap cleanup INT

# Cleanup function to restore terminal settings
cleanup() {
	stty "$OLD_SETTINGS"
	tput cnorm
	echo -e "\n\n${RED}Script interrupted.${NC}"
	exit 1
}

# Function to display a menu and get user selection
choose_installation_mode() {
	local prompt="Choose installation mode:\n"
	local options=("Partial (default: YES)" "Partial (default: NO)" "Full (do everything)")
	local selected=0
	local num_options=${#options[@]}

	# Hide cursor
	tput civis

	while true; do
		echo -e "${BLUE}$prompt${NC}"
		for i in $(seq 0 $((num_options - 1))); do
			if [ "$i" -eq "$selected" ]; then
				echo -e "${GREEN}> ${options[$i]}${NC}"
			else
				echo "  ${options[$i]}"
			fi
		done

		read -s -n 1 key
		case "$key" in
		A) # Up arrow
			selected=$(((selected - 1 + num_options) % num_options))
			;;
		B) # Down arrow
			selected=$(((selected + 1) % num_options))
			;;
		"") # Enter
			printf $CLEAR_7_LINES
			# Show cursor
			tput cnorm
			echo -e "${BLUE}Chosen installation mode: ${options[$selected]}${NC}"
			echo
			return $selected
			;;
		q) # Quit
			cleanup
			exit 1
			;;
		esac

		printf $CLEAR_5_LINES
	done
}

# Function to display a single checkbox menu and get user selection
choose_single_checkbox() {
	local prompt="$1"
	local checked="$2"

	while true; do
		printf $CLEAR_LINE
		echo -n -e "${GREEN}> [${checked}] $prompt${NC}"

		# Read a single character
		key=$(dd bs=1 count=1 2>/dev/null)

		case "$key" in
		" ") # Space
			if [ "$checked" == " " ]; then
				checked="x"
			else
				checked=" "
			fi
			continue
			;;
		$'\r') # Enter
			printf $CLEAR_LINE
			echo -n "  [${checked}] $prompt"
			if [ "$checked" == "x" ]; then
				return 0
			else
				return 1
			fi
			break
			;;
		q) # Quit
			cleanup
			exit 1
			;;
		esac
	done
}

# Declare an associative array to map variables to prompts
declare -A prompts=(
	[resInitPrograms]="Install initial programs?"
	[resLinkDotfiles]="Link dotfiles?"
	[resProgramInstall]="Install all programs?"
	[resZshInstall]="Install ZSH?"
	[resZshPlugins]="Install ZSH plugins?"
)

# Define an ordered list of keys
ordered_keys=(
	resInitPrograms
	resLinkDotfiles
	resProgramInstall
	resZshInstall
	resZshPlugins
)

# --------------------------------------------------------------------------------------------------
# //////////////////////////////////////////////////////////////////////////////////////////////////
# ////////////////////////////////////// *** Selection *** /////////////////////////////////////////
# //////////////////////////////////////////////////////////////////////////////////////////////////
# --------------------------------------------------------------------------------------------------

if $dry_run; then
	echo -e "${RED}!!! THIS IS JUST A DRY RUN, NOTHING WILL ACTUALLY HAPPEN ON THE MACHINE !!!${NC}"
	echo
	echo
fi

# Save current terminal settings
OLD_SETTINGS=$(stty -g)

echo -e "${BLUE}Always clone the dotfiles repository as ~/.dotfiles"
echo -e "Run this script without sudo. Rebos won't work if this script is run as sudo.${NC}"
echo

echo -e "${BLUE}Press ${GREEN}Enter${BLUE} to confirm or ${GREEN}q${BLUE} to quit:${NC}"
echo

# Choose the installation mode
choose_installation_mode

case "$?" in
0) # partial install with default toggled
	default_checkbox_value="x"
	full_install="n"
	;;
1) # partial install with default untoggled
	default_checkbox_value=" "
	full_install="n"
	;;
2) # full install
	default_checkbox_value="x"
	full_install="y"
	;;
*) # Quit
	cleanup
	exit 1
	;;
esac

# Hide cursor
tput civis
# Disable canonical mode (line buffering) and echoing
stty raw -echo

echo -e "${BLUE}Press ${GREEN}Space${BLUE} to toggle, ${GREEN}Enter${BLUE} to confirm and ${GREEN}q${BLUE} to quit:${NC}"
echo
# Collect user inputs and assign to variables directly
for var in "${ordered_keys[@]}"; do
	if [[ "$full_install" == "y" ]]; then
		eval "$var=y" # Assign 'y' to all variables
	else
		if choose_single_checkbox "${prompts[$var]}" "$default_checkbox_value"; then
			eval "$var=y" # Assign 'y' to the variable
		else
			eval "$var=n" # Assign 'n' to the variable
		fi
		echo
	fi
done

# Restore original terminal settings
stty "$OLD_SETTINGS"
# Show cursor
tput cnorm
echo
echo

# --------------------------------------------------------------------------------------------------
# //////////////////////////////////////////////////////////////////////////////////////////////////
# ///////////////////////////////////// *** Installation *** ///////////////////////////////////////
# //////////////////////////////////////////////////////////////////////////////////////////////////
# --------------------------------------------------------------------------------------------------

# Function to execute commands, respecting dry_run
execute() {
	local command="$1"
	echo -n -e " ${GREEN}>${NC} "
	echo "$command"
	if ! $dry_run; then
		eval "$command"
	fi
}

execute_non_verbose() {
	local command="$1"
	if ! $dry_run; then
		eval "$command"
	fi
}

# initial programs
if [[ "$resInitPrograms" == "y" ]]; then
	echo
	echo -e "${BLUE}Installing initial programs needed for system setup:${NC}"
	execute "sudo apt-get -y install stow"
	echo
else
	echo -e "${GREEN}Skipped initial program installation.${NC}"
fi

# dotfiles
if [[ "$resLinkDotfiles" == "y" ]]; then
	echo
	echo -e "${BLUE}Creating folders for your dotfiles...${NC}"
	execute "mkdir -p $HOME/.config/nvim"
	execute "mkdir -p $HOME/.local/share/nvim"
	echo
	echo
	echo -e "${BLUE}Linking your dotfiles via stow...${NC}"
	execute "cd ~/.server-dotfiles"
	execute "stow --adopt ."
	execute "git reset --hard"
	execute "cd"
	echo
else
	echo -e "${GREEN}Skipped dotfiles linking.${NC}"
fi

# remaining program install
if [[ "$resProgramInstall" == "y" ]]; then
	echo
	echo -e "${BLUE}Installing the remaining system packages:"
	echo
	echo -e "Updating system:${NC}"
	execute "sudo apt-get update"
	execute "sudo apt-get upgrade -y"
	echo
	echo -e "${BLUE}Adding docker repository:${NC}"
	execute "sudo install -m 0755 -d /etc/apt/keyrings"
	execute "sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc"
	execute "sudo chmod a+r /etc/apt/keyrings/docker.asc"
	execute "echo \
		\"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
		\$(. /etc/os-release && echo \"\$VERSION_CODENAME\") stable\" | \
		sudo tee /etc/apt/sources.list.d/docker.list > /dev/null"
	execute "sudo apt-get update"
	echo
	echo -e "${BLUE}Uninstalling old docker:${NC}"
	execute "sudo apt-get remove -y \
		docker.io \
		docker-doc \
		docker-compose \
		podman-docker \
		containerd \
		runc"
	echo
	echo -e "${BLUE}Installing apt packages:${NC}"
	execute "sudo apt-get install -y \
		fzf \
		ncdu \
		ripgrep \
		mc \
		btop \
		tldr \
		thefuck \
		neofetch \
		wireguard-tools \
		snapper \
		nodejs \
		python3-pip \
		docker-ce \
		docker-ce-cli \
		containerd.io \
		docker-buildx-plugin \
		docker-compose-plugin \
		zsh \
		git \
		neovim"
	echo
	echo -e "${BLUE}Installing pip packages:${NC}"
	execute "sudo apt-get install -y \
		python3-toml"
	echo
	echo -e "${BLUE}Installing npm packages:${NC}"
	execute "sudo npm install -g \
		bun \
		yarn \
		pnpm"
	echo
	echo
else
	echo -e "${GREEN}Skipped system package install.${NC}"
fi

if [[ "$resZshInstall" == "y" ]]; then
	echo
	echo -e "${BLUE}Changing default shell to zsh and installing oh-my-zsh...${NC}"
	execute "sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
	echo
else
	echo -e "${GREEN}Skipped ZSH install.${NC}"
fi

if [[ "$resZshPlugins" == "y" ]]; then
	echo
	echo -e "${BLUE}Installing oh-my-zsh plugins...${NC}"
	execute "cd"
	execute "sudo rm -rf $ZSH_CUSTOM/plugins/zsh-autosuggestions && sudo git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions"
	execute "sudo rm -rf $ZSH_CUSTOM/plugins/zsh-syntax-highlighting && sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
	execute "sudo rm -rf $ZSH_CUSTOM/themes/powerlevel10k && sudo git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k"
	echo
else
	echo -e "${GREEN}Skipped ZSH install.${NC}"
fi

if [[ "$resZshInstall" == "y" ]] || [[ "$resZshPlugins" == "y" ]]; then
	echo
	echo -e "${BLUE}Replacing automatically overwritten .zshrc file with that from dotfiles...${NC}"
	execute "touch $HOME/.server-dotfiles/.krane-rc/bash/local-paths"
	execute "touch $HOME/.server-dotfiles/.krane-rc/zsh/local-paths"
	execute "rm $HOME/.zshrc"
	execute "cd $HOME/.server-dotfiles/"
	execute "stow ."
	echo
else
	echo -e "${GREEN}Skipped .zshrc fixup.${NC}"
fi

echo
echo -e "Exiting...${NC}"

