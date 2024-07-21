" The functions contained within this file are for internal use only.  For the
" official API, see the commented functions in plugin/bujo.vim.

if exists('g:autoloaded_bujo')
  finish
endif
let g:autoloaded_bujo = 1


" Constants/ Enums
let s:BUJO_NOTE = "note"
let s:BUJO_TASK = "task"
let s:BUJO_EVENT = "event"
let s:BUJO_DAILY = "daily"
let s:BUJO_BACKLOG = "backlog"
let s:BUJO_MONTHLY = "monthly"
let s:BUJO_FUTURE = "future"
let s:THIS_YEAR = strftime("%Y")
let s:THIS_MONTH = strftime("%m")

if !exists('g:bujo_path')
	let g:bujo_path = '~/repos/bujo/'
endif
if !exists('g:bujo_index_winsize')
	let g:bujo_index_winsize = 30
endif
if !exists('g:bujo_default_journal')
  let g:bujo_default_journal = "Default"
endif
if !exists('g:bujo_split_right')
  let g:bujo_split_right = &splitright
endif
if !exists('g:bujo_journal_statusline_prepend')
  let g:bujo_journal_statusline_prepend = ""
endif
if !exists('g:bujo_journal_statusline_append')
  let g:bujo_journal_statusline_append = "Journal"
endif



" Daily Log vars
let s:bujo_daily_filename = s:BUJO_DAILY . "_%Y-%m-%{#}.md"
if !exists('g:bujo_daily_winsize')
	let g:bujo_daily_winsize = 50
endif
let s:bujo_daily_header =  "# %A %B %d" 
let s:bujo_daily_task_header =  "**Tasks:**"
let s:bujo_daily_event_header =  "**Events:**" 
let s:bujo_daily_note_header =  "**Notes:**"

if !exists('g:bujo_header_entries_ordered')
  let g:bujo_header_entries_ordered = [
  \ s:BUJO_EVENT,
  \ s:BUJO_TASK,
  \ s:BUJO_NOTE,
  \]
endif

let s:bujo_header_entries = {
\ s:BUJO_EVENT: {
\   "name": s:BUJO_EVENT,
\   "header": s:bujo_daily_event_header,
\   "list_char": "*",
\   "daily_enabled": v:true,
\   "future_enabled": v:true,
\   "monthly_enabled": v:true,
\   "backlog_enabled": v:false
\ },
\ s:BUJO_TASK : {
\   "name": s:BUJO_TASK,
\   "header": s:bujo_daily_task_header,
\   "list_char": "- [ ]",
\   "daily_enabled": v:true,
\   "future_enabled": v:true,
\   "monthly_enabled": v:true,
\   "backlog_enabled": v:true
\ },
\ s:BUJO_NOTE: {
\   "name": s:BUJO_NOTE,
\   "header": s:bujo_daily_note_header,
\   "list_char": "",
\   "daily_enabled": v:true,
\   "future_enabled": v:true,
\   "monthly_enabled": v:true,
\   "backlog_enabled": v:false
\ }
\}

" Add in custom index entries from global dictionary
if exists("g:bujo_header_entries") 
  call extend(s:bujo_header_entries, g:bujo_header_entries)
endif

" Options: month_long, month_short
" 0 = Don't include header
" 1 = Include header
" 2 = Smart inclusion only if events scheduled for this day
if !exists('g:bujo_daily_include_event_header')
	let g:bujo_daily_include_event_header = 0
endif

" Future Log vars
let s:bujo_future_filename = s:BUJO_FUTURE . "_%Y.md"
if !exists('g:bujo_future_header')
	let g:bujo_future_header =  "# {journal} Future Log - %Y" 
endif
" Available replacements: 
" - Long month name: %B
" - Short month name: %b
if !exists('g:bujo_future_month_header')
	let g:bujo_future_month_header =  "# %B" 
endif

" Monthly Log vars
let s:bujo_monthly_filename = s:BUJO_MONTHLY . "_%Y_%m.md"
if !exists('g:bujo_monthly_header')
	let g:bujo_monthly_header = "# %B %Y"
endif
if !exists('g:bujo_monthly_table_enabled')
	let g:bujo_monthly_table_enabled = v:true
endif
if !exists('g:bujo_monthly_table_align')
	let g:bujo_monthly_table_align = v:true
endif

if !exists('g:bujo_monthly_table_headers_ordered')
  let g:bujo_monthly_table_headers_ordered = [
  \ "gratitude",
  \ "meditation",
  \ "reading"
  \ ]
endif
if !exists('g:bujo_monthly_table_headers')
  let g:bujo_monthly_table_headers = { 
  \ "gratitude": {
  \		"display":"Gratitude",
  \		"cron":""
  \ },
  \ "meditation": {
  \		"display":"Meditation",
  \		"cron":""
  \ },
  \ "reading": {
  \		"display":"Reading",
  \		"cron":""
  \ }
  \ }
endif

