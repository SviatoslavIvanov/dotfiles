{ pkgs, ... }:

let
  # Keys here are owned by Nix and will be overwritten on every activation.
  # Everything else in ~/.claude/settings.json (mcpServers, enabledPlugins,
  # pluginMarketplaces, ...) is left untouched so that `claude mcp add`,
  # `/plugin install` etc. work without being reverted on next rebuild.
  managed = {
    "$schema" = "https://json.schemastore.org/claude-code-settings.json";

    permissions = {
      allow = [
        "mcp__acp__*"
        "mcp__plugin_context7_context7__*"
        "WebFetch"
        "WebSearch"
        "Bash(ls *)"
        "Bash(cat *)"
        "Bash(tree *)"
        "Bash(head *)"
        "Bash(tail *)"
        "Bash(wc *)"
        "Bash(file *)"
        "Bash(find *)"
        "Bash(which *)"
        "Bash(stat *)"
      ];

      ask = [
        # Sensitive files
        "Read(**/.env*)"
        "Read(**/secrets/**)"
        "Read(**/*secret*)"
        "Read(**/*credential*)"

        # Destructive operations
        "Bash(rm -rf *)"
        "Bash(rm -r *)"

        # Network requests
        "Bash(curl *)"
        "Bash(wget *)"

        # Git write operations
        "Bash(git add *)"
        "Bash(git commit *)"
        "Bash(git push *)"
        "Bash(git push)"
        "Bash(git reset *)"
        "Bash(git checkout *)"
        "Bash(git restore *)"
        "Bash(git revert *)"
        "Bash(git merge *)"
        "Bash(git rebase *)"
        "Bash(git stash *)"
        "Bash(git branch -d *)"
        "Bash(git branch -D *)"
        "Bash(git tag *)"
        "Bash(git cherry-pick *)"
        "Bash(git clean *)"
      ];

      deny = [
        # Private keys - never read
        "Read(**/*.key)"
        "Read(**/*.pem)"
        "Read(**/*_rsa)"
        "Read(**/*_ed25519)"
        "Read(**/*.p12)"
      ];
    };

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

      read -r cwd context_size < <(echo "$input" | ${pkgs.jq}/bin/jq -r '
        .workspace.current_dir,
        .context_window.context_window_size
      ' | tr '\n' ' ')

      read -r input_tokens cache_create cache_read < <(echo "$input" | ${pkgs.jq}/bin/jq -r '
        .context_window.current_usage |
        if . == null then "0 0 0" else
          "\(.input_tokens // 0) \(.cache_creation_input_tokens // 0) \(.cache_read_input_tokens // 0)"
        end
      ')

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

      context_info=""
      if [ "$input_tokens" != "0" ] || [ "$cache_create" != "0" ] || [ "$cache_read" != "0" ]; then
          current=$((input_tokens + cache_create + cache_read))
          pct=$((current * 100 / context_size))
          context_info=" \033[38;5;8m$pct%\033[0m"
      fi

      printf "\033[38;5;12m %s\033[0m%b%b" "$dir_name" "$git_branch" "$context_info"
    '';
  };
}
