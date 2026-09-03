#!/bin/sh
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
rate_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rate_5h_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
rate_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
rate_7d_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')
git_worktree=$(echo "$input" | jq -r '.workspace.git_worktree // empty')
cc_worktree=$(echo "$input" | jq -r '.worktree.name // empty')

dir=$(basename "$cwd")

# Git branch (empty segment if not a repo). A trailing ⑂ marks a *linked*
# worktree: .workspace.git_worktree is set whenever cwd sits under
# .git/worktrees/, whoever created it. The marker is yellow for a Claude-managed
# --worktree session (.worktree is present only then) and magenta for any other
# linked worktree, so a worktree Claude made reads apart from one already there.
# In the main worktree the segment is byte-for-byte what it has always been.
branch=$(git -C "$cwd" symbolic-ref --short -q HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
branch_seg=""
if [ -n "$branch" ]; then
  if [ -n "$git_worktree" ]; then
    if [ -n "$cc_worktree" ]; then wt_color=33; else wt_color=35; fi
    branch_seg=$(printf "\033[32m⎇ %s \033[%sm⑂\033[0m  " "$branch" "$wt_color")
  else
    branch_seg=$(printf "\033[32m⎇ %s\033[0m  " "$branch")
  fi
fi

# Reasoning effort, hung off the model name as "Opus 5·hi". .effort is absent
# entirely on models with no effort knob (Haiku, Opus 4.x, Sonnet 4.5), so the
# segment drops out on its own without a model check here. Claude Code resolves
# an unset level to "high", so this always shows the effective value.
# Colour ramps cool -> hot with the level; the separator stays dim.
effort_seg=""
case "$effort" in
  low)    effort_seg=$(printf "\033[90m·\033[34mlo\033[0m")  ;;
  medium) effort_seg=$(printf "\033[90m·\033[36mmd\033[0m")  ;;
  high)   effort_seg=$(printf "\033[90m·\033[32mhi\033[0m")  ;;
  xhigh)  effort_seg=$(printf "\033[90m·\033[35mxh\033[0m")  ;;
  max)    effort_seg=$(printf "\033[90m·\033[31mmax\033[0m") ;;
esac

# --- Billing / auth mode -------------------------------------------------
# Precedence mirrors Claude Code's own credential resolution: cloud > API
# key/token env > subscription OAuth. rate_5h / rate_7d come from the JSON
# above and only exist for subscription sessions.
CFG="$HOME/.claude.json"
bill=""
bill_color="35"   # magenta = normal (subscription or plain API)
if [ -n "$CLAUDE_CODE_USE_BEDROCK" ]; then
  bill="☁ Bedrock"
elif [ -n "$CLAUDE_CODE_USE_VERTEX" ]; then
  bill="☁ Vertex"
elif [ -n "$ANTHROPIC_API_KEY" ] || [ -n "$ANTHROPIC_AUTH_TOKEN" ]; then
  bill="⚡ API"                        # billing to API credits, not subscription
else
  # Claude subscription (OAuth). Read plan + extra-usage capability in one jq.
  acct=$(jq -r '[
      .oauthAccount.organizationRateLimitTier // .oauthAccount.userRateLimitTier // "sub",
      (.oauthAccount.hasExtraUsageEnabled // false | tostring),
      (.cachedExtraUsageDisabledReason // "null" | tostring)
    ] | @tsv' "$CFG" 2>/dev/null)
  tier=$(echo "$acct" | cut -f1)
  has_extra=$(echo "$acct" | cut -f2)
  extra_off=$(echo "$acct" | cut -f3)
  case "$tier" in
    *max_20x*) plan="Max 20x" ;;
    *max_5x*)  plan="Max 5x"  ;;
    *max*)     plan="Max"     ;;
    *pro*)     plan="Pro"     ;;
    *)         plan="Sub"     ;;
  esac
  bill="✦ $plan"

  # Over the included quota right now? (either window at/over 100%)
  over=0
  [ -n "$rate_5h" ] && [ "$(printf '%.0f' "$rate_5h")" -ge 100 ] && over=1
  [ -n "$rate_7d" ] && [ "$(printf '%.0f' "$rate_7d")" -ge 100 ] && over=1
  if [ "$over" -eq 1 ]; then
    if [ "$has_extra" = "true" ] && [ "$extra_off" = "null" ]; then
      bill="credits"            # limit reached -> spilling to usage credits (extra usage)
      bill_color="33"           # yellow
    else
      bill="⛔ limit"           # limit reached, no spillover configured
      bill_color="31"           # red
    fi
  fi
