%lex
%%

\s+                   /* skip whitespace */
";"                   /* skip whitespace */
"Var"                 %{ console.log(`<VARIABLE_DEFINE>`); return 'VAR';  %}
"Const"               %{ console.log(`<CONSTANT_DEFINE>`); return 'CONST';  %}
"if"                  %{ console.log(`<IF>`); return 'IF';  %}
"else"                %{ console.log(`<ELSE>`); return 'ELSE';  %}
"then"                %{ console.log(`<THEN>`); return 'THEN';  %}
"while"               %{ console.log(`<WHILE>`); return 'WHILE';  %}
"do"                  %{ console.log(`<DO>`); return 'DO';  %}
"begin"               %{ console.log(`<BEGIN>`); return 'BEGIN';  %}
"end"                 %{ console.log(`<END>`); return 'END';  %}
"("                   %{ console.log(`<LEFT_BRACKET>`); return '('; %}
")"                   %{ console.log(`<RIGHT_BRACKET>`); return ')'; %}
"+"                   %{ console.log(`<OP, +>`); return '+'; %}
"-"                   %{ console.log(`<OP, ->`); return '-'; %}
"*"                   %{ console.log(`<OP, *>`); return '*'; %}
"/"                   %{ console.log(`<OP, />`); return '/'; %}
"=="                  %{ console.log(`<EQ>`); return 'EQ';   %}
"<="                  %{ console.log(`<LTEQ>`); return 'LTEQ';   %}
">="                  %{ console.log(`<GTEQ>`); return 'GTEQ';   %}
"<>"                  %{ console.log(`<NEQ>`); return 'NEQ';   %}
"<"                   %{ console.log(`<LT>`); return 'LT';   %}
">"                   %{ console.log(`<GT>`); return 'GT';   %}
"="                   %{ console.log(`<ASSIGN>`); return 'ASSIGN';   %}
","                   %{ console.log(`<COMMA>`); return 'COMMA';   %}
"{"                   %{ console.log(`<{>`); return '{';   %}
"}"                   %{ console.log(`<}>`); return '}';   %}
[a-zA-Z_][a-zA-Z0-9_]* %{ console.log(`<ID>`); return 'ID';   %}
[0-9]                 %{ console.log(`<NUMBER, ${yytext}>`); return 'NUMBER'; %}
[a-z]                 %{ console.log(`<LETTER, ${yytext}>`); return 'LETTER'; %}
<<EOF>>               %{ console.log(`<EOF>`); return 'EOF'; %}

/lex

%nonassoc IF_WITHOUT_ELSE
%nonassoc ELSE

%% /* language grammar */

program
    : constant_definition variable_definition statement_list EOF
    | variable_definition statement_list EOF
    | statement_list EOF
    ;

    assignment
        : identifier ASSIGN unsigned_number
        ;

    constant_definition
        : CONST constant_definition_body
        ;
    
    constant_definition_body
        : assignment
        | constant_definition_body COMMA assignment 
        ;
    
    unsigned_number
        : NUMBER
        | unsigned_number NUMBER
        ;
    
    identifier
        : ID
        ;
    
    variable_definition
        : VAR variable_definition_body
        ;
    
    variable_definition_body
        : identifier
        | variable_definition_body COMMA identifier
        ;

    statement_list
        : statement_list statement
        | ;
    
    statement
        : assignment_statement 
        | condition_statement
        | while_loop_statement
        | block_statement
        ;

        assignment_statement
            : identifier ASSIGN expression
            ;
        
        expression
            : '+' item
            | '-' item
            | item 
            | item plus_op item
            ;
        
        item
            : factor 
            | factor mul_op factor
            ;

        factor
            : identifier
            | unsigned_number
            | LEFT_BRACKET expression RIGHT_BRACKET
            ;
        
        plus_op
            : '+'
            | '-'
            ;
        
        mul_op
            : '*'
            | '/'
            ;

        condition_statement
            : IF condition THEN statement %prec IF_WITHOUT_ELSE
            | IF condition THEN statement ELSE statement
            ;

        condition
            : expression compare_op expression
            ;
        
        compare_op
            : EQ
            | LT
            | GT
            | LTEQ
            | GTEQ
            ;
        
        while_loop_statement
            : WHILE condition DO statement
            ;
        
        block_statement
            : BEGIN statement_list END
            ;
%%