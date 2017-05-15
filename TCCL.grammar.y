%namespace ASTBuilder
%partial
%parsertype TCCLParser
%visibility public
%tokentype Token

// We are setting the type for each production individually below
// %YYSTYPE AbstractNode

%union{
    public int IntVal;
    public double DblVal;
    public string StrVal;
    public AbstractNode AbstractNode;
}

%{
    // user defined functions go here
%}

%start CompilationUnit

%token <AbstractNode> AND ASTERISK BANG BOOLEAN CLASS
%token <AbstractNode> COLON COMMA ELSE EQUALS HAT
%token <AbstractNode> IF INSTANCEOF INT 
%token <StrVal> IDENTIFIER 
%token <IntVal> INT_NUMBER
%token <AbstractNode> LBRACE LBRACKET LITERAL LPAREN MINUSOP
%token <AbstractNode> NEW NULL OP_EQ OP_GE OP_GT
%token <AbstractNode> OP_LAND OP_LE OP_LOR OP_LT OP_NE
%token <AbstractNode> PERCENT PERIOD PIPE PLUSOP PRIVATE
%token <AbstractNode> PUBLIC QUESTION RBRACE RBRACKET RETURN
%token <AbstractNode> RPAREN RSLASH SEMICOLON STATIC STRUCT
%token <AbstractNode> SUPER THIS TILDE VOID WHILE

/* All Nodes are AbstractType */
%type <AbstractNode> ArgumentList
%type <AbstractNode> ArithmeticUnaryOperator
%type <AbstractNode> ArraySpecifier
%type <AbstractNode> Block
%type <AbstractNode> ClassBody
%type <AbstractNode> ClassDeclaration
%type <AbstractNode> CompilationUnit
%type <AbstractNode> ComplexPrimary
%type <AbstractNode> ComplexPrimaryNoParenthesis
%type <AbstractNode> ConstructorDeclaration
%type <AbstractNode> DeclaratorName
%type <AbstractNode> EmptyStatement
%type <AbstractNode> Expression
%type <AbstractNode> ExpressionStatement
%type <AbstractNode> FieldAccess
%type <AbstractNode> FieldDeclaration
%type <AbstractNode> FieldDeclarations
%type <AbstractNode> FieldVariableDeclaration
%type <AbstractNode> FieldVariableDeclaratorName
%type <AbstractNode> FieldVariableDeclarators
%type <AbstractNode> Identifier
%type <AbstractNode> IterationStatement
%type <AbstractNode> LocalVarDeclOrStatement
%type <AbstractNode> LocalVariableDecl
%type <AbstractNode> LocalVariableDeclarationsAndStatements
%type <AbstractNode> LocalVariableDeclaratorName
%type <AbstractNode> LocalVariableDeclarators
%type <AbstractNode> MethodBody
%type <AbstractNode> MethodCall
%type <AbstractNode> MethodDeclaration
%type <AbstractNode> MethodDeclarator
%type <AbstractNode> MethodDeclaratorName
%type <AbstractNode> MethodReference
%type <AbstractNode> Modifiers
%type <AbstractNode> NotJustName
%type <AbstractNode> Number
%type <AbstractNode> Parameter
%type <AbstractNode> ParameterList
%type <AbstractNode> PrimaryExpression           
%type <AbstractNode> PrimitiveType
%type <AbstractNode> QualifiedName
%type <AbstractNode> ReturnStatement
%type <AbstractNode> SelectionStatement
%type <AbstractNode> SpecialName
%type <AbstractNode> Statement
%type <AbstractNode> StaticInitializer
%type <AbstractNode> StructDeclaration
%type <AbstractNode> TypeName
%type <AbstractNode> TypeSpecifier


%right EQUALS
%left  OP_LOR
%left  OP_LAND
%left  PIPE
%left  HAT
%left  AND
%left  OP_EQ, OP_NE
%left  OP_GT, OP_LT, OP_LE, OP_GE
%left  PLUSOP, MINUSOP
%left  ASTERISK, RSLASH, PERCENT
%left  UNARY 

%%

