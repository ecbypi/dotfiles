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

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
  syntax on
endif

"" Plugins
"
" Load plugins using vundle
filetype off
set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#begin()

" Let Vundle manage Vundle
Plugin 'gmarik/Vundle.vim'

" Define bundles via Github repos
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'pbrisbin/vim-mkdir'
Plugin 'thoughtbot/vim-rspec'

" Shell interaction
"
" Running bundler commands
Plugin 'tpope/vim-bundler'
" File management
Plugin 'tpope/vim-eunuch'
" Git commands
Plugin 'tpope/vim-fugitive'
" handles opening sending commands to tmux panes, used by thoughtbot/vim-rspec
Plugin 'tpope/vim-dispatch'
" Searching through files using `ag`
Plugin 'rking/ag.vim'

" Extensions
"
" Get `.` to support plugin maps
Plugin 'tpope/vim-repeat'
" Split by lines
Plugin 'AndrewRadev/splitjoin.vim'

" Editing macros
"
" Replacing / removing surrounding characters (parens, quotes, etc)
Plugin 'tpope/vim-surround'
" Modifiers to move within camel-cased or snake-cased words
Plugin 'bkad/CamelCaseMotion'
" Easily align things with mappings recommended by tl;dr in README
Plugin 'junegunn/vim-easy-align'
" Configurable tab completion. Defaults to switching <Tab> and <Shift-Tab> to
" replicate <Ctrl-p> and <Ctrl-n> respectively in insert mode.
Plugin 'ervandew/supertab'

" UI
"
" Better statusline
Plugin 'itchyny/lightline.vim'
" Solarized color scheme
Plugin 'altercation/vim-colors-solarized'

" Syntax highlighting / language support
"
" TODO: using this resulted in undesirable syntax highlighting in ruby.
" Investigate and fix.
" Bundle 'sheerun/vim-polyglot'
Plugin 'kchmck/vim-coffee-script'
Plugin 'heartsentwined/vim-emblem'
Plugin 'nono/vim-handlebars'
Plugin 'rodjek/vim-puppet'
Plugin 'pangloss/vim-javascript'
Plugin 'vim-ruby/vim-ruby'
Plugin 'tpope/vim-rails'
" Adding closing syntax (`end`, in ruby, `endfunction` in vimscript, etc)
Plugin 'tpope/vim-endwise'
Plugin 'scrooloose/syntastic'

call vundle#end()
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

  " Enable spellchecking for Markdown
  autocmd FileType markdown setlocal spell

  " Automatically wrap at 80 characters for Markdown
  autocmd BufRead,BufNewFile *.md setlocal textwidth=80

  " Automatically wrap at 72 characters and spell check git commit messages
  autocmd FileType gitcommit setlocal textwidth=72
  autocmd FileType gitcommit setlocal spell

  " Allow stylesheets to autocomplete hyphenated words
  autocmd FileType css,scss,sass setlocal iskeyword+=-
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

" Exclude Javascript files in :Rtags via rails.vim due to warnings when parsing
let g:Tlist_Ctags_Cmd="ctags --exclude='*.js'"

" Treat <li> and <p> tags like the block tags they are
let g:html_indent_tags = 'li\|p'

" configure syntastic syntax checking to check on open as well as save
let g:syntastic_check_on_open=1
" enable syntastic for eslint
let g:syntastic_javascript_checkers = ['eslint']

" Use `vim-dispatch for rspec.
let g:rspec_command = 'Dispatch bundle exec rspec {spec}'

" Don't use curly braces when splitting a ruby hash into multiple lines
let g:splitjoin_ruby_curly_braces = 0

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

" vim-rspec mappings
nnoremap <Leader>t :call RunCurrentSpecFile()<CR>
nnoremap <Leader>s :call RunNearestSpec()<CR>
nnoremap <Leader>l :call RunLastSpec()<CR>
nnoremap <Leader>a :call RunAllSpecs()<CR>

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
