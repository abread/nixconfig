{
  hostConfig,
  config,
  inputs,
  pkgs,
  ...
}: {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "breda";
  home.homeDirectory = "/home/breda";

  home.packages = with pkgs; [
    fd
  ];

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    delta.enable = true;
    signing = {
      key = inputs.hidden.gitSigningKey.tightpants.breda;
      signByDefault = true;
    };
    ignores = [
      ".gdb_history"
      ".vscode"
    ];

    extraConfig = {
      user = {
        email = inputs.hidden.gitEmail.tightpants.breda;
        name = "André Breda";
      };
      gpg.format = "ssh";
      pull.ff = "only";
      init.defaultBranch = "main";
      credential = {
        credentialStore = "secretservice";
        helper = "${pkgs.gitAndTools.gitFull}/bin/git-credential-libsecret";
      };
    };
  };

  services.mpris-proxy.enable = true;

  programs.starship =
    hostConfig.programs.startship
    // {
      enable = true;
      packages = pkgs.startship;
      enableZshIntegration = true;
    };

  #  wayland.windowManager.sway = let
  #        terminal = "${pkgs.foot}/bin/foot";
  #        bemenu_opts = "-i -f --fn 'Fira Code 12' --nb '#100F10' --nf '#E0E6F0' --fb '#000000' --ff '#FFFFFF' --hb '#2A40B8' --hf '#FFFFFF' --scf '#34CFFF' -p '' -w -l 10'";
  #        modifier = "Mod4";
  #    in {
  #    enable = true;
  #    config = rec {
  #      inherit modifier terminal;
  #
  #      bars = [
  #        {
  #          command = "${pkgs.waybar}/bin/waybar";
  #        }
  #      ];
  #
  #      colors = {
  #        # based on modus-vivendi
  #
  #        background = "#000000";
  #        focused = {
  #          border = "#2A40B8";
  #          background = "#2A40B8";
  #          text = "#FFFFFF";
  #          indicator = "#2A40B8";
  #          childBorder = "#2A40B8";
  #        };
  #        focusedInactive = {
  #          border = "#0F0E39";
  #          background = "#0F0E39";
  #          text = "#E0E6F0";
  #          indicator = "#0F0E39";
  #          childBorder = "#0F0E39";
  #        };
  #        unfocused = {
  #          border = "#3A303B";
  #          background = "#110B11";
  #          text = "#E0E6F0";
  #          indicator = "#3A303B";
  #          childBorder = "#3A303B";
  #        };
  #        urgent = {
  #          border = "#8F0040";
  #          background = "#A4202A";
  #          text = "#FFFFFF";
  #          indicator = "#8F0040";
  #          childBorder = "#8F0040";
  #        };
  #        placeholder = {
  #          border = "#6F4A00";
  #          background = "#604200";
  #          text = "#BEBEBE";
  #          indicator = "#6F4A00";
  #          childBorder = "#6F4A00";
  #        };
  #      };
  #
  #      floating = {
  #        criteria = [
  #          {
  #            title = "Firefox - Sharing Indicator";
  #          }
  #          {
  #            title = "(Save|Open) (File|Folder)(s)?";
  #          }
  #        ];
  #      };
  #
  #      fonts = {
  #        names = ["IBM Plex Sans"];
  #        size = 12.0;
  #      };
  #
  #      input = {
  #        "2:14:ETPS/2_Elantech_Touchpad" = {
  #          dwt = "disabled";
  #          tap = "enabled";
  #          natural_scroll = "enabled";
  #          middle_emulation = "enabled";
  #          scroll_method = "two_finger";
  #        };
  #        "type:keyboard" = {
  #          xkb_layout = "pt";
  #          xkb_options = "caps:swapescape";
  #          repeat_delay = "300";
  #          repeat_rate = "50";
  #        };
  #      };
  #
  #      menu = "${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --dmenu='${pkgs.bemenu}/bin/bemenu ${bemenu_opts}' --term='${terminal}' --no-generic";
  #
  #      keybindings = lib.mkOptionDefault {
  #        "${modifier}+Return" = "exec ${pkgs.systemd}/bin/systemd-cat --identifier=swayterm ~/.local/bin/sway-shell.sh";
  #        "${modifier}+Shift+d" = "exec ${pkgs.bemenu}/bin/bemenu-run ${bemenu_opts} | xargs swaymsg exec --";
  #
  #        "${modifier}+0" = "workspace 10";
  #        "${modifier}+Shift+0" = "move container to workspace 10";
  #
  #        "Shift+${modifier}+v" = "splith";
  #
  #        # disable scratchpad keybindings
  #        "${modifier}+Shift+minus" = "exec true";
  #        "${modifier}+minus" = "exec true";
  #
  #        "${modifier}+Shift+c" = "exec true";
  #        "${modifier}+Shift+r" = "reload";
  #
  #        "XF86AudioMicMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
  #        "XF86Tools" = "exec pkill -USR1 swayidle";
  #        "Shift+Print" = "exec 'grim -g \"$(slurp)\" - | swappy -f -'";
  #        "Print" = "exec 'grim -g \"$(slurp)\" - | wl-copy -t image/png'";
  #        "XF86Display" = "exec ${pkgs.wdisplays}/bin/wdisplays";
  #      };
  #
  #    output = {
  #      e-DP1 = {
  #        pos = "0 0";
  #        resolution = "1920x1080";
  #        scale = "1";
  #        background = "#181A20 solid_color";
  #        adaptive_sync = "on";
  #        subpixel = "rgb";
  #      };
  #    };
  #
  #    startup = [
  #      #{ command = "systemd-cat --identifier=sway-session-helper /home/breda/.config/sway/session.sh -E XCURSOR_SIZE -E XDG_SEAT -E XDG_VTNR -E XDG_SESSION_CLASS -E XDG_SESSION_ID --with-cleanup"; }
  #
  #      # TODO: package
  #      { command = "systemd-cat --identifier=battery-popup ~/.local/bin/battery-popup.sh -L 20 -m 'CHARGE MEEEEEE!!!' -n"; }
  #
  #      # TODO: change to services.mako
  #      { command = "systemd-cat --identifier=mako mako"; }
  #    ];
  #
  #    window = {
  #      border = 0;
  #      commands = [
  #        {
  #          criteria.app_id = "Alacritty";
  #          command = "border normal";
  #        }
  #        {
  #          criteria.app_id = "foot";
  #          command = "border normal";
  #        }
  #        {
  #          criteria = { class = "vlc"; window_type = "normal"; };
  #          command = "border normal";
  #        }
  #        {
  #          criteria = { app_id = "eagle"; window_type = "normal"; };
  #          command = "border normal";
  #        }
  #        {
  #          criteria.class = "processing-app-Base";
  #          command = "border normal";
  #        }
  #        {
  #          criteria.title = "Firefox - Sharing Indicator";
  #          command = "border pixel 3";
  #        }
  #        {
  #          criteria.title = "Firefox - Sharing Indicator";
  #          command = "move absolute position 1840 990"; # TODO: do it more reliably maybe?
  #        }
  #      ];
  #    };
  #
  #    workspaceAutoBackAndForth = true;
  #
  #    };
  ##    extraSessionCommands = ''
  ##      export _JAVA_AWT_WM_NONREPARENTING=1
  ##      export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=lcd"
  ##      export QT_AUTO_SCREEN_SCALE_FACTOR=1
  ##      export QT_QPA_PLATFORM=wayland
  ##      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
  ##      export GDK_BACKEND=wayland
  ##      export NIXOS_OZONE_WL=1 # wayland in chrome/chromium/electron/...
  ##      export MOZ_ENABLE_WAYLAND=1
  ##      export MOZ_WEBRENDER=1
  ##      export MOZ_ACCELERATED=1
  ##    '';
  #
  #    extraConfig = ''
  #      bindsym --locked {
  #        XF86AudioMute exec "pactl set-sink-mute @DEFAULT_SINK@ toggle"
  #        XF86AudioLowerVolume exec "pactl set-sink-volume @DEFAULT_SINK@ -5%"
  #        XF86AudioRaiseVolume exec "pactl set-sink-volume @DEFAULT_SINK@ +5%"
  #        Shift+XF86AudioLowerVolume exec "pactl set-sink-volume @DEFAULT_SINK@ -1%"
  #        Shift+XF86AudioRaiseVolume exec "pactl set-sink-volume @DEFAULT_SINK@ +1%"
  #
  #        ${modifier}+P exec 'playerctl play-pause'
  #        ${modifier}+N exec 'playerctl next'
  #
  #        # headphones use this
  #        XF86AudioPlay exec 'playerctl play'
  #        XF86AudioPause exec 'playerctl pause'
  #        XF86AudioNext exec 'playerctl next'
  #        XF86AudioPrev exec 'playerctl previous'
  #
  #        Shift+XF86MonBrightnessUp exec "xbacklight -ctrl amdgpu_bl0 -inc 1 -fps 60"
  #        Shift+XF86MonBrightnessDown exec "xbacklight -ctrl amdgpu_bl0 -dec 1 -fps 60"
  #        XF86MonBrightnessUp exec "xbacklight -ctrl amdgpu_bl0 -inc 5 -fps 60"
  #        XF86MonBrightnessDown exec "xbacklight -ctrl amdgpu_bl0 -dec 5 -fps 60"
  #      }
  #
  #    '';
  #
  #    swaynag.enable = true;
  #    systemdIntegration = true;
  #    wrapperFeatures.gtk = true;
  #  };

  #  programs.swaylock = {
  #    enable = true;
  #    settings = {
  #      color = "181A20";
  #      ignore-empty-password = true;
  #      show-failed-attempts = true;
  #      font = "IBM Plex Sans";
  #    };
  #  };
  #
  #  services.swayidle = {
  #    enable = true;
  #    timeouts = [
  #      {
  #        timeout = 600;
  #        command = "swaymsg 'output * power off";
  #        resumeCommand = "swaymsg 'output * power on'";
  #      }
  #      { timeout = 610; command = "loginctl lock-session"; }
  #    ];
  #    events = [
  #      { event = "before-sleep"; command = "loginctl lock-session"; }
  #      { event = "lock"; command = "swaylock -f"; }
  #    ];
  #  };

  #  services.mako = {
  #    enable = true;
  #    defaultTimeout = 120000;
  #    font = "IBM Plex Sans 12";
  #
  #    extraConfig = ''
  #      on-button-left=dismiss
  #      on-button-middle=invoke-default-action
  #      on-button-right=dismiss-group
  #
  #      [app-name="discord"]
  #      group-by=summary
  #      default-timeout=10000
  #
  #      [app-name="Spotify"]
  #      default-timeout=1000
  #
  #      [app-name="Mattermost"]
  #      group-by=summary
  #      default-timeout=1000
  #    '';
  #  };

  services.playerctld.enable = true;
  systemd.user.services.playerctld.Install.WantedBy = ["sway-session.target"];

  services.kanshi = {
    enable = true;

    settings = [
      {
        profile = {
          name = "default";
          outputs = [
            {
              criteria = "eDP-1";
              status = "enable";
              position = "0,0";
            }
          ];
        };
      }
      {
        profile = {
          name = "rnl";
          outputs = [
            {
              criteria = "Iiyama North America PL3293UH 1213432400569";
              status = "enable";
              position = "0,0";
              scale = 1.2;
            }
            {
              criteria = "eDP-1";
              status = "enable";
              position = "640,1801";
            }
          ];
          exec = "swaymsg workspace 2, move workspace to 'Iiyama North America PL3293UH 1213432400569', workspace 3, move workspace to 'Iiyama North America PL3293UH 1213432400569'";
        };
      }
      {
        profile = {
          name = "rnl2";
          outputs = [
            {
              criteria = "Iiyama North America PL3293UH 1213432400967";
              status = "enable";
              position = "0,0";
              scale = 1.2;
            }
            {
              criteria = "eDP-1";
              status = "enable";
              position = "640,1801";
            }
          ];
          exec = "swaymsg workspace 2, move workspace to 'Iiyama North America PL3293UH 1213432400967', workspace 3, move workspace to 'Iiyama North America PL3293UH 1213432400967'";
        };
      }
      {
        profile = {
          name = "rnl3";
          outputs = [
            {
              criteria = "Iiyama North America PL3293UH 1213432700309";
              status = "enable";
              position = "0,0";
              scale = 1.2;
            }
            {
              criteria = "eDP-1";
              status = "enable";
              position = "640,1801";
            }
          ];
          exec = "swaymsg workspace 2, move workspace to 'Iiyama North America PL3293UH 1213432700309', workspace 3, move workspace to 'Iiyama North America PL3293UH 1213432700309'";
        };
      }
    ];
  };

  services.blueman-applet.enable = true;
  services.network-manager-applet.enable = true;

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    envExtra = ''
      if [[ -z $DISPLAY ]] && [[ "a$XDG_SESSION_TYPE" = "atty" ]] && [[ $(tty) = /dev/tty1 ]]; then
          export PATH="$HOME/.local/waybin:$PATH"
          export XDG_DATA_DIRS="$XDG_DATA_DIRS:/usr/share" # we put fonts there and flatpak struggles
          export _JAVA_AWT_WM_NONREPARENTING=1
          export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=lcd"
          export QT_AUTO_SCREEN_SCALE_FACTOR=1
          export QT_QPA_PLATFORM="wayland;xcb"
          export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
          export QT_AUTO_SCREEN_SCALE_FACTOR=1
          export GDK_BACKEND=wayland,x11
          export SDL_VIDEODRIVER=wayland
          export CLUTTER_BACKEND=wayland
          export NIXOS_OZONE_WL=1 # wayland in chrome/chromium/electron/...
          export MOZ_ENABLE_WAYLAND=1
          export MOZ_WEBRENDER=1
          export MOZ_ACCELERATED=1
          export LIBVA_DRIVER_NAME="radeonsi"
          export VDPAU_DRIVER="radeonsi"
          export AMD_VULKAN_ICD=RADV
          export VK_ICD_FILENAMES="/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json"

          eval "$(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)"
          export SSH_AUTH_SOCK

          # let subshells use new vars (after switching home-manager generation)
          unset __HM_ZSH_SESS_VARS_SOURCED

          exec systemd-cat --identifier=sway sway
      fi
    '';

    sessionVariables = {
      GTK_THEME = "Adwaita:dark";
      TERMINAL = "alacritty -e";
      EDITOR = "nvim";
      BROWSER = "chromium";
      PATH = "$HOME/.local/bin:$HOME/go/bin:$HOME/.cargo/bin:$PATH";
      DICPATH = "~/.local/share/hunspell:$DICPATH";
      FZF_DEFAULT_COMMAND = "${pkgs.ripgrep}/bin/rg --files --no-ignore --hidden --follow --glob '!.git/*'";
      ELECTRON_TRASH = "gio";
      SCCACHE_DIR = "/var/cache/sccache";
      SCCACHE_MAX_FRAME_LENGTH = "104857600";
      VAGRANT_DEFAULT_PROVIDER = "libvirt";
      DOTNET_CLI_TELEMETRY_OPTOUT = "1";
      PROTOC = "/run/current-system/sw/bin/protoc";
    };

    initExtraBeforeCompInit = ''
      setopt extendedglob nomatch
      setopt no_beep
      setopt interactive_comments

      # Case-insensitive completions
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

      # Show what I selected during tab completions
      zstyle ':completion:*' menu select

      # can't really be an alias, so let's define a function instead
      function ldapsearch() {
          _binddn="uid=ist189409,ou=People,dc=ist,dc=utl,dc=pt" # spellchecker:disable-line
          /run/current-system/sw/bin/ldapsearch -D "$_binddn" -y <(pass show tecnico.ulisboa.pt/ist189409 | tr -d '\n') "$@"
      }
    '';

    initExtra = ''
      autoload edit-command-line
      zle -N edit-command-line
      bindkey '^X^E' edit-command-line

      ${pkgs.any-nix-shell}/bin/any-nix-shell zsh --info-right | source /dev/stdin
    '';

    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    enableVteIntegration = true;

    autocd = true;

    shellAliases = {
      open = "xdg-open";
      ls = "eza";
      l = "eza -l";
      ll = "eza -l";
      la = "eza -la";
      ip = "ip --color=auto";
      youtube-dl = "yt-dlp";
      grep = "rg";
      restic = "restic -r rclone:b2-backups-tightpants:backups-tightpants --password-command 'pass show restic-backups/tightpants'";
    };
    history = {
      save = 20000000;
      size = 1000000;
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    historySubstringSearch = {
      enable = true;
      searchUpKey = "$terminfo[kcuu1]";
      searchDownKey = "$terminfo[kcud1]";
    };
    defaultKeymap = "emacs";
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    extraConfig = ''
      set mouse=a
      set relativenumber
      set termguicolors
      set clipboard=unnamed
      filetype indent on
    '';
    extraPackages = with pkgs; [
      python312Packages.python-lsp-server
      rust-analyzer
    ];
    plugins = with pkgs.vimPlugins; [
      editorconfig-nvim
      vim-sleuth
      {
        plugin = lualine-nvim;
        config = "lua require 'lualine'.setup()";
      }
      {
        plugin = telescope-nvim;
        config = ''
          lua <<EOF
          require 'telescope'.setup()
          local builtin = require 'telescope.builtin'
          vim.keymap.set('n', 'ff', builtin.find_files, {})
          vim.keymap.set('n', 'fg', builtin.live_grep, {})
          vim.keymap.set('n', 'fb', builtin.buffers, {})
          vim.keymap.set('n', 'fh', builtin.help_tags, {})
          EOF
        '';
      }
      {
        plugin = project-nvim;
        config = ''
          lua <<EOF
          require 'project_nvim'.setup()
          require('telescope').load_extension('projects')
          EOF
        '';
      }
      {
        plugin = nvim-tree-lua;
        config = ''
          lua <<EOF
          local tree = require('nvim-tree')
          tree.setup {
            sync_root_with_cwd = true,
            respect_buf_cwd = true,
            update_focused_file = {
              enable = true,
              update_root = true,
            },
          }


          vim.keymap.set('n', 'tt', function() tree.toggle(false) end)
          EOF
        '';
      }
      {
        plugin = nvim-autopairs;
        config = "lua require 'nvim-autopairs'.setup()";
      }
      cmp-nvim-lsp
      {
        plugin = nvim-lspconfig;
        config = ''
          lua <<EOF
          -- Mappings.
          -- See `:help vim.diagnostic.*` for documentation on any of the below functions
          local opts = { noremap=true, silent=true }
          vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
          vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

          -- Use an on_attach function to only map the following keys
          -- after the language server attaches to the current buffer
          local on_attach = function(client, bufnr)
            -- Enable completion triggered by <c-x><c-o>
            vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

            -- Mappings.
            -- See `:help vim.lsp.*` for documentation on any of the below functions
            local bufopts = { noremap=true, silent=true, buffer=bufnr }
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
            vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
            vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
            vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
            vim.keymap.set('n', '<space>wl', function()
              print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, bufopts)
            vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
            vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
            vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
            vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
          end

          -- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
          local capabilities = require('cmp_nvim_lsp').default_capabilities()

          require 'lspconfig'.rust_analyzer.setup { on_attach = on_attach, capabilities = capabilities }
          require 'lspconfig'.gopls.setup { on_attach = on_attach, capabilities = capabilities }
          require 'lspconfig'.pylsp.setup { on_attach = on_attach, capabilities = capabilities }
          require 'lspconfig'.clangd.setup { on_attach = on_attach, capabilities = capabilities }
          EOF
        '';
      }
      {
        plugin = luasnip;
        config = ''
          " press <Tab> to expand or jump in a snippet. These can also be mapped separately
          " via <Plug>luasnip-expand-snippet and <Plug>luasnip-jump-next.
          imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>'
          " -1 for jumping backwards.
          inoremap <silent> <S-Tab> <cmd>lua require'luasnip'.jump(-1)<Cr>

          snoremap <silent> <Tab> <cmd>lua require('luasnip').jump(1)<Cr>
          snoremap <silent> <S-Tab> <cmd>lua require('luasnip').jump(-1)<Cr>

          " For changing choices in choiceNodes (not strictly necessary for a basic setup).
          imap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
          smap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
        '';
      }
      cmp_luasnip
      cmp-path
      cmp-buffer
      {
        plugin = nvim-cmp;
        config = ''
          lua <<EOF
          local cmp = require 'cmp'

          cmp.setup {
            snippet = {
              -- REQUIRED - you must specify a snippet engine
              expand = function(args)
                -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
                -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
              end,
            },
            window = {
              -- completion = cmp.config.window.bordered(),
              -- documentation = cmp.config.window.bordered(),
            },
            mapping = cmp.mapping.preset.insert({
              ['<C-b>'] = cmp.mapping.scroll_docs(-4),
              ['<C-f>'] = cmp.mapping.scroll_docs(4),
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<C-e>'] = cmp.mapping.abort(),
              ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            }),
            sources = cmp.config.sources({
              { name = 'nvim_lsp' },
              -- { name = 'vsnip' }, -- For vsnip users.
              { name = 'luasnip' }, -- For luasnip users.
              -- { name = 'ultisnips' }, -- For ultisnips users.
              -- { name = 'snippy' }, -- For snippy users.
            }, {
              { name = 'buffer' },
              {
                name = 'path',
                -- TODO: set get_cwd to get_project_root or sth
              },
            })
          }

          -- make autopairs work
          local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
          cmp.event:on(
            'confirm_done',
            cmp_autopairs.on_confirm_done()
          )
          EOF
        '';
      }
      {
        plugin = rust-tools-nvim;
        config = "lua require 'rust-tools'.setup()";
      }
      Coqtail
      {
        plugin = nvim-treesitter.withPlugins (plugins:
          with plugins; [
            tree-sitter-c
            tree-sitter-go
            tree-sitter-zig
            tree-sitter-vue
            tree-sitter-tsx
            tree-sitter-php
            tree-sitter-nix
            tree-sitter-hcl
            tree-sitter-lua
            tree-sitter-css
            tree-sitter-cpp
            tree-sitter-yaml
            tree-sitter-toml
            tree-sitter-scss
            tree-sitter-rust
            tree-sitter-ruby
            tree-sitter-perl
            tree-sitter-make
            tree-sitter-llvm
            tree-sitter-json
            tree-sitter-java
            tree-sitter-http
            tree-sitter-html
            tree-sitter-bash
            tree-sitter-swift
            tree-sitter-regex
            tree-sitter-latex
            tree-sitter-julia
            tree-sitter-gomod
            tree-sitter-elisp
            tree-sitter-cmake
            tree-sitter-svelte
            tree-sitter-python
            tree-sitter-kotlin
            tree-sitter-bibtex
            tree-sitter-haskell
            tree-sitter-comment
            tree-sitter-c-sharp
            tree-sitter-markdown
            tree-sitter-typescript
            tree-sitter-javascript
            tree-sitter-dockerfile
            tree-sitter-devicetree
          ]);
        config = ''
          lua require 'nvim-treesitter.configs'.setup { highlight = { enable = true } }
        '';
      }
    ];
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";
}
