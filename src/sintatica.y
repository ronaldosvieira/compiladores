%{
#include <iostream>
#include <string>
#include <fstream>
#include <cstdio>
#include <sstream>
#include <map>
#include <vector>

#define YYSTYPE _atributos

using namespace std;

int yydebug=1; 

int nlinha = 1;

int contador = 0;

// Estrutura dos atributos de um token

typedef struct
{
	string label;
	string traducao;
	string tipo;
	string tipo_traducao;
	int tamanho;
} _atributos;

// Variável que indica se ocorreram erros ao compilar o programa

bool erro = false;

int yylex(void);
void yyerror(string);

// Estrutura de informações de uma variável

typedef struct _info_variavel
{
	string tipo;
	string nome_temp;
	int tamanho;
	bool parametro;
} info_variavel;

typedef struct _info_funcao
{
	string nome_temp;
	string tipo;
	int tamanho;
	map<string, info_variavel> parametros;
	vector<string> posicoes_parametros;

} info_funcao;

map<string, info_variavel> ultimo_contexto;

// Estrutura que guarda informações sobre o cast a se fazer

typedef struct _tipo_cast
{
	string resultado;
	int operando_cast;
} tipo_cast;

// Estrutura para guardar pares de labels (inicio, fim)

typedef struct _conjunto_label
{
	string inicio;
	string proximo;
	string fim;
} conjunto_label;

// Variável para o cabeçalho
stringstream cabecalho;

// Variável para indicar a função atual
string funcao_atual;

// Mapa de casts
map<string, tipo_cast> mapa_cast;

// Mapa de traduções de tipo
map<string, string> mapa_traducao_tipo;

// Mapa de traduções de tipo
map<string, string> mapa_valor_padrao;

// Pilha de labels
vector<conjunto_label> pilha_label;

// Pilha de labels para loops
vector<conjunto_label> pilha_label_loop;

// Pilha de contextos
vector< map<string, info_variavel> > pilha_contexto;

// Lista de retornos de função
vector<info_variavel> lista_retornos;

// Mapa de funcoes
map<string, info_funcao> mapa_funcao;

// Mapa de parâmetros da função atual
map<string, info_variavel> mapa_parametros_funcao_atual;

// Mapa que guarda todas as variáveis de uma função
map<string, info_variavel> mapa_global_variavel;

// Lista de argumentos
vector<string> lista_parametros;

// Pilha de indices do vetor
vector<string> lista_indices;

// Lista de posições de parâmetros
vector<string> lista_posicoes_parametros;

/****************************************
	Início da declaração de funções
****************************************/

// Função para recuperação de variáveis
info_variavel *recupera_variavel(string nome);

// Funcao para recuperação de funcções
info_funcao *recupera_funcao(string nome);

// Função para recuperar variável em um determinado escopo
info_variavel *recupera_variavel(string nome, map<string, info_variavel> mapa_contexto);

// Função para recuperar o escopo atual
map<string, info_variavel> recupera_escopo_atual();

// Função para inicialização de um escopo
void inicializa_escopo();

// Função para finalização de um escopo
void finaliza_escopo();

// Função para geração do mapa de cast
void gera_mapa_cast();

// Função para gerar o mapa de traduções de tipo
void gera_mapa_traducao_tipo();

// Função para gerar o mapa de traduções de tipo
void gera_mapa_valor_padrao();

// Função para gerar labels
conjunto_label gera_label(string nome_estrutura, bool usar_ultima=false, bool loop=false);

// Função para recuperar a última label
conjunto_label recupera_label(bool loop=false);

// Função para excluir a última label
void exclui_label(bool loop=false);


// Função para gerar declaração de variáveis
string gera_declaracoes_variaveis();

string gera_chave(string operador1, string operador2, string operacao);

// Função para gerar funções temporárias
string gera_funcao_temporaria(string tipo, string nome, map<string, info_variavel> parametros, vector<string> posicoes_parametros);

// Função para gerar nomes temporários para as variáveis
string gera_variavel_temporaria(string tipo, int tamanho, string nome="", bool parametro=false);

void adiciona_biblioteca_cabecalho(string nome_biblioteca);

%}

%token TK_MAIN TK_ID TK_RETURN TK_GLOBAL
%token TK_TIPO_INT TK_TIPO_FLOAT TK_TIPO_BOOL TK_TIPO_DOUBLE TK_TIPO_LONG TK_TIPO_STRING
%token TK_VOID
%token TK_ATR
%token TK_SOMA TK_SUB 
%token TK_MUL TK_DIV TK_RESTO
%token TK_BEGIN TK_END
%token TK_FIM TK_ERROR
%token TK_NUM TK_FLOAT TK_LONG TK_DOUBLE TK_STRING

%token TK_WRITE TK_WRITELN TK_READ

%token TK_LOGICO TK_NOT

%token TK_BREAK TK_NEXT TK_ALL

%token TK_INCREMENTO TK_DECREMENTO

%token TK_MENOR
%token TK_MAIOR
%token TK_MENOR_IGUAL
%token TK_MAIOR_IGUAL
%token TK_IGUAL
%token TK_DIFERENTE
%token TK_AMPERSAND

%token TK_AND TK_OR

%token TK_IF TK_ELSE TK_ELSIF
%token TK_WHILE TK_FOR TK_IN

%start S

%left TK_SOMA TK_SUB
%left TK_MUL TK_DIV

%%

S 			: INI_ESCOPO COMANDOS_GLOBAIS FUNCAO TK_TIPO_INT TK_MAIN '(' ')' BLOCO_SEM_B
			{
				//ofstream myfile;
				//myfile.open ("example.c");
				//myfile << "Writing this to a file.\n";
				//printf(\"Resultado: %d\", " << tipo[contador] << ");\n\t 
				//cout << "$5.traducao";
				//cout << contador << "\n";

				//cout << $5.traducao << "\n\n";

				adiciona_biblioteca_cabecalho("cstdio");
				adiciona_biblioteca_cabecalho("cstdlib");
				adiciona_biblioteca_cabecalho("cstring");
				adiciona_biblioteca_cabecalho("iostream");

				if(!erro) {
					//cout << "/*Compilador FOCA*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << $5.traducao << "\n\treturn 0;\n}" << endl; 
					cout << cabecalho.str();

					string variaveis_funcao = gera_declaracoes_variaveis();

					cout << "\nusing namespace std;\n\n";

					finaliza_escopo();

					cout << gera_declaracoes_variaveis() << endl;
					cout << $3.traducao << endl;
					cout << "int main(void)\n{";
					cout << $2.traducao << endl << endl;
					cout << variaveis_funcao << $8.traducao << "\n\treturn 0;\n}" << endl;
				}
				//myfile.close();
			}
			| INI_ESCOPO COMANDOS_GLOBAIS TK_TIPO_INT TK_MAIN '(' ')' BLOCO_SEM_B
			{

				adiciona_biblioteca_cabecalho("cstdio");
				adiciona_biblioteca_cabecalho("cstdlib");
				adiciona_biblioteca_cabecalho("cstring");
				adiciona_biblioteca_cabecalho("iostream");

				if(!erro) {
					//cout << "\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << $5.traducao << "\n\treturn 0;\n}" << endl; 

					string variaveis_funcao = gera_declaracoes_variaveis();

					cout << cabecalho.str();
					cout << "\nusing namespace std;\n\n";

					finaliza_escopo();

					cout << gera_declaracoes_variaveis();
					cout << "int main(void) {\n";
					cout << $2.traducao << endl << endl;
					cout << variaveis_funcao << $7.traducao << "\n\treturn 0;\n}" << endl; 
				}
				//myfile.close();
			}

COMANDOS_GLOBAIS: VAR_GLOBAIS
			{
				$$.traducao = $1.traducao;
			}
			|
			{
				$$.traducao = "";
			}


VAR_GLOBAIS: VAR_GLOBAIS VAR_GLOBAL ';'
			{
				$$.traducao = $1.traducao + $2.traducao;

				if($3.tipo != "undefined") {
					$$.tipo = $3.tipo;
					$$.tamanho = $3.tamanho;
				} else {
					$$.tipo = $1.tipo;
					$$.tamanho = $1.tamanho;
				}	
			}
			| VAR_GLOBAL ';'
			{
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
				$$.tamanho = $1.tamanho;
			}
			
VAR_GLOBAL : TK_GLOBAL DECLARACAO
			{
				$$.label = $2.label;
				$$.traducao = $2.traducao;
				$$.tipo = "void";
			}

ARGUMENTO	: TIPO TK_ID
			{
				string nome_variavel_temporaria = gera_variavel_temporaria($1.label, 0, $2.label, true);

				lista_posicoes_parametros.push_back($1.label);

				if(mapa_parametros_funcao_atual.find($2.label) == mapa_parametros_funcao_atual.end()) {
					
					mapa_parametros_funcao_atual[$2.label] = *recupera_variavel($2.label);
					
					if($1.label == "string") {
						$$.traducao = $1.traducao + "* " + $2.label;
					} else {
						//$$.traducao = $1.traducao + " " + $2.label;
						$$.traducao = $1.traducao + " " + nome_variavel_temporaria;

					}
					
					$$.label = $1.label;
					$$.tipo = $2.tipo;
					$$.tamanho = $2.tamanho;
					
				} else {
					cout << "Erro na linha " << nlinha <<": O nome do parâmetro " << $2.label << " já foi declarado\n";
					erro = true;
				}
			}
		
