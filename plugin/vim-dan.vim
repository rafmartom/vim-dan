" Title:        vim-dan
" Description:  Offline viewer for web-based documentation
" Last Change:  05 May 2025
" Maintainer:   Rafael Martinez Tomas <https://github.com/rafmartom>

" Allow user to disable and prevent duplicate loading
if exists("g:loaded_vim_dan") || &cp
  finish
endif
let g:loaded_vim_dan = 1

" Save and restore 'compatible' option
let s:save_cpo = &cpo
set cpo&vim

" Commands
command! -nargs=1 DanHelp call dan#ShowHelp(<f-args>)

" Autoloaded function (see autoload/dan.vim)
" Example usage:
"   :DanHelp curl
"   Shows help for "curl"

" Restore 'compatible' option
let &cpo = s:save_cpo
unlet s:save_cpo

" vim:ts=2:sw=2:et:
