# =========================================================
# Privacy — opt out of tool telemetry / analytics
# Plain env exports, no ordering dependency. Harmless for tools not installed
# (an unused var costs nothing). Homebrew's own opt-out lives in 20-homebrew.zsh.
# =========================================================

# Universal signal honored by a growing number of tools (dotnet, gatsby, etc.)
export DO_NOT_TRACK=1

# JS / web frameworks
export NEXT_TELEMETRY_DISABLED=1
export GATSBY_TELEMETRY_DISABLED=1
export NUXT_TELEMETRY_DISABLED=1
export ASTRO_TELEMETRY_DISABLED=1
export STORYBOOK_DISABLE_TELEMETRY=1
export NG_CLI_ANALYTICS=false          # Angular CLI

# npm noise: disable funding/opencollective postinstall spam
export ADBLOCK=1
export DISABLE_OPENCOLLECTIVE=1

# Runtimes / SDKs
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export POWERSHELL_TELEMETRY_OPTOUT=1

# Cloud CLIs
export AZURE_CORE_COLLECT_TELEMETRY=0
export SAM_CLI_TELEMETRY=0             # AWS SAM

# HashiCorp checkpoint calls (Terraform, Packer, Vagrant, Vault)
export CHECKPOINT_DISABLE=1

# Local LLM: don't log prompts to history
export OLLAMA_NOHISTORY=1