" Backlog vars
let s:bujo_backlog_filename = "backlog.md"
if !exists('g:bujo_backlog_header')
	let g:bujo_backlog_header =  "# {journal} Backlog" 
endif


" Index vars
let s:bujo_index_header = "# {journal} Index"
if !exists('g:bujo_index_list_char')
	let g:bujo_index_list_char = "{#}"
endif
if !exists('g:bujo_index_enable_future')
	let g:bujo_index_enable_future = v:true
endif
if !exists('g:bujo_index_enable_monthly')
	let g:bujo_index_enable_monthly = v:true
endif
if !exists('g:bujo_index_enable_daily ')
	let g:bujo_index_enable_daily  = v:true
endif
if !exists('g:bujo_index_enable_backlog ')
	let g:bujo_index_enable_backlog  = v:true
endif
let s:bujo_index_entries = [
\ { 
\  "name": "Future Log",
\  "file": s:bujo_future_filename,
\ },
\ { 
\   "name": "Monthly Log",
\   "file": s:bujo_monthly_filename,
\ },
\ { 
\   "name": "Daily Log",
\   "file": s:bujo_daily_filename,
\ },
\ { 
\   "name": "Backlog",
\   "file": s:bujo_backlog_filename,
\ }
\]

" Add in custom index entries from global list
if exists("g:bujo_index_entries") 
  call extend(s:bujo_index_entries, g:bujo_index_entries)
endif

let s:date_suffixes = {
\ 1: "st",
\ 2: "nd",
\ 3: "rd",
\ 4: "th",
\ 5: "th",
\ 6: "th",
\ 7: "th",
\ 8: "th",
\ 9: "th",
\ 0: "th",
\ }
let s:bujo_months = [
  \ { "short": "Jan", "long": "January", "days": 31 },
  \ { "short": "Feb", "long": "February", "days": 28 },
  \ { "short": "Mar", "long": "March", "days": 31 },
  \ { "short": "Apr", "long": "April", "days": 30 },
  \ { "short": "May", "long": "May", "days": 31 },
  \ { "short": "Jun", "long": "June", "days": 30 },
  \ { "short": "Jul", "long": "July", "days": 31 },
  \ { "short": "Aug", "long": "August", "days": 31 },
  \ { "short": "Sep", "long": "September", "days": 30 },
  \ { "short": "Oct", "long": "October", "days": 31 },
  \ { "short": "Nov", "long": "November", "days": 30 },
  \ { "short": "Dec", "long": "December", "days": 31 },
\ ]
" i.e. let g:bujo_migrated_to_future = '<' -- Migrated to future log
"      > = Migrated to next week look
" etc

if !exists('g:bujo_vader_testing')
  let g:bujo_vader_testing = v:true
endif
if !exists('g:bujo_vader_mkdir_choice')
  let g:bujo_vader_mkdir_choice = 1
endif


function! s:strip_whitespace(input) abort
  return substitute(substitute(a:input, '^ *', '', "g"), " *$", "", "g")
endfunction

function! s:format_initial_case(input) abort
  return substitute(a:input, '\<.', '\U&', "g")
endfunction

function! s:format_title_case(input) abort
  return substitute(a:input, '\<.', '\U&', "")
endfunction


function! s:format_filename(filename)  abort
  return tolower(
      \ substitute(
        \ substitute(
          \ substitute(strftime(s:strip_whitespace(a:filename)), " ", "_", "g"), 
        \ '{#}', ((strftime("%d") / 7) + 1), "g"),
      \ '[!"£$%^&*;:''><\\\/|,())?\[\]]', "", "g"))
endfunction

" We setup g:bujo_default_journal at top of this file if it hasn't been set by
" user (will always have a value). Do this down here for use of above function
let s:current_journal = s:format_filename(g:bujo_default_journal)

function! s:get_formatted_journal(journal)
  " If the journal index doesn't exist we need to intialise it 
  " Other function has missed creating it
  call s:init_journal_index(a:journal)
  " Read the first line from the index file under the journal specified
  " Skip first 2 chars as these are always `# `
	return substitute(readfile(s:format_path(g:bujo_path, a:journal, "index.md"), "", 1)[0][2:-1], "Index", "", "g")
endfunction

function! s:format_header(header, journal = s:format_initial_case(s:current_journal))  abort
  return strftime(substitute(a:header, "{journal}", s:format_initial_case(a:journal), "g"))
endfunction

function! s:format_path(...) abort
	if a:0 == 0 
		echoerr "format_path requires at least 2 arguments"
	endif
	let l:path = ""
	for step in a:000
		if step[-1:-1] == "/" || step[-1:-1] == "\\" 
			let l:path .= expand(step[0:-2])
		else
			let l:path .= "/" . (step) 
		endif
	endfor
	return l:path
endfunction

function! s:format_from_path(journal, collection = "index.md") abort
  try 
    return substitute(readfile(s:format_path(g:bujo_path, a:journal, a:collection), "", 1)[0][2:-1], "index", "", "g")
  catch
    " This shouldn't happen, but sometimes while in dev so just easier 
    " If it does happen at least there's a fallback...
    return s:format_initial_case(substitute(a:journal, "_", " ", "g"))
  endtry
