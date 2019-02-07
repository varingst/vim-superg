if get(g:, 'superg_loaded') || v:version < 800
  finish
endif

nnoremap <expr><Plug>SuperG "\<ESC>".superg#G()
vnoremap <expr><Plug>SuperG "\<ESC>V".superg#G()
onoremap <expr><Plug>SuperG "\<ESC>V".superg#G().v:operator

function! superg#G() abort " {{{1
  let lnum = line('.')
  let l:count = v:count
  if l:count == 0 && exists('g:superg_fallback')
    return g:superg_fallback
  endif

  return superg#(line('.'), v:count)."G"
endfun

function! superg#(lnum, count) abort " {{{1
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

let g:superg_loaded = 1
