" The functions contained within this file are for internal use only.  For the
" official API, see the commented functions in plugin/bujo.vim.

if exists('g:autoloadedBujo') | finish | endif
let g:autoloadedBujo = 1

" Public variables
if !exists('g:bujoPath')                     | let g:bujoPath = '~/bujo/'                               | endif
if !exists('g:bujoDefaultJournal')           | let g:bujoDefaultJournal = "Default"                     | endif
if !exists('g:bujoSplitRight')               | let g:bujoSplitRight = &splitright                       | endif
if !exists('g:bujoAutoReflection')           | let g:bujoAutoReflection = v:true                        | endif
if !exists('g:bujoDailySkipWeekend')         | let g:bujoDailySkipWeekend = v:false                     | endif
if !exists('g:bujoWinsize')                  | let g:bujoWinsize = 50                                   | endif
if !exists('g:bujoMonthlyTableEnabled')      | let g:bujoMonthlyTableEnabled = v:true                   | endif
if !exists('g:bujoMonthlyTableAlign')        | let g:bujoMonthlyTableAlign = v:true                     | endif
if !exists('g:bujoWeekStart')                | let g:bujoWeekStart = 1                                  | endif
if !exists('g:bujoJournalStatuslinePrepend') | let g:bujoJournalStatuslinePrepend = ""                  | endif
if !exists('g:bujoJournalStatuslineAppend')  | let g:bujoJournalStatuslineAppend = "Journal"            | endif
if !exists('g:bujoIndexIncludeFuture')       | let g:bujoIndexIncludeFuture = v:true                    | endif
if !exists('g:bujoIndexIncludeMonthly')      | let g:bujoIndexIncludeMonthly = v:true                   | endif
if !exists('g:bujoIndexIncludeDaily ')       | let g:bujoIndexIncludeDaily  = v:true                    | endif
if !exists('g:bujoIndexIncludeBacklog ')     | let g:bujoIndexIncludeBacklog  = v:true                  | endif
if !exists('g:bujoBacklogHeader')            | let g:bujoBacklogHeader =  "# {journal} Backlog"         | endif
if !exists('g:bujoFutureHeader')             | let g:bujoFutureHeader =  "# {journal} Future Log - %Y"  | endif
if !exists('g:bujoMonthlyHeader')            | let g:bujoMonthlyHeader = "# %B %Y"                      | endif
if !exists('g:bujoHabits')
  let g:bujoHabits = [ 
  \ {
  \		"title":"Journal",
  \		"cron":"* * * *"
  \ },
  \ ]
endif

" Constants/ Enums
let s:BUJONOTE    = "note"
let s:BUJOTASK    = "task"
let s:BUJOEVENT   = "event"
let s:BUJODAILY   = "daily"
let s:BUJOBACKLOG = "backlog"
let s:BUJOMONTHLY = "monthly"
let s:BUJOFUTURE  = "future"

" Private variables
" Daily Log vars
let s:bujoDailyFilename = s:BUJODAILY . "_%Y-%m-%d.md"
let s:bujoDailyHeader =  "# %A %B %d" 
let s:bujoDailyTaskHeader =  "**Tasks:**"
let s:bujoDailyEventHeader =  "**Events:**" 
let s:bujoDailyNoteHeader =  "**Notes:**"

if !exists('g:bujoHeaderEntriesOrdered')
  let g:bujoHeaderEntriesOrdered = [
  \ s:BUJOEVENT,
  \ s:BUJOTASK,
  \ s:BUJONOTE,
  \]
endif

let s:bujoHeaderEntries = {
\ s:BUJOEVENT : {
\   "name": s:BUJOEVENT,
\   "header": s:bujoDailyEventHeader,
\   "listChar": "*",
\   "dailyEnabled": v:true,
\   "futureEnabled": v:true,
\   "monthlyEnabled": v:true,
\   "backlogEnabled": v:false
\ },
\ s:BUJOTASK : {
\   "name": s:BUJOTASK,
\   "header": s:bujoDailyTaskHeader,
\   "listChar": "- [ ]",
\   "dailyEnabled": v:true,
\   "futureEnabled": v:true,
\   "monthlyEnabled": v:true,
\   "backlogEnabled": v:true
\ },
\ s:BUJONOTE: {
\   "name": s:BUJONOTE,
\   "header": s:bujoDailyNoteHeader,
\   "listChar": "*",
\   "dailyEnabled": v:true,
\   "futureEnabled": v:true,
\   "monthlyEnabled": v:true,
\   "backlogEnabled": v:false
\ }
\}

" Add in custom index entries from global dictionary
if exists("g:bujoHeaderEntries") 
  call extend(s:bujoHeaderEntries, g:bujoHeaderEntries)
endif

" Future Log vars
let s:bujoFutureFilename = s:BUJOFUTURE . "_%Y.md"
let s:bujoFutureMonthHeader =  "# %B" 

" Monthly Log vars
let s:bujoMonthlyFilename = s:BUJOMONTHLY . "_%Y_%m.md"

" Backlog vars
let s:bujoBacklogFilename = "backlog.md"


" Index vars
let s:bujoIndexHeader = "# {journal} Index"
let s:bujoIndexEntries = [
\ { 
\  "name": "Future Log",
\  "file": s:bujoFutureFilename,
\ },
\ { 
\   "name": "Monthly Log",
\   "file": s:bujoMonthlyFilename,
\ },
\ { 
\   "name": "Daily Log",
\   "file": s:bujoDailyFilename,
\ },
\ { 
\   "name": "Backlog",
\   "file": s:bujoBacklogFilename,
\ }
\]

" Add in custom index entries from global list
if exists("g:bujoIndexEntries") 
  call extend(s:bujoIndexEntries, g:bujoIndexEntries)
endif

let s:bujoDays = { 
\ 0: { "letter": "S", "short": "Sun", "long": "Sunday"},
\ 1: { "letter": "M", "short": "Mon", "long": "Monday"},
\ 2: { "letter": "T", "short": "Tue", "long": "Tuesday"},
\ 3: { "letter": "W", "short": "Wed", "long": "Wednesday"},
\ 4: { "letter": "T", "short": "Thu", "long": "Thursday"},
\ 5: { "letter": "F", "short": "Fri", "long": "Friday"},
\ 6: { "letter": "S", "short": "Sat", "long": "Saturday"},
\ }

