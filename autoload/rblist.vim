" vim-rainbow-lists - nested highlighting of lists
"
" Maintainer: Karl Yngve Lervåg
" Email:      karl.yngve@gmail.com
"

function! rblist#enable() abort " {{{1
  echo 'enabled'
endfunction

" }}}1
function! rblist#disable() abort " {{{1
  echo 'disabled'
endfunction

" }}}1

" {{{1 function! rblist#reload()
let s:file = expand('<sfile>')
if get(s:, 'reload_guard', 1)
  function! rblist#reload() abort
    let s:reload_guard = 0

    " Reload autoload scripts
    for l:file in [s:file]
          \ + split(globpath(fnamemodify(s:file, ':h'), '**/*.vim'), '\n')
      execute 'source' l:file
    endfor

    " Reload plugin
    if exists('g:rblist_loaded')
      unlet g:rblist_loaded
      runtime plugin/rblist.vim
    endif

    unlet s:reload_guard
  endfunction
endif

" }}}1
