setlocal et sts=2 sw=2 tw=80 list lcs=tab:>>

syn clear

syn match lusStatement "=\|;"
syn match default '[a-zA-Z_][a-zA-Z0-9_]*'
syn keyword Type int real bool
syn keyword Control if else then with
syn keyword Node node const include type let var returns
syn match   Node "tel."
syn match   Node "tel"
syn keyword Commands pre fby current merge when and or xor not mod
syn match Commands "->"
syn keyword Constant true false
syn match Constant "[-]\d*[\.]\d"
syn match Constant "\d*[\.]\d*"

syn region Comment start="--" end="$"
syn region Comment start="(\*" end="\*)" excludenl
syn region Comment start="/\*" end="\*/" excludenl

hi def link lusStatement Statement
hi def link Node Statement
hi def link Commands keyword
hi def link control keyword

hi link Control Commands 

