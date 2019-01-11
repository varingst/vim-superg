if get(g:, 'gG_loaded') || v:version < 800
  finish
endif

let s:default_mappings = {
      \ 'gG': 'gG#()',
      \ '<leader>$': "gG#N('j', 'k').'$'",
      \ '<leader>_': "gG#N('j', 'k').'_'",
      \}

if get(g:, 'gG_mappings', 1)
  for [lhs, rhs] in items(s:default_mappings)
    if !strlen(maparg(lhs))
      exe printf('noremap <expr> %s %s', lhs, rhs)
    endif
  endfor
endif

function! gG#() " {{{1
  return printf(gG#modefmt('G'), gG#G(line('.'), v:count))
endfun

function! gG#N(down, up, ...) " {{{1
  let lnum = line('.')
  let delta = lnum - gG#G(lnum, v:count)
  echo delta
  if delta == 0
    return "\<ESC>".(a:0 ? a:1 : '')
  endif
  return printf("\<ESC>%d%s", abs(delta), delta < 0 ? a:down : a:up)
endfun

function! gG#G(lnum, count) " {{{1
  let max = line('$')

  if a:count <= 0 || a:count > max
    return a:lnum
  endif

  let count_str = string(a:count)
  let lnum_str = string(a:lnum)

  let mid = str2nr(
        \ substitute(lnum_str,
        \            '\d\{'.strlen(count_str).',1}$',
        \            count_str,
        \            ''))

  let step = float2nr(pow(10, strlen(count_str)))

  let lo = mid - step
  let hi = mid + step

  if lo > 0
    let closest = a:lnum - lo < abs(a:lnum - mid)
          \ ? lo
          \ : mid
  else
    let closest = mid
  endif

  if hi <= max
    return abs(a:lnum - closest) < (hi - a:lnum)
          \ ? closest
          \ : hi
  else
    return closest <= max
          \ ? closest
          \ : lo
  endif
endfun

fun! gG#modefmt(s) " {{{1
  let mode = mode(1)
  if mode[1] ==# 'o'
    return "\<ESC>".v:operator."%d".a:s
  elseif mode =~? 'v'
    return "\<ESC>gv%d".a:s
  elseif mode ==# 'n'
    return "\<ESC>%d".a:s
  else
    throw printf('gG: unsupported mode: '%s', mode())
  endif
endfun

if get(g:, 'gG_TESTING')
  fun! S(f, ...)
    return call('s:'.a:f, a:000)
  endfun
  fun! Ref(name)
    return s:[a:name]
  endfun
endif
