" bujo.vim - A Bullet Journal system for Vim
" Maintainer:   Joe Paterson
" Version:      0.1

if exists('g:loaded_bujo')
  finish
endif
let g:loaded_bujo = 1

if !exists('g:bujo_journal_statusline_prepend')
  let g:bujo_journal_statusline_prepend = ""
endif
if !exists('g:bujo_journal_statusline_append')
  let g:bujo_journal_statusline_append = "Journal"
endif

function! BujoCurrent() abort
  let l:prepend = len(g:bujo_journal_statusline_prepend) == 0 ? "": " " . g:bujo_journal_statusline_prepend
  let l:append = len(g:bujo_journal_statusline_append) == 0 ? "": " " . g:bujo_journal_statusline_append
  return l:prepend . bujo#FormatFromPath(bujo#GetInternalVariable('current_journal')) . l:append
endfunction

command! -nargs=* -bang Journal      call bujo#Journal(<bang>0, <f-args>)
command! -nargs=* -bang Index        call bujo#OpenIndex(<bang>0, <f-args>)
command! -nargs=* -bang Collection   call bujo#Collection(<bang>0, <f-args>)

command! -nargs=* -bang Today        call bujo#OpenDaily(<f-args>)
command! -nargs=+ -bang Task         call bujo#CreateEntry(bujo#GetInternalVariable('BUJO_TASK'),    <bang>0,   <f-args>)
command! -nargs=+ -bang Event        call bujo#CreateEntry(bujo#GetInternalVariable('BUJO_EVENT'),   <bang>0,   <f-args>)
command! -nargs=+ -bang Note         call bujo#CreateEntry(bujo#GetInternalVariable('BUJO_NOTE'),    <bang>0,   <f-args>)

command! -nargs=*       Future       call bujo#OpenFuture(<f-args>)
command! -nargs=* -bang FutureEvent  call bujo#FutureEntry(bujo#GetInternalVariable('BUJO_EVENT'), <bang>0, <f-args>)
command! -nargs=* -bang FutureTask   call bujo#FutureEntry(bujo#GetInternalVariable('BUJO_TASK'), <bang>0, <f-args>)
command! -nargs=* -bang FutureNote   call bujo#FutureEntry(bujo#GetInternalVariable('BUJO_NOTE'), <bang>0, <f-args>)

command! -nargs=*       Monthly      call bujo#OpenMonthly(<f-args>)
command! -nargs=*       MonthlyEvent call bujo#MonthlyEntry(bujo#GetInternalVariable('BUJO_EVENT'), <f-args>)
command! -nargs=*       MonthlyTask  call bujo#MonthlyEntry(bujo#GetInternalVariable('BUJO_TASK'), <f-args>)
command! -nargs=*       MonthlyNote  call bujo#MonthlyEntry(bujo#GetInternalVariable('BUJO_NOTE'), <f-args>)

command! -nargs=*       Backlog      call bujo#OpenBacklog(<f-args>)

command! -nargs=* -bang TaskList   call bujo#ListTasks(<bang>0)
command! -nargs=* -bang ListTasks   call bujo#ListTasks(<bang>0)
