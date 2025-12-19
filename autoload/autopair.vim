vim9script

const Go = "\<C-G>U"
const GoLeft = Go .. "\<LEFT>"
const GoRight = Go .. "\<RIGHT>"

def Left(s: string): string
	return repeat(GoLeft, strchars(s))
enddef

def Right(s: string): string
	return repeat(GoRight, strchars(s))
enddef

def Delete(s: string): string
	return repeat("\<DEL>", strchars(s))
enddef

def Backspace(s: string): string
	return repeat("\<BS>", strchars(s))
enddef

# split text to two part
# returns [orig, text_before_open, open]
def MatchEnd(text: string, open: string): list<string>
	const m = matchstr(text, '\V' .. open .. '\v$')
	if m == ""
		return []
	endif
	return [text, strpart(text, 0, len(text) - len(m)), m]
enddef

# returns [orig, close, text_after_close]
def MatchBegin(text: string, close: string): list<string>
    const close_len = len(close)
    # On compare les N premiers caractères
    if text[: close_len - 1] ==# close
        return [text, close, text[close_len :]]
    endif
    return []
enddef

def Getline(): list<string>
	var line = getline('.')
	var pos = col('.') - 1
	var before = strpart(line, 0, pos)
	var after = strpart(line, pos)
	var afterline = after
	if g:AutoPairsMultilineClose
		var n = line('$')
		var i = line('.') + 1
		while i <= n
			line = getline(i)
			after = after .. ' ' .. line
			if !(line =~ '\v^\s*$')
				break
			endif
			i = i + 1
		endwhile
	endif
	return [before, after, afterline]
enddef

export def AutoPairsDefaultPairs(): dict<string>
	if exists('b:autopairs_defaultpairs')
		return b:autopairs_defaultpairs
	endif
	var r = copy(g:AutoPairs)
	var allPairs = {
				\ 'vim': {'\v^\s*\zs"': ''},
				\ 'rust': {'\w\zs<': '>', '&\zs''': ''},
				\ 'php': {'<?': '?>//k]', '<?php': '?>//k]'}
				\ }
	for [filetype, pairs] in items(allPairs)
		if &filetype == filetype
			for [open, close] in items(pairs)
				r[open] = close
			endfor
		endif
	endfor
	b:autopairs_defaultpairs = r
	return r
enddef

export def AutoPairsJump()
	call search('["\]'')}]','W')
enddef

export def AutoPairsInsert(key: string): string
    if !get(b:, 'autopairs_enabled', true)
        return key
    endif

    b:autopairs_saved_pair = [key, getpos('.')]

    var [before, after, afterline] = Getline()

    if !empty(before) && before[-1 : -1] == '\'
        return key
    endif

    for [open, close, opt] in b:AutoPairsList
        var ms = MatchEnd(before .. key, open)
        var m = matchstr(afterline, '^\v\s*\zs\V' .. close)

        if !empty(ms)
            var target = ms[1]
            var openPair = ms[2]

            if strchars(openPair) == 1 && m == openPair
                break
            endif

            var bs = ''
            var del = ''

            while strchars(before) > strchars(target)
                var found = false
                for [o, c, o_opt] in b:AutoPairsList
                    var os = MatchEnd(before, o)
                    if !empty(os) && strchars(os[1]) < strchars(target)
                        continue
                    endif

                    var cs = MatchBegin(afterline, c)
                    if !empty(os) && !empty(cs)
                        found = true
                        before = os[1]
                        afterline = cs[2]
                        bs ..= Backspace(os[2])
                        del ..= Delete(cs[1])
                        break
                    endif
                endfor

                if !found
                    var char_ms = MatchEnd(before, '\v.')
                    if !empty(char_ms)
                        before = char_ms[1]
                        bs ..= Backspace(char_ms[2])
                    endif
                endif
            endwhile

            return bs .. del .. openPair .. close .. Left(close)
        endif
    endfor

    for [open, close, opt_any] in b:AutoPairsList
        var opt: dict<any> = opt_any
        if empty(close) | continue | endif

        if key == get(g:, 'AutoPairsWildClosedPair', '') || (opt.mapclose && opt.key == key)
            var m = matchstr(afterline, '^\v\s*\V' .. close)
            if m != ''
                if before =~ '\V' .. open .. '\v\s*$' && m[0] =~ '\v\s'
                    return "\<DEL>" .. Right(m[1 : ])
                else
                    return Right(m)
                endif
            endif

            var m_after = matchstr(after, '^\v\s*\zs\V' .. close)
            if m_after != ''
                if key == get(g:, 'AutoPairsWildClosedPair', '') || opt.multiline
                    if get(b:, 'autopairs_return_pos', 0) == line('.') && getline('.') =~ '^\s*$'
                        normal! ddk$
                    endif
                    search(m_after, 'We')
                    return "\<Right>"
                else
                    break
                endif
            endif
        endif
    endfor

	if get(g:, 'AutoPairsFlyMode', 0) != 0 && key =~ '\v[\}\]\)]'
        if search(key, 'We') > 0
            return "\<Right>"
        endif
    endif

    return key
