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
    call s:enable_syntax_quotes(i)
    call s:enable_syntax_unordered(i)
    call s:enable_syntax_ordered(i)
  endfor

  let b:rblist_enabled = 1
endfunction

" }}}1
function! rblist#disable() abort " {{{1
  if !rblist#enabled() | return | endif

  for i in range(g:rblist_levels)
    execute 'syntax clear RBListsO' . i
    execute 'syntax clear RBListsU' . i
    execute 'syntax clear RBListsQ' . i
    execute 'syntax clear RBListsB' . i
  endfor

  unlet b:rblist_enabled
endfunction

" }}}1

function! s:enable_syntax_ordered(i) abort " {{{1
  let grpItem = 'RBListsO' . a:i
  let grpBullet = 'RBListsB' . a:i
  let re_number = '\%(\d\+\.\)\s'
  let contains = 'contains=TOP,mkdNonListItemBlock'

  if a:i == 0
    execute 'syntax region' grpItem
          \ 'start="^' . re_number . '"'
          \ 'end="^\ze\S"'
          \ contains
    execute 'syntax match' grpBullet
          \ '"^' . re_number . '"'
          \ 'contained containedin=' . grpItem
  else
    let contains .= ',' . join(map(range(a:i), '"RBListsO" . v:val'), ',')

    for indent in [a:i*&shiftwidth, a:i*3]
      let re_start = '"^\s\{' . indent . '}' . re_number . '"'

      execute 'syntax region' grpItem
            \ 'start=' . re_start
            \ 'end="^\ze\s\{,' . indent . '}\S"'
            \ contains
      execute 'syntax match' grpBullet
            \ re_start
            \ 'contained containedin=' . grpItem
    endfor
  endif
endfunction

" }}}1
function! s:enable_syntax_unordered(i) abort " {{{1
  let grpItem = 'RBListsU' . a:i
  let grpBullet = 'RBListsB' . a:i
  let re_bullets = '\%(>\|[-*]\%( \[[ Xx.]\]\)\?\)\s'
  let contains = 'contains=TOP,mkdNonListItemBlock'

  if a:i == 0
    execute 'syntax region' grpItem
          \ 'start="^' . re_bullets . '"'
          \ 'end="^\ze\S"'
          \ contains
    execute 'syntax match' grpBullet
          \ '"^' . re_bullets . '"'
          \ 'contained containedin=' . grpItem
  else
    let contains .= ',' . join(map(range(a:i), '"RBListsO" . v:val'), ',')
    let indent = a:i*&shiftwidth
    let re_start = '"^\s\{' . indent . '}' . re_bullets . '"'

    execute 'syntax region' grpItem
          \ 'start=' . re_start
          \ 'end="^\ze\s\{,' . indent . '}\S"'
          \ contains
    execute 'syntax match' grpBullet
          \ re_start
          \ 'contained containedin=' . grpItem
  endif

  execute 'syntax cluster mkdNonListItem add=' . grpItem
endfunction

" }}}1
function! s:enable_syntax_quotes(i) abort " {{{1
  let grpItem = 'RBListsQ' . a:i
  let grpBullet = 'RBListsB' . a:i
  let re_quote = repeat('> ', a:i) . '>\s*'

  execute 'syntax match' grpItem '"^' . re_quote . '.*"'
  execute 'syntax match' grpBullet '"^' . re_quote . '"'
        \ 'contained containedin=' . grpItem

  execute 'syntax cluster mkdNonListItem add=' . grpItem
endfunction

" }}}1
