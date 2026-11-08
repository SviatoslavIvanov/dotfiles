{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  source = ../configs/pi;
  agentDir = config.programs.pi-coding-agent.configDir;
  pi =
    (pkgs.callPackage "${inputs.pi-src}/nix/package.nix" {
      source = inputs.pi-src;
      # Pi 1.5.0's recipe omits pi-schema from its workspace overrides, so pin the published tarball.
      importNpmLock = pkgs.importNpmLock // {
        importNpmLock =
          args:
          pkgs.importNpmLock (
            args
            // lib.optionalAttrs (args ? packageSourceOverrides) {
              packageSourceOverrides = args.packageSourceOverrides // {
                "node_modules/@earendil-works/pi-schema" = pkgs.fetchurl {
                  url = "https://registry.npmjs.org/@earendil-works/pi-schema/-/pi-schema-1.5.0.tgz";
                  hash = "sha512-RW0MbT2tR65OY6xMsgB/yVBb7m/RTNwA+9hurSN1vVXfHZRVmVnXbruBPrx/PzbrQnW5yLVlMRWxErGDQtF1Hg==";
                };
              };
            }
          );
      };
    }).overrideAttrs
      (old: {
        # Cosmetic patches; --replace-fail breaks the build when upstream renames a patched line.
        postInstall = (old.postInstall or "") + ''
          chunks="$out"/lib/pi/node_modules/@earendil-works/pi-coding-agent/dist/bundle/chunks

          # Slash-menu descriptions without "[u:npm:pkg@version]" source tags.
          chunk=$(grep -l 'getAutocompleteSourceTag(sourceInfo){' "$chunks"/*.js)
          substituteInPlace "$chunk" --replace-fail \
            'getAutocompleteSourceTag(sourceInfo){if(!sourceInfo||' \
            'getAutocompleteSourceTag(sourceInfo){if(true||!sourceInfo||'

          # Autocomplete menu above the editor, so the prompt line never jumps; mouse mapping follows.
          chunk=$(grep -l 'this.editorContainer=new Container,this.editorContainer.addChild(this.editor)' "$chunks"/*.js)
          substituteInPlace "$chunk" --replace-fail \
            'this.editorContainer=new Container,this.editorContainer.addChild(this.editor)' \
            'this.editorContainer=new Container,this.editorContainer.render=function(w){let l=Container.prototype.render.call(this,w),s=0;for(let c of this.mouseLayout.children){let h=c.component.renderedAutocompleteHeight;if(h>0&&h<c.height){let b=l.slice(s,s+c.height);l.splice(s,c.height,...b.slice(-h),...b.slice(0,-h))}s+=c.height}return l},this.editorContainer.addChild(this.editor)'
          chunk=$(grep -l 'handleMouse(event){let autocompleteStartRow=this.renderedVisibleLineCount+2;' "$chunks"/*.js)
          substituteInPlace "$chunk" \
            --replace-fail \
              'handleMouse(event){let autocompleteStartRow=this.renderedVisibleLineCount+2;' \
              'handleMouse(event){let autocompleteStartRow=0;' \
            --replace-fail \
              'if(event.type!=="click"||event.button!=="left")return;if(event.y<=0||event.y>this.renderedVisibleLineCount)' \
              'if(event.type!=="click"||event.button!=="left")return;event={...event,y:event.y-this.renderedAutocompleteHeight};if(event.y<=0||event.y>this.renderedVisibleLineCount)'
        '';
      });
  piMcpFields = {
    context7 = {
      exposure = "direct";
      description = "Current library and CLI documentation. Resolve the library ID, then query docs.";
    };
    linear.description = "Work issues and projects in Linear.";
    sentry.description = "Investigate Sentry issues, events, traces and releases.";
    posthog.description = "Query PostHog product analytics, feature flags and experiments.";
  };
  mcpServers = lib.mapAttrs (
    name: server:
    lib.hm.mcp.transformMcpServer {
      inherit server;
      extraTransforms = [ lib.hm.mcp.addType ];
    }
    // piMcpFields.${name} or { }
  ) config.programs.mcp.servers;
  managedFiles = [
    "README.md"
    "LICENSES"
    "extension-sources.json"
    "subagents-lite.json"
    "interactive-shell.json"
    "next-prompt.json"
    "stt.json"
    "web-search.json"
    "agents"
    "extensions"
    "themes"
    "npm/patches"
  ];
in
{
  programs.pi-coding-agent = {
    enable = true;
    package = pi;
    keybindings = builtins.fromJSON (builtins.readFile (source + "/keybindings.json"));
    models = builtins.fromJSON (builtins.readFile (source + "/models.json"));
    mutableSettings = true;
    settings = builtins.fromJSON (builtins.readFile (source + "/settings.json"));
    appendSystem = source + "/APPEND_SYSTEM.md";
  };

  # pi-web-access uses XDG paths even though Pi uses ~/.pi/agent.
  xdg.configFile."pi/web-search.json".source = source + "/web-search.json";
  xdg.configFile."ponytail/config.json".source = source + "/ponytail.json";

  home = {
    file =
      lib.listToAttrs (
        map (
          name:
          lib.nameValuePair "${agentDir}/${name}" {
            source = source + "/${name}";
            recursive = true;
          }
        ) managedFiles
      )
      // {
        "${agentDir}/mcp.json".text = builtins.toJSON { inherit mcpServers; };
      };

    # Explicit maintenance, never network access or npm installation during activation.
    packages = [
      (pkgs.writeShellApplication {
        name = "pi-restore-extensions";
        runtimeInputs = [
          pkgs.nodejs_22
          pkgs.coreutils
        ];
        text = ''
          echo 'Stop all Pi sessions before restoring extensions.' >&2
          agent="${agentDir}"
          mkdir -p "$agent/npm"
          install -m 600 ${source}/npm/package.json "$agent/npm/package.json"
          install -m 600 ${source}/npm/package-lock.json "$agent/npm/package-lock.json"
          cd "$agent/npm"
          # Match Pi: host-provided peers must not install a second Pi runtime.
          npm ci --ignore-scripts --legacy-peer-deps --no-audit --no-fund
          node node_modules/patch-package/index.js --error-on-fail
        '';
      })
    ];
  };
}
