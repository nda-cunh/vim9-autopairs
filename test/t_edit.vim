vim9script
import './helpers.vim' as H

# --- backspace --------------------------------------------------------------

def Test_bs_deletes_empty_pair()
	for p in ['()', '[]', '{}', '""', "''", '``']
		assert_equal('|', H.T('text', p[0] .. '|' .. p[1], "\<BS>"), p)
	endfor
enddef

def Test_bs_deletes_pair_just_typed()
	assert_equal('|', H.T('text', '|', "(\<BS>"))
	assert_equal('|', H.T('text', '|', "\"\<BS>"))
	assert_equal('foo|', H.T('text', 'foo|', "[\<BS>"))
enddef

def Test_ctrl_h_deletes_pair()
	assert_equal('|', H.T('text', '(|)', "\<C-h>"))
enddef

def Test_bs_nested()
	assert_equal('(|)', H.T('text', '((|))', "\<BS>"))
	assert_equal('|', H.T('text', '((|))', "\<BS>\<BS>"))
enddef

def Test_bs_inside_spaces()
	assert_equal('(|)', H.T('text', '( | )', "\<BS>"))
	assert_equal('|', H.T('text', '(| )', "\<BS>"))
enddef

def Test_bs_triple_quotes()
	assert_equal('|', H.T('text', '"""|"""', "\<BS>"))
enddef

def Test_bs_non_empty_pair()
	assert_equal('(|)', H.T('text', '(x|)', "\<BS>"))
	assert_equal('"ab|"', H.T('text', '"abc|"', "\<BS>"))
enddef

def Test_bs_normal_text()
	assert_equal('ab|', H.T('text', 'abc|', "\<BS>"))
	assert_equal('a|c', H.T('text', 'ab|c', "\<BS>"))
	assert_equal('|', H.T('text', 'a|', "\<BS>"))
enddef

def Test_bs_after_closed_pair()
	assert_equal('(|', H.T('text', '()|', "\<BS>"))
	assert_equal('"|', H.T('text', '""|', "\<BS>"))
enddef

def Test_bs_only_opening_char()
	assert_equal('|abc', H.T('text', '(|abc', "\<BS>"))
enddef

def Test_bs_multibyte()
	assert_equal('é|', H.T('text', 'éa|', "\<BS>"))
	assert_equal('(|)', H.T('text', '(é|)', "\<BS>"))
enddef

def Test_bs_join_lines()
	assert_equal(['a|b'], H.M('text', ['a', '|b'], "\<BS>"))
enddef

# --- espace -----------------------------------------------------------------

def Test_space_inside_brackets()
	assert_equal('( | )', H.T('text', '(|)', ' '))
	assert_equal('[ | ]', H.T('text', '[|]', ' '))
	assert_equal('{ | }', H.T('text', '{|}', ' '))
enddef

def Test_space_inside_quotes_single()
	assert_equal('" |"', H.T('text', '"|"', ' '))
	assert_equal("' |'", H.T('text', "'|'", ' '))
enddef

def Test_space_normal()
	assert_equal('a |', H.T('text', 'a|', ' '))
	assert_equal('a | b', H.T('text', 'a| b', ' '))
	assert_equal('(a |)', H.T('text', '(a|)', ' '))
enddef

def Test_space_then_type()
	assert_equal('{ x| }', H.T('text', '|', '{ x'))
	assert_equal('{ x }|', H.T('text', '|', '{ x}'))
enddef

def Test_space_abbreviation_still_works()
	H.Open('text')
	iabbrev <buffer> teh the
	const res = H.Type('teh ')
	H.Close()
	assert_equal(['the |'], res)
enddef

# --- entrée -----------------------------------------------------------------

def Test_cr_between_braces_c()
	assert_equal(['{', "\t|", '}'], H.M('c', ['{|}'], "\<CR>"))
enddef

def Test_cr_between_braces_function_c()
	assert_equal(['int main(void)', '{', "\t|", '}'],
		H.M('c', ['int main(void)', '{|}'], "\<CR>"))
enddef

def Test_cr_between_brackets()
	# l'indentation dépend du filetype, on vérifie juste la structure
	for [ft, init, last] in [['c', '(|)', ')'], ['c', '[|]', ']'], ['python', 'x = [|]', ']']]
		const res = H.M(ft, [init], "\<CR>")
		assert_equal(3, len(res), ft .. ' ' .. init)
		assert_match('^\s*|$', res[1], ft .. ' ' .. init)
		assert_match('^\s*\V' .. last .. '\v$', res[2], ft .. ' ' .. init)
	endfor
enddef

def Test_cr_typed_pair_then_cr()
	assert_equal(['if (x) {', "\t|", '}'], H.M('c', ['|'], "if (x) {\<CR>"))
enddef

def Test_cr_then_text_then_close()
	assert_equal(['{', "\tx;", '}|'], H.M('c', ['|'], "{\<CR>x;\<Esc>jA"))
enddef

def Test_cr_normal_line()
	assert_equal(['abc', '|'], H.M('text', ['abc|'], "\<CR>"))
	assert_equal(['a', '|b'], H.M('text', ['a|b'], "\<CR>"))
enddef

def Test_cr_keeps_other_lines()
	assert_equal(['before', '{', "\t|", '}', 'after'],
		H.M('c', ['before', '{|}', 'after'], "\<CR>"))
enddef

def Test_cr_nested_braces()
	assert_equal(['{', "\t{", "\t\t|", "\t}", '}'], H.M('c', ['|'], "{\<CR>{\<CR>"))
enddef
