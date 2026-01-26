{ pkgs, ... }:

{
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code;

    settings = {
      permissions = {
        allow = [
          "mcp__acp__*"
          "mcp__plugin_context7_context7__resolve-library-id"
          "mcp__plugin_context7_context7__query-docs"
          "WebFetch(domain:github.com)"
          "WebFetch(domain:raw.githubusercontent.com)"
          "Bash(ls:*)"
          "Bash(cat:*)"
          "Bash(tree:*)"
          "Bash(find:*)"
          "Bash(grep:*)"
          "Bash(rg:*)"
          "Bash(fd:*)"
          "Bash(which:*)"
          "Bash(pwd:*)"
        ];

        deny = [
          "Read(**/.env*)"
          "Read(**/secrets/**)"
          "Read(**/*.key)"
          "Read(**/*.pem)"
          "Bash(rm -rf:*)"
          "Bash(curl:*)"
          "Bash(wget:*)"
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
  };

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
                  git_branch=" \033[38;5;10m  $branch\033[0m"
              else
                  git_branch=" \033[38;5;11m  $branch ●\033[0m"
              fi
          fi
      fi

      context_info=""
      if [ "$input_tokens" != "0" ] || [ "$cache_create" != "0" ] || [ "$cache_read" != "0" ]; then
          current=$((input_tokens + cache_create + cache_read))
          pct=$((current * 100 / context_size))
          context_info=" \033[38;5;8m$pct%\033[0m"
      fi

      printf "\033[38;5;12m  %s\033[0m%b%s" "$dir_name" "$git_branch" "$context_info"
    '';
  };
}
