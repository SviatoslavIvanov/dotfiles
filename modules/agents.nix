{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  rules = ../configs/agents/AGENTS.md;

  skills = {
    ui-taste = ../configs/agents/skills/ui-taste;
    frontend-design = "${inputs.claude-plugins-official}/plugins/frontend-design/skills/frontend-design";
    playwright-cli = "${inputs.playwright-cli}/skills/playwright-cli";
  }
  // lib.genAttrs [
    "sentry-create-alert"
    "sentry-debug-issue"
    "sentry-fix-stack-traces"
    "sentry-get-started"
    "sentry-instrument"
    "sentry-setup-releases"
  ] (name: "${inputs.sentry-plugin-claude}/skills/${name}");
in
{
  programs = {
    mcp = {
      enable = true;
      servers = {
        context7.url = "https://mcp.context7.com/mcp/oauth";
        linear.url = "https://mcp.linear.app/mcp";
        sentry.url = "https://mcp.sentry.dev/mcp";
        posthog.url = "https://mcp.posthog.com/mcp";
      };
    };

    claude-code = {
      context = rules;
      inherit skills;
    };

    pi-coding-agent.context = rules;
  };

  home = {
    file = {
      ".codex/AGENTS.md".source = rules;
    }
    # Agent Skills location read natively by Codex, Pi and Zed; Claude Code gets the same set above.
    // lib.mapAttrs' (
      name: source:
      lib.nameValuePair ".agents/skills/${name}" {
        inherit source;
        recursive = true;
      }
    ) skills;

    # Project-scoped .mcp.json files call it by name.
    packages = [ inputs.mcp-nixos.packages.${pkgs.stdenv.hostPlatform.system}.default ];
  };
}
