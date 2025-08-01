vim9script
import autoload 'dan.vim'
# Author: freddieventura
# File related to vim-dan linking rules
# so in files with the extension .dan
#      Upon locating in certain navigation areas
#      You can press Ctrl + ] and move around topics/signatures/etc
# Check https://github.com/rafmartom/vim-dan for more info

# Setting iskeyword to
set iskeyword=!-~,^*,^\|,^\",192-255

# Setting filename specific tags file .tags<DOCU_NAME>
execute 'set tags+=./.tags' .. expand("%:t:r")


# New linkto functionality
# In vim-dan documents there are a bunch of
#   - & @link_from@ link_string &
#  That refer to
#   - # link_to # 
#  (been link_from and link_to the same)
#  You just need to locate the cursor on top of the line
#   with the linkFrom and press Ctrl + ]
#
#   The syntax is conealing @link_from@ from the user so it can only see
#   link_string
#   Basically link_from is now a unique identifier


command! GotoLinkTarget call GotoLinkTargetFn()
command! IsLineLinkSource call IsLineLinkSourceFn()
nnoremap <expr> <C-]>  IsLineLinkSourceFn() ? ':GotoLinkTarget<CR>' :  '<C-]>'


def IsLineLinkSourceFn(): number
    # if there is a $linkfrom& in the current line
    if match(getline('.'), '<L=[[:alnum:]#]\+>.*</L>') != -1
        return 1
    else
    endif
    return 0
enddef


def GotoLinkTargetFn(): void
## Trigger the custom Dan GotoLinkTarget functionality
##    - If in the current line there is only one DanTagMath ,
##         Goto that Linkto, regardless of cursor position
##    - If in the current line there is more than one DanTagMath
##         Goto the Linkto corresponding to the current cursor position

    var current_line = getline('.')
    var danUIDMatchPos = GetDanUIDMatchPos(current_line)
    var danLinkSourceMatchPos = GetDanLinkSourceMatchPos(current_line)


    if len(danUIDMatchPos) == 1
        if match(current_line, '<L=[[:alnum:]#]\+>.*</L>') != -1
            execute "tag " .. matchstr(current_line, '<L=\zs[[:alnum:]#]\{-}\ze>')
            return
        endif
    else
        var mouse_position = col('.') - 1

    # Iterate through both lists simultaneously
        for index in range(len(danUIDMatchPos))
            var danUIDMatch = danUIDMatchPos[index]
            var danLinkSourceMatch = danLinkSourceMatchPos[index]


            if ( danLinkSourceMatch[1] <= mouse_position && danLinkSourceMatch[2] >= mouse_position )
                execute "tag " .. danUIDMatch[0]
                
            endif
        endfor
    endif

enddef



def GetDanUIDMatchPos(inputString: string): list<list<any>>
## Parse a bi-dimensional-list of matches of L=<alphanum> (just the num) its start and end position of the match
##     And its indexStart (index where the match start)
##     Ex . var myString = "Browse to<L=002>Previous</L><L=004>Next</L> docs."
##     echo GetDanUIDMatchPos(myString) ## [['002', 12, 14],['004', 31, 33]] 


    var danTagMatchPos: list<list<any>> = []
    var current_char = 0

    while 1
        var newMember: list<any> = []
        var match_result = matchstr(inputString, '<L=\zs[[:alnum:]#]\{-}\ze>', current_char)
        current_char = match(inputString, '<L=\zs[[:alnum:]#]\{-}\ze>', current_char)
        if !empty(match_result)
            add(newMember, match_result)
            add(newMember, current_char)
            current_char = matchend(inputString, '[[:alnum:]#]\{-}\ze>', current_char)
            add(newMember, current_char - 1)
            add(danTagMatchPos, newMember)
        else
            break
        endif
    endwhile


    return danTagMatchPos
enddef



def GetDanLinkSourceMatchPos(inputString: string): list<list<any>>
## Like previousone but with Linkfrom positions so
##     Ex . var myString = "Browse to<L=002>Previous</L><L=004>Next</L> docs."
##     Matches < on <L=002> been this 0 based , 9 in this case , and so on
##     echo GetDanLinkSourceMatchPos(myString) ## [[ '<L=002>Previous</L>', 9, 27],['<L=004>Next</L>', 28, 42]]
    var datLinkfromMatchPos: list<list<any>> = []
    var current_char = 0

    while 1
        var newMember: list<any> = []
        var match_result = matchstr(inputString, '<L=[[:alnum:]#]\+>.\{-}</L>', current_char)
        current_char = match(inputString, '<L=[[:alnum:]#]\+>.\{-}</L>', current_char)
        if !empty(match_result)
            add(newMember, match_result)
            add(newMember, current_char)
            current_char = matchend(inputString, '<L=[[:alnum:]#]\+>.\{-}</L>', current_char)
            add(newMember, current_char - 1)
            add(datLinkfromMatchPos, newMember)
        else
            break
        endif
    endwhile


    return datLinkfromMatchPos
