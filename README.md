# lucy's dotfiles

everything is catppuccin latte. i'd explore other themes but i like how
catppuccin has pretty reliable ready-to-go configs for almost everything. i have
made some changes, though. the background is dimmed slightly, using the `colors`
module from the `catppuccin` neovim plugin. overriding in neovim and tmux
doesn't require changing the plugins, but i did have to modify the alacritty
theme.

the following commands assume you've put this repository in your home directory,
`~/dotfiles`. if that's not the case, specify home as the target with `-t ~`,
for example, `stow -t ~ nvim`.

### neovim

```shell
stow -t ~/.config/nvim -S nvim
```

a distant relative of [kickstart](https://github.com/nvim-lua/kickstart.nvim)
with many mutations.

some external tools needed. in general `:checkhealth` helps identify any missing
programs.

based on a split-heavy post-IDE workflow. perma-zen mode & fuzzy finders. i'm
very particular about my tools. i need a level of consistency, so that's what
i've tried to set up here. expect consistent ui and ux where ever possible.
copilot integration for chat and completions, supercollider support,

**to-do**:

- improve handling of supercollider help buffers
- fork Copilot Chat to make some UI tweaks

### zsh

```shell
stow -t ~ -S zsh
```

i use zsh because it is default.

i use completions via `compsys`.

### alacritty

```shell
stow -t ~/.config/alacritty -S alacritty
```

current terminal emulator. kiss.

### tmux

```shell
stow -t ~ tmux
```

i'm using the [catppuccin theme](https://github.com/catppuccin/tmux). normally
you'd keep this as a git repository, but i'm tracking it locally so that it
plays nice with `stow`.

i have a slightly modified key mapping set up to emulate something between
`zellij` and `vim`:

```
C-g           - leader
C-g [h|j|k|l] - to left/below/above/right pane
C-g s         - split pane
C-g v         - vsplit pane
M-\           - open floating terminal
```
