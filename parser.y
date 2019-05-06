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

long opt1 = -1;
long opt2 = -1;

long atoi(char *str) {
    long ans = 0;
    int len = strlen(str);
    int i;
    long j = 1;
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

long calcSize(char *str, int opt1, int opt2) {
    long ret = 0;
    if(!strncmp(str,"dec",strlen(str)) || !strncmp(str,"decimal",strlen(str)) || !strncmp(str,"numeric",strlen(str))) {
        ret += (opt1/9)*4 + (opt2/9)*4;
        int rem1 = opt1%9;
        int rem2 = opt2%9;
        ret += (rem1+1)/2 + (rem2+1)/2;
    } else if(!strncmp(str,"float",strlen(str))) {
        if(opt1 <= 24) {
            ret = 4;
        } else {
            ret = 8;
        }
    } else if(!strncmp(str,"bit",strlen(str))) {
        ret = (opt1+7)/8;
    } else if(!strncmp(str,"datetime",strlen(str))) {
        ret = 5;
        if(opt1 != -1) {
            ret += opt1 / 2;
        }
    } else if(!strncmp(str,"timestamp",strlen(str))) {
        ret = 4;
        if(opt1 != -1) {
            ret += opt1 / 2;
        }
    } else if(!strncmp(str,"time",strlen(str))) {
        ret = 3;
        if(opt1 != -1) {
            ret += opt1 / 2;
        }
    } else if(!strncmp(str,"blob",strlen(str))) {
        ret = 65537;
        if(opt1 != -1) {
            ret = opt1;
        }
    } else if(!strncmp(str,"char",strlen(str))) {
        ret = opt1 * 4;
    } else if(!strncmp(str,"varchar",strlen(str))) {
        if(opt1 * 4 < 255) {
            ret = opt1 * 4 + 1;
        } else {
            ret = opt1 * 4 + 2;
        }
    } else if(!strncmp(str,"binary",strlen(str))) {
        ret = opt1;
    } else if(!strncmp(str,"varbinary",strlen(str))) {
        if(opt1 < 255) {
            ret = opt1 + 1;
        } else {
            ret = opt1 + 2;
        }
    } else if(!strncmp(str,"text",strlen(str))) {
        ret = 65535+3;
        if(opt1 != -1) {
            ret = opt1*4+3;
        }
    }
    return ret;
}

void newCol(char *coltype, long size) {
    col c;
    c.name = "";
    c.coltype = coltype;
    c.hasIdx = false;

    if(size == -1) {
        c.size = calcSize(coltype, opt1, opt2);
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
             | ColDefOptions ColumnFormat ColumnFormatOption
             | ColDefOptions Storage StorageOption

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
             | SQAnyStr
ColumnFormatOption: Fixed
                  | Dynamic
                  | Default
StorageOption: Disk
             | Memory
IndexKey: Index
        | Key
DataType: Bits
        | Nums
        | Times
        | Texts
        | Sets
Bits: Bit SizeOption1  { newCol("bit", -1); }
    | Bool             { newCol("tinyint", 1); }
    | Boolean          { newCol("tinyint", 1); }
Nums: TinyInt SizeOption1 NumOptions          { newCol("tinyint", 1); }
    | SmallInt SizeOption1 NumOptions         { newCol("smallint", 2); }
    | MediumInt SizeOption1 NumOptions        { newCol("mediumint", 3); }
    | Int SizeOption1 NumOptions              { newCol("int", 4); }
    | Integer SizeOption1 NumOptions          { newCol("integer", 4); }
    | BigInt SizeOption1 NumOptions           { newCol("bigint", 8); }
    | Decimal SizeOption1or2 NumOptions       { newCol("decimal", -1); }
    | Dec SizeOption1or2 NumOptions           { newCol("dec", -1); }
    | Numeric SizeOption1or2 NumOptions       { newCol("numeric", -1); }
    | Float SizeOption1or2 NumOptions         { newCol("float", -1); }
    | Double SizeOption2 NumOptions           { newCol("double", 8); }
    | Double Precision SizeOption2 NumOptions { newCol("double", 8); }
    | Real SizeOption2 NumOptions             { newCol("real", 8); }
Times: Date                  { newCol("date", 3); }
     | Datetime SizeOption1  { newCol("datetime", -1); }
     | Timestamp SizeOption1 { newCol("timestamp", -1); }
     | Time SizeOption1      { newCol("time", -1); }
     | Year                  { newCol("year", 1); }
Texts: Binary           { newCol("binary", -1); }
     | Varbinary        { newCol("varbinary", -1); }
     | TinyBlob         { newCol("tinyblob", 256); }        /* 255B + 1*/
     | Blob SizeOption1 { newCol("blob", -1); }             /* 65535 + 2 or opt */
     | MediumBlob       { newCol("mediumblob", 16777218); } /* 16MB - 1B +3 */
     | LongBlob         { newCol("longblob", 4294967299); } /* 4GB - 1B +4 */
     | Char SizeOption1 CharacterSetOptions    { newCol("char", -1); }
     | Varchar SizeOption1 CharacterSetOptions { newCol("varchar", -1); }
     | TinyText CharacterSetOptions            { newCol("tinytext", 256); }
     | Text SizeOption1 CharacterSetOptions    { newCol("text", -1); } /* 65535 + 2 or opt*4 */
     | MediumText CharacterSetOptions          { newCol("mediumtext", 16777218); }
     | LongText CharacterSetOptions            { newCol("longtext", 4294967299); }
Sets: Enum { newCol("enum", 2); }
    | Set  { newCol("set", 2); }
SizeOption1: /* empty */
           | LPar IntNum RPar { opt1 = atoi($2); }
SizeOption2: /* empty */
           | LPar IntNum Comma IntNum RPar { opt1 = atoi($2); opt2 = atoi($4); }
SizeOption1or2: /* empty */
              | LPar IntNum RPar { opt1 = atoi($2); }
              | LPar IntNum Comma IntNum RPar { opt1 = atoi($2); opt2 = atoi($4); }
CharacterSetOptions: /* empty */
                   | Character Set SQAnyStr CollateOptions
CollateOptions: /* empty */
              | CollateOption
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