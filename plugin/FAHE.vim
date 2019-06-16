" Vim filetype plugin to allow binary format analysis and hex editing. (FAHE)
" Last change: In development
" Maintainer: Philippe Van Velzen
" License: Vim license

" The code to toggle Hexmode come from: 
" https://vim.fandom.com/wiki/Improved_hex_editing

let s:save_cpo = &cpo
set cpo&vim

if exists("g:loaded_fahe")
  finish
endif
let g:loaded_fahe = 1


nnoremap <C-H> :Hexmode<CR>
inoremap <C-H> <Esc>:Hexmode<CR>
vnoremap <C-H> :<C-U>Hexmode<CR>

" toggle hex mode
command -bar Hexmode call ToggleHex()

" ToggleHex(). Save old buffer variable. --- {{{
function! ToggleHex()
  " save old buffer parameter
  let l:modified = &mod
  let l:oldreadonly = &readonly | let &readonly=0
  let l:oldmodifiable = &modifiable | let &modifiable=1

  if !exists("b:editHex") || !b:editHex
    let b:oldbin = &bin | let &bin=1
    silent :edit
    let b:editHex = 1
    %!xxd
    let b:oldft = &ft | let &ft="xxd"
  else
    let &bin=b:oldbin
    let b:editHex = 0
    %!xxd -r
    "ugly! should have been in xxd.vim, but doesn't work if it 
    "isn't declare in the file that make the ft change.
    let b:undo_ftplugin = "au! s:xxd | aug! s:xxd" 
    let &ft=b:oldft
  endif

  " Restore old buffer parameter
  let &mod=l:modified
  let &readonly=l:oldreadonly
  let &modifiable=l:oldmodifiable
endfunction 
" }}}

" autocmd for hexmode management from '' --- {{{
"autocmds to automatically enter hex mode and handle file writes properly
if has("autocmd")
  " vim -b : edit binary using xxd-format!
  augroup Binary
    au!
    au BufReadPre *.bin,*.hex setlocal binary

    " if on a fresh read the buffer variable is already set, it's wrong
    au BufReadPost * 
          \ if exists('b:editHex') && b:editHex | 
          \   let b:editHex = 0 |
          \ endif

    " convert to hex on startup for binary files automatically
    au BufReadPost *
          \ if &binary |
          \   echom "Warning!" . &binary |
          \ endif

    " When the text is freed, the next time the buffer is made active it will
    " re-read the text and thus not match the correct mode, we will need to
    " convert it again if the buffer is again loaded.
    au BufUnload *
          \ if getbufvar(expand("<afile>"), 'editHex') == 1 |
          \   call setbufvar(expand("<afile>"), 'editHex', 0) |
          \ endif

    " before writing a file when editing in hex mode, convert back to non-hex
    au BufWritePre *
          \ if exists("b:editHex") && b:editHex && &binary |
          \  let oldro=&ro | let &ro=0 |
          \  let oldma=&ma | let &ma=1 |
          \  silent exe "%!xxd -r" |
          \  let &ma=oldma | let &ro=oldro |
          \  unlet oldma | unlet oldro |
          \ endif

    " after writing a binary file, if we're in hex mode, restore hex mode
    au BufWritePost *
          \ if exists("b:editHex") && b:editHex && &binary |
          \  let oldro=&ro | let &ro=0 |
          \  let oldma=&ma | let &ma=1 |
          \  silent exe "%!xxd" |
          \  exe "set nomod" |
          \  let &ma=oldma | let &ro=oldro |
          \  unlet oldma | unlet oldro |
          \ endif
  augroup END
endif
" }}}

let &cpo = s:save_cpo
unlet s:save_cpo
