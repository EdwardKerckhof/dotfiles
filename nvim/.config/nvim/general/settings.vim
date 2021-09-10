" set leader key
let g:mapleader = "\<Space>"

syntax enable                           " Enables syntax highlighing
set t_Co=256                            " Support 256 colors
set hidden                              " Required to keep multiple buffers open multiple buffers
set nohlsearch                          " Remove highlighting after search
set encoding=utf-8                      " The encoding displayed
set pumheight=10                        " Makes popup menu smaller
set fileencoding=utf-8                  " The encoding written to file
set ruler              			            " Show the cursor position all the time
set cmdheight=2                         " More space for displaying messages
set noerrorbells                        " Disable annoying error sounds
set iskeyword+=-                      	" treat dash separated words as a word text object"
set mouse=a                             " Enable your mouse
set splitbelow                          " Horizontal splits will automatically be below
set splitright                          " Vertical splits will automatically be to the right
set conceallevel=0                      " So that I can see `` in markdown files
set tabstop=2                           " Insert 2 spaces for a tab
set shiftwidth=2                        " Change the number of space characters inserted for indentation
set smarttab                            " Makes tabbing smarter will realize you have 2 vs 4
set expandtab                           " Converts tabs to spaces
set smartindent                         " Makes indenting smart
set autoindent                          " Good auto indent
set laststatus=0                        " Always display the status line
set number                              " Line numbers
set relativenumber                      " Relative line numbers
set cursorline                          " Enable highlighting of the current line
set background=dark                     " tell vim what the background color looks like
set showtabline=2                       " Always show tabs
set noswapfile                          " Disable swapfile
set undodir=~/.vim/undodir              " Set undodir
set undofile                            " Set undofile
set nobackup                            " This is recommended by coc
set nowritebackup                       " This is recommended by coc
set scrolloff=8                         " Start scrolling down when 8 lines are left
set updatetime=300                      " Faster completion
set timeoutlen=500                      " By default timeoutlen is 1000 ms
set formatoptions-=cro                  " Stop newline continution of comments
set clipboard=unnamedplus               " Copy paste between vim and everything else
set autochdir                           " Your working directory will always be the same as your working directory

au! BufWritePost $MYVIMRC source %      " auto source when writing to init.vm alternatively you can run :source $MYVIMRC

" vim-prettier
command! -nargs=0 Prettier :CocCommand prettier.formatFile

" NERDTree
let g:NERDTreeIgnore = ['^node_modules$']
let NERDTreeShowHidden = 1

" Rainbow
let g:rainbow#max_level = 16
let g:rainbow#pairs = [['(', ')'], ['[', ']'], ['{', '}']]

autocmd FileType * RainbowParentheses

" Auto trim any whitespace
fun! TrimWhitespace()
  let l:save = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:save)
endfun

" Create autogroup to call TrimWhitespace for all filetypes
augroup EDWARD
  autocmd!
  autocmd BufWritePre * :call TrimWhitespace()
augroup END

" Prettier
let g:prettier#autoformat_config_present = 1
let g:prettier#config#config_precedence = 'prefer-file'