fi

if [ -n "$used_pct" ] && [ -n "$input_tokens" ] && [ -n "$ctx_size" ]; then
  # Build visual bar (10 chars wide)
  filled=$(echo "$used_pct" | awk '{printf "%d", int($1 / 10 + 0.5)}')
  empty=$((10 - filled))
  bar=""
  i=0
  while [ $i -lt $filled ]; do
    bar="${bar}█"
    i=$((i + 1))
  done
  i=0
  while [ $i -lt $empty ]; do
    bar="${bar}░"
    i=$((i + 1))
  done

  # Convert tokens to human-readable notation (k or M)
  fmt_tokens() {
    echo "$1" | awk '{
      k = $1 / 1000
      if (k >= 1000) {
        m = k / 1000
        if (m == int(m)) printf "%dM", m
        else printf "%.1fM", m
      } else {
        printf "%dk", int(k + 0.5)
      }
    }'
  }
  used_actual=$(echo "$used_pct $ctx_size" | awk '{printf "%d", $1 * $2 / 100}')
  used_k=$(fmt_tokens "$used_actual")
  total_k=$(fmt_tokens "$ctx_size")
  pct=$(printf "%.0f" "$used_pct")

  # Format seconds as Xh Ym countdown
  fmt_reset() {
    now=$(date +%s)
    diff=$(( $1 - now ))
    if [ $diff -le 0 ]; then
      echo "now"
    else
      h=$(( diff / 3600 ))
      m=$(( (diff % 3600) / 60 ))
      if [ $h -gt 0 ]; then
        printf "%dh%dm" $h $m
      else
        printf "%dm" $m
      fi
    fi
  }

  # Rate limits (MAX plan)
  rate_info=""
  if [ -n "$rate_5h" ]; then
    r5=$(printf "%.0f" "$rate_5h")
    if [ -n "$rate_5h_reset" ]; then
      t5=$(fmt_reset "$rate_5h_reset")
      rate_info="5h:${r5}% ↺ ${t5}"
    else
      rate_info="5h:${r5}%"
    fi
  fi
  if [ -n "$rate_7d" ]; then
    r7=$(printf "%.0f" "$rate_7d")
    rate_info="${rate_info}${rate_info:+  }7d:${r7}%"
  fi

  if [ -n "$rate_info" ]; then
    printf "\033[34m%s\033[0m  %s\033[33m%s\033[0m%s  \033[90m%s\033[0m \033[37m%s/%s (%s%%)\033[0m  \033[36m%s\033[0m" \
      "$dir" "$branch_seg" "$model" "$effort_seg" "$bar" "$used_k" "$total_k" "$pct" "$rate_info"
  else
    printf "\033[34m%s\033[0m  %s\033[33m%s\033[0m%s  \033[90m%s\033[0m \033[37m%s/%s (%s%%)\033[0m" \
      "$dir" "$branch_seg" "$model" "$effort_seg" "$bar" "$used_k" "$total_k" "$pct"
  fi
else
  printf "\033[34m%s\033[0m  %s\033[33m%s\033[0m%s" "$dir" "$branch_seg" "$model" "$effort_seg"
fi

# Billing / auth-mode segment (appended to whichever line printed above)
if [ -n "$bill" ]; then
  printf "  \033[%sm%s\033[0m" "$bill_color" "$bill"
fi
