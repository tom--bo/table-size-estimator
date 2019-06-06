%{
#include <string.h>
#include "yystype.h"
#include "parser.tab.h"
%}
%%
0|[1-9][0-9]*    { yylval = strdup(yytext); return IntNum; }
([0-9]+"."[0-9]*)|([0-9]*"."[0-9]+) { yylval = strdup(yytext); return RealNum; }

","              { return Comma; }
";"              { return Semi; }
"("              { return LPar; }
")"              { return RPar; }
"]"              { return BrckRPar; }
"["              { return BrckLPar; }
"="              { yylval = yytext; return Equal; }
"action"         { yylval = yytext; return Action; }
"always"         { yylval = yytext; return Always; }
"as"             { yylval = yytext; return AS; }
"asc"            { yylval = yytext; return Asc; }
"auto_increment" { yylval = yytext; return AutoIncrement; }
"avg_row_length" { yylval = yytext; return AvgRowLength; }
"bigint"         { yylval = yytext; return BigInt; }
"binary"         { yylval = yytext; return Binary; }
"bit"            { yylval = yytext; return Bit; }
"blob"           { yylval = yytext; return Blob; }
"bool"           { yylval = yytext; return Bool; }
"boolean"        { yylval = yytext; return Boolean; }
"btree"          { yylval = yytext; return Btree; }
"cascade"        { yylval = yytext; return Cascade; }
"char"           { yylval = yytext; return Char; }
"charset"        { yylval = yytext; return Charset; }
"character"      { yylval = yytext; return Character; }
"checksum"       { yylval = yytext; return Checksum; }
"collate"        { yylval = yytext; return Collate; }
"column_format"  { yylval = yytext; return ColumnFormat; }
"comment"        { yylval = yytext; return Comment; }
"compact"        { yylval = yytext; return Compact; }
"compressed"     { yylval = yytext; return Compressed; }
"compression"    { yylval = yytext; return Compression; }
"constraint"     { yylval = yytext; return Constraint; }
"create"         { yylval = yytext; return Create; }
"date"           { yylval = yytext; return Date; }
"datetime"       { yylval = yytext; return Datetime; }
"dec"            { yylval = yytext; return Dec; }
"decimal"        { yylval = yytext; return Decimal; }
"default"        { yylval = yytext; return Default; }
"delete"         { yylval = yytext; return Delete; }
"desc"           { yylval = yytext; return Desc; }
"disk"           { yylval = yytext; return Disk; }
"double"         { yylval = yytext; return Double; }
"dynamic"        { yylval = yytext; return Dynamic; }
"encryption"     { yylval = yytext; return Encryption; }
"engine"         { yylval = yytext; return Engine; }
"enum"           { yylval = yytext; return Enum; }
"exists"         { yylval = yytext; return Exists; }
"fixed"          { yylval = yytext; return Fixed; }
"float"          { yylval = yytext; return Float; }
"foreign"        { yylval = yytext; return Foreign; }
"full"           { yylval = yytext; return Full; }
"generated"      { yylval = yytext; return Generated; }
"hash"           { yylval = yytext; return Hash; }
"if"             { yylval = yytext; return IF; }
"index"          { yylval = yytext; return Index; }
"int"            { yylval = yytext; return Int; }
"integer"        { yylval = yytext; return Integer; }
"key"            { yylval = yytext; return Key; }
"longblob"       { yylval = yytext; return LongBlob; }
"longtext"       { yylval = yytext; return LongText; }
"lz4"            { yylval = yytext; return Lz4; }
"match"          { yylval = yytext; return Match; }
"mediumblob"     { yylval = yytext; return MediumBlob; }
"mediumint"      { yylval = yytext; return MediumInt; }
"mediumtext"     { yylval = yytext; return MediumText; }
"memory"         { yylval = yytext; return Memory; }
"national"       { yylval = yytext; return National; }
"no"             { yylval = yytext; return No; }
"none"           { yylval = yytext; return None; }
"not"            { yylval = yytext; return Not; }
"numeric"        { yylval = yytext; return Numeric; }
"on"             { yylval = yytext; return On; }
"partial"        { yylval = yytext; return Partial; }
"precision"      { yylval = yytext; return Precision; }
"primary"        { yylval = yytext; return Primary; }
"real"           { yylval = yytext; return Real; }
"redundant"      { yylval = yytext; return Redundant; }
"references"     { yylval = yytext; return References; }
"restrict"       { yylval = yytext; return Restrict; }
"row_format"     { yylval = yytext; return RowFormat; }
"set"            { yylval = yytext; return Set; }
"simple"         { yylval = yytext; return Simple; }
"smallint"       { yylval = yytext; return SmallInt; }
"storage"        { yylval = yytext; return Storage; }
"stored"         { yylval = yytext; return Stored; }
"table"          { yylval = yytext; return Table; }
"temporary"      { yylval = yytext; return Temporary; }
"text"           { yylval = yytext; return Text; }
"time"           { yylval = yytext; return Time; }
"timestamp"      { yylval = yytext; return Timestamp; }
"tinyblob"       { yylval = yytext; return TinyBlob; }
"tinyint"        { yylval = yytext; return TinyInt; }
"tinytext"       { yylval = yytext; return TinyText; }
"unique"         { yylval = yytext; return Unique; }
"unsigned"       { yylval = yytext; return Unsigned; }
"update"         { yylval = yytext; return Update; }
"using"          { yylval = yytext; return Using; }
"utf8"           { yylval = yytext; return Utf8;}
"utf8mb4"        { yylval = yytext; return Utf8mb4;}
"varbinary"      { yylval = yytext; return Varbinary; }
"varchar"        { yylval = yytext; return Varchar; }
"virtual"        { yylval = yytext; return Virtual; }
"year"           { yylval = yytext; return Year; }
"zerofill"       { yylval = yytext; return Zerofill; }
"zlib"           { yylval = yytext; return Zlib; }
"null"           { yylval = yytext; return Snull; }

['`]?[a-z0-9_\-]*['`]? { yylval = strdup(yytext); return SQAnyStr; }
"/*"[a-z0-9 ]*"*/"   {}
"\n"|" "|"\t"        {}

%%
                  
int yywrap(void) {
	return 1; 
}
