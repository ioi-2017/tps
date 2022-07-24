#!/bin/bash
#
# Adopted from oh-my-zsh standalone installation script which is licensed under MIT License.
#
# This script should be run via curl:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/ioi-2017/tps/master/online-installer/install.sh)"
# or via wget:
#   bash -c "$(wget -qO- https://raw.githubusercontent.com/ioi-2017/tps/master/online-installer/install.sh)"
# or via fetch:
#   bash -c "$(fetch -o - https://raw.githubusercontent.com/ioi-2017/tps/master/online-installer/install.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget https://raw.githubusercontent.com/ioi-2017/tps/master/online-installer/install.sh
#   bash online-installer/install.sh

set -euo pipefail

# Make sure important variables exist if not already defined
#
# $USER is defined by login(1) which is not always executed (e.g. containers)
# POSIX: https://pubs.opengroup.org/onlinepubs/009695299/utilities/id.html
USER=${USER:-$(id -u -n)}
# $HOME is defined at the time of login, but it could be unset. If it is unset,
# a tilde by itself (~) will not be expanded to the current user's home directory.
# POSIX: https://pubs.opengroup.org/onlinepubs/009696899/basedefs/xbd_chap08.html#tag_08_03
HOME="${HOME:-$(getent passwd $USER 2> "/dev/null" | cut -d: -f6)}"
# macOS does not have getent, but this works even if $HOME is unset
HOME="${HOME:-$(eval echo ~$USER)}"

# Directory of TPS code repository
TPS="${TPS:-$HOME/.local/share/tps}"

# Tps cli file path. It will be a symlink from the code repository and the directory should be added to the path.
TPS_BIN="${TPS_BIN:-$HOME/.local/bin/tps}"
REPO=${REPO:-ioi-2017/tps}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-master}

command_exists() {
	command -v "$@" >/dev/null 2>&1
}

fmt_error() {
	printf "Error: %s\n" "$*" >&2
}

clone_tps() {
	# Prevent the cloned repository from having insecure permissions. Failing to do
	# so causes compinit() calls to fail with "command not found: compdef" errors
	# for users with insecure umasks (e.g., "002", allowing group writability). Note
	# that this will be ignored under Cygwin by default, as Windows ACLs take
	# precedence over umasks except for filesystems mounted with option "noacl".
	umask g-w,o-w

	echo -n " ########################## "
	echo -n "Cloning TPS..."
	echo -n " ########################## "
	echo

	command_exists git || {
		fmt_error "git is not installed"
		exit 1
	}

	ostype=$(uname)
	if [ -z "${ostype%CYGWIN*}" ] && git --version | grep -q msysgit; then
		fmt_error "Windows/MSYS Git is not supported on Cygwin"
		fmt_error "Make sure the Cygwin git package is installed and is first on the \$PATH"
		exit 1
	fi

	# Manual clone with git config options to support git < v1.7.2
	mkdir -p "$TPS"
	git init --quiet "$TPS" && cd "$TPS" \
	&& git config core.eol lf \
	&& git config core.autocrlf false \
	&& git config fsck.zeroPaddedFilemode ignore \
	&& git config fetch.fsck.zeroPaddedFilemode ignore \
	&& git config receive.fsck.zeroPaddedFilemode ignore \
	&& git config tps.remote origin \
	&& git config tps.branch "$BRANCH" \
	&& git remote add origin "$REMOTE" \
	&& git fetch --depth=1 origin \
	&& git checkout -b "$BRANCH" "origin/$BRANCH" || {
		[ ! -d "$TPS" ] || {
			cd -
			rm -rf "$TPS" 2> "/dev/null"
		}
		fmt_error "git clone of tps repo failed"
		exit 1
	}
	# Exit installation directory
	cd -

	echo
}

setup_tps() {
	echo -n " ########################## "
	echo -n "Setting up TPS"
	echo -n " ########################## "
	echo

	TPS_BIN_DIR=$(dirname "$TPS_BIN")
	mkdir -p "$TPS_BIN_DIR"

	ln -s "$TPS/tps.sh" "$TPS_BIN"
	chmod +x "$TPS_BIN"

	echo "Installed TPS at $TPS_BIN"

	command_exists tps || {
		echo "\"$TPS_BIN_DIR\" is not in \$PATH. Adding to \$PATH for bash and zsh." \
			"If your shell is different, add the following to your shell config:"
		echo "export PATH=\"\$PATH:$TPS_BIN_DIR\""
		echo "Please restart your shell to be able to run tps"
		echo

		for CONFIG_DIR in ".profile" ".bash_profile" ".zprofile" ".zshrc" ".bashrc"; do
			echo "export PATH=\"\$PATH:$TPS_BIN_DIR\"" >> "$HOME/$CONFIG_DIR"
		done
	}

	for CONFIG_DIR in ".profile" ".bash_profile" ".zprofile" ".zshrc" ".bashrc"; do
		echo "export TPS=\"$TPS\"" >> "$HOME/$CONFIG_DIR"
	done

	BC_FILE="$TPS/tps.bash_completion.sh"

	echo "Adding bash completion file \"$BC_FILE\" to \"~/.bashrc\" to load on bash startup." 
	echo ". \"$BC_FILE\"" >> "$HOME/.bashrc"
}

main() {
	!(command_exists tps) || {
		fmt_error "tps is installed in $(command -v tps). You need to remove it if you want to reinstall."
		exit 1
	}

	if [ -d "$TPS" ]; then
		echo "The \$TPS folder already exists ($TPS). You need to remove it if you want to reinstall."
		exit 1
	fi

	clone_tps
	setup_tps

	echo "TPS installed successfully. Run \"tps\" to try it out. You might need to reload your shell to get everything working."
}

main "$@"
