%{
#include <stdio.h>
#include <stdlib.h>
int yylex(void);
void yyerror(char* s);
extern int yylineno;
%}

%token ASSIGNMENTOP
%token AND
%token OR
%token XOR
%token ELSE
%token NOT
%token IMPLIES
%token IFF
%token LP
%token RP
%token LB
%token RB
%token LSB
%token RSB
%token COMMENT
%token COMMA
%token ENDSTMT
%token DIGIT
%token IF
%token VAR
%token DO
%token WHILE
%token FOR
%token RUN
%token RETURN
%token CAYYOUT
%token CAYYIN
%token BOOLEAN 
%token INT
%token STRING
%token IDENTIFIER
%token CONSTANT
%token MAIN
%token PREDICATE
%token ARRAY

%start program
%right ASSIGNMENTOP

%%

//Start Rule

//Program
program:
	predicateDeclarations main

main:
	MAIN LP RP LB stmts RB

predicateDeclarations:
	predicateDeclarations predicateDeclaration
	|predicateDeclaration

stmts:
	stmt
	|stmts stmt

//Possible statement types
stmt:
	matched_stmt
	|unmatched_stmt

end_stmt:
	ENDSTMT

matched_stmt:
	IF LP logical_expression RP matched_stmt ELSE matched_stmt
	|other_stmt

unmatched_stmt:
	IF LP logical_expression RP stmt
    |IF LP logical_expression RP matched_stmt ELSE unmatched_stmt

other_stmt:
	loop
	|declaration
	|init
	|input_stmt
	|output_stmt
	|end_stmt
	|COMMENT
	|return_stmt



//----------------------------------Declerations----------------------------------------------
declaration:
	varDeclaration
	|constantDeclaration
	|array_declaration

varDeclaration:
	VAR var_id end_stmt

//-------The value of the constant variables must be instantiated during decleration------------

constantDeclaration:
	CONSTANT LP constantContent RP ASSIGNMENTOP BOOLEAN end_stmt

constantContent:
	STRING


//----------------------------------Predicate----------------------------------
//----------------------------------How to declere a predicate----------------------------------
predicateDeclaration:
	PREDICATE LP declaration_param_list RP LB predicateBody RB

declaration_param_list:
	declaration_element
	|declaration_element COMMA declaration_param_list

declaration_element:
	VAR var_id
	|CONSTANT

predicateBody:
	return_stmt
	|stmts return_stmt

return_stmt:
	RETURN logical_expression end_stmt

//----------------------------------How to instantiate a predicate------------------------------------
predicateInstantiation:
	RUN PREDICATE LP parameter_list RP

parameter_list:
	element
	|element COMMA parameter_list

element:
	term
	|BOOLEAN


//----------------------------------Initialization----------------------------------------------------
init:
	varInitialization
	|predicateInstantiation
	|varDecWithInit
	|array_init
	|array_dec_init
	|assign_element




//----------------------------------Array-------------------------------------------------------------
//-------------------------How to declare a array----------------------------------------------------

array_declaration:
	VAR ARRAY end_stmt;

//-------------------------How to initialize a array--------------------------------------------------
array_init:
	ARRAY ASSIGNMENTOP LB array_parameter_list RB end_stmt

//-------------------------How to declare and initialize a array at the same time---------------------

array_dec_init:
	VAR ARRAY ASSIGNMENTOP LB array_parameter_list RB end_stmt

array_parameter_list:
	array_parameter COMMA array_parameter_list
	|array_parameter

array_parameter:
	BOOLEAN
	|var_id
	|CONSTANT

//-------------------------How to get a array element--------------------------------------------------
array_element:
	ARRAY LSB index RSB

index:
	INT
	|DIGIT
//-------------------------How to assign an array element----------------------------------------------
//-------------------------Logical expression can be true or false-------------------------------------
assign_element:
	array_element ASSIGNMENTOP logical_expression end_stmt

//----------------------------------How to initalize a term--------------------------------------------
varInitialization:
	var_id ASSIGNMENTOP logical_expression end_stmt

varDecWithInit:
	VAR var_id ASSIGNMENTOP logical_expression end_stmt


//----------------------------------Looping Statements-------------------------------------------------
loop:
	while_stmt
	|for_stmt
	|doWhile_stmt

while_stmt:
	WHILE LP logical_expression RP LB stmts RB

for_stmt:
	FOR LP varDecWithInit logical_expression RP LB stmts RB

doWhile_stmt:
	DO LB stmts RB WHILE LP logical_expression RP


//--------------------------------------Logical expressions----------------------------------------------------
//The order of the logical expressions are divided according
//to their presendence
//Highest to Lowest: Paranthesis Not And Xor OR Implies If and only if
//Also associativity is applied

//------------------------------logical expression- If and Only If expression------------------------------
//------------------------------If and only if left assoc------------------------------
logical_expression:
	logical_expression IFF primary_expression 
	|primary_expression


//------------------------------Implies expression------------------------------
//------------------------------Implies right assoc------------------------------
primary_expression:
	or_expression IMPLIES primary_expression
	|or_expression


//------------------------------or expression------------------------------
//------------------------------or left assoc------------------------------
or_expression:
	or_expression OR ternary_expression 
	|ternary_expression

//------------------------------xor expression------------------------------
//------------------------------xor left assoc------------------------------
ternary_expression:
	ternary_expression XOR and_expression
	|and_expression

//------------------------------and expression------------------------------
//------------------------------and left assoc------------------------------
and_expression:
	and_expression AND not_expression
	|not_expression

//------------------------------not expression------------------------------
//------------------------------not is unary------------------------------
not_expression:
	NOT p_expression
	|p_expression


//------------------------------paranthesis expression------------------------------
p_expression:
	LP logical_expression RP
	|term
	|BOOLEAN
	|predicateInstantiation

//------------------------------A term could either be a variable or a constant------------------------------
term:
	var_id
	|CONSTANT
//------------------------------A variable identifier is identifier--------------------------------------
var_id:
	IDENTIFIER
//------------------------------Input statement takes a varible and assigns it to the given input-------------
//------------------------------Since constant assignments must be done during declaration--------------------
//------------------------------constant cannot assign to a input statement------------------------------
input_stmt:
	CAYYIN LP var_id RP end_stmt

//------------------------------Outputs the logical expression between LP and RP------------------------------
output_stmt:
	CAYYOUT LP logical_expression RP end_stmt

%%



void yyerror(char *s) {
	fprintf(stdout, "line %d: %s\n", yylineno,s);
}
int main(void){
 yyparse();
if(yynerrs < 1){
		printf("Parsing is successful\n");
	}
 return 0;
}

