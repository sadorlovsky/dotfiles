#!/usr/bin/env bash
#
# macOS defaults — curated from mathiasbynens/dotfiles for this machine.
# Apple Silicon, macOS 15 (Sequoia), WezTerm user. No sudo; user-domain only.
# Idempotent — safe to re-run.

set -euo pipefail

# macOS-only: `defaults` doesn't exist elsewhere. Exit cleanly on other OSes so a
# cross-platform apply isn't aborted by this script.
[ "$(uname -s)" = "Darwin" ] || exit 0

# Close System Settings so it doesn't overwrite the changes below.
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

###############################################################################
# Typing — disable "smart" substitutions that mangle code                     #
###############################################################################

defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Fast key repeat, key repeat on hold (needed for the two rates to matter).
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

###############################################################################
# General UI                                                                  #
###############################################################################

# Near-instant window resize animation.
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

###############################################################################
# Finder                                                                      #
###############################################################################

defaults write com.apple.finder DisableAllAnimations -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true       # show file extensions
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true        # folders on top
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"   # search current folder
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Never write .DS_Store on network / USB volumes.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

###############################################################################
# Dock & Mission Control  (Dock is auto-hidden)                               #
###############################################################################

defaults write com.apple.dock launchanim -bool false                 # no bounce on launch
defaults write com.apple.dock expose-animation-duration -float 0.1   # fast Mission Control
defaults write com.apple.dock mru-spaces -bool false                 # don't reorder Spaces
defaults write com.apple.dock autohide -bool true                    # auto-hide the Dock
defaults write com.apple.dock autohide-delay -float 0                # react instantly…
defaults write com.apple.dock autohide-time-modifier -float 0.3      # …with a smooth slide
defaults write com.apple.dock showhidden -bool true                  # dim hidden apps
defaults write com.apple.dock show-recents -bool false               # no recent apps

###############################################################################
# Software Update — stay current, auto-install security data                  #
###############################################################################

defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1      # check daily
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1      # download in background
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1  # install security updates

###############################################################################
# Apply                                                                       #
###############################################################################

for app in "Finder" "Dock"; do
	killall "${app}" &>/dev/null || true
done
echo "Done. Some changes need a logout/restart to fully take effect."
