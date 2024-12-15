{
  pkgs,
  ...
}:
{
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
        plugin = nvim-treesitter.withPlugins (
          plugins: with plugins; [
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
          ]
        );
        config = ''
          lua require 'nvim-treesitter.configs'.setup { highlight = { enable = true } }
        '';
      }
    ];
  };
}
