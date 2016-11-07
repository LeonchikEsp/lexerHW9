%{
	#include <stdio.h>

	typedef int bool;
	enum { false, true };

	//array of lexems
	char arrayOfLexems[10000][1000];
	int arrayOfLexemsIterator = 0;
	
	//
	bool filterEnabled = false;

	int numOflines = 1;
	int currPos = 1;

	char* LOperator = "op";
	char* LVariable = "var";
	char* LInteger = "int";
	char* LComment = "comment";

	//yytext - curr lexeme
	//yyleng - len of lexeme

	addMultilineCommentLexeme(char* type, int startLine, int numOflines, 
		int startSym, int endSym)
	{
		char lexeme[1000];
		sprintf(lexeme,"%s(%s, %i, %i, %i, %i); ", type, yytext, startLine, 
			numOflines, currPos, currPos - 1 + yyleng);
 		strcpy(arrayOfLexems[arrayOfLexemsIterator], lexeme);
 		currPos += yyleng;
 		arrayOfLexemsIterator++;
	}
	

	addLexeme(char* type)
	{
		char lexeme[1000];
		sprintf(lexeme,"%s(%s, %i, %i, %i); ", type, yytext, numOflines, currPos, currPos - 1 + yyleng);
 		strcpy(arrayOfLexems[arrayOfLexemsIterator], lexeme);
 		currPos += yyleng;
 		arrayOfLexemsIterator++;
	}

	printArrayOfLexems()
	{
		int i = 0;
		for (i; i < arrayOfLexemsIterator; i++)
		{
			printf("%s", arrayOfLexems[i]);
		}
	}

	printLexeme(char* type)
	{
		printf("%s(%s, %i, %i, %i); ", type, yytext, numOflines, currPos, currPos - 1 + yyleng);
 		currPos += yyleng;
	}
%}

digit	[0-9]
letter	[a-zA-Z]

%%
[1-9][0-9]*				{addLexeme(LInteger);}
[0]+					{addLexeme(LInteger);}
read 					{addLexeme(LOperator);}
skip 					{addLexeme(LOperator);}
write		 			{addLexeme(LOperator);}
while 					{addLexeme(LOperator);}
do 						{addLexeme(LOperator);}
if 						{addLexeme(LOperator);}
then 					{addLexeme(LOperator);}
else 					{addLexeme(LOperator);}

[*][*]					{addLexeme("power_operator");}

\/\/.*					{if (!filterEnabled) addLexeme(LComment);}
[(][*]((([^*])*([^)])*)|((([^*])*([^)])*[*][^)]+[)]([^*])*([^)])*))*)[*][)]		{
	int startLine = numOflines;
	int startSym = currPos;
	int endSym;

	int i;
	for(i = 0; i < yyleng; i++)
	{
		endSym = currPos;
		currPos += 1;
		if (yytext[i] == '\n')
		{
			currPos = 1;
			numOflines += 1;
		}
	}

	if (!filterEnabled) 
	{
		//printf("multiline_comment(%s, %i, %i, %i, %i); ", yytext, startLine, numOflines, startSym, endSym);
		addMultilineCommentLexeme("multiline_comment", startLine, numOflines, startSym, endSym);
	}
}

[:][=]					{addLexeme("assignment_operator");}
([+|\-|*|/|%|>|<])|([=|\!][=])|([>|<][=])|([&][&])|([\|][\|])	{addLexeme(LOperator);}


\(						{addLexeme("open_br");}
\)						{addLexeme("close_br");}
\;						{addLexeme("colon");}

[ |\f|\r|\t|\v]			{currPos+=yyleng;}

[a-zA-Z_][0-9a-zA-Z_]*	{addLexeme(LVariable);}

\n 						{numOflines++; currPos = 1;}

.						{printf("\n%s %i %s %i %s\n", "ERROR! Something went wrong on", numOflines, "line", currPos, "character"); exit(1);}

%%

main(int argc, char *argv[])
{
	filterEnabled = false;	

	if (argc < 2 || argc > 3) {printf("Usage: <./a.out> <source file> [<flag>] \n"); exit(0);}

	int i;
    for (i = 1; i < argc; ++i)
    {
    	if (!strcmp(argv[i], "-filter"))
    	{
    		filterEnabled = true;
    		//printf("flag %s\n", argv[i]);
    	}
    	else 
    	{
    		//printf("Opened %s\n", argv[i]);
    		yyin = fopen(argv[i], "r");
    	}
    }

	//printf("(%s, %s, %s, %s)\n", "lexeme name", "line", "start position" , "end position");

	yylex();

	printArrayOfLexems();
	printf("#\nNumber of lines = %d\n", numOflines);

	return 0;
}
