%{
#include <string>
#include <sstream>

using namespace std;

%}

ESPACO [ \t]
DIGITO [0-9]
AMPERSAND &
LETRA [A-Za-z_]
COMENTARIO #.*"\n"

COMENTARIO_INICIO \/\*
COMENTARIO_FIM \*\/

COMENTARIO_MULTILINHA {COMENTARIO_INICIO}(.|"\n")*{COMENTARIO_FIM}

DELIM {ESPACO}+
NUM {DIGITO}+
REAL {NUM}+("."{NUM}+)?
LONG {DIGITO}+[lL]
DOUBLE {NUM}+("."{NUM}+)[dD]
CHAR \'({LETRA}|{NUM})\'
STRING \"[^"\n]*["]
ID {LETRA}({LETRA}|{NUM})*

%%

"\n"		{
				nlinha++;
			}

"="			{
				yylval.label = yytext;
				return TK_ATR;
			}
			
{AMPERSAND}	{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_AMPERSAND;
			}

"begin"		{
				yylval.traducao = "{";
				yylval.label = yytext;

				return TK_BEGIN;
			}

"end"		{
				yylval.traducao = "}";
				yylval.label = yytext;

				return TK_END;
			}

{DELIM} 	{}

{COMENTARIO} {
				nlinha++;
			}
			
{COMENTARIO_MULTILINHA} {
							int i;
							
							for( i=0; yytext[i]; yytext[i]=='\n'? i++ : *yytext++);
							
							nlinha+=i;
		
						}
 
"main"		{
				return TK_MAIN;
			}

"return"	{
				yylval.label = yytext;
				yylval.traducao = yytext;
				return TK_RETURN;
			}

"break"		{
				yylval.label = yytext;
				yylval.traducao = yytext;
				return TK_BREAK;
			}

"all"		{
				yylval.label = yytext;
				yylval.traducao = yytext;
				return TK_ALL;
			}

"write"		{
				yylval.label = yytext;
				yylval.traducao = "cout";
				return TK_WRITE;
			}

"writeln"	{
				yylval.label = yytext;
				yylval.traducao = "cout";
				return TK_WRITELN;
			}

"read"		{
				yylval.label = yytext;
				yylval.traducao = "cin";
				return TK_READ;
			}
			
"global"	{
				yylval.label = yytext;
				yylval.traducao = "cin";
				return TK_GLOBAL;
			}

"next"		{
				yylval.label = yytext;
				yylval.traducao = yytext;
				return TK_NEXT;
			}

"int"		{
				yylval.label = yytext;
				yylval.traducao = "int";
				return TK_TIPO_INT;
			}

"float"		{
				yylval.label = yytext;
				yylval.traducao = "float";
				return TK_TIPO_FLOAT;
			}

"long"		{
				yylval.label = yytext;
				yylval.traducao = "long";
				return TK_TIPO_LONG;
			}

"double"	{
				yylval.label = yytext;
				yylval.traducao = "double";
				return TK_TIPO_DOUBLE;
			}

"boolean"	{
				yylval.traducao = "int";
				yylval.label = yytext;
				return TK_TIPO_BOOL;
			}

"string"	{
				yylval.traducao = "char";
				yylval.label = yytext;

				return TK_TIPO_STRING;
			}
	
"void"		{
				yylval.label = yytext;
				yylval.traducao = yytext;
				yylval.tipo = yytext;
				return TK_VOID;
			}

"if"		{
				yylval.label = yytext;
				yylval.traducao = yytext;

				return TK_IF;
			}

"elsif"		{
				yylval.label = yytext;
				yylval.traducao = "if";

				return TK_ELSIF;
			}

"else"		{
				yylval.label = yytext;
				yylval.traducao = "if";

				return TK_ELSE;
			}

"while"		{
				yylval.label = yytext;
				yylval.traducao = "if";

				return TK_WHILE;
			}

"for"		{
				yylval.label = yytext;
				yylval.traducao = "if";

				return TK_FOR;
			}

"in"		{
				yylval.label = yytext;
				yylval.traducao = yytext;

				return TK_IN;
			}

[(){}[\];,:]	{ return *yytext; }

"+"			{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_SOMA;
			}

"++"		{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_INCREMENTO;
			}

"--"		{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_DECREMENTO;
			}

"-"			{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_SUB;
			}

"*"			{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_MUL;
			}

"/"			{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_DIV;
			}

"%"			{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_RESTO;
			}

"<"			{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_MENOR;
			}

">"			{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_MAIOR;
			}
			


"<="		{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_MENOR_IGUAL;
			}


">="		{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_MAIOR_IGUAL;
			}

"=="		{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_IGUAL;
			}

"!="		{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_DIFERENTE;
			}

"and"		{	
				yylval.traducao = "&&";
				yylval.label = yytext;
				return TK_AND;
			}

"or"		{	
				yylval.traducao = "||";
				yylval.label = yytext;
				return TK_OR;
			}

"not"		{	
				yylval.traducao = "!";
				yylval.label = yytext;
				return TK_NOT;
			}

"true"		{	
				yylval.traducao = "1";
				yylval.label = yytext;
				yylval.tipo = "boolean";
				yylval.tipo_traducao = "int";
				return TK_LOGICO;
			}

"false"		{	
				yylval.traducao = "0";
				yylval.label = yytext;
				yylval.tipo = "boolean";
				yylval.tipo_traducao = "int";
				return TK_LOGICO;
			}

{NUM}		{	
				yylval.traducao = yytext;
				yylval.label = yytext;
				yylval.tipo = "int";
				yylval.tipo_traducao = "int";
				yylval.tamanho = ((string) yytext).size();
				return TK_NUM;
			}
			
{REAL}		{
				yylval.traducao = yytext;
				yylval.label = yytext;
				yylval.tipo = "float";
				yylval.tipo_traducao = "float";
				yylval.tamanho = ((string) yytext).size();
				return TK_FLOAT;
			}

{LONG}		{	
				yylval.traducao = yytext;
				yylval.label = yytext;
				yylval.tipo = "long";
				yylval.tipo_traducao = "long";
				yylval.tamanho = ((string) yytext).size();
				return TK_LONG;
			}
			
{DOUBLE}	{
				yylval.traducao = yytext;
				yylval.label = yytext;
				yylval.tipo = "double";
				yylval.tipo_traducao = "double";
				yylval.tamanho = ((string) yytext).size();
				return TK_DOUBLE;
			}	

{ID}		{
				yylval.label = yytext;
				return TK_ID;
			}

{STRING}  	{
				string texto = yytext;
				
				texto.replace(texto.begin(), texto.begin() + 1, "");
				texto.replace(texto.end() - 1, texto.end(), "");
				
				yylval.traducao = texto;
				yylval.label = texto;
				yylval.tipo = "string";
				yylval.tipo_traducao = "char";
				yylval.tamanho = texto.size();
				
				return TK_STRING;
			}
			
.			{
				*yytext;
			}

%%

