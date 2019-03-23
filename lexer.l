%{
#include "y.tab.h"
%}
%%
0|[1-9][0-9]*    return INTNUM;
([0-9]+"."[0-9]*)|([0-9]*"."[0-9]+) return REALNUM;
","              return COMMA;
";"              return SEMI;
"("              return LPAR;
")"              return RPAR;
"]"              return BRCKRPAR;
"["              return BRCKLPAR;
"always"         return ALWAYS;
"as"             return AS;
"asc"            return ASC;
"auto_increment" return AUTO_INCREMENT;
"bigint"         return BIGINT;
"binary"         return BINARY;
"bit"            return BIT;
"blob"           return BLOB;
"bool"           return BOOL;
"boolean"        return BOOLEAN;
"btree"          return BTREE;
"char"           return CHAR;
"character"      return CHARACTER;
"collate"        return COLLATE;
"column_format"  return COLUMN_FORMAT;
"comment"        return COMMENT;
"create"         return CREATE;
"date"           return DATE;
"datetime"       return DATETIME;
"dec"            return DEC;
"decimal"        return DECIMAL;
"default"        return DEFAULT;
"desc"           return DESC;
"disk"           return DISK;
"double"         return DOUBLE;
"dynamic"        return DYNAMIC;
"enum"           return ENUM;
"exists"         return EXISTS;
"fixed"          return FIXED;
"float"          return FLOAT;
"generated"      return GENERATED;
"hash"           return HASH;
"if"             return IF;
"index"          return INDEX;
"int"            return INT;
"integer"        return INTEGER;
"key"            return KEY;
"longblob"       return LONGBLOB;
"longtext"       return LONGTEXT;
"mediumblob"     return MEDIUMBLOB;
"mediumint"      return MEDIUMINT;
"mediumtext"     return MEDIUMTEXT;
"memory"         return MEMORY;
"national"       return NATIONAL;
"not"            return NOT;
"numeric"        return NUMERIC;
"precision"      return PRECISION;
"primary"        return PRIMARY;
"real"           return REAL;
"set"            return SET;
"smallint"       return SMALLINT;
"storage"        return STORAGE;
"stored"         return STORED;
"table"          return TABLE;
"temporary"      return TEMPORARY;
"text"           return TEXT;
"time"           return TIME;
"timestamp"      return TIMESTAMP;
"tinyblob"       return TINYBLOB;
"tinyint"        return TINYINT;
"tinytext"       return TINYTEXT;
"unique"         return UNIQUE;
"unsigned"       return UNSIGNED;
"using"          return USING;
"varbinary"      return VARBINARY;
"varchar"        return VARCHAR;
"virtual"        return VIRTUAL;
"year"           return YEAR;
"zerofill"       return ZEROFILL;
"null"           return SNULL;

"/*"[a-z0-9 ]*"*/" ;
"\n"|" "|"\t" ;
. return ERROR;

%%
                  
int yywrap(void) {
	return 1; 
}
