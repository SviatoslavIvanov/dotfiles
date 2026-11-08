{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.claude-code = {
    enable = true;
    # Homebrew installs and self-updates the CLI.
    package = null;
    # The desktop app and Cowork read ~/.claude and never see CLAUDE_CONFIG_DIR.
    configDir = "${config.home.homeDirectory}/.claude";
    mutableSettings = true;
    enableMcpIntegration = true;

    settings = {
      # Apply globally: Claude ignores bypassPermissions in project settings.
      permissions.defaultMode = "bypassPermissions";
      skipDangerousModePermissionPrompt = true;

      statusLine = {
        type = "command";
        command = "~/.config/claude-code/statusline.sh";
        padding = 0;
      };

      attribution = false;
    };

    lspServers.typescript = {
      command = lib.getExe pkgs.typescript-language-server;
      args = [ "--stdio" ];
      extensionToLanguage = {
        ".ts" = "typescript";
        ".tsx" = "typescriptreact";
        ".mts" = "typescript";
        ".cts" = "typescript";
        ".js" = "javascript";
        ".jsx" = "javascriptreact";
        ".mjs" = "javascript";
        ".cjs" = "javascript";
      };
    };
  };

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

      # status, unlike diff, never takes index.lock, so it cannot race the agent's own commits.
      git_branch=""
      if status=$(${pkgs.git}/bin/git --no-optional-locks -C "$cwd" status --porcelain=v2 --branch --untracked-files=no 2>/dev/null); then
          branch="" dirty=""
          while IFS= read -r line; do
              case $line in
                  "# branch.head "*) branch=''${line#\# branch.head } ;;
                  [12u]" "*) dirty=1 ;;
              esac
          done <<<"$status"
          if [ -n "$branch" ] && [ "$branch" != "(detached)" ]; then
              if [ -n "$dirty" ]; then
                  git_branch=" \033[38;5;11m $branch ●\033[0m"
              else
                  git_branch=" \033[38;5;10m $branch\033[0m"
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
