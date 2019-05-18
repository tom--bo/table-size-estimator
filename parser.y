%token IntNum RealNum Comma Semi LPar RPar BrckLPar BrckRPar Always AS Asc AutoIncrement AvgRowLength BigInt Binary Bit Blob Bool Boolean Btree Char Charset Character Checksum Collate ColumnFormat Comment Compact Compressed Compression Create Date Datetime Dec Decimal Default Desc Disk Double Dynamic Encryption Engine Enum Exists Fixed Float Generated Hash IF Index Int Integer Key LongBlob LongText Lz4 MediumBlob MediumInt MediumText Memory National None Not Snull Numeric Precision Primary Real Redundant RowFormat Set SmallInt Storage Stored Table Temporary Text Time Timestamp TinyBlob TinyInt TinyText Unique Unsigned Utf8 Utf8mb4 Using Varbinary Varchar Virtual Year SQAnyStr AnyStr Zerofill Zlib Error Equal
%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include "yystype.h"
#include "calc.h"

// #define YYDEBUG 1

void yyerror(char* s) {
    printf("%s\n", s);
}
%}
%%

Expression: CreateSQL {}
CreateSQL: Create OptTemp Table OptExists SQAnyStr LPar ColIndexes RPar TableOptions OptSemi
OptTemp: /* empty */
       | Temporary
OptExists: /* empty */
         | IF Not Exists
OptSemi: /* empty */
       | Semi
ColIndexes: ColIndex
          | ColIndexes Comma ColIndex
ColIndex: SQAnyStr ColDef { addColName($1); incNowCol(); resetOpt(); }
        | IndexKey OptSQAnyStr OptIndexType LPar KeyParts RPar { addIdxName($2); incNowIdx(); iniNowIdxCol(); }
ColDef: DataType ColDefOptions
ColDefOptions: /* empty */
             | ColDefOptions Not Snull { setColsNull(false); }
             | ColDefOptions DefaultOption
             | ColDefOptions AutoIncrement
             | ColDefOptions UniqueKey { setHasIdx(true); }
             | ColDefOptions PrimaryKey { setHasPk(true); }
             | ColDefOptions Comments
             | ColDefOptions ColumnFormat ColumnFormatOption
             | ColDefOptions Storage StorageOption

ColumnFormatOption: ColumnFormat 
DefaultOption: Default Snull { setColsNull(true); }
             | Default DefaultVal
DefaultVal: SQAnyStr {}
UniqueKey: Unique
         | Unique Key
PrimaryKey: Primary
          | Primary Key
CollateOption: Collate SQAnyStr
             | Collate Equal SQAnyStr
CharsetOptions: Utf8
              | Utf8mb4
              | SQAnyStr
ColumnFormatOption: Fixed
                  | Dynamic
                  | Default
StorageOption: Disk
             | Memory
IndexKey: Index
        | Key
        | Primary Key
        | Unique Key
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
           | LPar IntNum RPar { setOpt1(atolong($2)); }
SizeOption2: /* empty */
           | LPar IntNum Comma IntNum RPar { setOpt1(atolong($2)); setOpt2(atolong($4)); }
SizeOption1or2: /* empty */
              | LPar IntNum RPar { setOpt1(atolong($2)); }
              | LPar IntNum Comma IntNum RPar { setOpt1(atolong($2)); setOpt2(atolong($4)); }
CharacterSetOptions: /* empty */
                   | Character Set SQAnyStr CollateOptions
CollateOptions: /* empty */
              | CollateOption
Comments: Comment Equal SQAnyStr
        | Comment SQAnyStr
NumOptions: /* empty */
          | NumOptions Unsigned
          | NumOptions Zerofill
OptSQAnyStr: /* empty */ { $$ = "(NONE)"; }
           | SQAnyStr { $$ = $1; }
KeyParts: KeyPart
        | KeyParts Comma KeyPart
KeyPart: SQAnyStr OptSize OptAscDesc { addIdxCol($1, $2, $3); }
OptSize: /* empty */ { $$ = "0"; }
       | LPar IntNum RPar { $$ = $2; }
OptAscDesc: /* empty */ { $$ = "asc"; }
          | Asc  { $$ = "asc"; }
          | Desc { $$ = "desc"; }
OptIndexType: /* empty */
         | Using BtreeHash
BtreeHash: Btree
         | Hash
TableOptions: /* empty */
           | TableOptions AutoIncrements
           | TableOptions AvgRowLengths
           | TableOptions DefaultCharSets DefaultCollations
           | TableOptions Checksums
           | TableOptions Comments
           | TableOptions Compressions
           | TableOptions Encryptions
           | TableOptions Engines
           | TableOptions RowFormats

AutoIncrements: AutoIncrement IntNum
              | AutoIncrement Equal IntNum
AvgRowLengths: AvgRowLength IntNum
             | AvgRowLength Equal IntNum
DefaultCharSets: Default Charset Equal CharsetOptions
              | Default Charset CharsetOptions
              | Charset Equal CharsetOptions
              | Charset CharsetOptions
Checksums: Checksum ZeroOne
         | Checksum Equal ZeroOne
ZeroOne: IntNum { /* TODO: only 0 or 1*/ }
DefaultCollations: /* empty */
                 | Default CollateOption
                 | CollateOption
Compressions: Compression Equal CompressOptions
            | Compression CompressOptions
CompressOptions: Zlib
               | Lz4
               | None
Encryptions: Encryption Equal SQAnyStr { /* Todo: only 'Y' or 'N' */ }
           | Encryption SQAnyStr { /* Todo: only 'Y' or 'N' */ }
Engines: Engine Equal SQAnyStr
       | Engine SQAnyStr
RowFormats: RowFormat Equal RowFormatOptions
          | RowFormat RowFormatOptions
RowFormatOptions: Default
                | Dynamic
                | Fixed
                | Compressed
                | Redundant
                | Compact
%%

int yydebug = 1;

int main() {

    if(!yyparse()) {
        printf("successfully ended\n");
    }

    long sum = calcTotalSize(true); // debug = true

    printf("------\n\n");
    printf("1 row size = %ld bytes", sum);
    if(sum >= 1024) {
        printf("(%ld KB)", sum/1024);
    }
    printf(".\n");
    return 0;
}