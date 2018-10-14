#!/usr/bin/env bash
#       _                 _
#   ___(_)_ __ ___  _ __ | | ___
#  / __| | '_ ` _ \| '_ \| |/ _ \
#  \__ \ | | | | | | |_) | |  __/
#  |___/_|_| |_| |_| .__/|_|\___|
#                  |_|
#
# Boilerplate for creating a simple bash script with some basic strictness
# checks and help features.
#
# Usage:
#   bash-simple argument
#
# Depends on:
#  list
#  of
#  programs
#  expected
#  in
#  environment
#
# Bash Boilerplate: https://github.com/alphabetum/bash-boilerplate
#
# Copyright (c) 2015 William Melody • hi@williammelody.com

# Notes #######################################################################

# Extensive descriptions are included for easy reference.
#
# Explicitness and clarity are generally preferable, especially since bash can
# be difficult to read. This leads to noisier, longer code, but should be
# easier to maintain. As a result, some general design preferences:
#
# - Use leading underscores on internal variable and function names in order
#   to avoid name collisions. For unintentionally global variables defined
#   without `local`, such as those defined outside of a function or
#   automatically through a `for` loop, prefix with double underscores.
# - Always use braces when referencing variables, preferring `NAME` instead
#   of `NAME`. Braces are only required for variable references in some cases,
#   but the cognitive overhead involved in keeping track of which cases require
#   braces can be reduced by simply always using them.
# - Prefer `printf` over `echo`. For more information, see:
#   http://unix.stackexchange.com/a/65819
# - Prefer `_explicit_variable_name` over names like `var`.
# - Use the `#!/usr/bin/env bash` shebang in order to run the preferred
#   Bash version rather than hard-coding a `bash` executable path.
# - Prefer splitting statements across multiple lines rather than writing
#   one-liners.
# - Group related code into sections with large, easily scannable headers.
# - Describe behavior in comments as much as possible, assuming the reader is
#   a programmer familiar with the shell, but not necessarily experienced
#   writing shell scripts.

###############################################################################
# Strict Mode
###############################################################################

# Treat unset variables and parameters other than the special parameters ‘@’ or
# ‘*’ as an error when performing parameter expansion. An 'unbound variable'
# error message will be written to the standard error, and a non-interactive
# shell will exit.
#
# This requires using parameter expansion to test for unset variables.
#
# http://www.gnu.org/software/bash/manual/bashref.html#Shell-Parameter-Expansion
#
# The two approaches that are probably the most appropriate are:
#
# -word
#   If parameter is unset or null, the expansion of word is substituted.
#   Otherwise, the value of parameter is substituted. In other words, "word"
#   acts as a default value when the value of "parameter" is blank. If "word"
#   is not present, then the default is blank (essentially an empty string).
#
# ?word
#   If parameter is null or unset, the expansion of word (or a message to that
#   effect if word is not present) is written to the standard error and the
#   shell, if it is not interactive, exits. Otherwise, the value of parameter
#   is substituted.
#
# Examples
# ========
#
# Arrays:
#
#   ${some_array[@]:-}              # blank default value
#   ${some_array[*]:-}              # blank default value
#   ${some_array[0]:-}              # blank default value
#   ${some_array[0]:-default_value} # default value: the string 'default_value'
#
# Positional variables:
#
#   -alternative # default value: the string 'alternative'
#   -            # blank default value
#
# With an error message:
#
#   -alternative  # exit with 'error message' if variable is unbound
#
# Short form: set -u
set -o nounset

# Exit immediately if a pipeline returns non-zero.
#
# NOTE: this has issues. When using read -rd '' with a heredoc, the exit
# status is non-zero, even though there isn't an error, and this setting
# then causes the script to exit. read -rd '' is synonymous to read -d $'\0',
# which means read until it finds a NUL byte, but it reaches the EOF (end of
# heredoc) without finding one and exits with a 1 status. Therefore, when
# reading from heredocs with set -e, there are three potential solutions:
#
# Solution 1. set +e / set -e again:
#
# set +e
# read -rd '' variable <<EOF
# EOF
# set -e
#
# Solution 2. <<EOF || true:
#
# read -rd '' variable <<EOF || true
# EOF
#
# Solution 3. Don't use set -e or set -o errexit at all.
#
# More information:
#
# https://www.mail-archive.com/bug-bash@gnu.org/msg12170.html
#
# Short form: set -e
set -o errexit

# Print a helpful message if a pipeline with non-zero exit code causes the
# script to exit as described above.
trap 'echo "Aborting due to errexit on line LINENO. Exit code: $?" >&2' ERR

# Allow the above trap be inherited by all functions in the script.
#
# Short form: set -E
set -o errtrace

# Return value of a pipeline is the value of the last (rightmost) command to
# exit with a non-zero status, or zero if all commands in the pipeline exit
# successfully.
set -o pipefail

# Set $IFS to only newline and tab.
#
# http://www.dwheeler.com/essays/filenames-in-shell.html
IFS=$'\n\t'

