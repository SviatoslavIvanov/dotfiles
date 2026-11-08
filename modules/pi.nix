{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  source = ../configs/pi;
  pi =
    (pkgs.callPackage "${inputs.pi-src}/nix/package.nix" {
      source = inputs.pi-src;
      # Pi 1.5.0's Nix recipe omits pi-schema from its workspace overrides;
      # the install lock has no integrity for it. Pin the published tarball instead.
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
        # Cosmetic patches of the bundled CLI. --replace-fail makes a renamed upstream line fail
        # the build loudly; then drop or update the patch.
        postInstall = (old.postInstall or "") + ''
          chunks="$out"/lib/pi/node_modules/@earendil-works/pi-coding-agent/dist/bundle/chunks

          # Slash-menu descriptions without "[u:npm:pkg@version]" source tags.
          chunk=$(grep -l 'getAutocompleteSourceTag(sourceInfo){' "$chunks"/*.js)
          substituteInPlace "$chunk" --replace-fail \
            'getAutocompleteSourceTag(sourceInfo){if(!sourceInfo||' \
            'getAutocompleteSourceTag(sourceInfo){if(true||!sourceInfo||'

          # Autocomplete menu above the editor, so the prompt line never jumps. The editor still
          # renders the menu last (extensions decorate its first lines); the container moves the
          # menu rows above it, and the editor's mouse mapping follows.
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
  stt = builtins.fromJSON (builtins.readFile (source + "/stt.json"));
  managedFiles = [
    "README.md"
    "LICENSES"
    "extension-sources.json"
    "mcp.json"
    "subagents-lite.json"
    "interactive-shell.json"
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
    # This Home Manager revision lacks mutableSettings; do not symlink settings.json.
  };

  # pi-web-access uses XDG paths even though Pi uses ~/.pi/agent.
  xdg.configFile."pi/web-search.json".source = source + "/web-search.json";
  xdg.configFile."ponytail/config.json".source = source + "/ponytail.json";

  home = {
    file =
      lib.genAttrs (map (name: ".pi/agent/${name}") managedFiles) (name: {
        source = source + "/${lib.removePrefix ".pi/agent/" name}";
        recursive = true;
      })
      // {
        # Pi loads one context file per directory and has no imports.
        ".pi/agent/AGENTS.md".text =
          builtins.readFile ../configs/agents/AGENTS.md + "\n" + builtins.readFile (source + "/AGENTS.md");
        ".pi/agent/stt.json".text = builtins.toJSON (
          stt
          // {
            capture = stt.capture // {
              ffmpegPath = "${pkgs.ffmpeg}/bin/ffmpeg";
            };
            provider = stt.provider // {
              apiKey = "!${pkgs.jq}/bin/jq -er '.[\"openai-api\"] | select(.type == \"api_key\") | .key | select(type == \"string\" and length > 0)' \"${config.home.homeDirectory}/.pi/agent/auth.json\"";
            };
          }
        );
      };

    activation.piSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run env PATH="${
        lib.makeBinPath [
          pkgs.jq
          pkgs.coreutils
        ]
      }:$PATH" \
        ${pkgs.bash}/bin/bash ${source}/merge-settings.sh \
        "$HOME/.pi/agent/settings.json" ${source}/settings.json
    '';

    activation.piLauncher = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run env PATH="${lib.makeBinPath [ pkgs.coreutils ]}:$PATH" \
        ${pkgs.bash}/bin/bash ${source}/prefer-nix.sh \
        /opt/homebrew/bin/pi "$HOME/.pi/agent/bin/pi" ${pi}/bin/pi
    '';

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
          agent="$HOME/.pi/agent"
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
