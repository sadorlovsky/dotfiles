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

dir=$(basename "$cwd")

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
    printf "\033[34m%s\033[0m  \033[33m%s\033[0m  \033[90m%s\033[0m \033[37m%s/%s (%s%%)\033[0m  \033[36m%s\033[0m" \
      "$dir" "$model" "$bar" "$used_k" "$total_k" "$pct" "$rate_info"
  else
    printf "\033[34m%s\033[0m  \033[33m%s\033[0m  \033[90m%s\033[0m \033[37m%s/%s (%s%%)\033[0m" \
      "$dir" "$model" "$bar" "$used_k" "$total_k" "$pct"
  fi
else
  printf "\033[34m%s\033[0m  \033[33m%s\033[0m" "$dir" "$model"
fi