###############################################################################
# Environment
###############################################################################

# _ME
#
# Set to the program's basename.
_ME=$(basename "${0}")
_V="v1.0.1"
_ASCII_ME=$(figlet "$_ME")

###############################################################################
# Help
###############################################################################

# define helpers
source_dir=~/.osx-bootstrap

source spinner.sh

# sudo keepalive
_start_sudo() {
    sudo -v
    ( while true; do sudo -v; sleep 60; done; ) &
    SUDO_PID="$!"
    trap stopsudo SIGINT SIGTERM
}
_stop_sudo() {
    kill "$SUDO_PID"
    trap - SIGINT SIGTERM
    sudo -k
}

# _print_help()
#
# Usage:
#   _print_help
#
# Print the program help information.
_print_help() {
  cat <<HEREDOC
${_ASCII_ME}
${_V}

Opinionated OSX settings

Usage:
  ${_ME}
  ${_ME} -h | --help

Options:
  -h --help  Show this screen.
HEREDOC
}

_print_hybernation_instructions() {
  cat <<HEREDOC | boxes -a hcvc
optional instructions, READ CAREFULLY!
In normal mode (with SIP), run:
    $ sudo pmset -a hibernatemode 0
In recovery mode (CMD + R), run:
    $ csrutil disable
    $ reboot 
In normal without SIP (which is a risk and might 
expose you to long dormant threats), run:
    $ sudo rm -f /private/var/vm/sleepimage
    $ sudo touch /private/var/vm/sleepimage
    $ sudo chflags uchg /private/var/vm/sleepimage
In recovery mode, run:
    $ csrutil enable
    $ reboot
In normal mode, verify:
    $ csrutil status
    $ ls -la /private/var/vm
HEREDOC
}

###############################################################################
# Program Functions
###############################################################################

