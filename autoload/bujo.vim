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

if !exists('g:bujo_path')
	let g:bujo_path = '~/bujo/'
endif
if !exists('g:bujo_default_journal')
  let g:bujo_default_journal = "Default"
endif
if !exists('g:bujo_split_right')
  let g:bujo_split_right = &splitright
endif
if !exists('g:bujo_auto_reflection')
  let g:bujo_auto_reflection = v:true
endif
if !exists('g:bujo_daily_skip_weekend')
  let g:bujo_daily_skip_weekend = v:false
endif

" Daily Log vars
let s:bujo_daily_filename = s:BUJO_DAILY . "_%Y-%m-%d.md"
if !exists('g:bujo_winsize')
	let g:bujo_winsize = 50
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
\ s:BUJO_EVENT : {
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
\   "list_char": "*",
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
let s:bujo_future_month_header =  "# %B" 

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

if !exists('g:bujo_define_default_monthly_table_headers')
  let g:bujo_define_default_monthly_table_headers = v:true
endif

if !exists('g:bujo_monthly_table_headers') && g:bujo_define_default_monthly_table_headers
  let g:bujo_monthly_table_headers = [ 
  \ {
  \		"title":"Gratitude",
  \		"cron":"* * * *"
  \ },
  \ {
  \		"title":"Meditation",
  \		"cron":"* * * *"
  \ },
  \ {
  \		"title":"Reading",
  \		"cron":"1,3,4,5-9 * * *"
  \ }
  \ ]
endif

" Backlog vars
let s:bujo_backlog_filename = "backlog.md"
if !exists('g:bujo_backlog_header')
	let g:bujo_backlog_header =  "# {journal} Backlog" 
endif


" Index vars
let s:bujo_index_header = "# {journal} Index"
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

if !exists('g:bujo_week_start') || g:bujo_week_start < 0 || g:bujo_week_start > 7
  let g:bujo_week_start = 1 
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

let s:bujo_days = { 
\ 0: { "letter": "S", "short": "Sun", "long": "Sunday"},
\ 1: { "letter": "M", "short": "Mon", "long": "Monday"},
\ 2: { "letter": "T", "short": "Tue", "long": "Tuesday"},
\ 3: { "letter": "W", "short": "Wed", "long": "Wednesday"},
\ 4: { "letter": "T", "short": "Thu", "long": "Thursday"},
\ 5: { "letter": "F", "short": "Fri", "long": "Friday"},
\ 6: { "letter": "S", "short": "Sat", "long": "Saturday"},
\ }

let s:bujo_months = [
  \ { "short": "Jan", "long": "January", "days": 31, "code": 0 },
  \ { "short": "Feb", "long": "February", "days": 28, "code": 3 },
  \ { "short": "Mar", "long": "March", "days": 31, "code": 3 },
  \ { "short": "Apr", "long": "April", "days": 30, "code": 6 },
  \ { "short": "May", "long": "May", "days": 31, "code": 1 },
  \ { "short": "Jun", "long": "June", "days": 30, "code": 4 },
  \ { "short": "Jul", "long": "July", "days": 31, "code": 6 },
  \ { "short": "Aug", "long": "August", "days": 31, "code": 2 },
  \ { "short": "Sep", "long": "September", "days": 30, "code": 5 },
  \ { "short": "Oct", "long": "October", "days": 31, "code": 0 },
  \ { "short": "Nov", "long": "November", "days": 30, "code": 3 },
  \ { "short": "Dec", "long": "December", "days": 31, "code": 5 },
\ ]
" i.e. let g:bujo_migrated_to_future = '<' -- Migrated to future log
"      > = Migrated to next week look
" etc

if !exists('g:bujo_vader_testing')
  let g:bujo_vader_testing = v:false
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

function! s:format_date_with_suffix(date) abort
  if a:date >= 10 && a:date <= 20
    return a:date . "th"
  endif
  return a:date . s:date_suffixes[a:date[-1:-1]]
endfunction

function! s:format_filename(filename)  abort
  return tolower(
      \ substitute(
        \ substitute(strftime(s:strip_whitespace(a:filename)), " ", "_", "g"), 
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

function! s:format_header_custom_date(format, year, month, day) abort
  let l:dow = s:get_week_day(a:year,a:month,a:day)
  return substitute(
         \ substitute(
           \ substitute(
             \ substitute(
               \ substitute(
                 \ substitute(
                   \ substitute(
                     \ substitute(
                       \ substitute(a:format, "{journal}", s:format_initial_case(s:current_journal), "g"), 
                       \ "%Y", a:year, "g"),
                     \ "%m", a:month, "g"),
                   \ "%d", a:day, "g"),
                 \ "%B", s:bujo_months[a:month - 1]["long"], "g"),
               \ "%b", s:bujo_months[a:month - 1]["short"], "g"),
             \ "%A", s:bujo_days[l:dow]["long"], "g"),
           \ "%a", s:bujo_days[l:dow]["short"], "g"),
         \ "%w", s:get_week_of_month(a:year,a:month,a:day), "g")
endfunction

function! s:format_path(...) abort
	if a:0 == 0 
		echoerr "format_path requires at least 2 arguments"
	endif
	let l:path = a:000[0]
	for step in a:000[1:-1]
    let l:item = step
    " Trim any leading slashes
    if l:item[0:0] == "/" || l:item[0:0] == "\\"
      let l:item = l:item[1:-1]
    endif
    if l:path[-1:-1] == "/" || l:path[-1:-1] == "\\"
      let l:path .= l:item
    else 
      let l:path .= "/" . l:item
    endif
	endfor
	return expand(l:path)
endfunction

function! s:format_from_path(journal, collection = "index.md") abort
  return substitute(readfile(s:format_path(g:bujo_path, a:journal, a:collection), "", 1)[0][2:-1], "index", "", "g")
endfunction

function! s:list_journals() abort
	return readdir(expand(g:bujo_path), {f -> isdirectory(expand(g:bujo_path . f)) && f !~ "^[.]"})
endfunction

" mkdir_if_needed
" Returns true if user cancelled, false if already exists/created directory
" TODO - See if we can remove the bool return from here and rely on abort...
function! s:mkdir_if_needed(journal) abort
  let l:journal_dir = s:format_path(g:bujo_path, s:format_filename(a:journal))
  if isdirectory(l:journal_dir) | return v:false | endif

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
  let l:journal_index = s:format_path(g:bujo_path, s:format_filename(a:journal), "/index.md")
  " We have already initialised index 
  if filereadable(l:journal_index) | return | endif

  let l:content = [s:format_header(s:bujo_index_header, a:journal), ""]
  let l:counter = 0
  for key in s:bujo_index_entries
    let l:counter += 1
    call add(l:content, l:counter . "." . " [" . key["name"] . "](" . key["file"] . ")")
  endfor
  call writefile(l:content, l:journal_index)
endfunction

function! s:get_monthly_log_entries(year, month)
  let l:monthly_log = s:format_path(g:bujo_path, s:current_journal, s:format_header_custom_date(s:bujo_monthly_filename, a:year, a:month, 1))
  if !filereadable(l:monthly_log) | call s:init_monthly(s:get_current_month()) | endif
  let l:monthly_content = readfile(l:monthly_log)
  let l:entries = {}
  let l:prev_start = -1
  for i in range(len(g:bujo_header_entries_ordered))
    let l:key = g:bujo_header_entries_ordered[i]
    let l:start = matchstrlist(l:monthly_content, escape(s:bujo_header_entries[l:key]["header"], "*"))[0]["idx"] + 1
    let l:end = i + 1 == len(g:bujo_header_entries_ordered) ? -1 : matchstrlist(l:monthly_content, escape(s:bujo_header_entries[g:bujo_header_entries_ordered[i + 1]]["header"], "*"))[0]["idx"] - 1
    let l:entries[l:key] = l:monthly_content[l:start: l:end]
  endfor
  return l:entries
endfunction

function! s:get_entries_from_block(block, date) abort
  let l:entries = {}
  for key in g:bujo_header_entries_ordered
    let l:entry_block = a:block[key]
    let l:entries[key] = []
    let l:matches = matchstrlist(l:entry_block, s:format_date_with_suffix(a:date))
    for entry in l:matches
      call add(l:entries[key], substitute(l:entry_block[entry["idx"]], s:format_date_with_suffix(a:date) . ": ", "", ""))
    endfor
  endfor
  return l:entries
endfunction

function! s:generate_daily_content(year,month,day) abort
  let l:monthly_entries = s:get_monthly_log_entries(a:year, a:month)
  let l:day_header = s:format_header_custom_date(s:bujo_daily_header, a:year, a:month, a:day)
  let l:content = [l:day_header, ""]
  let l:entries = s:get_entries_from_block(l:monthly_entries, a:day)
  for key in g:bujo_header_entries_ordered
    call add(l:content, s:bujo_header_entries[key]["header"])
    call extend(l:content, l:entries[key])
    call add(l:content, "")
  endfor
  return l:content
endfunction

" TODO - Option to disable weekends
function! s:init_daily() abort
  let l:formatted_daily_header = s:format_header(s:bujo_daily_header, s:current_journal)
  let l:daily_log = s:format_path(g:bujo_path, s:current_journal, s:format_header_custom_date(s:bujo_daily_filename, s:get_current_year(), s:get_current_month(), s:get_current_day())) 

  if s:mkdir_if_needed(s:current_journal) | return | endif
  if filereadable(l:daily_log) | return | endif

  let l:content = s:generate_daily_content(s:get_current_year(), s:get_current_month(), s:get_current_day())
  " Write output to file
  call writefile(l:content, l:daily_log)
  call bujo#Outstanding()
  execute "wincmd w"
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
  if s:get_current_year() == a:year 
    " Skip the months that have already passed
    let l:months = s:bujo_months[strftime("%m") - 1:-1]
  else 
    let l:months = s:bujo_months
  endif 
  for month in l:months
    " TODO - This **will** break between systems. Will need to add a conditional to decide what to go with when we encounter it
    call add(l:content, substitute(substitute(s:bujo_future_month_header, "%B", month["long"], "g"), "%b", month["short"], "g"))
    call add(l:content, "")
    for key in g:bujo_header_entries_ordered
      if s:bujo_header_entries[key]["future_enabled"]
        call add(l:content, s:bujo_header_entries[key]["header"])
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
  let l:list_char = a:type_list_char . " " 
  for line in a:list
    if a:stop_pattern isnot v:null && line ==# a:stop_pattern | return | endif
    if line ==# a:type_header
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
  let l:list_char = a:type_list_char . " " 
  for line in a:list
    if line ==# a:type_header
      for item in a:list[l:index:-1]
        if item !~# '^\s*' . escape(l:list_char[0], '*\/+') || (l:index + 1 == len(a:list))
          call insert(a:list, l:list_char . a:entry, l:index)
          return a:list
        endif
        let l:index += 1
      endfor
      
      " Edge case at EOF
      if l:index == len(a:list)
        call insert(a:list, l:list_char . a:entry, l:index)
        return a:list
      endif

      " We shouldn't get to here
      echoerr "How did we end up here then?"
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
  call insert(a:list, l:list_char . a:entry, l:line)
  let l:line += 1
  call insert(a:list, l:list_char, l:line)
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

function! s:formatted_daily_header(day, date) abort
  return s:format_date_str(s:bujo_daily_header, s:get_current_year(), s:get_current_month(), a:date)
  let l:formatted_daily_header = s:format_header(s:bujo_daily_header, a:journal) 
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
      if l:result == 0 || l:result == len(l:choices)
        echon "User cancelled journal selection. Journal unchanged."
        return
      endif
      return s:set_current_journal(s:get_formatted_journal(a:journal_list[l:result - 1]))
endfunction

function! s:process_cron_interval(interval) abort
  let l:arr = []
  let l:intervals = split(a:interval, ",")
  for interval in l:intervals
    if match(interval, "-") != -1
      let l:split = split(interval, "-")
      let l:lhs = l:split[0]
      let l:rhs = l:split[1]
      for range_interval in range(l:lhs, l:rhs)
        call add(l:arr, range_interval)
      endfor
    else
      if str2nr(interval) != 0
        call add(l:arr, str2nr(interval))
      else
        call add(l:arr, interval)
      endif
    endif
  endfor
  return l:arr
endfunction

function! s:process_cron(expr, year, month, day, dow) abort
  " TODO - This doesn't handle division styling
  " i.e. */2 for every other day 
  " need to reread up on cron again before doing any more tho
  " Day Month Year DayOfWeek
  let l:expr_list = split(a:expr, " ")
  if len(l:expr_list) < 4 
    call (extend(l:expr_list, repeat(["*"], 4 - len(l:expr_list))))
  endif
  let l:days   = s:process_cron_interval(l:expr_list[0])
  let l:months = s:process_cron_interval(l:expr_list[1])
  let l:years  = s:process_cron_interval(l:expr_list[2])
  let l:dows   = s:process_cron_interval(l:expr_list[3])
  if index(l:years, "*") >= 0 || index(l:years, a:year) >= 0
    if index(l:months, "*") >= 0 ||  index(l:months, a:month) >= 0
      if index(l:days, "*") >= 0 ||  index(l:days, a:day) >= 0
        if index(l:dows, "*") >= 0 || index(l:dows, a:dow) >= 0
          return v:true
        endif
      endif
    endif
  endif
  return v:false
endfunction

function! s:get_current_year() abort
  return strftime("%Y")
endfunction

function! s:get_current_month() abort
  return strftime("%m")
endfunction

function! s:get_current_day() abort
  return strftime("%d")
endfunction

function! s:is_leap_year(year) abort
  return a:year % 400 == 0 || (a:year % 100 != 0 && a:year % 4 == 0)
endfunction

" 0 = Sunday
" 1 = Monday
" 2 = Tuesday
" 3 = Wednesday
" 4 = Thursday
" 5 = Friday
" 6 = Saturday
function! s:get_week_day(year, month, day) abort
  " TODO - Ability to shift these aroud according to what day of the week you
  " want to start on
  let l:century_codes = {17: 4, 18: 2, 19: 0, 20: 6, 21: 4, 22: 2, 23:0}
  let l:year_code = (a:year[2:-1] + (a:year[-2:-1] / 4)) % 7
  let l:month_code = s:bujo_months[a:month - 1]["code"]
  let l:leap = s:is_leap_year(a:year) && (a:month == 0 || a:month == 1) ? 1: 0 
  return (l:year_code + l:month_code + l:century_codes[a:year[0:1]] + a:day - l:leap) % 7
endfunction

function! s:get_week_of_month(year,month,day) abort
  let l:first_day_of_month = s:get_week_day(a:year,a:month,1)
  let l:first_week_start_of_month = g:bujo_week_start >= l:first_day_of_month ? g:bujo_week_start - l:first_day_of_month : (7 % l:first_day_of_month) + g:bujo_week_start
  if l:first_week_start_of_month < a:day
    return ((a:day - l:first_week_start_of_month) / 7) + 1
  else 
    let l:month_days = s:is_leap_year(a:year) && a:month == 2 ? 29 : s:bujo_months[a:month-1]["days"]
    return s:get_week_of_month(a:year,a:month -1, a:day + l:month_days)
  endif
endfunction



function! s:format_date_str(in, year, month, day) abort
  let l:month = a:month < 10 ? "0" . str2nr(a:month) : a:month
  let l:day = a:day < 10 ? "0" . str2nr(a:day) : a:day
  let l:week_of_month = s:get_week_of_month(a:year,a:month,a:day)
  return substitute(
        \ substitute(
          \ substitute(
            \ substitute(a:in, "%d", l:day, "g"),
            \ "%w", l:week_of_month, "g"),
          \ "%m", l:month, "g"),
        \ "%Y", a:year, "g")
endfunction

" TODO #4
function! s:fix_index_collection_links(journal) abort
endfunction

function! bujo#Head() abort
  let l:prepend = len(g:bujo_journal_statusline_prepend) == 0 ? "": " " . g:bujo_journal_statusline_prepend
  let l:append = len(g:bujo_journal_statusline_append) == 0 ? "": " " . g:bujo_journal_statusline_append     
  return l:prepend . s:format_title_case(s:current_journal) . l:append           
endfunction

" Get and set current journal (offer to create if it doesn't exist)
function! bujo#Journal(print_current, ...) abort
  let l:journal_name = s:format_title_case(join(a:000, " "))
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
  let l:matched_journals = matchstrlist(l:journals, l:journal_name)
  if len(l:matched_journals) == 0 
    if s:mkdir_if_needed(l:journal_name) | return | endif
    return s:set_current_journal(l:journal_name)
  elseif len(l:matched_journals) == 1
    return s:set_current_journal(l:matched_journals[0]["text"])
  elseif len(l:matched_journals) > 1
    let l:matches = []
    for match in l:matched_journals
      call add(l:matches, l:journals[match["idx"]])
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
function! bujo#Index(list_journals, ...) abort
  let l:journal = a:0 == 0 ? s:current_journal : join(a:000, " ")
  let l:journal_index = s:format_path(g:bujo_path,s:format_filename(l:journal), "/index.md")
  
  " Check to see if the journal exists
  if !a:list_journals
    if s:mkdir_if_needed(l:journal) | return | endif
  endif

  if a:list_journals
    execute "edit " . fnameescape(s:format_path("bujo://", expand(g:bujo_path), "index.md"))
    setlocal filetype=markdown buftype=nofile noswapfile bufhidden=wipe
    let l:content = ["# Journal Index", ""]
    for entry in readdir(expand(g:bujo_path), {f -> isdirectory(expand(g:bujo_path . f)) && f !~ "^[.]"})
      call add(l:content, "- [" . s:format_initial_case(entry). "]( " . entry . "/index.md" . " )")
    endfor
    call append(0, l:content)
    setlocal readonly nomodifiable
  else
    call s:init_journal_index(l:journal)
    call s:fix_index_collection_links(l:journal)
    execute "edit " . fnameescape(l:journal_index)
  endif
endfunction

" TODO - Support migration
" On initialising each week, get the last daily journal file (need to
" support going on holiday for 2 weeks and coming back, should show last
" daily log not not find the last weeks one)
" This needs to (based on user choice v/h) split  showing past file and new
" file, focus the old file, motions in this file migrate tasks accordingly
" IMPORTANT: Only needs to show unfinished tasks
" Motions: 
"   getting it working: 
"     `>>` move to new daily log
"     `<<` prompt user for month and move to future log
"     `tbd` move to backlog
"   getting it working: 
"     `>>` prompt for day (default to today) and put under that daily header
"          in new daily log
"     `<<` ability to specify year (will be needed when close to year end
"          i.e. December) and need to put things in for new year
"     `tbd` move to custom collection?

function! s:outstanding_sort(a, b) abort
  let l:a_date = split(match(a:a, '[0-9]\{4}-[0-9]{1,2}-[0-9]{1,2}'), "-")
  let l:b_date = split(match(a:b, '[0-9]\{4}-[0-9]{1,2}-[0-9]{1,2}'), "-")
  let l:year = 0
  let l:month = 1
  let l:day = 2
  if l:a_date[l:year] > l:b_date[l:year] && l:a_date[l:month] > l:b_date[l:month] && l:a_date[l:day] > l:b_date[l:day] 
    return -1
  endif
  return 1
endfunction

function! bujo#Outstanding() abort
  let l:files = sort(readdir(s:format_path(g:bujo_path, s:current_journal), {f -> f =~ "daily.*[.]md$"}), "s:outstanding_sort")
  call extend(l:files, readdir(s:format_path(g:bujo_path, s:current_journal), {f -> f =~ "[.]md$" && f !~ "backlog" && f !~ "daily.*[.]md$"}))
  let l:outstanding_buffer = []
  for file in l:files
    let l:file_content = readfile(s:format_path(g:bujo_path, s:current_journal, file))
    let l:open_tasks = matchstrlist(l:file_content, '- \[ \] ..*')
    if len(l:open_tasks) == 0 | continue | endif

    let l:formatted_file_name = s:format_from_path(s:current_journal, file)

    let l:content = []
    call add(l:content, "**" . l:formatted_file_name . ":**")
    for entry in l:open_tasks
      call add(l:content, entry["text"])
    endfor
    call add(l:content, "")
    if len(l:content) > 2
      call extend(l:outstanding_buffer, l:content)
    endif
  endfor
  " Don't bother opening anything if we haven't foud any open tasks
  if len(l:outstanding_buffer) == 0 | return | endif

  execute "belowright split " . fnameescape(s:format_path("bujo://", expand(g:bujo_path), s:current_journal, "outstanding.md"))
  setlocal filetype=markdown buftype=nofile noswapfile bufhidden=wipe
  call append(0, l:outstanding_buffer)
  call cursor(1, 0) 
endfunction

function! bujo#Today() abort
  let l:daily_log = s:format_path(g:bujo_path, s:current_journal, s:format_date_str(s:bujo_daily_filename, s:get_current_year(), s:get_current_month(), s:get_current_day()))
  " We're initialising this weeks daily log, do we have auto reflection
  " enabled?
  let l:log_exists = filereadable(l:daily_log)
  " if !l:log_exists && g:bujo_auto_reflection
  "   return bujo#Migration()
  " endif

  call s:init_daily()

  execute "edit " . fnameescape(l:daily_log)
endfunction


function! s:date_add_days(year,month,day,add) abort
  let l:year = a:year
  let l:month = a:month
  let l:day = a:day + a:add

  let l:is_leap = s:is_leap_year(l:year)
  let l:days_in_month = l:month == 2 && l:is_leap ? 29 : s:bujo_months[l:month-1]["days"]

  while l:day > l:days_in_month
    let l:day -= l:days_in_month
    let l:month += 1
    let l:days_in_month = l:month == 2 && l:is_leap ? 29 : s:bujo_months[l:month-1]["days"]
    if l:month > 12
      let l:year += 1
      let l:month -= 12
      let l:is_leap = s:is_leap_year(l:year)
    endif
  endwhile
  " If we're passed a negative value
  if l:day < 0 
    let l:day = l:day * -1
    let l:month -= 1
    let l:days_in_month = l:month == 2 && l:is_leap ? 29 : s:bujo_months[l:month-1]["days"]
    while l:day > l:days_in_month
      let l:day -= l:days_in_month
      let l:month -= 1
      let l:days_in_month = l:month == 2 && l:is_leap ? 29 : s:bujo_months[l:month-1]["days"]
      if l:month < 1
        let l:year -= 1
        let l:month += 12
        let l:is_leap = s:is_leap_year(l:year)
      endif
    endwhile
    let l:day = l:days_in_month - l:day
  endif
  return [l:year, l:month, l:day]
endfunction
  
function! bujo#TestAddDays(year,month,day, add) abort
  return s:date_add_days(a:year,a:month,a:day,a:add)
endfunction

function! bujo#Tomorrow() abort
  let l:date = s:date_add_days(s:get_current_year(), s:get_current_month(), s:get_current_day(), 1)
  let l:day = date[2]
  let l:filename = s:format_path(g:bujo_path, s:current_journal, s:format_date_str(s:bujo_daily_filename, l:date[0], l:date[1], l:date[2]))

  let l:content = s:generate_daily_content(date[0], date[1], date[2])
  execute "edit " . fnameescape(l:filename)
  setlocal filetype=markdown noswapfile bufhidden=wipe
  call append(0, l:content)
  call cursor(1, 0) 
endfunction

function! bujo#Yesterday() abort
  let l:todays_daily = s:format_date_str(s:bujo_daily_filename, s:get_current_year(), s:get_current_month(), s:get_current_day())
  try
    let l:filename = sort(readdir(s:format_path(g:bujo_path, s:current_journal), {f -> f =~ "daily.*[.]md$" && f !~ l:todays_daily}), "s:outstanding_sort")[0]
    let l:filepath = s:format_path(g:bujo_path, s:current_journal, l:filename)
    execute "edit " . fnameescape(l:filepath)
  catch
    let l:date = s:date_add_days(s:get_current_year(), s:get_current_month(), s:get_current_day(), -1)
    let l:day = date[2]
    let l:filename = s:format_path(g:bujo_path, s:current_journal, s:format_date_str(s:bujo_daily_filename, l:date[0], l:date[1], l:date[2]))
    let l:content = s:generate_daily_content(l:date[0], l:date[1], l:date[2])
    call writefile(l:content, l:filename)
    execute "edit " . fnameescape(l:filename)
  endtry
endfunction

function! s:get_days_since_week_start(year,month,day) abort
  let l:dow = s:get_week_day(a:year, a:month, a:day)
  return l:dow - g:bujo_week_start
endfunction

function! s:preview_week(year,month,day) abort
  let l:week_start = s:date_add_days(a:year, a:month, a:day, -s:get_days_since_week_start(a:year,a:month,a:day))
  let l:content = []
  for day in range(6) 
    if day > 0 | call add(l:content, "---") | endif
    let l:current_date = s:date_add_days(l:week_start[0], l:week_start[1], l:week_start[2], day)
    let l:filename = s:format_path(g:bujo_path, s:current_journal, s:format_date_str(s:bujo_daily_filename, l:current_date[0], l:current_date[1], l:current_date[2]))
    if filereadable(l:filename)
      call extend(l:content, readfile(l:filename))
    else
      call extend(l:content, s:generate_daily_content(l:current_date[0], l:current_date[1], l:current_date[2]))
    endif
  endfor
  return l:content
endfunction

function! bujo#ThisWeek() abort
  let l:content = s:preview_week(s:get_current_year(), s:get_current_month(), s:get_current_day())
  execute "edit " . fnameescape(s:format_path("bujo://", expand(g:bujo_path), s:current_journal, "this_week.md"))
  setlocal filetype=markdown buftype=nofile noswapfile bufhidden=wipe
  call append(0, l:content)
  call cursor(1, 0) 
endfunction

function! bujo#NextWeek() abort
  let l:date = s:date_add_days(s:get_current_year(), s:get_current_month(), s:get_current_day(), 7)
  let l:content = s:preview_week(l:date[0], l:date[1], l:date[2])
  execute "edit " . fnameescape(s:format_path("bujo://", expand(g:bujo_path), s:current_journal, "next_week.md"))
  setlocal filetype=markdown buftype=nofile noswapfile bufhidden=wipe
  call append(0, l:content)
  call cursor(1, 0) 
endfunction

function! bujo#LastWeek() abort
  let l:date = s:date_add_days(s:get_current_year(), s:get_current_month(), s:get_current_day(), -7)
  let l:content = s:preview_week(l:date[0], l:date[1], l:date[2])
  execute "edit " . fnameescape(s:format_path("bujo://", expand(g:bujo_path), s:current_journal, "last_week.md"))
  setlocal filetype=markdown buftype=nofile noswapfile bufhidden=wipe
  call append(0, l:content)
  call cursor(1, 0) 

endfunction

" TODO - Handle displaying urgent tasks
function! bujo#CreateEntry(type, is_urgent, ...) abort
	if a:0 == 0 
		echoerr "CreateEntry requires at least 1 additional argument for the entry value."
		return
	endif
	let l:entry = s:format_title_case(join(a:000, " "))

	" Note entries do not have a list character. 
	" To ensure we generate markdown that formats correctly insert
	" newline after entry
	let l:entry = l:entry

  let l:journal = s:current_journal
  let l:daily_log = s:format_path(g:bujo_path, l:journal, s:format_date_str(s:bujo_daily_filename, s:get_current_year(), s:get_current_month(), s:get_current_day()))

  call s:init_daily()
  let l:content = readfile(l:daily_log)
  call writefile(s:list_append_entry(l:content, s:bujo_header_entries[a:type]["header"], s:bujo_header_entries[a:type]["list_char"], l:entry), l:daily_log)
endfunction

function! bujo#Future(...) abort
  let l:future_log = s:format_path(g:bujo_path, s:current_journal, s:format_filename(s:bujo_future_filename)) 

  if a:0 == 0
    let l:year = s:get_current_year()
  else
    let l:year = a:1 
  endif
  let l:future_log = s:format_path(g:bujo_path, s:current_journal, s:format_header_custom_date(s:bujo_future_filename, l:year, 1, 1))

  if s:mkdir_if_needed(s:current_journal) | return | endif
  
  call s:init_future(l:year)

  execute "edit " . fnameescape(l:future_log)
  let l:content = readfile(l:future_log)
  let l:row = matchstrlist(l:content, s:format_header_custom_date(s:bujo_future_month_header, l:year, s:get_current_month(), 1))
  " Set the month to be the top of the file
  " + 1 as index starts at 0 + configured scrolloff distance to put the header
  " at the top of the buffer
  call cursor(l:row[0]["idx"] + 1 + &scrolloff, 0) 
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
  let l:entry = s:format_date_with_suffix(l:day) . ": " . s:format_title_case(join(a:000[l:entry_start_index:-1], " "))

  try
    let l:month = s:bujo_months[str2nr(expr)]["short"]
  catch
    if len(l:month) < 3 
      echoerr "Please provide at least the first 3 characters of the month when specifying name."
    endif
    let l:month = l:month[0:2]
  endtry
  
  call s:init_future(a:year)

  " Open that year's future log
  let l:future_log = s:format_path(g:bujo_path, s:current_journal, s:BUJO_FUTURE . "_" . l:year . ".md")
  let l:content = readfile(l:future_log)

  let l:search_for = substitute(substitute(s:bujo_future_month_header, "%B", l:month, "g"), "%b", l:month, "g")
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
  let l:list_char = l:list_char . " " 
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
    let l:journal_name = a:bang ? "global" : s:current_journal
    execute "edit " . fnameescape(s:format_path("bujo://", expand(g:bujo_path), l:journal_name, "collections.md"))
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
      if line !~# l:counter . ". "
        call insert(l:content, l:counter . l:collection_header, l:counter + 2)
        break
      " Account for the case where we are at EOF and no empty newline
      elseif line ==# l:content[0] || len(l:content) == l:counter + 2
        call add(l:content, l:counter + 1 . l:collection_header)
      endif
    endfor
    call writefile(l:content, l:journal_index)
	endif

  let l:content = [ "# " . l:collection_print_name, "", "" ]
  call writefile(l:content, l:collection_path)

  execute "edit " . fnameescape(l:collection_path)

endfunction

function! bujo#Backlog(...) abort
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
        call add(l:content, "")
      endif
    endfor
    call add(l:content, "")
    call writefile(l:content, l:backlog)
  endif
  " Check if we need to create an entry
  " We do this before opening the split as we may want to do both
  if a:0 == 0
    execute "edit " . fnameescape(l:backlog)
  else
    let l:entry = substitute(join(a:000, " "), "\\(^[a-z]\\)", "\\U\\1", "g")
    let l:content = readfile(l:backlog)
    call writefile(s:list_append_entry(l:content, s:bujo_header_entries[s:BUJO_TASK]["header"], s:bujo_header_entries[s:BUJO_TASK]["list_char"],  l:entry), l:backlog)
  endif
endfunction

function! s:init_monthly(month) abort
  let l:monthly_log = s:format_path(g:bujo_path, s:current_journal, s:format_header_custom_date(s:bujo_monthly_filename, s:get_current_year(), a:month, 1))
  let l:future_log = s:format_path(g:bujo_path,s:current_journal,s:format_header_custom_date(s:bujo_future_filename,s:get_current_year(), 1, 1))
  if filereadable(l:monthly_log) | return | endif
  " We rely on pulling info from future log to create the monthly
  " event/tasks/notes lists (to prepopulate)
  if !filereadable(l:future_log) | call s:init_future(s:get_current_year()) | endif
  let l:future_content = readfile(l:future_log)
  let l:content = [ s:format_header_custom_date(g:bujo_monthly_header, s:get_current_year(), a:month, 1), "" ]
  let l:month_start = matchstrlist(l:future_content, s:format_header_custom_date(s:bujo_future_month_header, s:get_current_year(), a:month, 1))
  let l:month_end = a:month + 1 >= 12 ? -1 : matchstrlist(l:future_content, s:format_header_custom_date(s:bujo_future_month_header, s:get_current_year(), a:month + 1, 1))
  call extend(l:content, l:future_content[l:month_start[0]["idx"] + 2 : l:month_end[0]["idx"] - 1])

  if g:bujo_monthly_table_enabled 
    let l:day_header = "Day "
    let l:empty_checkbox = "[ ]"
    let l:table_horizontal_border = "|" . repeat("-",len(l:day_header) + 1)
    let l:row = "| " . l:day_header
    for header in g:bujo_monthly_table_headers
      let l:table_horizontal_border .= "-+" . repeat("-", len(s:format_header(header["title"])) + 1)
      let l:row .= " | " . s:format_header(header["title"])
    endfor
    let l:table_horizontal_border .= "-|"
    let l:row .= " |"
    call add(l:content, l:table_horizontal_border)
    call add(l:content, l:row)
    if g:bujo_monthly_table_align
      let l:row = "| :" . repeat("-", len(l:day_header) - 1) . " |"
      for header in g:bujo_monthly_table_headers
        let l:row .= " :" . repeat("-", len(header["title"]) - 2) . ": |"
      endfor
      call add(l:content, l:row)
    endif
    for day in range(1, s:bujo_months[a:month - 1]["days"])
      let l:row = "| " . s:bujo_days[s:get_week_day(s:get_current_year(), a:month, day)]["letter"] . day . "." . repeat(" ", len(l:day_header) - (day / 10 < 1 ? 3: 4)) . " |"
      for header in g:bujo_monthly_table_headers
        let l:padding = ((len(header["title"]) + 2) / 2) - (len(l:empty_checkbox) / 2)
        let l:cron_expr = header["cron"]
        if s:process_cron(l:cron_expr, s:get_current_year(), a:month, day, s:get_week_day(s:get_current_year(), a:month, day))
          let l:cell_content = l:empty_checkbox 
        else
          let l:cell_content = repeat(" ", len(l:empty_checkbox))
        endif
        let l:rounding_padding = (len(header["title"]) + 2) - ((l:padding * 2) + len(l:empty_checkbox))
        let l:row .= repeat(" ", l:padding) . l:cell_content . repeat(" ", l:padding + l:rounding_padding) . "|"
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
function! bujo#Monthly(...) abort
  if a:0 > 0  
    let l:month = a:1
    if l:month =~ "[0-9]+"
      let l:month = str2nr(l:month)
    else
      if len(l:month) < 3 
        echoerr "Please provide at least 3 characters when specifying a month to properly differentiate between similar names"
      endif
      let l:index = 0
      for entry in s:bujo_months
        let l:index += 1
        if entry["short"] =~? l:month[-3:-1]
          let l:month = l:index
        endif
      endfor
    endif
  else
    let l:month = s:get_current_month()
  endif

  let l:monthly_log = s:format_path(g:bujo_path, s:current_journal, s:BUJO_MONTHLY . "_" . s:get_current_year() . "_" . l:month . ".md")

  if s:mkdir_if_needed(s:current_journal) | return | endif
  call s:init_monthly(l:month)

  execute "edit " . fnameescape(l:monthly_log)
endfunction

function! bujo#MonthlyEntry(type, ...) abort
  " FIXME - Notes add a lot of extra space around them
  let l:month = s:get_current_month()
  let l:monthly_log = s:format_path(g:bujo_path, s:current_journal, s:BUJO_MONTHLY . "_" . s:get_current_year() . "_" . l:month . ".md")
  if s:mkdir_if_needed(s:current_journal) | return | endif
  call s:init_monthly(l:month)
  let l:entry = substitute(join(a:000[1:-1], " "), "\\(^[a-z]\\)", "\\U\\1", "")
  let l:content = readfile(l:monthly_log)
  call writefile(s:list_append_entry(l:content, s:bujo_header_entries[a:type]["header"], s:bujo_header_entries[a:type]["list_char"], l:entry), l:monthly_log)
endfunction

function! bujo#ListTasks(all_journals) abort
  if a:all_journals
    let l:journals = readdir(s:format_path(g:bujo_path), {f -> isdirectory(expand(g:bujo_path . f)) && f !~ "^[.]"})
  else 
    let l:journals = [s:current_journal]
  endif

  let l:content = [ "# Task List", "" ]
  for journal in l:journals 
    let l:formatted_journal_name = s:format_from_path(journal)
    let l:journal_content = ["## Journal: " . l:formatted_journal_name, ""]
    let l:collections = readdir(s:format_path(g:bujo_path, journal), {f -> f =~ "[.]md$"})
    for collection in l:collections
      let l:file_content = readfile(s:format_path(g:bujo_path, journal, collection))
      let l:open_tasks = matchstrlist(l:file_content, '- \[ \] ..*')
      if len(l:open_tasks) == 0
        continue
      endif

      let l:has_tasks = v:true
      let l:formatted_collection_name = s:format_from_path(collection)

      call add(l:journal_content, "**" . l:formatted_collection_name . ":**")
      for entry in l:open_tasks
        call add(l:journal_content, entry["text"])
      endfor
      call add(l:journal_content, "")
    endfor
    if len(l:journal_content) > 2
      call extend(l:content, l:journal_content)
    endif
  endfor
  if len(l:content) == 2
    call add(l:content, "**No open tasks found**")
  endif

  let l:journal_name = len(l:journals) > 1 ? "global": l:journals[0]
  execute "edit " . fnameescape(s:format_path("bujo://", expand(g:bujo_path), l:journal_name, "tasklist.md"))
  setlocal filetype=markdown buftype=nofile noswapfile bufhidden=wipe
  call append(0, l:content)
  setlocal readonly nomodifiable
endfunction

function! bujo#GetInternalVariable(var) abort
  return get(s:, a:var, "Failed to find " . a:var . " in s:")
endfunction

function! bujo#VaderCall(funcname, ...) abort
  return call(a:funcname, a:000)
endfunction
