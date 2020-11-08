" Use Vim settings, rather then Vi settings. This setting must be as early as
" possible, as it has side effects.
set nocompatible

" Use space as Leader
let mapleader = " "

"" Settings
"
set backspace=2   " Backspace deletes like most programs in insert mode
set nobackup
set nowritebackup
set noswapfile    " http://robots.thoughtbot.com/post/18739402579/global-gitignore#comment-458413287
set history=50
set ruler         " show the cursor position all the time
set showcmd       " display incomplete commands
set incsearch     " do incremental searching
set laststatus=2  " Always display the status line
set autowrite     " Automatically :write before running commands

" Set width to 95 characters where auto-wrapping will occur. Display the color column at 1 past
" this point
set textwidth=95
set colorcolumn=+1

" Display line numbers and adjust the width of the column their displayed in
set number
set numberwidth=5

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Always use vertical diffs
set diffopt+=vertical

" Softtabs, 2 spaces
set tabstop=2
set shiftwidth=2
set shiftround
set expandtab

" Formatting options
" `-o` prevents inserting a comment leader when using `O` or `o` sequences.
" `-l` allows for long lines to be broken in insert mode
" `+v` sets up automatic line wrapping in insert mode
" `+r` allows inserting a comment leader after hitting `<Cr>`
set formatoptions-=ol
set formatoptions+=vr

" Always have spell-checking on
set spell

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
  syntax on
endif

"" Plugins
"
" Automatic installation of vim-plug
" https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Load plugins using vundle
call plug#begin('~/.vim/bundle')

" Utilities
"
" Fuzzy-finder
Plug 'ctrlpvim/ctrlp.vim'
" Create missing directories when writing a file
Plug 'pbrisbin/vim-mkdir'

" Shell interaction
"
" Running bundler commands
Plug 'tpope/vim-bundler'
" File management
Plug 'tpope/vim-eunuch'
" Git commands
Plug 'tpope/vim-fugitive'
" handles opening sending commands to tmux panes, used by thoughtbot/vim-rspec
Plug 'tpope/vim-dispatch'
" Searching through files using `ag`
Plug 'rking/ag.vim'
" Test runner for everything
Plug 'janko/vim-test'

" Extensions
"
" Get `.` to support plugin maps
Plug 'tpope/vim-repeat'
" Split by lines
Plug 'AndrewRadev/splitjoin.vim'

" Editing macros
"
" Replacing / removing surrounding characters (parens, quotes, etc)
Plug 'tpope/vim-surround'
" Modifiers to move within camel-cased or snake-cased words
Plug 'bkad/CamelCaseMotion'
" Easily align things with mappings recommended by tl;dr in README
Plug 'junegunn/vim-easy-align'
" Configurable tab completion. Defaults to switching <Tab> and <Shift-Tab> to
" replicate <Ctrl-p> and <Ctrl-n> respectively in insert mode.
Plug 'ervandew/supertab'

" UI
"
" Better statusline
Plug 'itchyny/lightline.vim'
" Solarized color scheme
Plug 'altercation/vim-colors-solarized'

" Syntax highlighting / language support
"
" TODO: using this resulted in undesirable syntax highlighting in ruby.
" Investigate and fix.
" Bundle 'sheerun/vim-polyglot'
Plug 'kchmck/vim-coffee-script'
Plug 'heartsentwined/vim-emblem'
Plug 'nono/vim-handlebars'
Plug 'rodjek/vim-puppet'
Plug 'pangloss/vim-javascript'
Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-rails'
" Adding closing syntax (`end`, in ruby, `endfunction` in vimscript, etc)
Plug 'tpope/vim-endwise'
Plug 'scrooloose/syntastic'
" Plug 'w0rp/ale'
Plug 'mxw/vim-jsx'
Plug 'mattn/emmet-vim'
Plug 'leshill/vim-json'
Plug 'wgwoods/vim-systemd-syntax'
Plug 'vim-scripts/indentpython.vim'

Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'

call plug#end()
filetype plugin indent on

augroup vimrcEx
  autocmd!

  " When editing a file, always jump to the last known cursor position.
  " Don't do it for commit messages, when the position is invalid, or when
  " inside an event handler (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " Set syntax highlighting for specific file types
  autocmd BufRead,BufNewFile Appraisals set filetype=ruby
  autocmd BufRead,BufNewFile *.md set filetype=markdown

  " Enable spellchecking for Markdown and HTML
  autocmd FileType markdown setlocal spell
  autocmd FileType haml setlocal spell
  autocmd FileType html setlocal spell

  " Automatically wrap at 80 characters for Markdown
  autocmd BufRead,BufNewFile *.md setlocal textwidth=80

  " Automatically wrap at 72 characters and spell check git commit messages
  autocmd FileType gitcommit setlocal textwidth=72
  autocmd FileType gitcommit setlocal spell

  " Allow stylesheets to autocomplete hyphenated words
  autocmd FileType css,scss,sass setlocal iskeyword+=-

  autocmd BufRead,BufNewFile *.py setlocal tabstop=4 shiftwidth=4 autoindent
