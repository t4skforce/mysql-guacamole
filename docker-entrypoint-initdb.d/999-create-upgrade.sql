/*
  Setup autoupgrade script tracking
*/
CREATE TABLE IF NOT EXISTS `auto_updates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `scriptname` varchar(255) NOT NULL UNIQUE,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
