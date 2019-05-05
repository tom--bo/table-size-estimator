%token IntNum RealNum Comma Semi LPar RPar BrckLPar BrckRPar Always AS Asc AutoIncrement BigInt Binary Bit Blob Bool Boolean Btree Char Character Collate ColumnFormat Comment Create Date Datetime Dec Decimal Default Desc Disk Double Dynamic Enum Exists Fixed Float Generated Hash IF Index Int Integer Key LongBlob LongText MediumBlob MediumInt MediumText Memory National Not Snull Numeric Precision Primary Real Set SmallInt Storage Stored Table Temporary Text Time Timestamp TinyBlob TinyInt TinyText Unique Unsigned Utf8 Utf8mb4 Using Varbinary Varchar Virtual Year SQAnyStr AnyStr Zerofill Error
%{
#include <stdio.h>
#include <stdbool.h>
#include "yystype.h"

// #define YYDEBUG 1
const int MAXCOLS = 100;
const int MAXIDXS = 100;
int nowCol = 0;
int nowIdx = 0;

// define node
typedef struct _col {
	char *name;
	char *coltype;
	int size;
	bool hasIdx;
} col;

typedef struct _idx {
	char *idxname;
	int size;
	int colId[MAXCOLS];
} idx;

// define nodes array
col cols[MAXCOLS] = {};
idx idxs[MAXIDXS] = {};

void newCol(char *coltype, int size) {
	/*
	printf("%s\n", coltype);
	printf("%d\n", nowCol);
	*/

	col c;
	c.name = "";
        c.coltype = coltype;
        c.size = size;
        c.hasIdx = false;

        cols[nowCol] = c;

	/*
	col *c = (col*)malloc(sizeof(col));
        c->name = "";
        c->coltype = coltype;
        c->size = size;
        c->hasIdx = false;

        cols[nowCol] = *c;
	*/
}


void yyerror(char* s) {
        printf("%s\n", s);
}
%}
%%

Expression: CreateSQL {}
CreateSQL: Create OptTemp Table OptExists SQAnyStr LPar ColIndexes RPar Semi
OptTemp: /* empty */
       | Temporary
OptExists: /* empty */
         | IF Not Exists
ColIndexes: ColIndex
          | ColIndexes Comma ColIndex
ColIndex: SQAnyStr ColDef { printf("ColDef: %s", $1); nowCol += 1; }
        | IndexKey SQAnyStr IndexType KeyPart { nowIdx += 1; }
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
DefaultVal: SQAnyStr { printf("SQAnyStr: %s", $1);}
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
DataType: Bits
        | Nums
        | Times
        | Texts
        | Sets
Bits: Bit SizeOption1
    | Bool
    | Boolean
    | Binary
    | Varbinary
    | Varchar
    | TinyText
    | TinyBlob
    | Blob
    | MediumBlob
    | LongBlob
Nums: TinyInt SizeOption1 NumOptions { newCol("tinyint", 1); }
    | SmallInt SizeOption1 NumOptions { newCol("smallint", 2); }
    | MediumInt SizeOption1 NumOptions { newCol("mediumint", 3); }
    | Int SizeOption1 NumOptions { newCol("int", 4); }
    | Integer SizeOption1 NumOptions { newCol("integer", 4); }
    | BigInt SizeOption1 NumOptions { newCol("bigint", 8); }
    | Decimal SizeOption1or2 NumOptions { }
    | Dec SizeOption1or2 NumOptions { }
    | Numeric SizeOption1or2 NumOptions { }
    | Fixed SizeOption1or2 NumOptions { }
    | Float SizeOption1or2 NumOptions { }
    | Float SizeOption1 { }
    | Double SizeOption2 NumOptions { newCol("double", 8); }
    | Double Precision SizeOption2 NumOptions { newCol("double", 8); }
    | Real SizeOption2 NumOptions { newCol("real", 8); }
Times: Date
     | Datetime
     | Timestamp
     | Time
     | Year
Texts: Text
     | MediumText
     | LongText
Sets: Enum
    | Set
SizeOption1: /* empty */
          | LPar IntNum RPar
SizeOption2: /* empty */
          | LPar IntNum Comma IntNum RPar
SizeOption1or2: /* empty */
          | LPar IntNum RPar
          | LPar IntNum Comma IntNum RPar
NumOptions: /* empty */
          | NumOptions Unsigned
          | NumOptions Zerofill
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
	printf("start\n");

        if(!yyparse()) {
		printf("successfully ended\n");
	}

        // print all array contents
        int i;
        for(i = 0; i<nowCol; i++) {
        	printf("------\n");
        	printf("%s\n", cols[i].name);
        	printf("%s\n", cols[i].coltype);
        	printf("%d\n", cols[i].size);
        }

        // calcurate table size
        return 0;
}