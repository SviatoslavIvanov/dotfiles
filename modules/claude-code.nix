{ pkgs, ... }:

let
  settings = {
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

    enabledPlugins = {
      "frontend-design@claude-plugins-official" = true;
      "context7@claude-plugins-official" = true;
      "code-simplifier@claude-plugins-official" = true;
      "playwright@claude-plugins-official" = true;
    };

    pluginMarketplaces = [
      {
        source = "github";
        repo = "anthropics/claude-plugins-official";
      }
    ];
  };
  settingsJson = builtins.toJSON settings;
in
{
  home.activation.claudeConfig = ''
        mkdir -p "$HOME/.claude"

        # Remove symlink if exists (migration from old config)
        [ -L "$HOME/.claude/settings.json" ] && rm "$HOME/.claude/settings.json"

        # Settings - always overwrite (nix is source of truth)
        cat > "$HOME/.claude/settings.json" << 'EOF'
    ${settingsJson}
    EOF
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
