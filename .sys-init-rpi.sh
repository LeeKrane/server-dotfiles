#!/bin/bash

NC="\033[0m"
BLUE="\033[1;34m"
GREEN="\033[1;32m"

echo -e "${BLUE}Always clone the dotfiles repository as ~/.server-dotfiles"
echo -e "Run this script without sudo. Rebos won't work if this script is run as sudo.${NC}"
echo
echo

# initial programs
echo -e "${BLUE}Installing initial programs needed for system setup:${NC}"
sudo apt-get install -y stow
echo
echo

# dotfiles
echo -e "${BLUE}Creating folders for your dotfiles...${NC}"
mkdir -p $HOME/.config/nvim
mkdir -p $HOME/.local/share/nvim
echo
echo
echo -e "${BLUE}Linking your dotfiles via stow...${NC}"
cd ~/.server-dotfiles
stow --adopt .
git reset --hard
source ~/.bashrc
cd
echo
echo

# rebos for remaining programs
echo -e "${BLUE}Installing remaining packages..."
echo
echo -e "Installing apt packages:${NC}"
sudo apt-get install -y \
	fzf \
	ncdu \
	exa \
	bat \
	ripgrep \
	zoxide \
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
	neovim

echo
echo -e "${BLUE}Installing pip packages:${NC}"
sudo apt-get install -y \
	python3-toml

echo
echo -e "${BLUE}Installing npm packages:${NC}"
sudo npm install -g \
	bun \
	yarn \
	pnpm

echo
echo

# ZSH and BASH config
echo -e "${BLUE}Changing default shell to zsh and installing oh-my-zsh...${NC}"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo
echo
echo -e "${BLUE}Installing oh-my-zsh plugins...${NC}"
cd
sudo rm -rf $ZSH_CUSTOM/plugins/zsh-autosuggestions
sudo git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
sudo rm -rf $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
sudo rm -rf $ZSH_CUSTOM/themes/powerlevel10k
sudo git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
echo
echo
echo -e "${BLUE}Replacing automatically overwritten .zshrc file with that from dotfiles...${NC}"
touch $HOME/.server-dotfiles/.krane-rc/bash/local-paths
touch $HOME/.server-dotfiles/.krane-rc/zsh/local-paths
rm $HOME/.zshrc
cd $HOME/.server-dotfiles/
stow .
echo
echo
echo -e "${BLUE}System initialization is complete!"
echo -e "Exiting...${NC}"