ARGUMENTOS	: ARGUMENTOS ',' ARGUMENTO
			{
				$$.traducao = $1.traducao + ", " + $3.traducao;
				$$.label = $3.label;
				$$.tamanho = $3.tamanho;
				$$.tipo = $3.tipo;
			}
			| ARGUMENTO
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
				$$.tamanho = $1.tamanho;
				$$.tipo = $1.tipo;
			}
			| 
			{
				$$.traducao = "";
				$$.label = "";
				$$.tipo = "undefined";
				$$.tamanho = 0;
			}

CABECALHO_FUNC : TIPO_FUNC TK_ID '(' ARGUMENTOS ')'
			{
				
				stringstream traducao;
				
				string funcao = gera_funcao_temporaria($1.label, $2.label, mapa_parametros_funcao_atual, lista_posicoes_parametros);

				info_funcao *info_funcao = recupera_funcao($2.label);

				if($1.label == "string") {
					
					traducao << "char* " << info_funcao->nome_temp << "(";
				} else {
					
					traducao << $1.traducao << " " << info_funcao->nome_temp << "(";
				}
				
				traducao << $4.traducao;
				
				traducao << ") {\n";

				$$.label = $2.label;
				$$.tipo = $1.label;
				$$.traducao = traducao.str();

				funcao_atual = $2.label;

				mapa_parametros_funcao_atual.clear();
				lista_posicoes_parametros.clear();
			}

FUNCAO		: FUNCAO CABECALHO_FUNC BLOCO_SEM_B
			{

				info_funcao *info_funcao = recupera_funcao($2.label);
				
				int tamanho_retorno = 0;
				
				int contador = 0;
				
				for(contador = 0; contador < lista_retornos.size(); contador++) {
					if(lista_retornos[contador].tamanho > tamanho_retorno) {
						tamanho_retorno = lista_retornos[contador].tamanho;
					}
				}

				info_funcao->tamanho = tamanho_retorno;

				funcao_atual = $2.label;

				stringstream traducao;

				traducao << $1.traducao;
				traducao << $2.traducao;
				traducao << gera_declaracoes_variaveis();
				traducao << $3.traducao;
				traducao << "\n\treturn";
				
				if(mapa_valor_padrao.find($2.tipo) != mapa_valor_padrao.end()) {
					traducao << " " << mapa_valor_padrao[$2.tipo];
				}
				
				traducao << ";\n}\n";

				$$.traducao = traducao.str();
				$$.tamanho = tamanho_retorno;
				$$.label = $2.label;

				lista_retornos.clear();
			}
			| CABECALHO_FUNC BLOCO_SEM_B
			{
				info_funcao *info_funcao = recupera_funcao($1.label);
				
				int tamanho_retorno = 0;

				for(vector<info_variavel>::iterator it = lista_retornos.begin(); it != lista_retornos.end(); ++it ) {
					if(it->tamanho > tamanho_retorno) {
						tamanho_retorno = it->tamanho;
					}
				}

				info_funcao->tamanho = tamanho_retorno;

				stringstream traducao;

				traducao << $1.traducao;
				traducao << gera_declaracoes_variaveis();
				traducao << $2.traducao;
				traducao << "\n\treturn";
				
				if(mapa_valor_padrao.find($1.tipo) != mapa_valor_padrao.end()) {
					traducao << " " << mapa_valor_padrao[$1.tipo];
				}
				
				traducao << ";\n}\n";

				$$.traducao = traducao.str();
				
				lista_retornos.clear();
			}

INI_ESCOPO:
			{
				inicializa_escopo();
				$$.traducao = "";
				$$.label = "";
			}

BLOCO_SEM_B	: INI_ESCOPO COMANDOS TK_END
			{
				$$.traducao = $2.traducao;
				$$.tipo = $2.tipo;
				$$.tamanho = $2.tamanho;

				finaliza_escopo();
			};

EST_BLOCO_P	: INI_ESCOPO COMANDOS 
			{
				$$.traducao = $2.traducao;

				finaliza_escopo();
			}

COMANDOS	: COMANDO ';' COMANDOS
			{
				$$.traducao = $1.traducao + $3.traducao;

				if($3.tipo != "undefined") {
					$$.tipo = $3.tipo;
					$$.tamanho = $3.tamanho;
				} else {
					$$.tipo = $1.tipo;
					$$.tamanho = $1.tamanho;
				}
			}
			| EST_BLOCO COMANDOS
			{
				$$.traducao = $1.traducao + $2.traducao;
			}|
			{
				$$.traducao = "";
				$$.label = "";
				$$.tipo = "undefined";
			};

EST_BLOCO	: BLOCO_COM_B
			{
				stringstream variaveis;

				std::map<string, info_variavel> mapa_variavel = recupera_escopo_atual();

				for (std::map<string, info_variavel>::iterator it=mapa_variavel.begin(); it!=mapa_variavel.end(); ++it) {
    				variaveis << "\t" << mapa_traducao_tipo[it->second.tipo] << " " << it->second.nome_temp;

    				if(it->second.tipo == "string") {
    					variaveis << "[" << (it->second.tamanho + 1) << "]";
    				}

    				variaveis << ";\n";
    			}

				$$.traducao = "\n\n" + variaveis.str() + $1.traducao + "\n";
			}
			| EST_ELSE TK_END
			{
				$$.traducao = $1.traducao;
			}
			| EST_WHILE TK_END
			{
				$$.traducao = $1.traducao;
			}
			| EST_FOR TK_END
			{
				$$.traducao = $1.traducao;
			}

STEP_FOR	: ATRIBUICAO
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			}
			| ATR_UNARIA
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			}

DEC_EST_FOR : TK_FOR '(' ATRIBUICAO ';' E_OP_OR ';' STEP_FOR ')'
			{
				if($5.tipo == "boolean") {
					stringstream traducao;

					conjunto_label label_atual =  gera_label($1.label, false, true);

					traducao << "\t" << $3.traducao << endl;
					traducao << label_atual.inicio << ":\n";
					traducao << $5.traducao << "\n\t" << $1.traducao << "(!(" << $5.label << "))";
					traducao << " goto " << label_atual.fim << ";\n";

					// Para substituição
					traducao << "_r_";

					traducao << $7.traducao;
					traducao << "\n\tgoto " << label_atual.inicio << ";\n";
					traducao << "\n" << label_atual.fim << ":\n";

					$$.traducao = traducao.str();

				} else {
					cout << "Erro na linha " << nlinha <<": A condição utilizada na estrutura do for espera um valor do tipo boolean, mas o valor utilizado foi do tipo " + $3.tipo + "\n";

					erro = true;
				}
			}
			| TK_FOR '(' TK_ID TK_IN RANGE ')' 
			{
				stringstream traducao;

				info_variavel *variavel = recupera_variavel($3.label);

				if(variavel) {

					string nome_variavel_temporaria = variavel->nome_temp;
					string tipo_variavel_temporaria = variavel->tipo;

					conjunto_label label_atual =  gera_label($1.label, false, true);
					string nome_variavel_temporaria_comparacao = gera_variavel_temporaria("boolean", 0);

					string inicio, fim, passo;
					{
						int posicao_delimitador = 0;
						string range = $5.label;

						posicao_delimitador = range.find(":");
						inicio = range.substr(0, posicao_delimitador);
						range.erase(0, posicao_delimitador+1);
						posicao_delimitador = range.find(":");
						fim = range.substr(0, posicao_delimitador);
						range.erase(0, posicao_delimitador+1);
						passo = range;
					}					

					traducao << "\t" << $5.traducao << endl;
					traducao << "\t" << nome_variavel_temporaria << " = " << inicio << ";\n";
					traducao << label_atual.inicio << ":\n";
					traducao << "\t" << nome_variavel_temporaria_comparacao << " = " << nome_variavel_temporaria << " < " << fim << ";\n";

					traducao << "\n\t" << $1.traducao << "(!" << nome_variavel_temporaria_comparacao << ")";
					traducao << " goto " << label_atual.fim << ";\n";

					traducao << "_r_";

					string chave = gera_chave(tipo_variavel_temporaria,$5.tipo,"=");

					if(mapa_cast.find(chave) != mapa_cast.end()) {
						tipo_cast cast = mapa_cast[chave];

						switch(cast.operando_cast) {
							case 0:
								traducao << "\n\t" << nome_variavel_temporaria << " = " << nome_variavel_temporaria << " + " << passo << ";\n";
								break;

							case 2:
								traducao << "\n\t" << nome_variavel_temporaria << " = (" << cast.resultado << ")" << nome_variavel_temporaria << " + " << passo << ";\n";
								break;
							default:
								cout << "Erro na linha " << nlinha << ": Não é possível atribuir uma variável do tipo " << $5.tipo << " a uma do tipo " << tipo_variavel_temporaria << "\n";
								erro = true;
						}
					} else {
						cout << "Erro na linha " << nlinha << ": Não é possível atribuir uma variável do tipo " << $5.tipo << " a uma do tipo " << tipo_variavel_temporaria << "\n";
						erro = true;
					}

					traducao << "\n\tgoto " << label_atual.inicio << ";\n";
					traducao << "\n" << label_atual.fim << ":\n";

					$$.traducao = traducao.str();

				}

			}

