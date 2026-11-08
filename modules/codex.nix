{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Field mapping follows Home Manager's programs.codex MCP integration.
  toCodexServer =
    _: server:
    lib.hm.mcp.transformMcpServer {
      inherit server;
      exclude = [
        "headers"
        "type"
      ];
      extraTransforms = [
        (s: s // lib.optionalAttrs (s.headers or { } != { }) { http_headers = s.headers; })
      ];
    };

  managed = (pkgs.formats.toml { }).generate "codex-config.toml" {
    approval_policy = "never";
    sandbox_mode = "danger-full-access";
    mcp_servers = lib.mapAttrs toCodexServer config.programs.mcp.servers;
  };
in
{
  # Not programs.codex: with preferXdgDirectories it moves CODEX_HOME where the ChatGPT app never looks.
  home.activation.codexConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] (
    lib.hm.generators.mkImpureConfigMerger {
      inherit pkgs;
      format = "toml";
      empty = "{}";
      jqOperation = "$dynamic * $static";
      path = "${config.home.homeDirectory}/.codex/config.toml";
      staticSettings = managed;
      mode = "600";
    }
  );
}