endfunction

function! s:list_journals() abort
	return readdir(expand(g:bujo_path), {f -> isdirectory(expand(g:bujo_path . f)) && f !~ "^[.]"})
endfunction

" mkdir_if_needed
" Returns true if user cancelled, false if already exists/created directory
" TODO - See if we can remove the bool return from here and rely on abort...
function! s:mkdir_if_needed(journal) abort
  let l:journal_dir = s:format_path(g:bujo_path, s:format_filename(a:journal))
  if isdirectory(l:journal_dir)
    return v:false
	endif

  let l:journal_print_name = s:format_initial_case(a:journal)
  let choice = g:bujo_vader_testing ? g:bujo_vader_mkdir_choice : confirm("Creating new journal `" . l:journal_print_name . "`. Continue Y/n (default: yes)?","&Yes\n&No")
  if l:choice != 1 
    echon "Aborting journal creation"
    return v:true
  endif

  call mkdir(l:journal_dir, "p", "0o775")
  return v:false
endfunction

function! s:init_journal_index(journal) abort
  let l:journal_dir = expand(g:bujo_path) . s:format_filename(a:journal)
  let l:journal_index = l:journal_dir . "/index.md"
  " We have already initialised index 
  if filereadable(l:journal_index) | return | endif

  let l:content = [s:format_header(s:bujo_index_header, a:journal), ""]
  let l:counter = 0
  for key in s:bujo_index_entries
    let l:counter += 1
    call add(l:content, substitute(g:bujo_index_list_char, "{#}", l:counter . ".", "g") . " [" . key["name"] . "](" . key["file"] . ")")
  endfor
  call writefile(l:content, l:journal_index)
endfunction

function! s:init_daily(journal) abort
  let l:formatted_daily_header = s:format_header(s:bujo_daily_header, a:journal) 
  let l:journal_dir = expand(g:bujo_path) . s:format_filename(a:journal) 
  let l:daily_log = l:journal_dir . "/". s:format_filename(s:bujo_daily_filename)
  " FIXME TODO - init_daily doesn't support future dates which is planned to be
  " added (future dates are at the top of the file, need to check whole file
  " for its existence)
  if filereadable(l:daily_log) && readfile(l:daily_log, "", 1)[0] ==# l:formatted_daily_header
    return
  endif

  let l:content = [l:formatted_daily_header, ""]

  if s:mkdir_if_needed(a:journal) | return | endif

  for key in g:bujo_header_entries_ordered
    if s:bujo_header_entries[key]["daily_enabled"]
      call add(l:content, s:bujo_header_entries[key]["header"])
      if g:bujo_daily_include_event_header == 2
      " TODO - implement smart event inclusion in daily log
      " Will likely come after calendar integration, need a way of finding all live events
        echoerr "Smart event creation Not implemented!"
        return
      endif
      if s:bujo_header_entries[key]["list_char"] !=# ""
        call add(l:content, s:bujo_header_entries[key]["list_char"] . " ")
        call add(l:content, "")
      endif
    endif
  endfor

  " Does the containing file have other daily log entries?
  if filereadable(l:daily_log) && readfile(l:daily_log, "", 1)[0] !=# l:formatted_daily_header
    " Add any pre-existing content to the file
    call extend(l:content, readfile(l:daily_log))
  endif

  " Write output to file
  call writefile(l:content, l:daily_log)
endfunction

function! s:init_future(year) abort
  let l:journal_dir = s:format_path(g:bujo_path, s:current_journal)
  let l:future_log = s:format_path(g:bujo_path, s:current_journal, s:BUJO_FUTURE . "_" . a:year . ".md")
  if filereadable(l:future_log)
    return
  endif
  let l:content = []
  call add(l:content, s:format_header(g:bujo_future_header))
  call add(l:content, "")
  if s:THIS_YEAR == a:year 
    " Skip the months that have already passed
    let l:months = s:bujo_months[strftime("%m") - 1:-1]
  else 
    let l:months = s:bujo_months
  endif 
  for month in l:months
    " TODO - This **will** break between systems. Will need to add a conditional to decide what to go with when we encounter it
    call add(l:content, substitute(substitute(g:bujo_future_month_header, "%B", month["long"], "g"), "%b", month["short"], "g"))
    call add(l:content, "")
    for key in g:bujo_header_entries_ordered
      if s:bujo_header_entries[key]["future_enabled"]
        call add(l:content, s:bujo_header_entries[key]["header"])
        call add(l:content, s:bujo_header_entries[key]["list_char"] . " ")
        call add(l:content, "")
      endif
    endfor
    call add(l:content, "")
    call writefile(l:content, l:future_log)
  endfor
endfunction

