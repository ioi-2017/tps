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

# Making sure important variables exist if not already defined
#
# $USER is defined by login(1) which is not always executed (e.g. containers)
# POSIX: https://pubs.opengroup.org/onlinepubs/009695299/utilities/id.html
USER="${USER:-$(id -u -n)}"
# $HOME is defined at the time of login, but it could be unset. If it is unset,
# a tilde by itself (~) will not be expanded to the current user's home directory.
# POSIX: https://pubs.opengroup.org/onlinepubs/009696899/basedefs/xbd_chap08.html#tag_08_03
HOME="${HOME:-$(getent passwd $USER 2> "/dev/null" | cut -d: -f6)}"
# macOS does not have getent, but this works even if $HOME is unset
HOME="${HOME:-$(eval echo ~$USER)}"

# Directory to store TPS code repository in
TPS_LOCAL_REPO="${TPS_LOCAL_REPO:-$HOME/.local/share/tps}"

TPS_REMOTE_REPO_GIT_URL="${TPS_REMOTE_REPO_GIT_URL:-https://github.com/ioi-2017/tps.git}"
TPS_REMOTE_BRANCH="${TPS_REMOTE_BRANCH:-master}"

function command_exists {
	command -v "$@" &> "/dev/null"
}

function fmt_error {
	printf "Error: %s\n" "$*" >&2
}

function user_can_sudo {
	# Checking if sudo is installed
	command_exists "sudo" || return 1
	# The following command has 3 parts:
	#
	# 1. Runs `sudo` with `-v`. Does the following:
	#    • with privilege: asks for a password immediately.
	#    • without privilege: exits with error code 1 and prints the message:
	#      Sorry, user <username> may not run sudo on <hostname>
	#
	# 2. Passes `-n` to `sudo` to tell it to not ask for a password. If the
	#    password is not required, the command will finish with exit code 0.
	#    If one is required, sudo will exit with error code 1 and print the
	#    message:
	#    sudo: a password is required
	#
	# 3. Checks for the words "may not run sudo" in the output to really tell
	#    whether the user has privileges or not. For that we have to make sure
	#    to run `sudo` in the default locale (with `LANG=`) so that the message
	#    stays consistent regardless of the user's locale.
	#
	! LANG= sudo -n -v 2>&1 | grep -q "may not run sudo"
}


function clone_tps {
	# Preventing the cloned repository from having insecure permissions. Failing to do
	# so causes compinit() calls to fail with "command not found: compdef" errors
	# for users with insecure umasks (e.g., "002", allowing group writability). Note
	# that this will be ignored under Cygwin by default, as Windows ACLs take
	# precedence over umasks except for filesystems mounted with option "noacl".
	umask g-w,o-w

	echo -n " ########################## "
	echo -n "Cloning TPS Repo to ${TPS_LOCAL_REPO}..."
	echo -n " ########################## "
	echo

	command_exists "git" || {
		fmt_error "git is not installed"
		exit 1
	}

	ostype=$(uname)
	if [ -z "${ostype%CYGWIN*}" ] && git --version | grep -q msysgit; then
		fmt_error "Windows/MSYS Git is not supported on Cygwin. Make sure the" \
			"Cygwin git package is installed and is first on the \$PATH"
		exit 1
	fi

	# Manual cloning with git config options to support git < v1.7.2
	mkdir -p "${TPS_LOCAL_REPO}"
	git init --quiet "${TPS_LOCAL_REPO}" && cd "${TPS_LOCAL_REPO}" \
	&& git config core.eol lf \
	&& git config core.autocrlf false \
	&& git config fsck.zeroPaddedFilemode ignore \
	&& git config fetch.fsck.zeroPaddedFilemode ignore \
	&& git config receive.fsck.zeroPaddedFilemode ignore \
	&& git config tps.remote origin \
	&& git config tps.branch "${TPS_REMOTE_BRANCH}" \
	&& git remote add origin "${TPS_REMOTE_REPO_GIT_URL}" \
	&& git fetch --depth=1 origin \
	&& git checkout -b "${TPS_REMOTE_BRANCH}" "origin/${TPS_REMOTE_BRANCH}" || {
		[ ! -d "${TPS_LOCAL_REPO}" ] || {
			cd -
			rm -rf "${TPS_LOCAL_REPO}" 2> "/dev/null"
		}
		fmt_error "git clone of tps repo failed"
		exit 1
	}
	# Exiting installation directory
	cd - > "/dev/null"

	echo
}

function setup_tps {
	echo -n " ########################## "
	echo -n "Installing TPS system-wide"
	echo -n " ########################## "
	echo
	
	cd "${TPS_LOCAL_REPO}"

	install_exit_code=0
	if user_can_sudo; then
		echo "You might need to enter your password for installation."
		sudo -k bash "install-tps.sh" || install_exit_code=$?
	else
		bash "install-tps.sh" || install_exit_code=$?
	fi 

	# Checking if installation was successful
	if [ "${install_exit_code}" -ne "0" ]; then
		fmt_error "Installation failed."
		exit 1
	fi

	cd - > "/dev/null"
}

function main {
	if [ -d "${TPS_LOCAL_REPO}" ]; then
		echo "The \$TPS_LOCAL_REPO folder already exists (${TPS_LOCAL_REPO}). You need to remove it if you want to reinstall."
		exit 1
	fi

	clone_tps
	setup_tps

	echo "TPS installed successfully. Run \"tps\" to try it out. You might need to reload your shell to get everything working."
}

main "$@"
