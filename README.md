# Table-size-estimator

Table-size-estimator estimates table size from `CREATE TABLE ...` syntax.

## How to use

git clone & build

```
git clone {table-size-estimator}
cd table-size-estimator
make
```

you can use as simple script

```sh
$ ./tse
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
./tse < tests/input/1.sql
Input Table Definition: (Please type ^d to end input)
successfully ended
------
1 row max size = 28 bytes .
1 row Average size = 28 bytes .
```



### Options

- -d: print all column and index information.

```sh
./tse -d
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
