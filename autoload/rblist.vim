" vim-rainbow-lists - nested highlighting of lists
"
" Maintainer: Karl Yngve Lervåg
" Email:      karl.yngve@gmail.com
"

function! rblist#enable() abort " {{{1
  syntax region RBListsI0 start=/^[*-]/            end=/^\%(\S\)\@=/ contains=TOP
  syntax region RBListsI0 start=/^  \%([*-]\)\@<!/ end=/^\%(\S\)\@=/ contains=TOP
  syntax match RBListsB0 /^\zs[*-]/ contained containedin=RBListsI0

  for i in range(1, 3)
    let indent = i*&shiftwidth
    let contains = 'contains=TOP,' . join(map(range(i), '"RBListsI" . v:val'), ',')
    execute printf('syntax region RBListsI%d start=/^\s\{%d}[*-]/            end=/^\%(\s\{,%d}\S\)\@=/ %s', i, indent, indent, contains)
    execute printf('syntax region RBListsI%d start=/^\s\{%d}  \%([*-]\)\@<!/ end=/^\%(\s\{,%d}\S\)\@=/ %s', i, indent, indent, contains)
    execute printf('syntax match RBListsB%d /^\s\{%d}[*-]/ contained containedin=RBListsI%d', i, indent, i)
  endfor

  highlight def link RBListsI0 Constant
  highlight def link RBListsI1 Identifier
  highlight def link RBListsI2 Statement
  highlight def link RBListsI3 PreProc
  highlight def link RBListsB0 Identifier
  highlight def link RBListsB1 Statement
  highlight def link RBListsB2 PreProc
  highlight def link RBListsB3 Type
endfunction

" }}}1
function! rblist#disable() abort " {{{1
  for i in range(4)
    execute 'syntax clear RBListsI' . i
    execute 'syntax clear RBListsB' . i
  endfor
endfunction

" }}}1

" {{{1 function! rblist#reload()
let s:file = expand('<sfile>')
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

" }}}1
