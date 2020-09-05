" my gvimrc
" i at camerongreen dot org
"
" For a complete list of options :options
"
" autoindent on
set autoindent 
" tell vim to try to use colours for dark bg
set background=dark
" allow backspace over anything '2=indent,eol,start'
set bs=2
" options for clipboard
set clipboard=autoselect
" options for gui, m=show menubar, a=control clipboard, A=uber a 
set guioptions=maA
" Number of commands and search patterns to remember
set history=100
" ignore case in searches (and regexs)
set ignorecase
" but if I put a capital in my search, don't ignore it
set smartcase
" show match for current part of search whilst typing it 
set incsearch
" list of flags to use with mouse ???
set mouse=a
" list of pairs to show for the "%" command
set mps=(:),{:},[:],<:>
" don't care about vi compatibility
set nocompatible
" don't ring the bell all the time
set noeb
" show line numbers
set number
" always display the current position in bottom right corner
set ruler
" list of flags to make messages shorter ???
set shm=at
" show incomplete command in bottom right of window
set showcmd
" show what mode we are in on bottom of window
set showmode
" do clever auto indenting
" set smartindent
" number of spaces used for each step of autoindent
set sw=3
" number of spaces a tab in the text stands for
set tabstop=3
" number of levels of undo
set ul=2000
" list that specifies what to write in the viminfo file ???
set viminfo='20,\"50
" wrap long lines
set wrap
" if you don't know about folds, they are way cool
" I like to keep them simple, so I always use markers
set foldmethod=marker

" Make it look how I like it
highlight Normal guibg=Black guifg=white
highlight Search guibg=#555555 guifg=white
highlight Folded guibg=#555555 guifg=white
syntax on

" abbreviations for often used regexes
" :ab for list
" quote html tag attributes
ab tagquote s/\(\w\+=\)\([^"'[:space:]>]\+\)/\1"\2"/g
" quote html tag attributes, escape quotes for programming
ab tagescquote s/\(\w\+=\)\([^\\"'[:space:]>]\+\)/\1\\"\2\\"/g
" change brs to proper syntax
ab brs s/<[Bb][Rr]>/<br \/>/g
" xthml header
ab _html_ <?xml version="1.0" encoding="UTF-8"?><Cr><!DOCTYPE html<Cr><Tab>PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"<Cr>"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><Cr><BackSpace><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en"><Cr><head><Cr><Tab><title></title><Cr><BackSpace></head><Cr><body><Cr></body><Cr></html>
" perl header
ab _pl_ #!/usr/bin/perl -w<Cr><Cr>use strict;<Cr>

" Key Mappings for often used functions
" :map for list
" New paragraph 
" shift F8  
map <S-F8> o<p></p><Esc>3hi
" Comment line 
" shift F11   
map <S-F11> ^i//<Esc>
" Make copy of current line, comment original
" Shift F12
map <S-F12> yy^i//<Esc>p
" New line with PHP error log statement, cursor at entry point
" Shift F9
map <S-F9> oerror_log(, 0);<Esc>4hi
" Gnome conf XML is impossible to read, so make it into seperate
" lines per entity
" Ctrl-F4
map <C-F4> <Esc>/><<Cr>a<Cr><Esc>
" New line with PHP error log statement and nest_array, cursor at entry point
" Shift F9
map <C-S-F9> oerror_log(nest_array(), 0);<Esc>5hi
