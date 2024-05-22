return {
  "windwp/nvim-ts-autotag",
  config = function()
    vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics,
      {
        underline = true,
        virtual_text = {
          spacing = 5,
          min = severity,
        },
        update_in_insert = true,
      }
    )
  end
}
