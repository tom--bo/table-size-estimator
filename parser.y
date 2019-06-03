%token IntNum RealNum Comma Semi LPar RPar BrckLPar BrckRPar Action Always AS Asc AutoIncrement AvgRowLength BigInt Binary Bit Blob Bool Boolean Btree Cascade Char Charset Character Checksum Collate ColumnFormat Comment Compact Compressed Compression Constraint Create Date Datetime Dec Decimal Default Delete Desc Disk Double Dynamic Encryption Engine Enum Exists Fixed Float Foreign Full Generated Hash IF Index Int Integer Key LongBlob LongText Lz4 Match MediumBlob MediumInt MediumText Memory National No None Not Snull Numeric On Partial Precision Primary Real Redundant References Restrict RowFormat Set SmallInt Simple Storage Stored Table Temporary Text Time Timestamp TinyBlob TinyInt TinyText Unique Unsigned Update Using Utf8 Utf8mb4 Varbinary Varchar Virtual Year SQAnyStr AnyStr Zerofill Zlib Error Equal
%{
#include <stdio.h>
#include "yystype.h"
#include "calc.h"

// #define YYDEBUG 1

void yyerror(char* s) {
    printf("[Error] %s or table-size-estimater doesn't support yet...\n", s);
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
        | IndexKey OptSQAnyStr OptIndexType LPar KeyParts RPar OptReferenceDefinition { addIdxName($2); incNowIdx(); iniNowIdxCol(); }
/* Column */
ColDef: DataType ColDefOptions
ColDefOptions: /* empty */
             | ColDefOptions Snull { setColsNull(true); }
             | ColDefOptions Not Snull { setColsNull(false); }
             | ColDefOptions DefaultOption
             | ColDefOptions AutoIncrement
             | ColDefOptions UniqueKey { setHasIdx(true); }
             | ColDefOptions PrimaryKey { setHasPk(true); }
             | ColDefOptions Comments
             | ColDefOptions ColumnFormat ColumnFormatOption
             | ColDefOptions CollateOption
             | ColDefOptions Storage StorageOption
             | ColDefOptions ReferenceDefinition
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
OptSize: /* empty */ { $$ = "0"; }
       | LPar IntNum RPar { $$ = $2; }
OptAscDesc: /* empty */ { $$ = "asc"; }
          | Asc  { $$ = "asc"; }
          | Desc { $$ = "desc"; }
BtreeHash: Btree
         | Hash
OptConstraintSymbol: /* empty */
                   | Constraint OptSQAnyStr
/* Index */
IndexKey: Index
        | Key
        | OptConstraintSymbol Primary Key
        | OptConstraintSymbol Unique Key
        | OptConstraintSymbol Unique Index
        | OptConstraintSymbol Foreign Key
OptIndexType: /* empty */
         | Using BtreeHash
KeyParts: KeyPart
        | KeyParts Comma KeyPart
KeyPart: SQAnyStr OptSize OptAscDesc { addIdxCol($1, $2, $3); }
OptReferenceDefinition: /* empty */
                      | ReferenceDefinition
ReferenceDefinition: References SQAnyStr LPar KeyParts RPar OptMatch OptAction
OptMatch: /* empty */
        | Match Full
        | Match Partial
        | Match Simple
OptAction: /* empty */
         | On Delete ReferenceOption
         | On Update ReferenceOption
ReferenceOption: Restrict
               | Cascade
               | Set Snull
               | No Action
               | Set Default


/* Table Options */
TableOptions: /* empty */
           | TableOptions AutoIncrements
           | TableOptions AvgRowLengths
           | TableOptions DefaultCharSets
           | TableOptions DefaultCollations
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
DefaultCollations: Default CollateOption
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

#include <unistd.h>

int yydebug = 1;

int main(int argc, char* argv[]) {
    int opt;
    bool debug = false;
    while((opt = getopt(argc, argv, "d")) != -1) {
        switch(opt) {
            case 'd':
                // printf("-d is specified\n");
                debug = true;
                break;
            default:
                printf("Usage: %s [-d] \n", argv[0]);
                return 1;
        }
    }

    printf("Input Table Definition: (Please type ^d to end input) \n");

    if(!yyparse()) {
        printf("successfully ended\n");

        long maxSize, aveSize;
        calcTotalSize(debug, &maxSize, &aveSize); // debug = true

        printResult(maxSize, aveSize);
    }

    return 0;
}