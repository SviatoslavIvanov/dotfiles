{ pkgs, ... }:

let
  # Keys here are owned by Nix and will be overwritten on every activation.
  # Everything else in ~/.claude/settings.json (mcpServers, enabledPlugins,
  # pluginMarketplaces, ...) is left untouched so that `claude mcp add`,
  # `/plugin install` etc. work without being reverted on next rebuild.
  managed = {
    "$schema" = "https://json.schemastore.org/claude-code-settings.json";

    # Apply globally: Claude ignores bypassPermissions in project settings.
    permissions.defaultMode = "bypassPermissions";
    skipDangerousModePermissionPrompt = true;

    # Keep this explicit so activation replaces the previous sandbox rules.
    sandbox.enabled = false;

    statusLine = {
      type = "command";
      command = "~/.config/claude-code/statusline.sh";
      padding = 0;
    };

    attribution = {
      commit = "";
      pr = "";
    };

    outputStyle = "explanatory";
  };
  managedFile = pkgs.writeText "claude-managed.json" (builtins.toJSON managed);
in
{
  home.activation.claudeConfig = ''
    mkdir -p "$HOME/.claude"

    SETTINGS="$HOME/.claude/settings.json"

    # Remove symlink if exists (migration from old config)
    [ -L "$SETTINGS" ] && rm "$SETTINGS"
    [ ! -f "$SETTINGS" ] && echo '{}' > "$SETTINGS"

    # Merge: Nix owns the keys present in managed.json; everything else
    # (mcpServers, enabledPlugins, pluginMarketplaces, ...) is preserved
    # so CLI-driven changes survive `darwin-rebuild switch`.
    tmpfile=$(mktemp)
    ${pkgs.jq}/bin/jq --slurpfile managed ${managedFile} '
      ($managed[0] | keys) as $mkeys
      | with_entries(select(.key as $k | $mkeys | index($k) | not))
      + $managed[0]
    ' "$SETTINGS" > "$tmpfile" && mv "$tmpfile" "$SETTINGS"
  '';

  xdg.configFile."claude-code/statusline.sh" = {
    executable = true;
    text = ''
      #!/bin/bash

      input=$(cat)

      IFS=$'\x1f' read -r cwd model context_pct five_hour_pct seven_day_pct < <(
        echo "$input" | ${pkgs.jq}/bin/jq -r '[
          (.workspace.current_dir // .cwd // ""),
          (.model.display_name // .model.id // ""),
          (.context_window.used_percentage // ""),
          (.rate_limits.five_hour.used_percentage // ""),
          (.rate_limits.seven_day.used_percentage // "")
        ] | map(tostring) | join("\u001f")'
      )

      dir_name=$(basename "$cwd")

      git_branch=""
      if cd "$cwd" 2>/dev/null && ${pkgs.git}/bin/git rev-parse --git-dir >/dev/null 2>&1; then
          branch=$(${pkgs.git}/bin/git branch --show-current 2>/dev/null)
          if [ -n "$branch" ]; then
              if ${pkgs.git}/bin/git -c core.useBuiltinFSMonitor=false diff --quiet 2>/dev/null && \
                 ${pkgs.git}/bin/git -c core.useBuiltinFSMonitor=false diff --cached --quiet 2>/dev/null; then
                  git_branch=" \033[38;5;10m $branch\033[0m"
              else
                  git_branch=" \033[38;5;11m $branch ●\033[0m"
              fi
          fi
      fi

      model_info=""
      [ -n "$model" ] && model_info=" \033[38;5;13m$model\033[0m"

      usage_info=""
      if [ -n "$context_pct" ]; then
          context_pct=$(printf '%.0f' "$context_pct")
          usage_info=" \033[38;5;8mctx $context_pct%\033[0m"
      fi
      if [ -n "$five_hour_pct" ]; then
          five_hour_pct=$(printf '%.0f' "$five_hour_pct")
          usage_info="$usage_info \033[38;5;8m5h $five_hour_pct%\033[0m"
      fi
      if [ -n "$seven_day_pct" ]; then
          seven_day_pct=$(printf '%.0f' "$seven_day_pct")
          usage_info="$usage_info \033[38;5;8m7d $seven_day_pct%\033[0m"
      fi

      printf "\033[38;5;12m %s\033[0m%b%b%b" "$dir_name" "$git_branch" "$model_info" "$usage_info"
    '';
  };
}
