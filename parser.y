%token IntNum RealNum Comma Semi LPar RPar BrckLPar BrckRPar Always AS Asc AutoIncrement BigInt Binary Bit Blob Bool Boolean Btree Char Character Collate ColumnFormat Comment Create Date Datetime Dec Decimal Default Desc Disk Double Dynamic Enum Exists Fixed Float Generated Hash IF Index Int Integer Key LongBlob LongText MediumBlob MediumInt MediumText Memory National Not Snull Numeric Precision Primary Real Set SmallInt Storage Stored Table Temporary Text Time Timestamp TinyBlob TinyInt TinyText Unique Unsigned Utf8 Utf8mb4 Using Varbinary Varchar Virtual Year SQAnyStr AnyStr Zerofill Error
%{
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
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

int opt1 = -1;
int opt2 = -1;

int atoi(char *str) {
    int ans = 0;
    int len = strlen(str);
    int i;
    int j = 1;
    for(i = len-1; i>=0; i--) {
        ans += (str[i] - '0') * j;
        j *= 10;
    }
    return ans;
}

void resetOpt() {
    opt1 = -1;
    opt2 = -1;
}

int colcSize(char *str, int opt1, int opt2) {
    int ret = 0;
    if(strncmp(str,"dec",strlen(str)) || strncmp(str,"decimal",strlen(str)) || strncmp(str,"numeric",strlen(str))) {
        ret += (opt1/9)*4 + (opt2/9)*4;
        int rem1 = opt1%9;
        int rem2 = opt2%9;
        ret += (rem1+1)/2 + (rem2+1)/2;
    } else if(strncmp(str,"float",strlen(str))) {
        if(opt1 <= 24) {
            ret = 4;
        } else {
            ret = 8;
        }
    }
    return ret;
}

void newCol(char *coltype, int size) {
    col c;
    c.name = "";
    c.coltype = coltype;
    c.hasIdx = false;

    if(size == -1) {
        c.size = colcSize(coltype, opt1, opt2);
    } else {
        c.size = size;
    }

    cols[nowCol] = c;

    return;
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
ColIndex: SQAnyStr ColDef { nowCol += 1; resetOpt(); }
        | IndexKey SQAnyStr IndexType KeyPart { nowIdx += 1; }
ColDef: DataType ColDefOptions
ColDefOptions: /* empty */
             | ColDefOptions NullOrNot
             | ColDefOptions DefaultOption
             | ColDefOptions AutoIncrement
             | ColDefOptions UniquKey { cols[nowCol].hasIdx = true; }
             | ColDefOptions PrimaryKey {}
             | ColDefOptions Comment SQAnyStr
             | ColDefOptions CollateOption
             | ColDefOptions ColumnFormatOption
             | ColDefOptions StorageOption

ColumnFormatOption: ColumnFormat 
DefaultOption: Default DefaultVal
DefaultVal: SQAnyStr {}
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
Nums: TinyInt SizeOption1 NumOptions          { newCol("tinyint", 1); }
    | SmallInt SizeOption1 NumOptions         { newCol("smallint", 2); }
    | MediumInt SizeOption1 NumOptions        { newCol("mediumint", 3); }
    | Int SizeOption1 NumOptions              { newCol("int", 4); }
    | Integer SizeOption1 NumOptions          { newCol("integer", 4); }
    | BigInt SizeOption1 NumOptions           { newCol("bigint", 8); }
    | Decimal SizeOption1or2 NumOptions       { newCol("decimal", -1); }
    | Dec SizeOption1or2 NumOptions           { newCol("dec", -1); }
    | Numeric SizeOption1or2 NumOptions       { newCol("numeric", -1); }
    | Fixed SizeOption1or2 NumOptions         { newCol("fixed", 8); }
    | Float SizeOption1or2 NumOptions         { newCol("float", -1); }
    | Float SizeOption1                       { newCol("float", -1); }
    | Double SizeOption2 NumOptions           { newCol("double", 8); }
    | Double Precision SizeOption2 NumOptions { newCol("double", 8); }
    | Real SizeOption2 NumOptions             { newCol("real", 8); }
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
           | LPar IntNum RPar { opt1 = atoi($2); }
SizeOption2: /* empty */
           | LPar IntNum Comma IntNum RPar { opt1 = atoi($2); opt2 = atoi($4); }
SizeOption1or2: /* empty */
              | LPar IntNum RPar { opt1 = atoi($2); }
              | LPar IntNum Comma IntNum RPar { opt1 = atoi($2); opt2 = atoi($4); }
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
        printf("%s\n", (cols[i].hasIdx ? "true": "false"));
    }

    // calcurate table size
    return 0;
}