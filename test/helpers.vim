vim9script

# Ouvre un buffer de type `ft` contenant `lines`, où le premier '|' marque la
# position du curseur. `vars` est appliqué à b: avant l'init du plugin (ex:
# {AutoPairs: {'<': '>'}}).
export def Open(ft: string, lines: list<string> = ['|'], vars: dict<any> = {})
	const lnum = match(lines, '|') + 1
	const text = lines[lnum - 1]
	const col = stridx(text, '|') + 1
	var content = copy(lines)
	content[lnum - 1] = strpart(text, 0, col - 1) .. strpart(text, col)

	# comme à l'ouverture d'un fichier : contenu, filetype, puis init
	new
	setline(1, content)
	execute 'setlocal filetype=' .. ft
	unlet! b:autopairs_loaded b:autopairs_defaultpairs b:AutoPairs
	for [k, v] in items(vars)
		setbufvar('', k, v)
	endfor
	autopair#AutoPairsTryInit()
	cursor(lnum, col)
	# le curseur ne peut pas être après la fin de ligne en mode normal
	b:test_append = col > strlen(content[lnum - 1]) && col > 1
enddef

# Tape `keys` en mode insertion puis renvoie le buffer avec '|' au curseur.
export def Type(keys: string): list<string>
	const start = get(b:, 'test_append', false) ? 'a' : 'i'
	b:test_append = false
	feedkeys(start .. keys .. '|' .. "\<Esc>", 'xt')
	return getline(1, '$')
enddef

# Exécute `keys` en mode normal puis renvoie le buffer avec '|' au curseur.
export def Normal(keys: string): list<string>
	feedkeys(keys, 'xt')
	var lines = getline(1, '$')
	const l = line('.') - 1
	lines[l] = strpart(lines[l], 0, col('.') - 1) .. '|' .. strpart(lines[l], col('.') - 1)
	return lines
enddef

export def Close()
	bwipe!
enddef

# Raccourci : une seule ligne, renvoie une string.
export def T(ft: string, init: string, keys: string, vars: dict<any> = {}): string
	Open(ft, [init], vars)
	const res = Type(keys)
	Close()
	return join(res, "\n")
enddef

# Raccourci multi-ligne.
export def M(ft: string, init: list<string>, keys: string, vars: dict<any> = {}): list<string>
	Open(ft, init, vars)
	const res = Type(keys)
	Close()
	return res
enddef
