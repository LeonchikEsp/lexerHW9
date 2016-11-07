#!/bin/bash
exists()
{
	command -v "$1" >/dev/null 2>&1
}
if exists flex; then
	if exists gcc; then
		lex lexer.lex
		gcc lex.yy.c -lfl
	else echo "GCC compiler should be installed"
		echo "Type sudo apt-get install gcc"
	fi
else echo "FLEX should be installed"
	echo "Type sudo apt-get install flex"
fi