CompilationUnit     
    :   ClassDeclaration    { $$ = new CompilationUnit($1);}
    ;

ClassDeclaration    
    :   Modifiers CLASS Identifier ClassBody 
                            { $$ = new ClassDeclaration($1, $3, $4);}
    ;

Modifiers           
    :   PUBLIC              { $$ = new Modifiers(ModifierType.PUBLIC);}
    |   PRIVATE             { $$ = new Modifiers(ModifierType.PRIVATE);}
    |   STATIC              { $$ = new Modifiers(ModifierType.STATIC);}
    |   Modifiers PUBLIC    { ((Modifiers)$1).AddModType(ModifierType.PUBLIC); $$ = $1;}
    |   Modifiers PRIVATE   { ((Modifiers)$1).AddModType(ModifierType.PRIVATE); $$ = $1;}
    |   Modifiers STATIC    { ((Modifiers)$1).AddModType(ModifierType.STATIC); $$ = $1;}
    ;

ClassBody           
    :   LBRACE FieldDeclarations RBRACE     { $$ = new ClassBody($2);}
    |   LBRACE RBRACE                       { $$ = new ClassBody();}
    ;

FieldDeclarations   
    :   FieldDeclaration                    { $$ = new FieldDeclarations($1); }
    |   FieldDeclarations FieldDeclaration  { $1.AddChild($2); $$ = $1;}
    ;

FieldDeclaration    
    :   FieldVariableDeclaration SEMICOLON  { $$ = $1; }
    |   MethodDeclaration                   { $$ = $1; }
    |   ConstructorDeclaration              { $$ = $1; }
    |   StaticInitializer                   { $$ = $1; }
    |   StructDeclaration                   { $$ = $1; }
    ;

StructDeclaration   
    :   Modifiers STRUCT Identifier ClassBody   { $$ = new NotImplemented("StructDeclaration"); }
    ;

/*
 * This isn't structured so nicely for a bottom up parse.  Recall
 * the example I did in class for Digits, where the "type" of the digits
 * (i.e., the base) is sitting off to the side.  You'll have to do something
 * here to get the information where you want it, so that the declarations can
 * be suitably annotated with their type and modifier information.
 */
FieldVariableDeclaration    
    :   Modifiers TypeSpecifier FieldVariableDeclarators            
                                            { $$ = new NotImplemented("FieldVariableDeclaration"); }
    ;

TypeSpecifier               
    :   TypeName                            { $$ = $1; }
    |   ArraySpecifier                      { $$ = $1; }
    ;

TypeName                    
    :   PrimitiveType                       { $$ = $1; }
    |   QualifiedName                       { $$ = $1; }
    ;

ArraySpecifier              
    :   TypeName LBRACKET RBRACKET          { $$ = new ArraySpecifier($1); }
    ;
                            
PrimitiveType               
    :   BOOLEAN                             { $$ = new PrimitiveType(EnumPrimitiveType.BOOLEAN); }
    |   INT                                 { $$ = new PrimitiveType(EnumPrimitiveType.INT); }
    |   VOID                                { $$ = new PrimitiveType(EnumPrimitiveType.VOID); }
    ;

FieldVariableDeclarators    
    :   FieldVariableDeclaratorName         { $$ = new NotImplemented("FieldVariableDeclarators"); }
    |   FieldVariableDeclarators COMMA FieldVariableDeclaratorName  
                                            { $$ = new NotImplemented("FieldVariableDeclarators"); }
    ;


MethodDeclaration           
    :   Modifiers TypeSpecifier MethodDeclarator MethodBody         
                                            { $$ = new MethodDeclaration($1, $2, $3, $4); }
    ;

MethodDeclarator            
    :   MethodDeclaratorName LPAREN ParameterList RPAREN            
                                            { $$ = new MethodDeclarator($1, $3); }
    |   MethodDeclaratorName LPAREN RPAREN  { $$ = new MethodDeclarator($1); }
    ;

ParameterList               
    :   Parameter                           { $$ = new ParameterList($1); }
    |   ParameterList COMMA Parameter       { $1.AddChild($3); $$ = $1;}  
    ;

