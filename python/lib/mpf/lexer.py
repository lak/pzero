import ply.lex as lex

punctuation = (
    '['   : 'LBRACK',
    ']'   : 'RBRACK',
    '{'   : 'LBRACE',
    '}'   : 'RBRACE',
    ','   : 'COMMA',
    '->'  : 'IN_EDGE',
    '~>'  : 'IN_EDGE_SUB',
    '<-'  : 'OUT_EDGE',
    '<~'  : 'OUT_EDGE_SUB',
    '=>'  : 'FARROW',
    )

string_tokens = (
    r'([a-z][-\w]*)?(::[a-z][-\w]*)+' : 'CLASSNAME', # Require '::' in the class name, else we'd compete with NAME
    r'((::){0,1}[A-Z][-\w]*)+' : 'CLASSREF',
    r'[a-z0-9][-\w]*' : 'NAME',
    r'"[^"]*"' : 'DQSTRING',
    r"'[^']*'" : 'SQSTRING',
    )

tokens = string_tokens.values + punctuation.values

# A string containing ignored characters (spaces and tabs)
t_ignore  = ' \t'

# Build the lexer
lexer = lex.lex()

def t_STRING(t):
  t.value = (t.value, symbol_lookup(t.value))
  return t

def t_PUNC(t):
  t.value = (t.value, symbol_lookup(t.value))
  return t

# Define a rule so we can track line numbers
def t_newline(t):
    r'\n+'
    t.lexer.lineno += len(t.value)

# Error handling rule
def t_error(t):
    print "Illegal character '%s'" % t.value[0]
    t.lexer.skip(1)

while True:
    tok = lexer.token()
    if not tok: break      # No more input
    print tok.type, tok.value, tok.line, tok.lexpos
