
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
function! s:callDebug()
  let l:debugDict = {}
  let debugDict["Adress start: "] = s:addressStart
  let debugDict["Address end: "] = s:addressEnd
  let debugDict["Ascii start: "] = s:asciiStart
  let debugDict["Ascii end: "] = s:asciiEnd
  let debugDict["Hexa start: "] = s:hexaStart
  let debugDict["Hexa end: "] = s:hexaEnd
  call debug#SetDebugWin(l:debugDict)
endfunction

call s:GetXxdInfo()

augroup s:xxd
  au!
  au cursorMoved,cursorMovedI * call s:GetMatch()
augroup END

call s:callDebug()

let b:undo_ftplugin = "au! s:xxd | aug! s:xxd"

