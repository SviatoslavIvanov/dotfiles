{ ... }:

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
    ];

    userSettings = {
      # Appearance
      which_key.enabled = true;
      autosave = "on_focus_change";
      ui_font_size = 24;
      buffer_font_size = 22;
      agent_ui_font_size = 24;
      agent_buffer_font_size = 22;
      buffer_font_family = "MonaspiceNe Nerd Font";
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
        light = "One Light";
        dark = "Catppuccin Mocha";
      };
      icon_theme = "Material Icon Theme";

      # Terminal
      terminal.toolbar.breadcrumbs = false;

      # Preview tabs
      preview_tabs.enable_preview_from_file_finder = false;

      # Title bar
      title_bar = {
        show_menus = false;
        show_user_picture = true;
        show_user_menu = true;
        show_onboarding_banner = true;
        show_project_items = true;
        show_branch_name = true;
        show_branch_icon = true;
      };

      # Status bar
      status_bar = {
        active_language_button = true;
        cursor_position_button = false;
      };

      # Search & Debugger
      search.button = true;
      debugger.button = false;

      # Diagnostics
      diagnostics.inline.enabled = true;

      # Vim mode
      vim_mode = true;
      vim = {
        use_system_clipboard = "on_yank";
        use_smartcase_find = true;
      };
      relative_line_numbers = "enabled";

      # Editor UI
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

      # Panels
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

      # Zen mode
      centered_layout = {
        left_padding = 0.2;
        right_padding = 0.2;
      };

      # AI
      features.edit_prediction_provider = "copilot";
      agent = {
        inline_assistant_model = {
          provider = "copilot_chat";
          model = "gpt-5.1-codex";
        };
        default_model = {
          provider = "copilot_chat";
          model = "gpt-5";
        };
        model_parameters = [ ];
      };

      # LSP
      inlay_hints.enabled = true;
      lsp.tailwindcss-language-server.settings = {
        classAttributes = [ "class" "className" "ngClass" "styles" ];
        EDITOR = "zed --wait";
      };

      # File exclusions
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

      # Telemetry
      telemetry = {
        diagnostics = true;
        metrics = true;
      };
    };

    userKeymaps = [
      # Global workspace bindings
      {
        context = "Workspace";
        bindings = {
          "ctrl-/" = "workspace::ToggleBottomDock";
          "ctrl-\\" = "terminal_panel::ToggleFocus";
          "cmd-b" = "workspace::ToggleLeftDock";
        };
      }

      # Window navigation
      {
        context = "Dock || Terminal || Editor";
        bindings = {
          "ctrl-h" = "workspace::ActivatePaneLeft";
          "ctrl-l" = "workspace::ActivatePaneRight";
          "ctrl-k" = "workspace::ActivatePaneUp";
          "ctrl-j" = "workspace::ActivatePaneDown";
        };
      }

      # Normal + Visual mode (shared)
      {
        context = "Editor && (vim_mode == normal || vim_mode == visual) && !VimWaiting && !menu";
        bindings = {
          # Git
          "space g h d" = "editor::ExpandAllDiffHunks";
          "space g h r" = "git::Restore";
          "space g s" = "git_panel::ToggleFocus";

          # Toggle
          "space u i" = "editor::ToggleInlayHints";
          "space u w" = "editor::ToggleSoftWrap";
          "space u z" = "workspace::ToggleCenteredLayout";
          "space z" = "workspace::ToggleZoom";

          # Markdown
          "space m p" = "markdown::OpenPreview";
          "space m P" = "markdown::OpenPreviewToTheSide";

          # Find/files
          "space f p" = "projects::OpenRecent";
          "space f f" = "file_finder::Toggle";
          "space f n" = "workspace::NewFile";

          # Search
          "space s w" = "buffer_search::Deploy";
          "space s W" = "pane::DeploySearch";
          "space s g" = "workspace::NewSearch";
          "space s b" = "vim::Search";
          "space s s" = "outline::Toggle";
          "space s S" = "project_symbols::Toggle";
          "space s d" = "diagnostics::Deploy";

          # AI
          "space a a" = "agent::ToggleFocus";
          "space a e" = "assistant::InlineAssist";
          "space a t" = "workspace::ToggleRightDock";

          # Go to file
          "g f" = "editor::OpenExcerpts";
        };
      }

      # Normal mode only
      {
        context = "Editor && vim_mode == normal && !VimWaiting && !menu";
        bindings = {
          # LSP
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

          # Diagnostics
          "] d" = "editor::GoToDiagnostic";
          "[ d" = "editor::GoToPreviousDiagnostic";
          "] e" = "editor::GoToDiagnostic";
          "[ e" = "editor::GoToPreviousDiagnostic";
          "space x x" = "diagnostics::Deploy";

          # Git
          "space g g" = [ "task::Spawn" { task_name = "lazygit"; reveal_target = "center"; } ];
          "space g b" = "git::Blame";
          "space g d" = "git::Diff";
          "space g D" = "editor::ExpandAllDiffHunks";
          "] h" = "editor::GoToHunk";
          "[ h" = "editor::GoToPreviousHunk";
          "] c" = "editor::GoToHunk";
          "[ c" = "editor::GoToPreviousHunk";

          # Buffers
          "shift-h" = "pane::ActivatePreviousItem";
          "shift-l" = "pane::ActivateNextItem";
          "] b" = "pane::ActivateNextItem";
          "[ b" = "pane::ActivatePreviousItem";
          "space b d" = "pane::CloseActiveItem";
          "shift-q" = "pane::CloseActiveItem";
          "space b o" = "pane::CloseOtherItems";
          "space b q" = "pane::CloseOtherItems";
          "space b b" = "pane::AlternateFile";
          "space b n" = "workspace::NewFile";
          "space ," = "tab_switcher::Toggle";

          # Quick tab access
          "space 1" = [ "pane::ActivateItem" 0 ];
          "space 2" = [ "pane::ActivateItem" 1 ];
          "space 3" = [ "pane::ActivateItem" 2 ];
          "space 4" = [ "pane::ActivateItem" 3 ];
          "space 5" = [ "pane::ActivateItem" 4 ];
          "space 6" = [ "pane::ActivateItem" 5 ];
          "space 7" = [ "pane::ActivateItem" 6 ];
          "space 8" = [ "pane::ActivateItem" 7 ];
          "space 9" = [ "pane::ActivateItem" 8 ];
          "space 0" = "pane::ActivateLastItem";

          # File
          "ctrl-s" = "workspace::Save";
          "space space" = "file_finder::Toggle";
          "space /" = "workspace::NewSearch";
          "space e" = "workspace::ToggleLeftDock";
          "space f E" = "pane::RevealInProjectPanel";

          # Windows
          "space -" = "pane::SplitDown";
          "space |" = "pane::SplitRight";
          "space w s" = "pane::SplitDown";
          "space w v" = "pane::SplitRight";
          "space w d" = "pane::CloseAllItems";
          "space w c" = "pane::CloseAllItems";

          # Quit
          "space q q" = "zed::Quit";

          # Tasks
          "space r t" = "task::Spawn";
          "space r b" = [ "task::Spawn" { task_name = "Build"; } ];
          "space r r" = [ "task::Spawn" { task_name = "Start"; } ];
          "space r f" = [ "task::Spawn" { task_name = "Format"; } ];
          "space t a" = [ "task::Spawn" { task_name = "Test: All"; } ];
          "space t u" = [ "task::Spawn" { task_name = "Test: Unit"; } ];
          "space a c" = [ "task::Spawn" { task_name = "Claude Code"; } ];

          # Excerpts
          "] q" = "editor::MoveToStartOfNextExcerpt";
          "[ q" = "editor::MoveToStartOfExcerpt";
        };
      }

      # Visual mode only
      {
        context = "Editor && vim_mode == visual && !VimWaiting && !menu";
        bindings = {
          "g c" = "editor::ToggleComments";
          "shift-j" = "editor::MoveLineDown";
          "shift-k" = "editor::MoveLineUp";
        };
      }

      # Insert mode
      {
        context = "Editor && vim_mode == insert && !menu";
        bindings = {
          "j j" = "vim::NormalBefore";
        };
      }

      # Vim operators
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

      # Sneak motion
      {
        context = "vim_mode == normal || vim_mode == visual";
        bindings = {
          "s" = "vim::PushSneak";
          "S" = "vim::PushSneakBackward";
        };
      }

      # Center after motions
      {
        context = "VimControl && !menu";
        bindings = {
          "ctrl-d" = [ "workspace::SendKeystrokes" "ctrl-d z z" ];
          "ctrl-u" = [ "workspace::SendKeystrokes" "ctrl-u z z" ];
          "n" = [ "workspace::SendKeystrokes" "n z z z v" ];
          "shift-n" = [ "workspace::SendKeystrokes" "shift-n z z z v" ];
          "shift-g" = [ "workspace::SendKeystrokes" "shift-g z z" ];
        };
      }

      # Empty pane
      {
        context = "EmptyPane || SharedScreen";
        bindings = {
          "space space" = "file_finder::Toggle";
          "space f f" = "file_finder::Toggle";
          "space f n" = "workspace::NewFile";
          "space f p" = "projects::OpenRecent";
          "space s g" = "workspace::NewSearch";
          "space q q" = "zed::Quit";
          "space r t" = [ "editor::SpawnNearestTask" { reveal = "no_focus"; } ];
        };
      }

      # Project panel
      {
        context = "ProjectPanel && not_editing";
        bindings = {
          "a" = "project_panel::NewFile";
          "%" = "project_panel::NewFile";
          "A" = "project_panel::NewDirectory";
          "r" = "project_panel::Rename";
          "shift-r" = "project_panel::Rename";
          "d" = "project_panel::Delete";
          "shift-d" = "project_panel::Delete";
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

      # Git panel
      {
        context = "GitPanel";
        bindings = {
          "q" = "git_panel::Close";
        };
      }

      # AI Agent panel
      {
        context = "AssistantPanel && vim_mode == normal";
        bindings = {
          "q" = "workspace::ToggleRightDock";
        };
      }

      # Terminal
      {
        context = "Terminal";
        bindings = {
          "ctrl-h" = "workspace::ActivatePaneLeft";
          "ctrl-l" = "workspace::ActivatePaneRight";
          "ctrl-k" = "workspace::ActivatePaneUp";
          "ctrl-j" = "workspace::ActivatePaneDown";
        };
      }

      # Dock
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
        label = "Claude Code";
        command = "claude";
        use_new_terminal = true;
        allow_concurrent_runs = false;
        reveal = "always";
        hide = "on_success";
        reveal_target = "center";
      }
    ];
  };
}
