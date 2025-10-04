{ inputs, pkgs, lib, minimal ? false, ... }:

let
  mkPlugin = name:
    pkgs.vimUtils.buildVimPlugin {
      inherit name;
      src = inputs.neovim-plugins.${name};
    };

  custom = {
    avante = {
      plugin = pkgs.vimPlugins.avante-nvim;
      type = "lua";
      config = builtins.readFile ./avante.lua;
    };

    conform = {
      plugin = mkPlugin "conform-nvim";
      type = "lua";
      config = builtins.readFile ./conform.lua;
    };

    copilot-chat = {
      plugin = (mkPlugin "copilot-chat-nvim").overrideAttrs {
        checkInputs = with pkgs.vimPlugins; [
          fzf-lua
          telescope-nvim
          snacks-nvim
        ];
        dependencies = with pkgs.vimPlugins; [ copilot-lua plenary-nvim ];
      };
      type = "lua";
      config = builtins.readFile ./copilot-chat.lua;
    };

    copilot-cmp = {
      plugin = pkgs.vimPlugins.copilot-cmp;
      type = "lua";
      config = ''
        require("copilot_cmp").setup()
      '';
    };

    copilot-lua = {
      plugin = pkgs.vimPlugins.copilot-lua;
      type = "lua";
      config = ''
        require("copilot").setup({
          -- suggestion  = { enabled = false },
          -- panel       = { enabled = false },
        })
      '';
    };

    dashboard = {
      plugin = pkgs.vimPlugins.alpha-nvim;
      type = "lua";
      config = builtins.readFile ./dashboard.lua;
    };

    gruvbox = { # Lua port of gruvbox-community w/ treesitter support
      plugin = pkgs.vimPlugins.gruvbox-nvim;
      type = "lua";
      config = ''
        require("gruvbox").setup({ contrast = "hard" })
        vim.cmd.colorscheme("gruvbox")
      '';
    };

    leap-nvim = {
      plugin = pkgs.vimPlugins.leap-nvim;
      type = "lua";
      config = "require('leap').add_default_mappings()";
    };

    lspconfig = {
      plugin = pkgs.vimPlugins.nvim-lspconfig;
      type = "lua";
      config = builtins.readFile ./lspconfig.lua;
    };

    lsp-selection-range = {
      plugin = mkPlugin "nvim-lsp-selection-range";
      type = "lua";
      config = "require('lsp-selection-range')";
    };

    lualine-nvim = {
      plugin = pkgs.vimPlugins.lualine-nvim;
      type = "lua";
      config = builtins.readFile ./lualine.lua;
    };

    mini = {
      plugin = pkgs.vimPlugins.mini-nvim;
      type = "lua";
      config = builtins.readFile ./mini.lua;
    };

    neotest = {
      plugin = pkgs.vimPlugins.neotest;
      type = "lua";
      config = ''
        require("neotest").setup({
          adapters = {
            require("neotest-minitest")
          },
        })
      '';
    };

    nvim-autopairs = {
      plugin = pkgs.vimPlugins.nvim-autopairs;
      type = "lua";
      config = "require('nvim-autopairs').setup {}";
    };

    nvim-cmp = {
      plugin = pkgs.vimPlugins.nvim-cmp;
      type = "lua";
      config = builtins.readFile ./nvim-cmp.lua;
    };

    nvim-tree = {
      plugin = pkgs.vimPlugins.nvim-tree-lua;
      type = "lua";
      config = builtins.readFile ./nvim-tree.lua;
    };

    obsidian = {
      plugin = pkgs.vimPlugins.obsidian-nvim;
      type = "lua";
      config = builtins.readFile ./obsidian.lua;
    };

    onedark = {
      plugin = pkgs.vimPlugins.onedark-nvim;
      type = "lua";
      config = ''
        require('onedark').setup { style = 'warmer' }
      '';
    };

    ruby-code-actions = {
      plugin = mkPlugin "ruby-code-actions";
      type = "lua";
      config = builtins.readFile ./ruby-code-actions.lua;
    };

    rust-tools = {
      plugin = pkgs.vimPlugins.rust-tools-nvim;
      type = "lua";
      config = builtins.readFile ./rust-tools.lua;
    };

    supermaven = { # Supermaven copilot
      plugin = mkPlugin "supermaven-nvim";
      type = "lua";
      config = ''
        require("supermaven-nvim").setup({

        })
      '';
    };

    tabular = {
      plugin = pkgs.vimPlugins.Tabular;
      runtime = {
        "after/plugin/tabular.vim".source = ./after/plugin/tabular.vim;
      };
    };

    telescope = {
      plugin = pkgs.vimPlugins.telescope-nvim;
      type = "lua";
      config = builtins.readFile ./telescope.lua;
    };

    treesitter = {
      plugin = pkgs.vimPlugins.nvim-treesitter.withPlugins (p:
        with p; [
          awk
          bash
          c
          cpp
          css
          dhall
          elixir
          erlang
          fennel
          git-config
          git-rebase
          gitattributes
          gitcommit
          gitignore
          graphql
          gleam
          haskell
          java
          javascript
          jq
          json
          lua
          markdown
          nginx
          nim
          nix
          python
          swift
          rbs
          ruby
          rust
          scss
          sql
          ssh-config
          terraform
          toml
          tsx
          typescript
          vim
          vimdoc
          vue
          xml
          yaml
          zig
        ]);
      type = "lua";
      config = builtins.readFile ./treesitter.lua;
    };

    ts-node-action = {
      plugin = mkPlugin "ts-node-action";
      type = "lua";
      config = ''
        require("ts-node-action").setup({})
        vim.keymap.set({ "n" }, "<F12>", require("ts-node-action").node_action, { desc = "Trigger Node Action" })
      '';
    };

    vsnip = {
      plugin = pkgs.vimPlugins.vim-vsnip;
      config = builtins.readFile ./vsnip.vim;
    };

  };

  corePlugins = with pkgs.vimPlugins; [
    Rename
    Tagbar
    custom.conform
    custom.dashboard
    custom.leap-nvim
    custom.lspconfig
    custom.mini
    custom.nvim-autopairs
    custom.lsp-selection-range
    custom.tabular
    custom.treesitter
    editorconfig-vim
    fugitive
    gitsigns-nvim
    neoformat
    none-ls-nvim
    nvim-nio
    nvim-ufo
    plenary-nvim
    repeat
    sensible
    tlib
    undotree
    vim-abolish
    # vim-commentary
    vim-dispatch
    vim-grepper
    vim-gutentags
    vim-sandwich
    vim-test
    # vim-unimpaired
    vimproc

    # THEME / VISUAL
    custom.gruvbox
    custom.lualine-nvim
    rainbow-delimiters-nvim # Treesitter multicolored parens/brackets

    # FILE EXPLORER
    custom.nvim-tree
    custom.telescope
    nvim-web-devicons
    fzf-lua
    telescope-fzy-native-nvim
    telescope-ui-select-nvim
    telescope_hoogle # hoogle search
    telescope-manix # nix search

    # LANGUAGE / FILETYPE SPECIFIC
    vim-polyglot # syntax highlighting for most languages

    # COMPLETION
    cmp-buffer
    cmp-cmdline
    cmp-cmdline-history
    custom.nvim-cmp
    cmp-nvim-lsp
    cmp-nvim-lua
    cmp-path
    cmp-vsnip
    custom.vsnip
    lspkind-nvim
    vim-vsnip-integ
    vim-snippets
  ];

  fullPlugins = with pkgs.vimPlugins; [
    custom.obsidian
    custom.ts-node-action
    img-clip-nvim
    nvim-jdtls # java lsp
    vim-tmux-navigator

    # THEME / VISUAL
    custom.onedark
    kanagawa-nvim
    tokyonight-nvim

    # LANGUAGE / FILETYPE SPECIFIC
    Hoogle
    # custom.ruby-code-actions
    custom.rust-tools
    dhall-vim
    elm-vim
    # ghc-mod-vim
    # haskell-vim
    haskell-tools-nvim
    # neco-ghc
    hlint-refactor
    # intero-neovim
    vim-stylish-haskell
    vim-rails
    vim-terraform

    # TESTING
    custom.neotest
    neotest-haskell
    neotest-minitest
    neotest-plenary
    neotest-rspec
    neotest-rust
    neotest-vitest

    # COPILOT
    # custom.avante
    custom.copilot-chat
    custom.copilot-cmp
    custom.copilot-lua
    # custom.supermaven
  ];

in
  if minimal
  then corePlugins
  else corePlugins ++ fullPlugins
