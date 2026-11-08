{
  config,
  lib,
  pkgs,
  ...
}:

let
  homeAudit = pkgs.writeShellApplication {
    name = "home-audit";
    runtimeInputs = with pkgs; [ coreutils ];
    text = ''
      shopt -s nullglob

      home_dir="''${HOME:?HOME is not set}"
      count=0
      show_sizes=false

      case "''${1:-}" in
        "")
          ;;
        --sizes)
          show_sizes=true
          ;;
        -h|--help)
          printf 'Usage: home-audit [--sizes]\n'
          exit 0
          ;;
        *)
          printf 'Unknown argument: %s\n' "$1" >&2
          exit 2
          ;;
      esac

      if [[ "$show_sizes" == true ]]; then
        printf '%-10s %8s  %s\n' "KIND" "SIZE" "ENTRY"
      else
        printf '%-10s  %s\n' "KIND" "ENTRY"
      fi

      for path in "$home_dir"/.* "$home_dir"/*; do
        name="''${path##*/}"

        case "$name" in
          .|..)
            continue
            ;;
        esac

        if [[ -L "$path" ]]; then
          target=$(readlink "$path")
          case "$target" in
            /nix/store/*-home-manager-files/*)
              continue
              ;;
          esac
        fi

        # Intentional roots; everything else stays visible until allow-listed here.
        case "$name" in
          .1password|.cache|.CFUserTextEncoding|.config|.DS_Store|.gnupg|.local|.nix-profile|.ssh|.Trash|Applications|Desktop|Developer|Documents|Downloads|Library|Movies|Music|Pictures|Public)
            continue
            ;;
        esac

        kind="unmanaged"
        case "$name" in
          *backup*|*.bak|*.old)
            kind="backup"
            ;;
        esac

        if [[ "$show_sizes" == true ]]; then
          size=$(du -sh "$path" 2>/dev/null | cut -f1 || true)
          printf '%-10s %8s  %s\n' "$kind" "''${size:-?}" "$name"
        else
          printf '%-10s  %s\n' "$kind" "$name"
        fi
        count=$((count + 1))
      done

      if (( count == 0 )); then
        printf '\nNo unmanaged home entries found.\n'
      else
        printf '\n%d unmanaged entries; this command never deletes anything.\n' "$count"
      fi
    '';
  };
  stateFiles = {
    NODE_REPL_HISTORY = "${config.xdg.stateHome}/node/repl_history";
    PSQL_HISTORY = "${config.xdg.stateHome}/postgresql/history";
    PYTHON_HISTORY = "${config.xdg.stateHome}/python/history";
  };
  wgetHsts = "${config.xdg.stateHome}/wget/hsts";
in
{
  home = {
    sessionVariables = stateFiles // {
      ANSIBLE_CONFIG = "${config.xdg.configHome}/ansible/ansible.cfg";
      ANSIBLE_GALAXY_CACHE_DIR = "${config.xdg.cacheHome}/ansible/galaxy";
      ANSIBLE_LOCAL_TEMP = "${config.xdg.cacheHome}/ansible/tmp";
      NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
      WGETRC = "${config.xdg.configHome}/wget/wgetrc";
    };

    # These tools write their state files but do not create the parent directories.
    activation.createXdgStateDirectories = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p ${lib.escapeShellArgs (map dirOf (lib.attrValues stateFiles ++ [ wgetHsts ]))}
    '';

    packages = [ homeAudit ];
  };

  xdg.configFile = {
    "ansible/ansible.cfg".text = ''
      [defaults]
      forks = 20

      [ssh_connection]
      pipelining = True
    '';

    "wget/wgetrc".text = ''
      hsts-file = ${wgetHsts}
    '';
  };
}