RANGE		: E_OP_OR ':' E_OP_OR
			{

				if($1.tipo == "boolean" || $1.tipo == "string" || $3.tipo == "boolean" || $3.tipo == "string") {
					
					cout << "Erro na linha " << nlinha << ": Não é possível criar um range com variáveis não numéricas";
					erro = true;

				} else {

					string chave = gera_chave($1.tipo,$3.tipo,"+");
					tipo_cast cast = mapa_cast[chave];

					$$.tipo = cast.resultado;
					$$.traducao = $1.traducao + $3.traducao;
					$$.label = $1.label + ":" + $3.label + ":1";
				}
			}
			| E_OP_OR ':' E_OP_OR ':' E_OP_OR
			{
				if($1.tipo == "boolean" || $1.tipo == "string" || $3.tipo == "boolean" || $3.tipo == "string" || $5.tipo == "boolean" || $5.tipo == "string") {
					
					cout << "Erro na linha " << nlinha << ": Não é possível criar um range com variáveis não numéricas";
					erro = true;

				} else {
					string chave = gera_chave($1.tipo,$3.tipo,"+");
					tipo_cast cast = mapa_cast[chave];

					$$.tipo = cast.resultado;
					$$.traducao = $1.traducao + $3.traducao + $5.traducao;
					$$.label = $1.label + ":" + $3.label + ":" + $5.label;
				}
			}

EST_FOR		: DEC_EST_FOR EST_BLOCO_P
			{
				conjunto_label label_atual = pilha_label_loop.back();

				string bloco_for = $1.traducao;

				bloco_for = bloco_for.replace( bloco_for.find("_r_"), 3, $2.traducao );

				$$.traducao = bloco_for;
			}

DEC_EST_WHILE : TK_WHILE '(' E_OP_OR ')'
			{
				if($3.tipo == "boolean") {

					stringstream traducao;

					conjunto_label label_atual =  gera_label($1.label, false, true);

					traducao << $3.traducao << endl;
					traducao << label_atual.inicio << ":\n";
					traducao << "\t" << $1.traducao << "(!(" << $3.label << "))";
					traducao << " goto " << label_atual.fim << ";\n";

					$$.traducao = traducao.str();

					$$.label = label_atual.fim;

				} else {
					cout << "Erro na linha " << nlinha <<": A condição utilizada na estrutura do while espera um valor do tipo boolean, mas o valor utilizado foi do tipo " + $3.tipo + "\n";

					erro = true;
				}
			}

EST_WHILE	: DEC_EST_WHILE EST_BLOCO_P
			{

				conjunto_label label_atual = pilha_label_loop.back();

				stringstream traducao;

				traducao << $2.traducao << endl;
				traducao << "\tgoto " << label_atual.inicio << ";\n";
				traducao << $1.label << ":\n";

				$$.traducao = $1.traducao + traducao.str();
			}

EST_ELSE	: EST_ELSIF TK_ELSE EST_BLOCO_P
			{
				stringstream traducao;

				conjunto_label label_atual =  gera_label($2.label, true);

				traducao << $1.traducao;
				traducao << label_atual.inicio << ":" << "\n";
				traducao << $3.traducao << "\n";
				traducao << label_atual.fim << ":" << "\n";

				$$.traducao = traducao.str();

				$$.label = label_atual.inicio;

				exclui_label();
			}
			| EST_ELSIF TK_ELSIF '(' E_OP_OR ')' EST_BLOCO_P
			{

				if($4.tipo == "boolean") {

					stringstream traducao;

					conjunto_label label_atual = gera_label($2.label, true);

					traducao << $1.traducao << "\n" << $1.label << ":\n\t" << $2.traducao << "(!(" << $4.label << "))";
					traducao << " goto " << label_atual.fim << ";\n";
					traducao << $6.traducao << "\n";
					traducao << label_atual.fim << ":\n";

					$$.traducao = traducao.str();

					$$.label = label_atual.proximo;

				} else {
					cout << "Erro na linha " << nlinha <<": A condição utilizada na estrutura do if espera um valor do tipo boolean, mas o valor utilizado foi do tipo " + $4.tipo + "\n";

					erro = true;
				}
			}
			|  TK_IF '(' E_OP_OR ')' EST_BLOCO_P
			{
				if($3.tipo == "boolean") {

					stringstream traducao;

					conjunto_label label_atual = gera_label($1.label);

					traducao << $3.traducao << "\n" << label_atual.inicio << ":\n\t" << $1.traducao << "(!(" << $3.label << "))" << " goto " << label_atual.fim << ";\n";//$7.label << ";\n";
					traducao << $5.traducao << "\n";
					traducao << label_atual.fim << ":\n";

					$$.traducao = traducao.str();
					$$.label = label_atual.proximo;

				} else {
					cout << "Erro na linha " << nlinha <<": A condição utilizada na estrutura do if espera um valor do tipo boolean, mas o valor utilizado foi do tipo " + $4.tipo + "\n";

					erro = true;
				}
			}

EST_ELSIF	: EST_ELSIF TK_ELSIF '(' E_OP_OR ')' EST_BLOCO_P
			{
				if($4.tipo == "boolean") {

					stringstream traducao;

					conjunto_label label_atual = gera_label($2.label, true);

					traducao << $1.traducao << "\n" << $1.label << ":\n\t" << $2.traducao << "(!(" << $4.label << "))";
					traducao << " goto " << label_atual.proximo << ";\n";
					traducao << $6.traducao << "\n";
					traducao << "\tgoto " << label_atual.fim << ";\n";

					$$.traducao = traducao.str();

					$$.label = label_atual.proximo;

				} else {
					cout << "Erro na linha " << nlinha <<": A condição utilizada na estrutura do if espera um valor do tipo boolean, mas o valor utilizado foi do tipo " + $4.tipo + "\n";

					erro = true;
				}
			}
			| EST_IF
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			};

EST_IF 		: TK_IF '(' E_OP_OR ')' EST_BLOCO_P
			{
				if($3.tipo == "boolean") {

					stringstream traducao;

					conjunto_label label_atual = gera_label($1.label);

					traducao << $3.traducao << "\n" << label_atual.inicio << ":\n\t" << $1.traducao << "(!(" << $3.label << "))" << " goto " << label_atual.proximo << ";\n";//$7.label << ";\n";
					traducao << $5.traducao << "\n";

					traducao << "\tgoto " << label_atual.fim << ";\n";
					
					$$.traducao = traducao.str();
					$$.label = label_atual.proximo;

				} else {
					cout << "Erro na linha " << nlinha <<": A condição utilizada na estrutura do if espera um valor do tipo boolean, mas o valor utilizado foi do tipo " + $4.tipo + "\n";

					erro = true;
				}
			};

BLOCO_COM_B	: TK_BEGIN EST_BLOCO_P TK_END
			{
				$$.traducao = $2.traducao;
			}

PARAMETROS 	: PARAMETROS ',' PARAMETRO
			{
				lista_parametros.push_back($3.tipo);

				$$.label = $1.label + $3.traducao;
				$$.traducao = $1.traducao + ", " + $3.label;
				/*
				$$.traducao = $1.traducao + ", " + $3.label;
				$$.label = $3.label;
				*/
				$$.tamanho = $3.tamanho;
				$$.tipo = $3.tipo;
			}
			| PARAMETRO
			{
				lista_parametros.push_back($1.tipo);

				$$.label = $1.traducao;
				$$.traducao = $1.label;
				/*
				$$.traducao = $1.traducao;
				$$.label = $1.label;
				*/

				$$.tamanho = $1.tamanho;
				$$.tipo = $1.tipo;
			}
			|
			{
				$$.traducao = "";
				$$.label = "";
				$$.tamanho = 0;
				$$.tipo = "void";
			}

PARAMETRO 	: E_OP_OR
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
				$$.tamanho = $1.tamanho;
				$$.tipo = $1.tipo;
			}

