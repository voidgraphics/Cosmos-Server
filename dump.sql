# ************************************************************
# Sequel Pro SQL dump
# Version 4499
#
# http://www.sequelpro.com/
# https://github.com/sequelpro/sequelpro
#
# Hôte: localhost (MySQL 5.5.42)
# Base de données: cosmos
# Temps de génération: 2016-01-19 03:10:47 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Affichage de la table mockups
# ------------------------------------------------------------

DROP TABLE IF EXISTS `mockups`;

CREATE TABLE `mockups` (
  `id` varchar(255) NOT NULL DEFAULT '',
  `title` varchar(255) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT NULL,
  `updatedAt` timestamp NULL DEFAULT NULL,
  `deletedAt` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `mockups` WRITE;
/*!40000 ALTER TABLE `mockups` DISABLE KEYS */;

INSERT INTO `mockups` (`id`, `title`, `image`, `createdAt`, `updatedAt`, `deletedAt`)
VALUES
	('0161e0f0-be49-11e5-a837-0800200c9a66','Home','cat.jpg',NULL,NULL,NULL),
	('153d0a00-be49-11e5-a837-0800200c9a66','About','hellno.jpg',NULL,NULL,NULL);

/*!40000 ALTER TABLE `mockups` ENABLE KEYS */;
UNLOCK TABLES;


# Affichage de la table tasks
# ------------------------------------------------------------

DROP TABLE IF EXISTS `tasks`;

CREATE TABLE `tasks` (
  `id` varchar(255) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL DEFAULT '',
  `deadline` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT NULL,
  `updatedAt` timestamp NULL DEFAULT NULL,
  `deletedAt` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `tasks` WRITE;
/*!40000 ALTER TABLE `tasks` DISABLE KEYS */;

INSERT INTO `tasks` (`id`, `title`, `deadline`, `state`, `position`, `createdAt`, `updatedAt`, `deletedAt`)
VALUES
	('ec96a3ac-9d0a-4e10-9be3-a35aa9377212','Creating users','2016-01-16','todo',0,NULL,'2016-01-19 01:09:57',NULL),
	('c8b9e3f8-1590-4ecd-9ee5-4dbfd16e9edc','Logging in / out','2016-01-20','todo',1,NULL,'2016-01-19 01:09:57',NULL),
	('9111e89b-02c2-40b5-859e-838d6ff0bf58','Displaying mockups','2016-01-22','inprogress',0,NULL,'2016-01-18 23:43:08','2016-01-18 23:43:14'),
	('e2e7d06c-da03-428c-9a16-1975cbc3dd5f','Adding tasks','2016-01-23','finished',0,NULL,'2016-01-19 01:09:57',NULL),
	('67d1c4d5-cfa7-4ce0-84f7-cc628922fe71','Moving tasks between states','2016-01-28','finished',2,NULL,'2016-01-19 01:09:57',NULL),
	('6266e4f3-ce89-45a1-8c10-cab592e599f8','Creating teams','2016-01-28','inprogress',0,'2016-01-19 00:06:23','2016-01-19 00:06:44','2016-01-19 00:06:51'),
	('f3b81ec9-1524-4c15-8ead-ec448fa1ef28','Joining teams','2016-01-28','inprogress',0,'2016-01-19 00:16:45','2016-01-19 01:09:57',NULL),
	('cb16fa12-b295-457a-a499-7df525911f72','Creating projects','2016-01-30','inprogress',1,'2016-01-19 00:16:49','2016-01-19 00:38:42','2016-01-19 00:38:43'),
	('f2bcf79c-ad4c-456e-8108-bd3deaa67a5a','Chatrooms','2016-01-28','inprogress',0,'2016-01-19 00:16:57','2016-01-19 00:16:57','2016-01-19 00:38:32'),
	('7fe2b87d-f85f-4e54-b22b-67d996b42b0b','Think about branding','2016-01-29','todo',0,'2016-01-19 00:17:04','2016-01-19 01:09:57',NULL),
	('fbf7a5ce-5daf-4770-a36a-d1a245b7a60e','Make logo','2016-01-20','finished',0,'2016-01-19 00:17:11','2016-01-19 01:09:57',NULL),
	('443106e9-e409-47fc-82c7-904f9a295420','Switch to Vue.js','2016-01-28','inprogress',1,'2016-01-19 00:43:05','2016-01-19 01:09:57',NULL);

/*!40000 ALTER TABLE `tasks` ENABLE KEYS */;
UNLOCK TABLES;


# Affichage de la table user_tasks
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user_tasks`;

CREATE TABLE `user_tasks` (
  `user_id` varchar(11) DEFAULT NULL,
  `task_id` varchar(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Affichage de la table users
# ------------------------------------------------------------

DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `id` varchar(11) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
