%token IntNum RealNum Comma Semi LPar RPar BrckLPar BrckRPar Always AS Asc AutoIncrement BigInt Binary Bit Blob Bool Boolean Btree Char Character Collate ColumnFormat Comment Create Date Datetime Dec Decimal Default Desc Disk Double Dynamic Enum Exists Fixed Float Generated Hash IF Index Int Integer Key LongBlob LongText MediumBlob MediumInt MediumText Memory National Not Snull Numeric Precision Primary Real Set SmallInt Storage Stored Table Temporary Text Time Timestamp TinyBlob TinyInt TinyText Unique Unsigned Utf8 Utf8mb4 Using Varbinary Varchar Virtual Year SQAnyStr AnyStr Zerofill Error
%{
#include <stdio.h>
#include "yystype.h"

// #define YYDEBUG 1

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
ColIndex: SQAnyStr ColDef { printf("ColDef: %s", $1); }
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
DataType: Bit
        | TinyInt
        | Bool
        | Boolean
        | SmallInt
        | MediumInt
        | Int
        | Integer
        | BigInt
        | Decimal
        | Dec
        | Float
        | Double
        | Double Precision
        | Date
        | Datetime
        | Timestamp
        | Time
        | Year
        | Binary
        | Varbinary
        | Varchar
        | TinyBlob
        | TinyText
        | Blob
        | Text
        | MediumBlob
        | MediumText
        | LongBlob
        | LongText
        | Enum
        | Set
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