COMANDO 	: DECLARACAO
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = "void";
			}
			| ATRIBUICAO
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = "void";
			}
			| TK_BREAK
			{
				if(!pilha_label_loop.empty()) {
					$$.traducao = "\tgoto " + pilha_label_loop.back().fim + ";\n";
				} else {
					cout << "Erro na linha " << nlinha << ": Não existem loops a serem parados\n";
					erro = true;
				}

				$$.label = $1.label;
				$$.tamanho = $1.tamanho;
			}
			| TK_BREAK TK_ALL
			{
				if(!pilha_label_loop.empty()) {
					$$.traducao = "\tgoto " + pilha_label_loop.front().fim + ";\n";
				} else {
					cout << "Erro na linha " << nlinha << ": Não existem loops a serem parados\n";
					erro = true;
				}

				$$.label = $1.label;
				$$.tamanho = $1.tamanho;
			}
			| TK_NEXT
			{
				if(!pilha_label_loop.empty()) {
					$$.traducao = "\tgoto " + pilha_label_loop.back().inicio + ";\n";
				} else {
					cout << "Erro na linha " << nlinha << ": Não existem loops a serem continuados\n";
					erro = true;
				}
			}
			| TK_NEXT TK_ALL
			{
				if(!pilha_label_loop.empty()) {
					$$.traducao = "\tgoto " + pilha_label_loop.front().inicio + ";\n";
				} else {
					cout << "Erro na linha " << nlinha << ": Não existem loops a serem continuados\n";
					erro = true;
				}
			}
			| TK_READ TK_ID
			{
				info_variavel *variavel = recupera_variavel($2.label);

				if(variavel) {

					string nome_variavel_temporaria = variavel->nome_temp;

					if(variavel->tipo == "string") {
						$$.tamanho = 1024;
						variavel->tamanho = 1024;

						$$.traducao = "\tcin.getline(" + variavel->nome_temp + ", 1024);\n";

					} else if(variavel->tipo == "boolean") {

						stringstream traducao;

						stringstream label_stream;

						string label_true;
						string label_erro;
						string label_fim;

						label_stream << "boolean_true_" << contador;
						label_true = label_stream.str();
						label_stream.str("");

						label_stream << "boolean_erro_" << contador;
						label_erro = label_stream.str();
						label_stream.str("");

						label_stream << "boolean_fim_" << contador;
						label_fim = label_stream.str();
						label_stream.str("");

						string nome_variavel_temporaria_leitura = gera_variavel_temporaria("string", 1024);
						string nome_variavel_temporaria_comparacao = gera_variavel_temporaria("boolean", 0);

						traducao << "\n\tcin.getline(" << nome_variavel_temporaria_leitura << ", 1024);\n";

						traducao << "\t" << nome_variavel_temporaria_comparacao << " = strcmp(" << nome_variavel_temporaria_leitura << ", \"false\");\n";


						traducao << "\n\tif(" << nome_variavel_temporaria_comparacao << ") goto " << label_true << ";\n";

						traducao << "\t" << nome_variavel_temporaria << " = 0;\n";

						traducao << "\tgoto " << label_fim << ";\n\n";

						traducao << label_true << ":\n";

						traducao << "\t" << nome_variavel_temporaria_comparacao << " = strcmp(" << nome_variavel_temporaria_leitura << ", \"true\");\n";

						traducao << "\n\tif(" << nome_variavel_temporaria_comparacao << ") goto " << label_erro << ";\n";

						traducao << "\t" << nome_variavel_temporaria << " = 1;\n";

						traducao << "\tgoto " << label_fim << ";\n\n";

						traducao << label_erro << ":\n";

						traducao << "\tcout << \"Valor inválido\" << endl;\n";

						traducao << "\texit(0);\n";

						traducao << label_fim << ":\n";

						$$.traducao = traducao.str();

						contador++;
					} else {
						$$.traducao = "\n\tcin >> " + nome_variavel_temporaria + ";\n\t";
                    	$$.tamanho = 0;
					}

					$$.label = $2.label;
					$$.tipo = "void";

				} else {
					cout << "Erro na linha " << nlinha <<": Variável \"" << $2.label << "\" não declarada neste escopo" << endl << endl;
					erro = true;
				}
			}
			| TK_WRITE ARGS_IO
			{
				$$.traducao = $2.traducao;
				$$.label = $2.label;
				$$.tipo = "void";
				$$.tamanho = 0;
			}
			| TK_WRITELN ARGS_IO
			{
				$$.traducao = $2.traducao + "\tcout << endl;\n";
				$$.label = $2.label;
				$$.tipo = "void";
				$$.tamanho = 0;
			}
			| TK_RETURN
			{
				info_funcao *funcao = recupera_funcao(funcao_atual);
				
				if(funcao) {
					
					if(funcao->tipo == "void") {
						$$.traducao = "\t" + $1.traducao + ";\n";
						$$.label = $1.label;
						$$.tamanho = 0;
						$$.tipo = "void";
						
					} else {
						cout << "Erro na linha " << nlinha <<": A função " + funcao_atual + " necessita de um valor de retorno do tipo " + funcao->tipo + "\n";
						erro = true;
					}
				}
			}
			| TK_RETURN E_OP_OR
			{

				info_funcao *funcao = recupera_funcao(funcao_atual);

				if(funcao) {

					string tipo_retorno;

					string chave = gera_chave(funcao->tipo, $2.tipo, "=");

					string nome_variavel_temporaria;

					if(mapa_cast.find(chave) != mapa_cast.end()) {

						stringstream traducao;

						tipo_cast cast = mapa_cast[chave];

						traducao << $2.traducao << "\n";

						if($2.tipo == "string") {
							nome_variavel_temporaria = gera_variavel_temporaria("char*", $2.tamanho);

							traducao << "\t" << nome_variavel_temporaria << " = (char *) malloc(" << ($2.tamanho+1) << "* sizeof(char));\n";
							traducao << "\t" << "strcpy(" << nome_variavel_temporaria << "," << $2.label << ");\n";
						} else {
							nome_variavel_temporaria = $2.label;
						}

						switch(cast.operando_cast) {
							case 0: 
								traducao << "\t" << $1.traducao << " " << nome_variavel_temporaria << ";\n";
								$$.tipo = $2.tipo;
								break;
							case 2:
								traducao << "\t" << $1.traducao << " " << "(" << cast.resultado << ") " << nome_variavel_temporaria << ";\n";
								$$.tipo = cast.resultado;
								break;
							default:
								cout << "Erro na linha " << nlinha <<": Impossível retornar um valor do tipo " + $2.tipo + " em uma função do tipo " + funcao->tipo + "\n";
								erro = true;
						}

						info_variavel variavel_retorno = {$2.tipo, $2.label, $2.tamanho, false};

						lista_retornos.push_back(variavel_retorno);

						$$.tamanho = variavel_retorno.tamanho;
						$$.traducao = traducao.str();

					} else {

						cout << "Erro na linha " << nlinha <<": Impossível retornar um valor do tipo " + $2.tipo + " em uma função do tipo " + funcao->tipo + "\n";

						erro = true;
					}
				}
			}

ARGS_IO		: ARGS_IO ',' E_OP_OR
			{
				$$.label = $3.label;
				if($3.tipo == "boolean")
					$$.traducao = $1.traducao + $3.traducao + "\n\tcout << \" \" << (" + $3.label + "? \"true\" : \"false\");\n";
				else
					$$.traducao = $1.traducao + $3.traducao + "\n\tcout << \" \" << " + $3.label + ";\n";
			}
			| E_OP_OR
			{
				$$.label = $1.label;
				if($1.tipo == "boolean")
					$$.traducao = $1.traducao + "\n\tcout << (" + $1.label + "? \"true\" : \"false\");\n";
				else
					$$.traducao = $1.traducao + "\n\tcout << " + $1.label + ";\n";
			}

DIREITA_ATR	: ATRIBUICAO
			{
				$$.label = $1.label;
				$$.tipo = $1.tipo;
				$$.traducao = $1.traducao;
				$$.tamanho = $1.tamanho;
			}
			| E_OP_OR
			{
				$$.label = $1.label;
				$$.tipo = $1.tipo;
				$$.traducao = $1.traducao;
				$$.tamanho = $1.tamanho;
			}

ATRIBUICAO 	: TK_ID TK_ATR DIREITA_ATR
			{

				info_variavel *ptr_variavel = recupera_variavel($1.label);

				if(ptr_variavel) {

					info_variavel variavel = *ptr_variavel;

					string chave = gera_chave(variavel.tipo, $3.tipo, $2.label);

					$$.tipo = variavel.tipo;

					if(mapa_cast.find(chave) != mapa_cast.end()) {

						tipo_cast cast = mapa_cast[chave];

						switch(cast.operando_cast) {
							case 0:

								if($3.tipo == "string") {
									$$.traducao = "\t" + $3.traducao;

									$$.traducao = $$.traducao + "\tstrcpy(" + variavel.nome_temp + ", " + $3.label + ");\n";
								} else {
									$$.traducao = "\t" + $3.traducao + "\n\t" + variavel.nome_temp + " " + $2.label + " " + $3.label + ";";
								}

								break;
							case 2:
								$$.traducao = "\t" + $3.traducao + "\n\t" + variavel.nome_temp + " " + $2.label + " " + "(" + cast.resultado + ") " + $3.label + ";";
								break;
							default:
								cout << "Erro na linha " << nlinha <<": Não é possível atribuir um valor do tipo " << $3.tipo
									<< " a uma variável do tipo " << variavel.tipo << endl << endl;
									erro = true;
								break;
						}
					} else {

						cout << "Erro na linha " << nlinha <<": Não é possível atribuir um valor do tipo " << $3.tipo
							<< " a uma variável do tipo " << variavel.tipo << endl << endl;
						erro = true;
					}

				} else {
					//cout << "Erro na linha " << nlinha <<": Que porra de variável \"" << $1.label << "\" é essa?" << endl << endl;
					cout << "Erro na linha " << nlinha <<": Variável \"" << $1.label << "\" não declarada neste escopo" << endl << endl;

					erro = true;
				}
			};