enddef


export def AutoPairsToggle(): string
	if b:autopairs_enabled
		b:autopairs_enabled = 0
		echo 'AutoPairs Disabled.'
	else
		b:autopairs_enabled = 1
		echo 'AutoPairs Enabled.'
	endif
	return ''
enddef

export def AutoPairsDelete(): string
	if !b:autopairs_enabled
		return "\<BS>"
	endif

	var [before, after, ig] = Getline()
	for [open, close, opt] in b:AutoPairsList
		var b = matchstr(before, '\V' .. open .. '\v\s?$')
		var a = matchstr(after, '^\v\s*\V' .. close)
		if b != '' && a != ''
			if b[-1 : -1] == ' '
				if a[0] == ' '
					return "\<BS>\<DELETE>"
				else
					return "\<BS>"
				endif
			endif
			return Backspace(b) .. Delete(a)
		endif
	endfor

	return "\<BS>"
enddef

export def AutoPairsReturn(): string
	if b:autopairs_enabled == 0
		return ''
	endif
	b:autopairs_return_pos = 0
	var before = getline(line('.') - 1)
	var [_, _, afterline] = Getline()
	var cmd = ''
	for [open, close, opt] in b:AutoPairsList
		if close == ''
			continue
		endif

		if before =~ '\V' .. open .. '\v\s*$' && afterline =~ '^\s*\V' .. close
			b:autopairs_return_pos = line('.')
			if g:AutoPairsCenterLine && winline() * 3 >= winheight(0) * 2
	# Recenter before adding new line to avoid replacing line content
				cmd = "zz"
			endif

	# If equalprg has been set, then avoid call =
	# https://github.com/jiangmiao/auto-pairs/issues/24
			if &equalprg != ''
				return "\<ESC>" .. cmd .. "O"
			endif

	# conflict with javascript and coffee
	# javascript   need   indent new line
	# coffeescript forbid indent new line
			if &filetype == 'coffeescript' || &filetype == 'coffee'
				return "\<ESC>" .. cmd .. "k==o"
			else
				return "\<ESC>" .. cmd .. "=ko"
			endif
		endif
	endfor
	return ''
enddef

export def AutoPairsMoveCharacter(key: string): string
	const c = getline(".")[col(".")-1]
	const escaped_key = substitute(key, "'", "''", 'g')
	return "\<DEL>\<ESC>:call search(" .. "'" .. escaped_key .. "'" .. ")\<CR>a" .. c .. "\<LEFT>"
enddef

export def AutoPairsBackInsert(): string
	const pair = b:autopairs_saved_pair[0]
	const pos  = b:autopairs_saved_pair[1]
	call setpos('.', pos)
	return pair
enddef

# Fast wrap the word in brackets
export def AutoPairsFastWrap(): string
	var c = @"
	normal! x
	var [before, after, ig] = Getline()
	if after[0] =~ '\v[\{\[\(\<]'
		normal! %
		normal! p
	else
		for [open, close, opt] in b:AutoPairsList
			if close == ''
				continue
			endif
			if after =~ '^\s*\V' .. open
				call search(close, 'We')
				normal! p
				@" = c
				return ""
			endif
		endfor
		if after[1 : 1] =~ '\v\w'
			normal! e
			normal! p
		else
			normal! p
		endif
	endif
	@" = c
	return ""
enddef

export def AutoPairsSpace(): string
	if !b:autopairs_enabled
		return "\<SPACE>"
	endif

	var [before, after, ig] = Getline()

	for [open, close, opt] in b:AutoPairsList
		if close == ''
			continue
		endif
		if before =~ '\V' .. open .. '\v$' && after =~ '^\V' .. close
			if close =~ '\v^[''"`]$'
				return "\<SPACE>"
			else
				return "\<SPACE>\<SPACE>" .. GoLeft
			endif
		endif
	endfor
	return "\<SPACE>"
enddef

def ExpandMap(_map: string): string
  var map = substitute(_map, '\(<Plug>\w\+\)', '\=maparg(submatch(1), "i")', 'g')
  return substitute(map, '\(<Plug>([^)]*)\)', '\=maparg(submatch(1), "i")', 'g')
enddef

def AutoPairsMap(_key: string)
	# | is special key which separate map command from text
	var key: string
	if _key == '|'
		key = '<BAR>'
	else
		key = _key
	endif
	const escaped_key = substitute(key, "'", "''", 'g')
	# use expr will cause search() doesn't work
	execute 'inoremap <buffer> <silent> ' .. key .. " <C-R>=autopair#AutoPairsInsert('" .. escaped_key .. "')<CR>"
enddef

