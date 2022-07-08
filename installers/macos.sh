#!/usr/bin/env bash

# Get the path to this script, so that we can correctly find relevant
# dotfiles.
#
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
CONFIG_PATH="$(dirname "$SCRIPT_PATH")/../"

# Get Xcode and associated tools installed.
#
xcode-select --install
read -p "Press any key once Xcode has finished installing... " -n1 -s

# Make sure that Rosetta is installed.
#
sudo softwareupdate --install-rosetta
read -p "Press any key once Rosetta has finished installing... " -n1 -s

# Install Homebrew. See:
#
#     https://brew.sh/
#
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to our path.
#
eval "$(/opt/homebrew/bin/brew shellenv)"

# Disable Homebrew analytics.
#
brew analytics off

# Add the cask-drivers tap to Homebrew.
#
brew tap homebrew/cask-drivers

# Install new applications.
#
brew install \
adobe-creative-cloud \
aircrack-ng \
amethyst \
apktool \
asciinema \
awscli \
awscurl \
azure-cli \
brave-browser \
burp-suite \
coreutils \
diffutils \
discord \
expect \
ffmpeg \
ffuf \
firefox \
free-gpgmail \
ghidra \
go \
gobuster \
google-cloud-sdk \
gpg-suite-no-mail \
graphicsmagick \
graphviz \
hashcat \
hydra \
insomnia \
insync \
john-jumbo \
jq \
keepassxc \
keybase \
lagrange \
libqalculate \
little-snitch \
logitech-options \
logitech-unifying \
macx-dvd-ripper-pro \
malwarebytes \
mediahuman-audio-converter \
metasploit \
microsoft-excel \
microsoft-powerpoint \
microsoft-remote-desktop \
microsoft-word \
mingw-w64 \
nano \
netcat \
ngrok \
nikto \
nmap \
node \
obsidian \
optipng \
poppler \
postman \
powershell \
radamsa \
radicle-upstream \
remarkable \
ripgrep \
rlwrap \
roam-research \
ruby
rust \
safe-multisig \
semgrep \
signal \
slack \
slowhttptest \
socat \
sqlmap \
temurin \
testssl \
virtualenv \
viscosity \
visual-studio-code \
webp \
xld \
ykman \
youtube-dl \
zoom

# Wireshark is available through Homebrew as both a formula and a cask.
# We want the cask version (the macOS "native" app).
#
brew install --cask wireshark

# Install a better Zsh configuration.
#
curl -L -o $HOME/.zshrc "https://git.grml.org/?p=grml-etc-core.git;a=blob_plain;f=etc/zsh/zshrc;hb=HEAD"
curl -L -o $HOME/.zshrc.local "https://git.grml.org/?p=grml-etc-core.git;a=blob_plain;f=etc/skel/.zshrc;hb=HEAD"

cat >> $HOME/.zshrc.local << EOF

# Prefix the GRML prompt when in an active virtualenv.
#
function virtual_env_prompt () {
	REPLY=\${VIRTUAL_ENV+(\${VIRTUAL_ENV:t}) }
}
grml_theme_add_token virtual-env -f virtual_env_prompt '%F{magenta}' '%f'
zstyle ':prompt:grml:left:setup' items rc virtual-env change-root user at host path vcs percent
EOF

# Local SSH config.
#
mkdir -p $HOME/.ssh
cat > $HOME/.ssh/config << EOF
# Defaults
#
Host *
	Compression  yes
	ForwardAgent no
	IdentityFile ~/.ssh/id_ed25519
EOF
chmod 700 $HOME/.ssh
chmod 600 $HOME/.ssh/*

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.local/{bin,share}

cp    $CONFIG_PATH/user/local/bin/update.sh        $HOME/.local/bin/update.sh
cp    $CONFIG_PATH/user/local/bin/update-system.sh $HOME/.local/bin/update-system.sh
cp -r $CONFIG_PATH/user/local/share/red-team       $HOME/.local/share/red-team
cp    $CONFIG_PATH/user/zinit                      $HOME/.zinit
cp    $CONFIG_PATH/user/zprofile                   $HOME/.zprofile
cp    $CONFIG_PATH/user/zshenv                     $HOME/.zshenv

chmod 755 $HOME/.local/bin/*

# Pre-create Insync directories.
#
mkdir -p $HOME/Google/{cardboard-iguana,personal,yakcollective}

# Restore all git repos.
#
mkdir $HOME/Repos
(
	git config --global user.name "Nathan Acks"
	git config --global user.email nathan.acks@cardboard-iguana.com
#	git config --global user.signingKey "$(gpg --list-keys nathan.acks@cardboard-iguana.com | grep -E "^      [0-9A-Z]{40}$" | sed -e "s/^ *//")"
	git config --global commit.gpgSign true
	git config --global pull.rebase false
	cd $HOME/Repos
	git clone git@github.com:necopinus/backups.git
	mv backups backups-necopinus
	git clone git@github.com:The-Yak-Collective/backups.git
	mv backups backups-yakcollective
	git clone git@github.com:necopinus/cardboard-iguana.com.git
	git clone git@github.com:necopinus/chateaumaxmin.info.git
	git clone git@github.com:necopinus/delphi-strategy.com.git
	git clone git@github.com:necopinus/digital-orrery.com.git
	git clone git@github.com:necopinus/dotfiles.git
	git clone git@github.com:necopinus/ecopunk.info.git
	git clone git@github.com:necopinus/ellen-and-nathan.info.git
	git clone git@github.com:The-Yak-Collective/infrastructure-map.git
	git clone git@github.com:The-Yak-Collective/lunchtime-tickets.git
	git clone git@github.com:necopinus/necopinus.xyz.git
	git clone git@github.com:The-Yak-Collective/onboarding_robot.git
	git clone git@github.com:The-Yak-Collective/project_ui.git
	git clone git@github.com:necopinus/resume.git
	git clone https://github.com/danielmiessler/SecLists.git
	git clone git@github.com:necopinus/website-theme.git
	git clone git@github.com:The-Yak-Collective/yakcollective.git
	git clone git@github.com:necopinus/zibaldone.git
)

# Uncompress rockyou.txt.
#
mkdir -p $HOME/.local/share/red-team/wordlists
(
	cd $HOME/.local/share/red-team/wordlists
	cp $HOME/Repos/SecLists/Passwords/Leaked-Databases/rockyou.txt.tar.gz .
	tar -xzvf rockyou.txt.tar.gz
	rm rockyou.txt.tar.gz
)

# Finis.
#
echo "A reboot is required for some features to become available."
