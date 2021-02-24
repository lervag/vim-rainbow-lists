" vim-rainbow-lists - nested highlighting of lists
"
" Maintainer: Karl Yngve Lervåg
" Email:      karl.yngve@gmail.com
"

function! rblist#enabled() abort " {{{1
  return exists('b:rblist_enabled')
endfunction

" }}}1
" {{{1 function! rblist#toggle() abort

if get(s:, 'reload_guard', 1)
  function! rblist#toggle() abort
    if rblist#enabled()
      call rblist#disable()
      call rblist#reload()
    else
      call rblist#enable()
    endif
  endfunction
endif

" }}}1
" {{{1 function! rblist#reload() abort

if get(s:, 'reload_guard', 1)
  function! rblist#reload() abort
    let s:reload_guard = 0

    " Reload autoload scripts
    for filename in [s:file]
          \ + split(globpath(fnamemodify(s:file, ':h'), '**/*.vim'), '\n')
      execute 'source' filename
    endfor

    " Reload plugin
    if exists('g:rblist_loaded')
      unlet g:rblist_loaded
      runtime plugin/rblist.vim
    endif

    unlet s:reload_guard
  endfunction
endif

let s:file = expand('<sfile>')

" }}}1

function! rblist#enable() abort " {{{1
  if rblist#enabled() | return | endif

  for i in range(g:rblist_levels)
    call s:create_syntax_level(i)
  endfor

  let b:rblist_enabled = 1
endfunction

" }}}1
function! rblist#disable() abort " {{{1
  if !rblist#enabled() | return | endif

  for i in range(4)
    execute 'syntax clear RBListsI' . i
    execute 'syntax clear RBListsB' . i
  endfor

  unlet b:rblist_enabled
endfunction

" }}}1

function! s:create_syntax_level(i) abort " {{{1
  let grpItem = 'RBListsI' . a:i
  let grpBullet = 'RBListsB' . a:i
  let contains = 'contains=TOP'

  if a:i == 0
    let re_indent = ''
    let re_indent_neg = '\S'
  else
    let indent = a:i*&shiftwidth
    let re_indent = '\s\{' . indent . '}'
    let re_indent_neg = '\s\{,' . indent . '}\S'
    let contains .= ',' . join(map(range(a:i), '"RBListsI" . v:val'), ',')
  endif

  let re_bullets = '[*-]'
  let re_start = '"^' . re_indent . re_bullets . '"'
  let re_continue = '"^' . re_indent . '\%(' . re_bullets . '\)\@<!"'
  let match_end = 'end="^\ze' . re_indent_neg . '"'

  execute 'syntax region' grpItem 'start=' . re_start    match_end contains
  execute 'syntax region' grpItem 'start=' . re_continue match_end contains
  execute 'syntax match' grpBullet re_start 'contained containedin=' . grpItem
endfunction

" }}}1