augroup END

"" Whitespace handling
" Display non-space tabs
set list listchars=tab:>>
" Make trailing whitespace visible
match ErrorMsg '\s\+$'

" Remove trailing whitespace before writing a file
function! TrimWhiteSpace()
  normal! mm:%s/\s\+$//e`m
endfunction
autocmd FileWritePre    * :call TrimWhiteSpace()
autocmd FileAppendPre   * :call TrimWhiteSpace()
autocmd FilterWritePre  * :call TrimWhiteSpace()
autocmd BufWritePre     * :call TrimWhiteSpace()

"" Plugin config
"
" Use `ag` for feeding into `ctrlp` fuzzy matching plugin
if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif

" Tab completion
" will insert tab at beginning of line,
" will use completion if not at beginning
set wildmode=list:longest,list:full
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <Tab> <c-r>=InsertTabWrapper()<cr>
inoremap <S-Tab> <c-n>

" Disable automatic folding of markdown files
let g:vim_markdown_folding_disabled = 1

" Exclude Javascript files in :Rtags via rails.vim due to warnings when parsing
let g:Tlist_Ctags_Cmd="ctags --exclude='*.js'"

" Treat <li> and <p> tags like the block tags they are
let g:html_indent_tags = 'li\|p'

" configure syntastic syntax checking to check on open as well as save
let g:syntastic_check_on_open=1
" enable syntastic for eslint
let g:syntastic_javascript_checkers = ['eslint']
" use pep8 for python
let g:syntastic_python_checkers = ['pep8']
" Ignore:
" * E501: line too long
" * E402: all imports at the top of the file; sometimes code is run to
" * modify the load path to load code local to the current project.
" * E302, E305: extra blank lines between function and class definitions
let g:syntastic_python_pep8_args='--ignore=E501,E402,E302,E305'

" Configure vim-test
let test#strategy = "dispatch"

" Don't use curly braces when splitting a ruby hash into multiple lines
let g:splitjoin_ruby_curly_braces = 0

" Define custom vim-rails mappings
let g:rails_projections = {
\  "app/javascript/*.js": {
\    "command": "js"
\  },
\  "app/presenters/*.rb": {
\    "command": "presenter"
\  }
\}

" Use comma for camelcasemotion
call camelcasemotion#CreateMotionMappings(',')

"" Mappings
"
" vim-easy-align recommending settings
vmap <Enter> <Plug>(EasyAlign)
nmap <Leader> <Plug>(EasyAlign)

" Navigating between modes, windows, buffers, tabs, etc. Easier tab navigation in normal and
" insert mode
nnoremap <C-h> :tabprevious<Cr>
nnoremap <C-l> :tabnext<Cr>
inoremap <C-h> <Esc>:tabprevious<Cr>
inoremap <C-l> <Esc>:tabnext<Cr>

" Mappings to open and source .vimrc
nnoremap <Leader>ev :vsplit $MYVIMRC<Cr>
nnoremap <Leader>sv :source $MYVIMRC<Cr>

" Force using `h` and `l` for navigating
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
" If I'm reading over code, I'll try to use arrow keys
" to scroll through the code like I would when reading
" a PDF.
" Since I'm not editing code, it's easier to use the
" arrow keys since my hands may not be on the home row
nnoremap <Up> <C-y>
nnoremap <Down> <C-e>

" vim-test mappings
nnoremap <Leader>s :TestNearest<CR>
nnoremap <Leader>t :TestFile<CR>
nnoremap <Leader>a :TestSuite<CR>
nnoremap <Leader>l :TestLast<CR>
nnoremap <Leader>g :TestVisit<CR>

" Add `jk` and `jj` to exit out of insert mode (also while accidentally pressing `<shift>`
inoremap jk <Esc>
inoremap jK <Esc>
inoremap JK <Esc>
inoremap jj <Esc>

"" Typoes
iabbrev descrbie describe
iabbrev appliant applicant
iabbrev appliation application
iabbrev uesr user
iabbrev autcomd autocmd
iabbrev autocomd autocmd
iabbrev =? =>
iabbrev =. =>
iabbrev reprot report
iabbrev complicant compliant

"" UI
set background=dark
colorscheme solarized
