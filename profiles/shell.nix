{
  lib,
  inputs,
  pkgs,
  ...
}:
{
  # Configure the shell itself
  programs.bash = {
    completion.enable = true;
    enableLsColors = true;
    # TODO: Add auto logout on tty[1-6] after 30 minutes of inactivity
  };
  users.defaultUserShell = lib.mkDefault pkgs.bashInteractive;

  # Keep SSH_CONNECTION env variable when using sudo
  # This allows starship to correctly detect that we are ssh-ed into a remote host
  # when using sudo -i/sudo -s/etc.
  security.sudo.extraConfig = ''
    Defaults:root,%wheel env_keep+=SSH_CONNECTION
  '';

  # Prompt
  programs.starship = {
    enable = true;

    settings = {
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };
      cmd_duration.min_time = 500; # ms
      time = {
        disabled = false;
        time_range = "23:00:00-08:30:00";
      };
      gcloud.disabled = true;
      hostname.style = "bold green"; # ensure hostname is *very* visible (default is bold dimmed green)
      nix_shell.disabled = true;
    };
  };

  # Make nix-shell/nix shell/nix run/etc. work
  nix = {
    registry = {
      # pin flake registry
      self.flake = inputs.self;
      nixpkgs = {
        from = {
          id = "nixpkgs";
          type = "indirect";
        };
        flake = inputs.nixpkgs;
      };
    };

    # Set flake inputs as NIX_PATH channels.
    # This allows nix-shell to work as if a channel exists with the exact copy of nixpkgs
    # (or unstable) that is provided as a flake input. Without it, a user must somehow create
    # channels or set NIX_PATH themselves to use legacy nix commands.
    nixPath = [
      "nixpkgs=${inputs.nixpkgs.outPath}"

      # This entry exists in the original NIX_PATH but makes no sense in our machines,
      # as /etc/nixos/configuration.nix does not even exist.
      # "nixos-configuration=/etc/nixos/configuration.nix"
    ];
  };

  # Misc shell utilities
  environment = {
    systemPackages = with pkgs; [
      # Networking
      iproute2

      # Misc
      eza
      curl
      file
      lsof
      molly-guard # Prevents accidental shutdowns/reboots
      ripgrep
      strace
      tcpdump
      netcat
      iotop
      iftop
    ];

    variables = {
      HISTTIMEFORMAT = "%y-%m-%d %T ";
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;

    configure = {
      customRC = ''
        set mouse=a
        set relativenumber
        set termguicolors
        set clipboard=unnamed
        filetype indent on
        set list
        set listchars=tab:>\ ,trail:·,nbsp:·
      '';
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ vim-nix ];
      };
    };
  };

  programs.htop = {
    enable = true;
    settings = {
      show_program_path = false;
      hide_kernel_threads = true;
      hide_userland_threads = true;
    };
  };

  programs.tmux = {
    enable = true;
  };
}
