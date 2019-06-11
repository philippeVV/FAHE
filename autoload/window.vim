function! window#BufOptions()
  "Buffer option
  setlocal bufhidden=hide " hide thhe buffer instead of unloading it
  setlocal buftype=nofile " buffer attach to no file (won't try to save it)
  setlocal noswapfile " don't create swap file for this buffer
  setlocal nobin " Should not be necessary

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

function! window#CreateWindow()
  let l:splitLocation = "botright "
  let l:splitSize = "50"

  silent! exec l:splitLocation . " vertical " . l:splitSize . " new"
  silent! exec 'buffer bufferNameTest'
  
  call window#BufOptions()
endfunction
