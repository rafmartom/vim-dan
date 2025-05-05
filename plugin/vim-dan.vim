" Title:        vim-dan
" Description:  Vimhelp way for offline viewing of any documentation available
"   on the web
" Last Change:  05 May 2025
" Maintainer:   Rafael Martinez Tomas <https://github.com/rafmartom>

" Prevents the plugin from being loaded multiple times. If the loaded
" variable exists, do nothing more. Otherwise, assign the loaded
" variable and continue running this instance of the plugin.
if exists("g:loaded_vim_dan")
    finish
endif

let g:loaded_vim_dan = 1
