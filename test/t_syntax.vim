vim9script
import './helpers.vim' as H

# --- C : caractères et échappements -----------------------------------------

def Test_c_char_escapes()
	assert_equal("'\\0'|", H.T('c', '|', "'\\0'"))
	assert_equal("'\\n'|", H.T('c', '|', "'\\n'"))
	assert_equal("'\\t'|", H.T('c', '|', "'\\t'"))
	assert_equal("'\\''|", H.T('c', '|', "'\\''"))
	assert_equal("'\\\\'|", H.T('c', '|', "'\\\\'"))
	assert_equal("'\"'|", H.T('c', '|', "'\"'"))
enddef

def Test_c_char_in_context()
	assert_equal("\ts[i] = '\\0'|;", H.T('c', "\ts[i] = |;", "'\\0'"))
	assert_equal("if (c == '\\0')|", H.T('c', '|', "if (c == '\\0')"))
	assert_equal("f('\\0'|)", H.T('c', 'f(|)', "'\\0'"))
	assert_equal("c = '\\0';|", H.T('c', '|', "c = '\\0';"))
	assert_equal("return ('\\n')|;", H.T('c', 'return |;', "('\\n')"))
enddef

def Test_c_char_existing_line()
	assert_equal(["int\tmain(void)", '{', "\tchar c = '\\0'|;", '}'],
		H.M('c', ["int\tmain(void)", '{', "\tchar c = |;", '}'], "'\\0'"))
enddef

def Test_c_string_escapes()
	assert_equal('"\n"|', H.T('c', '|', '"\n"'))
	assert_equal('"\0"|', H.T('c', '|', '"\0"'))
	assert_equal('"a\"b"|', H.T('c', '|', '"a\"b"'))
	assert_equal('"\\"|', H.T('c', '|', '"\\"'))
	assert_equal('"\\\""|', H.T('c', '|', '"\\\""'))
	assert_equal('"\x41"|', H.T('c', '|', '"\x41"'))
enddef

def Test_c_string_format()
	assert_equal('"%d\n"|', H.T('c', '|', '"%d\n"'))
	assert_equal('printf("%s", s)|', H.T('c', '|', 'printf("%s", s)'))
enddef

# --- C : pas de paire dans les strings --------------------------------------

def Test_c_no_pair_inside_string()
	assert_equal('"(x|"', H.T('c', '|', '"(x'))
	assert_equal('"[x|"', H.T('c', '|', '"[x'))
	assert_equal('"{x|"', H.T('c', '|', '"{x'))
	assert_equal('"a ''|"', H.T('c', '|', '"a '''))
	assert_equal('"a `|"', H.T('c', '|', '"a `'))
enddef

def Test_c_close_inside_string_inserts()
	assert_equal('"a)|"', H.T('c', '|', '"a)'))
enddef

def Test_c_pair_after_string()
	assert_equal('"abc" (|)', H.T('c', '|', '"abc" ('))
	assert_equal('"abc"(|)', H.T('c', '|', '"abc"('))
	assert_equal('"abc", "|"', H.T('c', '|', '"abc", "'))
	assert_equal('f("a", (|))', H.T('c', '|', 'f("a", ('))
	assert_equal("'a' + (|)", H.T('c', '|', "'a' + ("))
enddef

def Test_c_second_string_on_line()
	assert_equal('f("a", "b"|)', H.T('c', 'f(|)', '"a", "b"'))
	assert_equal('f("a", "|")', H.T('c', 'f("a", |)', '"'))
enddef

# --- C : commentaires -------------------------------------------------------

def Test_c_no_pair_in_line_comment()
	assert_equal('// (|', H.T('c', '|', '// ('))
	assert_equal('// "|', H.T('c', '|', '// "'))
	assert_equal("// don'|", H.T('c', '|', "// don'"))
	assert_equal('x; // [|', H.T('c', '|', 'x; // ['))
enddef

def Test_c_no_pair_in_block_comment()
	assert_equal('/* (|', H.T('c', '|', '/* ('))
	assert_equal("/* it'|", H.T('c', '|', "/* it'"))
	assert_equal(['/*', ' * (|', ' */'], H.M('c', ['/*', ' * |', ' */'], '('))
enddef

def Test_c_pair_after_block_comment()
	assert_equal('/* x */ (|)', H.T('c', '|', '/* x */ ('))
enddef

