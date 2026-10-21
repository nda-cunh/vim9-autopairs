vim9script
import './helpers.vim' as H

# --- paires par filetype ----------------------------------------------------

def Test_rust_generics()
	assert_equal('Vec<|>', H.T('rust', '|', 'Vec<'))
	assert_equal('Vec<i32>|', H.T('rust', '|', 'Vec<i32>'))
	assert_equal('a <|', H.T('rust', '|', 'a <'))
enddef

def Test_rust_lifetime()
	assert_equal("&'a|", H.T('rust', '|', "&'a"))
	assert_equal("'|'", H.T('rust', '|', "'"))
enddef

def Test_no_generics_outside_rust()
	assert_equal('Vec<|', H.T('c', '|', 'Vec<'))
enddef

def Test_php_tags()
	assert_equal('<?|?>', H.T('php', '|', '<?'))
	assert_equal('<?php|?>', H.T('php', '|', '<?php'))
enddef

# --- paires personnalisées --------------------------------------------------

def Test_buffer_pairs()
	const vars = {AutoPairs: {'<': '>', '(': ')'}}
	assert_equal('<|>', H.T('text', '|', '<', vars))
	assert_equal('(|)', H.T('text', '|', '(', vars))
	assert_equal('[|', H.T('text', '|', '[', vars))
	assert_equal('<a>|', H.T('text', '|', '<a>', vars))
enddef

def Test_buffer_pairs_multichar()
	const vars = {AutoPairs: {'<!--': '-->'}}
	assert_equal('<!--|-->', H.T('html', '|', '<!--', vars))
	assert_equal('<!--x-->|', H.T('html', '|', '<!--x-->', vars))
enddef

def Test_buffer_pairs_bs_multichar()
	const vars = {AutoPairs: {'<!--': '-->'}}
	assert_equal('|', H.T('html', '<!--|-->', "\<BS>", vars))
enddef

def Test_autopairs_define()
	const vars = {AutoPairs: g:AutoPairsDefine({'<!--': '-->'}, ['{'])}
	assert_equal('<!--|-->', H.T('html', '|', '<!--', vars))
	assert_equal('{|', H.T('html', '|', '{', vars))
	assert_equal('(|)', H.T('html', '|', '(', vars))
enddef

def Test_autopairs_define_no_remove()
	const vars = {AutoPairs: g:AutoPairsDefine({'$': '$'})}
	assert_equal('$|$', H.T('tex', '|', '$', vars))
	assert_equal('$x$|', H.T('tex', '|', '$x$', vars))
	assert_equal('{|}', H.T('tex', '|', '{', vars))
enddef

# --- activation / désactivation ---------------------------------------------

def Test_disabled_buffer()
	const vars = {autopairs_enabled: false}
	assert_equal('(|', H.T('text', '|', '(', vars))
	assert_equal('"|', H.T('text', '|', '"', vars))
	assert_equal('|)', H.T('text', '(|)', "\<BS>", vars))
	assert_equal('( |)', H.T('text', '(|)', ' ', vars))
	assert_equal(')|)', H.T('text', '|)', ')', vars))
enddef

def Test_toggle()
	H.Open('text')
	assert_equal(['(|)'], H.Type('('))
	silent call autopair#AutoPairsToggle()
	setline(1, '')
	assert_equal(['(|'], H.Type('('))
	silent call autopair#AutoPairsToggle()
	setline(1, '')
	assert_equal(['(|)'], H.Type('('))
	H.Close()
enddef

def Test_toggle_insert_mapping()
	H.Open('text')
	feedkeys("i(\<M-p>(\<Esc>", 'xt')
	assert_equal(['(()'], getline(1, '$'))
	assert_false(b:autopairs_enabled)
	H.Close()
enddef

def Test_global_toggle_function()
	H.Open('text')
	silent g:AutoPairsToggle()
	assert_equal(['(|'], H.Type('('))
	silent g:AutoPairsToggle()
	H.Close()
enddef

def Test_enabled_per_buffer()
	H.Open('text', ['|'], {autopairs_enabled: false})
	assert_equal(['(|'], H.Type('('))
	H.Open('text')
	assert_equal(['(|)'], H.Type('('))
	H.Close()
	H.Close()
enddef

def Test_reinit_is_idempotent()
	H.Open('text')
	autopair#AutoPairsTryInit()
	autopair#AutoPairsTryInit()
	doautocmd BufEnter
	assert_equal(['(|)'], H.Type('('))
	H.Close()
enddef

def Test_cr_mapping_chained()
	# un <CR> déjà mappé (ex: complétion) doit continuer d'être appelé
	new
	g:cr_called = 0
	inoremap <buffer> <expr> <CR> execute('g:cr_called += 1') .. "\<CR>"
	unlet! b:autopairs_loaded
	autopair#AutoPairsTryInit()
	setlocal filetype=c
	feedkeys("i{\<CR>x\<Esc>", 'xt')
	assert_equal(1, g:cr_called)
	assert_equal(['{', "\tx", '}'], getline(1, '$'))
	bwipe!
enddef

def Test_php_close_step()
	assert_equal('<?x?>|', H.T('php', '|', '<?x?>'))
enddef

def Test_buffer_pairs_multichar_step()
	const vars = {AutoPairs: {'<!--': '-->'}}
	assert_equal('<!--x-|->', H.T('text', '<!--x|-->', '-', vars))
	assert_equal('<!--x--|>', H.T('text', '<!--x|-->', '--', vars))
	assert_equal('<!--x-->|', H.T('text', '<!--x|-->', '-->', vars))
	assert_equal('a > b|', H.T('text', '|', 'a > b', vars))
enddef

def Test_cr_mapping_not_expr_chained()
	new
	inoremap <buffer> <CR> <CR>
	unlet! b:autopairs_loaded
	autopair#AutoPairsTryInit()
	setlocal filetype=c
	feedkeys("i{\<CR>x\<Esc>", 'xt')
	assert_equal(['{', "\tx", '}'], getline(1, '$'))
	bwipe!
enddef
