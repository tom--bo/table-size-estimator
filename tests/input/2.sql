CREATE table `t3` (
  `id` int not null auto_increment,
  `c1` int not null,
  `c2` char(32),
  `c3` varchar(120),
  primary key (`id`),
  unique key `idx1` (`c1`),
  key `idxc13` (`c1`, `c2`)
);
