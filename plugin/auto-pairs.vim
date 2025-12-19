vim9script noclear
# Insert or delete brackets, parens, quotes in pairs.
# Maintainer:  nda-cunh <hydraldev@gmail.com> 
# Original Maintainer JiangMiao <jiangfriend@gmail.com>, camthompson
# Version: 2.0.0
# Homepage: http://www.vim.org/scripts/script.php?script_id=3599
# License: MIT

if exists('g:AutoPairsLoaded') || &cp
	finish
endif

g:AutoPairsLoaded = 1

if !exists('g:AutoPairs')
	g:AutoPairs = { '(': ')', '[': ']', '{': '}', "'": "'", '"': '"', '```': '```', '"""': '"""', "'''": "'''", '`': '`' }
endif

g:AutoPairsMapBS = get(g:, 'AutoPairsMapBS', 1)
g:AutoPairsMapBS = get(g:, 'AutoPairsMapBS', 1)
# Map <C-h> as the same BS
g:AutoPairsMapCh = get(g:, 'AutoPairsMapCh', 1)
g:AutoPairsMapCR = get(g:, 'AutoPairsMapCR', 1)
g:AutoPairsWildClosedPair = get(g:, 'AutoPairsWildClosedPair', '')
g:AutoPairsMapSpace = get(g:, 'AutoPairsMapSpace', 1)
g:AutoPairsCenterLine = get(g:, 'AutoPairsCenterLine', 1)
g:AutoPairsShortcutToggle = get(g:, 'AutoPairsShortcutToggle', '<M-p>')
g:AutoPairsShortcutFastWrap = get(g:, 'AutoPairsShortcutFastWrap', '<M-e>')
g:AutoPairsMoveCharacter = get(g:, 'AutoPairsMoveCharacter', "()[]{}\"'")
g:AutoPairsShortcutJump = get(g:, 'AutoPairsShortcutJump', '<M-n>')

# Fly mode will for closed pair to jump to closed pair instead of insert.
# also support AutoPairsBackInsert to insert pairs where jumped.
g:AutoPairsFlyMode = get(g:, 'AutoPairsFlyMode', 0)

# When skipping the closed pair, look at the current and
# next line as well.
g:AutoPairsMultilineClose = get(g:, 'AutoPairsMultilineClose', 1)

# Work with Fly Mode, insert pair where jumped
g:AutoPairsShortcutBackInsert = get(g:, 'AutoPairsShortcutBackInsert', '<M-b>')
g:AutoPairsSmartQuotes = get(g:, 'AutoPairsSmartQuotes', 1)

# add or delete pairs base on g:AutoPairs
# AutoPairsDefine(addPairs:dict[, removeOpenPairList:list])
#
# eg:
#   au FileType html let b:AutoPairs = AutoPairsDefine({'<!--' : '-->'}, ['{'])
#   add <!-- --> pair and remove '{' for html file
def g:AutoPairsDefine(pairs: dict<string>, ...remove_list: list<list<string>>): dict<string>
    var r = copy(autopair#AutoPairsDefaultPairs())

    if !empty(remove_list)
        for open_key in remove_list[0]
            if has_key(r, open_key)
                remove(r, open_key)
            endif
        endfor
    endif
    extend(r, pairs)
    return r
enddef

def g:AutoPairsToggle(): string
	return autopair#AutoPairsToggle()
enddef

inoremap <silent> <SID>autopair#AutoPairsReturn <C-R>=autopair#AutoPairsReturn()<CR>
imap <script> <Plug>AutoPairsReturn <SID>autopair#AutoPairsReturn

au BufEnter * :call autopair#AutoPairsTryInit()