" FIXME - Doesn't handle if no prefilled entry exists 
" check if line == "" too
function! s:list_insert_entry(list, type_header, type_list_char, entry, stop_pattern = v:null) abort
  let l:index = 1
  let l:list_char = a:type_list_char . (a:type_list_char == "" ? "" : " " )
  for line in a:list
    if a:stop_pattern isnot v:null && line ==# a:stop_pattern | break | endif
    if line ==# a:type_header
      if l:list_char == ""
        call insert(a:list, "", l:index)
        let l:index += 1
      endif
      call insert(a:list, l:list_char . a:entry, l:index)
      return a:list
    endif
    let l:index += 1
  endfor

  " If we reach here, we've failed to locate the header
  " The only 'safe' way I can conceive to add this in is 
  " to locate todays header and insert it 3 lines below 
  " (leaving blank line below header)
  call insert(a:list, a:type_header, 2)
  call insert(a:list, l:list_char . a:entry, 3)
  call insert(a:list, l:list_char, 4)
  call insert(a:list, "", 5)
  return a:list
endfunction

" FIXME - Make notes actually append to either EOF 
" or before next header
" FIXME - Doesn't handle if no prefilled entry exists 
" check if line == "" too
" FIXME - Now adding lots of pre filled list entries
function! s:list_append_entry(list, type_header, type_list_char, entry)  abort
  let l:index = 1
  let l:list_char = a:type_list_char . (a:type_list_char == "" ? "" : " " )
  for line in a:list
    if line ==# a:type_header
      for item in a:list[l:index:-1]
        if item ==# l:list_char
          if l:list_char ==# ""
            call insert(a:list, "", l:index)
            let l:index += 1
          endif
          call insert(a:list, l:list_char . a:entry, l:index)
          return a:list
        endif
        let l:index += 1
      endfor
      break
    endif
    let l:index += 1
  endfor

  " If we reach here, we've failed to locate the header
  " The only 'safe' way I can conceive to add this in is 
  " to locate todays header and insert it 3 lines below 
  " (leaving blank line below header)
  let l:line = 2
  call insert(a:list, a:type_header, l:line)
  let l:line += 1
  if l:list_char == ""
    " we need to prepend an empty line to keep markdown formatting
    call insert(a:list, "", l:line)
    let l:line += 1
  endif
  call insert(a:list, l:list_char . a:entry, l:line)
  let l:line += 1
  call insert(a:list, l:list_char, l:line)
  if l:list_char != ""
    let l:line += 1
    call insert(a:list, "", l:line)
  endif
  return a:list
endfunction

function! s:list_replace_entry(list, target, new) abort
endfunction

function! s:list_collections(show_all) abort
  let l:collections = []
  if a:show_all
    let l:journals = s:list_journals()
    for journal in l:journals
      let l:entry = [journal, readdir(s:format_path(g:bujo_path, journal), {f -> f !~ '\(' . s:BUJO_DAILY . '\|' . s:BUJO_MONTHLY . '\|' . s:BUJO_FUTURE . '\|' . s:BUJO_BACKLOG. '\)'})]
      call add(l:collections, l:entry)
    endfor
  else
    call add(l:collections, [s:current_journal, readdir(s:format_path(expand(g:bujo_path), s:format_filename(s:current_journal)), {f -> f !~ '\(' . s:BUJO_DAILY . '\|' . s:BUJO_MONTHLY . '\|' . s:BUJO_FUTURE . '\|' . s:BUJO_BACKLOG. '\)'})])
  endif
  return l:collections
endfunction

function! s:format_list_collections(collections) abort
    let l:content = []
    for journal in a:collections
      let l:journal_name = s:format_from_path(journal[0])
      call add(l:content, "# " . l:journal_name)
      call add(l:content, "")
      for collection in journal[1]
        let l:formatted_entry = s:format_from_path(journal[0], collection)
        let l:entry_link = s:format_path(g:bujo_path, journal[0], collection)
        call add(l:content, "* [" . l:formatted_entry . "](" . l:entry_link . ")")
      endfor
      call add(l:content, "")
    endfor
    return l:content
endfunction

function! s:is_collection(journal, collection)  abort
	try
		let l:collections = readdir(s:format_path(expand(g:bujo_path), s:format_filename(a:journal)), {f -> f !~ '\(' . s:BUJO_DAILY . '\|' . s:BUJO_MONTHLY . '\|' . s:BUJO_FUTURE . '\|' . s:BUJO_BACKLOG. '\)'})
	catch
		return v:false
	endtry
	for entry in l:collections
		if s:format_filename(entry) ==# s:format_filename(a:collection . ".md")
			return v:true
		endif
	endfor
	return v:false
endfunction

function! s:set_current_journal(journal) abort
  let s:current_journal = s:format_filename(a:journal)
  " The screen gets stuck on 'Press Enter to continue' here
  " Force a redraw then show message in popup win to avoid
  " 'Enter to continue' prompts
  redraw!
  echon "Switched to journal: " . s:format_initial_case(a:journal)
  return
endfunction