COMANDO 	: E_OP_OR
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao + "\n\t" + $1.label + ";\n";
			};

DECLARACAO	: TIPO TK_ID TK_ATR DIREITA_ATR
			{
				string nome_temp = gera_variavel_temporaria($1.label, $4.tamanho, $2.label);

				info_variavel atributos = *recupera_variavel($2.label);

				string chave = gera_chave(atributos.tipo, $4.tipo, $3.label);

				$$.label = atributos.nome_temp;
				$$.tipo = $1.label;

				if(mapa_cast.find(chave) != mapa_cast.end()) {

					tipo_cast cast = mapa_cast[chave];

					switch(cast.operando_cast) {
						case 0:
							if($1.label == "string") {
						
								stringstream traducao;
								
								traducao << $4.traducao << "\tstrcpy(" << atributos.nome_temp << ", " << $4.label << ");\n";
								
								$$.traducao = traducao.str();
								
							} else {
								$$.traducao = "\t" + $4.traducao + "\n\t" + atributos.nome_temp + " " + $3.label + " " + $4.label + ";";
							}
							break;
						case 2:
							$$.traducao = "\t" + $4.traducao + "\n\t" + atributos.nome_temp + " " + $3.label + " " + "(" + cast.resultado + ") " + $4.label + ";";
							break;
						default:
							cout << "Erro na linha " << nlinha <<": Não é possível atribuir um valor do tipo " << $4.tipo
								<< " a uma variável do tipo " << atributos.tipo << endl << endl;
							erro = true;
							break;
					}

					$$.tipo = "boolean";
					$$.tamanho = $4.tamanho;

				} else {
					cout << "Erro na linha " << nlinha <<": Não é possível atribuir um valor do tipo " << $4.tipo
						<< " a uma variável do tipo " << atributos.tipo << endl << endl;

					erro = true;
				}
			}
			| TIPO TK_ID
			{
				string nome_temp = gera_variavel_temporaria($1.label, 0, $2.label);

				info_variavel atributos = *recupera_variavel($2.label);

				$$.label = atributos.nome_temp;
				
				if($1.label == "string") {
					$$.traducao = "\tstrcpy(" + atributos.nome_temp + ", " + mapa_valor_padrao[$1.label] + ");\n";
					
				} else {
					$$.traducao = "\n\t" + atributos.nome_temp + " = " + mapa_valor_padrao[$1.label] + ";";
				}
				
				$$.tipo = $1.label;
				$$.tamanho = $2.tamanho;
			}
			| TIPO DIMENSOES TK_ID 
			{
				stringstream tipo_variavel;
				tipo_variavel << $1.label << "*";

				string nome_temp = gera_variavel_temporaria(tipo_variavel.str(), 0, $3.label);

				info_variavel variavel = *recupera_variavel($3.label);
				$$.label = variavel.nome_temp;

				$$.traducao = $2.traducao + "\n\t" + variavel.nome_temp + " = malloc(" + $2.label + " * sizeof (" + $1.label + "));\n";
			}

DIMENSOES	: DIMENSOES '[' DIMENSAO ']'
			{
				string nome_variavel_temporaria = gera_variavel_temporaria("int", 0);

				$$.traducao = $1.traducao + $3.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.label + " * " + $3.label + ";\n";

				$$.label = nome_variavel_temporaria;
			}
			| '[' DIMENSAO ']'
			{
				$$.label = $2.label;
				$$.traducao = $2.traducao;
			}

DIMENSAO	: E_OP_OR
			{
				lista_indices.push_back($1.label);

				if($1.tipo == "int") {
					$$.traducao = $1.traducao;
					$$.label = $1.label;
					$$.tamanho = $1.tamanho;
					$$.tipo = $$.tipo;

				} else {
					cout << "Erro na linha " << nlinha << ": O índice do vetor deve ser do tipo int" << endl;
					erro = true;
				}
			}

E_OP_OR		: E_OP_OR TK_OR E_OP_AND
			{
				string nome_variavel_temporaria;

				string chave = gera_chave($1.tipo, $3.tipo, $2.label);

				if(mapa_cast.find(chave) != mapa_cast.end()) {

					tipo_cast cast = mapa_cast[chave];

					nome_variavel_temporaria = gera_variavel_temporaria($1.tipo, $1.tamanho);

					if (cast.operando_cast == 0) {
						$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.traducao + " " + $3.label + ";";

					} else if (cast.operando_cast == 1) { 

						string nome_variavel_temporaria_cast = gera_variavel_temporaria(cast.resultado, $1.tamanho);

						$$.traducao = "\t" + $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria_cast + " " + "= " + "(" + cast.resultado + ") " + $1.label + ";\n";

						$$.traducao = $$.traducao + "\t" + nome_variavel_temporaria + " = " + nome_variavel_temporaria_cast + " " + $2.traducao + " " + $3.label + ";";

					} else if (cast.operando_cast == 2) { 

						string nome_variavel_temporaria_cast = gera_variavel_temporaria(cast.resultado, $3.tamanho);

						$$.traducao = "\t" + $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria_cast + " " + "= " + "(" + cast.resultado + ") " + $3.label + ";\n";

						$$.traducao = $$.traducao + "\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.traducao + " " + nome_variavel_temporaria_cast + ";";

					} else {
						//cout << "Erro na linha " << nlinha <<": Verifique os tipos, idiota!" << endl << endl;
						cout << "Erro na linha " << nlinha <<": Não é possível comparar um valor do tipo " << $1.tipo
						<< " com um do tipo " << $3.tipo << endl << endl;
						erro = true;
					}

				} else {
					cout << "Erro na linha " << nlinha <<": Não é possível comparar um valor do tipo " << $1.tipo
						<< " com um do tipo " << $3.tipo << endl << endl;

					erro = true;
				}

				$$.label = nome_variavel_temporaria;
			}
			| E_OP_AND
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
				$$.tamanho = $1.tamanho;
			};

E_OP_AND	: E_OP_AND TK_AND E_REL
			{
				string nome_variavel_temporaria;

				string chave = gera_chave($1.tipo, $3.tipo, $2.label);

				if(mapa_cast.find(chave) != mapa_cast.end()) {

					tipo_cast cast = mapa_cast[chave];

					nome_variavel_temporaria = gera_variavel_temporaria($1.tipo, $1.tamanho);

					if (cast.operando_cast == 0) {
						$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.traducao + " " + $3.label + ";";

					} else if (cast.operando_cast == 1) { 

						string nome_variavel_temporaria_cast = gera_variavel_temporaria(cast.resultado, $1.tamanho);

						$$.traducao = "\t" + $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria_cast + " " + "= " + "(" + cast.resultado + ") " + $1.label + ";\n";

						$$.traducao = $$.traducao + "\t" + nome_variavel_temporaria + " = " + nome_variavel_temporaria_cast + " " + $2.traducao + " " + $3.label + ";";

					} else if (cast.operando_cast == 2) { 

						string nome_variavel_temporaria_cast = gera_variavel_temporaria(cast.resultado, $3.tamanho);

						$$.traducao = "\t" + $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria_cast + " " + "= " + "(" + cast.resultado + ") " + $3.label + ";\n";

						$$.traducao = $$.traducao + "\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.traducao + " " + nome_variavel_temporaria_cast + ";";

					} else {
						//cout << "Erro na linha " << nlinha <<": Verifique os tipos, idiota!" << endl << endl;
						cout << "Erro na linha " << nlinha <<": Não é possível comparar um valor do tipo " << $1.tipo
						<< " com um do tipo " << $3.tipo << endl << endl;
						erro = true;
					}

				} else {
					cout << "Erro na linha " << nlinha <<": Não é possível comparar um valor do tipo " << $1.tipo
						<< " com um do tipo " << $3.tipo << endl << endl;

					erro = true;
				}

				$$.label = nome_variavel_temporaria;
			}
			| E_REL
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
				$$.tamanho = $1.tamanho;
			};

