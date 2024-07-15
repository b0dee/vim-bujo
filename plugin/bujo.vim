" bujo.vim - A Bullet Journal system for Vim
" Maintainer:   Joe Paterson
" Version:      0.1

if exists('g:loaded_bujo')
  finish
endif
let g:loaded_bujo = 1

command! -nargs=* -bang Index call bujo#OpenIndex(<bang>0, <f-args>)
command! -nargs=* -bang Today call bujo#OpenDaily(<f-args>)
command! -nargs=+ -bang Task  call bujo#CreateEntry(bujo#GetInternalVariable('BUJO_TASK'),    <bang>0,   <f-args>)
command! -nargs=+ -bang Event call bujo#CreateEntry(bujo#GetInternalVariable('BUJO_EVENT'),   <bang>0,   <f-args>)
command! -nargs=+ -bang Note  call bujo#CreateEntry(bujo#GetInternalVariable('BUJO_NOTE'),    <bang>0,   <f-args>)
command! -nargs=+ Collection  call bujo#CreateCollection(<f-args>)
command! -nargs=* Backlog call bujo#OpenBacklog(<f-args>)
command! -nargs=* Future call bujo#OpenFuture(<f-args>)
command! -nargs=* Monthly call bujo#OpenMonthly(<f-args>)
