%{
/***************************************************************************
    CS152 Compiler Design - Project 3
    Daniel Pasillas
    John Castillo
    
    Terminals: UPPER CASE
    Non-Terminals: Mixed Case
***************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <queue>
#include <stack>
#include <set>
#include <string>
#include <ctype.h>
#include <cstring>

using namespace std;

#define print(x) sprintf(temp,x),mystack.push(string(temp))
#define print1(x,a) sprintf(temp,x,a),mystack.push(string(temp))
#define print2(x,a,b) sprintf(temp,x,a,b),mystack.push(string(temp))
#define print3(x,a,b,c) sprintf(temp,x,a,b,c),mystack.push(string(temp))
#define print4(x,a,b,c,d) sprintf(temp,x,a,b,c,d),mystack.push(string(temp))
#define print5(x,a,b,c,d,e) sprintf(temp,x,a,b,c,d,e),mystack.push(string(temp))
#define print6(x,a,b,c,d,e,f) sprintf(temp,x,a,b,c,d,e,f),mystack.push(string(temp))
#define print7(x,a,b,c,d,e,f,g) sprintf(temp,x,a,b,c,d,e,f,g),mystack.push(string(temp))

#define vprint(x) sprintf(temp,x),varDeclarations.push(string(temp))
#define vprint1(x,a) sprintf(temp,x,a),varDeclarations.push(string(temp))
#define vprint2(x,a,b) sprintf(temp,x,a,b),varDeclarations.push(string(temp))
#define vprint3(x,a,b,c) sprintf(temp,x,a,b,c),varDeclarations.push(string(temp))
#define vprint4(x,a,b,c,d) sprintf(temp,x,a,b,c,d),varDeclarations.push(string(temp))
#define vprint5(x,a,b,c,d,e) sprintf(temp,x,a,b,c,d,e),varDeclarations.push(string(temp))
#define vprint6(x,a,b,c,d,e,f) sprintf(temp,x,a,b,c,d,e,f),varDeclarations.push(string(temp))
#define vprint7(x,a,b,c,d,e,f,g) sprintf(temp,x,a,b,c,d,e,f,g),varDeclarations.push(string(temp))

#define eprint(x) sprintf(temp,x),errors.push(string(temp))
#define eprint1(x,a) sprintf(temp,x,a),errors.push(string(temp))
#define eprint2(x,a,b) sprintf(temp,x,a,b),errors.push(string(temp))
#define eprint3(x,a,b,c) sprintf(temp,x,a,b,c),errors.push(string(temp))
#define eprint4(x,a,b,c,d) sprintf(temp,x,a,b,c,d),errors.push(string(temp))
#define eprint5(x,a,b,c,d,e) sprintf(temp,x,a,b,c,d,e),errors.push(string(temp))
#define eprint6(x,a,b,c,d,e,f) sprintf(temp,x,a,b,c,d,e,f),errors.push(string(temp))
#define eprint7(x,a,b,c,d,e,f,g) sprintf(temp,x,a,b,c,d,e,f,g),errors.push(string(temp))

void yyerror(const char * msg);
void userVariables(int numElements);
int if_routine();
int else_routine();
void rwStringsFormat(int bit);
int isNumber(char * str);
char* binaryOperator(const char *op, const char *left, const char *right);
void checkInt(const char * str);
void checkArray(const char * str);

extern unsigned int line;
extern unsigned int currPos;
extern char* yytext;
extern char* ID;
extern int yylex();
extern FILE * yyin;
int tokenNum = 0;
int pNum = 0;
int tNum = 0;
int lNum = 0;

queue<string> mystack, varDeclarations, errors;
stack<string> usrVars, endLabels, startLabels, ifEndLabels, ifElseLabels;
queue<string> rwStrings;
set<string> intNames, arrayNames;
string declStr;
char misc[256];
char temp[256];
char fileName[256] = {0};
%}

%union{
  int           ival;
  const char*   idval;
}

%error-verbose
%token PROGRAM BEGIN_PROGRAM END_PROGRAM ARRAY OF IF THEN ENDIF ELSE WHILE BEGINLOOP ENDLOOP READ WRITE BREAK CONTINUE EXIT AND OR NOT TRUE FALSE ADD SUB MULT DIV MOD EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_PAREN R_PAREN ASSIGN QUESTION INTEGER
%token<ival>  NUMBER
%type<idval>  Expression Var LVar RWVar Ident L_Paren R_Paren Add Sub Mult Div Mod Program Semicolon EndProgram BeginProgram Term Factor Comp Multiplicative_Exp Block Else EndIf If Assign Or And Colon BlockDeclarationLoop BlockStatmentLoop Comma Declaration Of Integer Array DeclarationIdentLoop While Write Read Break EndLoop Continue Exit Statement ProgStart NoElse EColon RWVarLoop Bool_Then Bool_BeginL Bool_Question Ternary_First
%type<ival>  Declaration_End Number Then Question Bool_Exp Relation_And_Exp Relation_Exp BeginLoop
%token<idval> IDENT
%left   ADD SUB
%left   MULT DIV MOD

%%


ProgStart:
      Program Ident Semicolon Block EndProgram { $$ = ""; sprintf(fileName,"%s.mil",$2); }
;

        
Block:
      BlockDeclarationLoop BeginProgram BlockStatmentLoop { $$ = ""; }
;

        
BlockDeclarationLoop:
      /* empty */ { $$ = ""; }
|     Declaration Semicolon BlockDeclarationLoop { $$ = ""; }
;

BlockStatmentLoop:
      /* empty */ { $$ = ""; }
|     Statement Semicolon BlockStatmentLoop { $$ = ""; }
;


Declaration:
      DeclarationIdentLoop Colon Declaration_End { $$ = ""; userVariables($3); }
;

Declaration_End:
      Integer { $$ = -1; }
|     Array L_Paren Number R_Paren Of Integer { $$ = $3; if($3 < 1)
            eprint2("** Line %d, Position %d: Illegal array size.\n",line,currPos); }
;

DeclarationIdentLoop:
      Ident { $$ = ""; usrVars.push($1); }
|     Ident Comma DeclarationIdentLoop { $$ = ""; usrVars.push($1); }
;

RWVarLoop:
      RWVar { $$ = $1; rwStrings.push($1);/*print1("%s\n",$1);*/ delete (char*)$1; } // OP Var
|     RWVarLoop Comma RWVar { $$ = $1; rwStrings.push($3); /*print1("%s\n",$1);*/ delete (char*)$3; }
;

Statement:
      LVar Assign Expression { $$ = ""; 
        if(string($1).find_first_of(",") == string::npos)
            print2("   = %s, %s\n",$1,$3);
        else
            print2("   []= %s, %s\n",$1,$3);
        
        delete (char*)$1; delete(char*)$3; }
      
|     Ternary_First EColon Expression  {
            $$ = "";
            
            if(string($1).find_first_of(",") == string::npos)
                print2("   = %s, %s\n",$1,$3);
            else
                print2("   []= %s, %s\n",$1,$3);
                
            print1(": %s\n",ifEndLabels.top().c_str());
            ifEndLabels.pop();
            
            delete (char*)$1; delete(char*)$3; }
            
|     If Bool_Then BlockStatmentLoop NoElse EndIf { $$ = ""; }
        
|     If Bool_Then BlockStatmentLoop Else BlockStatmentLoop EndIf { $$ = ""; }
            
|     While Bool_BeginL BlockStatmentLoop EndLoop { $$ = ""; }
        
|     Read RWVarLoop { $$ = $2; rwStringsFormat(0); }

|     Write RWVarLoop { $$ = $2; rwStringsFormat(1); }

|     Break { 
                $$ = "";
                if(endLabels.size()){
                    print1("   := %s\n",endLabels.top().c_str());
                }
                else{
                    eprint2("** Line %d, Position %d: Break statement outside of loop.\n",line,currPos);
                }
                
            }
|     Continue {
                    $$ = "";
                    if(startLabels.size()){ 
                        print1("   := %s\n",startLabels.top().c_str());
                    }
                    else{
                        eprint2("** Line %d, Position %d: Continue statement outside of loop.\n",line,currPos);
                    }
                    
               }
|     Exit { $$ = ""; print("   := EndLabel\n");}
;

Ternary_First:
      LVar Assign Bool_Question Expression {
        $$ = $1;
        if(string($1).find_first_of(",") == string::npos)
            print2("   = %s, %s\n",$1,$4);
        else
            print2("   []= %s, %s\n",$1,$4);
        delete (char*)$4;
      }
;

Bool_Then:
      Bool_Exp Then { $$ = ""; print2("   == p%d, p%d, 0\n",$2,$1); print2("   ?:= %s, p%d\n",ifElseLabels.top().c_str(),$2); }
;

Bool_Question:
      Bool_Exp Question { $$ = ""; print2("   == p%d, p%d, 0\n",$2,$1);  print2("   ?:= %s, p%d\n",ifElseLabels.top().c_str(),$2); }
;

Bool_BeginL:
      Bool_Exp BeginLoop { $$ = ""; print2("   == p%d, p%d, 0\n",$2,$1);  print2("   ?:= %s, p%d\n",endLabels.top().c_str(),$2); }
;

Bool_Exp:
      Relation_And_Exp { $$ = $1; }
|     Relation_And_Exp Or Bool_Exp { $$ = pNum++; vprint1("   . p%d\n",$$);
            print3("   || p%d, p%d, p%d\n",$$,$1,$3); }
;


Relation_And_Exp:
      Relation_Exp { $$ = $1; }
|     Relation_And_Exp And Relation_Exp { $$ = pNum++; vprint1("   . p%d\n",$$);
            print3("   && p%d, p%d, p%d\n",$$,$1,$3); }
;

Relation_Exp:
      Expression Comp Expression { $$ = pNum++; vprint1("   . p%d\n",$$);
            print4("   %s p%d, %s, %s\n",$2,$$,$1,$3); delete (char*)$1; delete (char*)$3; }
|     TRUE { $$ = pNum++; vprint1("   . p%d\n",$$); print1("   = p%d, 1\n",$$);}
|     FALSE { $$ = pNum++; vprint1("   . p%d\n",$$); print1("   = p%d, 0\n",$$);}
|     L_Paren Bool_Exp R_Paren { $$ = $2;}
|     NOT Relation_Exp { $$ = pNum++; vprint1("   . p%d\n",$$); print2("   == p%d, p%d, 0\n",$$, $2); }
;

Comp:
      EQ { $$ = "=="; }
|     NEQ { $$ = "!="; }
|     LT { $$ = "<"; }
|     GT { $$ = ">"; }
|     LTE { $$ = "<="; }
|     GTE { $$ = ">="; }
;

Expression:
      Multiplicative_Exp { $$ = $1; }
|     Expression Add Multiplicative_Exp { $$ = binaryOperator($2,$1,$3); }
|     Expression Sub Multiplicative_Exp { $$ = binaryOperator($2,$1,$3); }

;

Multiplicative_Exp:
      Term { $$ = $1; }
|     Multiplicative_Exp Mult Term { $$ = binaryOperator($2,$1,$3); }
|     Multiplicative_Exp Div Term { $$ = binaryOperator($2,$1,$3); }
|     Multiplicative_Exp Mod Term { $$ = binaryOperator($2,$1,$3); }
;

Term:
      Factor { $$ = $1; }
|     Sub Factor { $$ = new char[80]; sprintf((char*)$$,"-%s",$2); delete (char*)$2; }
;

Factor:
      Var { $$ = $1; }
|     Number { $$ = new char[80]; sprintf((char*)$$,"%d",$1); }
|     L_Paren Expression R_Paren { $$ = $2; }
;

Var:
      Ident { $$ = new char[80]; sprintf((char*)$$,"_%s",$1); checkInt($1); }
|     Ident L_Paren Expression R_Paren {  
            $$ = new char[80];
            sprintf((char*)$$,"t%d", tNum);
            vprint1("   . t%d\n",tNum++);
            
            print3("   =[] %s, _%s, %s\n",$$,$1,$3);
            
            checkArray($1);
            
            delete (char*)$3;}
;

LVar:
      Ident { $$ = new char[80]; sprintf((char*)$$,"_%s",$1); checkInt($1);}
|     Ident L_Paren Expression R_Paren { $$ = new char[80]; sprintf((char*)$$,"_%s, %s",$1,$3); delete (char*)$3; checkArray($1);}
;

RWVar:
      Ident { $$ = new char[80]; sprintf((char*)$$,"_%s",$1); checkInt($1);}
|     Ident L_Paren Expression R_Paren {
        $$ = new char[80]; sprintf((char*)$$,"_%s, %s",$1,$3); delete (char*)$3; checkArray($1);
    /*strcpy(temp,$3); if(isNumber(temp)==1){sprintf(misc,"_%s, %s",$1,temp);} else{sprintf(misc,"_%s, %s",$1,temp);} $$ = misc;*/ }
;

L_Paren:
      L_PAREN { $$ = ""; }
;

R_Paren:
      R_PAREN { $$ = ""; }
;

Ident:
      IDENT { $$ = $1; }
;

Add:
      ADD { $$ = "+"; }
;

Sub:
      SUB { $$ = "-"; }
;

Mult:
      MULT { $$ = "*"; }
;

Div:
      DIV { $$ = "/"; }
;

Mod:
      MOD { $$ = "%"; }
;

Program:
      PROGRAM { $$ = ""; }
;

Semicolon:
      SEMICOLON { $$ = ""; }
;

EndProgram:
      END_PROGRAM { $$ = ""; print(": EndLabel\n"); }
;

BeginProgram:
      BEGIN_PROGRAM { $$ = ""; print(": START\n"); }
;

Number:
      NUMBER { $$ = $1; }
;

Or:
      OR { $$ = ""; }
;

And:
      AND { $$ = ""; }
;

Colon:
      COLON { $$ = ""; }
;

Comma:
      COMMA { $$ = ""; }
;

Array:
      ARRAY { $$ = ""; }
;

Of:
      OF { $$ = ""; }
;

Integer:
      INTEGER { $$ = ""; }
;

While:
      WHILE { $$ = ""; 
        char temp[255] = {0};
        
        sprintf(temp,"L%d",lNum++);
        startLabels.push(temp);
        sprintf(temp,"L%d",lNum++);
        endLabels.push(temp);
        print1(": %s\n",startLabels.top().c_str()); }
;

Write:
      WRITE { $$ = ""; }
;

Read:
      READ { $$ = ""; }
;

Break:
      BREAK { $$ = ""; }
;

BeginLoop:
      BEGINLOOP { $$ = pNum++; vprint1("   . p%d\n",$$); }
;

EndLoop:
      ENDLOOP { $$ = ""; 
      print1("   := %s\n",startLabels.top().c_str());
      print1(": %s\n",endLabels.top().c_str());
      startLabels.pop();
      endLabels.pop(); }
;

Continue:
      CONTINUE { $$ = ""; }
;

Exit:
      EXIT { $$ = ""; }
;

If:
     IF { $$ = ""; } 
;

Then:
     THEN { $$ = if_routine(); } 
;



Question:
      QUESTION { $$ = if_routine(); }
;

Assign:
      ASSIGN { $$ = ""; }
;

Else:
      ELSE { $$ = ""; else_routine(); }
;

NoElse:
           { $$ = ""; else_routine(); }
;

EColon:
      COLON { $$ = ""; else_routine(); }
;

EndIf:
      ENDIF { $$ = ""; print1(": %s\n",ifEndLabels.top().c_str()); ifEndLabels.pop();}
;

%%

int main(int argc, char ** argv)
{
      yyparse();
      
      if(!(argc > 1 && atoi(argv[1]) == 1))
      if (fileName != 0 && fileName[0] != 0)
      {
          freopen (fileName,"w",stdout);
      }

      if(errors.size())
      {
            while (!errors.empty())
            {
                printf("%s", errors.front().c_str());
                errors.pop();
            }
            return 0;
      }
      while (!varDeclarations.empty())
      {
            printf("%s", varDeclarations.front().c_str());
            varDeclarations.pop();
      }
      while (!mystack.empty())
      {
            printf("%s", mystack.front().c_str());
            mystack.pop();
      }
    
      return 0;
}


void yyerror(const char* msg)
{
      eprint3("** Line %d, position %d: %s\n", line, currPos, msg);
      //exit(0);
}

void userVariables(int numElements)
{
    if(numElements == -1)
    {
        while(usrVars.size())
        {
            if(!arrayNames.count(usrVars.top()) && !intNames.count(usrVars.top()))
            {
                intNames.insert(usrVars.top());
                vprint1("   . _%s\n",usrVars.top().c_str());
            }
            else
            {
                eprint2("** Line %d: Variable `%s` already defined!\n",line,usrVars.top().c_str());
            }
            
            usrVars.pop();
        }
    }
    else
    {
        while(usrVars.size())
        {
            if(!arrayNames.count(usrVars.top()) && !intNames.count(usrVars.top()))
            {
                arrayNames.insert(usrVars.top());
                vprint2("   .[] _%s, %d\n",usrVars.top().c_str(),numElements);
            }
            else
            {
                eprint2("** Line %d: Variable `%s` already defined!\n",line,usrVars.top().c_str());
            }
            
            
            usrVars.pop();
        }
    }
}

int if_routine()
{
        char temp[255] = {0};
        vprint1("   . p%d\n",pNum);
        
        sprintf(temp,"L%d",lNum++);
        ifElseLabels.push(temp);
        
        return pNum++;
}

int else_routine()
{
    sprintf(temp,"L%d",lNum++);
    ifEndLabels.push(temp);
    
    print1("   := %s\n",ifEndLabels.top().c_str());
    print1(": %s\n",ifElseLabels.top().c_str()); ifElseLabels.pop();
    
    return pNum;
}

void rwStringsFormat(int bit)
{
    if(bit == 0) // read
    {
        while(rwStrings.size())
        {
            if (rwStrings.front().find_first_of(",") == string::npos)
            {
                print1("   .< %s\n",rwStrings.front().c_str());
                rwStrings.pop();
            }
            else
            {
                print1("   .[]< %s\n",rwStrings.front().c_str());
                rwStrings.pop();
            }
        }
    }
    else // write
    {
        while(rwStrings.size())
        {
            if (rwStrings.front().find_first_of(",") == string::npos)
            {
                print1("   .> %s\n",rwStrings.front().c_str());
                rwStrings.pop();
            }
            else
            {
                print1("   .[]> %s\n",rwStrings.front().c_str());
                rwStrings.pop();
            }
        }
    }
}

int isNumber(char * str)
{
    int size = strlen(str);
    for(int i = 0; i < size; ++i)
    {
        if(!isdigit(str[i]))
        {
            return 1;
        }
    }
    return 0;
}

char* binaryOperator(const char *op, const char *left, const char *right)
{
    char *o = (char*)op, *l = (char*)left, *r = (char*)right;
    
    char * ret = new char[80]; sprintf((char*)ret,"t%d",tNum);
    vprint1("   . t%d\n",tNum++);
    
    print4("   %s %s, %s, %s\n",op,ret,left,right);
    
    delete (char*)left; delete (char*)right;
    
    return ret;
}


void checkInt(const char * str)
{
    if(arrayNames.count(str))
    {
        eprint3("** Line %d, position %d: variable `%s` is an array.\n",line,currPos,str);
    }
    else if(!intNames.count(str))
    {
        eprint3("** Line %d, position %d: variable `%s` has not been defined.\n",line,currPos,str);
    }
}

void checkArray(const char * str)
{
    if(intNames.count(str))
    {
        eprint3("** Line %d, position %d: variable `%s` is a scalar value.\n",line,currPos,str);
    }
    else if(!arrayNames.count(str))
    {
        eprint3("** Line %d, position %d: variable `%s` has not been defined.\n",line,currPos,str);
    }
}
