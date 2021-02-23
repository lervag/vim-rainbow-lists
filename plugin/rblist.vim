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
" call s:init_option('rblist_global_load', 1)

" Initialize global commands
command! RBListEnable   call rblist#enable()
command! RBListDisable  call rblist#disable()
command! RBListReload   call rblist#reload()

" Initialize mappings
nnoremap <silent> <plug>(rblist-enable)    :RBListEnable<cr>
nnoremap <silent> <plug>(rblist-disable)   :RBListDisable<cr>
nnoremap <silent> <plug>(rblist-reload)    :RBListReload<cr>

" Apply default mappings
call s:init_default_mappings({
      \ '<plug>(rblist-enable)': '<leader>re',
      \ '<plug>(rblist-disable)': '<leader>rd',
      \ '<plug>(rblist-reload)': '<leader>rr',
      \})
