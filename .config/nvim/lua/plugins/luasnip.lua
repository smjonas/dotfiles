require('utils').map('n', '<leader>s', '<cmd>e ' .. vim.fn.stdpath('config') .. '/lua/plugins/luasnip.lua<cr>')

local ls = require('luasnip')
local prs = ls.parser.parse_snippet
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local events = require('luasnip.util.events')

-- snippet css "html_docs_standard.css" b
-- 	<link rel="stylesheet" href="${1:../3tz9ixmacd201270/styles/html_docs_standard.css}">
-- endsnippet

-- snippet download "Download PDF" b
-- <li>
-- 	<a class="download_pdf" download="" href="$1.pdf">
-- 		$2
-- 	</a>
-- </li>
-- $0
-- endsnippet

-- snippet whiteboard "Q&A and Whiteboard" b
-- <li>
-- 	<a class="titel">Q&A + Whiteboard</a>
-- 		<ul>
-- 			<li>
-- 				<a href="mailto:$1">Send new question to Inacon</a>
-- 			</li>
-- 			<li>
-- 				<a href="Empty-Page.html" target="iframe">Whiteboard</a>
-- 			</li>
-- 		</ul>
-- </li>
-- $0
-- endsnippet

-- snippet recording "Video recording for a session"
-- <li><a>Day $1 &gt;</a>
-- 	<ul>
-- 		<li><a href="${2:videos}/Day$1_Session1.html" target="iframe">Session 1</a></li>
-- 		<li><a href="$2/Day$1_Session2.html" target="iframe">Session 2</a></li>
-- 	</ul>
-- </li>
-- endsnippet

-- 'normal' snippets without extra parameters
local function n(trig, text)
  return s(trig, { t(text) })
end

-- text node with description
local function td(trig, name, text)
  return s({ trig = trig, name = name }, t(text))
end

-- <img src="$1" alt="$2">
local html = {
  -- TODO: change to utf8? using regex trigger
  n('utf', '<meta charset="utf-8"/>'),
  td('jq', 'jquery', '<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>'),
  prs({ trig = 'img', name = '<img> tag' }, '<img src="$1" alt="$2">'),
  -- TODO: alternative triggers? i.e. dl and pdf
  prs({ trig = 'dl', name = 'Download PDF'}, '<a class="download_pdf" download="" href="$1.pdf">\n$2\n<\a>'),
}

local vimwiki = {
  s('arrow', c(1, { t('🠂'), t('⇨') })),
  n('leftrightarrow', '🡘'),
  prs('bf', '**$1**'),
  n('alpha', 'α'),
  n('beta', 'β'),
  n('eps', 'ε'),
  n('Gamma', 'Γ'),
  n('lambda', 'λ'),
  n('tau', 'τ'),
  n('vdash', '$\\vdash$'),
  n('all', '∀'),
}

local tex = {
  prs('frac', '\\frac{$1}{$2}'),
  prs('sum', '\\sum_{$1}^{$2}'),
  prs('sqrt', '\\sum_{$1}'),
}

local python = {
  s({ trig = 'deb', name = 'debug variable' },  { t('print(f"{'), i(1), t({'=}")', ''}) })
}

local all = {
  prs('neq', '≠'),
}

ls.snippets = {
  all = all,
  html = html,
  python = python,
  tex = tex,
  vimwiki = vimwiki,
}

ls.filetype_extend('vimwiki', { 'tex' })
ls.filetype_extend('text', { 'vimwiki' })
ls.filetype_extend('prolog', { 'vimwiki' })

