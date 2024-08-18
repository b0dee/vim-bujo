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

command! -nargs=* -bang Journal      call bujo#Journal(<bang>0, <f-args>)
command! -nargs=* -bang Index        call bujo#Index(<bang>0, <f-args>)
command! -nargs=* -bang Collection   call bujo#Collection(<bang>0, <f-args>)

command! -nargs=+ -bang Event        call bujo#CreateEntry(bujo#GetInternalVariable('BUJO_EVENT'), <bang>0, <f-args>)
command! -nargs=* -bang FutureEvent  call bujo#FutureEntry(bujo#GetInternalVariable('BUJO_EVENT'), <bang>0, <f-args>)
command! -nargs=*       MonthlyEvent call bujo#MonthlyEntry(bujo#GetInternalVariable('BUJO_EVENT'), <f-args>)

command! -nargs=+ -bang Task         call bujo#CreateEntry(bujo#GetInternalVariable('BUJO_TASK'), <bang>0, <f-args>)
command! -nargs=* -bang FutureTask   call bujo#FutureEntry(bujo#GetInternalVariable('BUJO_TASK'), <bang>0, <f-args>)
command! -nargs=*       MonthlyNote  call bujo#MonthlyEntry(bujo#GetInternalVariable('BUJO_NOTE'), <f-args>)

command! -nargs=+ -bang Note         call bujo#CreateEntry(bujo#GetInternalVariable('BUJO_NOTE'), <bang>0, <f-args>)
command! -nargs=* -bang FutureNote   call bujo#FutureEntry(bujo#GetInternalVariable('BUJO_NOTE'), <bang>0, <f-args>)
command! -nargs=*       MonthlyTask  call bujo#MonthlyEntry(bujo#GetInternalVariable('BUJO_TASK'), <f-args>)


command! -nargs=* Today       call bujo#Today()
command! -nargs=* Tomorrow    call bujo#Tomorrow()
command! -nargs=* Yesterday   call bujo#Yesterday()
command! -nargs=* Thisweek    call bujo#ThisWeek()
command! -nargs=* Nextweek    call bujo#NextWeek()
command! -nargs=* Lastweek    call bujo#LastWeek()
command! -nargs=* Future      call bujo#Future(<f-args>)
command! -nargs=* Monthly     call bujo#Monthly(<f-args>)
command! -nargs=* Backlog      call bujo#Backlog(<f-args>)

command! -nargs=* -bang Outstanding   call bujo#Outstanding()
command! -nargs=* -bang TaskList   call bujo#ListTasks(<bang>0)
command! -nargs=* -bang ListTasks   call bujo#ListTasks(<bang>0)
