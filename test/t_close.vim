vim9script
import './helpers.vim' as H

# --- on saute par-dessus le caractère fermant -------------------------------

def Test_close_jump_empty()
	assert_equal('()|', H.T('text', '|', '()'))
	assert_equal('[]|', H.T('text', '|', '[]'))
	assert_equal('{}|', H.T('text', '|', '{}'))
enddef

def Test_close_jump_with_content()
	assert_equal('(x)|', H.T('text', '|', '(x)'))
	assert_equal('f(a, b)|', H.T('text', '|', 'f(a, b)'))
	assert_equal('[1, 2, 3]|', H.T('text', '|', '[1, 2, 3]'))
enddef

def Test_close_jump_nested()
	assert_equal('((x))|', H.T('text', '|', '((x))'))
	assert_equal('([{x}])|', H.T('text', '|', '([{x}])'))
	assert_equal('f(g(h()))|', H.T('text', '|', 'f(g(h()))'))
enddef

def Test_close_jump_partial()
	assert_equal('((x)|)', H.T('text', '|', '((x)'))
	assert_equal('f(g()|)', H.T('text', '|', 'f(g()'))
enddef

def Test_close_jump_existing_text()
	assert_equal('(abc)|', H.T('text', '(abc|)', ')'))
	assert_equal('[abc]| tail', H.T('text', '[abc|] tail', ']'))
enddef

def Test_close_jump_over_spaces()
	assert_equal('( x )|', H.T('text', '|', '( x)'))
	assert_equal('(x )|', H.T('text', '(x| )', ')'))
enddef

def Test_close_without_pair_inserts()
	assert_equal('abc)|', H.T('text', 'abc|', ')'))
	assert_equal(']|', H.T('text', '|', ']'))
	assert_equal('}|', H.T('text', '|', '}'))
enddef

def Test_close_different_char_inserts()
	assert_equal('(]|)', H.T('text', '(|)', ']'))
enddef

# --- guillemets -------------------------------------------------------------

def Test_quote_double_tap()
	assert_equal('""|', H.T('text', '|', '""'))
	assert_equal("''|", H.T('text', '|', "''"))
	assert_equal('``|', H.T('text', '|', '``'))
enddef

def Test_quote_with_content()
	assert_equal('"abc"|', H.T('text', '|', '"abc"'))
	assert_equal("'abc'|", H.T('text', '|', "'abc'"))
	assert_equal('`abc`|', H.T('text', '|', '`abc`'))
	assert_equal('"a b c"|', H.T('text', '|', '"a b c"'))
enddef

def Test_quote_existing_text()
	assert_equal('"abc"|', H.T('text', '"abc|"', '"'))
enddef

def Test_quote_double_tap_c()
	assert_equal('""|', H.T('c', '|', '""'))
	assert_equal("''|", H.T('c', '|', "''"))
	assert_equal('"abc"|', H.T('c', '|', '"abc"'))
	assert_equal("'a'|", H.T('c', '|', "'a'"))
enddef

def Test_quote_double_tap_other_ft()
	for ft in ['cpp', 'python', 'sh', 'javascript', 'lua', 'rust', 'go', 'java', 'vala', 'markdown']
		assert_equal('""|', H.T(ft, '|', '""'), ft)
		assert_equal('"abc"|', H.T(ft, '|', '"abc"'), ft)
	endfor
enddef

def Test_quote_in_call_c()
	assert_equal('f("abc")|', H.T('c', '|', 'f("abc")'))
	assert_equal('f("a", "b")|', H.T('c', '|', 'f("a", "b")'))
	assert_equal("f('a')|", H.T('c', '|', "f('a')"))
enddef

def Test_quote_in_middle_c()
	assert_equal("\tputs(\"\")|;", H.T('c', "\t|;", 'puts("")'))
	assert_equal('printf("%d\n", x)|;', H.T('c', '|;', 'printf("%d\n", x)'))
enddef

# --- fermeture multi-ligne --------------------------------------------------

def Test_close_multiline_no_fly()
	assert_equal(['{', "\t}|", '}'], H.M('text', ['{', "\t|", '}'], '}'))
enddef

def Test_close_multiline_fly()
	g:AutoPairsFlyMode = true
	try
		assert_equal(['{', "\t", '}|'], H.M('text', ['{', "\t|", '}'], '}'))
	finally
		g:AutoPairsFlyMode = false
	endtry
enddef

def Test_close_multiline_fly_same_line_inserts()
	g:AutoPairsFlyMode = true
	try
		assert_equal('(a)|b)', H.T('text', '(a|b)', ')'))
	finally
		g:AutoPairsFlyMode = false
	endtry
enddef