E_REL		: E TK_REL_OP E
			{
				string nome_variavel_temporaria;

				string chave = gera_chave($1.tipo, $3.tipo, $2.label);

				if (mapa_cast.find(chave) != mapa_cast.end()) {
					tipo_cast cast = mapa_cast[chave];

					//TODO verificar se o tamanho está certo
					//nome_variavel_temporaria = gera_variavel_temporaria(cast.resultado, 0);

					if(cast.operando_cast == 0) {

						stringstream traducao;

						traducao << $3.traducao << "\t" + $1.traducao << "\n\t";

						if(!(cast.resultado == "string")) {
							nome_variavel_temporaria = gera_variavel_temporaria(cast.resultado, 0);

							traducao << nome_variavel_temporaria << " = " << $1.label << " " << $2.traducao << " " << $3.label << ";";
						} else {
							string nome_variavel_temporaria_comparacao = gera_variavel_temporaria("boolean", 0);

							traducao << nome_variavel_temporaria_comparacao << " = " << "strcmp(" << $1.label << ", " << $3.label << ");\n\t";

							nome_variavel_temporaria = gera_variavel_temporaria("boolean", 0);

							traducao << nome_variavel_temporaria << " = " << nome_variavel_temporaria_comparacao << " " << $2.traducao << " 0;\n";
						}

						$$.traducao = traducao.str();
					
					} else if(cast.operando_cast == 1) {

						string nome_variavel_temporaria_cast = gera_variavel_temporaria(cast.resultado, $1.tamanho);

						$$.traducao = "\t" + $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria_cast + " " + "= " + "(" + cast.resultado + ") " + $1.label + ";\n";

						$$.traducao = $$.traducao + "\t" + nome_variavel_temporaria + " = " + nome_variavel_temporaria_cast + " " + $2.traducao + " " + $3.label + ";";

					} else if (cast.operando_cast == 2) {

						string nome_variavel_temporaria_cast = gera_variavel_temporaria(cast.resultado, $3.tamanho);

						$$.traducao = "\t" + $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria_cast + " " + "= " + "(" + cast.resultado + ") " + $3.label + ";\n";

						$$.traducao = $$.traducao + "\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.traducao + " " + nome_variavel_temporaria_cast + ";";

					} else{
						cout << "Erro na linha " << nlinha <<": Não é possível comparar um valor do tipo " << $1.tipo << " com um do tipo " << $3.tipo << endl << endl;

						erro = true;
					}

					$$.tipo = "boolean";

				} else {
					cout << "Erro na linha " << nlinha <<": Não é possível comparar um valor do tipo " << $1.tipo
						<< " com um do tipo " << $3.tipo << endl << endl;

					erro = true;
				}

				$$.label = nome_variavel_temporaria;
			}
			| E
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
				$$.tamanho = $1.tamanho;
			};

E 			: E TK_ARIT_OP_S E_TEMP
			{
				string nome_variavel_temporaria;

				string chave = gera_chave($1.tipo, $3.tipo, $2.label);

				if (mapa_cast.find(chave) != mapa_cast.end()) {
					tipo_cast cast = mapa_cast[chave];

					if($1.tipo == "string" && $2.label == "+") {

						nome_variavel_temporaria = gera_variavel_temporaria(cast.resultado, $1.tamanho + $3.tamanho);

						string nome_variavel_temporaria_concatenacao = gera_variavel_temporaria("char*", 0);

						$$.traducao = "\t" + $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria_concatenacao + " = strcat(" + $1.label + ", " + $3.label + ");\n";

						$$.traducao = $$.traducao + "\tstrcpy(" + nome_variavel_temporaria + ", " + nome_variavel_temporaria_concatenacao + ");\n";

						

					} else {

						//TODO verificar se o tamanho está certo
						nome_variavel_temporaria = gera_variavel_temporaria(cast.resultado, 0);

						if (cast.operando_cast == 0) {
							$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.traducao + " " + $3.label + ";";

						} else if (cast.operando_cast == 1) { 

							string nome_variavel_temporaria_cast = gera_variavel_temporaria(cast.resultado, $1.tamanho);

							$$.traducao = "\t" + $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria_cast + " " + "= " + "(" + cast.resultado + ") " + $1.label + ";\n";

							$$.traducao = $$.traducao + "\t" + nome_variavel_temporaria + " = " + nome_variavel_temporaria_cast + " " + $2.traducao + " " + $3.label + ";";

						} else if (cast.operando_cast == 2) { 

							string nome_variavel_temporaria_cast = gera_variavel_temporaria(cast.resultado, $3.tamanho);

							$$.traducao = "\t" + $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria_cast + " " + "= " + "(" + cast.resultado + ") " + $3.label + ";\n";

							$$.traducao = $$.traducao + "\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.traducao + " " + nome_variavel_temporaria_cast + ";";

						} else {
							//cout << "Erro na linha " << nlinha <<": Verifique os tipos, idiota!" << endl << endl;
							cout << "Erro na linha " << nlinha <<": Não é possível operar um valor do tipo " << $1.tipo
								<< " com um do tipo " << $3.tipo << endl << endl;
							erro = true;
						}
					}

					$$.tipo = cast.resultado;

				} else {
					//cout << "Erro na linha " << nlinha <<": Verifique os tipos, idiota!" << endl << endl;
					cout << "Erro na linha " << nlinha <<": Não é possível operar um valor do tipo " << $1.tipo
						<< " com um do tipo " << $3.tipo << endl << endl;
					erro = true;
				}

				$$.label = nome_variavel_temporaria;
			}
			| E_TEMP
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
				$$.tamanho = $1.tamanho;
			};

E_TEMP		: E_TEMP TK_ARIT_OP_M VAL
			{
				string nome_variavel_temporaria;

				string chave = gera_chave($1.tipo, $3.tipo, $2.label);

				if (mapa_cast.find(chave) != mapa_cast.end()) {
					tipo_cast cast = mapa_cast[chave];

					nome_variavel_temporaria = gera_variavel_temporaria(cast.resultado, 0);

					if (cast.operando_cast == 0) {
						$$.traducao = $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.traducao + " " + $3.label + ";";

					} else if (cast.operando_cast == 1) { 

						string nome_variavel_temporaria_cast = gera_variavel_temporaria(cast.resultado, $1.tamanho);

						$$.traducao = "\t" + $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria_cast + " " + "= " + "(" + cast.resultado + ") " + $1.label + ";\n";

						$$.traducao = $$.traducao + "\t" + nome_variavel_temporaria + " = " + nome_variavel_temporaria_cast + " " + $2.traducao + " " + $3.label + ";";

					} else if (cast.operando_cast == 2) { 

						string nome_variavel_temporaria_cast = gera_variavel_temporaria(cast.resultado, $3.tamanho);

						$$.traducao = "\t" + $3.traducao + "\t" + $1.traducao + "\n\t" + nome_variavel_temporaria_cast + " " + "= " + "(" + cast.resultado + ") " + $3.label + ";\n";

						$$.traducao = $$.traducao + "\t" + nome_variavel_temporaria + " = " + $1.label + " " + $2.traducao + " " + nome_variavel_temporaria_cast + ";";

					} else {
						//cout << "Erro na linha " << nlinha <<": Verifique os tipos, idiota!" << endl << endl;
						cout << "Erro na linha " << nlinha <<": Não é possível comparar um valor do tipo " << $1.tipo
						<< " com um do tipo " << $3.tipo << endl << endl;
						erro = true;
					}

					$$.tipo = cast.resultado;

				} else {

					//cout << "Erro na linha " << nlinha <<": Verifique os tipos, idiota!" << endl << endl;
					cout << "Erro na linha " << nlinha <<": Não é possível comparar um valor do tipo " << $1.tipo
						<< " com um do tipo " << $3.tipo << endl << endl;
					erro = true;
				}

				$$.label = nome_variavel_temporaria;
			}
			| E_NOT
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
				$$.tamanho = $1.tamanho;
			};

E_NOT		: TK_NOT E_NOT
			{
				string nome_variavel_temporaria;

				if ($2.tipo == "boolean") {

					nome_variavel_temporaria = gera_variavel_temporaria($2.tipo, 0);

					$$.traducao = $2.traducao + "\n\t" + nome_variavel_temporaria + " = " + $1.traducao + $2.label + ";";
					
				}else {
					//cout << "Erro na linha " << nlinha <<": Verifique os tipos, idiota!" << endl << endl;
					cout << "Erro na linha " << nlinha <<": Não é possível negar um valor do tipo " << $1.tipo
						<< " com um do tipo " << $2.tipo << endl << endl;
					erro = true;
				}

				$$.tipo = $2.tipo;
				$$.label = nome_variavel_temporaria;
			}
			| VAL
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
				$$.tamanho = $1.tamanho;
			};

VAL			: '(' TIPO ')' VAL
			{
				string nome_variavel_temporaria_cast;

				string chave = gera_chave($2.label, $4.tipo, "=");

				if (mapa_cast.find(chave) != mapa_cast.end()) {
					tipo_cast cast = mapa_cast[chave];

					nome_variavel_temporaria_cast = gera_variavel_temporaria(cast.resultado, $4.tamanho);

					$$.traducao = "\t" + $4.traducao + "\n\t" + nome_variavel_temporaria_cast + " " + "= " + "(" + cast.resultado + ") " + $4.label + ";";

					$$.tipo = cast.resultado;
					$$.tamanho = $4.tamanho;
					$$.label = nome_variavel_temporaria_cast;
				} else {
					cout << "Erro na linha " << nlinha <<": Não é possível fazer cast de um valor do tipo " << $2.tipo
						<< " com um do tipo " << $4.tipo << endl << endl;

					erro = true;
				}
			}
			| '(' E_OP_OR ')'
			{
				$$.label = $2.label;
				$$.traducao = $2.traducao;
				$$.tipo = $2.tipo;
			}
