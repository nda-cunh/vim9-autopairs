vim9script

# Tape `keys` en mode insertion dans un buffer vide de type `ft` et renvoie
# la ligne avec un '|' à la position du curseur.
def Type(ft: string, keys: string): string
	new
	execute 'setlocal filetype=' .. ft
	# comme à l'ouverture d'un fichier : init après la détection du filetype
	unlet! b:autopairs_loaded b:autopairs_defaultpairs b:AutoPairs
	autopair#AutoPairsTryInit()
	feedkeys('i' .. keys .. '|' .. "\<Esc>", 'xt')
	const res = getline(1)
	bwipe!
	return res
enddef

# --- ouverture des paires ---------------------------------------------------

def Test_open_paren()
	assert_equal('(|)', Type('text', '('))
	assert_equal('[|]', Type('text', '['))
	assert_equal('{|}', Type('text', '{'))
enddef

def Test_open_quotes()
	assert_equal('"|"', Type('text', '"'))
	assert_equal("'|'", Type('text', "'"))
	assert_equal('`|`', Type('text', '`'))
enddef

def Test_nested_paren()
	assert_equal('((|))', Type('text', '(('))
	assert_equal('([{|}])', Type('text', '([{'))
enddef

def Test_triple_quotes()
	assert_equal('"""|"""', Type('text', '"""'))
	assert_equal("'''|'''", Type('text', "'''"))
	assert_equal('```|```', Type('text', '```'))
	assert_equal('"""|"""', Type('c', '"""'))
	assert_equal('"""|"""', Type('python', '"""'))
enddef

def Test_escaped_open_not_paired()
	assert_equal('\(|', Type('text', '\('))
	assert_equal('\"|', Type('text', '\"'))
enddef

# --- fermeture : on saute par-dessus ----------------------------------------

def Test_close_jump_paren()
	assert_equal('()|', Type('text', '()'))
	assert_equal('(x)|', Type('text', '(x)'))
	assert_equal('((x))|', Type('text', '((x))'))
enddef

def Test_close_jump_quotes_text()
	assert_equal('""|', Type('text', '""'))
	assert_equal("''|", Type('text', "''"))
	assert_equal('"abc"|', Type('text', '"abc"'))
enddef

def Test_close_jump_quotes_c()
	assert_equal('""|', Type('c', '""'))
	assert_equal("''|", Type('c', "''"))
	assert_equal('"abc"|', Type('c', '"abc"'))
	assert_equal("'a'|", Type('c', "'a'"))
enddef

def Test_close_jump_quotes_python()
	assert_equal('""|', Type('python', '""'))
	assert_equal('"abc"|', Type('python', '"abc"'))
enddef

# --- échappements -----------------------------------------------------------

def Test_escape_char_c()
	assert_equal("'\\0'|", Type('c', "'\\0'"))
	assert_equal("'\\n'|", Type('c', "'\\n'"))
	assert_equal("'\\''|", Type('c', "'\\''"))
	assert_equal("'\\\\'|", Type('c', "'\\\\'"))
enddef

def Test_escape_string_c()
	assert_equal('"\n"|', Type('c', '"\n"'))
	assert_equal('"a\"b"|', Type('c', '"a\"b"'))
	assert_equal('"\\"|', Type('c', '"\\"'))
enddef

def Test_escape_text()
	assert_equal("'\\0'|", Type('text', "'\\0'"))
	assert_equal('"\n"|', Type('text', '"\n"'))
enddef

# --- syntaxe ignorée (string / commentaire) ---------------------------------

def Test_no_pair_inside_string_c()
	assert_equal('"(x|"', Type('c', '"(x'))
enddef

def Test_no_pair_inside_comment_c()
	assert_equal('// (|', Type('c', '// ('))
enddef

def Test_vim_comment_quote()
	assert_equal('"|', Type('vim', '"'))
enddef

# --- backspace / espace -----------------------------------------------------

def Test_backspace_deletes_pair()
	assert_equal('|', Type('text', "(\<BS>"))
	assert_equal('|', Type('text', "\"\<BS>"))
	assert_equal('|', Type('text', "[\<BS>"))
enddef

def Test_space_inside_paren()
	assert_equal('( | )', Type('text', '( '))
	assert_equal('" |"', Type('text', '" '))
enddef
