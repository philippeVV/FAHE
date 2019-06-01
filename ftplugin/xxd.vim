" Vim fyletype plugin to allow binary format analysis and hex editing. (fanhex)
" Last change: In development
" Maintainer: Philippe Van Velzen
" License: Ain't sure yet


" The function have for goal to retrieve information regarding the formating
" outputed by xxd.
function! s:GetXxdInfo()
  call cursor(1, 1)
  
  "log address position
  call cursor(1, 1)
  let s:addressStart = 1
  call search('\:', 'e', line(".")) 
  let s:addressEnd = virtcol(".")

  "log ascii position
  call cursor(1, 1000) "cuz I dont'know how to get at the end of the line
  call search(" ", 'b', line("."))
  let s:asciiStart = virtcol(".") + 1 "Because ' ' is before ascii start
  let s:asciiEnd = virtcol("$") - 1 "Because '$' is after the las readable carac.

  "log hexa position
  let s:hexaStart = s:addressEnd + 2
  let s:hexaEnd = s:asciiStart - 3
  call cursor(1, 1)
endfunction

" Determine the position of the cursor and the matching position in the
" appropriate section
function! s:GetMatch()
  let s:lineStr = getline(".")
  let l:column = virtcol(".")
  let l:line = line(".")

  if l:column >= s:hexaStart && l:column <= s:hexaEnd
    "match ascii
    if s:lineStr[l:column - 1] == " "
      echo "space - no match"
    else
      let l:spaceHexa = (l:column - s:hexaStart) / 5
      let l:match = float2nr(floor((l:column - s:hexaStart - l:spaceHexa) / 2.0))
      let l:match = l:match + s:asciiStart
      call s:HighlightMatch(l:match, l:line)
      echo "hexa" 
    endif
  elseif l:column > s:asciiStart && l:column < s:asciiEnd 
    "match hexa
    echo "ascii" 
  else
    "no match
    echo "address"
  endif
endfunction

function! s:EditMatch()
  "every time i move from a match actualize the previous match
  "Could verify if the matcher as change
endfunction

function! s:HighlightMatch(col, line)
  highlight Hexascii ctermbg=grey guibg=grey
  exe 'match Hexascii /\%' . a:col . 'v\%' . a:line . 'l/'
endfunction

"=============================
function! s:SetDebugWin()
  let l:xxdWinId = win_getid()

  call s:CreateWindow()
  let l:debugWinId = win_getid()
  let l:debugBufName = bufname(l:debugWinId)
  call setbufline(l:debugBufName, 1, "DEBUG")
  call setbufline(l:debugBufName, 2, "Debug window Id: " . l:debugWinId)
  call setbufline(l:debugBufName, 3, "Debug Buffer name: " . l:debugBufName)
  call setbufline(l:debugBufName, 4, "Address start: " . s:addressStart)
  call setbufline(l:debugBufName, 5, "Address end: " . s:addressEnd)
  call setbufline(l:debugBufName, 6, "Ascii start: " . s:asciiStart)
  call setbufline(l:debugBufName, 7, "Ascii end: " . s:asciiEnd)
  call setbufline(l:debugBufName, 8, "Hexa start: " . s:hexaStart)
  call setbufline(l:debugBufName, 9, "Hexa end: " . s:hexaEnd)
  
endfunction

"=============================
function! s:CreateWindow()
  let l:splitLocation = "botright "
  let l:splitSize = "50"

  silent! exec l:splitLocation . " vertical " . l:splitSize . " new"
  
  call s:BufOptions()
endfunction

function! s:BufOptions()
  "Buffer option
  setlocal bufhidden=hide " hide thhe buffer instead of unloading it
  setlocal buftype=nofile " buffer attach to no file (won't try to save it)
  setlocal noswapfile " don't create swap file for this buffer

  " window appearence
  setlocal foldcolumn=0 " no fold colunm (local for window)
  setlocal foldmethod=manual " determine the fold method
  setlocal nobuflisted " Buffer won't be listed in buffer list
  setlocal nofoldenable " Fold close by default
  setlocal nolist " Hmm unsure, but we don't want it
  setlocal nospell " No spell checking
  setlocal nowrap " No line wrap
  setlocal nonu " No line number
  if v:version >= 703 " Why the version check ?
    setlocal nornu " No relative line number
  endif

  iabc <buffer> " Remove insert mode abbreviations
  
  setlocal cursorline " Highlight the line of the cursor
  setlocal winfixwidth " Keep the width of the window when tab are open or closed
endfunction
"=============================

" Save cpo and set it for line continuation
let s:save_cpo = &cpo
set cpo&vim

if exists("g:loaded_fanhex")
  finish
endif
let g:loaded_fanhex = 1

"call GetXxdInfo()

" augroup xxd
"   au!
"   au cursorMoved,cursorMovedI * call GetMatch()
" augroup END

call SetDebugWin()

let &cpo = s:save_cpo
unlet s:save_cpo
