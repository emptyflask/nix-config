{
  description = "Neovim plugin flake";

  inputs = {
    conform-nvim = {
      url = "github:stevearc/conform.nvim?ref=v9.0.0";
      flake = false;
    };
    copilot-chat-nvim = {
      url = "github:CopilotC-Nvim/CopilotChat.nvim";
      flake = false;
    };
    nvim-lsp-selection-range = {
      url = "github:camilledejoye/nvim-lsp-selection-range";
      flake = false;
    };
    ruby-code-actions = {
      url = "github:semanticart/ruby-code-actions.nvim";
      flake = false;
    };
    supermaven-nvim = {
      url = "github:supermaven-inc/supermaven-nvim";
      flake = false;
    };
    ts-node-action = {
      url = "github:ckolkey/ts-node-action";
      flake = false;
    };
  };

  outputs = inputs: inputs;
}
