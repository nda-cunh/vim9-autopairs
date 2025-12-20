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

g:AutoPairsLoaded = true

if !exists('g:AutoPairs')
	g:AutoPairs = { '(': ')', '[': ']', '{': '}', "'": "'", '"': '"', '```': '```', '"""': '"""', "'''": "'''", '`': '`' }
endif

g:AutoPairsEnabled = get(g:, 'AutoPairsEnabled', true)
g:AutoPairsMapBS = get(g:, 'AutoPairsMapBS', true)
g:AutoPairsMapBS = get(g:, 'AutoPairsMapBS', true)
# Map <C-h> as the same BS
g:AutoPairsMapCh = get(g:, 'AutoPairsMapCh', true)
g:AutoPairsMapCR = get(g:, 'AutoPairsMapCR', true)
g:AutoPairsWildClosedPair = get(g:, 'AutoPairsWildClosedPair', '')
g:AutoPairsMapSpace = get(g:, 'AutoPairsMapSpace', true)
g:AutoPairsCenterLine = get(g:, 'AutoPairsCenterLine', true)
g:AutoPairsShortcutToggle = get(g:, 'AutoPairsShortcutToggle', '<M-p>')
g:AutoPairsShortcutFastWrap = get(g:, 'AutoPairsShortcutFastWrap', '<M-e>')
g:AutoPairsMoveCharacter = get(g:, 'AutoPairsMoveCharacter', "()[]{}\"'")
g:AutoPairsShortcutJump = get(g:, 'AutoPairsShortcutJump', '<M-n>')

# Fly mode will for closed pair to jump to closed pair instead of insert.
# also support AutoPairsBackInsert to insert pairs where jumped.
g:AutoPairsFlyMode = get(g:, 'AutoPairsFlyMode', false)

# When skipping the closed pair, look at the current and
# next line as well.
g:AutoPairsMultilineClose = get(g:, 'AutoPairsMultilineClose', true)

# Work with Fly Mode, insert pair where jumped
g:AutoPairsShortcutBackInsert = get(g:, 'AutoPairsShortcutBackInsert', '<M-b>')
g:AutoPairsSmartQuotes = get(g:, 'AutoPairsSmartQuotes', true)

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

# Enable the autocmd to initialize AutoPairs on BufEnter
def g:AutoPairsEnable()
	inoremap <silent> <SID>autopair#AutoPairsReturn <C-R>=autopair#AutoPairsReturn()<CR>
	imap <script> <Plug>AutoPairsReturn <SID>autopair#AutoPairsReturn
	augroup AutoPairs
		autocmd!
		au BufEnter * :call autopair#AutoPairsTryInit()
	augroup END
	if !exists('b:autopairs_enabled')
		call autopair#AutoPairsTryInit()
	else
		b:autopairs_enabled = 1
	endif
enddef

def g:AutoPairsDisable()
	silent! imapclear <Plug>AutoPairsReturn
	silent! autocmd! AutoPairs
	if exists('b:autopairs_enabled')
		b:autopairs_enabled = 0
	endif
enddef

if g:AutoPairsEnabled == true
	call g:AutoPairsEnable()
endif