function! s:interactive_journal_select(journal_list) abort
			" Select journal from list 
			let l:choices = []
			let l:choice_number = 0
			for journal in a:journal_list
        let l:choice_number += 1
        call add(l:choices, "&" . l:choice_number . s:get_formatted_journal(journal)) 
			endfor
      call add(l:choices, "&Quit") 

			let l:result = confirm("Select Journal", join(l:choices, "\n")) 
      if l:result == 0 
        return
      endif
      return s:set_current_journal(s:get_formatted_journal(a:journal_list[l:result - 1]))
endfunction

function! bujo#CurrentJournal() abort
  let l:prepend = len(g:bujo_journal_statusline_prepend) == 0 ? "": " " . g:bujo_journal_statusline_prepend
  let l:append = len(g:bujo_journal_statusline_append) == 0 ? "": " " . g:bujo_journal_statusline_append
  return l:prepend . s:format_from_path(s:current_journal) . l:append
endfunction

" function! s:open_or_replace_window(is_journal = v:false)
"   let l:current_winnr = winnr()
"   let l: = g:bujo_split_right ? "$" : "1"
" 
"   
"   exe l:current_winnr . "wincmd w"
" 
"   exe l:current_winnr . "wincmd w"
"   let l:winsize = l:is_journal ? g:bujo_index_winsize : g:bujo_daily_winsize
"   return (g:bujo_split_right ? "botright" : "topleft") . " vertical " . ((l:winsize > 0)? (l:winsize*winwidth(0))/100 : -l:winsize) "new" 
" endfunction
"
" Get and set current journal (offer to create if it doesn't exist)
function! bujo#Journal(print_current, ...) abort
	let l:journals = s:list_journals()
	if len(l:journals) == 0 
		call s:init_journal_index(s:current_journal)
    let l:journals = s:list_journals()
	endif
  if a:0 == 0 
		if a:print_current
			echon "Current Journal: " . s:get_formatted_journal(s:current_journal)
      return
		else
      return s:interactive_journal_select(l:journals)
		endif
  endif
	" Check if journal can be found
	" Support regex but needs to only find 1 match
	" Doesn't change s:current_journal on failure
  let l:matched_journals = matchstrlist(l:journals, s:format_filename(join(a:000, " ")))
  if len(l:matched_journals) == 1
    return s:set_current_journal(l:matched_journals[0]["text"])
  elseif len(l:matched_journals) > 1
    let l:matches = []
    for match in l:matched_journals
      call add(l:matches, match["text"])
    endfor
    return s:interactive_journal_select(l:matches)
  endif
  return s:interactive_journal_select()

endfunction

" Paramaters: openJournal: bool, vaargs - each argument is joined in a string
" to create the journal name
" Description: Open the index file for a journal or index file of journals
" Notes: Additional arguments are appended to the 'journal' argument with
" spaces between
function! bujo#OpenIndex(list_journals, ...) abort
  let l:journal = a:0 == 0 ? s:current_journal : join(a:000, " ")
  let l:journal_index = s:format_path(g:bujo_path,s:format_filename(l:journal), "/index.md")
  
  " Check to see if the journal exists
  if !a:list_journals
    if s:mkdir_if_needed(l:journal) | return | endif
  endif

  let l:cmd = (g:bujo_split_right ? "botright" : "topleft") . " vertical " . ((g:bujo_index_winsize > 0)? (g:bujo_index_winsize*winwidth(0))/100 : -g:bujo_index_winsize) . "new" 
  if a:list_journals
    execute l:cmd 
    setlocal filetype=markdown buftype=nofile noswapfile bufhidden=wipe
    let l:content = ["# Journal Index", ""]
    for entry in readdir(expand(g:bujo_path), {f -> isdirectory(expand(g:bujo_path . f)) && f !~ "^[.]"})
      call add(l:content, "- [" . s:format_initial_case(entry). "]( " . entry . "/index.md" . " )")
    endfor
    call append(0, l:content)
    setlocal readonly nomodifiable
  else
    call s:init_journal_index(l:journal)
    execute l:cmd 
    execute "edit " . fnameescape(l:journal_index)
  endif
endfunction

function! bujo#OpenDaily(...) abort
  let l:journal = a:0 == 0 ? s:current_journal : join(a:000, " ")
  let l:daily_log = s:format_path(g:bujo_path, s:format_filename(l:journal), s:format_filename(s:bujo_daily_filename))
  call s:init_daily(l:journal)
  execute (g:bujo_split_right ? "botright" : "topleft") . " vertical " . ((g:bujo_daily_winsize > 1)? (g:bujo_daily_winsize*winwidth(0))/100 : -g:bujo_daily_winsize) "new" 
  execute  "edit " . fnameescape(l:daily_log)
 