let s:bujoMonths = [
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
" i.e. let g:bujoMigratedToFuture = '<' -- Migrated to future log
"      > = Migrated to next week look
" etc

if !exists('g:bujoVaderTesting')
  let g:bujoVaderTesting = v:false
  let g:bujoVaderMkdirChoice = 1
endif

function! s:stripWhitespace(input) abort
  return substitute(substitute(a:input, '^ *', '', "g"), " *$", "", "g")
endfunction

function! s:formatInitialCase(input) abort
  return substitute(a:input, '\<.', '\U&', "g")
endfunction

function! s:formatTitleCase(input) abort
  return substitute(a:input, '\<.', '\U&', "")
endfunction

function! s:formatDateWithSuffix(date) abort
  if a:date[-1:-1] == 1 
    return a:date . "st"
  elseif a:date[-1:-1] == 2
    return a:date . "nd"
  elseif a:date[-1:-1] == 3
    return a:date . "rd"
  else 
    return a:date . "th"
  endif
endfunction

function! s:formatFilename(filename)  abort
  return tolower(
      \ substitute(
        \ substitute(strftime(s:stripWhitespace(a:filename)), " ", "_", "g"), 
      \ '[!"£$%^&*;:''><\\\/|,())?\[\]]', "", "g"))
endfunction

" We setup g:bujoDefaultJournal at top of this file if it hasn't been set by
" user (will always have a value). Do this down here for use of above function
let s:currentJournal = s:formatFilename(g:bujoDefaultJournal)

function! s:getFormattedJournal(journal)
  " If the journal index doesn't exist we need to intialise it 
  " Other function has missed creating it
  call s:initJournalIndex(a:journal)
  " Read the first line from the index file under the journal specified
  " Skip first 2 chars as these are always `# `
	return substitute(readfile(s:formatPath(g:bujoPath, a:journal, "index.md"), "", 1)[0][2:-1], "Index", "", "g")
endfunction

function! s:formatHeader(header, journal = s:formatInitialCase(s:currentJournal))  abort
  return strftime(substitute(a:header, "{journal}", s:formatInitialCase(a:journal), "g"))
endfunction

function! s:formatHeaderCustomDate(format, year, month, day) abort
  let l:dow = s:getWeekDay(a:year,a:month,a:day)
  return substitute(
         \ substitute(
           \ substitute(
             \ substitute(
               \ substitute(
                 \ substitute(
                   \ substitute(
                     \ substitute(
                       \ substitute(a:format, "{journal}", s:formatInitialCase(s:currentJournal), "g"), 
                       \ "%Y", a:year, "g"),
                     \ "%m", a:month, "g"),
                   \ "%d", a:day, "g"),
                 \ "%B", s:bujoMonths[a:month - 1]["long"], "g"),
               \ "%b", s:bujoMonths[a:month - 1]["short"], "g"),
             \ "%A", s:bujoDays[l:dow]["long"], "g"),
           \ "%a", s:bujoDays[l:dow]["short"], "g"),
         \ "%w", s:getWeekOfMonth(a:year,a:month,a:day), "g")
endfunction

function! s:formatPath(...) abort
	if a:0 == 0 
		echoerr "formatPath requires at least 2 arguments"
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

function! s:formatFromPath(journal, collection = "index.md") abort
  return substitute(readfile(s:formatPath(g:bujoPath, a:journal, a:collection), "", 1)[0][2:-1], "index", "", "g")
endfunction

function! s:listJournals() abort
	return readdir(expand(g:bujoPath), {f -> isdirectory(s:formatPath(g:bujoPath, f)) && f !~ "^[.]"})
endfunction

" mkdirIfNeeded
" Returns true if user cancelled, false if already exists/created directory
" TODO - See if we can remove the bool return from here and rely on abort...
function! s:mkdirIfNeeded(journal) abort
  let l:journalDir = s:formatPath(g:bujoPath, s:formatFilename(a:journal))
  if isdirectory(l:journalDir) | return v:false | endif

  let l:journalPrintName = s:formatInitialCase(a:journal)
  let choice = g:bujoVaderTesting ? g:bujoVaderMkdirChoice : confirm("Creating new journal `" . l:journalPrintName . "`. Continue Y/n (default: yes)?","&Yes\n&No")
  if l:choice != 1 
    echon "Aborting journal creation"
    return v:true
  endif

  call mkdir(l:journalDir, "p", "0o775")
  return v:false
endfunction

function! s:initJournalIndex(journal) abort
  let l:journalIndex = s:formatPath(g:bujoPath, s:formatFilename(a:journal), "/index.md")
  " We have already initialised index 
  if filereadable(l:journalIndex) | return | endif

  let l:content = [s:formatHeader(s:bujoIndexHeader, a:journal), ""]
  let l:counter = 0
  for key in s:bujoIndexEntries
    let l:counter += 1
    call add(l:content, l:counter . "." . " [" . key["name"] . "](" . key["file"] . ")")
  endfor
  call writefile(l:content, l:journalIndex)
endfunction

function! s:getMonthlyLogEntries(year, month)
  let l:monthlyLog = s:formatPath(g:bujoPath, s:currentJournal, s:formatHeaderCustomDate(s:bujoMonthlyFilename, a:year, a:month, 1))
  if !filereadable(l:monthlyLog) | call s:initMonthly(s:getCurrentMonth()) | endif
  let l:monthlyContent = readfile(l:monthlyLog)
  let l:entries = {}
  let l:prevStart = -1
  for i in range(len(g:bujoHeaderEntriesOrdered))
    let l:key = g:bujoHeaderEntriesOrdered[i]
    let l:start = matchstrlist(l:monthlyContent, escape(s:bujoHeaderEntries[l:key]["header"], "*"))[0]["idx"] + 1
    let l:end = i + 1 == len(g:bujoHeaderEntriesOrdered) ? -1 : matchstrlist(l:monthlyContent, escape(s:bujoHeaderEntries[g:bujoHeaderEntriesOrdered[i + 1]]["header"], "*"))[0]["idx"] - 1
    let l:entries[l:key] = l:monthlyContent[l:start: l:end]
  endfor
  return l:entries
endfunction

function! s:getEntriesFromBlock(block, date) abort
  let l:entries = {}
  for key in g:bujoHeaderEntriesOrdered
    let l:entryBlock = a:block[key]
    let l:entries[key] = []
    let l:matches = matchstrlist(l:entryBlock, s:formatDateWithSuffix(a:date))
    for entry in l:matches
      call add(l:entries[key], substitute(l:entryBlock[entry["idx"]], s:formatDateWithSuffix(a:date) . ": ", "", ""))
    endfor
  endfor
  return l:entries
endfunction

function! s:generateDailyContent(year,month,day) abort
  let l:monthlyEntries = s:getMonthlyLogEntries(a:year, a:month)
  let l:dayHeader = s:formatHeaderCustomDate(s:bujoDailyHeader, a:year, a:month, a:day)
  let l:content = [l:dayHeader, ""]
  let l:entries = s:getEntriesFromBlock(l:monthlyEntries, a:day)
  for key in g:bujoHeaderEntriesOrdered
    call add(l:content, s:bujoHeaderEntries[key]["header"])
    call extend(l:content, l:entries[key])
    call add(l:content, "")
  endfor
  return l:content
endfunction

" TODO - Option to disable weekends
function! s:initDaily() abort
  let l:formattedDailyHeader = s:formatHeader(s:bujoDailyHeader, s:currentJournal)
  let l:dailyLog = s:formatPath(g:bujoPath, s:currentJournal, s:formatHeaderCustomDate(s:bujoDailyFilename, s:getCurrentYear(), s:getCurrentMonth(), s:getCurrentDay())) 

  if s:mkdirIfNeeded(s:currentJournal) | return | endif
  if filereadable(l:dailyLog) | return | endif

  let l:content = s:generateDailyContent(s:getCurrentYear(), s:getCurrentMonth(), s:getCurrentDay())
  " Write output to file
  call writefile(l:content, l:dailyLog)
  call bujo#Outstanding()
  execute "wincmd w"
endfunction

function! s:initFuture(year) abort
  let l:journalDir = s:formatPath(g:bujoPath, s:currentJournal)
  let l:futureLog = s:formatPath(g:bujoPath, s:currentJournal, s:BUJOFUTURE . "_" . a:year . ".md")
  if filereadable(l:futureLog)
    return
  endif
  let l:content = []
  call add(l:content, s:formatHeader(g:bujoFutureHeader))
  call add(l:content, "")
  if s:getCurrentYear() == a:year 
    " Skip the months that have already passed
    let l:months = s:bujoMonths[strftime("%m") - 1:-1]
  else 
    let l:months = s:bujoMonths
  endif 
  for month in l:months
    " TODO - This **will** break between systems. Will need to add a conditional to decide what to go with when we encounter it
    call add(l:content, substitute(substitute(s:bujoFutureMonthHeader, "%B", month["long"], "g"), "%b", month["short"], "g"))
    call add(l:content, "")
    for key in g:bujoHeaderEntriesOrdered
      if s:bujoHeaderEntries[key]["futureEnabled"]
        call add(l:content, s:bujoHeaderEntries[key]["header"])
        call add(l:content, "")
      endif
    endfor
    call add(l:content, "")
    call writefile(l:content, l:futureLog)
  endfor
endfunction

function! s:listInsertEntry(list, typeHeader, typeListChar, entry, stopPattern = v:null) abort
  let l:index = 1
  let l:listChar = a:typeListChar . " " 
  for line in a:list
    if a:stopPattern isnot v:null && line ==# a:stopPattern | return | endif
    if line ==# a:typeHeader
      call insert(a:list, l:listChar . a:entry, l:index)
      return a:list
    endif
    let l:index += 1
  endfor

  " If we reach here, we've failed to locate the header
  " The only 'safe' way I can conceive to add this in is 
  " to locate todays header and insert it 3 lines below 
  " (leaving blank line below header)
  call insert(a:list, a:typeHeader, 2)
  call insert(a:list, l:listChar . a:entry, 3)
  call insert(a:list, "", 4)
  return a:list
endfunction

function! s:listAppendEntry(list, typeHeader, typeListChar, entry)  abort
  let l:index = 1
  let l:listChar = a:typeListChar . " " 
  for line in a:list
    if line ==# a:typeHeader
      for item in a:list[l:index:-1]
        if item !~# '^\s*' . escape(l:listChar[0], '*\/+') || (l:index + 1 == len(a:list))
          call insert(a:list, l:listChar . a:entry, l:index)
          return a:list
        endif
        let l:index += 1
      endfor
      
      " Edge case at EOF
      if l:index == len(a:list)
        call insert(a:list, l:listChar . a:entry, l:index)
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
  call insert(a:list, a:typeHeader, 2)
  call insert(a:list, l:listChar . a:entry, 3)
  call insert(a:list, l:listChar, 4)
  return a:list
endfunction

function! s:listReplaceEntry(list, target, new) abort
endfunction

function! s:listCollections(showAll) abort
  let l:collections = []
  if a:showAll
    let l:journals = s:listJournals()
    for journal in l:journals
      let l:entry = [journal, readdir(s:formatPath(g:bujoPath, journal), {f -> f !~ '\(' . s:BUJODAILY . '\|' . s:BUJOMONTHLY . '\|' . s:BUJOFUTURE . '\|' . s:BUJOBACKLOG. '\)'})]
      call add(l:collections, l:entry)
    endfor
  else
    call add(l:collections, [s:currentJournal, readdir(s:formatPath(expand(g:bujoPath), s:formatFilename(s:currentJournal)), {f -> f !~ '\(' . s:BUJODAILY . '\|' . s:BUJOMONTHLY . '\|' . s:BUJOFUTURE . '\|' . s:BUJOBACKLOG. '\)'})])
  endif
  return l:collections
endfunction

function! s:formatListCollections(collections) abort
    let l:content = []
    for journal in a:collections
      let l:journalName = s:formatFromPath(journal[0])
      call add(l:content, "# " . l:journalName)
      call add(l:content, "")
      for collection in journal[1]
        let l:formattedEntry = s:formatFromPath(journal[0], collection)
        let l:entryLink = s:formatPath(g:bujoPath, journal[0], collection)
        call add(l:content, "* [" . l:formattedEntry . "](" . l:entryLink . ")")
      endfor
      call add(l:content, "")
    endfor
    return l:content
endfunction

function! s:formattedDailyHeader(day, date) abort
  return s:formatDateStr(s:bujoDailyHeader, s:getCurrentYear(), s:getCurrentMonth(), a:date)
  let l:formattedDailyHeader = s:formatHeader(s:bujoDailyHeader, a:journal) 
endfunction

function! s:isCollection(journal, collection)  abort
	try
		let l:collections = readdir(s:formatPath(expand(g:bujoPath), s:formatFilename(a:journal)), {f -> f !~ '\(' . s:BUJODAILY . '\|' . s:BUJOMONTHLY . '\|' . s:BUJOFUTURE . '\|' . s:BUJOBACKLOG. '\)'})
	catch
		return v:false
	endtry
	for entry in l:collections
		if s:formatFilename(entry) ==# s:formatFilename(a:collection . ".md")
			return v:true
		endif
	endfor
	return v:false
endfunction

function! s:setCurrentJournal(journal) abort
  let s:currentJournal = s:formatFilename(a:journal)
  " The screen gets stuck on 'Press Enter to continue' here
  " Force a redraw then show message in popup win to avoid
  " 'Enter to continue' prompts
  redraw!
  echon "Switched to journal: " . s:formatInitialCase(a:journal)
  return
endfunction

function! s:interactiveJournalSelect(journalList) abort
			" Select journal from list 
			let l:choices = []
			let l:choiceNumber = 0
			for journal in a:journalList
        let l:choiceNumber += 1
        call add(l:choices, "&" . l:choiceNumber . s:getFormattedJournal(journal)) 
			endfor
      call add(l:choices, "&Quit") 

			let l:result = confirm("Select Journal", join(l:choices, "\n")) 
      if l:result == 0 || l:result == len(l:choices)
        echon "User cancelled journal selection. Journal unchanged."
        return
      endif
      return s:setCurrentJournal(s:getFormattedJournal(a:journalList[l:result - 1]))
endfunction

function! s:processCronInterval(interval) abort
  let l:arr = []
  let l:intervals = split(a:interval, ",")
  for interval in l:intervals
    if match(interval, "-") != -1
      let l:split = split(interval, "-")
      let l:lhs = l:split[0]
      let l:rhs = l:split[1]
      for rangeInterval in range(l:lhs, l:rhs)
        call add(l:arr, rangeInterval)
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

function! s:processCron(expr, year, month, day, dow) abort
  " TODO - This doesn't handle division styling
  " i.e. */2 for every other day 
  " need to reread up on cron again before doing any more tho
  " Day Month Year DayOfWeek
  let l:exprList = split(a:expr, " ")
  if len(l:exprList) < 4 
    call (extend(l:exprList, repeat(["*"], 4 - len(l:exprList))))
  endif
  let l:days   = s:processCronInterval(l:exprList[0])
  let l:months = s:processCronInterval(l:exprList[1])
  let l:years  = s:processCronInterval(l:exprList[2])
  let l:dows   = s:processCronInterval(l:exprList[3])
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

function! s:getCurrentYear() abort
  return strftime("%Y")
endfunction

function! s:getCurrentMonth() abort
  return strftime("%m")
endfunction

function! s:getCurrentDay() abort
  return strftime("%d")
endfunction

function! s:isLeapYear(year) abort
  return a:year % 400 == 0 || (a:year % 100 != 0 && a:year % 4 == 0)
endfunction

" 0 = Sunday - 6 = Saturday
function! s:getWeekDay(year, month, day) abort
  " TODO - Ability to shift these aroud according to what day of the week you
  " want to start on
  let l:centuryCodes = {17: 4, 18: 2, 19: 0, 20: 6, 21: 4, 22: 2, 23:0}
  let l:yearCode = (a:year[2:-1] + (a:year[-2:-1] / 4)) % 7
  let l:monthCode = s:bujoMonths[a:month - 1]["code"]
  let l:leap = s:isLeapYear(a:year) && (a:month == 0 || a:month == 1) ? 1: 0 
  return (l:yearCode + l:monthCode + l:centuryCodes[a:year[0:1]] + a:day - l:leap) % 7
endfunction

function! s:getWeekOfMonth(year,month,day) abort
  let l:firstDayOfMonth = s:getWeekDay(a:year,a:month,1)
  let l:firstWeekStartOfMonth = g:bujoWeekStart >= l:firstDayOfMonth ? g:bujoWeekStart - l:firstDayOfMonth : (7 % l:firstDayOfMonth) + g:bujoWeekStart
  if l:firstWeekStartOfMonth < a:day
    return ((a:day - l:firstWeekStartOfMonth) / 7) + 1
  else 
    let l:monthDays = s:isLeapYear(a:year) && a:month == 2 ? 29 : s:bujoMonths[a:month-1]["days"]
    return s:getWeekOfMonth(a:year,a:month -1, a:day + l:monthDays)
  endif
endfunction

function! s:formatDateStr(in, year, month, day) abort
  let l:month = a:month < 10 ? "0" . str2nr(a:month) : a:month
  let l:day = a:day < 10 ? "0" . str2nr(a:day) : a:day
  let l:weekOfMonth = s:getWeekOfMonth(a:year,a:month,a:day)
  return substitute(
        \ substitute(
          \ substitute(
            \ substitute(a:in, "%d", l:day, "g"),
            \ "%w", l:weekOfMonth, "g"),
          \ "%m", l:month, "g"),
        \ "%Y", a:year, "g")
endfunction

function! bujo#Head() abort
  let l:prepend = len(g:bujoJournalStatuslinePrepend) == 0 ? "": " " . g:bujoJournalStatuslinePrepend
  let l:append = len(g:bujoJournalStatuslineAppend) == 0 ? "": " " . g:bujoJournalStatuslineAppend     
  return l:prepend . s:formatTitleCase(s:currentJournal) . l:append           
endfunction

" Get and set current journal (offer to create if it doesn't exist)
function! bujo#Journal(printCurrent, ...) abort
  let l:journalName = s:formatTitleCase(join(a:000, " "))
	let l:journals = s:listJournals()
	if len(l:journals) == 0 
		call s:initJournalIndex(s:currentJournal)
    let l:journals = s:listJournals()
	endif
  if a:0 == 0 
		if a:printCurrent
			echon "Current Journal: " . s:getFormattedJournal(s:currentJournal)
      return
		else
      return s:interactiveJournalSelect(l:journals)
		endif
  endif
	" Check if journal can be found
	" Support regex but needs to only find 1 match
	" Doesn't change s:currentJournal on failure
  let l:matchedJournals = matchstrlist(l:journals, l:journalName)
  if len(l:matchedJournals) == 0 
    if s:mkdirIfNeeded(l:journalName) | return | endif
    return s:setCurrentJournal(l:journalName)
  elseif len(l:matchedJournals) == 1
    return s:setCurrentJournal(l:matchedJournals[0]["text"])
  elseif len(l:matchedJournals) > 1
    let l:matches = []
    for match in l:matchedJournals
      call add(l:matches, l:journals[match["idx"]])
    endfor
    return s:interactiveJournalSelect(l:matches)
  endif
  return s:interactiveJournalSelect()

endfunction

function! bujo#Index(listJournals, ...) abort
  let l:journal = a:0 == 0 ? s:currentJournal : join(a:000, " ")
  let l:journalIndex = s:formatPath(g:bujoPath,s:formatFilename(l:journal), "/index.md")
  
  " Check to see if the journal exists
  if !a:listJournals
    if s:mkdirIfNeeded(l:journal) | return | endif
  endif

  if a:listJournals
    execute "edit " . fnameescape(s:formatPath("bujo://", expand(g:bujoPath), "index.md"))
    setlocal filetype=markdown buftype=nofile noswapfile bufhidden=wipe
    let l:content = ["# Journal Index", ""]
    for entry in readdir(expand(g:bujoPath), {f -> isdirectory(expand(g:bujoPath . f)) && f !~ "^[.]"})
      call add(l:content, "- [" . s:formatInitialCase(entry). "]( " . entry . "/index.md" . " )")
    endfor
    call append(0, l:content)
    setlocal readonly nomodifiable
  else
    call s:initJournalIndex(l:journal)
    call s:fixIndexCollectionLinks(l:journal)
    execute "edit " . fnameescape(l:journalIndex)
  endif
endfunction

function! s:outstandingSort(a, b) abort
  let l:aDate = split(match(a:a, '[0-9]\{4}-[0-9]{1,2}-[0-9]{1,2}'), "-")
  let l:bDate = split(match(a:b, '[0-9]\{4}-[0-9]{1,2}-[0-9]{1,2}'), "-")
  let l:year = 0
  let l:month = 1
  let l:day = 2
  if l:aDate[l:year] > l:bDate[l:year] && l:aDate[l:month] > l:bDate[l:month] && l:aDate[l:day] > l:bDate[l:day] 
    return -1
  endif
  return 1
endfunction

function! bujo#Outstanding() abort
  let l:files = sort(readdir(s:formatPath(g:bujoPath, s:currentJournal), {f -> f =~ "daily.*[.]md$"}), "s:outstandingSort")
  call extend(l:files, readdir(s:formatPath(g:bujoPath, s:currentJournal), {f -> f =~ "[.]md$" && f !~ "backlog" && f !~ "daily.*[.]md$"}))
  let l:outstandingBuffer = []
  for file in l:files
    let l:fileContent = readfile(s:formatPath(g:bujoPath, s:currentJournal, file))
    let l:openTasks = matchstrlist(l:fileContent, '- \[ \] ..*')
    if len(l:openTasks) == 0 | continue | endif

    let l:formattedFileName = s:formatFromPath(s:currentJournal, file)

    let l:content = []
    call add(l:content, "**" . l:formattedFileName . ":**")
    for entry in l:openTasks
      call add(l:content, entry["text"])
    endfor
    call add(l:content, "")
    if len(l:content) > 2
      call extend(l:outstandingBuffer, l:content)
    endif
  endfor
  " Don't bother opening anything if we haven't foud any open tasks
  if len(l:outstandingBuffer) == 0 | return | endif

  execute "belowright split " . fnameescape(s:formatPath("bujo://", expand(g:bujoPath), s:currentJournal, "outstanding.md"))
  setlocal filetype=markdown buftype=nofile noswapfile bufhidden=wipe
  call append(0, l:outstandingBuffer)
  call cursor(1, 0) 
endfunction

function! bujo#Today() abort
  let l:dailyLog = s:formatPath(g:bujoPath, s:currentJournal, s:formatDateStr(s:bujoDailyFilename, s:getCurrentYear(), s:getCurrentMonth(), s:getCurrentDay()))
  " We're initialising this weeks daily log, do we have auto reflection
  " enabled?
  let l:logExists = filereadable(l:dailyLog)
  " if !l:logExists && g:bujoAutoReflection
  "   return bujo#Migration()
  " endif

  call s:initDaily()

  execute "edit " . fnameescape(l:dailyLog)
endfunction


function! s:dateAddDays(year,month,day,add) abort
  let l:year = a:year
  let l:month = a:month
  let l:day = a:day + a:add

  let l:isLeap = s:isLeapYear(l:year)
  let l:daysInMonth = l:month == 2 && l:isLeap ? 29 : s:bujoMonths[l:month-1]["days"]

  while l:day > l:daysInMonth
    let l:day -= l:daysInMonth
    let l:month += 1
    let l:daysInMonth = l:month == 2 && l:isLeap ? 29 : s:bujoMonths[l:month-1]["days"]
    if l:month > 12
      let l:year += 1
      let l:month -= 12
      let l:isLeap = s:isLeapYear(l:year)
    endif
  endwhile
  " If we're passed a negative value
  if l:day < 0 
    let l:day = l:day * -1
    let l:month -= 1
    let l:daysInMonth = l:month == 2 && l:isLeap ? 29 : s:bujoMonths[l:month-1]["days"]
    while l:day > l:daysInMonth
      let l:day -= l:daysInMonth
      let l:month -= 1
      let l:daysInMonth = l:month == 2 && l:isLeap ? 29 : s:bujoMonths[l:month-1]["days"]
      if l:month < 1
        let l:year -= 1
        let l:month += 12
        let l:isLeap = s:isLeapYear(l:year)
      endif
    endwhile
    let l:day = l:daysInMonth - l:day
  endif
  return [l:year, l:month, l:day]
endfunction
  
function! bujo#TestAddDays(year,month,day, add) abort
  return s:dateAddDays(a:year,a:month,a:day,a:add)
endfunction

function! bujo#Tomorrow() abort
  let l:date = s:dateAddDays(s:getCurrentYear(), s:getCurrentMonth(), s:getCurrentDay(), 1)
  let l:day = date[2]
  let l:filename = s:formatPath(g:bujoPath, s:currentJournal, s:formatDateStr(s:bujoDailyFilename, l:date[0], l:date[1], l:date[2]))

  let l:content = s:generateDailyContent(date[0], date[1], date[2])
  execute "edit " . fnameescape(l:filename)
  setlocal filetype=markdown noswapfile bufhidden=wipe
  call append(0, l:content)
  call cursor(1, 0) 
endfunction

function! bujo#Yesterday() abort
  let l:todaysDaily = s:formatDateStr(s:bujoDailyFilename, s:getCurrentYear(), s:getCurrentMonth(), s:getCurrentDay())
  try
    let l:filename = sort(readdir(s:formatPath(g:bujoPath, s:currentJournal), {f -> f =~ "daily.*[.]md$" && f !~ l:todaysDaily}), "s:outstandingSort")[0]
    let l:filepath = s:formatPath(g:bujoPath, s:currentJournal, l:filename)
    execute "edit " . fnameescape(l:filepath)
  catch
    let l:date = s:dateAddDays(s:getCurrentYear(), s:getCurrentMonth(), s:getCurrentDay(), -1)
    let l:day = date[2]
    let l:filename = s:formatPath(g:bujoPath, s:currentJournal, s:formatDateStr(s:bujoDailyFilename, l:date[0], l:date[1], l:date[2]))
    let l:content = s:generateDailyContent(l:date[0], l:date[1], l:date[2])
    call writefile(l:content, l:filename)
    execute "edit " . fnameescape(l:filename)
  endtry
endfunction

function! s:getDaysSinceWeekStart(year,month,day) abort
  let l:dow = s:getWeekDay(a:year, a:month, a:day)
  return l:dow - g:bujoWeekStart
endfunction

function! s:previewWeek(year,month,day) abort
  let l:weekStart = s:dateAddDays(a:year, a:month, a:day, -s:getDaysSinceWeekStart(a:year,a:month,a:day))
  let l:content = []
  for day in range(6) 
    if day > 0 | call add(l:content, "---") | endif
    let l:currentDate = s:dateAddDays(l:weekStart[0], l:weekStart[1], l:weekStart[2], day)
    let l:filename = s:formatPath(g:bujoPath, s:currentJournal, s:formatDateStr(s:bujoDailyFilename, l:currentDate[0], l:currentDate[1], l:currentDate[2]))
    if filereadable(l:filename)
      call extend(l:content, readfile(l:filename))
    else
      call extend(l:content, s:generateDailyContent(l:currentDate[0], l:currentDate[1], l:currentDate[2]))
    endif
  endfor
  return l:content
endfunction

function! bujo#ThisWeek() abort
  let l:content = s:previewWeek(s:getCurrentYear(), s:getCurrentMonth(), s:getCurrentDay())
  execute "edit " . fnameescape(s:formatPath("bujo://", expand(g:bujoPath), s:currentJournal, "thisWeek.md"))
  setlocal filetype=markdown buftype=nofile noswapfile bufhidden=wipe
  call append(0, l:content)
  call cursor(1, 0) 
endfunction

function! bujo#NextWeek() abort
  let l:date = s:dateAddDays(s:getCurrentYear(), s:getCurrentMonth(), s:getCurrentDay(), 7)
  let l:content = s:previewWeek(l:date[0], l:date[1], l:date[2])
  execute "edit " . fnameescape(s:formatPath("bujo://", expand(g:bujoPath), s:currentJournal, "nextWeek.md"))
  setlocal filetype=markdown buftype=nofile noswapfile bufhidden=wipe
  call append(0, l:content)
  call cursor(1, 0) 
endfunction

function! bujo#LastWeek() abort
  let l:date = s:dateAddDays(s:getCurrentYear(), s:getCurrentMonth(), s:getCurrentDay(), -7)
  let l:content = s:previewWeek(l:date[0], l:date[1], l:date[2])
  execute "edit " . fnameescape(s:formatPath("bujo://", expand(g:bujoPath), s:currentJournal, "lastWeek.md"))
  setlocal filetype=markdown buftype=nofile noswapfile bufhidden=wipe
  call append(0, l:content)
  call cursor(1, 0) 

endfunction

" TODO - Handle displaying urgent tasks
function! bujo#CreateEntry(type, isUrgent, ...) abort
	if a:0 == 0 
		echoerr "CreateEntry requires at least 1 additional argument for the entry value."
		return
	endif
	let l:entry = s:formatTitleCase(join(a:000, " "))

	" Note entries do not have a list character. 
	" To ensure we generate markdown that formats correctly insert
	" newline after entry
	let l:entry = l:entry

  let l:journal = s:currentJournal
  let l:dailyLog = s:formatPath(g:bujoPath, l:journal, s:formatDateStr(s:bujoDailyFilename, s:getCurrentYear(), s:getCurrentMonth(), s:getCurrentDay()))

  call s:initDaily()
  let l:content = readfile(l:dailyLog)
  call writefile(s:listAppendEntry(l:content, s:bujoHeaderEntries[a:type]["header"], s:bujoHeaderEntries[a:type]["listChar"], l:entry), l:dailyLog)
endfunction

function! bujo#Future(...) abort
  let l:futureLog = s:formatPath(g:bujoPath, s:currentJournal, s:formatFilename(s:bujoFutureFilename)) 

  if a:0 == 0
    let l:year = s:getCurrentYear()
  else
    let l:year = a:1 
  endif
  let l:futureLog = s:formatPath(g:bujoPath, s:currentJournal, s:formatHeaderCustomDate(s:bujoFutureFilename, l:year, 1, 1))

  if s:mkdirIfNeeded(s:currentJournal) | return | endif
  
  call s:initFuture(l:year)

  execute "edit " . fnameescape(l:futureLog)
  let l:content = readfile(l:futureLog)
  let l:row = matchstrlist(l:content, s:formatHeaderCustomDate(s:bujoFutureMonthHeader, l:year, s:getCurrentMonth(), 1))
  " Set the month to be the top of the file
  " + 1 as index starts at 0 + configured scrolloff distance to put the header
  " at the top of the buffer
  call cursor(l:row[0]["idx"] + 1 + &scrolloff, 0) 
  execute "normal z\<ENTER>"
endfunction

function! bujo#FutureEntry(type, providingYear, ...) abort
  " TODO - Ignore day, user can provide this if they choose as part of the entry
  " That way can have a general entry w/ no deadline (wont auto feed into daily log)
  if a:0 == 0
    echoerr "FutureEntry requires at least 1 additional argument"
  endif
  
  if a:providingYear 
    let l:year = a:1 
    let l:month = a:2
    let l:day = a:3
    let l:entryStartIndex = 3 
  else 
    let l:year = strftime("%Y")
    let l:month = a:1
    let l:day = a:2
    let l:entryStartIndex = 2 
  endif
  let l:entry = s:formatDateWithSuffix(l:day) . ": " . s:formatTitleCase(join(a:000[l:entryStartIndex:-1], " "))

  try
    let l:month = s:bujoMonths[str2nr(expr)]["short"]
  catch
    if len(l:month) < 3 
      echoerr "Please provide at least the first 3 characters of the month when specifying name."
    endif
    let l:month = l:month[0:2]
  endtry
  
  call s:initFuture(a:year)

  " Open that year's future log
  let l:futureLog = s:formatPath(g:bujoPath, s:currentJournal, s:BUJOFUTURE . "_" . l:year . ".md")
  let l:content = readfile(l:futureLog)

  let l:searchFor = substitute(substitute(s:bujoFutureMonthHeader, "%B", l:month, "g"), "%b", l:month, "g")
  " Find the month provided 
  let l:index = 0
  for line in l:content
    if line =~? l:searchFor
      break
    endif
    let l:index += 1
  endfor

  " Add entry under appropriate type header
  " TODO - Make this stop at the next month's header as may just run to EOF
  let l:listChar = s:bujoHeaderEntries[a:type]["listChar"]
  let l:listChar = l:listChar . " " 
  for line in l:content[l:index: -1]
    if line ==# s:bujoHeaderEntries[a:type]["header"]
      for item in l:content[l:index:-1]
        if item ==# l:listChar || item == ""
          if l:listChar ==# "" 
            call insert(l:content, "", l:index)
            let l:index += 1
          endif
          call insert(l:content, l:listChar . l:entry, l:index)
          break
        endif
        let l:index += 1
      endfor
      break
    endif
    let l:index += 1
  endfor

  call writefile(l:content, l:futureLog)
endfunction

function! bujo#Collection(bang, ...) abort
  if a:0 == 0
    let l:collections = s:listCollections(a:bang)
    let l:content = s:formatListCollections(l:collections)
    let l:journalName = a:bang ? "global" : s:currentJournal
    execute "edit " . fnameescape(s:formatPath("bujo://", expand(g:bujoPath), l:journalName, "collections.md"))
    setlocal filetype=markdown buftype=nofile noswapfile bufhidden=wipe nowrap
    " for entry in readdir(expand(g:bujoPath), {f -> isdirectory(expand(g:bujoPath . f)) && f !~ "^[.]"})
    "   call add(l:content, "- [" . s:formatInitialCase(entry). "]( " . entry . "/index.md" . " )")
    " endfor
    call append(0, l:content)
    setlocal readonly nomodifiable
    return
  endif


	let l:journal = s:currentJournal
  let l:collection = join(a:000, " ")
  let l:collectionPrintName = s:formatInitialCase(l:collection)

  if s:mkdirIfNeeded(l:journal) | return | endif

  let l:journalDir = s:formatPath(g:bujoPath, l:journal)
  let l:journalIndex = s:formatPath(l:journalDir, "/index.md")
  let l:collectionIndexLink = s:formatFilename(l:collection . ".md")
  let l:collectionPath = s:formatPath(l:journalDir, l:collectionIndexLink)

  call s:initJournalIndex(l:journal)
  if !s:isCollection(l:journal, l:collection) 
    " We are duplicating. 
    " Add the entry to index
    let l:content = readfile(l:journalIndex)
    " Skip the first 2 lines, these will always be the index header and a new line
    let l:counter = 0
    for line in l:content[2:-1]
      let l:counter += 1
      let l:collectionHeader = ". [" . l:collectionPrintName . "](" . l:collectionIndexLink . ")"
      if line !~# l:counter . ". "
        call insert(l:content, l:counter . l:collectionHeader, l:counter + 2)
        break
      " Account for the case where we are at EOF and no empty newline
      elseif line ==# l:content[0] || len(l:content) == l:counter + 2
        call add(l:content, l:counter + 1 . l:collectionHeader)
      endif
    endfor
    call writefile(l:content, l:journalIndex)
	endif

  let l:content = [ "# " . l:collectionPrintName, "", "" ]
  call writefile(l:content, l:collectionPath)

  execute "edit " . fnameescape(l:collectionPath)

endfunction

function! bujo#Backlog(...) abort
  let l:journalDir = s:formatPath(g:bujoPath, s:currentJournal)
  let l:backlog = l:journalDir . "/" . s:formatFilename(s:bujoBacklogFilename)
  if s:mkdirIfNeeded(s:currentJournal) | return | endif
  if !filereadable(l:backlog)
    let l:content = []
    call add(l:content, s:formatHeader(g:bujoBacklogHeader, s:currentJournal))
    call add(l:content, "")
    for key in g:bujoHeaderEntriesOrdered
      if s:bujoHeaderEntries[key]["backlogEnabled"]
        call add(l:content, s:bujoHeaderEntries[key]["header"])
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
    call writefile(s:listAppendEntry(l:content, s:bujoHeaderEntries[s:BUJOTASK]["header"], s:bujoHeaderEntries[s:BUJOTASK]["listChar"],  l:entry), l:backlog)
  endif
endfunction

function! s:initMonthly(month) abort
  let l:monthlyLog = s:formatPath(g:bujoPath, s:currentJournal, s:formatHeaderCustomDate(s:bujoMonthlyFilename, s:getCurrentYear(), a:month, 1))
  let l:futureLog = s:formatPath(g:bujoPath,s:currentJournal,s:formatHeaderCustomDate(s:bujoFutureFilename,s:getCurrentYear(), 1, 1))
  if filereadable(l:monthlyLog) | return | endif
  " We rely on pulling info from future log to create the monthly
  " event/tasks/notes lists (to prepopulate)
  if !filereadable(l:futureLog) | call s:initFuture(s:getCurrentYear()) | endif
  let l:futureContent = readfile(l:futureLog)
  let l:content = [ s:formatHeaderCustomDate(g:bujoMonthlyHeader, s:getCurrentYear(), a:month, 1), "" ]
  let l:monthStart = matchstrlist(l:futureContent, s:formatHeaderCustomDate(s:bujoFutureMonthHeader, s:getCurrentYear(), a:month, 1))
  let l:monthEnd = a:month + 1 >= 12 ? -1 : matchstrlist(l:futureContent, s:formatHeaderCustomDate(s:bujoFutureMonthHeader, s:getCurrentYear(), a:month + 1, 1))
  call extend(l:content, l:futureContent[l:monthStart[0]["idx"] + 2 : l:monthEnd[0]["idx"] - 1])

  if g:bujoMonthlyTableEnabled 
    let l:dayHeader = "Day "
    let l:emptyCheckbox = "[ ]"
    let l:tableHorizontalBorder = "|" . repeat("-",len(l:dayHeader) + 1)
    let l:row = "| " . l:dayHeader
    for header in g:bujoHabits
      let l:tableHorizontalBorder .= "-+" . repeat("-", len(s:formatHeader(header["title"])) + 1)
      let l:row .= " | " . s:formatHeader(header["title"])
    endfor
    let l:tableHorizontalBorder .= "-|"
    let l:row .= " |"
    call add(l:content, l:tableHorizontalBorder)
    call add(l:content, l:row)
    if g:bujoMonthlyTableAlign
      let l:row = "| :" . repeat("-", len(l:dayHeader) - 1) . " |"
      for header in g:bujoHabits
        let l:row .= " :" . repeat("-", len(header["title"]) - 2) . ": |"
      endfor
      call add(l:content, l:row)
    endif
    for day in range(1, s:bujoMonths[a:month - 1]["days"])
      let l:row = "| " . s:bujoDays[s:getWeekDay(s:getCurrentYear(), a:month, day)]["letter"] . day . "." . repeat(" ", len(l:dayHeader) - (day / 10 < 1 ? 3: 4)) . " |"
      for header in g:bujoHabits
        let l:padding = ((len(header["title"]) + 2) / 2) - (len(l:emptyCheckbox) / 2)
        let l:cronExpr = header["cron"]
        if s:processCron(l:cronExpr, s:getCurrentYear(), a:month, day, s:getWeekDay(s:getCurrentYear(), a:month, day))
          let l:cellContent = l:emptyCheckbox 
        else
          let l:cellContent = repeat(" ", len(l:emptyCheckbox))
        endif
        let l:roundingPadding = (len(header["title"]) + 2) - ((l:padding * 2) + len(l:emptyCheckbox))
        let l:row .= repeat(" ", l:padding) . l:cellContent . repeat(" ", l:padding + l:roundingPadding) . "|"
      endfor
      call add(l:content, l:row)
    endfor
    call add(l:content, l:tableHorizontalBorder)
    call add(l:content, "")
  endif
  call writefile(l:content, l:monthlyLog)

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
      for entry in s:bujoMonths
        let l:index += 1
        if entry["short"] =~? l:month[-3:-1]
          let l:month = l:index
        endif
      endfor
    endif
  else
    let l:month = s:getCurrentMonth()
  endif

  let l:monthlyLog = s:formatPath(g:bujoPath, s:currentJournal, s:BUJOMONTHLY . "_" . s:getCurrentYear() . "_" . l:month . ".md")

  if s:mkdirIfNeeded(s:currentJournal) | return | endif
  call s:initMonthly(l:month)

  execute "edit " . fnameescape(l:monthlyLog)
endfunction

function! bujo#MonthlyEntry(type, ...) abort
  " FIXME - Notes add a lot of extra space around them
  let l:month = s:getCurrentMonth()
  let l:monthlyLog = s:formatPath(g:bujoPath, s:currentJournal, s:BUJOMONTHLY . "_" . s:getCurrentYear() . "_" . l:month . ".md")
  if s:mkdirIfNeeded(s:currentJournal) | return | endif
  call s:initMonthly(l:month)
  let l:entry = substitute(join(a:000[1:-1], " "), "\\(^[a-z]\\)", "\\U\\1", "")
  let l:content = readfile(l:monthlyLog)
  call writefile(s:listAppendEntry(l:content, s:bujoHeaderEntries[a:type]["header"], s:bujoHeaderEntries[a:type]["listChar"], l:entry), l:monthlyLog)
endfunction

function! bujo#ListTasks(allJournals) abort
  let l:journals = !a:allJournals ? [s:currentJournal] : readdir(s:formatPath(g:bujoPath), {f -> isdirectory(expand(g:bujoPath . f)) && f !~ "^[.]"})

  let l:content = [ "# Task List", "" ]
  for journal in l:journals 
    let l:formattedJournalName = s:formatFromPath(journal)
    let l:journalContent = ["## Journal: " . l:formattedJournalName, ""]
    let l:collections = readdir(s:formatPath(g:bujoPath, journal), {f -> f =~ "[.]md$"})
    for collection in l:collections
      let l:fileContent = readfile(s:formatPath(g:bujoPath, journal, collection))
      let l:openTasks = matchstrlist(l:fileContent, '- \[ \] ..*')
      if len(l:openTasks) == 0 | continue | endif

      let l:formattedCollectionName = s:formatFromPath(collection)

      call add(l:journalContent, "**" . l:formattedCollectionName . ":**")
      for entry in l:openTasks
        call add(l:journalContent, entry["text"])
      endfor
      call add(l:journalContent, "")
    endfor
    if len(l:journalContent) > 2
      call extend(l:content, l:journalContent)
    endif
  endfor
  if len(l:content) == 2
    call add(l:content, "**No open tasks found**")
  endif

  let l:journalName = len(l:journals) > 1 ? "global": l:journals[0]
  execute "edit " . fnameescape(s:formatPath("bujo://", expand(g:bujoPath), l:journalName, "tasklist.md"))
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

" TODO - Remove *entriesOrdered variables and rework functions to handle missing elements if possible 
" TODO - Make everything use custom functions to replace dates in strings
" TODO - Replace %<char> with {year},{month},{day},{yr}(for short year) 
" TODO - Have Future/Monthly/Daily log links in Index to take to a virtual buffer listing in descending order 
