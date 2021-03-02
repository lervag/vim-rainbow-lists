" vim-rainbow-lists - nested highlighting of lists
"
" Maintainer: Karl Yngve Lervåg
" Email:      karl.yngve@gmail.com
"

if exists('g:rblist_loaded') | finish | endif
let g:rblist_loaded = 1

function! s:init_option(name, default) abort " {{{1
  let l:option = 'g:' . a:name
  if !exists(l:option)
    let {l:option} = a:default
  elseif type(a:default) == type({})
    call s:extend_recursive({l:option}, a:default, 'keep')
  endif
endfunction

" }}}1
function! s:init_default_mappings(dict) abort " {{{1
  for [l:rhs, l:lhs] in items(a:dict)
    if l:rhs[0] !=# '<'
      let l:mode = l:rhs[0]
      let l:rhs = l:rhs[2:]
    else
      let l:mode = 'n'
    endif

    if hasmapto(l:rhs, l:mode)
      continue
    endif

    execute l:mode . 'map <silent>' l:lhs l:rhs
  endfor
endfunction

" }}}1
function! s:extend_recursive(dict1, dict2, ...) abort " {{{1
  let l:option = a:0 > 0 ? a:1 : 'force'
  if index(['force', 'keep', 'error'], l:option) < 0
    throw 'E475: Invalid argument: ' . l:option
  endif

  for [l:key, l:value] in items(a:dict2)
    if !has_key(a:dict1, l:key)
      let a:dict1[l:key] = l:value
    elseif type(l:value) == type({})
      call wiki#u#extend_recursive(a:dict1[l:key], l:value, l:option)
    elseif l:option ==# 'error'
      throw 'E737: Key already exists: ' . l:key
    elseif l:option ==# 'force'
      let a:dict1[l:key] = l:value
    endif
    unlet l:value
  endfor

  return a:dict1
endfunction

" }}}1


" Initialize options
call s:init_option('rblist_levels', 4)

" Initialize global commands
command! RBListEnable   call rblist#enable()
command! RBListDisable  call rblist#disable()
command! RBListToggle   call rblist#toggle()

" Initialize mappings
nnoremap <silent> <plug>(rblist-enable)    :RBListEnable<cr>
nnoremap <silent> <plug>(rblist-disable)   :RBListDisable<cr>
nnoremap <silent> <plug>(rblist-toggle)    :RBListToggle<cr>

" Apply default mappings
call s:init_default_mappings({
      \ '<plug>(rblist-toggle)': '<leader>rr',
      \ '<plug>(rblist-enable)': '<leader>re',
      \ '<plug>(rblist-disable)': '<leader>rd',
      \})

" Initialize default highlight groups
highlight def link RBListsO0 Constant
highlight def link RBListsO1 Identifier
highlight def link RBListsO2 Statement
highlight def link RBListsO3 PreProc
for s:i in range(g:rblist_levels)
  execute printf('highlight def link RBListsU%d RBListsO%d', s:i, s:i)
  execute printf('highlight def link RBListsQ%d RBListsO%d', s:i, s:i)
endfor
highlight def link RBListsB0 Type
highlight def link RBListsB1 Constant
highlight def link RBListsB2 Identifier
highlight def link RBListsB3 Statement
