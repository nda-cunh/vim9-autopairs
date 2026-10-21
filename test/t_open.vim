vim9script
import './helpers.vim' as H

# --- ouverture simple -------------------------------------------------------

def Test_open_paren()
	assert_equal('(|)', H.T('text', '|', '('))
	assert_equal('[|]', H.T('text', '|', '['))
	assert_equal('{|}', H.T('text', '|', '{'))
enddef

def Test_open_quotes()
	assert_equal('"|"', H.T('text', '|', '"'))
	assert_equal("'|'", H.T('text', '|', "'"))
	assert_equal('`|`', H.T('text', '|', '`'))
enddef

def Test_open_after_text()
	assert_equal('foo(|)', H.T('text', 'foo|', '('))
	assert_equal('a = [|]', H.T('text', 'a = |', '['))
	assert_equal('x = "|"', H.T('text', 'x = |', '"'))
enddef

def Test_open_in_middle_of_line()
	assert_equal('a(|)b', H.T('text', 'a|b', '('))
	assert_equal('a[|] b', H.T('text', 'a| b', '['))
enddef

def Test_open_keeps_following_lines()
	assert_equal(['(|)', 'second', 'third'], H.M('text', ['|', 'second', 'third'], '('))
	assert_equal(['first', 'x{|}', 'third'], H.M('text', ['first', 'x|', 'third'], '{'))
enddef

def Test_open_with_indent()
	assert_equal("\tf(|)", H.T('text', "\tf|", '('))
	assert_equal('    f(|)', H.T('text', '    f|', '('))
enddef

# --- imbrication ------------------------------------------------------------

def Test_nested_same()
	assert_equal('((|))', H.T('text', '|', '(('))
	assert_equal('(((|)))', H.T('text', '|', '((('))
	assert_equal('[[|]]', H.T('text', '|', '[['))
	assert_equal('{{|}}', H.T('text', '|', '{{'))
enddef

def Test_nested_mixed()
	assert_equal('([{|}])', H.T('text', '|', '([{'))
	assert_equal('{[(|)]}', H.T('text', '|', '{[('))
	assert_equal('("|")', H.T('text', '|', '("'))
	assert_equal("['|']", H.T('text', '|', "['"))
enddef

def Test_open_inside_existing_pair()
	assert_equal('([|])', H.T('text', '(|)', '['))
	assert_equal('f(a, [|])', H.T('text', 'f(a, |)', '['))
enddef

# --- triples ----------------------------------------------------------------

def Test_triple_quotes_text()
	assert_equal('"""|"""', H.T('text', '|', '"""'))
	assert_equal("'''|'''", H.T('text', '|', "'''"))
	assert_equal('```|```', H.T('text', '|', '```'))
enddef

def Test_triple_quotes_c()
	assert_equal('"""|"""', H.T('c', '|', '"""'))
enddef

def Test_triple_quotes_python()
	assert_equal('"""|"""', H.T('python', '|', '"""'))
	assert_equal("'''|'''", H.T('python', '|', "'''"))
	assert_equal('x = """|"""', H.T('python', 'x = |', '"""'))
enddef

def Test_triple_backtick_markdown()
	assert_equal('```|```', H.T('markdown', '|', '```'))
enddef

def Test_triple_quotes_content_and_close()
	assert_equal('"""abc"""|', H.T('text', '|', '"""abc"""'))
	assert_equal('"""abc"""|', H.T('python', '|', '"""abc"""'))
	assert_equal('```sh```|', H.T('text', '|', '```sh```'))
enddef

# --- échappement ------------------------------------------------------------

def Test_escaped_open_not_paired()
	assert_equal('\(|', H.T('text', '|', '\('))
	assert_equal('\[|', H.T('text', '|', '\['))
	assert_equal('\{|', H.T('text', '|', '\{'))
	assert_equal('\"|', H.T('text', '|', '\"'))
	assert_equal("\\'|", H.T('text', '|', "\\'"))
	assert_equal('\`|', H.T('text', '|', '\`'))
enddef

def Test_double_backslash_is_not_escape()
	assert_equal('\\(|)', H.T('text', '|', '\\('))
	assert_equal('\\"|"', H.T('text', '|', '\\"'))
enddef

def Test_triple_backslash_is_escape()
	assert_equal('\\\(|', H.T('text', '|', '\\\('))
enddef

# --- multibyte --------------------------------------------------------------

def Test_multibyte_before()
	assert_equal('é(|)', H.T('text', 'é|', '('))
	assert_equal('日本"|"', H.T('text', '日本|', '"'))
enddef

def Test_multibyte_inside_and_close()
	assert_equal('(é)|', H.T('text', '|', '(é)'))
	assert_equal('"日本語"|', H.T('text', '|', '"日本語"'))
	assert_equal('[→]|', H.T('text', '|', '[→]'))
enddef

def Test_multibyte_after()
	assert_equal('(|)é', H.T('text', '|é', '('))
enddef

# --- undo / redo ------------------------------------------------------------

def Test_undo_removes_whole_insert()
	H.Open('text')
	feedkeys("i(abc)\<Esc>u", 'xt')
	assert_equal([''], getline(1, '$'))
	H.Close()
enddef

def Test_dot_repeat()
	H.Open('text')
	feedkeys("A(x)\<Esc>.", 'xt')
	assert_equal(['(x)(x)'], getline(1, '$'))
	H.Close()
enddef
