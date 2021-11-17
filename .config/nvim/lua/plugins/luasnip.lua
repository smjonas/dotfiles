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

-- local html = {
--   s({trig = 'img', name = ''}, )
-- }

-- snippet img "<img>"
-- <img src="$1" alt="$2">
-- $0
-- endsnippet

-- snippet jq "Include jquery script" b
-- <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
-- endsnippet

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


-- extends tex

local md = {
  s('rightarrow', c(1, { t('🠂'), t('⇨') })),
  s('leftrightarrow', t('🡘')),
}

local tex = {
  prs('frac', '\\frac{$1}{$2}'),
  prs('sum', '\\sum_{$1}^{$2}'),
  prs('sqrt', '\\sum_{$1}'),
}

ls.snippets = {
  md = md,
  all = tex
}

ls.filetype_set('md', { 'tex' })


