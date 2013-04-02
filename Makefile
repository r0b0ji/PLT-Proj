PARSE_DIR=./parser
LEX_DIR=./lexer

all: cgdlc
cgdlc: $(LEX_DIR)/lex.yy.c $(PARSE_DIR)/y.tab.c 
		gcc -o cgdlc $(PARSE_DIR)/y.tab.c -ll -ly
$(PARSE_DIR)/y.tab.c: $(PARSE_FILE) $(LEX_DIR)/lex.yy.c
		cd $(PARSE_DIR); yacc cgdl.y
$(LEX_DIR)/lex.yy.c: $(LEX_FILE)
		cd $(LEX_DIR); lex cgdl.l

