create table `t3` (
  `id` int not null auto_increment,
  `c1` int not null,
  `c2` int not null,
  primary key (`id`),
  unique key `c2` (`c2`),
  foreign key (c2) references users (id)
);