def Test_c_code_still_paired()
	assert_equal('int main(|)', H.T('c', '|', 'int main('))
	assert_equal('a[|]', H.T('c', '|', 'a['))
	assert_equal("\tif (|)", H.T('c', "\t|", 'if ('))
enddef

# --- autres langages --------------------------------------------------------

def Test_python_strings()
	assert_equal('"(x|"', H.T('python', '|', '"(x'))
	assert_equal("'a'|", H.T('python', '|', "'a'"))
	assert_equal('print("hi")|', H.T('python', '|', 'print("hi")'))
	assert_equal('f"{x}"|', H.T('python', '|', 'f"{x}"'))
enddef

def Test_python_comment()
	assert_equal('# (|', H.T('python', '|', '# ('))
	assert_equal("# don'|", H.T('python', '|', "# don'"))
enddef

def Test_python_docstring()
	assert_equal(['def f():', '    """|"""'], H.M('python', ['def f():', '    |'], '"""'))
enddef

def Test_sh_comment_and_string()
	assert_equal('# (|', H.T('sh', '|', '# ('))
	assert_equal('echo "$(|)"', H.T('sh', '|', 'echo "$('))
	assert_equal('echo "a"|', H.T('sh', '|', 'echo "a"'))
enddef

def Test_lua_comment()
	assert_equal('-- (|', H.T('lua', '|', '-- ('))
	assert_equal('print("a")|', H.T('lua', '|', 'print("a")'))
enddef

def Test_javascript()
	assert_equal('// (|', H.T('javascript', '|', '// ('))
	assert_equal('f(`a`)|', H.T('javascript', '|', 'f(`a`)'))
	assert_equal("f('a')|", H.T('javascript', '|', "f('a')"))
enddef

def Test_vim_comment_quote()
	assert_equal('"|', H.T('vim', '|', '"'))
	assert_equal('    "|', H.T('vim', '    |', '"'))
enddef

def Test_vim_string_quote()
	assert_equal('echo "|"', H.T('vim', 'echo |', '"'))
	assert_equal('echo "a"|', H.T('vim', '|', 'echo "a"'))
enddef

def Test_vim9_comment()
	assert_equal(['vim9script', '# (|'], H.M('vim', ['vim9script', '|'], '# ('))
enddef

# --- fin de ligne / guillemets imbriqués ------------------------------------

def Test_c_unclosed_string_at_eol()
	assert_equal('"abc"|', H.T('c', '"abc|', '"'))
	assert_equal('"abc(|', H.T('c', '"abc|', '('))
enddef

def Test_c_inside_string_middle()
	assert_equal('"ab(|c"', H.T('c', '"ab|c"', '('))
	assert_equal('f("a)|")', H.T('c', 'f("a|")', ')'))
	assert_equal('f("a")|', H.T('c', 'f("a|")', '")'))
enddef

def Test_python_after_string()
	assert_equal('"abc"[|]', H.T('python', '|', '"abc"['))
	assert_equal("'a' % (|)", H.T('python', '|', "'a' % ("))
	assert_equal('"(x|"', H.T('python', '|', '"(x'))
enddef

def Test_other_quote_inside_empty_quotes()
	assert_equal("\"'\"|", H.T('text', '|', "\"'\""))
	assert_equal("'\"'|", H.T('text', '|', "'\"'"))
	assert_equal("\"'\"|", H.T('python', '|', "\"'\""))
	assert_equal("\"'\"|", H.T('sh', '|', "\"'\""))
	assert_equal('`"`|', H.T('markdown', '|', '`"`'))
enddef

def Test_escaped_quote_in_string_does_not_jump()
	assert_equal('"\"|"', H.T('c', '"|"', '\"'))
	assert_equal('"\"|"', H.T('text', '"|"', '\"'))
	assert_equal("'\\'|'", H.T('python', "'|'", "\\'"))
enddef

def Test_triple_quotes_close_step_by_step()
	assert_equal('"""abc"|""', H.T('python', '"""abc|"""', '"'))
	assert_equal('"""abc""|"', H.T('python', '"""abc|"""', '""'))
	assert_equal('"""abc"""|', H.T('python', '"""abc|"""', '"""'))
	assert_equal('"""abc"""|', H.T('text', '"""abc|"""', '"""'))
enddef

def Test_sh_command_substitution_in_string()
	assert_equal('echo "$(ls)"|', H.T('sh', '|', 'echo "$(ls)"'))
enddef
