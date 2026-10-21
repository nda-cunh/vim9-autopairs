vim9script
import './helpers.vim' as H

# --- fast wrap (<M-e>) ------------------------------------------------------

def Test_fastwrap_word()
	H.Open('text', ['(|)abc'])
	H.Type("\<M-e>")
	assert_equal('(abc)', getline(1)->substitute('|', '', ''))
	H.Close()
enddef

def Test_fastwrap_word_then_text()
	H.Open('text', ['(|)abc def'])
	H.Type("\<M-e>")
	assert_equal('(abc) def', getline(1)->substitute('|', '', ''))
	H.Close()
enddef

def Test_fastwrap_bracket()
	H.Open('text', ['(|)[a, b] c'])
	H.Type("\<M-e>")
	assert_equal('([a, b]) c', getline(1)->substitute('|', '', ''))
	H.Close()
enddef

def Test_fastwrap_keeps_register()
	H.Open('text', ['(|)abc'])
	setreg('"', 'saved')
	H.Type("\<M-e>")
	assert_equal('saved', getreg('"'))
	H.Close()
enddef

# --- jump (<M-n>) -----------------------------------------------------------

def Test_jump_normal()
	H.Open('text', ['|ab(c) d'])
	assert_equal(['ab(c|) d'], H.Normal("\<M-n>"))
	H.Close()
enddef

def Test_jump_quote()
	H.Open('text', ['|x = "a"'])
	assert_equal(['x = |"a"'], H.Normal("\<M-n>"))
	H.Close()
enddef

def Test_jump_next_line()
	H.Open('text', ['|abc', 'f(x)'])
	assert_equal(['abc', 'f(x|)'], H.Normal("\<M-n>"))
	H.Close()
enddef

def Test_jump_insert()
	H.Open('text', ['f(a|, b) x'])
	assert_equal(['f(a, b)| x'], H.Type("\<M-n>"))
	H.Close()
enddef

# --- fly mode + back insert -------------------------------------------------

def Test_back_insert()
	g:AutoPairsFlyMode = true
	try
		H.Open('text', ['{', "\t|", '}'])
		feedkeys("a}\<M-b>\<Esc>", 'xt')
		assert_equal(['{', "\t}", '}'], getline(1, '$'))
		H.Close()
	finally
		g:AutoPairsFlyMode = false
	endtry
enddef
