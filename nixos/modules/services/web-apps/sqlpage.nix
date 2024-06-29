{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.sqlpage;

  sqlpageInstanceOpts = { name, config, ... }: {
    options = {
      enable = mkEnableOption "SQLPage instance ${name}";

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/sqlpage/${name}";
        description = "The directory where SQLPage instance ${name} will store its data.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.sqlpage;
        description = "The SQLPage package to use for instance ${name}.";
      };

      port = mkOption {
        type = types.port;
        description = "The port on which SQLPage instance ${name} will listen.";
      };

      user = mkOption {
        type = types.str;
        default = "sqlpage-${name}";
        description = "The user under which SQLPage instance ${name} will run.";
      };

      group = mkOption {
        type = types.str;
        default = "sqlpage-${name}";
        description = "The group under which SQLPage instance ${name} will run.";
      };

      config = mkOption {
        type = types.attrs;
        default = {};
        description = "SQLPage configuration options for instance ${name}.";
      };
    };
  };

in {
  options.services.sqlpage = mkOption {
    type = types.attrsOf (types.submodule sqlpageInstanceOpts);
    default = {};
    description = "Attribute set of SQLPage instances.";
  };

  config = mkMerge (mapAttrsToList (name: instanceCfg:
    mkIf instanceCfg.enable {
      systemd.services."sqlpage-${name}" = {
        description = "SQLPage Service (${name})";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        environment = {
          LISTEN_ON = ":${toString instanceCfg.port}";
        };
        serviceConfig = {
          ExecStart = "${instanceCfg.package}/bin/sqlpage";
          Restart = "always";
          User = instanceCfg.user;
          Group = instanceCfg.group;
          WorkingDirectory = instanceCfg.dataDir;
        };
      };

      users.users.${instanceCfg.user} = mkIf (instanceCfg.user == "sqlpage-${name}") {
        isSystemUser = true;
        group = instanceCfg.group;
        home = instanceCfg.dataDir;
        createHome = true;
      };

      users.groups.${instanceCfg.group} = mkIf (instanceCfg.group == "sqlpage-${name}") {};

      environment.etc."sqlpage-${name}/sqlpage.json" = mkIf (instanceCfg.config != {}) {
        text = builtins.toJSON instanceCfg.config;
      };

      system.activationScripts."sqlpageConfig-${name}" = mkIf (instanceCfg.config != {}) {
        text = ''
          mkdir -p ${instanceCfg.dataDir}/sqlpage
          ln -sf /etc/sqlpage-${name}/sqlpage.json ${instanceCfg.dataDir}/sqlpage/sqlpage.json
        '';
      };
    }
  ) cfg);
}
