" bujo.vim - A Bullet Journal system for Vim
" Maintainer:   Joe Paterson
" Version:      0.1

if exists('g:loaded_bujo')
  finish
endif
let g:loaded_bujo = 1


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

" TODO
" command! -nargs=* -bang ListEvents   call bujo#ListEvents()
" NOTE: Bang means list tasks in ALL journals, arguments provided are used as journal or default is used 
" command! -nargs=* -bang ListTasks   call bujo#ListTasks()
" NOTE: Bang means list tasks in ALL journals, arguments provided are used as journal or default is used 
" g:bujo_git_sync = v:true 
" NOTE: This will auto push/pull if enabled and in git repo
"
"" TODO - Features:
"" TODO - CORE:
"" TODO - Reflect Command
""      - ability to have this be done automatically/ prompt (perhaps controllable so can be silenced) when
""      - launching any bujo command
""      - Arguments provided are used as journal or default is used 
""      - Initialises next weeks daily log showing the past week in horizontal split and monthly log in 
""      - vert split to move tasks in where needed 
"" TODO - Automatic git pull, commit and push 
"" TODO - Monthly Log: Cron scheduling of monthly headers (to auto populate table)
"" TODO - Migration functionality
"" TODO - Motions to navigate/ prepopulate command (outside bujo file)
"" TODO - Motions within BuJo files
""        i.e. '<leader><<' in daily log can prompt
""        user to specify month and will migrate entry to future log etc., >> will move to next monthly log
"" TODO - List: list_replace_entry 
""        Needed for updating index and monthly log link to daily log 

"" TODO - Enhancement: 
"" TODO - RenameCollection Command
"" TODO - RenameJournal Command
""        These needs to update any open vim buffers to be the new path, same
""        way that fugitive etc. do
"" TODO - Have commands be smart enough to put things under appropriate header/collection when 1st, 2nd etc. args match existing (i.e. `collection xyz this is the new collection` would create that collection in xyz journal, `collection "Journal with spaces" "Collection with Spaces" Then create a new collection` would create a collection entry under collection header Collection with spaces in journal Journal with spaces)
"" TODO - Replace existing window if already open, don't spam create them
"" TODO - Monthly: Update table setting the row for today to have a link to daily log, remove the previous link
"" TODO - Make Vader test suite with expectations
"" TODO - Control insert/append based on entry type?
"" TODO - Future log: auto scroll to put this month header at top line
"" TODO - Future log: open a different year
"" TODO - Index: On open index update daily log entry to point to the correct daily file

"" TODO - Bug:
"" TODO - Make filenames replace special characters
"" TODO - Sort out issue with recording a weekly rolling daily log
"" TODO - list append/insert doesn't actually 'find todays header' it just inserts it a the top of the file
""        but when support for future daily log entries is added this may not be the case

"" TODO - Refactor: 
"" TODO - Make journal index use list_append_entry 
""        by providing a splice of list then replacing the remainder of the
""        file with whats returned from list_append_entry
