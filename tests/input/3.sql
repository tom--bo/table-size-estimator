create table t2 (
  id int not null primary,
  c0 date not null,
  c1 timestamp(6) not null,
  c2 bigint(20) unique key,
  c3 decimal(12,18),
  c4 varchar(32)
);