Parameter                   
    :   TypeSpecifier DeclaratorName        { $$ = new Parameter($1, $2); }
    ;

QualifiedName               
    :   Identifier                          { $$ = new QualifiedName($1);}
    |   QualifiedName PERIOD Identifier     { $$.AddChild($3); $$ = $1;}
    ;

DeclaratorName              
    :   Identifier                          { $$ = new DeclaratorName($1); }
    ;

MethodDeclaratorName        
    :   Identifier                          { $$ = $1; }
    ;

FieldVariableDeclaratorName 
    :   Identifier                          { $$ = new FieldVariableDeclaratorName($1); }
    ;

LocalVariableDeclaratorName 
    :   Identifier                          { $$ = new LocalVariableDeclaratorName($1); }
    ;

MethodBody                  
    :   Block                               { $$ = $1; }
    ;

ConstructorDeclaration      
    :   Modifiers MethodDeclarator Block    { $$ = new NotImplemented("ConstructorDeclaration"); }
    ;

StaticInitializer           
    :   STATIC Block                        { $$ = new StaticInitializer($2); }
    ;
        
/*
 * These can't be reorganized, because the order matters.
 * For example
    :  int i;  i = 5;  int j = i;
 */

Block                       
    :   LBRACE LocalVariableDeclarationsAndStatements RBRACE        
                                            { $$ = new Block($2); }
    |   LBRACE RBRACE                       { $$ = new Block(); }
    ;

LocalVariableDeclarationsAndStatements  
    :   LocalVarDeclOrStatement             { $$ = new LocalVariableDeclarationsAndStatements($1);}
    |   LocalVariableDeclarationsAndStatements LocalVarDeclOrStatement
                                            { $1.AddChild($2); $$ = $1; }
    ;

LocalVarDeclOrStatement 
    :   LocalVariableDecl                   { $$ = $1;}
    |   Statement                           { $$ = $1;}
    ;

LocalVariableDecl   
    :   TypeSpecifier LocalVariableDeclarators SEMICOLON    
                                            { $$ = new LocalVariableDecl($1, $2);}
    |   StructDeclaration                   { $$ = new LocalVariableDecl($1);}
    ;

LocalVariableDeclarators    
    :   LocalVariableDeclaratorName         { $$ = new LocalVariableDeclarators($1); }
    |   LocalVariableDeclarators COMMA LocalVariableDeclaratorName  
                                            { $1.AddChild($3); $$ = $1; }
    ;

                            
Statement                   
    :   EmptyStatement                      { $$ = $1; }
    |   ExpressionStatement SEMICOLON       { $$ = $1; }
    |   SelectionStatement                  { $$ = $1; }
    |   IterationStatement                  { $$ = $1; }
    |   ReturnStatement                     { $$ = $1; }
    |   Block                               { $$ = $1; }
    ;

EmptyStatement              
    :   SEMICOLON                           { $$ = new EmptyStatement();}
    ;

ExpressionStatement         
    :   Expression                          { $$ = $1; }
    ;

/*
 *  You will eventually have to address the shift/reduce error that
 *     occurs when the second IF-rule is uncommented.
 *
 */

SelectionStatement          
    :   IF LPAREN Expression RPAREN Statement ELSE Statement
                                            { $$ = new NotImplemented("SelectionStatement"); }
//  |   IF LPAREN Expression RPAREN Statement
    ;


IterationStatement          
    :   WHILE LPAREN Expression RPAREN Statement
                                            { $$ = new NotImplemented("IterationStatement"); }
    ;

ReturnStatement         
    :   RETURN Expression SEMICOLON         { $$ = new ReturnStatement($2); }
    |   RETURN            SEMICOLON         { $$ = new ReturnStatement(); }
    ;

ArgumentList            
    :   Expression                          { $$ = new NotImplemented("ArgumentList"); }
    |   ArgumentList COMMA Expression       { $$ = new NotImplemented("ArgumentList"); }
    ;