//****************************
			| TK_ID '(' PARAMETROS ')'
			{
				info_funcao *funcao = recupera_funcao($1.label);

				if(funcao) {

					if(funcao->parametros.size() == lista_parametros.size()) {
						
						for(int i = 0; i < funcao->parametros.size(); i++) {

							string tipo_parametro = funcao->posicoes_parametros[i];

							if(tipo_parametro != lista_parametros[i]) {
								cout << "Erro na linha " << nlinha << ": O tipo do argumento " << (i+1) << "(" << lista_parametros[i] << ") não condiz com tipo esperado pela função (" << tipo_parametro << ")\n";
								erro = true;

								break;
							}
						}

						$$.label = funcao->nome_temp + "(" + $3.traducao + ")";
						$$.traducao = $3.label + "\n";
						

					} else {
						cout << "Erro na linha " << nlinha << ": A função \"" << $1.label << "\" espera receber " << funcao->parametros.size() << " parâmetros, mas foram passados " << lista_parametros.size() << "\n";
						erro = true;
					}

					$$.tipo = funcao->tipo;

					cout << "\n\n" << $$.label << "\n\n";

					lista_parametros.clear();

					if(funcao->tipo == "string") {
						$$.tamanho = 1024;
					} else {
						$$.tamanho = 0;
					}

				} else {
					cout << "Erro na linha " << nlinha << ": Função \"" << $1.label << "\" não declarada\n";
					erro = true;
				}
			}
//****************************			

			| TK_LOGICO
			{
				string nome_variavel_temporaria = gera_variavel_temporaria($1.tipo, $1.tamanho);

				//TODO Verificar se essa atribuição está certa
				$$.label = nome_variavel_temporaria;
				$$.traducao = "\n\t" + nome_variavel_temporaria + " = " + $1.traducao + ";";
				$$.tipo = $1.tipo;
			}
			| TK_NUM
			{
				string nome_variavel_temporaria = gera_variavel_temporaria($1.tipo, $1.tamanho);

				$$.label = nome_variavel_temporaria;
				$$.traducao = "\n\t" + nome_variavel_temporaria + " = " + $1.traducao + ";";
				$$.tipo = $1.tipo;
			}
			| TK_ID
			{
				
				info_variavel *variavel = recupera_variavel($1.label);
				
				if(!variavel) {
					cout << "Erro na linha " << nlinha <<": Variável \"" << $1.label << "\" não declarada neste escopo" << endl << endl;

					erro = true;

					$$.label = "";
					$$.traducao = "";
					$$.tipo = "undeclared";
				} else {
					$$.label = variavel->nome_temp;
					$$.traducao = "";
					$$.tipo = variavel->tipo;
				}
			}
			| TK_FLOAT
			{
				string nome_variavel_temporaria = gera_variavel_temporaria($1.tipo, $1.tamanho);

				$$.label = nome_variavel_temporaria;
				$$.traducao = "\n\t" + nome_variavel_temporaria + " = " + $1.traducao + ";";
				$$.tipo = $1.tipo;
			}
			| TK_LONG
			{
				string nome_variavel_temporaria = gera_variavel_temporaria($1.tipo, $1.tamanho);

				$$.label = nome_variavel_temporaria;
				$$.traducao = "\n\t" + nome_variavel_temporaria + " = " + $1.traducao + ";";
				$$.tipo = $1.tipo;	
			}
			| TK_DOUBLE
			{
				string nome_variavel_temporaria = gera_variavel_temporaria($1.tipo, $1.tamanho);

				$$.label = nome_variavel_temporaria;
				$$.traducao = "\n\t" + nome_variavel_temporaria + " = " + $1.traducao + ";";
				$$.tipo = $1.tipo;	
			}
			| TK_STRING
			{
				stringstream traducao;
				string nome_variavel_temporaria = gera_variavel_temporaria($1.tipo, $1.tamanho);
							
				traducao << "\n\tstrcpy(" << nome_variavel_temporaria << ", \"" << $1.label << "\");\n";
				
				$$.traducao = traducao.str();
				$$.label = nome_variavel_temporaria;
				$$.tipo = $1.tipo;
				$$.tamanho = $1.tamanho;
			}
			| ATR_UNARIA
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
				$$.tipo = $1.tipo;
			}
			| TK_AMPERSAND VAL
			{
				stringstream traducao;
				
				if($2.tipo == "string") {
					string nome_variavel_temporaria = gera_variavel_temporaria("int", 1);

					traducao << nome_variavel_temporaria << " = (int) " << $2.label << "[0];\n";
					
					$$.traducao = traducao.str();
					$$.label = nome_variavel_temporaria;
					
				} else {
					cout << "Erro na linha " << nlinha <<": Impossível aplicar a operação & a uma variável do tipo " << $2.tipo << endl << endl;
					erro = true;
				}
				
				$$.tipo = "int";
				$$.tamanho = 0;
			}
			| TK_ID '[' TK_NUM ']'
			{
				stringstream traducao;
				
				if($1.tipo == "string") {
				
					info_variavel *variavel = recupera_variavel($1.label);
					
					if(variavel) {
					
						string nome_variavel_temporaria = gera_variavel_temporaria($1.tipo, 1);
						traducao << "\n\tstrncpy(" << nome_variavel_temporaria << ", " << variavel->nome_temp << "+" << $3.label << ", 1);\n";
						
						$$.traducao = traducao.str();
						$$.label = nome_variavel_temporaria;
						$$.tipo = $1.tipo;
						$$.tamanho = 2;
					} else {
						cout << "Erro na linha " << nlinha <<": Variável \"" << $1.label << "\" não declarada neste escopo" << endl << endl;
						erro = true;
					}
				} else {
					cout << "Erro na linha " << nlinha <<": Impossível aplicar slice a uma variável do tipo " << $1.tipo << endl << endl;
					erro = true;
				}
			};

ATR_UNARIA	: TK_INCREMENTO TK_ID
			{
				info_variavel *variavel = recupera_variavel($2.label);

				if(variavel) {

					if(variavel->tipo != "string" && variavel->tipo != "boolean") {
						$$.traducao = "\n\t" + variavel->nome_temp + " = " + variavel->nome_temp + " + 1;\n";
						$$.label = variavel->nome_temp;
					} else {
						cout << "Erro na linha " << nlinha << ": A operacao ++ não pode ser utilizada com uma variável do tipo " << variavel->tipo << endl << endl;
						erro = true;
					}
					
				} else {
					cout << "Erro na linha " << nlinha <<": Variável \"" << $1.label << "\" não declarada neste escopo" << endl << endl;
						erro = true;
				}
				
			}
			| TK_DECREMENTO TK_ID
			{
				info_variavel *variavel = recupera_variavel($2.label);

				if(variavel) {

					if(variavel->tipo != "string" && variavel->tipo != "boolean") {
						$$.traducao = "\n\t" + variavel->nome_temp + " = " + variavel->nome_temp + " - 1;\n";
						$$.label = variavel->nome_temp;
					} else {
						cout << "Erro na linha " << nlinha << ": A operacao -- não pode ser utilizada com uma variável do tipo " << variavel->tipo << endl << endl;
						erro = true;
					}
					
				} else {
					cout << "Erro na linha " << nlinha <<": Variável \"" << $1.label << "\" não declarada neste escopo" << endl << endl;
						erro = true;
				}
			}

TK_REL_OP	: TK_MENOR
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			}
			| TK_MAIOR
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			}
			| TK_MENOR_IGUAL
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			}
			| TK_MAIOR_IGUAL
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			}
			| TK_IGUAL
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			}
			| TK_DIFERENTE
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			};

TK_ARIT_OP_S: TK_SOMA
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			}
			| TK_SUB
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			};

TK_ARIT_OP_M: TK_MUL
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			}
			| TK_DIV
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			}
			| TK_RESTO
			{
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			};

/*
ID_FUNCAO	: TK_ID 
			{
				info_funcao *funcao = recupera_funcao($1.label);

				if(!funcao) {
					cout << "Erro na linha " << nlinha <<": Função \"" << $1.label << "\" não declarada" << endl << endl;

					erro = true;

					$$.label = "";
					$$.traducao = "";
					$$.tipo = "undeclared";
				} else {
					$$.label = funcao->nome_temp;
					$$.traducao = "";
					$$.tipo = funcao->tipo;
				}
			};
*/

TIPO 		: TK_TIPO_INT
			{
				$$.label = $1.label;
				//$$.traducao = "";
				$$.traducao = $1.traducao;
			}
			| TK_TIPO_FLOAT
			{
				$$.label = $1.label;
				//$$.traducao = "";
				$$.traducao = $1.traducao;
			}
			| TK_TIPO_BOOL
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
			}
			| TK_TIPO_LONG
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
			}
			| TK_TIPO_DOUBLE
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
			}
			| TK_TIPO_STRING
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
			};
			
TIPO_FUNC	: TIPO
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
			}
			| TK_VOID
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
				$$.tipo = $1.tipo;
			}

%%

#include "lex.yy.c"

int yyparse();

