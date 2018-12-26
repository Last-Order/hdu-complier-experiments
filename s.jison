%lex
%%

\s+                   /* skip whitespace */
";"                   /* skip whitespace */
"Var"                 %{ /*console.log(`<VARIABLE_DEFINE>`);*/ return 'VAR';  %}
"Const"               %{ /*console.log(`<CONSTANT_DEFINE>`);*/ return 'CONST';  %}
"if"                  %{ /*console.log(`<IF>`);*/ return 'IF';  %}
"else"                %{ /*console.log(`<ELSE>`);*/ return 'ELSE';  %}
"then"                %{ /*console.log(`<THEN>`);*/ return 'THEN';  %}
"while"               %{ /*console.log(`<WHILE>`);*/ return 'WHILE';  %}
"do"                  %{ /*console.log(`<DO>`);*/ return 'DO';  %}
"begin"               %{ /*console.log(`<BEGIN>`);*/ return 'BEGIN';  %}
"end"                 %{ /*console.log(`<END>`);*/ return 'END';  %}
"("                   %{ /*console.log(`<LEFT_BRACKET>`);*/ return '('; %}
")"                   %{ /*console.log(`<RIGHT_BRACKET>`);*/ return ')'; %}
"+"                   %{ /*console.log(`<OP, +>`);*/ return '+'; %}
"-"                   %{ /*console.log(`<OP, ->`);*/ return '-'; %}
"*"                   %{ /*console.log(`<OP, *>`);*/ return '*'; %}
"/"                   %{ /*console.log(`<OP, />`);*/ return '/'; %}
"=="                  %{ /*console.log(`<EQ>`);*/ return 'EQ';   %}
"<="                  %{ /*console.log(`<LTEQ>`);*/ return 'LTEQ';   %}
">="                  %{ /*console.log(`<GTEQ>`);*/ return 'GTEQ';   %}
"<>"                  %{ /*console.log(`<NEQ>`);*/ return 'NEQ';   %}
"<"                   %{ /*console.log(`<LT>`);*/ return 'LT';   %}
">"                   %{ /*console.log(`<GT>`);*/ return 'GT';   %}
"="                   %{ /*console.log(`<ASSIGN>`);*/ return 'ASSIGN';   %}
","                   %{ /*console.log(`<COMMA>`);*/ return 'COMMA';   %}
"{"                   %{ /*console.log(`<{>`);*/ return '{';   %}
"}"                   %{ /*console.log(`<}>`);*/ return '}';   %}
[a-zA-Z_][a-zA-Z0-9_]* %{ /*console.log(`<ID>`);*/ return 'ID';   %}
[0-9]                 %{ /*console.log(`<NUMBER, ${yytext}>`);*/ return 'NUMBER'; %}
[a-z]                 %{ /*console.log(`<LETTER, ${yytext}>`);*/ return 'LETTER'; %}
<<EOF>>               %{ /*console.log(`<EOF>`);*/ return 'EOF'; %}

/lex

%nonassoc IF_WITHOUT_ELSE
%nonassoc ELSE

%% /* language grammar */

program
    : program_body
      { return $1; }
    ;

program_body
    : constant_definition variable_definition statement_list EOF
      { $$ = { type: 'program', constant_definition: $1, variable_definition: $2, statement_list: $3 }; }
    | variable_definition statement_list EOF
      { $$ = { type: 'program', variable_definition: $1, statement_list: $2 }; }
    | statement_list EOF
      { $$ = { type: 'program', statement_list: $1 }; }
    ;

    assignment
        : identifier ASSIGN unsigned_number
          { $$ = { type: 'assignment', arguments: [$1, $3] } }
        ;

    constant_definition
        : CONST constant_definition_body
          { $$ = { type: 'constant_definition', constant_definition_body: $2 } }
        ;
    
    constant_definition_body
        : assignment
          { $$ = [$1] }
        | constant_definition_body COMMA assignment 
          { $1.push($3); $$ = $1 }
        ;
    
    unsigned_number
        : NUMBER
          { $$ = parseInt($1) }
        | unsigned_number NUMBER
          { $$ = parseInt($1 * 10) + parseInt($2) }
        ;
    
    identifier
        : ID
          { $$ = { type: 'identifier', name: $1 } }
        ;
    
    variable_definition
        : VAR variable_definition_body
          { $$ = { type: 'variable_definition', variable_definition_body: $2} }
        ;
    
    variable_definition_body
        : identifier
          { $$ = [{type: 'variable', name: $1}] }
        | variable_definition_body COMMA identifier
          { $1.push({type: 'variable', name: $3}); $$ = $1; }
        ;

    statement_list
        : statement
          { $$ = { type: 'statement_list', body: [$1] } }
        | statement_list statement
          { $1.body.push($2); $$ = $1; }
        ;
    
    statement
        : assignment_statement 
          { $$ = { type: 'assignment_statement', body: $1 } }
        | condition_statement
          { $$ = { type: 'condition_statement', body: $1} }
        | while_loop_statement
          { $$ = { type: 'while_loop_statement', body: $1} }
        | block_statement
          { $$ = { type: 'block_statement', body: $1} }
        ;

        assignment_statement
            : identifier ASSIGN expression
              { $$ = { type: 'assignment', arguments: [$1, $3]} }
            ;
        
        expression
            : '+' item
              { $$ = { type: 'expression', arguments: [$1, $2]} }
            | '-' item
              { $$ = { type: 'expression', arguments: [$1, $2]} }
            | item 
              { $$ = { type: 'expression', arguments: [$1]} }
            | expression plus_op item
              { $$ = { type: 'expression', arguments: [$1, $2, $3]} }
            ;
        
        item
            : factor 
              { $$ = { type: 'item', arguments: [$1]} }
            | factor mul_op factor
              { $$ = { type: 'item', arguments: [$1, $2, $3]} }
            ;

        factor
            : identifier
              { $$ = { type: 'factor', arguments: [$1]} }
            | unsigned_number
              { $$ = { type: 'factor', arguments: [$1]} }
            | LEFT_BRACKET expression RIGHT_BRACKET
              { $$ = { type: 'factor', arguments: [$1, $2, $3]} }
            ;
        
        plus_op
            : '+'
              { $$ = '+' }
            | '-'
              { $$ = '-' }
            ;
        
        mul_op
            : '*'
              { $$ = '*' }
            | '/'
              { $$ = '/' }
            ;

        condition_statement
            : IF condition THEN statement %prec IF_WITHOUT_ELSE
              { $$ = { type: 'condition_statement', condition: $2, true_statement: $4 } }
            | IF condition THEN statement ELSE statement
              { $$ = { type: 'condition_statement', condition: $2, true_statement: $4, false_statement: $6 } }
            ;

        condition
            : expression compare_op expression
              { $$ = { type: 'condition', arguments: [$1, $2, $3] } }
            ;
        
        compare_op
            : EQ
              { $$ = $1}
            | LT
              { $$ = $1}
            | GT
              { $$ = $1}
            | LTEQ
              { $$ = $1}
            | GTEQ
              { $$ = $1}
            ;
        
        while_loop_statement
            : WHILE condition DO statement
              { $$ = { type: 'while_loop_statement_body', condition: $2, body: $4 } }
            ;
        
        block_statement
            : BEGIN statement_list END
              { $$ = { type: 'block_statement_body', body: $2} }
            ;
%%