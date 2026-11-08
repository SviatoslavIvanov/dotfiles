_:

{
  programs.zed-editor = {
    enable = true;
    # Homebrew owns the macOS app and CLI; Home Manager only owns its config.
    # This avoids shadowing the current `zed` cask with nixpkgs' `zeditor`.
    package = null;
    mutableUserSettings = false;
    mutableUserKeymaps = false;
    mutableUserTasks = false;

    extensions = [
      "catppuccin"
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
      # Zed is primarily a code browser and review surface.
      autosave = "off";
      edit_predictions.provider = "none";
      show_edit_predictions = false;
      show_completions_on_input = false;
      auto_signature_help = false;
      show_signature_help_after_edits = false;
      inline_code_actions = false;
      # Documentation stays available explicitly via K or Cmd K, Cmd I.
      hover_popover_enabled = false;
      diff_view_style = "split";
      minimum_split_diff_width = 100;
      word_diff_enabled = true;
      ui_font_family = ".ZedSans";
      ui_font_size = 26;
      buffer_line_height.custom = 1.4;
      agent_ui_font_size = 28;
      agent_buffer_font_size = 24;
      cursor_blink = false;
      icon_theme = "Zed (Default)";

      # Keep navigation, editing, and agent conversations in separate areas.
      bottom_dock_layout = "contained";
      terminal = {
        dock = "bottom";
        working_directory = "current_project_directory";
        toolbar.breadcrumbs = false;
      };
      preview_tabs = {
        enabled = true;
        enable_preview_from_file_finder = true;
        enable_preview_from_project_panel = true;
        enable_preview_file_from_code_navigation = true;
        # Keep reference/search results available while browsing their source files.
        enable_preview_multibuffer_from_code_navigation = false;
      };
      toolbar = {
        breadcrumbs = true;
        quick_actions = false;
        selections_menu = false;
        agent_review = true;
        code_actions = false;
      };

      title_bar = {
        show_menus = false;
        show_user_picture = false;
        show_user_menu = false;
        show_sign_in = false;
        show_onboarding_banner = false;
        show_project_items = true;
        show_branch_name = true;
        show_branch_status_icon = false;
      };

      status_bar = {
        active_language_button = false;
        cursor_position_button = true;
      };

      search.button = false;
      debugger.button = false;
      diagnostics.inline.enabled = false;
      sticky_scroll.enabled = true;
      use_smartcase_search = true;

      vim_mode = true;
      vim = {
        use_system_clipboard = "on_yank";
        use_smartcase_find = true;
      };
      relative_line_numbers = "disabled";

      tab_bar.show = true;
      scrollbar.show = "auto";
      minimap.show = "never";
      tabs = {
        file_icons = false;
        git_status = true;
        show_diagnostics = "off";
      };
      indent_guides = {
        enabled = true;
        coloring = "fixed";
      };

      project_panel = {
        entry_spacing = "comfortable";
        hide_hidden = false;
        hide_root = true;
        button = true;
        dock = "left";
        default_width = 280;
        auto_reveal_entries = false;
        git_status = true;
        diagnostic_badges = false;
        show_diagnostics = "off";
      };
      git_panel = {
        dock = "left";
        default_width = 280;
        tree_view = true;
        file_icons = true;
        show_count_badge = false;
        commit_editor = "collapsed";
      };
      git = {
        diff_base = "head";
        path_style = "file_path_first";
        inline_blame = {
          enabled = true;
          location = "status_bar";
          show_commit_summary = true;
        };
      };
      outline_panel = {
        button = true;
        dock = "left";
        default_width = 280;
      };
      collaboration_panel = {
        button = false;
        dock = "left";
      };
      notification_panel.dock = "right";

      centered_layout = {
        left_padding = 0.2;
        right_padding = 0.2;
      };

      agent = {
        # This shared panel is also required by external ACP agents.
        # `disable_ai` or `agent.enabled = false` would hide Codex as well.
        dock = "right";
        flexible = false;
        default_width = 560;
        threads_sidebar = {
          position = "right";
          auto_open = false;
        };
        single_file_review = true;
        show_merge_conflict_indicator = false;
      };

      agent_servers = {
        claude-acp = {
          type = "registry";
          env = {
            CLAUDE_CODE_EXECUTABLE = "/opt/homebrew/bin/claude";
          };
        };
        codex-acp = {
          type = "registry";
        };
      };

      inlay_hints.enabled = false;
      lsp.tailwindcss-language-server.settings = {
        classAttributes = [
          "class"
          "className"
          "ngClass"
          "styles"
        ];
      };

      lsp.biome.settings = {
        require_config_file = true;
      };

      languages = {
        Nix = {
          language_servers = [
            "nixd"
            "!nil"
          ];
        };
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
        "..."
        "**/out"
        "**/dist"
        "**/.turbo"
        "**/.vscode-test"
        "**/obj"
        "**/.next"
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
        context = "Editor || Terminal";
        unbind."ctrl-enter" = "assistant::InlineAssist";
      }
      {
        context = "CommitEditor > Editor || GitCommit > Editor";
        unbind."alt-tab" = "git::GenerateCommitMessage";
      }
      {
        context = "Workspace";
        bindings = {
          "ctrl-/" = "workspace::ToggleBottomDock";
          "ctrl-\\" = "terminal_panel::ToggleFocus";
          "cmd-b" = "workspace::ToggleLeftDock";
          "cmd-alt-b" = "workspace::ToggleRightDock";
          "cmd-alt-shift-c" = [
            "agent::NewExternalAgentThread"
            { agent = "codex-acp"; }
          ];
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
          "space o" = "outline_panel::ToggleFocus";

          "space a a" = "agent::ToggleFocus";
          "space a d" = "agent::OpenAgentDiff";
          "space a h" = "agents_sidebar::ToggleThreadHistory";
          "space a n" = [
            "agent::NewExternalAgentThread"
            { agent = "codex-acp"; }
          ];
          "space a o" = [
            "agent::NewExternalAgentThread"
            { agent = "codex-acp"; }
          ];
          "space a l" = "multi_workspace::ToggleWorkspaceSidebar";
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
          "shift-k" = "editor::Hover";

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
          "space g d" = "git::DiffHead";
          "space g c" = "git::CompareWithBranch";
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
          "space b p" = "pane::TogglePinTab";
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
          "space e" = "project_panel::ToggleFocus";
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
          "enter" = "project_panel::Open";
          "o" = "project_panel::Open";
          "shift-enter" = "project_panel::OpenPermanent";
          "t" = "project_panel::OpenPermanent";
          "v" = "project_panel::OpenPermanent";
          "q" = "workspace::ToggleLeftDock";
          "space e" = "project_panel::ToggleFocus";
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
        context = "AgentPanel && vim_mode == normal";
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
        command = ''choice="$(mktemp -t zed-yazi)"; trap 'rm -f "$choice"' EXIT; yazi "$ZED_WORKTREE_ROOT" --chooser-file "$choice" && while IFS= read -r path; do zed -a "$path"; done < "$choice"'';
        use_new_terminal = true;
        allow_concurrent_runs = false;
        reveal = "always";
        hide = "on_success";
        reveal_target = "center";
      }
    ];
  };
}