string gera_variavel_temporaria(string tipo, int tamanho, string nome, bool parametro) {

	stringstream nome_temporario;
	string nome_mapa;

	string tipo_ponteiro = tipo;

	if(tipo_ponteiro[tipo_ponteiro.size() - 1] == '*') {
		tipo_ponteiro.replace(tipo_ponteiro.end() - 1, tipo_ponteiro.end(), "");
	}

	nome_temporario << "temp_" << tipo_ponteiro << "_";

	if (!nome.empty()) {
		nome_temporario << nome << "_" << contador;
		nome_mapa = nome;
	} else {
		nome_temporario << "exp_" << contador;
		nome_mapa = nome_temporario.str();
	}

	contador++;

	info_variavel atributos = {tipo, nome_temporario.str(), tamanho, parametro};
	if(!recupera_variavel(nome_mapa, pilha_contexto.back())) {

		pilha_contexto.back()[nome_mapa] = atributos;

	} else {
		cout << "Erro na linha " << nlinha <<": Você já declarou a variável \"" << nome << "\"." << endl << endl;
		erro = true;
	}

	return nome_temporario.str();
}

string gera_chave(string operador1, string operador2, string operacao) {

	return operador1 + "_" + operacao + "_" + operador2;
}

void gera_mapa_cast() {

	FILE* file2 = fopen("./src/mapa_cast.txt", "r");

	char operador1[20] = "";
	char operador2[20] = "";
	char operacao[3] = "";

	char resultado[20] = "";
	int operando_cast;

	while(fscanf(file2, "%s\t%s\t%s\t%s\t%d\n", operador1, operacao, operador2, resultado, &operando_cast)) {

		tipo_cast cast = {resultado, operando_cast};

		mapa_cast[gera_chave(operador1, operador2, operacao)] = cast;

		//cout << operador1 << " " << operador2 << " " << operacao;

		if(feof(file2)) {
			break;
		}
	}

	fclose(file2);
}

void gera_mapa_traducao_tipo() {

	mapa_traducao_tipo["string"] = "char";
	mapa_traducao_tipo["int"] = "int";
	mapa_traducao_tipo["float"] = "float";
	mapa_traducao_tipo["double"] = "double";
	mapa_traducao_tipo["long"] = "long";
	mapa_traducao_tipo["boolean"] = "int";

	mapa_traducao_tipo["string*"] = "char*";
	mapa_traducao_tipo["int*"] = "int*";
	mapa_traducao_tipo["float*"] = "float*";
	mapa_traducao_tipo["double*"] = "double*";
	mapa_traducao_tipo["long*"] = "long*";
	mapa_traducao_tipo["boolean*"] = "int*";

	mapa_traducao_tipo["char*"] = "char*";
}

void gera_mapa_valor_padrao() {

	mapa_valor_padrao["string"] = "\"\"";
	mapa_valor_padrao["int"] = "0";
	mapa_valor_padrao["float"] = "0.0";
	mapa_valor_padrao["double"] = "0.0D";
	mapa_valor_padrao["long"] = "0L";
	mapa_valor_padrao["boolean"] = "0";
	mapa_valor_padrao["char"] = "\'\0\'";
}

map<string, info_variavel> recupera_escopo_atual() {

	return pilha_contexto.back();
}

info_variavel *recupera_variavel(string nome) {
	for (int i = pilha_contexto.size() - 1; i >= 0; i--) {

		info_variavel *variavel = recupera_variavel(nome, pilha_contexto[i]);

		if(variavel) {
			return variavel;
		}
	}

	return (info_variavel *) 0;
}

info_variavel *recupera_variavel(string nome, map<string, info_variavel> mapa_contexto) {
	if(mapa_contexto.find(nome) != mapa_contexto.end()) {
		return &mapa_contexto[nome];
	}

	return (info_variavel *) 0;
}

int contador_label = 0;

conjunto_label gera_label(string nome_estrutura, bool usar_ultima, bool loop) {

	string inicio;
	string proximo;
	string fim;

	conjunto_label label_atual;

	if(!loop) {
		if(usar_ultima) {

			if(pilha_label.size() > 0) {
				conjunto_label conjunto_anterior = pilha_label.back();

				//inicio = conjunto_anterior.fim;
				inicio = conjunto_anterior.proximo;
				proximo = "prox_" + inicio;
				//fim = "end_" + inicio;
				fim = conjunto_anterior.fim;

				pilha_label.pop_back();

			} else {

				cout << nome_estrutura << endl << endl;

				cout << "Erro interno na linha " << nlinha << ": Nenhum label foi criado ainda" << endl << endl;
				erro = true;
			}
		} else {

			stringstream temp;

			temp << nome_estrutura << "_" << contador_label;

			inicio = temp.str();
			proximo = "prox_" + inicio;
			fim = "end_" + inicio;

			contador_label++;
		}

		label_atual = (conjunto_label) {inicio, proximo, fim};

		pilha_label.push_back(label_atual);

	} else {
		stringstream temp;

		temp << nome_estrutura << "_" << contador_label;

		inicio = temp.str();
		fim = "end_" + inicio;

		contador_label++;

		label_atual = (conjunto_label) {inicio, proximo, fim};

		pilha_label_loop.push_back(label_atual);
	}

	return label_atual;
}

conjunto_label recupera_label(bool loop) {

	if(loop) {
		return pilha_label_loop.back();
	} else {
		return pilha_label.back();
	}
}

void exclui_label(bool loop) {

	if(loop) {
		pilha_label_loop.pop_back();
	} else {
		pilha_label.pop_back();
	}
}

string gera_declaracoes_variaveis() {
	stringstream variaveis;

	map<string, info_variavel> mapa_variavel = mapa_global_variavel;

	for (std::map<string, info_variavel>::iterator it=mapa_variavel.begin(); it!=mapa_variavel.end(); ++it) {

		variaveis << "\t";
		if(mapa_traducao_tipo.find(it->second.tipo) != mapa_traducao_tipo.end()) {

			variaveis << mapa_traducao_tipo[it->second.tipo];
		} else {

			variaveis << it->second.tipo;
		}

		variaveis << " " << it->second.nome_temp;

		if(it->second.tipo == "string" || it->second.tipo == "string*") {
			variaveis << "[" << (it->second.tamanho + 1) << "]";
		}

		variaveis << ";\n";
	}

	mapa_global_variavel.clear();

	return variaveis.str();
}

string gera_funcao_temporaria(string tipo, string nome, map<string, info_variavel> parametros, vector<string> posicoes_parametros) {

	stringstream nome_temporario;
	string nome_mapa;

	string tipo_ponteiro = tipo;

	if(tipo_ponteiro[tipo_ponteiro.size() - 1] == '*') {
		tipo_ponteiro.replace(tipo_ponteiro.end() - 1, tipo_ponteiro.end(), "");
	}

	nome_temporario << nome << "_" << tipo;

	for(map<string, info_variavel>::iterator it = parametros.begin(); it != parametros.end(); ++it) {
		nome_temporario << "_" << it->second.tipo;
	}
	
	nome_mapa = nome;

	/*
	for (map<string, info_variavel>::iterator it = parametros.begin(); it != parametros.end(); ++it) {

		info_variavel variavel = it->second;

		gera_variavel_temporaria(variavel.tipo, variavel.tamanho, it->first, true);
	}
	*/

	info_funcao atributos_funcao = {nome_temporario.str(), tipo, 0, parametros, posicoes_parametros};
	if(!recupera_funcao(nome_mapa)) {

		mapa_funcao[nome_mapa] = atributos_funcao;

	} else {
		cout << "Erro na linha " << nlinha <<": Você já declarou a função \"" << nome << "\"." << endl << endl;
		erro = true;
	}


	//gera_variavel_temporaria(string tipo, int tamanho, string nome)

	//gera_variavel_temporaria(tipo, 0, string nome, true);

	/*
	info_variavel atributos = {tipo, nome_temporario.str(), parametros};
	if(!recupera_variavel(nome_mapa, pilha_contexto.back())) {

		pilha_contexto.back()[nome_mapa] = atributos;

	} else {
		cout << "Erro na linha " << nlinha <<": Você já declarou a variável \"" << nome << "\"." << endl << endl;
		erro = true;
	}
	*/

	return nome_temporario.str();
}

info_funcao *recupera_funcao(string nome) {

	if(mapa_funcao.find(nome) != mapa_funcao.end()) {
		return &mapa_funcao[nome];
	}

	return (info_funcao *) 0;
}

void inicializa_escopo() {
	map<string, info_variavel> mapa_contexto;

	pilha_contexto.push_back(mapa_contexto);
}

void finaliza_escopo() {

	ultimo_contexto = pilha_contexto.back();

	mapa_global_variavel.insert(ultimo_contexto.begin(), ultimo_contexto.end());

	pilha_contexto.pop_back();

	//pilha_label.clear();
	//pilha_label_loop.clear();
}

void adiciona_biblioteca_cabecalho(string nome_biblioteca) {
	cabecalho << "#include <" << nome_biblioteca << ">" << endl;
}

int main( int argc, char* argv[] )
{
	gera_mapa_cast();
	gera_mapa_traducao_tipo();
	gera_mapa_valor_padrao();

	yyparse();

	return 0;
}

void yyerror( string MSG )
{
	cout << MSG << " on line " << nlinha << endl;
	exit (0);
}				
