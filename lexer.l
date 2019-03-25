%{
#include "y.tab.h"
%}
%%
0|[1-9][0-9]*    { yylval = atoi(yytext); return INTNUM; }
([0-9]+"."[0-9]*)|([0-9]*"."[0-9]+) { return REALNUM; }

","              { return Comma; }
";"              { return Semi; }
"("              { return LPar; }
")"              { return RPar; }
"]"              { return BrckRPar; }
"["              { return BrckLPar; }
"always"         { return Always; }
"as"             { return AS; }
"asc"            { return Asc; }
"auto_increment" { return AutoIncrement; }
"bigint"         { return BigInt; }
"binary"         { return Binary; }
"bit"            { return Bit; }
"blob"           { return Blob; }
"bool"           { return Bool; }
"boolean"        { return Boolean; }
"btree"          { return Btree; }
"char"           { return Char; }
"character"      { return Character; }
"collate"        { return Collate; }
"column_format"  { return ColumnFormat; }
"comment"        { return Comment; }
"create"         { return Create; }
"date"           { return Date; }
"datetime"       { return Datetime; }
"dec"            { return DEC; }
"decimal"        { return Decimal; }
"default"        { return Default; }
"desc"           { return Desc; }
"disk"           { return Disk; }
"double"         { return Double; }
"dynamic"        { return Dynamic; }
"enum"           { return Enum; }
"exists"         { return Exists; }
"fixed"          { return Fixed; }
"float"          { return Float; }
"generated"      { return Generated; }
"hash"           { return Hash; }
"if"             { return IF; }
"index"          { return Index; }
"int"            { return Int; }
"integer"        { return Integer; }
"key"            { return Key; }
"longblob"       { return Longblob; }
"longtext"       { return LongText; }
"mediumblob"     { return MediumBlob; }
"mediumint"      { return MediumInt; }
"mediumtext"     { return MediumText; }
"memory"         { return Memory; }
"national"       { return National; }
"not"            { return Not; }
"numeric"        { return Numeric; }
"precision"      { return Precision; }
"primary"        { return Primary; }
"real"           { return Real; }
"set"            { return Set; }
"smallint"       { return SmallInt; }
"storage"        { return Storage; }
"stored"         { return Stored; }
"table"          { return Table; }
"temporary"      { return Temporary; }
"text"           { return Text; }
"time"           { return Time; }
"timestamp"      { return Timestamp; }
"tinyblob"       { return TinyBlob; }
"tinyint"        { return TinyInt; }
"tinytext"       { return TinyText; }
"unique"         { return Unique; }
"unsigned"       { return Unsigned; }
"using"          { return Using; }
"varbinary"      { return Varbinary; }
"varchar"        { return Varchar; }
"virtual"        { return Virtual; }
"year"           { return Year; }
"zerofill"       { return Zerofill; }
"null"           { return Snull; }

"/*"[a-z0-9 ]*"*/" {}
"\n"|" "|"\t"      {}
.                  { printf("Unknown character(s) in lexer\n"); return ERROR; }

%%
                  
int yywrap(void) {
	return 1; 
}