enddef


# VIM-DAN FUNCTIONALITIES
# ----------------------------------
nnoremap <C-p> :normal $a (X)<Esc>

noremap <F4> :ToggleXConceal<CR>

# Starting with new system no need to UpdateTags anytime Refreshloclist
#noremap <F5> :call dan#Refreshloclist()<CR>
nnoremap <silent> <F5> :silent call dan#Refreshloclist()<CR>


command! ToggleXConceal call dan#ToggleXConceal(g:xConceal)

set nofoldenable
set nomodeline


command! ParseDanModeline call ParseDanModeline()


# -----------------------------------------------
# Parse variable and content from YAML-like block between <B=0> and </B>
# -----------------------------------------------
export def ParseDanModeline(): void
    # Find the boundaries of the YAML block
    var startLine = search('<B=0>', 'n')
    var endLine = search('</B>', 'n')
    if startLine == 0 || endLine == 0 || startLine >= endLine
        return
    endif

    # Parse each line in the block
    var keyValueList: list<any>
    for lineNr in range(startLine + 1, endLine - 1)
        keyValueList = ParseDanModelineContent(lineNr)
        if empty(keyValueList)
            continue
        endif

        # Check if the varName already exists
        if has_key(g:dynamicLookupDict, keyValueList[0])
            # Append to existing content, ensuring uniqueness
            var updatedContent = g:dynamicLookupDict[keyValueList[0]] + keyValueList[1]
            g:dynamicLookupDict[keyValueList[0]] = DanUniq(updatedContent)
            var listLiteral = ListToListLiteral(g:dynamicLookupDict[keyValueList[0]])
            var cmd = 'g:' .. keyValueList[0] .. ' = ' .. listLiteral
            execute(cmd)
        else
            # Add new variable to global dictionary and namespace
            g:dynamicLookupDict[keyValueList[0]] = keyValueList[1]
            var listLiteral = ListToListLiteral(keyValueList[1])
            var cmd = 'g:' .. keyValueList[0] .. ' = ' .. listLiteral
            execute(cmd)
        endif
    endfor

    # Add current filename to sourced list
    var currentFileName = expand('%')
    g:danFilesSourced += [currentFileName]
    # Reload syntax file
    runtime syntax/dan.vim
enddef

# -----------------------------------------------
# Parse a single line of YAML-like content
# -----------------------------------------------
export def ParseDanModelineContent(lineNumber: number): list<any>
    var lineContent = getline(lineNumber)
    # Skip empty lines or lines without a colon
    if empty(lineContent) || lineContent !~ ':'
        return []
    endif

    # Split on the first colon to separate key and value
    var parts = split(lineContent, ':', 1)
    if len(parts) < 2
        return []
    endif

    var varName = trim(parts[0])
    var valueStr = trim(parts[1])

    # Handle different value formats
    var varValueList: list<string>
    if valueStr =~ '^\[.*\]$'
        # List format, e.g., ["sh", "javascript"]
        valueStr = substitute(valueStr, '^\[\(.*\)\]$', '\1', '')
        if !empty(valueStr)
            varValueList = map(split(valueStr, ','), 'trim(v:val, ''" '')')
        endif
    elseif valueStr =~ '^".*"$'
        # Single string value
        varValueList = [trim(valueStr, '"')]
    else
        # Treat as empty list or single value
        varValueList = empty(valueStr) ? [] : [valueStr]
    endif

    return [varName, varValueList]
enddef

# -----------------------------------------------
# Convert a list to a Vim list literal string
# -----------------------------------------------
export def ListToListLiteral(inputList: list<any>): string
    var listString = '['
    for item in inputList
        echom 'ITEM: ' .. string(item)
        listString ..= "'" .. item .. "', "
    endfor
    if len(listString) > 1
        listString = listString[0 : len(listString) - 3]
    endif
    listString ..= ']'
    return listString
enddef

# -----------------------------------------------
# Remove duplicates from a list
# -----------------------------------------------
export def DanUniq(inputList: list<any>): list<any>
    var uniqueDict = {}
    for item in inputList
        uniqueDict[item] = 1
    endfor
    var uniqueList = keys(uniqueDict)
    sort(uniqueList)
    return uniqueList
enddef

# -----------------------------------------------
# Autocommand to trigger parsing on BufEnter
# -----------------------------------------------
autocmd BufEnter *.dan {
    var currentFileName = expand('%')
    if index(g:danFilesSourced, currentFileName) == -1
        call ParseDanModeline()
    endif
}


# ----------------------------------
#eof eof eof eof eof VIM-DAN FUNCTIONALITIES

