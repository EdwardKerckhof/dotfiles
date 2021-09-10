" Remap escape to jk or kj
inoremap jk <Esc>
inoremap kj <Esc>

" Easy CAPS
inoremap <C-u> <ESC>viwUi
nnoremap <C-u> viwU<Esc>

" TAB in general mode will move to text buffer
nnoremap <TAB> :bnext<CR>
" SHIFT-TAB will go back
nnoremap <S-TAB> :bprevious<CR>
" Close buffer with ctrl+w
nnoremap <C-w> :bd<CR>

" Alternate way to save
nnoremap <C-s> :w<CR>
" Alternate way to quit
nnoremap <C-Q> :q!<CR>
" Use control-c instead of escape
nnoremap <C-c> <Esc>
" <TAB>: completion.
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

" Better tabbing
vnoremap < <gv
vnoremap > >gv

" Better window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" NERDTree
nmap <C-n> :NERDTreeToggle<CR>

" Commenter
vmap ++ <plug>NERDCommenterToggle
nmap ++ <plug>NERDCommenterToggle

" Remap for rename current word
nmap <F2> <Plug>(coc-rename)

" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Use <C-space> to trigger completion.
inoremap <silent><expr> <C-space> coc#refresh()

" Prettier
vmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)


" Move lines up and down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Find files using Telescope command-line sugar.
nnoremap <C-p> :Telescope find_files find_command=rg,--ignore,--hidden,--files prompt_prefix=🔍<CR>
nnoremap <C-o>ranger<CR>

" Git integration
nmap <C-g> :G<CR>
nmap <leader>ga :Git add .<CR>
nmap <leader>gc :Git commit<CR>
nmap <leader>gp :Git push<CR>

" Search and replace
nnoremap <S-r> :%s///g<Left><Left>
xnoremap <S-r> :%s///g<Left><Left>
vmap <S-h> y:let @/ = @"<CR>
" VimGrepper (replace acCRoss project)
nnoremap <leader>R :let @s='\<'.expand('<cword>').'\>'<CR> :Grepper -cword -noprompt<CR> :cfdo %s/<C-r>s// \| update<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>

" Dot replacement for Visual mode
nnoremap <silent> s* :let @/='\<'.expand('<cword>').'\>'<CR>cgn
xnoremap <silent> s* "sy:let @/=@s<CR>cgn

" Add ctrl+v for a vertical split
nnoremap <C-v> :vsplit<CR>
" Search in files
nnoremap <S-f> :Rg

" ZSH Terminal
" open new split panes to right
set splitright
set splitbelow
" turn terminal to normal mode with jk
tnoremap jk <C-\><C-t>
" start terminal in insert mode
au BufEnter * if &buftype == 'terminal' | :startinsert | endif
" open terminal on ctrl+t
function! OpenTerminal()
  split term://zsh
  resize 10
endfunction
nnoremap <C-t> :call OpenTerminal()<CR>