def AutoPairsInit()
    b:autopairs_loaded = 1
    b:autopairs_enabled = get(b:, 'autopairs_enabled', 1)
    b:AutoPairs = get(b:, 'AutoPairs', autopair#AutoPairsDefaultPairs())

    b:autopairs_return_pos = 0
	# [char, [bufnum, lnum, col, off]]
	b:autopairs_saved_pair = ['', [0, 0, 0, 0]]
    b:AutoPairsList = []

    for [open, close_full] in items(b:AutoPairs)
        var o = open[-1 : -1]
        var close = close_full
        var opt = {mapclose: 1, multiline: 1, key: ''}

        var m = matchlist(close, '\v(.*)//(.*)$')
        if !empty(m)
            close = m[1]
            if m[2] =~ 'n' | opt.mapclose = 0 | endif
            if m[2] =~ 'm' | opt.multiline = 1 | endif
            if m[2] =~ 's' | opt.multiline = 0 | endif
            var ks = matchlist(m[2], '\vk(.)')
            opt.key = !empty(ks) ? ks[1] : close[0]
        else
            opt.key = close[0]
        endif

        if o == close | opt.multiline = 0 | endif

        AutoPairsMap(o)
        if o != opt.key && opt.key != '' && opt.mapclose
            AutoPairsMap(opt.key)
        endif

        add(b:AutoPairsList, [open, close, opt])
    endfor

    sort(b:AutoPairsList, (i1, i2) => len(i2[0]) - len(i1[0]))

	for key in split(get(g:, 'AutoPairsMoveCharacter', ''), '\s*')
		const escaped_key = substitute(key, "'", "''", 'g')
		execute 'inoremap <silent> <buffer> <M-' .. key .. "> <C-R>=autopair#AutoPairsMoveCharacter('" .. escaped_key .. "')<CR>"
	endfor

	if get(g:, 'AutoPairsMapBS', 0)
		execute 'inoremap <buffer> <silent> <BS> <C-R>=autopair#AutoPairsDelete()<CR>'
	endif

	if get(g:, 'AutoPairsMapCh', 0)
		execute 'inoremap <buffer> <silent> <C-h> <C-R>=autopair#AutoPairsDelete()<CR>'
	endif

	if get(g:, 'AutoPairsMapSpace', 0)
		const do_abbrev = "<C-]>"
		execute 'inoremap <buffer> <silent> <SPACE> ' .. do_abbrev .. '<C-R>=autopair#AutoPairsSpace()<CR>'
	endif

	if g:AutoPairsShortcutFastWrap != ''
		execute 'inoremap <buffer> <silent> ' .. g:AutoPairsShortcutFastWrap .. ' <C-R>=autopair#AutoPairsFastWrap()<CR>'
	endif

	if g:AutoPairsShortcutBackInsert != ''
		execute 'inoremap <buffer> <silent> ' .. g:AutoPairsShortcutBackInsert .. ' <C-R>=autopair#AutoPairsBackInsert()<CR>'
	endif

	if g:AutoPairsShortcutToggle != ''
		execute 'inoremap <buffer> <silent> <expr> ' .. g:AutoPairsShortcutToggle .. ' AutoPairsToggle()'
		execute 'noremap <buffer> <silent> ' .. g:AutoPairsShortcutToggle .. ' :call autopair#AutoPairsToggle()<CR>'
	endif

	if g:AutoPairsShortcutJump != ''
		execute 'inoremap <buffer> <silent> ' .. g:AutoPairsShortcutJump .. ' <ESC>:call autopair#AutoPairsJump()<CR>a'
		execute 'noremap <buffer> <silent> ' .. g:AutoPairsShortcutJump .. ' :call autopair#AutoPairsJump()<CR>'
	endif

	if &keymap != ''
		var imsearch = &imsearch
		var iminsert = &iminsert
		var imdisable = &imdisable
		execute 'setlocal keymap=' .. &keymap
		execute 'setlocal imsearch=' .. imsearch
		execute 'setlocal iminsert=' .. iminsert
		if imdisable
			execute 'setlocal imdisable'
		else
			execute 'setlocal noimdisable'
		endif
	endif
enddef

export def AutoPairsTryInit()
    if exists('b:autopairs_loaded') | return | endif

    if get(g:, 'AutoPairsMapCR', 1)
        var info = maparg('<CR>', 'i', 0, 1)
        var old_cr = ''
        var is_expr = false

        if empty(info)
            old_cr = '<CR>'
        else
            old_cr = info.rhs
            old_cr = ExpandMap(old_cr)
            
            if has_key(info, 'sid')
                old_cr = substitute(old_cr, '<SID>', '<SNR>' .. info.sid .. '_', 'g')
            endif
            is_expr = info.expr
        endif

        if old_cr !~ 'AutoPairsReturn'
            if is_expr
                var wrapper_name = '<Plug>AutoPairsOldCRWrapper'
                execute 'inoremap <buffer> <expr> <script> ' .. wrapper_name .. ' ' .. old_cr
                old_cr = wrapper_name
            endif

            execute 'inoremap <script> <buffer> <silent> <CR> ' .. old_cr .. '<C-R>=autopair#AutoPairsReturn()<CR>'
        endif
    endif

    AutoPairsInit()
enddef
