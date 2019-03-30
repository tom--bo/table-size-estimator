%token IntNum RealNum Comma Semi LPar RPar BrckLPar BrckRPar Always AS Asc AutoIncrement BigInt Binary Bit Blob Bool Boolean Btree Char Character Collate ColumnFormat Comment Create Date DateTime Dec Decimal Default Desc Disk Double Dynamic Enum Exists Fixed Float Generated Hash IF Index Int Integer Key LongBlob LongText MediumBlob MediumInt MediumText Memory National Not Snull Numeric Precision Primary Real Set SmallInt Storage Stored Table Temporary Text Time Timestamp TinyBlob TinyInt TinyText Unique Unsigned Utf8 Utf8mb4 Using Varbinary Varchar Virtual Year SQAnyStr AnyStr Zerofill Error
%{
#include <stdio.h>
#include "lexer.yy.h"
#define YYDEBUG 1

void yyerror(char* s) {
	printf("%s\n", s);
}
%}
%%

Expression : CreateSQL { printf("--a-- %d %s %d\n", $1, yytext, yyval); }
CreateSQL: Create Table IntNum IntNum { $$ = $3 + $4; printf("--b-- %d %d %d %d %d %s\n", $1, $2, $3, $4, $$, yytext); }
		 | Create OptionTemp Table OptionExists SQAnyStr CreateDefinition
;
OptionTemp: /* empty */
		  | Temporary
OptionExists: /* empty */
			| IF Not Exists
CreateDefinition: SQAnyStr ColDef
				| IndexKey SQAnyStr IndexType KeyPart
ColDef: DataType ColDefOptions
ColDefOptions: /* empty */
			 | ColDefOptions NullOrNot
			 | ColDefOptions DefaultOption
			 | ColDefOptions AutoIncrement
			 | ColDefOptions UniquKey
			 | ColDefOptions PrimaryKey
			 | ColDefOptions Comment SQAnyStr
			 | ColDefOptions CollateOption
			 | ColDefOptions ColumnFormatOption
			 | ColDefOptions StorageOption

ColumnFormatOption: ColumnFormat 
DefaultOption: Default DefaultVal
DefaultVal: SQAnyStr
NullOrNot: Not Snull
		 | Snull
UniquKey: Unique
		| Unique Key
PrimaryKey: Primary
		  | Primary Key
CollateOption: Collate CollationType
CollationType: Utf8
			 | Utf8mb4
ColumnFormatOption: Fixed
				  | Dynamic
                  | Default
StorageOption: Storage Disk
			 | Storage Memory
IndexKey: Index
		| Key
DataType: Int
		| BigInt
KeyPart: SQAnyStr LPar IntNum RPar AscDesc
AscDesc: Asc
	   | Desc
IndexType: Using BtreeHash
BtreeHash: Btree
		| Hash


%%

#include <stdio.h>
int yydebug = 1;

int main() {
	if(!yyparse()) printf("successfully ended\n");
}