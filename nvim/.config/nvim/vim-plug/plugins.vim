call plug#begin('~/.config/nvim/autoload/plugged')
  " Better Syntax Support
  Plug 'sheerun/vim-polyglot'
  " File Explorer
  Plug 'scrooloose/NERDTree'
  " Auto pairs for '(' '[' '{'
  Plug 'jiangmiao/auto-pairs'
  " Theme
  Plug 'joshdick/onedark.vim'
  " Stable version of coc
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  let g:coc_global_extensions = ['coc-json', 'coc-git', 'coc-vetur', 'coc-prettier', 'coc-tsserver', 'coc-emmet', 'coc-eslint']
  " NERDTree git plugin
  Plug 'Xuyuanp/nerdtree-git-plugin'
  " NERDTree git highlight
  Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
  " NERDTree devicons
  Plug 'ryanoasis/vim-devicons'
  " Fuzzy find files
  Plug 'ctrlpvim/ctrlp.vim'
  " Commenter
  Plug 'scrooloose/nerdcommenter'
  " Gutter
  Plug 'airblade/vim-gitgutter'
  " Airline
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  " Colorizer
  Plug 'norcalli/nvim-colorizer.lua'
  " Rainbow
  Plug 'junegunn/rainbow_parentheses.vim'
  " Startify
  Plug 'mhinz/vim-startify'
  " GIT integration
  Plug 'mhinz/vim-signify'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-rhubarb'
  Plug 'junegunn/gv.vim'
  " Sneak
  Plug 'justinmk/vim-sneak'
  " Ranger
  Plug 'kevinhwang91/rnvimr', {'do': 'make sync'}
  " Telescope
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  " FZF
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  " VimGrepper
  Plug 'mhinz/vim-grepper'
  " Markdown preview
  Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
  Plug 'neovim/nvim-lspconfig' " Native LSP support
  Plug 'hrsh7th/nvim-cmp' " Autocompletion framework
  Plug 'hrsh7th/cmp-nvim-lsp' " LSP autocompletion provider
call plug#end()