endfunction
" TODO - Handle displaying urgent tasks
function! bujo#CreateEntry(type, is_urgent, ...) abort
	if a:0 == 0 
		echoerr "CreateEntry requires at least 1 additional argument for the entry value."
		return
	endif
	let l:filename = s:format_filename(s:bujo_daily_filename)
	let l:entry = join(a:000, " ")

	" Note entries do not have a list character. 
	" To ensure we generate markdown that formats correctly insert
	" newline after entry
	let l:entry = l:entry

  let l:journal = s:current_journal
  let l:journal_dir = s:format_path(expand(g:bujo_path), l:journal)
  let l:daily_log = s:format_path(l:journal_dir, l:filename)

  call s:init_daily(l:journal)
  let l:content = readfile(l:daily_log)
  call writefile(s:list_append_entry(l:content, s:bujo_header_entries[a:type]["header"], s:bujo_header_entries[a:type]["list_char"], l:entry), l:daily_log)
endfunction

" bujo#This needs to handle for month selected (required)
" TODO - Argument passed should be year or nothing
" Year will open that year's monthly log 
" Option for month to take to that month of that log
function! bujo#OpenFuture(...) abort
  let l:journal_dir = s:format_path(g:bujo_path, s:current_journal)
  let l:future_log = l:journal_dir . "/" . s:format_filename(s:bujo_future_filename) 
  if s:mkdir_if_needed(s:current_journal) | return | endif

  if a:0 == 0
    let l:year = s:THIS_YEAR
  else
    let l:year = a:1 
    let l:future_log = s:format_path(g:bujo_path, s:current_journal, s:BUJO_FUTURE . "_" . l:year . ".md")
  endif
  if a:0 == 2
    let l:month = a:2
  else 
    if l:year == s:THIS_YEAR
      let l:month = s:THIS_MONTH
    else
      let l:month = "Jan"
    endif
  endif
  
  call s:init_future(l:year)

  execute (g:bujo_split_right ? "botright" : "topleft") . " vertical " . ((g:bujo_daily_winsize > 1)? (g:bujo_daily_winsize*winwidth(0))/100 : -g:bujo_daily_winsize) "new" 
  execute  "edit " . fnameescape(l:future_log)
  let l:content = readfile(l:future_log)
  let l:month_index = 0
  for line in l:content
    let l:month_index += 1
    if line =~? l:month
      break
    endif
  endfor
  " Set the month to be the top of the file
  call cursor(l:month_index, 0) 
  execute "normal z\<ENTER>"
endfunction

function! bujo#FutureEntry(type, providing_year, ...) abort
  " TODO - Ignore day, user can provide this if they choose as part of the entry
  " That way can have a general entry w/ no deadline (wont auto feed into daily log)
  if a:0 == 0
    echoerr "FutureEntry requires at least 1 additional argument"
  endif
  
  if a:providing_year 
    let l:year = a:1 
    let l:month = a:2
    let l:day = a:3
    let l:entry_start_index = 3 
  else 
    let l:year = strftime("%Y")
    let l:month = a:1
    let l:day = a:2
    let l:entry_start_index = 2 
  endif
  let l:date_suffix = s:date_suffixes[l:day[-1:-1]]
  let l:entry = l:day . l:date_suffix . ": " . s:format_title_case(join(a:000[l:entry_start_index:-1], " "))

  try
    let l:month = s:bujo_months[str2nr(expr)]["short"]
  catch
    if len(l:month) < 3 
      echoerr "Please provide at least the first 3 characters of the month when specifying name."
    endif
    let l:month = l:month[0:2]
  endtry
  
  call s:init_future(year)

  " Open that year's future log
  let l:future_log = s:format_path(g:bujo_path, s:current_journal, s:BUJO_FUTURE . "_" . l:year . ".md")
  let l:content = readfile(l:future_log)

  let l:search_for = substitute(substitute(g:bujo_future_month_header, "%B", l:month, "g"), "%b", l:month, "g")
  " Find the month provided 
  let l:index = 0
  for line in l:content
    if line =~? l:search_for
      break
    endif
    let l:index += 1
  endfor

  " Add entry under appropriate type header
  " TODO - Make this stop at the next month's header as may just run to EOF
  let l:list_char = s:bujo_header_entries[a:type]["list_char"]
  let l:list_char = l:list_char . (l:list_char == "" ? "" : " " )
  for line in l:content[l:index: -1]
    if line ==# s:bujo_header_entries[a:type]["header"]
      for item in l:content[l:index:-1]
        if item ==# l:list_char || item == ""
          if l:list_char ==# "" 
            call insert(l:content, "", l:index)
            let l:index += 1
          endif
          call insert(l:content, l:list_char . l:entry, l:index)
          break
        endif
        let l:index += 1
      endfor
      break
    endif
    let l:index += 1
  endfor

  call writefile(l:content, l:future_log)
endfunction