_simple() {
  
  # defaults write -g InitialKeyRepeat -int "${1:-15}" # normal minimum is 15 (225 ms)
  # defaults write -g KeyRepeat -int "${2:-2}" # normal minimum is 2 (30 ms)\n

  _start_sudo

  start_spinner "Configuring cosmetics & osx-behaviour..."
  # Enabling subpixel font rendering on non-Apple LCDs
  defaults write NSGlobalDomain AppleFontSmoothing -int 2
  # Enable full keyboard access for all controls
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
  # Disable press-and-hold for keys in favor of key repeat
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  # Finder: show all filename extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  # Set a shorter Delay until key repeat
  defaults write NSGlobalDomain InitialKeyRepeat -int 12
  # always show scrollbars
  defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
  # Set a blazingly fast keyboard repeat rate
  defaults write NSGlobalDomain KeyRepeat -int 2
  # Disable window animations
  defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
  # I don't even... (disabling auto-correct)
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
  # Disable automatic termination of inactive apps
  defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true
  # Save to disk (not to iCloud) by default
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
  # Expanding the save panel by default
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  # Disable smooth scrolling
  defaults write NSGlobalDomain NSScrollAnimationEnabled -bool false
  # Disable Resume system-wide
  defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false
  # Display ASCII control characters using caret notation in standard text views
  defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true
  # Increasing the window resize speed for Cocoa applications whether you like it or not
  defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
  # Expand print panel by default
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  # ~~Disable~~ Enable “natural” (Lion-style) scrolling
  #defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true
  stop_spinner $?

  start_spinner "Configuring finder..."
  # Show dotfiles in Finder
  defaults write com.apple.finder AppleShowAllFiles TRUE
  # Setting Trash to empty securely not by default
  defaults write com.apple.finder EmptyTrashSecurely -bool false
  # Disable the warning when changing a file extension
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
  # show litsview as default
  defaults write com.apple.Finder FXPreferredViewStyle -string "Nlsv"
  # When performing a search, search the current folder by default
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
  # Show absolute path in finder's title bar
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES
  # Allow text selection in Quick Look/Preview
  defaults write com.apple.finder QLEnableTextSelection -bool true
  # Show Path bar in Finder
  defaults write com.apple.finder ShowPathbar -bool true
  # Show Status bar in Finder
  defaults write com.apple.finder ShowStatusBar -bool true
  # Avoiding creating stupid .DS_Store files on network volumes
  #efaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  # Disable dashboard
  defaults write com.apple.dashboard mcx-disabled -boolean YES
  # Show the ~/Library folder
  chflags nohidden ~/Library
  stop_spinner $?

  start_spinner "Configuring desktop & dock..."
  # Enable snap-to-grid for icons on the desktop and in other icon views
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
  # Set the icon size of Dock items to 36 pixels
  defaults write com.apple.dock tilesize -int 36
  # Speeding up Mission Control animations and grouping windows by application
  defaults write com.apple.dock expose-animation-duration -float 0.1
  defaults write com.apple.dock "expose-group-by-app" -bool true
  # Enabling iTunes track notifications in the Dock
  defaults write com.apple.dock itunes-notifications -bool true
  # Show indicator lights for open applications in the Dock
  defaults write com.apple.dock show-process-indicators -bool true
  # Make Dock icons of hidden applications translucent
  defaults write com.apple.dock showhidden -bool true
  # Add a spacer to the left and right side of the Dock (where the applications are)
  defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
  defaults write com.apple.dock persistent-others -array-add '{tile-data={}; tile-type="spacer-tile";}'
  # http://www.macprime.ch/tipps/article/optimierte-listen-ansicht-im-os-x-dock-aktivieren
  defaults write com.apple.dock use-new-list-stack -bool TRUE
  # Wipe all (default) app icons from the Dock
  # defaults write com.apple.dock persistent-apps -array
  # Reset Launchpad
  find ~/Library/Application\ Support/Dock -maxdepth 1 -name "*.db" -delete
  stop_spinner $?

  start_spinner "Configuring safari..."
  # Disabling Safari’s thumbnail cache for History and Top Sites
  defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2
  defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
  # Removing useless icons from Safari’s bookmarks bar
  defaults write com.apple.Safari ProxiesInBookmarksBar "()"
  # Enabling the Develop menu and the Web Inspector in Safari
  defaults write com.apple.Safari IncludeDevelopMenu -bool true
  defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
  defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true
  # Adding a context menu item for showing the Web Inspector in web views
  defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
  stop_spinner $?

  start_spinner "Configuring terminal..."
  # Enabling UTF-8 ONLY in Terminal.app and setting the Pro theme by default
  defaults write com.apple.Terminal StringEncodings -array 4
  defaults write com.apple.Terminal ShellExitAction 2
  defaults write com.apple.Terminal FontAntialias 1
  defaults write com.apple.Terminal Shell "/bin/zsh"
  defaults write com.apple.Terminal "Default Window Settings" "Pro"
  defaults write com.apple.Terminal "Startup Window Settings" "Pro"
  stop_spinner $?

  start_spinner "Configuring time machine..."
  # Preventing Time Machine from prompting to use new hard drives as backup volume
  defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
  # Disabling local Time Machine backups
  # DOES NOT EXIST ANYMORE: hash tmutil &> /dev/null && sudo tmutil disablelocal
  hash tmutil &> /dev/null && sudo tmutil thinLocalSnapshots / 10000000000 4 &>/dev/null
  stop_spinner $?

  start_spinner "Configuring security..."
  # Requiring password immediately after sleep or screen saver begins
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0
  # Disable the “Are you sure you want to open this application?” dialog
  defaults write com.apple.LaunchServices LSQuarantine -bool false
  stop_spinner $?

  # disable hibernation a la https://christianvarga.com/how-to-delete-sleepimage-on-macos-high-sierra/
  # (various hybernations modes: https://www.lifewire.com/change-mac-sleep-settings-2260804)
  sudo pmset -a hibernatemode 0
 
  # The following are original instructions which
  # are no longer straight up possible as described here:
  # Deleting space hogging sleep image and disabling
  # sudo rm /private/var/vm/sleepimage
  # sudo pmset -a hibernatemode 0

  start_spinner "Configuring others..."
  # Speed up wake from sleep to 24 hours from an hour
  # http://www.cultofmac.com/221392/quick-hack-speeds-up-retina-macbooks-wake-from-sleep-os-x-tips/
  sudo pmset -a standbydelay 86400
  # Enable Assistive Devices 
  sudo touch /private/var/db/.AccessibilityAPIEnabled
  # Trackpad: enable tap to click for this user and for the login screen
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  # Increasing sound quality for Bluetooth headphones/headsets, because duhhhhh
  defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40
  # disable guest user
  sudo defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool false
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool false
  # Enable AirDrop over Ethernet and on unsupported Macs running Lion
  defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true
  # show remaining battery time
  defaults write com.apple.menuextra.battery ShowPercent -string "YES"
  # Automatically illuminate built-in MacBook keyboard in low light
  defaults write com.apple.BezelServices kDim -bool true
  # Turn off keyboard illumination when computer is not used for 5 minutes
  defaults write com.apple.BezelServices kDimTime -int 300
  # Disable the Ping sidebar in iTunes
  defaults write com.apple.iTunes disablePingSidebar -bool true
  defaults write com.apple.iTunes disablePing -bool true
  stop_spinner $?

  start_spinner "Killing finder, dock, mail, safari, & itunes..."
  killall Finder Dock Mail Safari iTunes &>/dev/null || stop_spinner $? || _stop_sudo
  sleep 2s
  stop_spinner $?
  _stop_sudo
  _print_hybernation_instructions
}

###############################################################################
# Main
###############################################################################

# _main()
#
# Usage:
#   _main [<options>] [<arguments>]
#
# Description:
#   Entry point for the program, handling basic option parsing and dispatching.
_main() {
  # Avoid complex option parsing when only one program option is expected.
  if [[ "${1:-}" =~ ^-h|--help$  ]]
  then
    _print_help
  else
    _simple "$@"
  fi
}

# Call `_main` after everything has been defined.
_main "$@"
