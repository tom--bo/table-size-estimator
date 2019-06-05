# Table-size-estimator

Table-size-estimator estimates 1 record disk-size from `CREATE TABLE ...` syntax.

## How to use

git clone & build

```
git clone https://github.com/tom--bo/table-size-estimator
cd table-size-estimator
make
```

you can use as simple script

```sh
$ ./bin/tse
 Input Table Definition: (Please type ^d to end input)
 create table `t3` (
   `id` int not null auto_increment primary key,
   `c1` int not null,
   `c2` int not null,
   primary key (`id`),
   unique key `c2` (`c2`)
 );
 # (please type ^d for end of input)
 successfully ended
 ------
 1 row max size = 20 bytes .
 1 row Average size = 20 bytes .
```

Otherwise you can redirect a file which has `CREATE TABLE` syntax.

```sh
./bin/tse < tests/input/1.sql
Input Table Definition: (Please type ^d to end input)
successfully ended
------
1 row max size = 28 bytes .
1 row Average size = 28 bytes .
```



### Options

- -d: print all column and index information.

```sh
./bin/tse -d
-d is specified
Input Table Definition: (Please type ^d to end input)
 create table `t3` (
   `id` int not null auto_increment primary key,
   `c1` int not null,
   `c2` int not null,
   primary key (`id`),
   unique key `c2` (`c2`)
 );
successfully ended

 ====== COLUMN ======
------
Name:    id
Type:    int
MaxSize: 4
AveSize: 4
PK? :    true
Index?:  false
IsNull?: false
------
Name:    c1
Type:    int
MaxSize: 4
AveSize: 4
PK? :    false
Index?:  false
IsNull?: false
------
Name:    c2
Type:    int
MaxSize: 4
AveSize: 4
PK? :    false
Index?:  false
IsNull?: false

 ====== INDEX ======
------
Name:    (NONE)
Max Size:    4
Ave Size:    4
------
Name:    c2
Max Size:    4
Ave Size:    4
------
1 row max size = 20 bytes .
1 row Average size = 20 bytes .
```



## Supported Syntax

Subset of `CREATE TABLE` syntax based on MySQL 5.7

```sql
CREATE [TEMPORARY] TABLE [IF NOT EXISTS] tbl_name
    (create_definition,...)
    [table_options]

create_definition:
    col_name column_definition
  | {INDEX|KEY} [index_name] [index_type] (key_part,...)
  | [CONSTRAINT [symbol]] PRIMARY KEY
      [index_type] (key_part,...)
  | [CONSTRAINT [symbol]] UNIQUE [INDEX|KEY]
      [index_name] [index_type] (key_part,...)
  | [CONSTRAINT [symbol]] FOREIGN KEY
      [index_name] (col_name,...)
      reference_definition

column_definition:
    data_type [NOT NULL | NULL] [DEFAULT default_value]
      [AUTO_INCREMENT] [UNIQUE [KEY]] [[PRIMARY] KEY]
      [COMMENT 'string']
      [COLLATE collation_name]
      [COLUMN_FORMAT {FIXED|DYNAMIC|DEFAULT}]
      [STORAGE {DISK|MEMORY}]
      [reference_definition]
  | data_type
      [COLLATE collation_name]
      [GENERATED ALWAYS] AS (expr)
      [VIRTUAL | STORED] [NOT NULL | NULL]
      [UNIQUE [KEY]] [[PRIMARY] KEY]
      [COMMENT 'string']
      [reference_definition]

data_type:
    (see Chapter 11, Data Types)

key_part:
    col_name [(length)] [ASC | DESC]

index_type:
    USING {BTREE | HASH}

reference_definition:
    REFERENCES tbl_name (key_part,...)
      [MATCH FULL | MATCH PARTIAL | MATCH SIMPLE]
      [ON DELETE reference_option]
      [ON UPDATE reference_option]

reference_option:
    RESTRICT | CASCADE | SET NULL | NO ACTION | SET DEFAULT

table_options:
    table_option [[,] table_option] ...

table_option:
    AUTO_INCREMENT [=] value
  | AVG_ROW_LENGTH [=] value
  | [DEFAULT] CHARACTER SET [=] charset_name
  | CHECKSUM [=] {0 | 1}
  | [DEFAULT] COLLATE [=] collation_name
  | COMMENT [=] 'string'  
  | COMPRESSION [=] {'ZLIB'|'LZ4'|'NONE'}
  | ENCRYPTION [=] {'Y' | 'N'}
  | ENGINE [=] engine_name
  | ROW_FORMAT [=] {DEFAULT|DYNAMIC|FIXED|COMPRESSED|REDUNDANT|COMPACT}
```

### Not supported syntax

- CREATE TABLE AS ... SELECT ...
- CREATE TABLE LIKE ...
- CREATE TABLE [IGNORE | REPLACE]
- FULLTEXT, SPATIAL index
- Part of TABLE_OPTION
- CHECK constraint
- INDEX_OPTION
- PARTITION, SUBPARTITION, PARTITION_OPTIONS

### Will be supported

- Part of TABLE_OPTION
- CHECK constraint
- PARTITION, SUBPARTITION, PARTITION_OPTIONS


## How to test

Exec `make test`!
Please see more Makefile or `tests` dir.

```
make test
```



