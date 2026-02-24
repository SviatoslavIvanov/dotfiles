{ lib, ... }:

{
  programs.zed-editor = {
    enable = true;
    mutableUserSettings = false;
    mutableUserKeymaps = false;
    mutableUserTasks = false;

    extensions = [
      "catppuccin"
      "material-icon-theme"
      "nix"
      "toml"
      "dockerfile"
      "docker-compose"
      "git-firefly"
      "html"
      "sql"
      "csv"
      "biome"
    ];

    userSettings = {
      which_key.enabled = true;
      autosave = "on_focus_change";
      ui_font_size = lib.mkForce 24;
      buffer_font_size = lib.mkForce 22;
      agent_ui_font_size = 24;
      agent_buffer_font_size = 22;
      buffer_font_family = "MonaspiceNe Nerd Font Mono";
      buffer_font_fallbacks = [
        "JetBrainsMono Nerd Font Mono"
      ];
      buffer_font_features = {
        calt = true;
        liga = true;
        ss01 = true;
        ss02 = true;
        ss03 = true;
        ss04 = true;
        ss06 = true;
        ss07 = true;
        ss08 = true;
        ss09 = true;
      };

      theme = {
        mode = "dark";
      };
      icon_theme = "Material Icon Theme";

      terminal.toolbar.breadcrumbs = false;
      preview_tabs.enable_preview_from_file_finder = false;

      title_bar = {
        show_menus = false;
        show_user_picture = true;
        show_user_menu = true;
        show_onboarding_banner = true;
        show_project_items = true;
        show_branch_name = true;
        show_branch_icon = true;
      };

      status_bar = {
        active_language_button = true;
        cursor_position_button = false;
      };

      search.button = true;
      debugger.button = false;
      diagnostics.inline.enabled = true;

      vim_mode = true;
      vim = {
        use_system_clipboard = "on_yank";
        use_smartcase_find = true;
      };
      relative_line_numbers = "enabled";

      tab_bar.show = true;
      scrollbar.show = "auto";
      tabs = {
        file_icons = true;
        git_status = true;
        show_diagnostics = "all";
      };
      indent_guides = {
        enabled = true;
        coloring = "indent_aware";
      };

      project_panel = {
        entry_spacing = "comfortable";
        hide_hidden = false;
        hide_root = true;
        button = true;
        dock = "left";
        git_status = true;
      };
      git_panel.dock = "left";
      outline_panel = {
        button = false;
        dock = "right";
      };
      collaboration_panel = {
        button = true;
        dock = "left";
      };
      notification_panel.dock = "right";

      centered_layout = {
        left_padding = 0.2;
        right_padding = 0.2;
      };

      agent = {
        inline_assistant_model = {
          provider = "copilot_chat";
          model = "gpt-5.3-codex";
        };
        default_model = {
          provider = "copilot_chat";
          model = "gpt-5.3-codex";
        };
        model_parameters = [ ];
      };

      inlay_hints.enabled = true;
      lsp.tailwindcss-language-server.settings = {
        classAttributes = [
          "class"
          "className"
          "ngClass"
          "styles"
        ];
        EDITOR = "zed --wait";
      };

      lsp.biome.settings = {
        require_config_file = true;
      };

      languages = {
        Python = {
          language_servers = [
            "ty"
            "!basedpyright"
            "..."
          ];
        };
        JavaScript = {
          formatter = {
            language_server.name = "biome";
          };
          code_actions_on_format = {
            "source.fixAll.biome" = true;
            "source.organizeImports.biome" = true;
          };
        };
        TypeScript = {
          formatter = {
            language_server.name = "biome";
          };
          code_actions_on_format = {
            "source.fixAll.biome" = true;
            "source.organizeImports.biome" = true;
          };
        };
        TSX = {
          formatter = {
            language_server.name = "biome";
          };
          code_actions_on_format = {
            "source.fixAll.biome" = true;
            "source.organizeImports.biome" = true;
          };
        };
        JSX = {
          formatter = {
            language_server.name = "biome";
          };
          code_actions_on_format = {
            "source.fixAll.biome" = true;
            "source.organizeImports.biome" = true;
          };
        };
        JSON = {
          formatter = {
            language_server.name = "biome";
          };
        };
        JSONC = {
          formatter = {
            language_server.name = "biome";
          };
        };
        CSS = {
          formatter = {
            language_server.name = "biome";
          };
        };
      };

      file_scan_exclusions = [
        "**/.git"
        "**/.svn"
        "**/.hg"
        "**/CVS"
        "**/.DS_Store"
        "**/Thumbs.db"
        "**/.classpath"
        "**/.settings"
        "**/out"
        "**/dist"
        "**/.husky"
        "**/.turbo"
        "**/.vscode-test"
        "**/.vscode"
        "**/bin"
        "**/obj"
        "**/.next"
        "**/.storybook"
        "**/.tap"
        "**/.nyc_output"
        "**/report"
        "**/node_modules"
        "**/.dotnet"
      ];

      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      confirm_quit = false;
      use_system_prompts = false;
    };

    userKeymaps = [
      {
        context = "Workspace";
        bindings = {
          "ctrl-/" = "workspace::ToggleBottomDock";
          "ctrl-\\" = "terminal_panel::ToggleFocus";
          "cmd-b" = "workspace::ToggleLeftDock";
        };
      }

      {
        context = "Dock || Terminal || Editor";
        bindings = {
          "ctrl-h" = "workspace::ActivatePaneLeft";
          "ctrl-l" = "workspace::ActivatePaneRight";
          "ctrl-k" = "workspace::ActivatePaneUp";
          "ctrl-j" = "workspace::ActivatePaneDown";
        };
      }

      {
        context = "Editor && (vim_mode == normal || vim_mode == visual) && !VimWaiting && !menu";
        bindings = {
          "space g h d" = "editor::ExpandAllDiffHunks";
          "space g h r" = "git::Restore";
          "space g s" = "git_panel::ToggleFocus";

          "space u i" = "editor::ToggleInlayHints";
          "space u w" = "editor::ToggleSoftWrap";
          "space u z" = "workspace::ToggleCenteredLayout";
          "space z" = "workspace::ToggleZoom";

          "space m p" = "markdown::OpenPreview";
          "space m P" = "markdown::OpenPreviewToTheSide";

          "space f p" = "projects::OpenRecent";
          "space f n" = "workspace::NewFile";

          "space s w" = "buffer_search::Deploy";
          "space s W" = "pane::DeploySearch";
          "space s g" = "workspace::NewSearch";
          "space s b" = "vim::Search";
          "space s s" = "outline::Toggle";
          "space s S" = "project_symbols::Toggle";
          "space s d" = "diagnostics::Deploy";

          "space a a" = "agent::ToggleFocus";
          "space a e" = "assistant::InlineAssist";
          "space a h" = "agent::OpenHistory";
          "space a n" = "agent::NewThread";
          "space a s" = "agent::AddSelectionToThread";
          "space a t" = "workspace::ToggleRightDock";

          "g f" = "editor::OpenExcerpts";
        };
      }

      {
        context = "Editor && vim_mode == normal && !VimWaiting && !menu";
        bindings = {
          "space c a" = "editor::ToggleCodeActions";
          "space ." = "editor::ToggleCodeActions";
          "space c r" = "editor::Rename";
          "space c f" = "editor::Format";

          "g d" = "editor::GoToDefinition";
          "g D" = "editor::GoToDefinitionSplit";
          "g i" = "editor::GoToImplementation";
          "g I" = "editor::GoToImplementationSplit";
          "g t" = "editor::GoToTypeDefinition";
          "g T" = "editor::GoToTypeDefinitionSplit";
          "g y" = "editor::GoToTypeDefinition";
          "g r" = "editor::FindAllReferences";

          "] d" = "editor::GoToDiagnostic";
          "[ d" = "editor::GoToPreviousDiagnostic";
          "space x x" = "diagnostics::Deploy";

          "space g g" = [
            "task::Spawn"
            {
              task_name = "lazygit";
              reveal_target = "center";
            }
          ];
          "space g b" = "git::Blame";
          "space g d" = "git::Diff";
          "space g D" = "editor::ExpandAllDiffHunks";

          "space d d" = [
            "task::Spawn"
            {
              task_name = "lazydocker";
              reveal_target = "center";
            }
          ];
          "] h" = "editor::GoToHunk";
          "[ h" = "editor::GoToPreviousHunk";
          "] b" = "pane::ActivateNextItem";
          "[ b" = "pane::ActivatePreviousItem";
          "space b d" = "pane::CloseActiveItem";
          "shift-q" = "pane::CloseActiveItem";
          "space b o" = "pane::CloseOtherItems";
          "space b b" = "pane::AlternateFile";
          "space b n" = "workspace::NewFile";
          "space ," = "tab_switcher::Toggle";

          "space 1" = [
            "pane::ActivateItem"
            0
          ];
          "space 2" = [
            "pane::ActivateItem"
            1
          ];
          "space 3" = [
            "pane::ActivateItem"
            2
          ];
          "space 4" = [
            "pane::ActivateItem"
            3
          ];
          "space 5" = [
            "pane::ActivateItem"
            4
          ];
          "space 6" = [
            "pane::ActivateItem"
            5
          ];
          "space 7" = [
            "pane::ActivateItem"
            6
          ];
          "space 8" = [
            "pane::ActivateItem"
            7
          ];
          "space 9" = [
            "pane::ActivateItem"
            8
          ];
          "space 0" = "pane::ActivateLastItem";

          "ctrl-s" = "workspace::Save";
          "space space" = "file_finder::Toggle";
          "space /" = "workspace::NewSearch";
          "space e" = "workspace::ToggleLeftDock";
          "space f E" = "pane::RevealInProjectPanel";

          "space -" = "pane::SplitDown";
          "space |" = "pane::SplitRight";
          "space w d" = "pane::CloseAllItems";

          "space q q" = "zed::Quit";

          "space r t" = "task::Spawn";
          "space r b" = [
            "task::Spawn"
            { task_name = "Build"; }
          ];
          "space r r" = [
            "task::Spawn"
            { task_name = "Start"; }
          ];
          "space r f" = [
            "task::Spawn"
            { task_name = "Format"; }
          ];
          "space t a" = [
            "task::Spawn"
            { task_name = "Test: All"; }
          ];
          "space t u" = [
            "task::Spawn"
            { task_name = "Test: Unit"; }
          ];
          "space a c" = [
            "task::Spawn"
            { task_name = "Claude Code"; }
          ];

          "] q" = "editor::MoveToStartOfNextExcerpt";
          "[ q" = "editor::MoveToStartOfExcerpt";
        };
      }

      {
        context = "Editor && vim_mode == visual && !VimWaiting && !menu";
        bindings = {
          "g c" = "editor::ToggleComments";
          "shift-j" = "editor::MoveLineDown";
          "shift-k" = "editor::MoveLineUp";
        };
      }

      {
        context = "Editor && vim_operator == c";
        bindings = {
          "c" = "vim::CurrentLine";
          "r" = "editor::Rename";
          "a" = "editor::ToggleCodeActions";
        };
      }
      {
        context = "vim_operator == d";
        bindings = {
          "o" = "editor::ExpandAllDiffHunks";
          "r" = "git::Restore";
        };
      }
      {
        context = "vim_operator == a || vim_operator == i || vim_operator == cs";
        bindings = {
          "b" = "vim::AnyBrackets";
        };
      }

      {
        context = "vim_mode == normal || vim_mode == visual";
        bindings = {
          "s" = "vim::PushSneak";
          "S" = "vim::PushSneakBackward";
        };
      }

      {
        context = "VimControl && !menu";
        bindings = {
          "ctrl-d" = [
            "workspace::SendKeystrokes"
            "ctrl-d z z"
          ];
          "ctrl-u" = [
            "workspace::SendKeystrokes"
            "ctrl-u z z"
          ];
          "n" = [
            "workspace::SendKeystrokes"
            "n z z z v"
          ];
          "shift-n" = [
            "workspace::SendKeystrokes"
            "shift-n z z z v"
          ];
          "shift-g" = [
            "workspace::SendKeystrokes"
            "shift-g z z"
          ];
        };
      }

      {
        context = "EmptyPane || SharedScreen";
        bindings = {
          "space space" = "file_finder::Toggle";
          "space f f" = "file_finder::Toggle";
          "space f n" = "workspace::NewFile";
          "space f p" = "projects::OpenRecent";
          "space s g" = "workspace::NewSearch";
          "space q q" = "zed::Quit";
          "space r t" = [
            "editor::SpawnNearestTask"
            { reveal = "no_focus"; }
          ];
        };
      }

      {
        context = "ProjectPanel && not_editing";
        bindings = {
          "a" = "project_panel::NewFile";
          "A" = "project_panel::NewDirectory";
          "r" = "project_panel::Rename";
          "d" = "project_panel::Delete";
          "x" = "project_panel::Cut";
          "c" = "project_panel::Copy";
          "p" = "project_panel::Paste";
          "h" = "project_panel::CollapseSelectedEntry";
          "j" = "menu::SelectNext";
          "k" = "menu::SelectPrevious";
          "l" = "project_panel::ExpandSelectedEntry";
          "g g" = "menu::SelectFirst";
          "shift-g" = "menu::SelectLast";
          "-" = "project_panel::SelectParent";
          "enter" = "project_panel::OpenPermanent";
          "o" = "project_panel::OpenPermanent";
          "t" = "project_panel::OpenPermanent";
          "v" = "project_panel::OpenPermanent";
          "q" = "workspace::ToggleLeftDock";
          "space e" = "workspace::ToggleLeftDock";
          "escape" = "project_panel::ToggleFocus";
          "/" = "project_panel::NewSearchInDirectory";
          ":" = "command_palette::Toggle";
          "ctrl-h" = "workspace::ActivatePaneLeft";
          "ctrl-l" = "workspace::ActivatePaneRight";
          "ctrl-k" = "workspace::ActivatePaneUp";
          "ctrl-j" = "workspace::ActivatePaneDown";
          "ctrl-6" = "pane::AlternateFile";
        };
      }

      {
        context = "GitPanel";
        bindings = {
          "q" = "git_panel::Close";
        };
      }

      {
        context = "AssistantPanel && vim_mode == normal";
        bindings = {
          "q" = "workspace::ToggleRightDock";
        };
      }

      {
        context = "Terminal";
        bindings = {
          "ctrl-h" = "workspace::ActivatePaneLeft";
          "ctrl-l" = "workspace::ActivatePaneRight";
          "ctrl-k" = "workspace::ActivatePaneUp";
          "ctrl-j" = "workspace::ActivatePaneDown";
        };
      }

      {
        context = "Dock";
        bindings = {
          "ctrl-w h" = "workspace::ActivatePaneLeft";
          "ctrl-w l" = "workspace::ActivatePaneRight";
          "ctrl-w k" = "workspace::ActivatePaneUp";
          "ctrl-w j" = "workspace::ActivatePaneDown";
        };
      }
    ];

    userTasks = [
      {
        label = "lazygit";
        command = "lazygit";
        use_new_terminal = true;
        reveal = "always";
        hide = "on_success";
        reveal_target = "center";
      }
      {
        label = "lazydocker";
        command = "lazydocker";
        use_new_terminal = true;
        reveal = "always";
        hide = "on_success";
        reveal_target = "center";
      }
      {
        label = "Claude Code";
        command = "claude";
        use_new_terminal = true;
        allow_concurrent_runs = false;
        reveal = "always";
        hide = "on_success";
        reveal_target = "center";
      }
      {
        label = "Yazi (open file)";
        command = "yazi $ZED_WORKTREE_ROOT --chooser-file /tmp/zed-yazi-choice && [ -s /tmp/zed-yazi-choice ] && xargs zeditor -a < /tmp/zed-yazi-choice; rm -f /tmp/zed-yazi-choice";
        use_new_terminal = true;
        allow_concurrent_runs = false;
        reveal = "always";
        hide = "on_success";
        reveal_target = "center";
      }
    ];
  };
}
