%{
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <queue>
#include <string>
using namespace std;

#define print(x) sprintf(temp,x);mystack.push(string(temp))
#define printa(x,a) sprintf(temp,x,a);mystack.push(string(temp))

void yyerror(const char * msg);
extern unsigned int line;
extern unsigned int currPos;
extern char* yytext;
extern char* ID;
extern int yylex();
extern FILE * yyin;

queue<string> mystack;
char temp[80];
%}

%union{
  int       ival;
  char*     idval;
}

%error-verbose
%token PROGRAM BEGIN_PROGRAM END_PROGRAM ARRAY OF IF THEN ENDIF ELSE WHILE BEGINLOOP ENDLOOP READ WRITE BREAK CONTINUE EXIT AND OR NOT TRUE FALSE ADD SUB MULT DIV MOD EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_PAREN R_PAREN ASSIGN QUESTION INTEGER
%token  <ival>  NUMBER 
%type   <ival>  Expression 
%token  <idval> IDENT
%left   ADD SUB
%left   MULT DIV MOD
%nonassoc USUB

%%


Program:
      PROGRAM {print("program -> PROGRAM \n");} Ident SEMICOLON {print("semicolon -> SEMICOLON \n");} Block END_PROGRAM {print("end_program -> END_PROGRAM \n");}
;

        
Block:
      BlockDeclarationLoop BEGIN_PROGRAM {print("begin_program -> BEGIN_PROGRAM \n");} BlockStatmentLoop
;

        
BlockDeclarationLoop:
      /* empty */
|     Declaration SEMICOLON {print("semicolon -> SEMICOLON \n");} BlockDeclarationLoop
;

BlockStatmentLoop:
      /* empty */
|     Statement SEMICOLON {print("semicolon -> SEMICOLON \n");} BlockStatmentLoop
;


Declaration:
      DeclarationIdentLoop COLON {print("colon -> COLON \n");} Declaration_End
;

Declaration_End:
      INTEGER {print("integer -> INTEGER \n");}
|     ARRAY {print("array -> ARRAY \n");} L_Paren NUMBER {printa("number -> NUMBER (%s) \n", yytext);} R_Paren OF {print("of -> OF \n");} INTEGER {print("integer -> INTEGER \n");}
;

DeclarationIdentLoop:
      Ident
|     Ident COMMA {print("comma -> COMMA \n");} DeclarationIdentLoop
;

Statement:
      Var_ Assign Expression {printa("statement -> var# assign# expression#%d \n",line-1);}
|     Var_ Assign Bool_Exp {print("bool_exp ->  \n");} QUESTION {{print("question -> QUESTION \n");}} Expression {print("expression -> ");} COLON {print("colon -> COLON \n");} Expression {print("expression -> ");}
|     IF {print("if -> IF \n");} Bool_Exp {print("bool_exp ->  \n");} THEN {print("then -> THEN \n");} BlockStatmentLoop S_Else
|     WHILE {print("while -> WHILE \n");} Bool_Exp {print("bool_exp ->  \n");} BEGINLOOP {print("beginloop -> BEGINLOOP \n");} BlockStatmentLoop ENDLOOP {printa("endloop -> ENDLOOP (%d) \n",line-1);}
|     READ {print("read -> READ \n");} DeclarationIdentLoop
|     WRITE {print("write -> WRITE \n");} DeclarationIdentLoop
|     BREAK {print("break -> BREAK \n");}
|     CONTINUE {print("continue -> CONTINUE \n");}
|     EXIT {print("exit -> EXIT \n");}
;

Assign:
      ASSIGN {print("assign -> ASSIGN \n");}
;

Var_: 
      Var {printa("var -> ident#%d \n",line-1);}
;

S_Else:
      ELSE {print("else -> ELSE \n");} BlockStatmentLoop ENDIF {print("endif -> ENDIF \n");}
|     ENDIF {print("endif -> ENDIF \n");}

Bool_Exp:
      Relation_Exp {print("bool_exp -> relation_exp \n");} Bool_ExpLoop
;

Bool_ExpLoop:
      /* empty */
|     OR {print("or -> OR \n");} Relation_And_Exp {print("relation_and_exp -> \n");} Bool_ExpLoop
;

Relation_And_Exp:
      Relation_Exp {print("relation_and_exp -> relation_exp \n");} Relation_And_ExpLoop
;

Relation_And_ExpLoop:
      /* empty */
|     AND Relation_Exp {print("relation_exp -> \n");} Relation_And_ExpLoop
;

Relation_Exp:
      Expression {print("relation_exp2 -> expression ");} Comp Expression {print("relation_exp2 -> expression ");}
|     TRUE {print("true -> TRUE \n");}
|     FALSE {print("false -> FALSE \n");}
|     L_Paren Bool_Exp R_Paren
|     NOT Expression {print("expression -> ");} Comp Expression {print("expression -> ");}
|     NOT TRUE {print("true -> TRUE \n");}
|     NOT FALSE {print("false -> FALSE \n");}
|     NOT L_Paren Bool_Exp R_Paren
;

Comp:
      EQ {print("comp-> EQ ");}
|     NEQ {print("comp-> NEQ ");}
|     LT {print("comp-> LT ");}
|     GT {print("comp-> GT ");}
|     LTE {print("comp-> LTE ");}
|     GTE {print("comp-> GTE ");}
;

Expression:
      Multiplicative_Exp {print("expression -> multiplicative_exp \n");}
|     Multiplicative_Exp {print("expression -> multiplicative_exp \n");} ADD {print("add -> ADD \n");} ExpressionLoop
|     Multiplicative_Exp {print("expression -> multiplicative_exp \n");} SUB {print("sub -> SUB \n");} ExpressionLoop

;

ExpressionLoop:
      Multiplicative_Exp {print("expression -> multiplicative_exp \n");}
|     Multiplicative_Exp {print("expression -> multiplicative_exp \n");} ADD {print("add -> ADD \n");} ExpressionLoop
|     Multiplicative_Exp {print("expression -> multiplicative_exp \n");} SUB {print("sub -> SUB \n");} ExpressionLoop
;

Multiplicative_Exp:
      Term
|     Term MULT {print("mult -> MULT \n");} Multiplicative_ExpLoop
|     Term DIV {print("div -> DIV \n");} Multiplicative_ExpLoop
|     Term MOD {print("mod -> MOD \n");} Multiplicative_ExpLoop
;

Multiplicative_ExpLoop:
      Term
|     Term MULT {print("mult -> MULT \n");} Multiplicative_ExpLoop
|     Term DIV {print("div -> DIV \n");} Multiplicative_ExpLoop
|     Term MOD {print("mod -> MOD \n");} Multiplicative_ExpLoop
;

Term:
      Factor
|     SUB {print("sub -> SUB \n");} Factor
;

Factor:
      Var {print("var -> VAR \n");}
|     NUMBER {printa("number -> NUMBER(%i) \n", $1);}
|     L_Paren Expression R_Paren
;

Var:
      Ident
|     Ident L_Paren Expression R_Paren
;

L_Paren:
      L_PAREN {print("l_parent -> L_PAREN \n");}
;

R_Paren:
      R_PAREN {print("r_paren -> R_PAREN \n");}
;

Ident:
      IDENT {printa("ident -> IDENT (%s) \n", $1);}
;

%%

int main()
{
      yyparse();

      while (!mystack.empty())
      {
            printf("%s", mystack.front().c_str());
            mystack.pop();
      }
    
      return 0;
}


void yyerror(const char* msg)
{
      printf("** Line %d, position %d: %s\n", line, currPos, msg);
      exit(0);
}
