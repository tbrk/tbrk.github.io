" Maintainer:  Timothy Bourke
" Last Change: 2007 Oct 2
" $Id: checksenderaddress.vim 369 2008-01-01 22:55:11Z tbourke $

" Vim plugin
" for checking sender email addresses.
" 20070103 T. Bourke: original code
" 20071002 T. Bourke: fix bug parsing recipients of form:
"			    "last, first" <name@addr>, ...
"
" When using vim as an editor for email messages (as with mutt) this script
" can be used to help manage multiple sender addresses.
" 
" Define a global list variable, SenderEmailAddresses, with one entry for
" each email address. Place the `personal' email address first in the list.
" (When using mutt: the `from' variable should be set to the same email
"  address; `use_from' and `edit_headers' should be set to true.)
" See the example below.
"
" Redefine the function, IsPersonalEmailRecipient, which takes an email address
" and returns true if the `personal' email address is appropriate and false
" if not. The default in this file check the address against an abook
" datafile but this presumes that separate datafiles are used for personal
" and professional contacts.
"
" Call CheckSenderEmailAddress() when editing an email to verify the sender
" address. This works best if automated (possibly by adding the line
"     call CheckSenderEmailAddress()
" to $RUNTIME/ftplugins/mail.vim).
"
" The script will prompt for email address selection if the `personal' (i.e.
" first) address is being used for a `non-personal' (i.e.
" IsPersonalEmailRecipient returns false) recipient. This is why the
" personal address must be made the default in Mutt. Use Mutt's send-hook
" feature to automatically choose other from addresses. The script will not
" prompt when such an address is not the first in the list.
"
" Obviously there is room to generalise and improve these simple scripts.
"
" List of sender addresses. The first one is for `personal' emails.
"
" Override this.
if !exists("SenderEmailAddresses")
    let SenderEmailAddresses = []
    call add(SenderEmailAddresses, 'me@home.com')
    call add(SenderEmailAddresses, 'me@work.com')
    call add(SenderEmailAddresses, 'me@jobtwo.com')
endif

" Returns true if the given email address is `personal'. Any method will do.
" I use two abook databases; everyone in the default database counts as a
" personal entry.
"
" Override this.
if !exists("IsPersonalEmailRecipient")
function IsPersonalEmailRecipient(emailaddress)
    call system(join(['abook', '--mutt-query', a:emailaddress]))
    return v:shell_error == 0
endfunction
endif

" Return the line number of the first match for the given mail field name,
" or 0 if no such field is found.
if !exists("*s:GetHeaderLine")
function s:GetHeaderLine(field)
    let save_cursor = getpos(".")
    let result = 0

    call setpos('.', [0, 1, 1, 0])
    if search(join(['^', a:field, ':'], ''), 'c')
	let result = line('.')
    endif

    call setpos('.', save_cursor)
    return result
endfunction
endif

" Extract and return the first email address from the given line.
" Expect this line to begin with "To: " and to contain one or more
" recipients delimited by commas. A string from between angle brackets
" is returned if given.
if !exists("*s:GetFirstToAddress")
function s:GetFirstToAddress()
    let tolinenum = s:GetHeaderLine('To')
    if tolinenum == 0
	return ''
    endif

    let toline = substitute(getline(tolinenum), "\"[^\"]*\"", "", "g")
    try
	let [f, firstrecp; rest] = matchlist(toline, '^To: *\([^,]*\) *')
    catch /E688:/
	return ""
    endtry
    "echo "firstrecp:" firstrecp ":"

    try
	let [f, firstaddr; rest] = matchlist(firstrecp, '<\(.*\)>')
    catch /E688:/
	let firstaddr = firstrecp
    endtry
    "echo "firstaddr:" firstaddr ":"

    return firstaddr
endfunction
endif

" Look for a 'From:' mail header and read an email address:
"		From: Name <address>
" If it matches the first entry in g:SenderEmailAddresses then the first
" recipient address is read from the 'To:' mail header. If this address is
" not a `personal address' then the user is prompted to choose one of the
" addresses from g:SenderEmailAddresses.
if !exists("CheckSenderEmailAddress")
function CheckSenderEmailAddress()
    let fromlinenum = s:GetHeaderLine('From')
    if fromlinenum == 0
	return
    endif

    try
	let [fromline, fromaddr; rest] = matchlist(getline(fromlinenum), '^From: .*<\(.*\)>')
    catch /E688:/
	return
    endtry

    if (fromaddr != g:SenderEmailAddresses[0])
	return
    endif

    let toaddr = s:GetFirstToAddress()
    if IsPersonalEmailRecipient(toaddr)
	return
    endif

    let choices = ['From address:']
    let i = 0
    for entry in g:SenderEmailAddresses
	call add(choices, printf("%d. %s", i + 1, g:SenderEmailAddresses[i]))
	let i = i + 1
    endfor

    let fromidx = inputlist(choices)
    if fromidx == 0
	return
    endif

    let newaddr = join(['<', g:SenderEmailAddresses[fromidx - 1], '>'], '')
    call setline(fromlinenum, substitute(fromline, '<.*>', newaddr , ''))
endfunction
endif

