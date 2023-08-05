#!/usr/bin/env bash

# Get local version.
#
if [[ -f $HOME/.cache/versions/ligolo ]]; then
	LOCAL_VERSION="$(cat $HOME/.cache/versions/ligolo)"
else
	LOCAL_VERSION="XXX"
fi

# Determine architecture.
#
if [[ "$(uname -m)" == "aarch64" ]]; then
	ARCH="arm64"
else
	ARCH="amd64"
fi

# Get remote version.
#
REMOTE_VERSION="$(curl -L -s https://api.github.com/repos/nicocha30/ligolo-ng/releases/latest | grep -Po '"tag_name": ?"v\K.*?(?=")')"

# Install/update if there is a new version.
#
if [[ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]]; then
	BUILD_DIR="$(mktemp -d)"
	(
		cd "$BUILD_DIR"
		curl -L -O https://github.com/nicocha30/ligolo-ng/releases/download/v${REMOTE_VERSION}/ligolo-ng_proxy_${REMOTE_VERSION}_linux_${ARCH}.tar.gz
		mkdir -p $HOME/.local/bin
		tar -xzf ligolo-ng_proxy_${REMOTE_VERSION}_linux_${ARCH}.tar.gz -C $HOME/.local/bin proxy
		chmod +x $HOME/.local/bin/proxy

		curl -L -O https://github.com/nicocha30/ligolo-ng/releases/download/v${REMOTE_VERSION}/ligolo-ng_agent_${REMOTE_VERSION}_linux_amd64.tar.gz
		curl -L -O https://github.com/nicocha30/ligolo-ng/releases/download/v${REMOTE_VERSION}/ligolo-ng_agent_${REMOTE_VERSION}_linux_arm64.tar.gz
		curl -L -O https://github.com/nicocha30/ligolo-ng/releases/download/v${REMOTE_VERSION}/ligolo-ng_agent_${REMOTE_VERSION}_linux_armv7.tar.gz
		curl -L -O https://github.com/nicocha30/ligolo-ng/releases/download/v${REMOTE_VERSION}/ligolo-ng_agent_${REMOTE_VERSION}_linux_armv6.tar.gz
		mkdir -p $HOME/.local/share/red-team/tools/linux
		tar -xzf ligolo-ng_agent_${REMOTE_VERSION}_linux_amd64.tar.gz -C $HOME/.local/share/red-team/tools/linux agent
		mv -f $HOME/.local/share/red-team/tools/linux/agent $HOME/.local/share/red-team/tools/linux/agent_x86-64
		tar -xzf ligolo-ng_agent_${REMOTE_VERSION}_linux_arm64.tar.gz -C $HOME/.local/share/red-team/tools/linux agent
		mv -f $HOME/.local/share/red-team/tools/linux/agent $HOME/.local/share/red-team/tools/linux/agent_aarch64
		tar -xzf ligolo-ng_agent_${REMOTE_VERSION}_linux_armv7.tar.gz -C $HOME/.local/share/red-team/tools/linux agent
		mv -f $HOME/.local/share/red-team/tools/linux/agent $HOME/.local/share/red-team/tools/linux/agent_armv7
		tar -xzf ligolo-ng_agent_${REMOTE_VERSION}_linux_armv6.tar.gz -C $HOME/.local/share/red-team/tools/linux agent
		mv -f $HOME/.local/share/red-team/tools/linux/agent $HOME/.local/share/red-team/tools/linux/agent_armv6
		chmod +x $HOME/.local/share/red-team/tools/linux/agent_*

		curl -L -O https://github.com/nicocha30/ligolo-ng/releases/download/v${REMOTE_VERSION}/ligolo-ng_agent_${REMOTE_VERSION}_darwin_arm64.tar.gz
		curl -L -O https://github.com/nicocha30/ligolo-ng/releases/download/v${REMOTE_VERSION}/ligolo-ng_agent_${REMOTE_VERSION}_darwin_amd64.tar.gz
		mkdir -p $HOME/.local/share/red-team/tools/macos
		tar -xzf ligolo-ng_agent_${REMOTE_VERSION}_darwin_arm64.tar.gz -C $HOME/.local/share/red-team/tools/macos agent
		mv -f $HOME/.local/share/red-team/tools/macos/agent $HOME/.local/share/red-team/tools/macos/agent_aarch64
		tar -xzf ligolo-ng_agent_${REMOTE_VERSION}_darwin_amd64.tar.gz -C $HOME/.local/share/red-team/tools/macos agent
		mv -f $HOME/.local/share/red-team/tools/macos/agent $HOME/.local/share/red-team/tools/macos/agent_x86-64
		chmod +x $HOME/.local/share/red-team/tools/macos/agent_*

		curl -L -O https://github.com/nicocha30/ligolo-ng/releases/download/v${REMOTE_VERSION}/ligolo-ng_agent_${REMOTE_VERSION}_windows_amd64.zip
		curl -L -O https://github.com/nicocha30/ligolo-ng/releases/download/v${REMOTE_VERSION}/ligolo-ng_agent_${REMOTE_VERSION}_windows_arm64.zip
		curl -L -O https://github.com/nicocha30/ligolo-ng/releases/download/v${REMOTE_VERSION}/ligolo-ng_agent_${REMOTE_VERSION}_windows_armv7.zip
		curl -L -O https://github.com/nicocha30/ligolo-ng/releases/download/v${REMOTE_VERSION}/ligolo-ng_agent_${REMOTE_VERSION}_windows_armv6.zip
		mkdir -p $HOME/.local/share/red-team/tools/windows
		unzip ligolo-ng_agent_${REMOTE_VERSION}_windows_amd64.zip agent.exe -d $HOME/.local/share/red-team/tools/windows
		mv -f $HOME/.local/share/red-team/tools/windows/agent.exe $HOME/.local/share/red-team/tools/windows/agent_x86-64.exe
		unzip ligolo-ng_agent_${REMOTE_VERSION}_windows_arm64.zip agent.exe -d $HOME/.local/share/red-team/tools/windows
		mv -f $HOME/.local/share/red-team/tools/windows/agent.exe $HOME/.local/share/red-team/tools/windows/agent_aarch64.exe
		unzip ligolo-ng_agent_${REMOTE_VERSION}_windows_armv7.zip agent.exe -d $HOME/.local/share/red-team/tools/windows
		mv -f $HOME/.local/share/red-team/tools/windows/agent.exe $HOME/.local/share/red-team/tools/windows/agent_armv7.exe
		unzip ligolo-ng_agent_${REMOTE_VERSION}_windows_armv6.zip agent.exe -d $HOME/.local/share/red-team/tools/windows
		mv -f $HOME/.local/share/red-team/tools/windows/agent.exe $HOME/.local/share/red-team/tools/windows/agent_armv6.exe
		chmod +x $HOME/.local/share/red-team/tools/windows/agent_*.exe

		mkdir -p $HOME/.cache/versions
		echo "$REMOTE_VERSION" > $HOME/.cache/versions/ligolo
	)
	rm -rf "$BUILD_DIR"
else
	echo "Ligolo-ng is already at v${REMOTE_VERSION}"
	touch $HOME/.cache/versions/ligolo
fi