function! bujo#Collection(bang, ...) abort
  if a:0 == 0
    let l:collections = s:list_collections(a:bang)
    let l:content = s:format_list_collections(l:collections)
    execute (g:bujo_split_right ? "botright" : "topleft") . " vertical " . ((g:bujo_index_winsize > 0)? (g:bujo_index_winsize*winwidth(0))/100 : -g:bujo_index_winsize) . "new" 
    setlocal filetype=markdown buftype=nofile noswapfile bufhidden=wipe nowrap
    " for entry in readdir(expand(g:bujo_path), {f -> isdirectory(expand(g:bujo_path . f)) && f !~ "^[.]"})
    "   call add(l:content, "- [" . s:format_initial_case(entry). "]( " . entry . "/index.md" . " )")
    " endfor
    call append(0, l:content)
    setlocal readonly nomodifiable
    return
  endif


	let l:journal = s:current_journal
  let l:collection = join(a:000, " ")
  let l:collection_print_name = s:format_initial_case(l:collection)

  if s:mkdir_if_needed(l:journal) | return | endif

  let l:journal_dir = s:format_path(g:bujo_path, l:journal)
  let l:journal_index = s:format_path(l:journal_dir, "/index.md")
  let l:collection_index_link = s:format_filename(l:collection . ".md")
  let l:collection_path = s:format_path(l:journal_dir, l:collection_index_link)

  call s:init_journal_index(l:journal)
  if !s:is_collection(l:journal, l:collection) 
    " We are duplicating. 
    " Add the entry to index
    let l:content = readfile(l:journal_index)
    " Skip the first 2 lines, these will always be the index header and a new line
    let l:counter = 0
    for line in l:content[2:-1]
      let l:counter += 1
      let l:collection_header = ". [" . l:collection_print_name . "](" . l:collection_index_link . ")"
      if line !~# substitute(g:bujo_index_list_char, "{#}", l:counter . ". ", "g") 
        call insert(l:content, substitute(g:bujo_index_list_char, "{#}", l:counter, "g") . l:collection_header, l:counter + 2)
        break
      " Account for the case where we are at EOF and no empty newline
      elseif line ==# l:content[0] || len(l:content) == l:counter + 2
        call add(l:content, substitute(g:bujo_index_list_char, "{#}", l:counter + 1, "g") . l:collection_header)
      endif
    endfor
    call writefile(l:content, l:journal_index)
	endif

  let l:content = [ "# " . l:collection_print_name, "", "" ]
  call writefile(l:content, l:collection_path)

  execute (g:bujo_split_right ? "botright" : "topleft") . " vertical " . ((g:bujo_daily_winsize > 1)? (g:bujo_daily_winsize*winwidth(0))/100 : -g:bujo_daily_winsize) "new" 
  execute  "edit " . fnameescape(l:collection_path)

endfunction

function! bujo#OpenBacklog(...) abort
  let l:journal_dir = s:format_path(g:bujo_path, s:current_journal)
  let l:backlog = l:journal_dir . "/" . s:format_filename(s:bujo_backlog_filename)
  if s:mkdir_if_needed(s:current_journal) | return | endif
  if !filereadable(l:backlog)
    let l:content = []
    call add(l:content, s:format_header(g:bujo_backlog_header, s:current_journal))
    call add(l:content, "")
    for key in g:bujo_header_entries_ordered
      if s:bujo_header_entries[key]["backlog_enabled"]
        call add(l:content, s:bujo_header_entries[key]["header"])
        call add(l:content, s:bujo_header_entries[key]["list_char"] . " ")
        call add(l:content, "")
      endif
    endfor
    call add(l:content, "")
    call writefile(l:content, l:backlog)
  endif
  " Check if we need to create an entry
  " We do this before opening the split as we may want to do both
  if a:0 == 0
    execute (g:bujo_split_right ? "botright" : "topleft") . " vertical " . ((g:bujo_daily_winsize > 1)? (g:bujo_daily_winsize*winwidth(0))/100 : -g:bujo_daily_winsize) "new" 
    execute  "edit " . fnameescape(l:backlog)
  else
    let l:entry = substitute(join(a:000, " "), "\\(^[a-z]\\)", "\\U\\1", "g")
    let l:content = readfile(l:backlog)
    call writefile(s:list_append_entry(l:content, s:bujo_header_entries[s:BUJO_TASK]["header"], s:bujo_header_entries[s:BUJO_TASK]["list_char"],  l:entry), l:backlog)
  endif
endfunction

