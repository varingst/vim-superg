if get(g:, 'superg_loaded') || v:version < 800
  finish
endif

nnoremap <expr><Plug>SuperG "\<ESC>".superg#G()
vnoremap <expr><Plug>SuperG "\<ESC>V".superg#G()
onoremap <expr><Plug>SuperG "\<ESC>V".superg#G().v:operator

onoremap <silent><Plug>SuperSOL <ESC>:call superg#StartOfLine('o', v:prevcount, v:operator)<CR>
onoremap <silent><Plug>SuperEOL <ESC>:call superg#EndOfLine('o', v:prevcount, v:operator)<CR>

nnoremap <silent><Plug>SuperSOL <ESC>:call superg#StartOfLine('n', v:prevcount, v:operator)<CR>
nnoremap <silent><Plug>SuperEOL <ESC>:call superg#EndOfLine('n', v:prevcount, v:operator)<CR>

vnoremap <silent><Plug>SuperSOL <ESC>:call superg#StartOfLine('v', v:prevcount, v:operator)<CR>
vnoremap <silent><Plug>SuperEOL <ESC>:call superg#EndOfLine('v', v:prevcount, v:operator)<CR>

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
    let closest = abs(a:lnum - closest) < (hi - a:lnum)
              \ ? closest
              \ : hi
  else
    let closest = closest <= max
              \ ? closest
              \ : lo
  endif

  return closest
endfun

fun! superg#StartOfLine(mode, count, operator)
  let target = superg#(line('.'), a:count)
  if a:mode == 'o'
    let sel_save = &selection
    set selection=exclusive

    exe printf("normal! v%dG^%s", target, a:operator)

    exe 'set selection='.sel_save
  elseif a:mode == 'n'
    exe printf("normal! %dG^", target)
  elseif a:mode == 'v'
    exe printf("normal! gv%dG^", target)
  endif
endfun

fun! superg#EndOfLine(mode, count, operator)
  let target = superg#(line('.'), a:count)
  if a:mode == 'o'
    let sel_save = &selection
    set selection=exclusive

    exe printf("normal! v%dG$%s", target, a:operator)

    exe 'set selection='.sel_save
  elseif a:mode == 'n'
    exe printf("normal! %dG$", target)
  elseif a:mode == 'v'
    exe printf("normal! gv%dG$", target)
  endif
endfun

let g:superg_loaded = 1
