%{
#include <string.h>
#include <ctype.h>
#include <queue>
#include <string>
#include "y.tab.h"

/* need this for the call to atof() below */
/* isdigit is in ctype library */

unsigned int line = 1; //currentline
unsigned int currPos = 1; // current position or column

extern std::queue<std::string> errors;
extern char temp[256];

#define eprint(x) sprintf(temp,x),errors.push(std::string(temp))
#define eprint1(x,a) sprintf(temp,x,a),errors.push(std::string(temp))
#define eprint2(x,a,b) sprintf(temp,x,a,b),errors.push(std::string(temp))
#define eprint3(x,a,b,c) sprintf(temp,x,a,b,c),errors.push(std::string(temp))
#define eprint4(x,a,b,c,d) sprintf(temp,x,a,b,c,d),errors.push(std::string(temp))
#define eprint5(x,a,b,c,d,e) sprintf(temp,x,a,b,c,d,e),errors.push(std::string(temp))
#define eprint6(x,a,b,c,d,e,f) sprintf(temp,x,a,b,c,d,e,f),errors.push(std::string(temp))
#define eprint7(x,a,b,c,d,e,f,g) sprintf(temp,x,a,b,c,d,e,f,g),errors.push(std::string(temp))

%}
DIGIT		[0-9]+[\.]*[0-9]*
ALPHA		[a-zA-Z]
%%

"program"   {currPos += yyleng; return PROGRAM;}
"beginprogram"     {currPos += yyleng; return BEGIN_PROGRAM;}
"endprogram"    {currPos += yyleng; return END_PROGRAM;}
"integer"        {currPos += yyleng; return INTEGER;}
"array"           {currPos += yyleng; return ARRAY;}
"of"            {currPos += yyleng; return OF;}
"if"              {currPos += yyleng; return IF;}
"then"          {currPos += yyleng; return THEN;}
"endif"          {currPos += yyleng; return ENDIF;}
"else"          {currPos += yyleng; return ELSE;}
"while"        {currPos += yyleng; return WHILE;}
"beginloop"         {currPos += yyleng; return BEGINLOOP;}
"endloop"      {currPos += yyleng; return ENDLOOP;}
"read"        {currPos += yyleng; return READ;}
"write"        {currPos += yyleng; return WRITE;}
"break"        {currPos += yyleng; return BREAK;}
"continue"        {currPos += yyleng; return CONTINUE;}
"exit"        {currPos += yyleng; return EXIT;}
"and"         {currPos += yyleng; return AND;}
"or"          {currPos += yyleng; return OR;}
"not"      {currPos += yyleng; return NOT;}
"true"      {currPos += yyleng; return TRUE;}
"false"     {currPos += yyleng; return FALSE;}
("##")(.)* line;
"+" {currPos += yyleng; return ADD;}
"-" {currPos += yyleng; return SUB;}
"*" {currPos += yyleng; return MULT;}
"/" {currPos += yyleng; return DIV;}
"%" {currPos += yyleng; return MOD;}
"==" {currPos += yyleng; return EQ;}
"<>" {currPos += yyleng; return NEQ;}
"<" {currPos += yyleng; return LT;}
">" {currPos += yyleng; return GT;}
"<=" {currPos += yyleng; return LTE;}
">=" {currPos += yyleng; return GTE;}
";" {currPos += yyleng; return SEMICOLON;}
":" {currPos += yyleng; return COLON;}
"," {currPos += yyleng; return COMMA;}
"(" {currPos += yyleng; return L_PAREN;}
")" {currPos += yyleng; return R_PAREN;}
":=" {currPos += yyleng; return ASSIGN;}
"?" {currPos += yyleng; return QUESTION;}
[ ] {currPos += yyleng;}
[\t] {currPos += yyleng;}
[\n]{1} {currPos = 1; line++;}


({DIGIT})*({ALPHA}|"_")+({DIGIT}|{ALPHA}|"_")* { 
		                                            if(isdigit(yytext[0]))
		                                            {
														eprint3("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", line, currPos, yytext);
		                                            }
							 						if(yytext[yyleng-1]=='_')
		                                            {
		                                            	eprint3("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", line, currPos, yytext);
		                                            }
		                                            else
		                                            {
		                                            	yylval.idval=new char(yyleng+1); strcpy((char *)yylval.idval,yytext); currPos += yyleng;
		                                            	return IDENT;
		                                            }
                                               }
	           
("-")*({DIGIT})+	{
				currPos += yyleng;
				yylval.ival = atoi(yytext); 
				return NUMBER;
			}
            
. {  

	eprint3("Error at line %d, column %d: unrecognized symbol \"%s\"\n", line, currPos, yytext);
	//exit(0);
  }

%%
