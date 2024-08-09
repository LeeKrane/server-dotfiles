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
sudo dnf -y install stow cargo
echo
echo

# dotfiles
echo -e "${BLUE}Creating folders for your dotfiles...${NC}"
mkdir $HOME/.config/nvim
mkdir $HOME/.local/share/nvim
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

# important repositories and keys for rebos
echo -e "${BLUE}Adding needed dnf repositories, copr repositories and rpm keys:${NC}"
# terra
sudo dnf -y config-manager --add-repo https://github.com/terrapkg/subatomic-repos/raw/main/terra.repo
sudo dnf -y --refresh upgrade
sudo dnf -y install terra-release

# docker
sudo dnf -y config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf -y --refresh upgrade
#sudo usermod -a -G docker krane

# lazygit
sudo dnf -y copr enable atim/lazygit

echo
echo

# rebos for remaining programs
echo -e "${BLUE}Installing Rebos for the remaining system packages:${NC}"
cargo install rebos
echo "export PATH='/home/$USER/.cargo/bin/:$PATH'" >.krane-rc/bash/local-paths
echo "path=('/home/$USER/.cargo/bin/' '/home/$USER/.local/bin/' $path)" >.krane-rc/zsh/local-paths
echo "export PATH" >>.krane-rc/zsh/local-paths
source ~/.bashrc
echo
echo -e "${BLUE}Installing the remaining system packages via Rebos:${NC}"
rebos setup
rebos config init
rebos gen commit "[sys-init] automatic initial base system configuration"
rebos gen current build
echo
echo
echo -e "${BLUE}Changing default shell to zsh and installing oh-my-zsh...${NC}"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo
echo
echo -e "${BLUE}Installing oh-my-zsh plugins...${NC}"
cd
sudo git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
sudo git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
echo
echo
echo -e "${BLUE}Replacing automatically overwritten .zshrc file with that from dotfiles...${NC}"
rm $HOME/.zshrc
cd $HOME/.dotfiles/
stow .
echo
echo
echo -e "${BLUE}System initialization is complete!"
echo -e "Exiting...${NC}"
