{
  config,
  lib,
  osConfig,
  ...
}:

let
  flake = ''(builtins.getFlake "${config.home.sessionVariables.DOTFILES_DIR}")'';
  biome.formatter.language_server.name = "biome";
  biomeWithFixes = biome // {
    code_actions_on_format = {
      "source.fixAll.biome" = true;
      "source.organizeImports.biome" = true;
    };
  };

  codexThread = [
    "agent::NewExternalAgentThread"
    { agent = "codex-acp"; }
  ];
  centeredTask = name: [
    "task::Spawn"
    {
      task_name = name;
      reveal_target = "center";
    }
  ];
  dotfiles = "${flake}.darwinConfigurations.${osConfig.networking.hostName}";
  paneNavigation = {
    "ctrl-h" = "workspace::ActivatePaneLeft";
    "ctrl-l" = "workspace::ActivatePaneRight";
    "ctrl-k" = "workspace::ActivatePaneUp";
    "ctrl-j" = "workspace::ActivatePaneDown";
  };
in
{
  programs.zed-editor = {
    enable = true;
    package = null; # the Homebrew cask owns the app and its `zed` CLI
    mutableUserSettings = false;
    mutableUserKeymaps = false;
    mutableUserTasks = false;

    extensions = [
      "biome"
      "csharp"
      "csv"
      "docker-compose"
      "dockerfile"
      "fsharp"
      "git-firefly"
      "latex"
      "lua"
      "mermaid"
      "nix"
      "proto"
      "rainbow-csv"
      "sql"
      "toml"
      "vue"
      "xml"
    ];

    userSettings = {
      which_key.enabled = true;
      edit_predictions.provider = "none";
      show_completions_on_input = false;
      inline_code_actions = false;
      hover_popover_enabled = false;
      ui_font_size = 26;
      buffer_line_height.custom = 1.4;
      agent_ui_font_size = 28;
      agent_buffer_font_size = 24;
      cursor_blink = false;

      preview_tabs.enable_preview_from_file_finder = true;
      toolbar = {
        quick_actions = false;
        selections_menu = false;
      };

      title_bar = {
        show_user_picture = false;
        show_user_menu = false;
        show_sign_in = false;
        show_onboarding_banner = false;
      };
      status_bar.active_language_button = false;

      search.button = false;
      debugger.button = false;
      sticky_scroll.enabled = true;
      use_smartcase_search = true;

      vim_mode = true;
      vim = {
        use_system_clipboard = "on_yank";
        use_smartcase_find = true;
      };

      tabs.git_status = true;

      project_panel = {
        hide_root = true;
        dock = "left";
        default_width = 280;
        auto_reveal_entries = false;
        show_diagnostics = "off";
      };
      git_panel = {
        dock = "left";
        default_width = 280;
        tree_view = true;
        file_icons = true;
        commit_editor = "collapsed";
      };
      git = {
        path_style = "file_path_first";
        inline_blame = {
          location = "status_bar";
          show_commit_summary = true;
        };
      };
      outline_panel = {
        dock = "left";
        default_width = 280;
      };
      collaboration_panel = {
        button = false;
        dock = "left";
      };

      # External ACP agents need this panel too, so `disable_ai` would hide Codex as well.
      agent = {
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
          env.CLAUDE_CODE_EXECUTABLE = "/opt/homebrew/bin/claude";
        };
        codex-acp.type = "registry";
      };

      lsp = {
        tailwindcss-language-server.settings.classAttributes = [
          "class"
          "className"
          "ngClass"
          "styles"
        ];
        biome.settings.require_config_file = true;
        nixd.settings = {
          nixpkgs.expr = "import ${flake}.inputs.nixpkgs { }";
          options = {
            nix-darwin.expr = "${dotfiles}.options";
            home-manager.expr = "${dotfiles}.options.home-manager.users.type.getSubOptions [ ]";
          };
        };
      };

      languages =
        lib.genAttrs [ "JavaScript" "TypeScript" "TSX" ] (_: biomeWithFixes)
        // lib.genAttrs [ "JSON" "JSONC" "CSS" ] (_: biome)
        // {
          Nix.language_servers = [ "nixd" ];
          Python.language_servers = [
            "ty"
            "ruff"
          ];
        };

      telemetry = {
        diagnostics = false;
        metrics = false;
      };

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
          "cmd-alt-shift-c" = codexThread;
        };
      }
      {
        context = "Dock || Terminal || (Editor && VimControl)";
        bindings = paneNavigation;
      }
      {
        context = "Editor && (vim_mode == normal || vim_mode == visual) && !menu";
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
          "space a n" = codexThread;
          "space a l" = "multi_workspace::ToggleWorkspaceSidebar";
          "space a s" = "agent::AddSelectionToThread";
          "space a t" = "workspace::ToggleRightDock";
        };
      }
      {
        context = "Editor && vim_mode == normal && !menu";
        bindings = {
          "space c a" = "editor::ToggleCodeActions";
          "space ." = "editor::ToggleCodeActions";
          "space c r" = "editor::Rename";
          "space c f" = "editor::Format";

          "g D" = "editor::GoToDefinitionSplit";
          "g i" = "editor::GoToImplementation";
          "g I" = "editor::GoToImplementationSplit";
          "g t" = "editor::GoToTypeDefinition";
          "g T" = "editor::GoToTypeDefinitionSplit";
          "g r" = "editor::FindAllReferences";

          "space x x" = "diagnostics::Deploy";

          "space g g" = centeredTask "lazygit";
          "space g b" = "git::Blame";
          "space g d" = "git::DiffHead";
          "space g c" = "git::CompareWithBranch";
          "space g D" = "editor::ExpandAllDiffHunks";

          "space d d" = centeredTask "lazydocker";
          "] h" = "editor::GoToHunk";
          "[ h" = "editor::GoToPreviousHunk";
          "space b d" = "pane::CloseActiveItem";
          "shift-q" = "pane::CloseActiveItem";
          "space b o" = "pane::CloseOtherItems";
          "space b b" = "pane::AlternateFile";
          "space b n" = "workspace::NewFile";
          "space b p" = "pane::TogglePinTab";
          "space ," = "tab_switcher::Toggle";
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
          "space a c" = [
            "task::Spawn"
            { task_name = "Claude Code"; }
          ];

          "] q" = "editor::MoveToStartOfNextExcerpt";
          "[ q" = "editor::MoveToStartOfExcerpt";
        }
        // lib.listToAttrs (
          map (
            i:
            lib.nameValuePair "space ${toString (i + 1)}" [
              "pane::ActivateItem"
              i
            ]
          ) (lib.range 0 8)
        );
      }
      {
        context = "Editor && vim_mode == visual && !menu";
        bindings = {
          "shift-j" = "editor::MoveLineDown";
          "shift-k" = "editor::MoveLineUp";
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
        bindings."b" = "vim::AnyBrackets";
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
        bindings = lib.genAttrs [ "ctrl-d" "ctrl-u" "n" "shift-n" "shift-g" ] (key: [
          "workspace::SendKeystrokes"
          "${key} z z"
        ]);
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
          "space r t" = "task::Spawn";
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
          "j" = "menu::SelectNext";
          "k" = "menu::SelectPrevious";
          "enter" = "project_panel::Open";
          "o" = "project_panel::Open";
          "shift-enter" = "project_panel::OpenPermanent";
          "v" = "project_panel::OpenPermanent";
          "q" = "workspace::ToggleLeftDock";
          "space e" = "project_panel::ToggleFocus";
          "escape" = "project_panel::ToggleFocus";
          "ctrl-6" = "pane::AlternateFile";
        };
      }
      {
        context = "GitPanel";
        bindings."q" = "git_panel::Close";
      }
      {
        context = "AgentPanel > Editor && vim_mode == normal";
        bindings."q" = "workspace::ToggleRightDock";
      }
    ];

    userTasks =
      map
        (
          task:
          task
          // {
            use_new_terminal = true;
            hide = "on_success";
            reveal_target = "center";
          }
        )
        [
          {
            label = "lazygit";
            command = "lazygit";
          }
          {
            label = "lazydocker";
            command = "lazydocker";
          }
          {
            label = "Claude Code";
            command = "claude";
          }
          {
            label = "Yazi (open file)";
            command = ''choice="$(mktemp -t zed-yazi)"; trap 'rm -f "$choice"' EXIT; yazi "$ZED_WORKTREE_ROOT" --chooser-file "$choice" && while IFS= read -r path; do zed -a "$path"; done < "$choice"'';
          }
        ];
  };
}
