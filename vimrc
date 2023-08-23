
" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Load an indent file for the detected file type.
filetype indent on

" Turn syntax highlighting on.
syntax on

" Add numbers to each line on the left-hand side.
set number

" This enables relative line numbering mode. With both number and
" relativenumber enabled, the current line shows the true line number,
" while all other lines (above and below) are numbered relative to the
" current line. This is useful because you can tell, at a glance, what
" count is needed to jump up or down to a particular line, by {count}k to
" go up or {count}j to go down

set relativenumber

" Highlight cursor line underneath the cursor horizontally.
" set cursorline

" Highlight cursor line underneath the cursor vertically.
" set cursorcolumn

" Always show the status line at the bottom, even if you only have one
" window open.

set laststatus=2

" Set shift width to 4 spaces.
set shiftwidth=4

" Set tab width to 4 columns.
set tabstop=4

" Use space characters instead of tabs.
set expandtab

" Do not save backup files.
set nobackup

" Ignore capital letters during search.
set ignorecase

" Set smartcase
set smartcase

" Enable searching as you type, rather than waiting till you press enter.
set incsearch

" Disable the default Vim startup message.
set shortmess+=I

" Enable mouse
set mouse+=a
