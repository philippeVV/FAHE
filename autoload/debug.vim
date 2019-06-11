
function! debug#DebugAutoCommand()
  augrou- s:debug
    au!
    au FileType * call setbufline(l:debugBufName, 13, "FileType: " . &ft)
  augroup END

endfunction

function! debug#SetDebugWin(debugDict)
  let l:xxdWinId = win_getid()

  call window#CreateWindow()
  let l:debugWinId = win_getid()
  let l:debugBufName = bufname(l:debugWinId)

  call debug#DebugAutoCommand()
  call setbufline(l:debugBufName, 1, "DEBUG")
  call setbufline(l:debugBufName, 2, "Debug window Id: " . l:debugWinId)
  call setbufline(l:debugBufName, 3, "Debug Buffer name: " . l:debugBufName)
  "call setbufline(l:debugBufName, 10, "Edit hex: " . b:edithex)
  "call setbufline(l:debugBufName, 11, "Binary: " . b:edithex)
  "call setbufline(l:debugBufName, 12, "Hexmod: " . b:edithex)
  "call setbufline(l:debugBufName, 13, "FileType: " . b:filetype)

  let l:loopCounter = 0
  for key in keys(a:debugDict)
    call setbufline(l:debugBufName, 4 + l:loopCounter, key . a:debugDict[key])
    let l:loopCounter += 1
  endfor
endfunction
