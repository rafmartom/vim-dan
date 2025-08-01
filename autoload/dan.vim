vim9script
# Author : rafmartom
# File with some funtions to use on vim-dan
# <docu-name>.dan
# Set it to refresh tags and highlighted notes such as
# noremap <F5> :call dan#Refreshloclist()<CR>:silent! ctags -R ./ 2>/dev/null<CR>


# Close tab of the loclist that belongs to currentBuffer
export def Closeloclist()
    var currentBufname = bufname('%')
    var currTab = tabpagenr()
    var winInfoList = getwininfo()

    for winInfo in winInfoList
        if ( winInfo.loclist == 1 )
            ## Extracting filename from quickfix_title
            ## Title is gonna be something like
            ## "    lvimgrep! / (X)$/ cheatsheet.tmux.not"
            ##                        -------------------
            ##                      Matching against this
            var loclistFilename = matchstr(winInfo.variables.quickfix_title, '[^[:space:]]\+$')
            echo currentBufname
            if (loclistFilename == currentBufname)
                ## Remember <tabnr> is 1 based ,
                ##     whereas getwininfo()[0] is 0 based
                ## :<tabnr> tabnext , is also 1 based
                exec ":" .. winInfo.tabnr .. " tabnext"
                q!
            endif
        endif
    endfor
    exec ":" .. currTab .. " tabnext"
enddef
# -----------------------------------------------


# Creating a highlighted lines location list
export def Newloclist()
    # Setting so that qfList opens up in a new tab
    # And when using it it will change the previous buffer
	set switchbuf+=usetab,newtab

	# Creating the qfList
    silent lvimgrep! / (X)$/ %
enddef
# -----------------------------------------------

# Customizing the location list to not to show line numbers
# -----------------------------------------------
export def Customloclist()
    var locIdRef = getloclist(0, {'id': 0}).id

    def LocFormating(info: dict<any>): list<any>
        var items = getloclist(0, {'id': info.id, 'items': 1}).items
        var l = []
        for idx in range(info.start_idx - 1, info.end_idx - 1)
          call add(l, items[idx].text)
        endfor
        return l
    enddef

    setloclist(0, [], 'r', {
        id: locIdRef,
        quickfixtextfunc: LocFormating,
    })
enddef
# -----------------------------------------------

# Opening the location list in a new tab maintaining the syntax highlighting
# -----------------------------------------------
export def Openloclist()
    # Saving current Tab we are in
    var currTab = tabpagenr()

	# Saving the current filetype
    var myFiletype = &filetype

    # Opening qfList in a new tab
    tab lopen
    # Inserting the current filetype into the qfList
    execute 'set ft=' .. myFiletype
    set foldmethod=manual
    set foldcolumn=0

    # Concealing (X)
    execute 'syn match danX "(X)" conceal'

    # Returning to the previous tab
    exec ":" .. currTab .. " tabnext"
enddef
# -----------------------------------------------

# Refreshing the highlighted lines location list
# -----------------------------------------------
export def Refreshloclist()
    Closeloclist()
    Newloclist()
    Customloclist()
    Openloclist()
enddef
# -----------------------------------------------


# Updating tags for the current opened vim-dan main file
#   In use for files named <DOCU_NAME>.dan
# -----------------------------------------------
#  We need to direct ctags to the right file within the right
#  documentation dir
# Example: :call dan#UpdateTags()
export def UpdateTags()
    var ABSOLUTE_DIR = expand('%:p:h')
    var FILENAME_NOEXT = expand('%:t:r')
    var FILENAME = expand('%:t')
    var original_cwd = getcwd()

    try
        # Change to the directory of the current file
        execute 'cd ' .. ABSOLUTE_DIR

        # Run ctags with custom regex rules for .dan files
        silent! execute '!ctags --tag-relative=yes -f .tags' .. FILENAME_NOEXT .. ' ' ..
            \ FILENAME .. ' 2>/dev/null'

        # Redraw the screen to avoid "Press ENTER" prompt
        redraw!
    finally
        # Restore the original working directory
        execute 'cd ' .. original_cwd
    endtry
enddef
# -----------------------------------------------


# Concealing (X)
# -----------------------------------------------
export def ToggleXConceal(xConceal: number): void
    if (xConceal == 1)
        syn match danX "(X)"
        g:xConceal = 0
    elseif (xConceal == 0)
        syn match danX "(X)" conceal
        g:xConceal = 1
    else
        echo 'ERROR ON XConceal Toggle'
    endif
enddef
# -----------------------------------------------



def SyntaxOff(): void
  runtime syntax/nosyntax.vim
enddef

def SyntaxOn(): void
  runtime syntax/syntax.vim
enddef

export def SyntaxReset(r: bool = true): void
  popup_notification('Off', {time: 3333})
  SyntaxOff()
  redraw
  if r
    popup_notification('On', {time: 3333})
    sleep 2
    SyntaxOn()
  endif
enddef
