#!/usr/bin/env bash

# Get the path to this script, so that we can correctly find relevant
# dotfiles.
#
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
CONFIG_PATH="$(dirname "$SCRIPT_PATH")/../"

# Make sure that XCode command line tools are installed. See:
#
#     https://gist.github.com/phuctm97/946b5ced8cbfabc2f34e489c447456b1
#
xcode-select --install
until $(xcode-select --print-path &> /dev/null); do
	echo -n "."
	sleep 5;
done
echo ""

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
brave-browser \
coreutils \
diffutils \
discord \
electric-sheep \
exiftool \
ffmpeg \
git \
gnu-sed \
google-chrome \
gpg-suite-no-mail \
graphicsmagick \
graphviz \
insync \
jq \
logi-options-plus \
logitech-unifying \
macx-dvd-ripper-pro \
malwarebytes \
mediahuman-audio-converter \
microsoft-teams \
nano \
node \
obsidian \
optipng \
qflipper \
raspberry-pi-imager \
readwise-ibooks \
remarkable \
ruby \
signal \
virtualenv \
visual-studio-code \
vlc \
vpn-by-google-one \
webp \
xld \
yubico-yubikey-manager \
youtube-dl \
zoom

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

# Local SSH config. Note macOS-specific graffiti:
#
#     https://developer.apple.com/library/archive/technotes/tn2449/_index.html
#
mkdir -p $HOME/.ssh
ssh-keygen -C "nathan.acks@cardboard-iguana.com $(date "+%Y-%m-%d")" -t ed25519
cat > $HOME/.ssh/config << EOF
# Defaults
#
Host *
	AddKeysToAgent yes
	Compression    yes
	ForwardAgent   no
	IdentityFile   ~/.ssh/id_ed25519
	UseKeychain    yes
EOF
chmod 700 $HOME/.ssh
chmod 600 $HOME/.ssh/*
ssh-add
echo ""
echo "Add this SSH key to GitHub before continuing!"
read -p "Press any key to continue... " -n1 -s

# Some apps expect ~/.config to already exist.
#
mkdir -p $HOME/.config

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.local/bin

cp $CONFIG_PATH/user/local/bin/update.sh        $HOME/.local/bin/update.sh
cp $CONFIG_PATH/user/local/bin/update-system.sh $HOME/.local/bin/update-system.sh
cp $CONFIG_PATH/user/zinit                      $HOME/.zinit
cp $CONFIG_PATH/user/zprofile                   $HOME/.zprofile
cp $CONFIG_PATH/user/zshenv                     $HOME/.zshenv

chmod 755 $HOME/.local/bin/*

# Pre-create Insync directories.
#
mkdir -p $HOME/Google/{"Cardboard Iguana",Personal,"Yak Collective"}

# Generate new GPG key.
#
echo ""
echo "Create a GPG key for this device. Use the following settings:"
echo ""
echo ""
echo "    * When asked what kind of key you want to use, choose \"(9) ECC and"
echo "      ECC\"."
echo "    * When asked what kind of elliptic curve you want to use, choose \"(1)"
echo "      Curve 25519\"."
echo "    * When asked how long this key should be valid for, choose echo \"0\" (e.g.,"
echo "      \"key does not expire\")."
echo "    * Real name is \"Nathan Acks\", email address is"
echo "      \"nathan.acks@cardboard-iguana.com\", and the comment is today's date"
echo "      in YYYY-MM-DD format."
echo ""
gpg --expert --full-generate-key
echo ""
echo "Add this GPG key to GitHub before continuing!"
read -p "Press any key to continue... " -n1 -s

# Restore all git repos.
#
mkdir $HOME/Repos
(
	git config --global user.name "Nathan Acks"
	git config --global user.email nathan.acks@cardboard-iguana.com
	git config --global user.signingKey "$(gpg --list-keys nathan.acks@cardboard-iguana.com | grep -E "^      [0-9A-Z]{40}$" | sed -e "s/^ *//")"
	git config --global commit.gpgSign true
	git config --global pull.rebase false
	cd $HOME/Repos
	git clone git@github.com:necopinus/backups.git
	mv backups backups-necopinus
	git clone git@github.com:The-Yak-Collective/backups.git
	mv backups backups-yakcollective
	git clone git@github.com:cardboard-iguana/cardboard-iguana.com.git
	git clone git@github.com:necopinus/chateaumaxmin.info.git
	git clone git@github.com:necopinus/delphi-strategy.com.git
	git clone git@github.com:necopinus/digital-orrery.com.git
	git clone git@github.com:necopinus/dotfiles.git
	git clone git@github.com:necopinus/essays.git
	git clone git@github.com:cardboard-iguana/hacking-notes.git
	git clone git@github.com:The-Yak-Collective/infrastructure-map.git
	git clone git@github.com:The-Yak-Collective/lunchtime-tickets.git
	git clone git@github.com:necopinus/necopinus.xyz.git
	git clone git@github.com:necopinus/newsletters.git
	git clone git@github.com:necopinus/resume.git
	git clone https://github.com/timhutton/twitter-archive-parser.git
	git clone git@github.com:necopinus/website-theme.git
	git clone git@github.com:The-Yak-Collective/yakcollective.git
)

# Finis.
#
echo "A reboot is required for some features to become available."