function! s:init_monthly(month) abort
  let l:journal_dir = s:format_path(g:bujo_path, s:current_journal)
  let l:monthly_log = s:format_path(g:bujo_path, s:current_journal, s:BUJO_MONTHLY . "_" . s:THIS_YEAR . "_" . a:month . ".md")
  if filereadable(l:monthly_log)
    return
  endif
  let l:content = [ s:format_header(g:bujo_monthly_header), "" ]
  for header in g:bujo_header_entries_ordered
    if s:bujo_header_entries[header]["monthly_enabled"]
      call add(l:content, s:format_header(s:bujo_header_entries[header]["header"]))
      call add(l:content, s:bujo_header_entries[header]["list_char"] . " ")
      call add(l:content, "")
    endif
  endfor
  if g:bujo_monthly_table_enabled 
    let l:day_header = "Day "
    let l:empty_checkbox = "[ ]"
    let l:table_horizontal_border = "|" . repeat("-",len(l:day_header) + 1)
    let l:row = "| " . l:day_header
    for header in g:bujo_monthly_table_headers_ordered
      let l:table_horizontal_border .= "-+" . repeat("-", len(s:format_header(g:bujo_monthly_table_headers[header]["display"])) + 1)
      let l:row .= " | " . s:format_header(g:bujo_monthly_table_headers[header]["display"])
    endfor
    let l:table_horizontal_border .= "-|"
    let l:row .= " |"
    call add(l:content, l:table_horizontal_border)
    call add(l:content, l:row)
    if g:bujo_monthly_table_align
      let l:row = "| :" . repeat("-", len(l:day_header) - 1) . " |"
      for header in g:bujo_monthly_table_headers_ordered
        let l:row .= " :" . repeat("-", len(g:bujo_monthly_table_headers[header]["display"]) - 2) . ": |"
      endfor
      call add(l:content, l:row)
    endif
    for day in range(2, s:bujo_months[strftime("%m") - 1]["days"])
      let l:row = "| " . day . "." . repeat(" ", len(l:day_header) - (day / 10 < 1 ? 2: 3)) . " |"
      for header in g:bujo_monthly_table_headers_ordered
        let l:padding = ((len(g:bujo_monthly_table_headers[header]["display"]) + 2) / 2) - (len(l:empty_checkbox) / 2)
        let l:rounding_padding = (len(g:bujo_monthly_table_headers[header]["display"]) + 2) - ((l:padding * 2) + len(l:empty_checkbox))
        let l:row .= repeat(" ", l:padding) . l:empty_checkbox . repeat(" ", l:padding + l:rounding_padding) . "|"
      endfor
      call add(l:content, l:row)
    endfor
    call add(l:content, l:table_horizontal_border)
    call add(l:content, "")
  endif
  call writefile(l:content, l:monthly_log)

endfunction

" TODO - When initialising monthly should pull any info from future log for this year and month
" TODO (In future) - When opening do a diff to pull any missing entries over from future log
function! bujo#OpenMonthly(...) abort
  if a:0 > 0  
    let l:month = a:1
  else
    let l:month = s:THIS_MONTH
  endif

  let l:monthly_log = s:format_path(g:bujo_path, s:current_journal, s:BUJO_MONTHLY . "_" . s:THIS_YEAR . "_" . l:month . ".md")

  if s:mkdir_if_needed(s:current_journal) | return | endif
  call s:init_monthly(l:month)

  execute (g:bujo_split_right ? "botright" : "topleft") . " vertical " . ((g:bujo_daily_winsize > 1)? (g:bujo_daily_winsize*winwidth(0))/100 : -g:bujo_daily_winsize) "new" 
  execute  "edit " . fnameescape(l:monthly_log)
endfunction

function! bujo#MonthlyEntry(type, ...) abort
  " FIXME - Notes add a lot of extra space around them
  let l:month = s:THIS_MONTH
  let l:monthly_log = s:format_path(g:bujo_path, s:current_journal, s:BUJO_MONTHLY . "_" . s:THIS_YEAR . "_" . l:month . ".md")
  if s:mkdir_if_needed(s:current_journal) | return | endif
  call s:init_monthly(l:month)
  let l:entry = substitute(join(a:000[1:-1], " "), "\\(^[a-z]\\)", "\\U\\1", "")
  let l:content = readfile(l:monthly_log)
  call writefile(s:list_append_entry(l:content, s:bujo_header_entries[a:type]["header"], s:bujo_header_entries[a:type]["list_char"], l:entry), l:monthly_log)
endfunction

" Global wrappers made so Vader can run unit tests
function! bujo#Vader_FormatFilename(filename) abort
  return s:format_filename(a:filename)
endfunction

function! bujo#Vader_FormatHeader(header, journal = s:current_journal)  abort
  call s:format_header(a:header, a:journal) 
endfunction

function! bujo#Vader_MkdirIfNeeded(journal = g:bujo_default_journal) abort
  return s:mkdir_if_needed(a:journal)
endfunction

function! bujo#Vader_ListInsertEntry(list, type_header, type_list_char, entry, stop_pattern = v:null) abort
  return s:list_insert_entry(a:list, a:type_header, a:type_list_char, a:entry, a:stop_pattern)
endfunction

function! bujo#Vader_ListAppendEntry(list, type_header, type_list_char, entry)  abort
  return s:list_append_entry(a:list, a:type_header, a:type_list_char, a:entry) 
endfunction

function! bujo#Vader_GetJournalPath(journal = g:bujo_default_journal) abort
  return s:format_path(expand(g:bujo_path), s:format_filename(a:journal))
endfunction

function! bujo#Vader_IsCollection(journal, collection)  abort
	return s:is_collection(a:journal, a:collection)
endfunction

function! bujo#GetInternalVariable(var) abort
  return get(s:, a:var, "Failed to find " . a:var . " in s:")
endfunction