Expression                  
    :   QualifiedName EQUALS Expression     { $$ = new Expression($1, ExprType.EQUALS, $3); }
    |   Expression OP_LOR Expression        { $$ = new Expression($1, ExprType.OP_LOR, $3); }   /* short-circuit OR  */  
    |   Expression OP_LAND Expression       { $$ = new Expression($1, ExprType.OP_LAND, $3); }   /* short-circuit AND */  
    |   Expression PIPE Expression          { $$ = new Expression($1, ExprType.PIPE, $3); }                
    |   Expression HAT Expression           { $$ = new Expression($1, ExprType.HAT, $3); }                
    |   Expression AND Expression           { $$ = new Expression($1, ExprType.AND, $3); }                
    |   Expression OP_EQ Expression         { $$ = new Expression($1, ExprType.OP_EQ, $3); }                
    |   Expression OP_NE Expression         { $$ = new Expression($1, ExprType.OP_NE, $3); }                
    |   Expression OP_GT Expression         { $$ = new Expression($1, ExprType.OP_GT, $3); }                
    |   Expression OP_LT Expression         { $$ = new Expression($1, ExprType.OP_LT, $3); }                
    |   Expression OP_LE Expression         { $$ = new Expression($1, ExprType.OP_LE, $3); }                
    |   Expression OP_GE Expression         { $$ = new Expression($1, ExprType.OP_GE, $3); }                
    |   Expression PLUSOP Expression        { $$ = new Expression($1, ExprType.PLUSOP, $3); }                
    |   Expression MINUSOP Expression       { $$ = new Expression($1, ExprType.MINUSOP, $3); }                
    |   Expression ASTERISK Expression      { $$ = new Expression($1, ExprType.ASTERISK, $3); }                
    |   Expression RSLASH Expression        { $$ = new Expression($1, ExprType.RSLASH, $3); }                
    |   Expression PERCENT Expression       { $$ = new Expression($1, ExprType.PERCENT, $3); }   /* remainder */
    |   ArithmeticUnaryOperator Expression  %prec UNARY
                                            { $$ = new NotImplemented("ArithmeticUnaryOperator Expression  %prec UNARY"); }
    |   PrimaryExpression                   { $$ = new Expression($1, ExprType.PRIMARY); }
    ;

ArithmeticUnaryOperator     
    :   PLUSOP                          { $$ = new NotImplemented("ArithmeticUnaryOperator"); }
    |   MINUSOP                         { $$ = new NotImplemented("ArithmeticUnaryOperator"); }
    ;
                            
PrimaryExpression           
    :   QualifiedName                   { $$ = $1;}   
    |   NotJustName                     { $$ = $1;}
    ;

NotJustName                 
    :   SpecialName                     { $$ = $1;}
    |   ComplexPrimary                  { $$ = $1;}
    ;

ComplexPrimary              
    :   LPAREN Expression RPAREN        { $$ = $2;}
    |   ComplexPrimaryNoParenthesis     { $$ = $1;}
    ;

ComplexPrimaryNoParenthesis 
    :   LITERAL                         { $$ = new NotImplemented("LITERAL"); }
    |   Number                          { $$ = $1;}
    |   FieldAccess                     { $$ = $1;}    
    |   MethodCall                      { $$ = $1;}    
    ;

FieldAccess                 
    :   NotJustName PERIOD Identifier   { $$ = new NotImplemented("FieldAccess");}   
    ;       

MethodCall                  
    :   MethodReference LPAREN ArgumentList RPAREN
                                        { $$ = new MethodCall($1, $3);}
    |   MethodReference LPAREN RPAREN   { $$ = new MethodCall($1);}
    ;

MethodReference             
    :   ComplexPrimaryNoParenthesis     { $$ = new MethodReference($1);}
    |   QualifiedName                   { $$ = new MethodReference($1);}
    |   SpecialName                     { $$ = new MethodReference($1);}
    ;

SpecialName                 
    :   THIS                            { $$ = new SpecialName(SpecialNameType.THIS);}
    |   NULL                            { $$ = new SpecialName(SpecialNameType.NULL);}
    ;

Identifier                  
    :   IDENTIFIER                      { $$ = new Identifier($1);}
    ;

Number                      
    :   INT_NUMBER                      { $$ = new Number($1);}
    ;

%%

