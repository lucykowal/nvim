-- some common settings
return {
  ollama_host = vim.env.SERVER_ADDR,
  window = {
    border = "single",
    row = 1,
    height = function()
      return math.floor(vim.o.lines * 0.75)
    end,
    width = function()
      return math.floor(vim.o.columns * 0.8)
    end,
    title_pos = "center",
    winblend = 0,
  },
}
