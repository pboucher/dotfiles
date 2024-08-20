set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.config/nvim/bundle/Vundle.vim

let s:bootstrap = 0
try
    " alternatively, pass a path where Vundle should install plugins
    call vundle#begin()
catch /E117:/
    let s:bootstrap = 1
    silent !mkdir -p ~/.vim/bundle
    silent !unset GIT_DIR && git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    redraw!
    call vundle#begin()
endtry

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
" more Vundle plugins
Plugin 'vim-airline/vim-airline'
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-surround'
Plugin 'maksimr/vim-jsbeautify'
Plugin 'tpope/vim-fugitive'
Plugin 'Raimondi/delimitMate'
Plugin 'w0rp/ale'
" Themes
Plugin 'vim-airline/vim-airline-themes'
Plugin 'morhetz/gruvbox'

call vundle#end()
if s:bootstrap
    silent PluginInstall
    quit
end

filetype plugin indent on     " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList          - list configured plugins
" :PluginInstall(!)    - install (update) plugins
" :PluginSearch(!) foo - search (or refresh cache first) for foo
" :PluginClean(!)      - confirm (or auto-approve) removal of unused plugins
"
" see :h vundle for more details or wiki for FAQ
" NOTE: comments after Plugin commands are not allowed.
" Put your stuff after this line

"set termguicolors if using nvim
if has('nvim')
    set termguicolors
endif

" Gruvbox theme for Vim and Airline
let g:airline_theme="gruvbox"
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled=1
let g:gruvbox_bold=1
let g:gruvbox_italic=0
let g:gruvbox_underline=1
let g:gruvbox_undercurl=1
let g:gruvbox_contrast_dark="medium"
let g:gruvbox_contrast_light="medium"
let g:gruvbox_italicize_comments=1
set background=dark
colorscheme gruvbox

" map <c-p> :call JsBeautify()<cr>
autocmd FileType javascript noremap <buffer>  <c-p> :call JsBeautify()<cr>
autocmd FileType json noremap <buffer> <c-p> :call JsonBeautify()<cr>
autocmd FileType jsx noremap <buffer> <c-p> :call JsxBeautify()<cr>
autocmd FileType html noremap <buffer> <c-p> :call HtmlBeautify()<cr>
autocmd FileType css noremap <buffer> <c-p> :call CSSBeautify()<cr>

syntax on

set autowrite "autosave when losing focus
set cmdheight=1 "use 2 lines for command-line
set cpo&vim "set vimpatible-options to vim defaults
set encoding=utf-8
set foldlevelstart=20 "folds to start open
set foldmethod=indent "how to fold
set helplang=en
set hlsearch "highlight searches
set incsearch "search incrementally
set laststatus=2 "always show status line
set linebreak "break on words
set modelines=0 "don't check any lines for set commands
set mouse=a "enable mouse for all modes
set showmatch "briefly highlight matching bracket if visible
set wrap "wrap long lines
set visualbell "flash the screen for a bell

set autoindent "autoindent when applicable
set smarttab "insert blanks according to shiftwidth when <Tab> is hit
set expandtab "turn tabs into spaces
set shiftwidth=4 "set # of spaces to indent
set softtabstop=4 "how many spaces a tab counts as

" Setup line numbers
:set number relativenumber

:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
:  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
:augroup END

" Show whitespace characters
set list listchars=tab:»»,trail:·

autocmd FileType ruby setlocal expandtab shiftwidth=2 softtabstop=2
autocmd FileType python setlocal expandtab shiftwidth=4 softtabstop=4

" Auto linting and fix syntax
let g:ale_linters = {
      \   'javascript': ['eslint'],
      \   'ruby': ['rubocop'],
      \   'scss': ['scss_lint'],
      \}

let g:ale_fixers = {}
let g:ale_fixers['javascript'] = ['eslint']
let g:ale_fixers['ruby'] = ['rubocop']
let g:ale_fix_on_save = 1
let g:airline#extensions#ale#enabled = 1

nnoremap <F5> :ALEFix<CR>

"(t) autowrap using textwidth (t)
"(c) autowrap comments using textwidth, inserting the current commend leader
"    automatically.
"(r) Automatically insert the current comment leader after hitting <Enter> in
"    Insert mode.
"(q) Allow formatting of comments with `gq`.
"(2) When formatting text, recognize numbered lists.
set formatoptions=tcrq2

"mappings
nnoremap th  :tabnew<CR>
nnoremap tj  :tabprev<CR>
nnoremap tk  :tabnext<CR>
nnoremap tl  :tabclose<CR>
nnoremap tt  :tabedit<Space>
nnoremap tm  :tabm<Space>

"don't indent when pasting
map <F2> :set invpaste<CR>

let delimitMate_expand_space = 1
let delimitMate_expand_cr = 1

" Set a highlight at column 81 for lines that are at least that long.
" Not sure why colour won't set.
highlight ColorColumn ctermbg=grey guifg=red
call matchadd('ColorColumn', '\%81v', 100)

