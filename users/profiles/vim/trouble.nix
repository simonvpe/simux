{ config
, pkgs
, ...
}:
{

  config.programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      nvim-web-devicons
      trouble-nvim
    ];

    extraConfig = ''
      lua<<EOF
      require'nvim-web-devicons'.setup {}
      require'trouble'.setup {}
      EOF

      nnoremap <leader>xx <cmd>TroubleToggle<cr>
      nnoremap <leader>xw <cmd>TroubleToggle lsp_workspace_diagnostics<cr>
      nnoremap <leader>xd <cmd>TroubleToggle lsp_document_diagnostics<cr>
      nnoremap <leader>xq <cmd>TroubleToggle quickfix<cr>
      nnoremap <leader>xl <cmd>TroubleToggle loclist<cr>
      nnoremap gR <cmd>TroubleToggle lsp_references<cr>
    '';
  };
}
