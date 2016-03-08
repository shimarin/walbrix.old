-- MySQL dump 10.13  Distrib 5.6.28, for Linux (i686)
--
-- Host: localhost    Database: pimcore
-- ------------------------------------------------------
-- Server version	5.6.28

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `application_logs`
--

DROP TABLE IF EXISTS `application_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `application_logs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `pid` int(11) DEFAULT NULL,
  `timestamp` datetime NOT NULL,
  `message` varchar(1024) DEFAULT NULL,
  `priority` enum('emergency','alert','critical','error','warning','notice','info','debug') DEFAULT NULL,
  `fileobject` varchar(1024) DEFAULT NULL,
  `info` varchar(1024) DEFAULT NULL,
  `component` varchar(255) DEFAULT NULL,
  `source` varchar(255) DEFAULT NULL,
  `relatedobject` bigint(20) DEFAULT NULL,
  `relatedobjecttype` enum('object','document','asset') DEFAULT NULL,
  `maintenanceChecked` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `component` (`component`),
  KEY `timestamp` (`timestamp`),
  KEY `relatedobject` (`relatedobject`),
  KEY `priority` (`priority`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `application_logs`
--

LOCK TABLES `application_logs` WRITE;
/*!40000 ALTER TABLE `application_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `application_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `application_logs_archive_02_2016`
--

DROP TABLE IF EXISTS `application_logs_archive_02_2016`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `application_logs_archive_02_2016` (
  `id` bigint(20) NOT NULL,
  `pid` int(11) DEFAULT NULL,
  `timestamp` datetime NOT NULL,
  `message` varchar(1024) DEFAULT NULL,
  `priority` enum('emergency','alert','critical','error','warning','notice','info','debug') DEFAULT NULL,
  `fileobject` varchar(1024) DEFAULT NULL,
  `info` varchar(1024) DEFAULT NULL,
  `component` varchar(255) DEFAULT NULL,
  `source` varchar(255) DEFAULT NULL,
  `relatedobject` bigint(20) DEFAULT NULL,
  `relatedobjecttype` enum('object','document','asset') DEFAULT NULL,
  `maintenanceChecked` tinyint(4) DEFAULT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `application_logs_archive_02_2016`
--

LOCK TABLES `application_logs_archive_02_2016` WRITE;
/*!40000 ALTER TABLE `application_logs_archive_02_2016` DISABLE KEYS */;
/*!40000 ALTER TABLE `application_logs_archive_02_2016` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assets`
--

DROP TABLE IF EXISTS `assets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assets` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `parentId` int(11) unsigned DEFAULT NULL,
  `type` varchar(20) DEFAULT NULL,
  `filename` varchar(255) DEFAULT '',
  `path` varchar(765) CHARACTER SET ascii DEFAULT NULL,
  `mimetype` varchar(255) DEFAULT NULL,
  `creationDate` bigint(20) unsigned DEFAULT NULL,
  `modificationDate` bigint(20) unsigned DEFAULT NULL,
  `userOwner` int(11) unsigned DEFAULT NULL,
  `userModification` int(11) unsigned DEFAULT NULL,
  `customSettings` text,
  `hasMetaData` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `fullpath` (`path`,`filename`),
  KEY `parentId` (`parentId`),
  KEY `filename` (`filename`),
  KEY `path` (`path`),
  KEY `modificationDate` (`modificationDate`)
) ENGINE=InnoDB AUTO_INCREMENT=71 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assets`
--

LOCK TABLES `assets` WRITE;
/*!40000 ALTER TABLE `assets` DISABLE KEYS */;
INSERT INTO `assets` VALUES (1,0,'folder','','/','',1368522989,1368522989,1,1,'',0),(3,1,'folder','portal-sujets','/','',1368530371,1368632469,0,0,'a:0:{}',0),(4,3,'image','slide-01.jpg','/portal-sujets/','image/jpeg',1368530684,1370432846,0,0,'a:4:{s:10:\"imageWidth\";i:1500;s:11:\"imageHeight\";i:550;s:25:\"imageDimensionsCalculated\";b:1;s:10:\"thumbnails\";N;}',0),(5,3,'image','slide-02.jpg','/portal-sujets/','image/jpeg',1368530764,1370432868,0,0,'a:4:{s:10:\"imageWidth\";i:1500;s:11:\"imageHeight\";i:550;s:25:\"imageDimensionsCalculated\";b:1;s:10:\"thumbnails\";N;}',0),(6,3,'image','slide-03.jpg','/portal-sujets/','image/jpeg',1368530764,1370432860,0,0,'a:4:{s:10:\"imageWidth\";i:1500;s:11:\"imageHeight\";i:550;s:25:\"imageDimensionsCalculated\";b:1;s:10:\"thumbnails\";N;}',0),(7,1,'folder','examples','/','',1368531816,1368632468,0,0,'a:0:{}',0),(17,7,'folder','panama','/examples/','',1368532826,1368632468,0,0,'a:0:{}',0),(18,17,'image','img_0117.jpg','/examples/panama/','image/jpeg',1368532831,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:2000;s:11:\"imageHeight\";i:1500;s:25:\"imageDimensionsCalculated\";b:1;}',0),(19,17,'image','img_0201.jpg','/examples/panama/','image/jpeg',1368532832,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:2000;s:11:\"imageHeight\";i:1500;s:25:\"imageDimensionsCalculated\";b:1;}',0),(20,17,'image','img_0089.jpg','/examples/panama/','image/jpeg',1368532833,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:2000;s:11:\"imageHeight\";i:1500;s:25:\"imageDimensionsCalculated\";b:1;}',0),(21,17,'image','img_0037.jpg','/examples/panama/','image/jpeg',1368532834,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:2000;s:11:\"imageHeight\";i:1500;s:25:\"imageDimensionsCalculated\";b:1;}',0),(22,17,'image','img_0399.jpg','/examples/panama/','image/jpeg',1368532836,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:2000;s:11:\"imageHeight\";i:1500;s:25:\"imageDimensionsCalculated\";b:1;}',0),(23,17,'image','img_0411.jpg','/examples/panama/','image/jpeg',1368532837,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:2000;s:11:\"imageHeight\";i:1500;s:25:\"imageDimensionsCalculated\";b:1;}',0),(24,17,'image','img_0410.jpg','/examples/panama/','image/jpeg',1368532838,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:2000;s:11:\"imageHeight\";i:1500;s:25:\"imageDimensionsCalculated\";b:1;}',0),(25,17,'image','img_0160.jpg','/examples/panama/','image/jpeg',1368532839,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:2000;s:11:\"imageHeight\";i:1500;s:25:\"imageDimensionsCalculated\";b:1;}',0),(26,1,'folder','videos','/','',1368542684,1368632471,0,0,'a:0:{}',0),(27,26,'video','home-trailer-english.mp4','/videos/','video/mp4',1368542794,1405922844,0,0,'a:2:{s:10:\"thumbnails\";a:2:{s:12:\"featurerette\";a:2:{s:6:\"status\";s:8:\"finished\";s:7:\"formats\";a:2:{s:3:\"mp4\";s:83:\"/website/var/tmp/video-thumbnails/0/27/thumb__featurerette/home-trailer-english.mp4\";s:4:\"webm\";s:84:\"/website/var/tmp/video-thumbnails/0/27/thumb__featurerette/home-trailer-english.webm\";}}s:7:\"content\";a:2:{s:6:\"status\";s:8:\"finished\";s:7:\"formats\";a:2:{s:3:\"mp4\";s:78:\"/website/var/tmp/video-thumbnails/0/27/thumb__content/home-trailer-english.mp4\";s:4:\"webm\";s:79:\"/website/var/tmp/video-thumbnails/0/27/thumb__content/home-trailer-english.webm\";}}}s:8:\"duration\";d:147.00999999999999;}',0),(29,1,'folder','documents','/','',1368548619,1368632467,0,0,'a:0:{}',0),(34,1,'folder','screenshots','/','',1368560793,1368632470,0,0,'a:0:{}',0),(35,34,'image','glossary.png','/screenshots/','image/png',1368560809,1368632470,0,0,'a:3:{s:10:\"imageWidth\";i:908;s:11:\"imageHeight\";i:267;s:25:\"imageDimensionsCalculated\";b:1;}',0),(36,29,'document','documentation.pdf','/documents/','application/pdf',1368562442,1368632467,0,0,'a:0:{}',0),(37,7,'folder','italy','/examples/','',1368596763,1368632468,0,0,'a:0:{}',0),(38,37,'image','dsc04346.jpg','/examples/italy/','image/jpeg',1368596767,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:2000;s:11:\"imageHeight\";i:1500;s:25:\"imageDimensionsCalculated\";b:1;}',0),(39,37,'image','dsc04344.jpg','/examples/italy/','image/jpeg',1368596768,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:2000;s:11:\"imageHeight\";i:1500;s:25:\"imageDimensionsCalculated\";b:1;}',0),(40,37,'image','dsc04462.jpg','/examples/italy/','image/jpeg',1368596769,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:2000;s:11:\"imageHeight\";i:1500;s:25:\"imageDimensionsCalculated\";b:1;}',0),(41,37,'image','dsc04399.jpg','/examples/italy/','image/jpeg',1368596770,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:2000;s:11:\"imageHeight\";i:1500;s:25:\"imageDimensionsCalculated\";b:1;}',0),(42,7,'folder','south-africa','/examples/','',1368596785,1368632468,0,0,'a:0:{}',0),(43,42,'image','img_1414.jpg','/examples/south-africa/','image/jpeg',1368596789,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:4000;s:11:\"imageHeight\";i:3000;s:25:\"imageDimensionsCalculated\";b:1;}',0),(44,42,'image','img_2133.jpg','/examples/south-africa/','image/jpeg',1368596791,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:4000;s:11:\"imageHeight\";i:3000;s:25:\"imageDimensionsCalculated\";b:1;}',0),(45,42,'image','img_2240.jpg','/examples/south-africa/','image/jpeg',1368596793,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:4000;s:11:\"imageHeight\";i:3000;s:25:\"imageDimensionsCalculated\";b:1;}',0),(46,42,'image','img_1752.jpg','/examples/south-africa/','image/jpeg',1368596795,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:4000;s:11:\"imageHeight\";i:3000;s:25:\"imageDimensionsCalculated\";b:1;}',0),(47,42,'image','img_1739.jpg','/examples/south-africa/','image/jpeg',1368596798,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:4000;s:11:\"imageHeight\";i:3000;s:25:\"imageDimensionsCalculated\";b:1;}',0),(48,42,'image','img_0391.jpg','/examples/south-africa/','image/jpeg',1368596800,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:3872;s:11:\"imageHeight\";i:2332;s:25:\"imageDimensionsCalculated\";b:1;}',0),(49,42,'image','img_2155.jpg','/examples/south-africa/','image/jpeg',1368596801,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:4000;s:11:\"imageHeight\";i:3000;s:25:\"imageDimensionsCalculated\";b:1;}',0),(50,42,'image','img_1544.jpg','/examples/south-africa/','image/jpeg',1368596804,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:4000;s:11:\"imageHeight\";i:3000;s:25:\"imageDimensionsCalculated\";b:1;}',0),(51,42,'image','img_1842.jpg','/examples/south-africa/','image/jpeg',1368596806,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:4000;s:11:\"imageHeight\";i:3000;s:25:\"imageDimensionsCalculated\";b:1;}',0),(52,42,'image','img_1920.jpg','/examples/south-africa/','image/jpeg',1368596808,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:4000;s:11:\"imageHeight\";i:3000;s:25:\"imageDimensionsCalculated\";b:1;}',0),(53,42,'image','img_0322.jpg','/examples/south-africa/','image/jpeg',1368596810,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:7264;s:11:\"imageHeight\";i:2386;s:25:\"imageDimensionsCalculated\";b:1;}',0),(54,7,'folder','singapore','/examples/','',1368596871,1368632468,0,0,'a:0:{}',0),(55,54,'image','dsc03778.jpg','/examples/singapore/','image/jpeg',1368597116,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:2592;s:11:\"imageHeight\";i:1944;s:25:\"imageDimensionsCalculated\";b:1;}',0),(56,54,'image','dsc03807.jpg','/examples/singapore/','image/jpeg',1368597117,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:2592;s:11:\"imageHeight\";i:1944;s:25:\"imageDimensionsCalculated\";b:1;}',0),(57,54,'image','dsc03835.jpg','/examples/singapore/','image/jpeg',1368597119,1368632468,0,0,'a:3:{s:10:\"imageWidth\";i:2592;s:11:\"imageHeight\";i:1944;s:25:\"imageDimensionsCalculated\";b:1;}',0),(59,34,'image','thumbnail-configuration.png','/screenshots/','image/png',1368606782,1368632470,0,0,'a:3:{s:10:\"imageWidth\";i:809;s:11:\"imageHeight\";i:865;s:25:\"imageDimensionsCalculated\";b:1;}',0),(60,34,'image','website-translations.png','/screenshots/','image/png',1368608949,1368632470,0,0,'a:3:{s:10:\"imageWidth\";i:925;s:11:\"imageHeight\";i:554;s:25:\"imageDimensionsCalculated\";b:1;}',0),(61,34,'image','properties-1.png','/screenshots/','image/png',1368616805,1368632470,0,0,'a:3:{s:10:\"imageWidth\";i:1025;s:11:\"imageHeight\";i:272;s:25:\"imageDimensionsCalculated\";b:1;}',0),(62,34,'image','properties-2.png','/screenshots/','image/png',1368616805,1368632470,0,0,'a:3:{s:10:\"imageWidth\";i:1017;s:11:\"imageHeight\";i:329;s:25:\"imageDimensionsCalculated\";b:1;}',0),(63,34,'image','properties-3.png','/screenshots/','image/png',1368616847,1368632470,0,0,'a:3:{s:10:\"imageWidth\";i:1017;s:11:\"imageHeight\";i:316;s:25:\"imageDimensionsCalculated\";b:1;}',0),(64,34,'image','tag-snippet-management.png','/screenshots/','image/png',1368617634,1368632470,0,0,'a:3:{s:10:\"imageWidth\";i:1063;s:11:\"imageHeight\";i:872;s:25:\"imageDimensionsCalculated\";b:1;}',0),(65,34,'image','objects-forms.png','/screenshots/','image/png',1368623266,1368632470,0,0,'a:3:{s:10:\"imageWidth\";i:308;s:11:\"imageHeight\";i:265;s:25:\"imageDimensionsCalculated\";b:1;}',0),(66,29,'document','example-excel.xlsx','/documents/','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',1378992590,1378992590,0,0,'a:0:{}',0),(67,29,'document','example.docx','/documents/','application/vnd.openxmlformats-officedocument.wordprocessingml.document',1378992591,1378992591,0,0,'a:0:{}',0),(68,29,'document','example.pptx','/documents/','application/vnd.openxmlformats-officedocument.presentationml.presentation',1378992592,1378992592,0,0,'a:0:{}',0),(69,34,'image','e-commerce1.png','/screenshots/','image/png',1388740480,1388740490,0,0,'a:3:{s:10:\"imageWidth\";i:1252;s:11:\"imageHeight\";i:1009;s:25:\"imageDimensionsCalculated\";b:1;}',0),(70,34,'image','pim1.png','/screenshots/','image/png',1388740572,1388740580,0,0,'a:3:{s:10:\"imageWidth\";i:1275;s:11:\"imageHeight\";i:799;s:25:\"imageDimensionsCalculated\";b:1;}',0);
/*!40000 ALTER TABLE `assets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assets_metadata`
--

DROP TABLE IF EXISTS `assets_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assets_metadata` (
  `cid` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `language` varchar(255) DEFAULT NULL,
  `type` enum('input','textarea','asset','document','object','date','select','checkbox') DEFAULT NULL,
  `data` text,
  KEY `cid` (`cid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assets_metadata`
--

LOCK TABLES `assets_metadata` WRITE;
/*!40000 ALTER TABLE `assets_metadata` DISABLE KEYS */;
/*!40000 ALTER TABLE `assets_metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache` (
  `id` varchar(165) NOT NULL DEFAULT '',
  `data` longtext,
  `mtime` bigint(20) DEFAULT NULL,
  `expire` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_tags`
--

DROP TABLE IF EXISTS `cache_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache_tags` (
  `id` varchar(165) NOT NULL DEFAULT '',
  `tag` varchar(165) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`,`tag`),
  KEY `id` (`id`),
  KEY `tag` (`tag`)
) ENGINE=MEMORY DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_tags`
--

LOCK TABLES `cache_tags` WRITE;
/*!40000 ALTER TABLE `cache_tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `classes`
--

DROP TABLE IF EXISTS `classes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `classes` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `creationDate` bigint(20) unsigned DEFAULT NULL,
  `modificationDate` bigint(20) unsigned DEFAULT NULL,
  `userOwner` int(11) unsigned DEFAULT NULL,
  `userModification` int(11) unsigned DEFAULT NULL,
  `allowInherit` tinyint(1) unsigned DEFAULT '0',
  `allowVariants` tinyint(1) unsigned DEFAULT '0',
  `parentClass` varchar(255) DEFAULT NULL,
  `useTraits` varchar(255) DEFAULT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `previewUrl` varchar(255) DEFAULT NULL,
  `propertyVisibility` text,
  `showVariants` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classes`
--

LOCK TABLES `classes` WRITE;
/*!40000 ALTER TABLE `classes` DISABLE KEYS */;
INSERT INTO `classes` VALUES (2,'news','',1368613289,1382958417,0,0,0,0,'',NULL,'','/%title_n%o_id','a:2:{s:4:\"grid\";a:5:{s:2:\"id\";b:1;s:4:\"path\";b:1;s:9:\"published\";b:1;s:16:\"modificationDate\";b:1;s:12:\"creationDate\";b:1;}s:6:\"search\";a:5:{s:2:\"id\";b:1;s:4:\"path\";b:1;s:9:\"published\";b:1;s:16:\"modificationDate\";b:1;s:12:\"creationDate\";b:1;}}',0),(3,'inquiry','',1368620413,1368622807,0,0,0,0,'',NULL,'','','a:2:{s:4:\"grid\";a:5:{s:2:\"id\";b:1;s:4:\"path\";b:1;s:9:\"published\";b:1;s:16:\"modificationDate\";b:1;s:12:\"creationDate\";b:1;}s:6:\"search\";a:5:{s:2:\"id\";b:1;s:4:\"path\";b:1;s:9:\"published\";b:1;s:16:\"modificationDate\";b:1;s:12:\"creationDate\";b:1;}}',0),(4,'person','',1368620452,1368621909,0,0,0,0,'',NULL,'','','a:2:{s:4:\"grid\";a:5:{s:2:\"id\";b:1;s:4:\"path\";b:1;s:9:\"published\";b:1;s:16:\"modificationDate\";b:1;s:12:\"creationDate\";b:1;}s:6:\"search\";a:5:{s:2:\"id\";b:1;s:4:\"path\";b:1;s:9:\"published\";b:1;s:16:\"modificationDate\";b:1;s:12:\"creationDate\";b:1;}}',0),(5,'blogArticle','',1388389165,1388389849,7,7,0,0,'',NULL,'','','a:2:{s:4:\"grid\";a:5:{s:2:\"id\";b:1;s:4:\"path\";b:1;s:9:\"published\";b:1;s:16:\"modificationDate\";b:1;s:12:\"creationDate\";b:1;}s:6:\"search\";a:5:{s:2:\"id\";b:1;s:4:\"path\";b:1;s:9:\"published\";b:1;s:16:\"modificationDate\";b:1;s:12:\"creationDate\";b:1;}}',0),(6,'blogCategory','',1388389401,1388389839,7,7,0,0,'',NULL,'','','a:2:{s:4:\"grid\";a:5:{s:2:\"id\";b:1;s:4:\"path\";b:1;s:9:\"published\";b:1;s:16:\"modificationDate\";b:1;s:12:\"creationDate\";b:1;}s:6:\"search\";a:5:{s:2:\"id\";b:1;s:4:\"path\";b:1;s:9:\"published\";b:1;s:16:\"modificationDate\";b:1;s:12:\"creationDate\";b:1;}}',0);
/*!40000 ALTER TABLE `classes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `classificationstore_collectionrelations`
--

DROP TABLE IF EXISTS `classificationstore_collectionrelations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `classificationstore_collectionrelations` (
  `colId` bigint(20) NOT NULL,
  `groupId` bigint(20) NOT NULL,
  `sorter` int(10) DEFAULT '0',
  PRIMARY KEY (`colId`,`groupId`),
  KEY `colId` (`colId`),
  KEY `FK_classificationstore_collectionrelations_groups` (`groupId`),
  CONSTRAINT `FK_classificationstore_collectionrelations_groups` FOREIGN KEY (`groupId`) REFERENCES `classificationstore_groups` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classificationstore_collectionrelations`
--

LOCK TABLES `classificationstore_collectionrelations` WRITE;
/*!40000 ALTER TABLE `classificationstore_collectionrelations` DISABLE KEYS */;
/*!40000 ALTER TABLE `classificationstore_collectionrelations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `classificationstore_collections`
--

DROP TABLE IF EXISTS `classificationstore_collections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `classificationstore_collections` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `description` varchar(255) DEFAULT NULL,
  `creationDate` bigint(20) unsigned DEFAULT '0',
  `modificationDate` bigint(20) unsigned DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classificationstore_collections`
--

LOCK TABLES `classificationstore_collections` WRITE;
/*!40000 ALTER TABLE `classificationstore_collections` DISABLE KEYS */;
/*!40000 ALTER TABLE `classificationstore_collections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `classificationstore_groups`
--

DROP TABLE IF EXISTS `classificationstore_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `classificationstore_groups` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `parentId` bigint(20) NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  `description` varchar(255) DEFAULT NULL,
  `creationDate` bigint(20) unsigned DEFAULT '0',
  `modificationDate` bigint(20) unsigned DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classificationstore_groups`
--

LOCK TABLES `classificationstore_groups` WRITE;
/*!40000 ALTER TABLE `classificationstore_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `classificationstore_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `classificationstore_keys`
--

DROP TABLE IF EXISTS `classificationstore_keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `classificationstore_keys` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL DEFAULT '',
  `description` text,
  `type` enum('input','textarea','wysiwyg','checkbox','numeric','slider','select','multiselect','date','datetime','language','languagemultiselect','country','countrymultiselect','table','quantityValue','calculatedValue') DEFAULT NULL,
  `creationDate` bigint(20) unsigned DEFAULT '0',
  `modificationDate` bigint(20) unsigned DEFAULT '0',
  `definition` longtext,
  `enabled` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `name` (`name`),
  KEY `enabled` (`enabled`),
  KEY `type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classificationstore_keys`
--

LOCK TABLES `classificationstore_keys` WRITE;
/*!40000 ALTER TABLE `classificationstore_keys` DISABLE KEYS */;
/*!40000 ALTER TABLE `classificationstore_keys` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `classificationstore_relations`
--

DROP TABLE IF EXISTS `classificationstore_relations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `classificationstore_relations` (
  `groupId` bigint(20) NOT NULL,
  `keyId` bigint(20) NOT NULL,
  `sorter` int(10) DEFAULT '0',
  PRIMARY KEY (`groupId`,`keyId`),
  KEY `FK_classificationstore_relations_classificationstore_keys` (`keyId`),
  KEY `groupId` (`groupId`),
  CONSTRAINT `FK_classificationstore_relations_classificationstore_groups` FOREIGN KEY (`groupId`) REFERENCES `classificationstore_groups` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_classificationstore_relations_classificationstore_keys` FOREIGN KEY (`keyId`) REFERENCES `classificationstore_keys` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classificationstore_relations`
--

LOCK TABLES `classificationstore_relations` WRITE;
/*!40000 ALTER TABLE `classificationstore_relations` DISABLE KEYS */;
/*!40000 ALTER TABLE `classificationstore_relations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `custom_layouts`
--

DROP TABLE IF EXISTS `custom_layouts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_layouts` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `classId` int(11) unsigned NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `creationDate` bigint(20) unsigned DEFAULT NULL,
  `modificationDate` bigint(20) unsigned DEFAULT NULL,
  `userOwner` int(11) unsigned DEFAULT NULL,
  `userModification` int(11) unsigned DEFAULT NULL,
  `default` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`,`classId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `custom_layouts`
--

LOCK TABLES `custom_layouts` WRITE;
/*!40000 ALTER TABLE `custom_layouts` DISABLE KEYS */;
/*!40000 ALTER TABLE `custom_layouts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dependencies`
--

DROP TABLE IF EXISTS `dependencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dependencies` (
  `sourcetype` enum('document','asset','object') NOT NULL DEFAULT 'document',
  `sourceid` int(11) unsigned NOT NULL DEFAULT '0',
  `targettype` enum('document','asset','object') NOT NULL DEFAULT 'document',
  `targetid` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`sourcetype`,`sourceid`,`targetid`,`targettype`),
  KEY `sourceid` (`sourceid`),
  KEY `targetid` (`targetid`),
  KEY `sourcetype` (`sourcetype`),
  KEY `targettype` (`targettype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dependencies`
--

LOCK TABLES `dependencies` WRITE;
/*!40000 ALTER TABLE `dependencies` DISABLE KEYS */;
INSERT INTO `dependencies` VALUES ('document',1,'asset',4),('document',1,'document',5),('document',1,'asset',5),('document',1,'document',6),('document',1,'asset',6),('document',1,'document',15),('document',1,'document',16),('document',1,'document',17),('document',1,'asset',18),('document',1,'document',19),('document',1,'asset',19),('document',1,'document',20),('document',1,'asset',22),('document',1,'asset',23),('document',1,'asset',24),('document',1,'asset',27),('document',1,'document',40),('document',1,'asset',55),('document',1,'document',57),('document',1,'document',60),('document',3,'document',7),('document',3,'document',18),('document',3,'document',19),('document',3,'document',20),('document',3,'document',21),('document',3,'asset',22),('document',3,'document',24),('document',3,'document',25),('document',3,'document',26),('document',3,'document',27),('document',3,'document',28),('document',3,'document',29),('document',3,'asset',39),('document',3,'document',40),('document',3,'asset',40),('document',3,'asset',41),('document',3,'asset',44),('document',3,'asset',45),('document',3,'asset',46),('document',3,'asset',47),('document',3,'asset',50),('document',3,'asset',55),('document',3,'asset',56),('document',3,'asset',57),('document',3,'document',60),('document',4,'document',5),('document',4,'document',15),('document',4,'document',16),('document',4,'document',17),('document',4,'asset',22),('document',4,'asset',24),('document',4,'document',40),('document',4,'document',59),('document',4,'document',60),('document',5,'document',40),('document',5,'document',60),('document',5,'document',69),('document',6,'document',40),('document',6,'document',57),('document',6,'document',60),('document',7,'document',3),('document',7,'asset',27),('document',7,'document',40),('document',7,'document',57),('document',7,'document',60),('document',9,'document',5),('document',9,'asset',65),('document',10,'document',40),('document',12,'document',40),('document',15,'document',1),('document',15,'document',3),('document',15,'asset',21),('document',16,'document',1),('document',16,'document',5),('document',16,'asset',20),('document',17,'document',1),('document',17,'document',6),('document',17,'asset',18),('document',18,'document',3),('document',18,'asset',36),('document',18,'document',40),('document',18,'document',57),('document',18,'document',60),('document',19,'document',3),('document',19,'asset',17),('document',19,'asset',38),('document',19,'asset',39),('document',19,'document',40),('document',19,'asset',40),('document',19,'asset',41),('document',19,'asset',43),('document',19,'asset',46),('document',19,'asset',47),('document',19,'asset',48),('document',19,'asset',49),('document',19,'asset',50),('document',19,'asset',51),('document',19,'asset',52),('document',19,'asset',53),('document',19,'document',57),('document',19,'document',60),('document',20,'document',3),('document',20,'asset',35),('document',20,'document',40),('document',20,'document',57),('document',20,'document',60),('document',21,'document',3),('document',21,'document',40),('document',21,'asset',53),('document',21,'document',57),('document',21,'asset',59),('document',21,'document',60),('document',22,'document',3),('document',22,'document',23),('document',22,'document',40),('document',22,'document',57),('document',22,'document',60),('document',22,'asset',60),('document',23,'document',41),('document',24,'document',3),('document',24,'document',7),('document',24,'document',21),('document',24,'asset',22),('document',24,'asset',24),('document',24,'document',26),('document',24,'document',27),('document',24,'asset',27),('document',24,'document',40),('document',24,'asset',44),('document',24,'asset',48),('document',24,'asset',49),('document',24,'asset',51),('document',24,'asset',52),('document',24,'asset',53),('document',24,'document',57),('document',24,'document',60),('document',25,'document',3),('document',25,'document',15),('document',25,'document',19),('document',25,'document',20),('document',25,'document',21),('document',25,'asset',27),('document',25,'document',40),('document',25,'asset',44),('document',25,'asset',45),('document',25,'asset',47),('document',25,'asset',51),('document',25,'asset',54),('document',25,'document',57),('document',25,'document',60),('document',26,'document',3),('document',26,'document',40),('document',26,'document',57),('document',27,'document',3),('document',27,'document',40),('document',27,'document',57),('document',27,'document',60),('document',28,'document',3),('document',28,'asset',61),('document',28,'asset',62),('document',28,'asset',63),('document',29,'document',3),('document',29,'document',40),('document',29,'document',57),('document',29,'document',60),('document',29,'asset',64),('document',30,'document',5),('document',30,'document',40),('document',30,'asset',53),('document',30,'document',60),('document',30,'document',69),('document',31,'document',5),('document',31,'document',30),('document',31,'document',40),('document',31,'document',60),('document',31,'document',69),('document',32,'document',3),('document',33,'document',3),('document',33,'document',5),('document',34,'document',5),('document',35,'document',5),('document',35,'asset',51),('document',35,'asset',53),('document',36,'document',5),('document',36,'document',40),('document',36,'document',57),('document',37,'document',5),('document',37,'document',38),('document',38,'document',5),('document',39,'document',1),('document',40,'document',1),('document',41,'asset',4),('document',41,'document',5),('document',41,'asset',5),('document',41,'document',6),('document',41,'asset',6),('document',41,'asset',18),('document',41,'asset',19),('document',41,'asset',27),('document',41,'document',47),('document',41,'document',48),('document',41,'document',49),('document',41,'asset',55),('document',41,'document',58),('document',42,'document',40),('document',43,'document',40),('document',44,'document',40),('document',45,'document',40),('document',46,'document',40),('document',47,'document',3),('document',47,'asset',21),('document',47,'document',40),('document',48,'document',5),('document',48,'asset',20),('document',48,'document',40),('document',49,'document',6),('document',49,'asset',18),('document',49,'document',40),('document',50,'document',5),('document',50,'asset',22),('document',50,'asset',24),('document',50,'document',41),('document',50,'document',47),('document',50,'document',48),('document',50,'document',49),('document',51,'document',3),('document',51,'document',41),('document',52,'document',5),('document',52,'document',41),('document',53,'document',41),('document',57,'document',15),('document',57,'document',40),('document',58,'document',41),('document',58,'document',47),('document',58,'document',49),('document',58,'document',57),('document',59,'document',15),('document',59,'document',16),('document',59,'document',40),('document',60,'document',5),('document',60,'document',40),('document',60,'document',69),('document',61,'document',5),('document',61,'document',40),('document',61,'document',57),('document',62,'document',40),('document',62,'document',57),('document',63,'document',5),('document',63,'document',40),('document',63,'document',57),('document',64,'document',5),('document',64,'document',40),('document',64,'document',57),('document',65,'document',5),('document',65,'document',40),('document',65,'document',57),('document',66,'document',5),('document',66,'document',40),('document',66,'document',57),('document',67,'asset',22),('document',67,'document',40),('document',67,'document',57),('document',68,'document',5),('document',68,'document',40),('document',68,'document',57),('document',69,'document',5),('document',69,'document',40),('document',69,'document',57),('document',69,'document',60),('document',70,'document',5),('document',70,'document',40),('document',70,'document',60),('document',70,'document',69),('document',70,'asset',70),('document',71,'document',5),('document',71,'document',40),('document',71,'document',60),('document',71,'document',69),('document',71,'asset',69),('document',72,'document',5),('document',72,'document',40),('document',72,'document',60),('document',72,'document',69),('object',3,'document',19),('object',3,'document',24),('object',3,'asset',43),('object',3,'asset',49),('object',3,'asset',52),('object',4,'document',3),('object',4,'document',27),('object',4,'asset',51),('object',6,'asset',25),('object',7,'asset',18),('object',8,'asset',20),('object',9,'asset',21),('object',29,'object',28),('object',31,'object',30),('object',35,'object',37),('object',35,'object',38),('object',39,'asset',23),('object',39,'object',38),('object',40,'asset',20),('object',40,'asset',21),('object',40,'object',36);
/*!40000 ALTER TABLE `dependencies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents`
--

DROP TABLE IF EXISTS `documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `documents` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `parentId` int(11) unsigned DEFAULT NULL,
  `type` enum('page','link','snippet','folder','hardlink','email') DEFAULT NULL,
  `key` varchar(255) DEFAULT '',
  `path` varchar(765) CHARACTER SET ascii DEFAULT NULL,
  `index` int(11) unsigned DEFAULT '0',
  `published` tinyint(1) unsigned DEFAULT '1',
  `creationDate` bigint(20) unsigned DEFAULT NULL,
  `modificationDate` bigint(20) unsigned DEFAULT NULL,
  `userOwner` int(11) unsigned DEFAULT NULL,
  `userModification` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `fullpath` (`path`,`key`),
  KEY `parentId` (`parentId`),
  KEY `key` (`key`),
  KEY `path` (`path`),
  KEY `published` (`published`),
  KEY `modificationDate` (`modificationDate`)
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents`
--

LOCK TABLES `documents` WRITE;
/*!40000 ALTER TABLE `documents` DISABLE KEYS */;
INSERT INTO `documents` VALUES (1,0,'page','','/',999999,1,1368522989,1395151306,1,NULL),(3,40,'page','basic-examples','/en/',1,1,1368523212,1388738504,0,0),(4,40,'page','introduction','/en/',0,1,1368523285,1395042868,0,NULL),(5,40,'page','advanced-examples','/en/',2,1,1368523389,1388738496,0,0),(6,40,'page','experiments','/en/',3,1,1368523410,1395043974,0,NULL),(7,3,'page','html5-video','/en/basic-examples/',1,1,1368525394,1395042970,0,NULL),(9,5,'page','creating-objects-using-forms','/en/advanced-examples/',1,1,1368525933,1382956042,0,0),(10,40,'folder','shared','/en/',5,1,1368527956,1382956831,0,0),(11,10,'folder','includes','/en/shared/',1,1,1368527961,1382956831,0,0),(12,11,'snippet','footer','/en/shared/includes/',1,1,1368527967,1382956852,0,0),(13,10,'folder','teasers','/en/shared/',2,1,1368531657,1382956831,0,0),(14,13,'folder','standard','/en/shared/teasers/',1,1,1368531665,1382956831,0,0),(15,14,'snippet','basic-examples','/en/shared/teasers/standard/',1,1,1368531692,1382956831,0,0),(16,14,'snippet','advanced-examples','/en/shared/teasers/standard/',2,1,1368534298,1382956831,0,0),(17,14,'snippet','experiments','/en/shared/teasers/standard/',3,1,1368534344,1382956831,0,0),(18,3,'page','pdf-viewer','/en/basic-examples/',2,1,1368548449,1395042961,0,NULL),(19,3,'page','galleries','/en/basic-examples/',3,1,1368549805,1395043436,0,NULL),(20,3,'page','glossary','/en/basic-examples/',4,1,1368559903,1395043487,0,NULL),(21,3,'page','thumbnails','/en/basic-examples/',5,1,1368602443,1395043532,0,NULL),(22,3,'page','website-translations','/en/basic-examples/',6,1,1368607207,1395043561,0,NULL),(23,51,'page','website-uebersetzungen','/de/einfache-beispiele/',0,1,1368608357,1382958135,0,0),(24,3,'page','content-page','/en/basic-examples/',0,1,1368609059,1405923178,0,NULL),(25,3,'page','editable-roundup','/en/basic-examples/',7,1,1368609569,1395043587,0,NULL),(26,3,'page','form','/en/basic-examples/',8,1,1368610663,1388733533,0,0),(27,3,'page','news','/en/basic-examples/',9,1,1368613137,1395043614,0,NULL),(28,3,'page','properties','/en/basic-examples/',10,1,1368615986,1382956040,0,0),(29,3,'page','tag-and-snippet-management','/en/basic-examples/',11,1,1368617118,1395043636,0,NULL),(30,5,'page','content-inheritance','/en/advanced-examples/',2,1,1368623726,1395043816,0,NULL),(31,30,'page','content-inheritance','/en/advanced-examples/content-inheritance/',2,1,1368623866,1395043901,0,NULL),(32,3,'link','pimcore.org','/en/basic-examples/',12,1,1368626404,1382956040,0,0),(33,34,'hardlink','basic-examples','/en/advanced-examples/hard-link/',0,1,1368626461,1382956042,0,0),(34,5,'page','hard-link','/en/advanced-examples/',3,1,1368626655,1382956042,0,0),(35,5,'page','image-with-hotspots-and-markers','/en/advanced-examples/',4,1,1368626888,1382956042,0,0),(36,5,'page','search','/en/advanced-examples/',5,1,1368629524,1388733927,0,0),(37,5,'page','contact-form','/en/advanced-examples/',6,1,1368630444,1382956042,0,0),(38,37,'email','email','/en/advanced-examples/contact-form/',1,1,1368631410,1382956042,0,0),(39,1,'page','error','/',3,1,1369854325,1369854422,0,0),(40,1,'link','en','/',0,1,1382956013,1382956551,0,0),(41,1,'page','de','/',2,1,1382956716,1382962917,0,0),(42,41,'folder','shared','/de/',4,1,1382956884,1382956887,0,0),(43,42,'folder','includes','/de/shared/',1,1,1382956885,1382956888,0,0),(44,42,'folder','teasers','/de/shared/',2,1,1382956885,1382956888,0,0),(45,44,'folder','standard','/de/shared/teasers/',1,1,1382956885,1382956888,0,0),(46,43,'snippet','footer','/de/shared/includes/',1,1,1382956886,1382956919,0,0),(47,45,'snippet','basic-examples','/de/shared/teasers/standard/',1,1,1382956886,1382957000,0,0),(48,45,'snippet','advanced-examples','/de/shared/teasers/standard/',2,1,1382956886,1382957114,0,0),(49,45,'snippet','experiments','/de/shared/teasers/standard/',3,1,1382956887,1382957197,0,0),(50,41,'page','einfuehrung','/de/',0,1,1382957658,1382957760,0,0),(51,41,'page','einfache-beispiele','/de/',1,1,1382957793,1382957910,0,0),(52,41,'page','beispiele-fur-fortgeschrittene','/de/',2,1,1382957961,1382957999,0,0),(53,51,'page','neuigkeiten','/de/einfache-beispiele/',9,1,1382958188,1382958240,0,0),(57,40,'snippet','sidebar','/en/',4,1,1382962826,1388735598,0,0),(58,41,'snippet','sidebar','/de/',3,1,1382962891,1382962906,0,0),(59,4,'snippet','sidebar','/en/introduction/',1,1,1382962940,1388738272,0,0),(60,5,'page','blog','/en/advanced-examples/',0,1,1388391128,1395043669,7,NULL),(61,5,'page','sitemap','/en/advanced-examples/',7,1,1388406334,1388406406,0,0),(62,1,'folder','newsletters','/',5,1,1388409377,1388409377,0,0),(63,5,'page','newsletter','/en/advanced-examples/',8,1,1388409438,1388409571,0,0),(64,63,'page','confirm','/en/advanced-examples/newsletter/',1,1,1388409594,1388409641,0,0),(65,63,'page','unsubscribe','/en/advanced-examples/newsletter/',2,1,1388409614,1388412346,0,0),(66,63,'email','confirmation-email','/en/advanced-examples/newsletter/',3,1,1388409670,1388412587,0,0),(67,62,'email','example-mailing','/newsletters/',1,1,1388412605,1388412917,0,0),(68,5,'page','asset-thumbnail-list','/en/advanced-examples/',9,1,1388414727,1388414883,0,0),(69,5,'snippet','sidebar','/en/advanced-examples/',13,1,1388734403,1388738477,0,0),(70,5,'page','product-information-management','/en/advanced-examples/',12,1,1388740191,1388740585,0,0),(71,5,'page','e-commerce','/en/advanced-examples/',11,1,1388740265,1388740613,0,0),(72,5,'page','sub-modules','/en/advanced-examples/',10,1,1419933647,1419933980,32,32);
/*!40000 ALTER TABLE `documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents_elements`
--

DROP TABLE IF EXISTS `documents_elements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `documents_elements` (
  `documentId` int(11) unsigned NOT NULL DEFAULT '0',
  `name` varchar(750) CHARACTER SET ascii NOT NULL DEFAULT '',
  `type` varchar(50) DEFAULT NULL,
  `data` longtext,
  PRIMARY KEY (`documentId`,`name`),
  KEY `documentId` (`documentId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents_elements`
--

LOCK TABLES `documents_elements` WRITE;
/*!40000 ALTER TABLE `documents_elements` DISABLE KEYS */;
INSERT INTO `documents_elements` VALUES (1,'authorcontent3','input','Albert Einstein'),(1,'blockcontent1','block','a:3:{i:0;s:1:\"1\";i:1;s:1:\"2\";i:2;s:1:\"3\";}'),(1,'caption-text-0content3','textarea','Isla Colón, Bocas del Toro, Republic of Panama'),(1,'caption-text-1content3','textarea',''),(1,'caption-text-2content3','textarea',''),(1,'caption-title-0content3','input','Bocas del Toro'),(1,'caption-title-1content3','input',''),(1,'caption-title-2content3','input',''),(1,'carouselSlides','select','3'),(1,'cHeadline_0','input','Ready to be impressed?'),(1,'cHeadline_1','input','It\'ll blow your mind.'),(1,'cHeadline_2','input','Oh yeah, it\'s that good'),(1,'cImage_0','image','a:9:{s:2:\"id\";i:4;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(1,'cImage_1','image','a:9:{s:2:\"id\";i:5;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(1,'cImage_2','image','a:9:{s:2:\"id\";i:6;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(1,'cLink_0','link','a:14:{s:4:\"text\";s:16:\"See it in Action\";s:4:\"path\";s:18:\"/en/basic-examples\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:3;s:12:\"internalType\";s:8:\"document\";}'),(1,'cLink_1','link','a:15:{s:4:\"text\";s:16:\"See it in Action\";s:4:\"path\";s:18:\"/advanced-examples\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:5;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(1,'cLink_2','link','a:15:{s:4:\"text\";s:9:\"Checkmate\";s:4:\"path\";s:12:\"/experiments\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:6;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(1,'content','areablock','a:7:{i:0;a:2:{s:3:\"key\";s:1:\"6\";s:4:\"type\";s:15:\"icon-teaser-row\";}i:1;a:2:{s:3:\"key\";s:1:\"5\";s:4:\"type\";s:15:\"horizontal-line\";}i:2;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:10:\"featurette\";}i:3;a:2:{s:3:\"key\";s:1:\"7\";s:4:\"type\";s:18:\"tabbed-slider-text\";}i:4;a:2:{s:3:\"key\";s:1:\"8\";s:4:\"type\";s:15:\"horizontal-line\";}i:5;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:19:\"standard-teaser-row\";}i:6;a:2:{s:3:\"key\";s:1:\"3\";s:4:\"type\";s:16:\"gallery-carousel\";}}'),(1,'contentcontent_blockcontent11_1','wysiwyg','<p>In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi.</p>\n'),(1,'contentcontent_blockcontent11_2','wysiwyg','<p>Donec ullamcorper nulla non metus auctor fringilla. Vestibulum id ligula porta felis euismod semper. Praesent commodo cursus magna, vel scelerisque nisl consectetur. Fusce dapibus, tellus ac cursus commodo.</p>\n'),(1,'contentcontent_blockcontent11_3','wysiwyg','<p>Donec ullamcorper nulla non metus auctor fringilla. Vestibulum id ligula porta felis euismod semper. Praesent commodo cursus magna, vel scelerisque nisl consectetur. Fusce dapibus, tellus ac cursus commodo.</p>\n'),(1,'cText_0','textarea','Check out our examples and dive into the next generation of digital data management.'),(1,'cText_1','textarea','See for yourself.'),(1,'cText_2','textarea','See for yourself'),(1,'description_0content7','textarea','pimcore is the only open-source multi-channel experience and engagement management platform available. '),(1,'description_1content7','textarea','With complete creative freedom, flexibility, and agility, pimcore is a dream come true for designers and developers.'),(1,'description_2content7','textarea','pimcore makes it easier to manage large international sites with key features like advanced content reuse, inheritance, and distribution. pimcore is based on UTF-8 standards and is compatible to any language including Right-to-Left (RTL).'),(1,'headlinecontent4','input','Good looking and completely custom galleries'),(1,'headlinecontent_blockcontent11_1','input','Lorem ipsum.'),(1,'headlinecontent_blockcontent11_2','input','Oh yeah, it\'s that good.'),(1,'headlinecontent_blockcontent11_3','input','And lastly, this one.'),(1,'headline_0content7','input','About Us'),(1,'headline_1content7','input','100% Flexible 100% Editable'),(1,'headline_2content7','input','International and Multi-site'),(1,'icon_0content6','select','phone'),(1,'icon_1content6','select','bullhorn'),(1,'icon_2content6','select','screenshot'),(1,'imagecontent_blockcontent11_1','image','a:9:{s:2:\"id\";i:55;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(1,'imagecontent_blockcontent11_2','image','a:9:{s:2:\"id\";i:18;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(1,'imagecontent_blockcontent11_3','image','a:9:{s:2:\"id\";i:19;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(1,'imagePositioncontent_blockcontent11_1','select',''),(1,'imagePositioncontent_blockcontent11_2','select','left'),(1,'imagePositioncontent_blockcontent11_3','select',''),(1,'image_0content3','image','a:9:{s:2:\"id\";i:22;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(1,'image_0content7','image','a:9:{s:2:\"id\";N;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(1,'image_1content3','image','a:9:{s:2:\"id\";i:24;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(1,'image_1content7','image','a:9:{s:2:\"id\";i:5;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(1,'image_2content3','image','a:9:{s:2:\"id\";i:23;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(1,'image_2content7','image','a:9:{s:2:\"id\";N;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(1,'leadcontent4','wysiwyg','<p>Are integrated within minutes</p>\n'),(1,'link_0content6','link','a:15:{s:4:\"text\";s:9:\"Read More\";s:4:\"path\";s:27:\"/en/basic-examples/glossary\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:20;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(1,'link_1content6','link','a:15:{s:4:\"text\";s:9:\"Read More\";s:4:\"path\";s:28:\"/en/basic-examples/galleries\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:19;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(1,'link_2content6','link','a:15:{s:4:\"text\";s:9:\"Read More\";s:4:\"path\";s:28:\"/en/basic-examples/galleries\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:19;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(1,'multiselect','multiselect','a:0:{}'),(1,'myCheckbox','checkbox',''),(1,'myDate','date',NULL),(1,'myHref','href','a:3:{s:2:\"id\";N;s:4:\"type\";N;s:7:\"subtype\";N;}'),(1,'myImageBlock','block','a:0:{}'),(1,'myInput','input',''),(1,'myLink','link','a:10:{s:4:\"type\";s:8:\"internal\";s:4:\"path\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:6:\"target\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(1,'myMultihref','multihref','a:0:{}'),(1,'myNumber','numeric',''),(1,'mySelect','select',''),(1,'myTextarea','textarea',''),(1,'myWysiwyg','wysiwyg',''),(1,'pill-small_0content7','input','What is pimcore?'),(1,'pill-small_1content7','input','and enjoy creative freedom'),(1,'pill-small_2content7','input','中國人嗎？沒問題。'),(1,'pill-title_0content7','input','About us'),(1,'pill-title_1content7','input','Think different'),(1,'pill-title_2content7','input','International and Multi-site'),(1,'postitioncontent_blockcontent11_1','select',''),(1,'postitioncontent_blockcontent11_2','select','left'),(1,'postitioncontent_blockcontent11_3','select',''),(1,'quotecontent3','input','We can\'t solve problems by using the same kind of thinking we used when we created them.'),(1,'showPreviewscontent3','checkbox','1'),(1,'slidescontent3','select','3'),(1,'slidescontent7','select','3'),(1,'sublinecontent_blockcontent11_1','input','Cum sociis.'),(1,'sublinecontent_blockcontent11_2','input','See for yourself.'),(1,'sublinecontent_blockcontent11_3','input','Checkmate.'),(1,'teaser_0content2','snippet','15'),(1,'teaser_1content2','snippet','16'),(1,'teaser_2content2','snippet','17'),(1,'text_0content6','textarea','This demo is based on the Bootstrap framework which is the most popular, intuitive and powerful front-end framework available.'),(1,'text_1content6','textarea','HTML5, Javascript, CSS3, jQuery as well as concepts like responsive, mobile-apps or non-linear design-patterns.'),(1,'text_2content6','textarea','Content is created by simply dragging & dropping blocks, that can be editited in-place and wysiwyg in a very intuitive and comfortable way. '),(1,'title_0content6','input','Fully Responsive'),(1,'title_1content6','input','100% Buzzword Compatible'),(1,'title_2content6','input','Drag & Drop Interface'),(1,'typecontent_blockcontent11_1','select',''),(1,'typecontent_blockcontent11_2','select','video'),(1,'typecontent_blockcontent11_3','select',''),(1,'type_0content2','select',''),(1,'type_1content2','select',''),(1,'type_2content2','select',''),(1,'videocontent_blockcontent11_2','video','a:5:{s:2:\"id\";i:27;s:4:\"type\";s:5:\"asset\";s:5:\"title\";s:0:\"\";s:11:\"description\";s:0:\"\";s:6:\"poster\";N;}'),(3,'circle1content1','checkbox',''),(3,'circle1content2','checkbox','1'),(3,'circle1content3','checkbox','1'),(3,'circle1content4','checkbox',''),(3,'circle2content1','checkbox',''),(3,'circle2content2','checkbox','1'),(3,'circle2content3','checkbox','1'),(3,'circle2content4','checkbox',''),(3,'circle3content1','checkbox',''),(3,'circle3content2','checkbox','1'),(3,'circle3content3','checkbox','1'),(3,'circle3content4','checkbox',''),(3,'content','areablock','a:4:{i:0;a:2:{s:3:\"key\";s:1:\"3\";s:4:\"type\";s:19:\"standard-teaser-row\";}i:1;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:19:\"standard-teaser-row\";}i:2;a:2:{s:3:\"key\";s:1:\"4\";s:4:\"type\";s:19:\"standard-teaser-row\";}i:3;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:19:\"standard-teaser-row\";}}'),(3,'headDescription','input',''),(3,'headline','input','Basic Examples'),(3,'headline1content1','input','HTML5 Video'),(3,'headline1content2','input','Glossary'),(3,'headline1content3','input','Simple Content'),(3,'headline1content4','input','News'),(3,'headline2content1','input','PDF Viewer'),(3,'headline2content2','input','Thumbnails'),(3,'headline2content3','input','Round-Up'),(3,'headline2content4','input','Properties'),(3,'headline3content1','input','Galleries'),(3,'headline3content2','input','Website Translations'),(3,'headline3content3','input','Simple Form'),(3,'headline3content4','input','Tag Manager'),(3,'headTitle','input',''),(3,'image1content1','image','a:9:{s:2:\"id\";i:41;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(3,'image1content2','image','a:9:{s:2:\"id\";i:55;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(3,'image1content3','image','a:9:{s:2:\"id\";i:50;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(3,'image1content4','image','a:9:{s:2:\"id\";i:47;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(3,'image2content1','image','a:9:{s:2:\"id\";i:39;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(3,'image2content2','image','a:9:{s:2:\"id\";i:56;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(3,'image2content3','image','a:9:{s:2:\"id\";i:45;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(3,'image2content4','image','a:9:{s:2:\"id\";i:46;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(3,'image3content1','image','a:9:{s:2:\"id\";i:40;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(3,'image3content2','image','a:9:{s:2:\"id\";i:57;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(3,'image3content3','image','a:9:{s:2:\"id\";i:44;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(3,'image3content4','image','a:9:{s:2:\"id\";i:22;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(3,'link1content1','link','a:15:{s:4:\"text\";s:16:\"See it in Action\";s:4:\"path\";s:27:\"/basic-examples/html5-video\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:7;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(3,'link1content2','link','a:15:{s:4:\"text\";s:16:\"See it in Action\";s:4:\"path\";s:24:\"/basic-examples/glossary\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:20;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(3,'link1content3','link','a:15:{s:4:\"text\";s:16:\"See it in Action\";s:4:\"path\";s:28:\"/basic-examples/content-page\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:24;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(3,'link1content4','link','a:15:{s:4:\"text\";s:16:\"See it in Action\";s:4:\"path\";s:20:\"/basic-examples/news\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:27;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(3,'link2content1','link','a:15:{s:4:\"text\";s:16:\"See it in Action\";s:4:\"path\";s:26:\"/basic-examples/pdf-viewer\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:18;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(3,'link2content2','link','a:15:{s:4:\"text\";s:16:\"See it in Action\";s:4:\"path\";s:26:\"/basic-examples/thumbnails\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:21;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(3,'link2content3','link','a:15:{s:4:\"text\";s:16:\"See it in Action\";s:4:\"path\";s:32:\"/basic-examples/editable-roundup\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:25;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(3,'link2content4','link','a:15:{s:4:\"text\";s:16:\"See it in Action\";s:4:\"path\";s:26:\"/basic-examples/properties\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:28;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(3,'link3content1','link','a:15:{s:4:\"text\";s:16:\"See it in Action\";s:4:\"path\";s:25:\"/basic-examples/galleries\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:19;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(3,'link3content2','link','a:10:{s:4:\"type\";s:8:\"internal\";s:4:\"path\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:6:\"target\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(3,'link3content3','link','a:15:{s:4:\"text\";s:16:\"See it in Action\";s:4:\"path\";s:20:\"/basic-examples/form\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:26;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(3,'link3content4','link','a:15:{s:4:\"text\";s:16:\"See it in Action\";s:4:\"path\";s:42:\"/basic-examples/tag-and-snippet-management\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:29;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(3,'text1content1','wysiwyg','<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.</p>\n'),(3,'text1content2','wysiwyg','<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.</p>\n'),(3,'text1content3','wysiwyg','<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.</p>\n'),(3,'text1content4','wysiwyg','<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.</p>\n'),(3,'text2content1','wysiwyg','<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.</p>\n'),(3,'text2content2','wysiwyg','<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.</p>\n'),(3,'text2content3','wysiwyg','<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.</p>\n'),(3,'text2content4','wysiwyg','<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.</p>\n'),(3,'text3content1','wysiwyg','<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.</p>\n'),(3,'text3content2','wysiwyg','<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.</p>\n'),(3,'text3content3','wysiwyg','<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.</p>\n'),(3,'text3content4','wysiwyg','<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.</p>\n'),(3,'type_0content1','select','direct'),(3,'type_0content2','select','direct'),(3,'type_0content3','select','direct'),(3,'type_0content4','select','direct'),(3,'type_1content1','select','direct'),(3,'type_1content2','select','direct'),(3,'type_1content3','select','direct'),(3,'type_1content4','select','direct'),(3,'type_2content1','select','direct'),(3,'type_2content2','select','direct'),(3,'type_2content3','select','direct'),(3,'type_2content4','select','direct'),(4,'blockcontent2','block','a:1:{i:0;s:1:\"1\";}'),(4,'circle2content1','checkbox',''),(4,'content','areablock','a:4:{i:0;a:2:{s:3:\"key\";s:1:\"4\";s:4:\"type\";s:9:\"headlines\";}i:1;a:2:{s:3:\"key\";s:1:\"3\";s:4:\"type\";s:7:\"wysiwyg\";}i:2;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:19:\"standard-teaser-row\";}i:3;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:10:\"featurette\";}}'),(4,'contentcontent3','wysiwyg','<p>Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. <a href=\"/basic-examples\">Etiam rhoncus</a>.</p>\n\n<p>&nbsp;</p>\n\n<ul>\n	<li>Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum.</li>\n	<li>Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem.</li>\n	<li>Maecenas nec odio et ante tincidunt tempus.</li>\n	<li><a href=\"/basic-examples\">Donec vitae sapien ut libero venenatis faucibus.</a></li>\n	<li>Nullam quis ante.</li>\n	<li>Etiam sit amet orci eget eros <a href=\"/advanced-examples\">faucibus </a>tincidunt.</li>\n</ul>\n\n<p>&nbsp;</p>\n\n<p>Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform <a href=\"/experiments\">grammatica</a>, pronunciation e plu sommun paroles.</p>\n\n<p>&nbsp;</p>\n\n<ol>\n	<li>It va esser tam simplic quam Occidental in fact, it va esser Occidental.</li>\n	<li>A un Angleso it va semblar un simplificat Angles, quam un skeptic <a href=\"/introduction\">Cambridge </a>amico dit me que Occidental es.</li>\n	<li>Li Europan lingues es membres del sam familie.</li>\n	<li>Lor separat existentie es un myth.</li>\n	<li>Por scientie, musica, sport etc, litot Europa usa li sam vocabular.</li>\n	<li>Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules.</li>\n</ol>\n\n<p>&nbsp;</p>\n'),(4,'contentcontent_blockcontent22_1','wysiwyg','<p>Donec ullamcorper nulla non metus auctor fringilla. Vestibulum id ligula porta felis euismod semper. Praesent commodo cursus magna, vel scelerisque nisl consectetur. Fusce dapibus, tellus ac cursus commodo. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo.</p>\n'),(4,'headDescription','input','Overview of the project and how to get started with a simple template.'),(4,'headline','input','Introduction'),(4,'headline2content1','input',''),(4,'headlinecontent4','input','Maecenas tempus, tellus eget condimentum rhoncu'),(4,'headlinecontent_blockcontent22_1','input','Ullamcorper Scelerisque '),(4,'headTitle','input','Getting started'),(4,'image2content1','image','a:9:{s:2:\"id\";N;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(4,'imagecontent1','image','a:9:{s:2:\"id\";i:22;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(4,'imagecontent_blockcontent22_1','image','a:9:{s:2:\"id\";i:24;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(4,'imagePositioncontent_blockcontent22_1','select',''),(4,'leadcontent3','wysiwyg','<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.</p>\n'),(4,'leadcontent4','wysiwyg','<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.</p>\n'),(4,'link2content1','link','a:10:{s:4:\"type\";s:8:\"internal\";s:4:\"path\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:6:\"target\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(4,'linkcontent1','link','a:14:{s:4:\"text\";s:12:\"Etiam rhoncu\";s:4:\"path\";s:18:\"/advanced-examples\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:5;s:12:\"internalType\";s:8:\"document\";}'),(4,'postitioncontent_blockcontent22_1','select',''),(4,'sublinecontent_blockcontent22_1','input',''),(4,'teaser_0content1','snippet','15'),(4,'teaser_1content1','snippet','16'),(4,'teaser_2content1','snippet','17'),(4,'text2content1','wysiwyg',''),(4,'textcontent1','wysiwyg','<p>Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna.</p>\n'),(4,'typecontent_blockcontent22_1','select',''),(4,'type_0content1','select',''),(4,'type_1content1','select','snippet'),(4,'type_2content1','select','snippet'),(5,'content','areablock','a:1:{i:0;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:7:\"wysiwyg\";}}'),(5,'contentcontent1','wysiwyg','<p>The following list is generated automatically. See controller/action to see how it\'s done.&nbsp;</p>\n'),(5,'headDescription','input',''),(5,'headline','input','Advanced Examples'),(5,'headTitle','input',''),(5,'leadcontent1','wysiwyg',''),(6,'content','areablock','a:2:{i:0;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:9:\"headlines\";}i:1;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:7:\"wysiwyg\";}}'),(6,'contentcontent1','wysiwyg','<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt.</p>\n\n<p>&nbsp;</p>\n\n<p>Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet.</p>\n\n<p>&nbsp;</p>\n\n<p>Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc,</p>\n'),(6,'headDescription','input',''),(6,'headline','input','Experiments'),(6,'headlinecontent2','input','This space is reserved for your individual experiments & tests.'),(6,'headTitle','input',''),(6,'leadcontent1','wysiwyg',''),(6,'leadcontent2','wysiwyg',''),(7,'content','areablock','a:2:{i:0;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:9:\"headlines\";}i:1;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:5:\"video\";}}'),(7,'headDescription','input',''),(7,'headline','input','HTML5 Video is just as simple as that ....'),(7,'headlinecontent2','input',''),(7,'headTitle','input',''),(7,'leadcontent1','wysiwyg','<p>Just drop an video from your assets, the video will be automatically converted to the different HTML5 formats and to the correct size.&nbsp;</p>\n'),(7,'leadcontent2','wysiwyg','<p>Just drop an video from your assets, the video will be automatically converted to the different HTML5 formats and to the correct size.</p>\n'),(7,'videocontent1','video','a:5:{s:2:\"id\";i:27;s:4:\"type\";s:5:\"asset\";s:5:\"title\";s:0:\"\";s:11:\"description\";s:0:\"\";s:6:\"poster\";N;}'),(9,'content','areablock','a:1:{i:0;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:7:\"wysiwyg\";}}'),(9,'contentcontent1','wysiwyg','<p>&nbsp;</p>\n\n<p>In this example we dynamically create objects out of the data submitted via the form.</p>\n\n<p>The you can use the same approach to create objects using a <strong>commandline script</strong>, or wherever you need it.</p>\n\n<p>After submitting the form you\'ll find the data in \"Objects\" <em>/crm</em> and <em>/inquiries</em>.&nbsp;</p>\n\n<p>&nbsp;</p>\n\n<p><img pimcore_disable_thumbnail=\"true\" pimcore_id=\"65\" pimcore_type=\"asset\" src=\"/screenshots/objects-forms.png\" style=\"width:308px\" /></p>\n\n<p>&nbsp;</p>\n\n<hr />\n<h2><strong>And here\'s the form:&nbsp;</strong></h2>\n'),(9,'errorMessage','input','Please fill all fields and accept the terms of use. '),(9,'headDescription','input',''),(9,'headline','input','Creating Objects & Assets with a Form'),(9,'headTitle','input',''),(9,'leadcontent1','wysiwyg',''),(12,'linklinks1','link','a:11:{s:4:\"text\";s:11:\"pimcore.org\";s:4:\"path\";s:23:\"http://www.pimcore.org/\";s:6:\"target\";s:6:\"_blank\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(12,'linklinks2','link','a:11:{s:4:\"text\";s:13:\"Documentation\";s:4:\"path\";s:28:\"http://www.pimcore.org/wiki/\";s:6:\"target\";s:6:\"_blank\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(12,'linklinks3','link','a:11:{s:4:\"text\";s:11:\"Bug Tracker\";s:4:\"path\";s:30:\"http://www.pimcore.org/issues/\";s:6:\"target\";s:6:\"_blank\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(12,'links','block','a:3:{i:0;s:1:\"1\";i:1;s:1:\"2\";i:2;s:1:\"3\";}'),(12,'multiselect','multiselect','a:0:{}'),(12,'myCheckbox','checkbox',''),(12,'myDate','date',''),(12,'myHref','href','a:3:{s:2:\"id\";N;s:4:\"type\";N;s:7:\"subtype\";N;}'),(12,'myImageBlock','block','a:0:{}'),(12,'myInput','input',''),(12,'myLink','link','a:10:{s:4:\"type\";s:8:\"internal\";s:4:\"path\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:6:\"target\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(12,'myMultihref','multihref','a:0:{}'),(12,'myNumber','numeric',''),(12,'mySelect','select',''),(12,'myTextarea','textarea',''),(12,'myWysiwyg','wysiwyg',''),(12,'text','wysiwyg','<p>Designed and built with all the love in the world by&nbsp;<a href=\"http://twitter.com/mdo\" target=\"_blank\">@mdo</a>&nbsp;and&nbsp;<a href=\"http://twitter.com/fat\" target=\"_blank\">@fat</a>.</p>\n\n<p>Code licensed under&nbsp;<a href=\"http://www.apache.org/licenses/LICENSE-2.0\" target=\"_blank\">Apache License v2.0</a>,&nbsp;<a href=\"http://glyphicons.com/\">Glyphicons Free</a>&nbsp;licensed under&nbsp;<a href=\"http://creativecommons.org/licenses/by/3.0/\">CC BY 3.0</a>.</p>\n\n<p><strong>© Templates pimcore.org licensed under BSD License</strong></p>\n'),(15,'circle','checkbox',''),(15,'headline','input','Fully Responsive'),(15,'image','image','a:9:{s:2:\"id\";i:21;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(15,'link','link','a:15:{s:4:\"text\";s:11:\"Lorem ipsum\";s:4:\"path\";s:15:\"/basic-examples\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:3;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(15,'text','wysiwyg','<p>This demo is based on Bootstrap, the most popular, intuitive, and powerful front-end framework.</p>\n'),(16,'circle','checkbox',''),(16,'headline','input','Drag & Drop Interface'),(16,'image','image','a:9:{s:2:\"id\";i:20;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(16,'link','link','a:15:{s:4:\"text\";s:12:\"Etiam rhoncu\";s:4:\"path\";s:18:\"/advanced-examples\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:5;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(16,'text','wysiwyg','<p>Content is created by simply dragging &amp; dropping blocks, that can&nbsp;be editited in-place and wysiwyg.&nbsp;</p>\n'),(17,'circle','checkbox',''),(17,'headline','input','HTML5 omnipresent'),(17,'image','image','a:9:{s:2:\"id\";i:18;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(17,'link','link','a:15:{s:4:\"text\";s:14:\"Quisque rutrum\";s:4:\"path\";s:12:\"/experiments\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:6;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(17,'text','wysiwyg','<p>Drag &amp; drop upload directly&nbsp;into the asset tree, automatic html5 video transcoding, and much more ...</p>\n'),(18,'content','areablock','a:2:{i:0;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:9:\"headlines\";}i:1;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:3:\"pdf\";}}'),(18,'headDescription','input',''),(18,'headline','input','Isn\'t that amazing?'),(18,'headlinecontent2','input',''),(18,'headTitle','input',''),(18,'leadcontent1','wysiwyg','<p>Just drop a PDF, doc(x), xls(x) or many other formats, et voilá ...&nbsp;</p>\n'),(18,'leadcontent2','wysiwyg','<p>Just drop a PDF, doc(x), xls(x) or many other formats, et voilá ...</p>\n'),(18,'pdfcontent1','pdf','a:4:{s:2:\"id\";i:36;s:8:\"hotspots\";a:0:{}s:5:\"texts\";a:0:{}s:8:\"chapters\";a:0:{}}'),(19,'caption-text-0content5','textarea','White beaches and the indian ocean'),(19,'caption-text-0content6','textarea',''),(19,'caption-text-1content5','textarea',''),(19,'caption-text-1content6','textarea',''),(19,'caption-text-2content5','textarea','National Nature Reserve'),(19,'caption-text-2content6','textarea',''),(19,'caption-text-3content5','textarea',''),(19,'caption-text-3content6','textarea',''),(19,'caption-text-4content5','textarea',''),(19,'caption-title-0content5','input','Plettenberg Bay'),(19,'caption-title-0content6','input',''),(19,'caption-title-1content5','input',''),(19,'caption-title-1content6','input',''),(19,'caption-title-2content5','input','The Robberg'),(19,'caption-title-2content6','input',''),(19,'caption-title-3content5','input',''),(19,'caption-title-3content6','input',''),(19,'caption-title-4content5','input',''),(19,'content','areablock','a:6:{i:0;a:2:{s:3:\"key\";s:1:\"5\";s:4:\"type\";s:16:\"gallery-carousel\";}i:1;a:2:{s:3:\"key\";s:1:\"6\";s:4:\"type\";s:16:\"gallery-carousel\";}i:2;a:2:{s:3:\"key\";s:1:\"3\";s:4:\"type\";s:9:\"headlines\";}i:3;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:14:\"gallery-folder\";}i:4;a:2:{s:3:\"key\";s:1:\"4\";s:4:\"type\";s:9:\"headlines\";}i:5;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:21:\"gallery-single-images\";}}'),(19,'gallerycontent1','renderlet','a:3:{s:2:\"id\";i:17;s:4:\"type\";s:5:\"asset\";s:7:\"subtype\";s:6:\"folder\";}'),(19,'gallerycontent2','block','a:7:{i:0;s:1:\"1\";i:1;s:1:\"2\";i:2;s:1:\"3\";i:3;s:1:\"4\";i:4;s:1:\"5\";i:5;s:1:\"6\";i:6;s:1:\"7\";}'),(19,'headDescription','input',''),(19,'headline','input','Creating custom galleries is very simple'),(19,'headlinecontent3','input','Autogenerated Gallery (using Renderlet)'),(19,'headlinecontent4','input','Custom assembled Gallery'),(19,'headTitle','input',''),(19,'imagecontent_gallerycontent22_1','image','a:9:{s:2:\"id\";i:48;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(19,'imagecontent_gallerycontent22_2','image','a:9:{s:2:\"id\";i:43;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(19,'imagecontent_gallerycontent22_3','image','a:9:{s:2:\"id\";i:50;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(19,'imagecontent_gallerycontent22_4','image','a:9:{s:2:\"id\";i:47;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(19,'imagecontent_gallerycontent22_5','image','a:9:{s:2:\"id\";i:46;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(19,'imagecontent_gallerycontent22_6','image','a:9:{s:2:\"id\";i:51;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(19,'imagecontent_gallerycontent22_7','image','a:9:{s:2:\"id\";i:52;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(19,'image_0content5','image','a:9:{s:2:\"id\";i:48;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(19,'image_0content6','image','a:9:{s:2:\"id\";i:39;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(19,'image_1content5','image','a:9:{s:2:\"id\";i:53;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(19,'image_1content6','image','a:9:{s:2:\"id\";i:38;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(19,'image_2content5','image','a:9:{s:2:\"id\";i:46;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(19,'image_2content6','image','a:9:{s:2:\"id\";i:41;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(19,'image_3content5','image','a:9:{s:2:\"id\";i:49;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(19,'image_3content6','image','a:9:{s:2:\"id\";i:40;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(19,'image_4content5','image','a:9:{s:2:\"id\";i:47;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(19,'leadcontent1','wysiwyg','<p>Drag an asset folder on the following drop area, and the \"renderlet\" will create automatically a gallery out of the images in the folder.</p>\n'),(19,'leadcontent2','wysiwyg',''),(19,'leadcontent3','wysiwyg','<p>Drag an asset folder on the following drop area, and the \"renderlet\" will create automatically a gallery out of the images in the folder.</p>\n'),(19,'leadcontent4','wysiwyg',''),(19,'showPreviewscontent5','checkbox','1'),(19,'showPreviewscontent6','checkbox',''),(19,'slidescontent5','select','5'),(19,'slidescontent6','select','4'),(20,'content','areablock','a:4:{i:0;a:2:{s:3:\"key\";s:1:\"3\";s:4:\"type\";s:9:\"headlines\";}i:1;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:7:\"wysiwyg\";}i:2;a:2:{s:3:\"key\";s:1:\"4\";s:4:\"type\";s:9:\"headlines\";}i:3;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:5:\"image\";}}'),(20,'contentcontent1','wysiwyg','<p>Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles.</p>\n\n<p>&nbsp;</p>\n\n<p>Ma quande lingues coalesce, li grammatica del resultant lingue es plu simplic e regulari quam ti del coalescent lingues. Li nov lingua franca va esser plu simplic e regulari quam li existent Europan lingues. It va esser tam simplic quam Occidental in fact, it va esser Occidental. A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.</p>\n\n<p>&nbsp;</p>\n\n<p>Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles.</p>\n'),(20,'headDescription','input',''),(20,'headline','input','The Glossary ...'),(20,'headlinecontent3','input',''),(20,'headlinecontent4','input',''),(20,'headTitle','input',''),(20,'imagecontent2','image','a:9:{s:2:\"id\";i:35;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(20,'leadcontent1','wysiwyg','<p>... makes it very simple to automatically link keywords, abbreviation and acronyms. This is not only perfect for SEO but also makes it super easy to navigate in the content.&nbsp;</p>\n'),(20,'leadcontent2','wysiwyg','<p>&nbsp;</p>\n\n<p>... this is how it looks in the admin interface.</p>\n'),(20,'leadcontent3','wysiwyg','<p>... makes it very simple to automatically link keywords, abbreviation and acronyms. This is not only perfect for SEO but also makes it super easy to navigate in the content.</p>\n'),(20,'leadcontent4','wysiwyg','<p>... this is how it looks in the admin interface.</p>\n'),(21,'content','areablock','a:2:{i:0;a:2:{s:3:\"key\";s:1:\"3\";s:4:\"type\";s:9:\"headlines\";}i:1;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:5:\"image\";}}'),(21,'contentcontent1','wysiwyg',''),(21,'content_bottom','areablock','a:1:{i:0;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:5:\"image\";}}'),(21,'headDescription','input',''),(21,'headline','input','Incredible Possibilities'),(21,'headlinecontent3','input','This is the original image'),(21,'headlinecontent_bottom1','input','This is how it looks in the admin interface ... '),(21,'headTitle','input',''),(21,'image','image','a:9:{s:2:\"id\";N;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(21,'imagecontent2','image','a:9:{s:2:\"id\";i:53;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(21,'imagecontent_bottom1','image','a:9:{s:2:\"id\";i:59;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(21,'img1','image','a:9:{s:2:\"id\";i:53;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(21,'img10','image','a:9:{s:2:\"id\";i:53;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(21,'img11','image','a:9:{s:2:\"id\";i:53;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(21,'img12','image','a:9:{s:2:\"id\";i:53;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(21,'img2','image','a:9:{s:2:\"id\";i:53;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(21,'img3','image','a:9:{s:2:\"id\";i:53;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(21,'img4','image','a:9:{s:2:\"id\";i:53;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(21,'img5','image','a:9:{s:2:\"id\";i:53;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(21,'img6','image','a:9:{s:2:\"id\";i:53;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(21,'img7','image','a:9:{s:2:\"id\";i:53;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(21,'img8','image','a:9:{s:2:\"id\";i:53;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(21,'img9','image','a:9:{s:2:\"id\";i:53;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(21,'leadcontent1','wysiwyg',''),(21,'leadcontent2','wysiwyg',''),(21,'leadcontent3','wysiwyg',''),(21,'leadcontent_bottom1','wysiwyg',''),(21,'multiselect','multiselect','a:0:{}'),(21,'myCheckbox','checkbox',''),(21,'myDate','date',NULL),(21,'myHref','href','a:3:{s:2:\"id\";N;s:4:\"type\";N;s:7:\"subtype\";N;}'),(21,'myImageBlock','block','a:0:{}'),(21,'myInput','input',''),(21,'myLink','link','a:10:{s:4:\"type\";s:8:\"internal\";s:4:\"path\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:6:\"target\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(21,'myMultihref','multihref','a:0:{}'),(21,'myNumber','numeric',''),(21,'mySelect','select',''),(21,'myTextarea','textarea',''),(21,'myWysiwyg','wysiwyg',''),(22,'content','areablock','a:2:{i:0;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:9:\"headlines\";}i:1;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:7:\"wysiwyg\";}}'),(22,'contentBottom','areablock','a:2:{i:0;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:9:\"headlines\";}i:1;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:5:\"image\";}}'),(22,'contentcontent1','wysiwyg','<p>&nbsp;</p>\n\n<p><a href=\"/de/einfache-beispiele/website-uebersetzungen\" pimcore_id=\"23\" pimcore_type=\"document\">Please visit this page to see the German translation of this page.</a></p>\n\n<p>&nbsp;</p>\n\n<p>Following some examples:&nbsp;</p>\n\n<p>&nbsp;</p>\n'),(22,'headDescription','input',''),(22,'headline','input','Website Translations'),(22,'headlinecontent2','input',''),(22,'headlinecontentBottom1','input',''),(22,'headlinecontentBottom2','input',''),(22,'headTitle','input',''),(22,'imagecontentBottom1','image','a:9:{s:2:\"id\";i:60;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(22,'leadcontent1','wysiwyg','<p>Common used terms across the website can be translated centrally, hassle-free and comfortable.&nbsp;</p>\n'),(22,'leadcontent2','wysiwyg','<p>Common used terms across the website can be translated centrally, hassle-free and comfortable.</p>\n'),(22,'leadcontentBottom1','wysiwyg','<p>&nbsp;</p>\n\n<p>&nbsp;</p>\n\n<p>This is how it looks in the admin interface ...&nbsp;</p>\n'),(22,'leadcontentBottom2','wysiwyg','<p>This is how it looks in the admin interface ...</p>\n'),(22,'multiselect','multiselect','a:0:{}'),(22,'myCheckbox','checkbox',''),(22,'myDate','date',NULL),(22,'myHref','href','a:3:{s:2:\"id\";N;s:4:\"type\";N;s:7:\"subtype\";N;}'),(22,'myImageBlock','block','a:0:{}'),(22,'myInput','input',''),(22,'myLink','link','a:10:{s:4:\"type\";s:8:\"internal\";s:4:\"path\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:6:\"target\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(22,'myMultihref','multihref','a:0:{}'),(22,'myNumber','numeric',''),(22,'mySelect','select',''),(22,'myTextarea','textarea',''),(22,'myWysiwyg','wysiwyg',''),(23,'content','areablock','a:1:{i:0;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:7:\"wysiwyg\";}}'),(23,'contentBottom','areablock','a:0:{}'),(23,'contentcontent1','wysiwyg','<p>Folgend ein paar Beispiele:&nbsp;</p>\n'),(23,'headDescription','input',''),(23,'headline','input','Website Übersetzungen'),(23,'headTitle','input',''),(23,'leadcontent1','wysiwyg','<p>Häufig genutzte Begriffe auf der gesamten Website können komfortabel, zentral und einfach übersetzt werden.</p>\n'),(23,'multiselect','multiselect','a:0:{}'),(23,'myCheckbox','checkbox',''),(23,'myDate','date',''),(23,'myHref','href','a:3:{s:2:\"id\";N;s:4:\"type\";N;s:7:\"subtype\";N;}'),(23,'myImageBlock','block','a:0:{}'),(23,'myInput','input',''),(23,'myLink','link','a:10:{s:4:\"type\";s:8:\"internal\";s:4:\"path\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:6:\"target\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(23,'myMultihref','multihref','a:0:{}'),(23,'myNumber','numeric',''),(23,'mySelect','select',''),(23,'myTextarea','textarea',''),(23,'myWysiwyg','wysiwyg',''),(24,'accordioncontent7','block','a:4:{i:0;s:1:\"1\";i:1;s:1:\"2\";i:2;s:1:\"3\";i:3;s:1:\"4\";}'),(24,'authorcontent5','input','Albert Einstein'),(24,'blockcontent1','block','a:2:{i:0;s:1:\"1\";i:1;s:1:\"2\";}'),(24,'content','areablock','a:11:{i:0;a:2:{s:3:\"key\";s:1:\"6\";s:4:\"type\";s:9:\"headlines\";}i:1;a:2:{s:3:\"key\";s:2:\"11\";s:4:\"type\";s:19:\"wysiwyg-with-images\";}i:2;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:21:\"gallery-single-images\";}i:3;a:2:{s:3:\"key\";s:1:\"3\";s:4:\"type\";s:7:\"wysiwyg\";}i:4;a:2:{s:3:\"key\";s:1:\"5\";s:4:\"type\";s:10:\"blockquote\";}i:5;a:2:{s:3:\"key\";s:1:\"9\";s:4:\"type\";s:15:\"horizontal-line\";}i:6;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:10:\"featurette\";}i:7;a:2:{s:3:\"key\";s:1:\"8\";s:4:\"type\";s:15:\"horizontal-line\";}i:8;a:2:{s:3:\"key\";s:1:\"4\";s:4:\"type\";s:5:\"image\";}i:9;a:2:{s:3:\"key\";s:1:\"7\";s:4:\"type\";s:14:\"text-accordion\";}i:10;a:2:{s:3:\"key\";s:2:\"10\";s:4:\"type\";s:15:\"icon-teaser-row\";}}'),(24,'contentcontent11','wysiwyg','<p>Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca:</p>\n\n<p>&nbsp;</p>\n\n<p>On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles. Ma quande lingues coalesce, li grammatica del resultant lingue es plu simplic e regulari quam ti del coalescent lingues. Li nov lingua franca va esser plu simplic e regulari quam li existent Europan lingues. It va esser tam simplic quam Occidental in fact, it va esser Occidental.</p>\n\n<p>&nbsp;</p>\n\n<p>A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles.</p>\n'),(24,'contentcontent3','wysiwyg','<p>Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim.</p>\n\n<p>&nbsp;</p>\n\n<ul>\n	<li>Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus.</li>\n	<li>Phasellus viverra nulla ut metus varius laoreet.</li>\n	<li>Quisque rutrum. Aenean imperdiet.</li>\n</ul>\n\n<p>&nbsp;</p>\n\n<p>Etiam ultricies nisi vel augue. Curabitur <a href=\"/basic-examples/galleries\">ullamcorper </a>ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus.</p>\n'),(24,'contentcontent_blockcontent11_1','wysiwyg','<p>Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.</p>\n'),(24,'contentcontent_blockcontent11_2','wysiwyg','<p>Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna.</p>\n'),(24,'gallerycontent2','block','a:4:{i:0;s:1:\"1\";i:1;s:1:\"2\";i:2;s:1:\"3\";i:3;s:1:\"4\";}'),(24,'headDescription','input',''),(24,'headline','input','This is just a simple Content-Page ...'),(24,'headlinecontent6','input','Where some Content-Blocks are mixed together.'),(24,'headlinecontent_accordioncontent77_1','input','Lorem ipsum dolor sit amet'),(24,'headlinecontent_accordioncontent77_2','input',' Cum sociis natoque penatibus et magnis dis parturient montes'),(24,'headlinecontent_accordioncontent77_3','input','Donec pede justo, fringilla vel'),(24,'headlinecontent_accordioncontent77_4','input','Maecenas tempus, tellus eget condimentum rhoncus'),(24,'headlinecontent_blockcontent11_1','input','Lorem ipsum.'),(24,'headlinecontent_blockcontent11_2','input','Etiam ultricies.'),(24,'headTitle','input',''),(24,'icon_0content10','select','thumbs-up'),(24,'icon_1content10','select','qrcode'),(24,'icon_2content10','select','trash'),(24,'imagecontent4','image','a:9:{s:2:\"id\";i:53;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(24,'imagecontent_blockcontent11_1','image','a:9:{s:2:\"id\";i:48;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(24,'imagecontent_gallerycontent22_1','image','a:9:{s:2:\"id\";i:51;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(24,'imagecontent_gallerycontent22_2','image','a:9:{s:2:\"id\";i:52;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(24,'imagecontent_gallerycontent22_3','image','a:9:{s:2:\"id\";i:44;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(24,'imagecontent_gallerycontent22_4','image','a:9:{s:2:\"id\";i:49;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(24,'imagecontent_imagescontent1111_1','image','a:9:{s:2:\"id\";i:22;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(24,'imagecontent_imagescontent1111_2','image','a:9:{s:2:\"id\";i:24;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(24,'imagescontent11','block','a:2:{i:0;s:1:\"1\";i:1;s:1:\"2\";}'),(24,'leadcontent2','wysiwyg','<p>African Animals</p>\n'),(24,'leadcontent3','wysiwyg','<p>Donec pede justo, fringilla vel, aliquet nec</p>\n'),(24,'leadcontent4','wysiwyg',''),(24,'leadcontent6','wysiwyg',''),(24,'link_0content10','link','a:15:{s:4:\"text\";s:13:\"See in Action\";s:4:\"path\";s:30:\"/en/basic-examples/html5-video\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:7;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(24,'link_1content10','link','a:15:{s:4:\"text\";s:9:\"Read More\";s:4:\"path\";s:29:\"/en/basic-examples/thumbnails\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:21;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(24,'link_2content10','link','a:15:{s:4:\"text\";s:10:\"Try it now\";s:4:\"path\";s:23:\"/en/basic-examples/news\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:27;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(24,'postitioncontent_blockcontent11_1','select',''),(24,'postitioncontent_blockcontent11_2','select','left'),(24,'quotecontent5','input','We can\'t solve problems by using the same kind of thinking we used when we created them.'),(24,'sublinecontent_blockcontent11_1','input','Dolor sit amet.'),(24,'sublinecontent_blockcontent11_2','input','Nam eget dui.'),(24,'textcontent_accordioncontent77_1','wysiwyg','<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean <a href=\"/en/basic-examples/thumbnails\" pimcore_id=\"21\" pimcore_type=\"document\">commodo </a>ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim.</p>\n\n<p>&nbsp;</p>\n\n<p>Donec pede justo, fringilla vel, aliquet nec, <strong>vulputate </strong>eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus <a href=\"/en/basic-examples/form\" pimcore_id=\"26\" pimcore_type=\"document\">elementum </a>semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet.</p>\n\n<p>&nbsp;</p>\n\n<p>Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget <u>condimentum </u>rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc,</p>\n'),(24,'textcontent_accordioncontent77_2','wysiwyg','<p>Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca:</p>\n\n<p>&nbsp;</p>\n\n<p>On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles. Ma quande lingues coalesce, li grammatica del resultant lingue es plu simplic e regulari quam ti del coalescent lingues. Li nov lingua franca va esser plu simplic e regulari quam li existent Europan lingues. It va esser tam simplic quam Occidental in fact, it va esser Occidental.</p>\n\n<p>&nbsp;</p>\n\n<p>A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles.</p>\n'),(24,'textcontent_accordioncontent77_3','wysiwyg','<p>Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum.</p>\n'),(24,'textcontent_accordioncontent77_4','wysiwyg','<p>It va esser tam simplic quam Occidental in fact, it va esser Occidental. A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.Li Europan lingues es membres del sam familie. Lor separat existentie es un myth.</p>\n\n<p>&nbsp;</p>\n\n<p>Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles.</p>\n'),(24,'text_0content10','textarea','At solmen va esser necessi far uniform grammatica.'),(24,'text_1content10','textarea',' Curabitur ullamcorper ultricies nisi. Nam eget dui.'),(24,'text_2content10','textarea','On refusa continuar payar custosi traductores.'),(24,'title_0content10','input','Social Media Integration'),(24,'title_1content10','input','QR-Code Management'),(24,'title_2content10','input','Recycle Bin'),(24,'typecontent_blockcontent11_1','select',''),(24,'typecontent_blockcontent11_2','select','video'),(24,'videocontent_blockcontent11_2','video','a:5:{s:2:\"id\";i:27;s:4:\"type\";s:5:\"asset\";s:5:\"title\";s:0:\"\";s:11:\"description\";s:0:\"\";s:6:\"poster\";i:49;}'),(25,'content','areablock','a:1:{i:0;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:9:\"headlines\";}}'),(25,'contentcontent1','wysiwyg',''),(25,'headDescription','input',''),(25,'headline','input','This is an overview of all available \"editables\" (except area/areablock/block)'),(25,'headlinecontent2','input','Please view this page in the editmode (admin interface)!'),(25,'headTitle','input',''),(25,'leadcontent1','wysiwyg','<p>... nothing to see here ;-)&nbsp;</p>\n'),(25,'leadcontent2','wysiwyg','<p>... nothing to see here ;-)</p>\n'),(25,'multiselect','multiselect','a:0:{}'),(25,'myCheckbox','checkbox','1'),(25,'myDate','date','1368662400'),(25,'myHref','href','a:3:{s:2:\"id\";i:21;s:4:\"type\";s:8:\"document\";s:7:\"subtype\";s:4:\"page\";}'),(25,'myImage','image','a:9:{s:2:\"id\";i:47;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(25,'myImageBlock','block','a:0:{}'),(25,'myInput','input','Some Text'),(25,'myLink','link','a:15:{s:4:\"text\";s:7:\"My Link\";s:4:\"path\";s:25:\"/basic-examples/galleries\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:19;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(25,'myMultiHref','multihref','a:6:{i:0;a:4:{s:2:\"id\";i:20;s:4:\"path\";s:27:\"/en/basic-examples/glossary\";s:4:\"type\";s:8:\"document\";s:7:\"subtype\";s:4:\"page\";}i:1;a:4:{s:2:\"id\";i:21;s:4:\"path\";s:29:\"/en/basic-examples/thumbnails\";s:4:\"type\";s:8:\"document\";s:7:\"subtype\";s:4:\"page\";}i:2;a:4:{s:2:\"id\";i:25;s:4:\"path\";s:35:\"/en/basic-examples/editable-roundup\";s:4:\"type\";s:8:\"document\";s:7:\"subtype\";s:4:\"page\";}i:3;a:4:{s:2:\"id\";i:51;s:4:\"path\";s:35:\"/examples/south-africa/img_1842.jpg\";s:4:\"type\";s:5:\"asset\";s:7:\"subtype\";s:5:\"image\";}i:4;a:4:{s:2:\"id\";i:44;s:4:\"path\";s:35:\"/examples/south-africa/img_2133.jpg\";s:4:\"type\";s:5:\"asset\";s:7:\"subtype\";s:5:\"image\";}i:5;a:4:{s:2:\"id\";i:45;s:4:\"path\";s:35:\"/examples/south-africa/img_2240.jpg\";s:4:\"type\";s:5:\"asset\";s:7:\"subtype\";s:5:\"image\";}}'),(25,'myMultiselect','multiselect','a:2:{i:0;s:6:\"value2\";i:1;s:6:\"value4\";}'),(25,'myNumber','numeric',''),(25,'myNumeric','numeric','123'),(25,'myRenderlet','renderlet','a:3:{s:2:\"id\";i:54;s:4:\"type\";s:5:\"asset\";s:7:\"subtype\";s:6:\"folder\";}'),(25,'mySelect','select','option2'),(25,'mySnippet','snippet','15'),(25,'myTextarea','textarea','Some Text'),(25,'myVideo','video','a:5:{s:2:\"id\";i:27;s:4:\"type\";s:5:\"asset\";s:5:\"title\";s:0:\"\";s:11:\"description\";s:0:\"\";s:6:\"poster\";N;}'),(25,'myWysiwyg','wysiwyg','<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt.</p>\n\n<p>&nbsp;</p>\n\n<p>Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui.</p>\n\n<p>&nbsp;</p>\n\n<p>Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc,</p>\n'),(25,'tableName','table','a:2:{i:0;a:3:{i:0;s:7:\"Value 1\";i:1;s:7:\"Value 2\";i:2;s:7:\"Value 3\";}i:1;a:3:{i:0;s:4:\"this\";i:1;s:2:\"is\";i:2;s:4:\"test\";}}'),(26,'content','areablock','a:0:{}'),(26,'headDescription','input',''),(26,'headline','input','Just a simple form'),(26,'headTitle','input',''),(26,'multiselect','multiselect','a:0:{}'),(26,'myCheckbox','checkbox',''),(26,'myDate','date',''),(26,'myHref','href','a:3:{s:2:\"id\";N;s:4:\"type\";N;s:7:\"subtype\";N;}'),(26,'myImageBlock','block','a:0:{}'),(26,'myInput','input',''),(26,'myLink','link','a:10:{s:4:\"type\";s:8:\"internal\";s:4:\"path\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:6:\"target\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(26,'myMultihref','multihref','a:0:{}'),(26,'myNumber','numeric',''),(26,'mySelect','select',''),(26,'myTextarea','textarea',''),(26,'myWysiwyg','wysiwyg',''),(27,'content','areablock','a:1:{i:0;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:9:\"headlines\";}}'),(27,'contentcontent1','wysiwyg',''),(27,'headDescription','input',''),(27,'headline','input','News'),(27,'headlinecontent2','input',''),(27,'headTitle','input',''),(27,'leadcontent1','wysiwyg','<p>Any kind of structured data is stored in \"Objects\".&nbsp;</p>\n'),(27,'leadcontent2','wysiwyg','<p>Any kind of structured data is stored in \"Objects\".</p>\n'),(27,'multiselect','multiselect','a:0:{}'),(27,'myCheckbox','checkbox',''),(27,'myDate','date',NULL),(27,'myHref','href','a:3:{s:2:\"id\";N;s:4:\"type\";N;s:7:\"subtype\";N;}'),(27,'myImageBlock','block','a:0:{}'),(27,'myInput','input',''),(27,'myLink','link','a:10:{s:4:\"type\";s:8:\"internal\";s:4:\"path\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:6:\"target\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(27,'myMultihref','multihref','a:0:{}'),(27,'myNumber','numeric',''),(27,'mySelect','select',''),(27,'myTextarea','textarea',''),(27,'myWysiwyg','wysiwyg',''),(28,'content','areablock','a:4:{i:0;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:7:\"wysiwyg\";}i:1;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:5:\"image\";}i:2;a:2:{s:3:\"key\";s:1:\"3\";s:4:\"type\";s:5:\"image\";}i:3;a:2:{s:3:\"key\";s:1:\"4\";s:4:\"type\";s:5:\"image\";}}'),(28,'contentcontent1','wysiwyg','<p>On this page we use \"Properties\" to hide the navigation on the left and to change the color of the header to blue.&nbsp;</p>\n\n<p>Properties are very useful to control the behavior or to store meta data of documents, assets and objects. And the best: they are inheritable.&nbsp;</p>\n\n<p>&nbsp;</p>\n\n<p>On the following screens you can see how this is done in this example.</p>\n'),(28,'headDescription','input',''),(28,'headline','input','Properties'),(28,'headTitle','input',''),(28,'imagecontent2','image','a:9:{s:2:\"id\";i:61;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(28,'imagecontent3','image','a:9:{s:2:\"id\";i:62;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(28,'imagecontent4','image','a:9:{s:2:\"id\";i:63;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(28,'leadcontent1','wysiwyg',''),(28,'leadcontent2','wysiwyg',''),(28,'leadcontent3','wysiwyg',''),(28,'leadcontent4','wysiwyg',''),(29,'content','areablock','a:3:{i:0;a:2:{s:3:\"key\";s:1:\"3\";s:4:\"type\";s:9:\"headlines\";}i:1;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:7:\"wysiwyg\";}i:2;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:5:\"image\";}}'),(29,'contentcontent1','wysiwyg','<p>This page demonstrates how to use the \"Tag &amp; Snippet Management\" to inject codes into the HTML source code. This functionality can be used to easily integrate tracking codes, conversion codes, social plugins and whatever that needs to go into the HTML.</p>\n\n<p>&nbsp;</p>\n\n<p>The functionality is similar to this products:&nbsp;</p>\n\n<p><a href=\"http://www.google.com/tagmanager/\">http://www.google.com/tagmanager/</a>&nbsp;</p>\n\n<p><a href=\"http://www.searchdiscovery.com/satellite/\">http://www.searchdiscovery.com/satellite/&nbsp;</a></p>\n\n<p><a href=\"http://www.tagcommander.com/en/\">http://www.tagcommander.com/en/</a></p>\n\n<p>&nbsp;</p>\n\n<p>In our example we use it to integrate a facebook social plugin.</p>\n'),(29,'headDescription','input',''),(29,'headline','input','Tag & Snippet Management'),(29,'headlinecontent3','input','... gives all the freedom back to the marketing dept.'),(29,'headTitle','input',''),(29,'imagecontent2','image','a:9:{s:2:\"id\";i:64;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(29,'leadcontent1','wysiwyg',''),(29,'leadcontent2','wysiwyg',''),(29,'leadcontent3','wysiwyg',''),(30,'content','areablock','a:5:{i:0;a:2:{s:3:\"key\";s:1:\"4\";s:4:\"type\";s:9:\"headlines\";}i:1;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:7:\"wysiwyg\";}i:2;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:5:\"image\";}i:3;a:2:{s:3:\"key\";s:1:\"5\";s:4:\"type\";s:9:\"headlines\";}i:4;a:2:{s:3:\"key\";s:1:\"3\";s:4:\"type\";s:7:\"wysiwyg\";}}'),(30,'contentcontent1','wysiwyg','<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet.&nbsp;</p>\n'),(30,'contentcontent3','wysiwyg','<p>Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc,</p>\n'),(30,'headDescription','input',''),(30,'headline','input','Content Inheritance'),(30,'headlinecontent4','input','First Headline'),(30,'headlinecontent5','input','Second Headline'),(30,'headTitle','input',''),(30,'imagecontent2','image','a:9:{s:2:\"id\";i:53;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(30,'leadcontent1','wysiwyg','<p>This is the Master Document</p>\n'),(30,'leadcontent2','wysiwyg',''),(30,'leadcontent3','wysiwyg',''),(30,'leadcontent4','wysiwyg','<p>This is the Master Document</p>\n'),(30,'leadcontent5','wysiwyg',''),(31,'content','areablock','a:5:{i:0;a:2:{s:3:\"key\";s:1:\"5\";s:4:\"type\";s:9:\"headlines\";}i:1;a:2:{s:3:\"key\";s:1:\"3\";s:4:\"type\";s:7:\"wysiwyg\";}i:2;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:5:\"image\";}i:3;a:2:{s:3:\"key\";s:1:\"4\";s:4:\"type\";s:9:\"headlines\";}i:4;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:7:\"wysiwyg\";}}'),(31,'leadcontent4','wysiwyg','<p>This is the Slave Document</p>\n'),(31,'leadcontent5','wysiwyg','<p>This is the Slave Document</p>\n'),(34,'content','areablock','a:1:{i:0;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:7:\"wysiwyg\";}}'),(34,'contentcontent1','wysiwyg','<p>This page has a hardlink as child (see navigation on the left).&nbsp;</p>\n\n<p>This hardlink points to \"<a href=\"/basic-examples\">Basic Examples</a>\", so the whole content of /basic-examples is available in /advaned-examples/hardlink/basic-examples.&nbsp;</p>\n\n<p>&nbsp;</p>\n\n<p>Want to know more about hardlinks?&nbsp;</p>\n\n<ul>\n	<li><a href=\"http://en.wikipedia.org/wiki/Hard_link\">http://en.wikipedia.org/wiki/Hard_link</a></li>\n	<li>see also:&nbsp;<a href=\"http://en.wikipedia.org/wiki/Symbolic_link\">http://en.wikipedia.org/wiki/Symbolic_link</a>&nbsp;</li>\n</ul>\n\n<p>&nbsp;</p>\n'),(34,'headDescription','input',''),(34,'headline','input','Hard Link Example'),(34,'headTitle','input',''),(34,'leadcontent1','wysiwyg',''),(35,'content','areablock','a:2:{i:0;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:20:\"image-hotspot-marker\";}i:1;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:20:\"image-hotspot-marker\";}}'),(35,'headDescription','input',''),(35,'headline','input','Image with Hotspots & Markers'),(35,'headTitle','input',''),(35,'imagecontent1','image','a:9:{s:2:\"id\";i:53;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:4:{i:0;a:3:{s:3:\"top\";d:35.220125786163521;s:4:\"left\";d:82.098765432098759;s:4:\"data\";a:1:{i:0;a:3:{s:4:\"name\";s:5:\"title\";s:5:\"value\";s:27:\"Table Mountain Peak Station\";s:4:\"type\";s:9:\"textfield\";}}}i:1;a:3:{s:3:\"top\";d:67.924528301886795;s:4:\"left\";d:9.0534979423868318;s:4:\"data\";a:1:{i:0;a:3:{s:4:\"name\";s:5:\"title\";s:5:\"value\";s:16:\"Victoria Harbour\";s:4:\"type\";s:9:\"textfield\";}}}i:2;a:3:{s:3:\"top\";d:57.232704402515722;s:4:\"left\";d:45.267489711934154;s:4:\"data\";a:1:{i:0;a:3:{s:4:\"name\";s:5:\"title\";s:5:\"value\";s:12:\"District Six\";s:4:\"type\";s:9:\"textfield\";}}}i:3;a:3:{s:3:\"top\";d:45.911949685534594;s:4:\"left\";d:98.971193415637856;s:4:\"data\";a:1:{i:0;a:3:{s:4:\"name\";s:5:\"title\";s:5:\"value\";s:11:\"Lion\'s Head\";s:4:\"type\";s:9:\"textfield\";}}}}}'),(35,'imagecontent2','image','a:9:{s:2:\"id\";i:51;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:3:{i:0;a:5:{s:3:\"top\";d:0.54794520547945003;s:4:\"left\";d:20.370370370370001;s:5:\"width\";d:22.016460905350002;s:6:\"height\";d:21.917808219177999;s:4:\"data\";a:1:{i:0;a:3:{s:4:\"name\";s:5:\"title\";s:5:\"value\";s:3:\"Ear\";s:4:\"type\";s:9:\"textfield\";}}}i:1;a:5:{s:3:\"top\";d:59.178082191781002;s:4:\"left\";d:8.8477366255144005;s:5:\"width\";d:33.127572016461002;s:6:\"height\";d:40.273972602740002;s:4:\"data\";a:1:{i:0;a:3:{s:4:\"name\";s:5:\"title\";s:5:\"value\";s:5:\"Claws\";s:4:\"type\";s:9:\"textfield\";}}}i:2;a:5:{s:3:\"top\";d:25.205479452054998;s:4:\"left\";d:11.934156378600999;s:5:\"width\";d:16.460905349794;s:6:\"height\";d:18.356164383562;s:4:\"data\";a:1:{i:0;a:3:{s:4:\"name\";s:5:\"title\";s:5:\"value\";s:3:\"Eye\";s:4:\"type\";s:9:\"textfield\";}}}}s:6:\"marker\";a:0:{}}'),(36,'content','areablock','a:1:{i:0;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:7:\"wysiwyg\";}}'),(36,'contentcontent1','wysiwyg','<p>The search is using the contents from&nbsp;pimcore.org.&nbsp;<strong>TIP</strong>: Search for \"web\".</p>\n'),(36,'headDescription','input',''),(36,'headline','input','Search'),(36,'headTitle','input',''),(36,'leadcontent1','wysiwyg',''),(36,'multiselect','multiselect','a:0:{}'),(36,'myCheckbox','checkbox',''),(36,'myDate','date',''),(36,'myHref','href','a:3:{s:2:\"id\";N;s:4:\"type\";N;s:7:\"subtype\";N;}'),(36,'myImageBlock','block','a:0:{}'),(36,'myInput','input',''),(36,'myLink','link','a:10:{s:4:\"type\";s:8:\"internal\";s:4:\"path\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:6:\"target\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(36,'myMultihref','multihref','a:0:{}'),(36,'myNumber','numeric',''),(36,'mySelect','select',''),(36,'myTextarea','textarea',''),(36,'myWysiwyg','wysiwyg',''),(37,'content','areablock','a:0:{}'),(37,'headDescription','input',''),(37,'headline','input','Contact Form'),(37,'headTitle','input',''),(37,'multiselect','multiselect','a:0:{}'),(37,'myCheckbox','checkbox',''),(37,'myDate','date',''),(37,'myHref','href','a:3:{s:2:\"id\";N;s:4:\"type\";N;s:7:\"subtype\";N;}'),(37,'myImageBlock','block','a:0:{}'),(37,'myInput','input',''),(37,'myLink','link','a:10:{s:4:\"type\";s:8:\"internal\";s:4:\"path\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:6:\"target\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(37,'myMultihref','multihref','a:0:{}'),(37,'myNumber','numeric',''),(37,'mySelect','select',''),(37,'myTextarea','textarea',''),(37,'myWysiwyg','wysiwyg',''),(38,'content','wysiwyg','<p><strong>Gender</strong>: %Text(gender);&nbsp;</p>\n\n<p><strong>Firstname</strong>: %Text(firstname);<br />\n<strong>Lastname</strong>: %Text(lastname);<br />\n<strong>E-Mail</strong>: %Text(email);&nbsp;</p>\n\n<p>&nbsp;</p>\n\n<p><strong>Message</strong>:<br />\n%Text(message);&nbsp;</p>\n\n<p>&nbsp;</p>\n'),(38,'headline','input','You\'ve got a new E-Mail!'),(38,'multiselect','multiselect','a:0:{}'),(38,'myCheckbox','checkbox',''),(38,'myDate','date',''),(38,'myHref','href','a:3:{s:2:\"id\";N;s:4:\"type\";N;s:7:\"subtype\";N;}'),(38,'myImageBlock','block','a:0:{}'),(38,'myInput','input',''),(38,'myLink','link','a:10:{s:4:\"type\";s:8:\"internal\";s:4:\"path\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:6:\"target\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(38,'myMultihref','multihref','a:0:{}'),(38,'myNumber','numeric',''),(38,'mySelect','select',''),(38,'myTextarea','textarea',''),(38,'myWysiwyg','wysiwyg',''),(39,'content','areablock','a:1:{i:0;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:7:\"wysiwyg\";}}'),(39,'contentcontent1','wysiwyg','<div id=\"idTextPanel\">\n<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt.</p>\n\n<p>&nbsp;</p>\n\n<p>Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus.</p>\n\n<p>&nbsp;</p>\n\n<p>Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc,</p>\n\n<div>&nbsp;</div>\n</div>\n'),(39,'headDescription','input',''),(39,'headline','input','It seems that the page you were trying to find isn\'t around anymore. '),(39,'headTitle','input','Oh no!'),(39,'leadcontent1','wysiwyg',''),(41,'authorcontent3','input','Albert Einstein'),(41,'blockcontent1','block','a:1:{i:0;s:1:\"1\";}'),(41,'carouselSlides','select','3'),(41,'cHeadline_0','input','Bereit beeindruckt zu werden? '),(41,'cHeadline_1','input','Es wird dich umhauen!'),(41,'cHeadline_2','input','Oh ja, es ist wirklich so gut'),(41,'cImage_0','image','a:9:{s:2:\"id\";i:4;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(41,'cImage_1','image','a:9:{s:2:\"id\";i:5;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(41,'cImage_2','image','a:9:{s:2:\"id\";i:6;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(41,'cLink_0','link','a:15:{s:4:\"text\";s:16:\"See it in Action\";s:4:\"path\";s:18:\"/advanced-examples\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:5;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(41,'cLink_1','link','a:15:{s:4:\"text\";s:16:\"See it in Action\";s:4:\"path\";s:18:\"/advanced-examples\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:5;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(41,'cLink_2','link','a:15:{s:4:\"text\";s:9:\"Checkmate\";s:4:\"path\";s:12:\"/experiments\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:6;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(41,'content','areablock','a:2:{i:0;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:19:\"standard-teaser-row\";}i:1;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:10:\"featurette\";}}'),(41,'contentcontent_blockcontent11_1','wysiwyg','<p>In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi.</p>\n'),(41,'contentcontent_blockcontent11_2','wysiwyg','<p>Donec ullamcorper nulla non metus auctor fringilla. Vestibulum id ligula porta felis euismod semper. Praesent commodo cursus magna, vel scelerisque nisl consectetur. Fusce dapibus, tellus ac cursus commodo.</p>\n'),(41,'contentcontent_blockcontent11_3','wysiwyg','<p>Donec ullamcorper nulla non metus auctor fringilla. Vestibulum id ligula porta felis euismod semper. Praesent commodo cursus magna, vel scelerisque nisl consectetur. Fusce dapibus, tellus ac cursus commodo.</p>\n'),(41,'cText_0','textarea','Teste unsere Beispiele und tauche ein in die nächste Generation von digitalem Inhaltsmanagement'),(41,'cText_1','textarea','Sieh\' selbst'),(41,'cText_2','textarea','Sieh\' selbst!'),(41,'headlinecontent_blockcontent11_1','input','Lorem ipsum.'),(41,'headlinecontent_blockcontent11_2','input','Oh yeah, it\'s that good.'),(41,'headlinecontent_blockcontent11_3','input','And lastly, this one.'),(41,'imagecontent_blockcontent11_1','image','a:9:{s:2:\"id\";i:55;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(41,'imagecontent_blockcontent11_2','image','a:9:{s:2:\"id\";i:18;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(41,'imagecontent_blockcontent11_3','image','a:9:{s:2:\"id\";i:19;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(41,'imagePositioncontent_blockcontent11_1','select',''),(41,'imagePositioncontent_blockcontent11_2','select','left'),(41,'imagePositioncontent_blockcontent11_3','select',''),(41,'multiselect','multiselect','a:0:{}'),(41,'myCheckbox','checkbox',''),(41,'myDate','date',''),(41,'myHref','href','a:3:{s:2:\"id\";N;s:4:\"type\";N;s:7:\"subtype\";N;}'),(41,'myImageBlock','block','a:0:{}'),(41,'myInput','input',''),(41,'myLink','link','a:10:{s:4:\"type\";s:8:\"internal\";s:4:\"path\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:6:\"target\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(41,'myMultihref','multihref','a:0:{}'),(41,'myNumber','numeric',''),(41,'mySelect','select',''),(41,'myTextarea','textarea',''),(41,'myWysiwyg','wysiwyg',''),(41,'postitioncontent_blockcontent11_1','select',''),(41,'postitioncontent_blockcontent11_2','select','left'),(41,'postitioncontent_blockcontent11_3','select',''),(41,'quotecontent3','input','We can\'t solve problems by using the same kind of thinking we used when we created them.'),(41,'sublinecontent_blockcontent11_1','input','Cum sociis.'),(41,'sublinecontent_blockcontent11_2','input','See for yourself.'),(41,'sublinecontent_blockcontent11_3','input','Checkmate.'),(41,'teaser_0content2','snippet','47'),(41,'teaser_1content2','snippet','48'),(41,'teaser_2content2','snippet','49'),(41,'typecontent_blockcontent11_1','select',''),(41,'typecontent_blockcontent11_2','select','video'),(41,'typecontent_blockcontent11_3','select',''),(41,'type_0content2','select',''),(41,'type_1content2','select',''),(41,'type_2content2','select',''),(41,'videocontent_blockcontent11_2','video','a:5:{s:2:\"id\";i:27;s:4:\"type\";s:5:\"asset\";s:5:\"title\";s:0:\"\";s:11:\"description\";s:0:\"\";s:6:\"poster\";N;}'),(46,'linklinks1','link','a:12:{s:4:\"text\";s:11:\"pimcore.org\";s:4:\"path\";s:23:\"http://www.pimcore.org/\";s:6:\"target\";s:6:\"_blank\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:4:\"type\";s:8:\"internal\";}'),(46,'linklinks2','link','a:11:{s:4:\"text\";s:13:\"Dokumentation\";s:4:\"path\";s:28:\"http://www.pimcore.org/wiki/\";s:6:\"target\";s:6:\"_blank\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(46,'linklinks3','link','a:12:{s:4:\"text\";s:11:\"Bug Tracker\";s:4:\"path\";s:30:\"http://www.pimcore.org/issues/\";s:6:\"target\";s:6:\"_blank\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:4:\"type\";s:8:\"internal\";}'),(46,'links','block','a:3:{i:0;s:1:\"1\";i:1;s:1:\"2\";i:2;s:1:\"3\";}'),(46,'multiselect','multiselect','a:0:{}'),(46,'myCheckbox','checkbox',''),(46,'myDate','date',''),(46,'myHref','href','a:3:{s:2:\"id\";N;s:4:\"type\";N;s:7:\"subtype\";N;}'),(46,'myImageBlock','block','a:0:{}'),(46,'myInput','input',''),(46,'myLink','link','a:10:{s:4:\"type\";s:8:\"internal\";s:4:\"path\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:6:\"target\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(46,'myMultihref','multihref','a:0:{}'),(46,'myNumber','numeric',''),(46,'mySelect','select',''),(46,'myTextarea','textarea',''),(46,'myWysiwyg','wysiwyg',''),(46,'text','wysiwyg','<p>Designed and built with all the love in the world by&nbsp;<a href=\"http://twitter.com/mdo\" target=\"_blank\">@mdo</a>&nbsp;and&nbsp;<a href=\"http://twitter.com/fat\" target=\"_blank\">@fat</a>.</p>\n\n<p>Code licensed under&nbsp;<a href=\"http://www.apache.org/licenses/LICENSE-2.0\" target=\"_blank\">Apache License v2.0</a>,&nbsp;<a href=\"http://glyphicons.com/\">Glyphicons Free</a>&nbsp;licensed under&nbsp;<a href=\"http://creativecommons.org/licenses/by/3.0/\">CC BY 3.0</a>.</p>\n\n<p><strong>© Templates pimcore.org licensed under BSD License</strong></p>\n'),(47,'circle','checkbox',''),(47,'headline','input','Voll Responsive'),(47,'image','image','a:9:{s:2:\"id\";i:21;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(47,'link','link','a:15:{s:4:\"text\";s:11:\"Lorem ipsum\";s:4:\"path\";s:18:\"/en/basic-examples\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:3;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(47,'text','wysiwyg','<p>Diese Demo basiert auf Bootstrap, dem wohl bekanntesten,&nbsp;beliebtesten und flexibelsten Fontend-Framework.</p>\n'),(48,'circle','checkbox',''),(48,'headline','input','Drag & Drop Inhaltserstellung'),(48,'image','image','a:9:{s:2:\"id\";i:20;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(48,'link','link','a:15:{s:4:\"text\";s:12:\"Etiam rhoncu\";s:4:\"path\";s:21:\"/en/advanced-examples\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:5;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(48,'text','wysiwyg','<p>Inhalt wird einfach per drag &amp; drop mit Inhaltsblöcken erstellt, welche dann direkt in-line editiert werden können.</p>\n'),(49,'circle','checkbox',''),(49,'headline','input','HTML5 immer & überall'),(49,'image','image','a:9:{s:2:\"id\";i:18;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(49,'link','link','a:15:{s:4:\"text\";s:14:\"Quisque rutrum\";s:4:\"path\";s:15:\"/en/experiments\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:6;s:12:\"internalType\";s:8:\"document\";s:4:\"type\";s:8:\"internal\";}'),(49,'text','wysiwyg','<p>&nbsp;</p>\n\n<p>Bilder direkt per drag &amp; drop vom Desktop&nbsp;in den Baum in pimcore hochladen, automatische HTML5 Video Konvertierung&nbsp;und viel mehr ...</p>\n'),(50,'blockcontent2','block','a:1:{i:0;s:1:\"1\";}'),(50,'circle2content1','checkbox',''),(50,'content','areablock','a:3:{i:0;a:2:{s:3:\"key\";s:1:\"3\";s:4:\"type\";s:7:\"wysiwyg\";}i:1;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:19:\"standard-teaser-row\";}i:2;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:10:\"featurette\";}}'),(50,'contentcontent3','wysiwyg','<p>Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. <a href=\"/basic-examples\">Etiam rhoncus</a>.</p>\n\n<p>&nbsp;</p>\n\n<ul>\n	<li>Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum.</li>\n	<li>Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem.</li>\n	<li>Maecenas nec odio et ante tincidunt tempus.</li>\n	<li><a href=\"/basic-examples\">Donec vitae sapien ut libero venenatis faucibus.</a></li>\n	<li>Nullam quis ante.</li>\n	<li>Etiam sit amet orci eget eros <a href=\"/advanced-examples\">faucibus </a>tincidunt.</li>\n</ul>\n\n<p>&nbsp;</p>\n\n<p>Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform <a href=\"/experiments\">grammatica</a>, pronunciation e plu sommun paroles.</p>\n\n<p>&nbsp;</p>\n\n<ol>\n	<li>It va esser tam simplic quam Occidental in fact, it va esser Occidental.</li>\n	<li>A un Angleso it va semblar un simplificat Angles, quam un skeptic <a href=\"/introduction\">Cambridge </a>amico dit me que Occidental es.</li>\n	<li>Li Europan lingues es membres del sam familie.</li>\n	<li>Lor separat existentie es un myth.</li>\n	<li>Por scientie, musica, sport etc, litot Europa usa li sam vocabular.</li>\n	<li>Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules.</li>\n</ol>\n\n<p>&nbsp;</p>\n'),(50,'contentcontent_blockcontent22_1','wysiwyg','<p>Donec ullamcorper nulla non metus auctor fringilla. Vestibulum id ligula porta felis euismod semper. Praesent commodo cursus magna, vel scelerisque nisl consectetur. Fusce dapibus, tellus ac cursus commodo. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo.</p>\n'),(50,'headDescription','input','Überblick über das Projekt und wie man mit einer einfachen Vorlage loslegen kann.'),(50,'headline','input','Einführung'),(50,'headline2content1','input',''),(50,'headlinecontent_blockcontent22_1','input','Ullamcorper Scelerisque '),(50,'headTitle','input','Erste Schritte'),(50,'image2content1','image','a:9:{s:2:\"id\";N;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(50,'imagecontent1','image','a:9:{s:2:\"id\";i:22;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(50,'imagecontent_blockcontent22_1','image','a:9:{s:2:\"id\";i:24;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(50,'imagePositioncontent_blockcontent22_1','select',''),(50,'leadcontent3','wysiwyg','<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.</p>\n'),(50,'link2content1','link','a:10:{s:4:\"type\";s:8:\"internal\";s:4:\"path\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:6:\"target\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(50,'linkcontent1','link','a:14:{s:4:\"text\";s:12:\"Etiam rhoncu\";s:4:\"path\";s:18:\"/advanced-examples\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:8:\"internal\";b:1;s:10:\"internalId\";i:5;s:12:\"internalType\";s:8:\"document\";}'),(50,'postitioncontent_blockcontent22_1','select',''),(50,'sublinecontent_blockcontent22_1','input',''),(50,'teaser_0content1','snippet','47'),(50,'teaser_1content1','snippet','48'),(50,'teaser_2content1','snippet','49'),(50,'text2content1','wysiwyg',''),(50,'textcontent1','wysiwyg','<p>Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna.</p>\n'),(50,'typecontent_blockcontent22_1','select',''),(50,'type_0content1','select',''),(50,'type_1content1','select','snippet'),(50,'type_2content1','select','snippet'),(51,'content','areablock','a:1:{i:0;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:7:\"wysiwyg\";}}'),(51,'contentcontent1','wysiwyg',''),(51,'headDescription','input',''),(51,'headline','input','Übersicht über einfache Beispiele'),(51,'headTitle','input',''),(51,'leadcontent1','wysiwyg','<p>Diese Seite dient nur zur Demonstration einer mehrsprachigen Seite.&nbsp;</p>\n\n<p><a href=\"/en/basic-examples\" pimcore_id=\"3\" pimcore_type=\"document\">Um die Beispiele zu sehen verwende bitte die Englische Beispielseite.&nbsp;</a></p>\n'),(52,'content','areablock','a:1:{i:0;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:7:\"wysiwyg\";}}'),(52,'contentcontent1','wysiwyg',''),(52,'headDescription','input',''),(52,'headline','input','Übersicht über fortgeschrittene Beispiele'),(52,'headTitle','input',''),(52,'leadcontent1','wysiwyg','<p>Diese Seite dient nur zur Demonstration einer mehrsprachigen Seite.&nbsp;</p>\n\n<p><a href=\"/en/advanced-examples\" pimcore_id=\"5\" pimcore_type=\"document\">Um die Beispiele zu sehen verwende bitte die Englische Beispielseite.&nbsp;</a></p>\n'),(53,'content','areablock','a:1:{i:0;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:7:\"wysiwyg\";}}'),(53,'contentcontent1','wysiwyg',''),(53,'headDescription','input',''),(53,'headline','input','Neuigkeiten'),(53,'headTitle','input',''),(53,'leadcontent1','wysiwyg','<p>Alle strukturierten Daten werden in \"Objects\" gespeichert.&nbsp;</p>\n'),(53,'multiselect','multiselect','a:0:{}'),(53,'myCheckbox','checkbox',''),(53,'myDate','date',''),(53,'myHref','href','a:3:{s:2:\"id\";N;s:4:\"type\";N;s:7:\"subtype\";N;}'),(53,'myImageBlock','block','a:0:{}'),(53,'myInput','input',''),(53,'myLink','link','a:10:{s:4:\"type\";s:8:\"internal\";s:4:\"path\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:6:\"target\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(53,'myMultihref','multihref','a:0:{}'),(53,'myNumber','numeric',''),(53,'mySelect','select',''),(53,'myTextarea','textarea',''),(53,'myWysiwyg','wysiwyg',''),(57,'blogArticles','select','3'),(57,'teasers','block','a:1:{i:0;s:1:\"1\";}'),(57,'teaserteasers1','snippet','15'),(58,'teasers','block','a:2:{i:0;s:1:\"1\";i:1;s:1:\"2\";}'),(58,'teaserteasers1','snippet','47'),(58,'teaserteasers2','snippet','49'),(59,'blogArticles','select','2'),(59,'teasers','block','a:2:{i:0;s:1:\"1\";i:1;s:1:\"2\";}'),(59,'teaserteasers1','snippet','15'),(59,'teaserteasers2','snippet','16'),(60,'content','areablock','a:1:{i:0;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:9:\"headlines\";}}'),(60,'contentcontent1','wysiwyg',''),(60,'headDescription','input',''),(60,'headline','input','Blog'),(60,'headlinecontent2','input',''),(60,'headTitle','input',''),(60,'leadcontent1','wysiwyg','<p>A blog is also just a simple list of objects.</p>\n\n<p>You can easily modify the structure of an article in Settings -&gt; Object -&gt; Classes.&nbsp;</p>\n'),(60,'leadcontent2','wysiwyg','<p>A blog is also just a simple list of objects. You can easily modify the structure of an article in Settings -&gt; Object -&gt; Classes.</p>\n'),(60,'multiselect','multiselect','a:0:{}'),(60,'myCheckbox','checkbox',''),(60,'myDate','date',NULL),(60,'myHref','href','a:3:{s:2:\"id\";N;s:4:\"type\";N;s:7:\"subtype\";N;}'),(60,'myImageBlock','block','a:0:{}'),(60,'myInput','input',''),(60,'myLink','link','a:10:{s:4:\"type\";s:8:\"internal\";s:4:\"path\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:6:\"target\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(60,'myMultihref','multihref','a:0:{}'),(60,'myNumber','numeric',''),(60,'mySelect','select',''),(60,'myTextarea','textarea',''),(60,'myWysiwyg','wysiwyg',''),(61,'content','areablock','a:0:{}'),(61,'headDescription','input',''),(61,'headline','input','Auto-generated Sitemap'),(61,'headTitle','input',''),(61,'multiselect','multiselect','a:0:{}'),(61,'myCheckbox','checkbox',''),(61,'myDate','date',''),(61,'myHref','href','a:3:{s:2:\"id\";N;s:4:\"type\";N;s:7:\"subtype\";N;}'),(61,'myImageBlock','block','a:0:{}'),(61,'myInput','input',''),(61,'myLink','link','a:10:{s:4:\"type\";s:8:\"internal\";s:4:\"path\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:6:\"target\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(61,'myMultihref','multihref','a:0:{}'),(61,'myNumber','numeric',''),(61,'mySelect','select',''),(61,'myTextarea','textarea',''),(61,'myWysiwyg','wysiwyg',''),(63,'content','areablock','a:0:{}'),(63,'headDescription','input',''),(63,'headline','input','Newsletter'),(63,'headTitle','input',''),(64,'content','areablock','a:0:{}'),(64,'headDescription','input',''),(64,'headline','input',''),(64,'headTitle','input',''),(65,'content','areablock','a:0:{}'),(65,'headDescription','input',''),(65,'headline','input','Newsletter Unsubscribe'),(65,'headTitle','input',''),(66,'contactInfo','wysiwyg','<h5>Contact Info</h5>\n\n<p>Example Inc.<br />\nEvergreen Terrace 123<br />\nXX 89234 Springfield<br />\n<br />\n+8998 487563 34234<br />\n<a href=\"mailto:info@example.inc\">info@example.inc</a></p>\n'),(66,'content','wysiwyg','<p>Hi %Text(firstname);&nbsp;%Text(lastname);,&nbsp;</p>\n\n<p>&nbsp;</p>\n\n<p>You have just subscribed our cool newsletter with the email address: %Text(email);.&nbsp;</p>\n\n<p>To finish the process please click the following link to confirm your email address.&nbsp;</p>\n\n<p>&nbsp;</p>\n\n<p><a href=\"http://demo.pimcore.org/en/advanced-examples/newsletter/confirm?token=%Text(token);\">CLICK HERE TO CONFIRM</a></p>\n\n<p>&nbsp;</p>\n\n<p>Thanks &amp; have a nice day!</p>\n'),(66,'footerLink1','link','a:12:{s:4:\"text\";s:5:\"Terms\";s:4:\"path\";s:1:\"#\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:4:\"type\";s:8:\"internal\";}'),(66,'footerLink2','link','a:12:{s:4:\"text\";s:7:\"Privacy\";s:4:\"path\";s:1:\"#\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:4:\"type\";s:8:\"internal\";}'),(66,'footerLink3','link','a:12:{s:4:\"text\";s:5:\"About\";s:4:\"path\";s:1:\"#\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";s:4:\"type\";s:8:\"internal\";}'),(67,'contactInfo','wysiwyg','<h5>Contact Info</h5>\n\n<p>Example Inc.<br />\nEvergreen Terrace 123<br />\nXX 89234 Springfield<br />\n<br />\n+8998 487563 34234<br />\n<a href=\"mailto:info@example.inc\">info@example.inc</a></p>\n'),(67,'content','wysiwyg','<p><span style=\"line-height: 1.3;\">Lorem ipsum dolor sit amet, consectetuer adipiscing elit.</span></p>\n\n<p>Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus.</p>\n\n<p>&nbsp;</p>\n\n<p><img pimcore_id=\"22\" pimcore_type=\"asset\" src=\"/website/var/tmp/image-thumbnails/22/thumb__auto_850904660de984af948beee3aee98a4f/img_0399.jpeg\" style=\"width:600px;\" /></p>\n\n<p>&nbsp;</p>\n\n<p>&nbsp;</p>\n\n<p>Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante.&nbsp;</p>\n\n<p>&nbsp;</p>\n\n<p>&nbsp;</p>\n\n<p>&nbsp;</p>\n\n<p>Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum.</p>\n\n<p>&nbsp;</p>\n\n<p>Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor.</p>\n'),(67,'footerLink1','link','a:11:{s:4:\"text\";s:5:\"Terms\";s:4:\"path\";s:1:\"#\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(67,'footerLink2','link','a:11:{s:4:\"text\";s:7:\"Privacy\";s:4:\"path\";s:1:\"#\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(67,'footerLink3','link','a:11:{s:4:\"text\";s:11:\"Unsubscribe\";s:4:\"path\";s:87:\"http://demo.pimcore.org/en/advanced-examples/newsletter/unsubscribe?token=%Text(token);\";s:6:\"target\";s:0:\"\";s:10:\"parameters\";s:0:\"\";s:6:\"anchor\";s:0:\"\";s:5:\"title\";s:0:\"\";s:9:\"accesskey\";s:0:\"\";s:3:\"rel\";s:0:\"\";s:8:\"tabindex\";s:0:\"\";s:5:\"class\";s:0:\"\";s:10:\"attributes\";s:0:\"\";}'),(68,'content','areablock','a:0:{}'),(68,'headDescription','input',''),(68,'headline','input','Asset Thumbnail List'),(68,'headTitle','input',''),(68,'parentFolder','href','a:3:{s:2:\"id\";N;s:4:\"type\";N;s:7:\"subtype\";N;}'),(69,'teasers','block','a:2:{i:0;s:1:\"1\";i:1;s:1:\"2\";}'),(69,'teaserteasers1','snippet','16'),(69,'teaserteasers2','snippet','17'),(70,'content','areablock','a:2:{i:0;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:7:\"wysiwyg\";}i:1;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:5:\"image\";}}'),(70,'contentcontent1','wysiwyg','<p>Please visit our&nbsp;<a href=\"http://pimcore.org/demo\">PIM, E-Commerce &amp; Asset Management demo</a> to see it in action.&nbsp;</p>\n'),(70,'headDescription','input',''),(70,'headline','input','Product Information Management'),(70,'headTitle','input',''),(70,'imagecontent2','image','a:9:{s:2:\"id\";i:70;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(70,'leadcontent1','wysiwyg',''),(70,'leadcontent2','wysiwyg',''),(71,'content','areablock','a:2:{i:0;a:2:{s:3:\"key\";s:1:\"1\";s:4:\"type\";s:7:\"wysiwyg\";}i:1;a:2:{s:3:\"key\";s:1:\"2\";s:4:\"type\";s:5:\"image\";}}'),(71,'contentcontent1','wysiwyg','<p>Please visit our&nbsp;<a href=\"http://pimcore.org/demo\">PIM, E-Commerce &amp; Asset Management demo</a> to see it in action.&nbsp;</p>\n'),(71,'headDescription','input',''),(71,'headline','input','E-Commerce'),(71,'headTitle','input',''),(71,'imagecontent2','image','a:9:{s:2:\"id\";i:69;s:3:\"alt\";s:0:\"\";s:11:\"cropPercent\";N;s:9:\"cropWidth\";N;s:10:\"cropHeight\";N;s:7:\"cropTop\";N;s:8:\"cropLeft\";N;s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}}'),(71,'leadcontent1','wysiwyg',''),(71,'leadcontent2','wysiwyg',''),(72,'content','areablock','a:0:{}'),(72,'headDescription','input',''),(72,'headline','input',''),(72,'headTitle','input','');
/*!40000 ALTER TABLE `documents_elements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents_email`
--

DROP TABLE IF EXISTS `documents_email`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `documents_email` (
  `id` int(11) unsigned NOT NULL DEFAULT '0',
  `module` varchar(255) DEFAULT NULL,
  `controller` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `template` varchar(255) DEFAULT NULL,
  `to` varchar(255) DEFAULT NULL,
  `from` varchar(255) DEFAULT NULL,
  `cc` varchar(255) DEFAULT NULL,
  `bcc` varchar(255) DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents_email`
--

LOCK TABLES `documents_email` WRITE;
/*!40000 ALTER TABLE `documents_email` DISABLE KEYS */;
INSERT INTO `documents_email` VALUES (38,'','default','default','/advanced/email.php','pimcore@byom.de','webserver@pimcore.org','','','Contact Form'),(66,'','newsletter','standard-mail','','','','','',''),(67,'','newsletter','standard-mail','','','','','','Example Newsletter');
/*!40000 ALTER TABLE `documents_email` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents_hardlink`
--

DROP TABLE IF EXISTS `documents_hardlink`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `documents_hardlink` (
  `id` int(11) unsigned NOT NULL DEFAULT '0',
  `sourceId` int(11) DEFAULT NULL,
  `propertiesFromSource` tinyint(1) DEFAULT NULL,
  `childsFromSource` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents_hardlink`
--

LOCK TABLES `documents_hardlink` WRITE;
/*!40000 ALTER TABLE `documents_hardlink` DISABLE KEYS */;
INSERT INTO `documents_hardlink` VALUES (33,3,1,1);
/*!40000 ALTER TABLE `documents_hardlink` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents_link`
--

DROP TABLE IF EXISTS `documents_link`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `documents_link` (
  `id` int(11) unsigned NOT NULL DEFAULT '0',
  `internalType` enum('document','asset') DEFAULT NULL,
  `internal` int(11) unsigned DEFAULT NULL,
  `direct` varchar(1000) DEFAULT NULL,
  `linktype` enum('direct','internal') DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents_link`
--

LOCK TABLES `documents_link` WRITE;
/*!40000 ALTER TABLE `documents_link` DISABLE KEYS */;
INSERT INTO `documents_link` VALUES (32,NULL,0,'http://www.pimcore.org/','direct'),(40,'document',1,'','internal');
/*!40000 ALTER TABLE `documents_link` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents_page`
--

DROP TABLE IF EXISTS `documents_page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `documents_page` (
  `id` int(11) unsigned NOT NULL DEFAULT '0',
  `module` varchar(255) DEFAULT NULL,
  `controller` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `template` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `keywords` varchar(255) DEFAULT NULL,
  `metaData` text,
  `prettyUrl` varchar(255) DEFAULT NULL,
  `contentMasterDocumentId` int(11) DEFAULT NULL,
  `css` longtext,
  `personas` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `prettyUrl` (`prettyUrl`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents_page`
--

LOCK TABLES `documents_page` WRITE;
/*!40000 ALTER TABLE `documents_page` DISABLE KEYS */;
INSERT INTO `documents_page` VALUES (1,'','content','portal','','','','','a:0:{}','',0,'',''),(3,'','content','default','','','','','a:0:{}','',0,'',''),(4,'','content','default','','','','','a:0:{}','',0,'',''),(5,'','advanced','index','','','','','a:0:{}','',0,'',''),(6,'','content','default','','','','','a:0:{}','',0,'',''),(7,'','content','default','','','','','a:0:{}','',0,'',''),(9,'','advanced','object-form','','','','','a:0:{}','',0,'',''),(18,'','content','default','','','','','a:0:{}','',0,'',''),(19,'','content','default','','','','','a:0:{}','',0,'',''),(20,'','content','default','','','','','a:0:{}','',0,'',''),(21,'','content','thumbnails','','','','','a:0:{}','',0,'',''),(22,'','content','website-translations','','','','','a:0:{}','',0,'',''),(23,'','content','website-translations','','','','','a:0:{}','',0,'',''),(24,'','content','default','','','','','a:0:{}',NULL,0,'',''),(25,'','content','editable-roundup','','','','','a:0:{}','',0,'',''),(26,'','content','simple-form','','','','','a:0:{}','',0,'',''),(27,'','news','index','','','','','a:0:{}','',0,'',''),(28,'','content','default','','','','','a:0:{}','',0,'',''),(29,'','content','default','','','','','a:0:{}','',0,'',''),(30,'','content','default','','','','','a:0:{}','',0,'',''),(31,'','content','default','','','','','a:0:{}','',30,'',''),(34,'','content','default','','','','','a:0:{}','',0,'',''),(35,'','content','default','','','','','a:0:{}','',0,'',''),(36,'','advanced','search','','','','','a:0:{}','',0,'',''),(37,'','advanced','contact-form','','','','','a:0:{}','',0,'',''),(39,'','content','default','','','','','a:0:{}','',0,'',''),(41,'','content','portal','','','','','a:0:{}','',0,'',''),(50,'','content','default','','','','','a:0:{}','',0,'',''),(51,'','content','default','','Einfache Beispiele','','','a:0:{}','',0,'',''),(52,'','content','default','','Beispiele für Fortgeschrittene','','','a:0:{}','',0,'',''),(53,'','news','index','','','','','a:0:{}','',0,'',''),(60,'','blog','index','','Blog','','','a:0:{}','',0,'',''),(61,'','advanced','sitemap','','Sitemap','','','a:0:{}','',0,'',''),(63,'','newsletter','subscribe','','Newsletter','','','a:0:{}','',0,'',''),(64,'','newsletter','confirm','','','','','a:0:{}','',0,'',''),(65,'','newsletter','unsubscribe','','Unsubscribe','','','a:0:{}','',0,'',''),(68,'','advanced','asset-thumbnail-list','','Asset Thumbnail List','','','a:0:{}','',0,'',''),(70,'','content','default','','Product Information Management','','','a:0:{}','',0,'',''),(71,'','content','default','','E-Commerce','','','a:0:{}','',0,'',''),(72,'','category_example','test','','','','','a:0:{}',NULL,NULL,'','');
/*!40000 ALTER TABLE `documents_page` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents_snippet`
--

DROP TABLE IF EXISTS `documents_snippet`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `documents_snippet` (
  `id` int(11) unsigned NOT NULL DEFAULT '0',
  `module` varchar(255) DEFAULT NULL,
  `controller` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `template` varchar(255) DEFAULT NULL,
  `contentMasterDocumentId` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents_snippet`
--

LOCK TABLES `documents_snippet` WRITE;
/*!40000 ALTER TABLE `documents_snippet` DISABLE KEYS */;
INSERT INTO `documents_snippet` VALUES (12,'','default','default','/includes/footer.php',0),(15,'','default','default','/snippets/standard-teaser.php',0),(16,'','default','default','/snippets/standard-teaser.php',0),(17,'','default','default','/snippets/standard-teaser.php',0),(46,'','default','default','/includes/footer.php',0),(47,'','default','default','/snippets/standard-teaser.php',0),(48,'','default','default','/snippets/standard-teaser.php',0),(49,'','default','default','/snippets/standard-teaser.php',0),(57,'','default','default','/includes/sidebar.php',0),(58,'','default','default','/includes/sidebar.php',0),(59,'','default','default','/includes/sidebar.php',0),(69,'','default','default','/includes/sidebar.php',0);
/*!40000 ALTER TABLE `documents_snippet` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents_translations`
--

DROP TABLE IF EXISTS `documents_translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `documents_translations` (
  `id` int(11) unsigned NOT NULL DEFAULT '0',
  `sourceId` int(11) unsigned NOT NULL DEFAULT '0',
  `language` varchar(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`sourceId`,`language`),
  KEY `id` (`id`),
  KEY `sourceId` (`sourceId`),
  KEY `language` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents_translations`
--

LOCK TABLES `documents_translations` WRITE;
/*!40000 ALTER TABLE `documents_translations` DISABLE KEYS */;
INSERT INTO `documents_translations` VALUES (23,22,'de'),(41,40,'de'),(46,12,'de'),(47,15,'de'),(48,16,'de'),(49,17,'de'),(50,4,'de'),(51,3,'de'),(52,5,'de'),(53,27,'de'),(58,57,'de');
/*!40000 ALTER TABLE `documents_translations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `edit_lock`
--

DROP TABLE IF EXISTS `edit_lock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `edit_lock` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) unsigned NOT NULL DEFAULT '0',
  `ctype` enum('document','asset','object') DEFAULT NULL,
  `userId` int(11) unsigned NOT NULL DEFAULT '0',
  `sessionId` varchar(255) DEFAULT NULL,
  `date` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cid` (`cid`),
  KEY `ctype` (`ctype`),
  KEY `cidtype` (`cid`,`ctype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `edit_lock`
--

LOCK TABLES `edit_lock` WRITE;
/*!40000 ALTER TABLE `edit_lock` DISABLE KEYS */;
/*!40000 ALTER TABLE `edit_lock` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_blacklist`
--

DROP TABLE IF EXISTS `email_blacklist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_blacklist` (
  `address` varchar(255) NOT NULL DEFAULT '',
  `creationDate` int(11) unsigned DEFAULT NULL,
  `modificationDate` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`address`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_blacklist`
--

LOCK TABLES `email_blacklist` WRITE;
/*!40000 ALTER TABLE `email_blacklist` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_blacklist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_log`
--

DROP TABLE IF EXISTS `email_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `documentId` int(11) DEFAULT NULL,
  `requestUri` varchar(500) DEFAULT NULL,
  `params` text,
  `from` varchar(500) DEFAULT NULL,
  `to` longtext,
  `cc` longtext,
  `bcc` longtext,
  `sentDate` bigint(20) DEFAULT NULL,
  `subject` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_log`
--

LOCK TABLES `email_log` WRITE;
/*!40000 ALTER TABLE `email_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `glossary`
--

DROP TABLE IF EXISTS `glossary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `glossary` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `language` varchar(10) DEFAULT NULL,
  `casesensitive` tinyint(1) DEFAULT NULL,
  `exactmatch` tinyint(1) DEFAULT NULL,
  `text` varchar(255) DEFAULT NULL,
  `link` varchar(255) DEFAULT NULL,
  `abbr` varchar(255) DEFAULT NULL,
  `acronym` varchar(255) DEFAULT NULL,
  `site` int(11) unsigned DEFAULT NULL,
  `creationDate` bigint(20) unsigned DEFAULT '0',
  `modificationDate` bigint(20) unsigned DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `language` (`language`),
  KEY `site` (`site`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `glossary`
--

LOCK TABLES `glossary` WRITE;
/*!40000 ALTER TABLE `glossary` DISABLE KEYS */;
INSERT INTO `glossary` VALUES (1,'en',0,1,'occidental','7','','',0,0,0),(2,'en',0,1,'vocabular','20','','',0,0,0),(3,'en',0,1,'resultant','5','','',0,0,0),(4,'en',0,1,'familie','18','','',0,0,0),(5,'en',0,1,'omnicos','19','','',0,0,0),(6,'en',0,1,'coalesce','','coalesce','',0,0,0),(7,'en',0,1,'grammatica','','','grammatica',0,0,0);
/*!40000 ALTER TABLE `glossary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `http_error_log`
--

DROP TABLE IF EXISTS `http_error_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `http_error_log` (
  `uri` varchar(3000) CHARACTER SET ascii DEFAULT NULL,
  `code` int(3) DEFAULT NULL,
  `parametersGet` longtext,
  `parametersPost` longtext,
  `cookies` longtext,
  `serverVars` longtext,
  `date` bigint(20) DEFAULT NULL,
  `count` bigint(20) DEFAULT NULL,
  KEY `uri` (`uri`(765)),
  KEY `code` (`code`),
  KEY `date` (`date`),
  KEY `count` (`count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `http_error_log`
--

LOCK TABLES `http_error_log` WRITE;
/*!40000 ALTER TABLE `http_error_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `http_error_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `keyvalue_groups`
--

DROP TABLE IF EXISTS `keyvalue_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `keyvalue_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `description` varchar(255) DEFAULT NULL,
  `creationDate` bigint(20) unsigned DEFAULT '0',
  `modificationDate` bigint(20) unsigned DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `keyvalue_groups`
--

LOCK TABLES `keyvalue_groups` WRITE;
/*!40000 ALTER TABLE `keyvalue_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `keyvalue_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `keyvalue_keys`
--

DROP TABLE IF EXISTS `keyvalue_keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `keyvalue_keys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `description` text,
  `type` enum('bool','number','select','text','translated','translatedSelect','range') DEFAULT NULL,
  `unit` varchar(255) DEFAULT NULL,
  `possiblevalues` text,
  `group` int(11) DEFAULT NULL,
  `creationDate` bigint(20) unsigned DEFAULT '0',
  `modificationDate` bigint(20) unsigned DEFAULT '0',
  `translator` int(11) DEFAULT NULL,
  `mandatory` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `group` (`group`),
  CONSTRAINT `keyvalue_keys_ibfk_1` FOREIGN KEY (`group`) REFERENCES `keyvalue_groups` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `keyvalue_keys`
--

LOCK TABLES `keyvalue_keys` WRITE;
/*!40000 ALTER TABLE `keyvalue_keys` DISABLE KEYS */;
/*!40000 ALTER TABLE `keyvalue_keys` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `keyvalue_translator_configuration`
--

DROP TABLE IF EXISTS `keyvalue_translator_configuration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `keyvalue_translator_configuration` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) DEFAULT NULL,
  `translator` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `keyvalue_translator_configuration`
--

LOCK TABLES `keyvalue_translator_configuration` WRITE;
/*!40000 ALTER TABLE `keyvalue_translator_configuration` DISABLE KEYS */;
/*!40000 ALTER TABLE `keyvalue_translator_configuration` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `locks`
--

DROP TABLE IF EXISTS `locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `locks` (
  `id` varchar(150) NOT NULL DEFAULT '',
  `date` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MEMORY DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locks`
--

LOCK TABLES `locks` WRITE;
/*!40000 ALTER TABLE `locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notes`
--

DROP TABLE IF EXISTS `notes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) DEFAULT NULL,
  `cid` int(11) DEFAULT NULL,
  `ctype` enum('asset','document','object') DEFAULT NULL,
  `date` int(11) DEFAULT NULL,
  `user` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `description` longtext,
  PRIMARY KEY (`id`),
  KEY `cid` (`cid`),
  KEY `ctype` (`ctype`),
  KEY `date` (`date`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notes`
--

LOCK TABLES `notes` WRITE;
/*!40000 ALTER TABLE `notes` DISABLE KEYS */;
INSERT INTO `notes` VALUES (18,'newsletter',47,'object',1388412533,0,'subscribe',''),(19,'newsletter',47,'object',1388412545,0,'confirm','');
/*!40000 ALTER TABLE `notes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notes_data`
--

DROP TABLE IF EXISTS `notes_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notes_data` (
  `id` int(11) NOT NULL DEFAULT '0',
  `name` varchar(255) DEFAULT NULL,
  `type` enum('text','date','document','asset','object','bool') DEFAULT NULL,
  `data` text,
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notes_data`
--

LOCK TABLES `notes_data` WRITE;
/*!40000 ALTER TABLE `notes_data` DISABLE KEYS */;
INSERT INTO `notes_data` VALUES (18,'ip','text','192.168.9.12'),(19,'ip','text','192.168.9.12');
/*!40000 ALTER TABLE `notes_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `object_2`
--

DROP TABLE IF EXISTS `object_2`;
/*!50001 DROP VIEW IF EXISTS `object_2`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `object_2` AS SELECT 
 1 AS `oo_id`,
 1 AS `oo_classId`,
 1 AS `oo_className`,
 1 AS `date`,
 1 AS `image_1`,
 1 AS `image_2`,
 1 AS `image_3`,
 1 AS `o_id`,
 1 AS `o_parentId`,
 1 AS `o_type`,
 1 AS `o_key`,
 1 AS `o_path`,
 1 AS `o_index`,
 1 AS `o_published`,
 1 AS `o_creationDate`,
 1 AS `o_modificationDate`,
 1 AS `o_userOwner`,
 1 AS `o_userModification`,
 1 AS `o_classId`,
 1 AS `o_className`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `object_3`
--

DROP TABLE IF EXISTS `object_3`;
/*!50001 DROP VIEW IF EXISTS `object_3`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `object_3` AS SELECT 
 1 AS `oo_id`,
 1 AS `oo_classId`,
 1 AS `oo_className`,
 1 AS `person__id`,
 1 AS `person__type`,
 1 AS `date`,
 1 AS `message`,
 1 AS `terms`,
 1 AS `o_id`,
 1 AS `o_parentId`,
 1 AS `o_type`,
 1 AS `o_key`,
 1 AS `o_path`,
 1 AS `o_index`,
 1 AS `o_published`,
 1 AS `o_creationDate`,
 1 AS `o_modificationDate`,
 1 AS `o_userOwner`,
 1 AS `o_userModification`,
 1 AS `o_classId`,
 1 AS `o_className`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `object_4`
--

DROP TABLE IF EXISTS `object_4`;
/*!50001 DROP VIEW IF EXISTS `object_4`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `object_4` AS SELECT 
 1 AS `oo_id`,
 1 AS `oo_classId`,
 1 AS `oo_className`,
 1 AS `gender`,
 1 AS `firstname`,
 1 AS `lastname`,
 1 AS `email`,
 1 AS `newsletterActive`,
 1 AS `newsletterConfirmed`,
 1 AS `dateRegister`,
 1 AS `o_id`,
 1 AS `o_parentId`,
 1 AS `o_type`,
 1 AS `o_key`,
 1 AS `o_path`,
 1 AS `o_index`,
 1 AS `o_published`,
 1 AS `o_creationDate`,
 1 AS `o_modificationDate`,
 1 AS `o_userOwner`,
 1 AS `o_userModification`,
 1 AS `o_classId`,
 1 AS `o_className`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `object_5`
--

DROP TABLE IF EXISTS `object_5`;
/*!50001 DROP VIEW IF EXISTS `object_5`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `object_5` AS SELECT 
 1 AS `oo_id`,
 1 AS `oo_classId`,
 1 AS `oo_className`,
 1 AS `date`,
 1 AS `categories`,
 1 AS `posterImage__image`,
 1 AS `posterImage__hotspots`,
 1 AS `o_id`,
 1 AS `o_parentId`,
 1 AS `o_type`,
 1 AS `o_key`,
 1 AS `o_path`,
 1 AS `o_index`,
 1 AS `o_published`,
 1 AS `o_creationDate`,
 1 AS `o_modificationDate`,
 1 AS `o_userOwner`,
 1 AS `o_userModification`,
 1 AS `o_classId`,
 1 AS `o_className`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `object_6`
--

DROP TABLE IF EXISTS `object_6`;
/*!50001 DROP VIEW IF EXISTS `object_6`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `object_6` AS SELECT 
 1 AS `oo_id`,
 1 AS `oo_classId`,
 1 AS `oo_className`,
 1 AS `o_id`,
 1 AS `o_parentId`,
 1 AS `o_type`,
 1 AS `o_key`,
 1 AS `o_path`,
 1 AS `o_index`,
 1 AS `o_published`,
 1 AS `o_creationDate`,
 1 AS `o_modificationDate`,
 1 AS `o_userOwner`,
 1 AS `o_userModification`,
 1 AS `o_classId`,
 1 AS `o_className`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `object_localized_2_de`
--

DROP TABLE IF EXISTS `object_localized_2_de`;
/*!50001 DROP VIEW IF EXISTS `object_localized_2_de`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `object_localized_2_de` AS SELECT 
 1 AS `oo_id`,
 1 AS `oo_classId`,
 1 AS `oo_className`,
 1 AS `date`,
 1 AS `image_1`,
 1 AS `image_2`,
 1 AS `image_3`,
 1 AS `o_id`,
 1 AS `o_parentId`,
 1 AS `o_type`,
 1 AS `o_key`,
 1 AS `o_path`,
 1 AS `o_index`,
 1 AS `o_published`,
 1 AS `o_creationDate`,
 1 AS `o_modificationDate`,
 1 AS `o_userOwner`,
 1 AS `o_userModification`,
 1 AS `o_classId`,
 1 AS `o_className`,
 1 AS `ooo_id`,
 1 AS `language`,
 1 AS `title`,
 1 AS `shortText`,
 1 AS `text`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `object_localized_2_en`
--

DROP TABLE IF EXISTS `object_localized_2_en`;
/*!50001 DROP VIEW IF EXISTS `object_localized_2_en`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `object_localized_2_en` AS SELECT 
 1 AS `oo_id`,
 1 AS `oo_classId`,
 1 AS `oo_className`,
 1 AS `date`,
 1 AS `image_1`,
 1 AS `image_2`,
 1 AS `image_3`,
 1 AS `o_id`,
 1 AS `o_parentId`,
 1 AS `o_type`,
 1 AS `o_key`,
 1 AS `o_path`,
 1 AS `o_index`,
 1 AS `o_published`,
 1 AS `o_creationDate`,
 1 AS `o_modificationDate`,
 1 AS `o_userOwner`,
 1 AS `o_userModification`,
 1 AS `o_classId`,
 1 AS `o_className`,
 1 AS `ooo_id`,
 1 AS `language`,
 1 AS `title`,
 1 AS `shortText`,
 1 AS `text`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `object_localized_5_de`
--

DROP TABLE IF EXISTS `object_localized_5_de`;
/*!50001 DROP VIEW IF EXISTS `object_localized_5_de`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `object_localized_5_de` AS SELECT 
 1 AS `oo_id`,
 1 AS `oo_classId`,
 1 AS `oo_className`,
 1 AS `date`,
 1 AS `categories`,
 1 AS `posterImage__image`,
 1 AS `posterImage__hotspots`,
 1 AS `o_id`,
 1 AS `o_parentId`,
 1 AS `o_type`,
 1 AS `o_key`,
 1 AS `o_path`,
 1 AS `o_index`,
 1 AS `o_published`,
 1 AS `o_creationDate`,
 1 AS `o_modificationDate`,
 1 AS `o_userOwner`,
 1 AS `o_userModification`,
 1 AS `o_classId`,
 1 AS `o_className`,
 1 AS `ooo_id`,
 1 AS `language`,
 1 AS `title`,
 1 AS `text`,
 1 AS `tags`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `object_localized_5_en`
--

DROP TABLE IF EXISTS `object_localized_5_en`;
/*!50001 DROP VIEW IF EXISTS `object_localized_5_en`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `object_localized_5_en` AS SELECT 
 1 AS `oo_id`,
 1 AS `oo_classId`,
 1 AS `oo_className`,
 1 AS `date`,
 1 AS `categories`,
 1 AS `posterImage__image`,
 1 AS `posterImage__hotspots`,
 1 AS `o_id`,
 1 AS `o_parentId`,
 1 AS `o_type`,
 1 AS `o_key`,
 1 AS `o_path`,
 1 AS `o_index`,
 1 AS `o_published`,
 1 AS `o_creationDate`,
 1 AS `o_modificationDate`,
 1 AS `o_userOwner`,
 1 AS `o_userModification`,
 1 AS `o_classId`,
 1 AS `o_className`,
 1 AS `ooo_id`,
 1 AS `language`,
 1 AS `title`,
 1 AS `text`,
 1 AS `tags`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `object_localized_6_de`
--

DROP TABLE IF EXISTS `object_localized_6_de`;
/*!50001 DROP VIEW IF EXISTS `object_localized_6_de`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `object_localized_6_de` AS SELECT 
 1 AS `oo_id`,
 1 AS `oo_classId`,
 1 AS `oo_className`,
 1 AS `o_id`,
 1 AS `o_parentId`,
 1 AS `o_type`,
 1 AS `o_key`,
 1 AS `o_path`,
 1 AS `o_index`,
 1 AS `o_published`,
 1 AS `o_creationDate`,
 1 AS `o_modificationDate`,
 1 AS `o_userOwner`,
 1 AS `o_userModification`,
 1 AS `o_classId`,
 1 AS `o_className`,
 1 AS `ooo_id`,
 1 AS `language`,
 1 AS `name`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `object_localized_6_en`
--

DROP TABLE IF EXISTS `object_localized_6_en`;
/*!50001 DROP VIEW IF EXISTS `object_localized_6_en`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `object_localized_6_en` AS SELECT 
 1 AS `oo_id`,
 1 AS `oo_classId`,
 1 AS `oo_className`,
 1 AS `o_id`,
 1 AS `o_parentId`,
 1 AS `o_type`,
 1 AS `o_key`,
 1 AS `o_path`,
 1 AS `o_index`,
 1 AS `o_published`,
 1 AS `o_creationDate`,
 1 AS `o_modificationDate`,
 1 AS `o_userOwner`,
 1 AS `o_userModification`,
 1 AS `o_classId`,
 1 AS `o_className`,
 1 AS `ooo_id`,
 1 AS `language`,
 1 AS `name`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `object_localized_data_2`
--

DROP TABLE IF EXISTS `object_localized_data_2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_localized_data_2` (
  `ooo_id` int(11) NOT NULL DEFAULT '0',
  `language` varchar(10) NOT NULL DEFAULT '',
  `title` varchar(255) DEFAULT NULL,
  `shortText` longtext,
  `text` longtext,
  PRIMARY KEY (`ooo_id`,`language`),
  KEY `ooo_id` (`ooo_id`),
  KEY `language` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_localized_data_2`
--

LOCK TABLES `object_localized_data_2` WRITE;
/*!40000 ALTER TABLE `object_localized_data_2` DISABLE KEYS */;
INSERT INTO `object_localized_data_2` VALUES (3,'de','Er hörte leise Schritte hinter sich','Das bedeutete nichts Gutes. Wer würde ihm schon folgen, spät in der Nacht und dazu noch in dieser engen Gasse mitten im übel beleumundeten Hafenviertel?','<p>Oder geh&ouml;rten die Schritte hinter ihm zu einem der unz&auml;hligen Gesetzesh&uuml;ter dieser Stadt, und die st&auml;hlerne Acht um seine Handgelenke w&uuml;rde gleich zuschnappen? Er konnte die Aufforderung stehen zu bleiben schon h&ouml;ren. Gehetzt sah er sich um. Pl&ouml;tzlich erblickte er den schmalen Durchgang. Blitzartig drehte er sich nach rechts und verschwand zwischen den beiden Geb&auml;uden. Beinahe w&auml;re er dabei &uuml;ber den umgest&uuml;rzten M&uuml;lleimer gefallen, der mitten im Weg lag.</p>\n\n<p>Er versuchte, sich in der Dunkelheit seinen Weg zu ertasten und erstarrte: Anscheinend gab es keinen anderen Ausweg aus diesem kleinen Hof als den Durchgang, durch den er gekommen war. Die Schritte wurden lauter und lauter, er sah eine dunkle Gestalt um die Ecke biegen. Fieberhaft irrten seine Augen durch die n&auml;chtliche Dunkelheit und suchten einen Ausweg. War jetzt wirklich alles vorbei.</p>\n'),(3,'en','Lorem ipsum dolor sit amet','Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus.','<p>Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam&nbsp;<a href=\"/en/basic-examples/content-page\" pimcore_id=\"24\" pimcore_type=\"document\">ultricies&nbsp;</a>nisi vel augue.</p>\n\n<p>Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget&nbsp;<a href=\"/en/basic-examples/galleries\" pimcore_id=\"19\" pimcore_type=\"document\">condimentum&nbsp;rhoncus</a>, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus.</p>\n'),(4,'de','Li Europan lingues es membres','Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular.','<p>Li nov lingua franca va esser plu simplic e regulari quam li existent Europan lingues. It va esser tam simplic quam Occidental in fact, it va esser Occidental. A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular.</p>\n\n<p>Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles.</p>\n'),(4,'en','In enim justo','Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim.','<p>Nam eget dui. Etiam rhoncus.&nbsp;<a href=\"/en/basic-examples\" pimcore_id=\"3\" pimcore_type=\"document\">Maecenas&nbsp;tempus</a>, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. <a href=\"/en/basic-examples/news\" pimcore_id=\"27\" pimcore_type=\"document\">Donec vitae sapien</a> ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed&nbsp;fringilla&nbsp;mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc,</p>\n'),(5,'de','Zwei flinke Boxer jagen die quirlige Eva','Franz jagt im komplett verwahrlosten Taxi quer durch Bayern. Zwölf Boxkämpfer jagen Viktor quer über den großen Sylter Deich. Vogel Quax zwickt Johnys Pferd Bim.','<p>Victor jagt zw&ouml;lf Boxk&auml;mpfer quer &uuml;ber den gro&szlig;en Sylter Deich. Falsches &Uuml;ben von Xylophonmusik qu&auml;lt jeden gr&ouml;&szlig;eren Zwerg. Heiz&ouml;lr&uuml;cksto&szlig;abd&auml;mpfung. Zwei flinke Boxer jagen die quirlige Eva und ihren Mops durch Sylt. Franz jagt im komplett verwahrlosten Taxi quer durch Bayern. Zw&ouml;lf Boxk&auml;mpfer jagen Viktor quer &uuml;ber den gro&szlig;en Sylter Deich. Vogel Quax zwickt Johnys Pferd Bim. Sylvia wagt quick den Jux bei Pforzheim. Polyfon zwitschernd a&szlig;en M&auml;xchens V&ouml;gel R&uuml;ben, Joghurt und Quark. &quot;Fix, Schwyz!&quot; qu&auml;kt J&uuml;rgen bl&ouml;d vom Pa&szlig;.</p>\n\n<p>Victor jagt zw&ouml;lf Boxk&auml;mpfer quer &uuml;ber den gro&szlig;en Sylter Deich. Falsches &Uuml;ben von Xylophonmusik qu&auml;lt jeden gr&ouml;&szlig;eren Zwerg. Heiz&ouml;lr&uuml;cksto&szlig;abd&auml;mpfung.Zwei flinke Boxer jagen die quirlige Eva und ihren Mops durch Sylt. Franz jagt im komplett verwahrlosten Taxi quer durch Bayern. Zw&ouml;lf Boxk&auml;mpfer jagen Viktor quer &uuml;ber den gro&szlig;en Sylter Deich. Vogel Quax zwickt Johnys Pferd Bim. Sylvia wagt quick den Jux</p>\n'),(5,'en','Nam eget dui','Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum.','<p>Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc,</p>\n'),(6,'de','Li Europan lingues es membres','Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular.','<p>Li nov lingua franca va esser plu simplic e regulari quam li existent Europan lingues. It va esser tam simplic quam Occidental in fact, it va esser Occidental. A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular.</p>\n\n<p>Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles.</p>\n'),(6,'en','In enim justo','Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim.',''),(7,'de','Li Europan lingues es membres','Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular.','<p>Li nov lingua franca va esser plu simplic e regulari quam li existent Europan lingues. It va esser tam simplic quam Occidental in fact, it va esser Occidental. A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular.</p>\n\n<p>Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles.</p>\n'),(7,'en','In enim justo','Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim.',''),(8,'de','Li Europan lingues es membres','Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular.','<p>Li nov lingua franca va esser plu simplic e regulari quam li existent Europan lingues. It va esser tam simplic quam Occidental in fact, it va esser Occidental. A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular.</p>\n\n<p>Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles.</p>\n'),(8,'en','In enim justo','Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim.',''),(9,'de','Li Europan lingues es membres','Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular.','<p>Li nov lingua franca va esser plu simplic e regulari quam li existent Europan lingues. It va esser tam simplic quam Occidental in fact, it va esser Occidental. A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular.</p>\n\n<p>Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles.</p>\n'),(9,'en','In enim justo','Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim.','');
/*!40000 ALTER TABLE `object_localized_data_2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_localized_data_5`
--

DROP TABLE IF EXISTS `object_localized_data_5`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_localized_data_5` (
  `ooo_id` int(11) NOT NULL DEFAULT '0',
  `language` varchar(10) NOT NULL DEFAULT '',
  `title` varchar(255) DEFAULT NULL,
  `text` longtext,
  `tags` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ooo_id`,`language`),
  KEY `ooo_id` (`ooo_id`),
  KEY `language` (`language`),
  KEY `p_index_tags` (`tags`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_localized_data_5`
--

LOCK TABLES `object_localized_data_5` WRITE;
/*!40000 ALTER TABLE `object_localized_data_5` DISABLE KEYS */;
INSERT INTO `object_localized_data_5` VALUES (35,'de','Maecenas nec odio et ante tincidunt tempus','<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue.</p>\n\n<p>Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus.</p>\n\n<p>Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetuer vestibulum elit. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Vestibulum fringilla pede sit amet augue. In turpis. Pellentesque posuere. Praesent turpis. Aenean posuere, tortor sed cursus feugiat, nunc augue blandit nunc, eu sollicitudin urna dolor sagittis lacus. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Nullam sagittis. Suspendisse pulvinar, augue ac venenatis condimentum, sem libero volutpat nibh, nec pellentesque velit pede quis nunc.</p>\n','Aenean Vestibulum Etiam Curabitur'),(35,'en','Maecenas nec odio et ante tincidunt tempus','<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue.</p>\n\n<p>Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus.</p>\n\n<p>Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetuer vestibulum elit. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Vestibulum fringilla pede sit amet augue. In turpis. Pellentesque posuere. Praesent turpis. Aenean posuere, tortor sed cursus feugiat, nunc augue blandit nunc, eu sollicitudin urna dolor sagittis lacus. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Nullam sagittis. Suspendisse pulvinar, augue ac venenatis condimentum, sem libero volutpat nibh, nec pellentesque velit pede quis nunc.</p>\n','Aenean Vestibulum Etiam Curabitur'),(39,'de','Lorem ipsum dolor sit amet','<p>Quisque id mi. Ut tincidunt tincidunt erat. Etiam feugiat lorem non metus. Vestibulum dapibus nunc ac augue. Curabitur vestibulum aliquam leo. Praesent egestas neque eu enim. In hac habitasse platea dictumst.</p>\n\n<p>Fusce a quam. Etiam ut purus mattis mauris sodales aliquam. Curabitur nisi. Quisque malesuada placerat nisl. Nam ipsum risus, rutrum vitae, vestibulum eu, molestie vel, lacus. Sed augue ipsum, egestas nec, vestibulum et, malesuada adipiscing, dui. Vestibulum facilisis, purus nec pulvinar iaculis, ligula mi congue nunc, vitae euismod ligula urna in dolor. Mauris sollicitudin fermentum libero. Praesent nonummy mi in odio. Nunc interdum lacus sit amet orci. Vestibulum rutrum, mi nec elementum vehicula, eros quam gravida nisl, id fringilla neque ante vel mi. Morbi mollis tellus ac sapien. Phasellus volutpat, metus eget egestas mollis, lacus lacus blandit dui, id egestas quam mauris ut lacus. Fusce vel dui. Sed in libero ut nibh placerat accumsan. Proin faucibus arcu quis ante.</p>\n\n<p>In consectetuer turpis ut velit. Nulla sit amet est. Praesent metus tellus, elementum eu, semper a, adipiscing nec, purus. Cras risus ipsum, faucibus ut, ullamcorper id, varius ac, leo. Suspendisse feugiat. Suspendisse enim turpis, dictum sed, iaculis a, condimentum nec, nisi. Praesent nec nisl a purus blandit viverra. Praesent ac massa at ligula laoreet iaculis. Nulla neque dolor, sagittis eget, iaculis quis, molestie non, velit. Mauris turpis nunc, blandit et, volutpat molestie, porta ut, ligula. Fusce pharetra convallis urna. Quisque ut nisi. Donec mi odio, faucibus at, scelerisque quis, convallis in, nisi. Suspendisse non nisl sit amet velit hendrerit rutrum. Ut leo. Ut a nisl id ante tempus hendrerit. Proin pretium, leo ac pellentesque mollis, felis nunc ultrices eros, sed gravida augue augue mollis justo. Suspendisse eu ligula. Nulla facilisi. Donec id justo. Praesent porttitor, nulla vitae posuere iaculis, arcu nisl dignissim dolor, a pretium mi sem ut ipsum. Curabitur suscipit suscipit tellus. Praesent vestibulum dapibus nibh. Etiam iaculis nunc ac metus. Ut id nisl quis enim dignissim sagittis. Etiam sollicitudin, ipsum eu pulvinar rutrum, tellus ipsum laoreet sapien, quis venenatis ante odio sit amet eros. Proin magna. Duis vel nibh at velit scelerisque suscipit. Curabitur turpis. Vestibulum suscipit nulla quis orci. Fusce ac felis sit amet ligula pharetra condimentum. Maecenas egestas arcu quis ligula mattis placerat. Duis lobortis massa imperdiet quam. Suspendisse potenti. Pellentesque commodo eros a enim. Vestibulum turpis sem, aliquet eget, lobortis pellentesque, rutrum eu, nisl. Sed libero. Aliquam erat volutpat. Etiam vitae tortor. Morbi vestibulum volutpat enim. Aliquam eu nunc. Nunc sed turpis. Sed mollis, eros et ultrices tempus, mauris ipsum aliquam libero, non adipiscing dolor urna a orci.</p>\n\n<p>Nulla porta dolor. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos. Pellentesque dapibus hendrerit tortor. Praesent egestas tristique nibh. Sed a libero. Cras varius. Donec vitae orci sed dolor rutrum auctor. Fusce egestas elit eget lorem. Suspendisse nisl elit, rhoncus eget, elementum ac, condimentum eget, diam. Nam at tortor in tellus interdum sagittis. Aliquam lobortis. Donec orci lectus, aliquam ut, faucibus non, euismod id, nulla.</p>\n\n<p>Curabitur blandit mollis lacus. Nam adipiscing. Vestibulum eu odio.</p>\n','Etiam Curabitur Fusce Quisque'),(39,'en','Lorem ipsum dolor sit amet','<p>Quisque id mi. Ut tincidunt tincidunt erat. Etiam feugiat lorem non metus. Vestibulum dapibus nunc ac augue. Curabitur vestibulum aliquam leo. Praesent egestas neque eu enim. In hac habitasse platea dictumst.</p>\n\n<p>Fusce a quam. Etiam ut purus mattis mauris sodales aliquam. Curabitur nisi. Quisque malesuada placerat nisl. Nam ipsum risus, rutrum vitae, vestibulum eu, molestie vel, lacus. Sed augue ipsum, egestas nec, vestibulum et, malesuada adipiscing, dui. Vestibulum facilisis, purus nec pulvinar iaculis, ligula mi congue nunc, vitae euismod ligula urna in dolor. Mauris sollicitudin fermentum libero. Praesent nonummy mi in odio. Nunc interdum lacus sit amet orci. Vestibulum rutrum, mi nec elementum vehicula, eros quam gravida nisl, id fringilla neque ante vel mi. Morbi mollis tellus ac sapien. Phasellus volutpat, metus eget egestas mollis, lacus lacus blandit dui, id egestas quam mauris ut lacus. Fusce vel dui. Sed in libero ut nibh placerat accumsan. Proin faucibus arcu quis ante.</p>\n\n<p>In consectetuer turpis ut velit. Nulla sit amet est. Praesent metus tellus, elementum eu, semper a, adipiscing nec, purus. Cras risus ipsum, faucibus ut, ullamcorper id, varius ac, leo. Suspendisse feugiat. Suspendisse enim turpis, dictum sed, iaculis a, condimentum nec, nisi. Praesent nec nisl a purus blandit viverra. Praesent ac massa at ligula laoreet iaculis. Nulla neque dolor, sagittis eget, iaculis quis, molestie non, velit. Mauris turpis nunc, blandit et, volutpat molestie, porta ut, ligula. Fusce pharetra convallis urna. Quisque ut nisi. Donec mi odio, faucibus at, scelerisque quis, convallis in, nisi. Suspendisse non nisl sit amet velit hendrerit rutrum. Ut leo. Ut a nisl id ante tempus hendrerit. Proin pretium, leo ac pellentesque mollis, felis nunc ultrices eros, sed gravida augue augue mollis justo. Suspendisse eu ligula. Nulla facilisi. Donec id justo. Praesent porttitor, nulla vitae posuere iaculis, arcu nisl dignissim dolor, a pretium mi sem ut ipsum. Curabitur suscipit suscipit tellus. Praesent vestibulum dapibus nibh. Etiam iaculis nunc ac metus. Ut id nisl quis enim dignissim sagittis. Etiam sollicitudin, ipsum eu pulvinar rutrum, tellus ipsum laoreet sapien, quis venenatis ante odio sit amet eros. Proin magna. Duis vel nibh at velit scelerisque suscipit. Curabitur turpis. Vestibulum suscipit nulla quis orci. Fusce ac felis sit amet ligula pharetra condimentum. Maecenas egestas arcu quis ligula mattis placerat. Duis lobortis massa imperdiet quam. Suspendisse potenti. Pellentesque commodo eros a enim. Vestibulum turpis sem, aliquet eget, lobortis pellentesque, rutrum eu, nisl. Sed libero. Aliquam erat volutpat. Etiam vitae tortor. Morbi vestibulum volutpat enim. Aliquam eu nunc. Nunc sed turpis. Sed mollis, eros et ultrices tempus, mauris ipsum aliquam libero, non adipiscing dolor urna a orci.</p>\n\n<p>Nulla porta dolor. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos. Pellentesque dapibus hendrerit tortor. Praesent egestas tristique nibh. Sed a libero. Cras varius. Donec vitae orci sed dolor rutrum auctor. Fusce egestas elit eget lorem. Suspendisse nisl elit, rhoncus eget, elementum ac, condimentum eget, diam. Nam at tortor in tellus interdum sagittis. Aliquam lobortis. Donec orci lectus, aliquam ut, faucibus non, euismod id, nulla.</p>\n\n<p>Curabitur blandit mollis lacus. Nam adipiscing. Vestibulum eu odio.</p>\n','Etiam Curabitur Fusce Quisque'),(40,'de','Cum sociis natoque penatibus et magnis','<p>Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem.</p>\n\n<p>Maecenas nec odio et ante tincidunt tempus. <strong>Donec vitae sapien</strong> ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui.</p>\n\n<p><img pimcore_id=\"21\" pimcore_type=\"asset\" src=\"/website/var/tmp/image-thumbnails/21/thumb__auto_850904660de984af948beee3aee98a4f/img_0037.jpeg\" style=\"width:600px;\" /></p>\n\n<p>Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus.</p>\n\n<hr />\n<p>Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetuer vestibulum elit. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Vestibulum fringilla pede sit amet augue. In turpis. Pellentesque posuere. Praesent turpis. Aenean posuere, tortor sed cursus feugiat, nunc augue blandit nunc, eu sollicitudin urna dolor sagittis lacus. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Nullam sagittis. Suspendisse pulvinar, augue ac venenatis condimentum, sem libero volutpat nibh, nec pellentesque velit pede quis nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce id purus. Ut varius tincidunt libero. Phasellus dolor.</p>\n\n<p>Maecenas vestibulum mollis diam. Pellentesque ut neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In dui magna, posuere eget, vestibulum et, tempor auctor, justo. In ac felis quis tortor malesuada pretium. Pellentesque auctor neque nec urna. Proin sapien ipsum, porta a, auctor quis, euismod ut, mi. Aenean viverra rhoncus pede. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.</p>\n','Fusce Quisque Maecenas Donec'),(40,'en','Cum sociis natoque penatibus et magnis','<p>Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem.</p>\n\n<p>Maecenas nec odio et ante tincidunt tempus. <strong>Donec vitae sapien</strong> ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui.</p>\n\n<p><img pimcore_id=\"21\" pimcore_type=\"asset\" src=\"/website/var/tmp/image-thumbnails/21/thumb__auto_850904660de984af948beee3aee98a4f/img_0037.jpeg\" style=\"width:600px;\" /></p>\n\n<p>Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus.</p>\n\n<hr />\n<p>Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetuer vestibulum elit. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Vestibulum fringilla pede sit amet augue. In turpis. Pellentesque posuere. Praesent turpis. Aenean posuere, tortor sed cursus feugiat, nunc augue blandit nunc, eu sollicitudin urna dolor sagittis lacus. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Nullam sagittis. Suspendisse pulvinar, augue ac venenatis condimentum, sem libero volutpat nibh, nec pellentesque velit pede quis nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce id purus. Ut varius tincidunt libero. Phasellus dolor.</p>\n\n<p>Maecenas vestibulum mollis diam. Pellentesque ut neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In dui magna, posuere eget, vestibulum et, tempor auctor, justo. In ac felis quis tortor malesuada pretium. Pellentesque auctor neque nec urna. Proin sapien ipsum, porta a, auctor quis, euismod ut, mi. Aenean viverra rhoncus pede. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.</p>\n','Fusce Quisque Maecenas Donec');
/*!40000 ALTER TABLE `object_localized_data_5` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_localized_data_6`
--

DROP TABLE IF EXISTS `object_localized_data_6`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_localized_data_6` (
  `ooo_id` int(11) NOT NULL DEFAULT '0',
  `language` varchar(10) NOT NULL DEFAULT '',
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ooo_id`,`language`),
  KEY `ooo_id` (`ooo_id`),
  KEY `language` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_localized_data_6`
--

LOCK TABLES `object_localized_data_6` WRITE;
/*!40000 ALTER TABLE `object_localized_data_6` DISABLE KEYS */;
INSERT INTO `object_localized_data_6` VALUES (36,'de','Curabitur ullamcorper'),(36,'en','Curabitur ullamcorper'),(37,'de','Nam eget dui'),(37,'en','Nam eget dui'),(38,'de','Etiam rhoncus'),(38,'en','Etiam rhoncus');
/*!40000 ALTER TABLE `object_localized_data_6` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_localized_query_2_de`
--

DROP TABLE IF EXISTS `object_localized_query_2_de`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_localized_query_2_de` (
  `ooo_id` int(11) NOT NULL DEFAULT '0',
  `language` varchar(10) NOT NULL DEFAULT '',
  `title` varchar(255) DEFAULT NULL,
  `shortText` longtext,
  `text` longtext,
  PRIMARY KEY (`ooo_id`,`language`),
  KEY `ooo_id` (`ooo_id`),
  KEY `language` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_localized_query_2_de`
--

LOCK TABLES `object_localized_query_2_de` WRITE;
/*!40000 ALTER TABLE `object_localized_query_2_de` DISABLE KEYS */;
INSERT INTO `object_localized_query_2_de` VALUES (3,'de','Er hörte leise Schritte hinter sich','Das bedeutete nichts Gutes. Wer würde ihm schon folgen, spät in der Nacht und dazu noch in dieser engen Gasse mitten im übel beleumundeten Hafenviertel?','Oder geh&ouml;rten die Schritte hinter ihm zu einem der unz&auml;hligen Gesetzesh&uuml;ter dieser Stadt, und die st&auml;hlerne Acht um seine Handgelenke w&uuml;rde gleich zuschnappen? Er konnte die Aufforderung stehen zu bleiben schon h&ouml;ren. Gehetzt sah er sich um. Pl&ouml;tzlich erblickte er den schmalen Durchgang. Blitzartig drehte er sich nach rechts und verschwand zwischen den beiden Geb&auml;uden. Beinahe w&auml;re er dabei &uuml;ber den umgest&uuml;rzten M&uuml;lleimer gefallen, der mitten im Weg lag. Er versuchte, sich in der Dunkelheit seinen Weg zu ertasten und erstarrte: Anscheinend gab es keinen anderen Ausweg aus diesem kleinen Hof als den Durchgang, durch den er gekommen war. Die Schritte wurden lauter und lauter, er sah eine dunkle Gestalt um die Ecke biegen. Fieberhaft irrten seine Augen durch die n&auml;chtliche Dunkelheit und suchten einen Ausweg. War jetzt wirklich alles vorbei. '),(4,'de','Li Europan lingues es membres','Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular.','Li nov lingua franca va esser plu simplic e regulari quam li existent Europan lingues. It va esser tam simplic quam Occidental in fact, it va esser Occidental. A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles. '),(5,'de','Zwei flinke Boxer jagen die quirlige Eva','Franz jagt im komplett verwahrlosten Taxi quer durch Bayern. Zwölf Boxkämpfer jagen Viktor quer über den großen Sylter Deich. Vogel Quax zwickt Johnys Pferd Bim.','Victor jagt zw&ouml;lf Boxk&auml;mpfer quer &uuml;ber den gro&szlig;en Sylter Deich. Falsches &Uuml;ben von Xylophonmusik qu&auml;lt jeden gr&ouml;&szlig;eren Zwerg. Heiz&ouml;lr&uuml;cksto&szlig;abd&auml;mpfung. Zwei flinke Boxer jagen die quirlige Eva und ihren Mops durch Sylt. Franz jagt im komplett verwahrlosten Taxi quer durch Bayern. Zw&ouml;lf Boxk&auml;mpfer jagen Viktor quer &uuml;ber den gro&szlig;en Sylter Deich. Vogel Quax zwickt Johnys Pferd Bim. Sylvia wagt quick den Jux bei Pforzheim. Polyfon zwitschernd a&szlig;en M&auml;xchens V&ouml;gel R&uuml;ben, Joghurt und Quark. &quot;Fix, Schwyz!&quot; qu&auml;kt J&uuml;rgen bl&ouml;d vom Pa&szlig;. Victor jagt zw&ouml;lf Boxk&auml;mpfer quer &uuml;ber den gro&szlig;en Sylter Deich. Falsches &Uuml;ben von Xylophonmusik qu&auml;lt jeden gr&ouml;&szlig;eren Zwerg. Heiz&ouml;lr&uuml;cksto&szlig;abd&auml;mpfung.Zwei flinke Boxer jagen die quirlige Eva und ihren Mops durch Sylt. Franz jagt im komplett verwahrlosten Taxi quer durch Bayern. Zw&ouml;lf Boxk&auml;mpfer jagen Viktor quer &uuml;ber den gro&szlig;en Sylter Deich. Vogel Quax zwickt Johnys Pferd Bim. Sylvia wagt quick den Jux '),(6,'de','Li Europan lingues es membres','Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular.','Li nov lingua franca va esser plu simplic e regulari quam li existent Europan lingues. It va esser tam simplic quam Occidental in fact, it va esser Occidental. A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles. '),(7,'de','Li Europan lingues es membres','Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular.','Li nov lingua franca va esser plu simplic e regulari quam li existent Europan lingues. It va esser tam simplic quam Occidental in fact, it va esser Occidental. A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles. '),(8,'de','Li Europan lingues es membres','Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular.','Li nov lingua franca va esser plu simplic e regulari quam li existent Europan lingues. It va esser tam simplic quam Occidental in fact, it va esser Occidental. A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles. '),(9,'de','Li Europan lingues es membres','Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular.','Li nov lingua franca va esser plu simplic e regulari quam li existent Europan lingues. It va esser tam simplic quam Occidental in fact, it va esser Occidental. A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles. ');
/*!40000 ALTER TABLE `object_localized_query_2_de` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_localized_query_2_en`
--

DROP TABLE IF EXISTS `object_localized_query_2_en`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_localized_query_2_en` (
  `ooo_id` int(11) NOT NULL DEFAULT '0',
  `language` varchar(10) NOT NULL DEFAULT '',
  `title` varchar(255) DEFAULT NULL,
  `shortText` longtext,
  `text` longtext,
  PRIMARY KEY (`ooo_id`,`language`),
  KEY `ooo_id` (`ooo_id`),
  KEY `language` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_localized_query_2_en`
--

LOCK TABLES `object_localized_query_2_en` WRITE;
/*!40000 ALTER TABLE `object_localized_query_2_en` DISABLE KEYS */;
INSERT INTO `object_localized_query_2_en` VALUES (3,'en','Lorem ipsum dolor sit amet','Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus.','Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam&nbsp;<a href=\"/en/basic-examples/content-page\" pimcore_id=\"24\" pimcore_type=\"document\">ultricies&nbsp;</a>nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget&nbsp;<a href=\"/en/basic-examples/galleries\" pimcore_id=\"19\" pimcore_type=\"document\">condimentum&nbsp;rhoncus</a>, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. '),(4,'en','In enim justo','Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim.','Nam eget dui. Etiam rhoncus.&nbsp;<a href=\"/en/basic-examples\" pimcore_id=\"3\" pimcore_type=\"document\">Maecenas&nbsp;tempus</a>, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. <a href=\"/en/basic-examples/news\" pimcore_id=\"27\" pimcore_type=\"document\">Donec vitae sapien</a> ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed&nbsp;fringilla&nbsp;mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, '),(5,'en','Nam eget dui','Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum.','Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, '),(6,'en','In enim justo','Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim.',''),(7,'en','In enim justo','Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim.',''),(8,'en','In enim justo','Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim.',''),(9,'en','In enim justo','Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim.','');
/*!40000 ALTER TABLE `object_localized_query_2_en` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_localized_query_5_de`
--

DROP TABLE IF EXISTS `object_localized_query_5_de`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_localized_query_5_de` (
  `ooo_id` int(11) NOT NULL DEFAULT '0',
  `language` varchar(10) NOT NULL DEFAULT '',
  `title` varchar(255) DEFAULT NULL,
  `text` longtext,
  `tags` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ooo_id`,`language`),
  KEY `ooo_id` (`ooo_id`),
  KEY `language` (`language`),
  KEY `p_index_tags` (`tags`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_localized_query_5_de`
--

LOCK TABLES `object_localized_query_5_de` WRITE;
/*!40000 ALTER TABLE `object_localized_query_5_de` DISABLE KEYS */;
INSERT INTO `object_localized_query_5_de` VALUES (35,'de','Maecenas nec odio et ante tincidunt tempus','Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetuer vestibulum elit. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Vestibulum fringilla pede sit amet augue. In turpis. Pellentesque posuere. Praesent turpis. Aenean posuere, tortor sed cursus feugiat, nunc augue blandit nunc, eu sollicitudin urna dolor sagittis lacus. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Nullam sagittis. Suspendisse pulvinar, augue ac venenatis condimentum, sem libero volutpat nibh, nec pellentesque velit pede quis nunc. ','Aenean Vestibulum Etiam Curabitur'),(39,'de','Lorem ipsum dolor sit amet','Quisque id mi. Ut tincidunt tincidunt erat. Etiam feugiat lorem non metus. Vestibulum dapibus nunc ac augue. Curabitur vestibulum aliquam leo. Praesent egestas neque eu enim. In hac habitasse platea dictumst. Fusce a quam. Etiam ut purus mattis mauris sodales aliquam. Curabitur nisi. Quisque malesuada placerat nisl. Nam ipsum risus, rutrum vitae, vestibulum eu, molestie vel, lacus. Sed augue ipsum, egestas nec, vestibulum et, malesuada adipiscing, dui. Vestibulum facilisis, purus nec pulvinar iaculis, ligula mi congue nunc, vitae euismod ligula urna in dolor. Mauris sollicitudin fermentum libero. Praesent nonummy mi in odio. Nunc interdum lacus sit amet orci. Vestibulum rutrum, mi nec elementum vehicula, eros quam gravida nisl, id fringilla neque ante vel mi. Morbi mollis tellus ac sapien. Phasellus volutpat, metus eget egestas mollis, lacus lacus blandit dui, id egestas quam mauris ut lacus. Fusce vel dui. Sed in libero ut nibh placerat accumsan. Proin faucibus arcu quis ante. In consectetuer turpis ut velit. Nulla sit amet est. Praesent metus tellus, elementum eu, semper a, adipiscing nec, purus. Cras risus ipsum, faucibus ut, ullamcorper id, varius ac, leo. Suspendisse feugiat. Suspendisse enim turpis, dictum sed, iaculis a, condimentum nec, nisi. Praesent nec nisl a purus blandit viverra. Praesent ac massa at ligula laoreet iaculis. Nulla neque dolor, sagittis eget, iaculis quis, molestie non, velit. Mauris turpis nunc, blandit et, volutpat molestie, porta ut, ligula. Fusce pharetra convallis urna. Quisque ut nisi. Donec mi odio, faucibus at, scelerisque quis, convallis in, nisi. Suspendisse non nisl sit amet velit hendrerit rutrum. Ut leo. Ut a nisl id ante tempus hendrerit. Proin pretium, leo ac pellentesque mollis, felis nunc ultrices eros, sed gravida augue augue mollis justo. Suspendisse eu ligula. Nulla facilisi. Donec id justo. Praesent porttitor, nulla vitae posuere iaculis, arcu nisl dignissim dolor, a pretium mi sem ut ipsum. Curabitur suscipit suscipit tellus. Praesent vestibulum dapibus nibh. Etiam iaculis nunc ac metus. Ut id nisl quis enim dignissim sagittis. Etiam sollicitudin, ipsum eu pulvinar rutrum, tellus ipsum laoreet sapien, quis venenatis ante odio sit amet eros. Proin magna. Duis vel nibh at velit scelerisque suscipit. Curabitur turpis. Vestibulum suscipit nulla quis orci. Fusce ac felis sit amet ligula pharetra condimentum. Maecenas egestas arcu quis ligula mattis placerat. Duis lobortis massa imperdiet quam. Suspendisse potenti. Pellentesque commodo eros a enim. Vestibulum turpis sem, aliquet eget, lobortis pellentesque, rutrum eu, nisl. Sed libero. Aliquam erat volutpat. Etiam vitae tortor. Morbi vestibulum volutpat enim. Aliquam eu nunc. Nunc sed turpis. Sed mollis, eros et ultrices tempus, mauris ipsum aliquam libero, non adipiscing dolor urna a orci. Nulla porta dolor. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos. Pellentesque dapibus hendrerit tortor. Praesent egestas tristique nibh. Sed a libero. Cras varius. Donec vitae orci sed dolor rutrum auctor. Fusce egestas elit eget lorem. Suspendisse nisl elit, rhoncus eget, elementum ac, condimentum eget, diam. Nam at tortor in tellus interdum sagittis. Aliquam lobortis. Donec orci lectus, aliquam ut, faucibus non, euismod id, nulla. Curabitur blandit mollis lacus. Nam adipiscing. Vestibulum eu odio. ','Etiam Curabitur Fusce Quisque'),(40,'de','Cum sociis natoque penatibus et magnis','Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. <img pimcore_id=\"21\" pimcore_type=\"asset\" src=\"/website/var/tmp/image-thumbnails/21/thumb__auto_850904660de984af948beee3aee98a4f/img_0037.jpeg\" style=\"width:600px;\" /> Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetuer vestibulum elit. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Vestibulum fringilla pede sit amet augue. In turpis. Pellentesque posuere. Praesent turpis. Aenean posuere, tortor sed cursus feugiat, nunc augue blandit nunc, eu sollicitudin urna dolor sagittis lacus. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Nullam sagittis. Suspendisse pulvinar, augue ac venenatis condimentum, sem libero volutpat nibh, nec pellentesque velit pede quis nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce id purus. Ut varius tincidunt libero. Phasellus dolor. Maecenas vestibulum mollis diam. Pellentesque ut neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In dui magna, posuere eget, vestibulum et, tempor auctor, justo. In ac felis quis tortor malesuada pretium. Pellentesque auctor neque nec urna. Proin sapien ipsum, porta a, auctor quis, euismod ut, mi. Aenean viverra rhoncus pede. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. ','Fusce Quisque Maecenas Donec');
/*!40000 ALTER TABLE `object_localized_query_5_de` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_localized_query_5_en`
--

DROP TABLE IF EXISTS `object_localized_query_5_en`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_localized_query_5_en` (
  `ooo_id` int(11) NOT NULL DEFAULT '0',
  `language` varchar(10) NOT NULL DEFAULT '',
  `title` varchar(255) DEFAULT NULL,
  `text` longtext,
  `tags` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ooo_id`,`language`),
  KEY `ooo_id` (`ooo_id`),
  KEY `language` (`language`),
  KEY `p_index_tags` (`tags`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_localized_query_5_en`
--

LOCK TABLES `object_localized_query_5_en` WRITE;
/*!40000 ALTER TABLE `object_localized_query_5_en` DISABLE KEYS */;
INSERT INTO `object_localized_query_5_en` VALUES (35,'en','Maecenas nec odio et ante tincidunt tempus','Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetuer vestibulum elit. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Vestibulum fringilla pede sit amet augue. In turpis. Pellentesque posuere. Praesent turpis. Aenean posuere, tortor sed cursus feugiat, nunc augue blandit nunc, eu sollicitudin urna dolor sagittis lacus. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Nullam sagittis. Suspendisse pulvinar, augue ac venenatis condimentum, sem libero volutpat nibh, nec pellentesque velit pede quis nunc. ','Aenean Vestibulum Etiam Curabitur'),(39,'en','Lorem ipsum dolor sit amet','Quisque id mi. Ut tincidunt tincidunt erat. Etiam feugiat lorem non metus. Vestibulum dapibus nunc ac augue. Curabitur vestibulum aliquam leo. Praesent egestas neque eu enim. In hac habitasse platea dictumst. Fusce a quam. Etiam ut purus mattis mauris sodales aliquam. Curabitur nisi. Quisque malesuada placerat nisl. Nam ipsum risus, rutrum vitae, vestibulum eu, molestie vel, lacus. Sed augue ipsum, egestas nec, vestibulum et, malesuada adipiscing, dui. Vestibulum facilisis, purus nec pulvinar iaculis, ligula mi congue nunc, vitae euismod ligula urna in dolor. Mauris sollicitudin fermentum libero. Praesent nonummy mi in odio. Nunc interdum lacus sit amet orci. Vestibulum rutrum, mi nec elementum vehicula, eros quam gravida nisl, id fringilla neque ante vel mi. Morbi mollis tellus ac sapien. Phasellus volutpat, metus eget egestas mollis, lacus lacus blandit dui, id egestas quam mauris ut lacus. Fusce vel dui. Sed in libero ut nibh placerat accumsan. Proin faucibus arcu quis ante. In consectetuer turpis ut velit. Nulla sit amet est. Praesent metus tellus, elementum eu, semper a, adipiscing nec, purus. Cras risus ipsum, faucibus ut, ullamcorper id, varius ac, leo. Suspendisse feugiat. Suspendisse enim turpis, dictum sed, iaculis a, condimentum nec, nisi. Praesent nec nisl a purus blandit viverra. Praesent ac massa at ligula laoreet iaculis. Nulla neque dolor, sagittis eget, iaculis quis, molestie non, velit. Mauris turpis nunc, blandit et, volutpat molestie, porta ut, ligula. Fusce pharetra convallis urna. Quisque ut nisi. Donec mi odio, faucibus at, scelerisque quis, convallis in, nisi. Suspendisse non nisl sit amet velit hendrerit rutrum. Ut leo. Ut a nisl id ante tempus hendrerit. Proin pretium, leo ac pellentesque mollis, felis nunc ultrices eros, sed gravida augue augue mollis justo. Suspendisse eu ligula. Nulla facilisi. Donec id justo. Praesent porttitor, nulla vitae posuere iaculis, arcu nisl dignissim dolor, a pretium mi sem ut ipsum. Curabitur suscipit suscipit tellus. Praesent vestibulum dapibus nibh. Etiam iaculis nunc ac metus. Ut id nisl quis enim dignissim sagittis. Etiam sollicitudin, ipsum eu pulvinar rutrum, tellus ipsum laoreet sapien, quis venenatis ante odio sit amet eros. Proin magna. Duis vel nibh at velit scelerisque suscipit. Curabitur turpis. Vestibulum suscipit nulla quis orci. Fusce ac felis sit amet ligula pharetra condimentum. Maecenas egestas arcu quis ligula mattis placerat. Duis lobortis massa imperdiet quam. Suspendisse potenti. Pellentesque commodo eros a enim. Vestibulum turpis sem, aliquet eget, lobortis pellentesque, rutrum eu, nisl. Sed libero. Aliquam erat volutpat. Etiam vitae tortor. Morbi vestibulum volutpat enim. Aliquam eu nunc. Nunc sed turpis. Sed mollis, eros et ultrices tempus, mauris ipsum aliquam libero, non adipiscing dolor urna a orci. Nulla porta dolor. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos. Pellentesque dapibus hendrerit tortor. Praesent egestas tristique nibh. Sed a libero. Cras varius. Donec vitae orci sed dolor rutrum auctor. Fusce egestas elit eget lorem. Suspendisse nisl elit, rhoncus eget, elementum ac, condimentum eget, diam. Nam at tortor in tellus interdum sagittis. Aliquam lobortis. Donec orci lectus, aliquam ut, faucibus non, euismod id, nulla. Curabitur blandit mollis lacus. Nam adipiscing. Vestibulum eu odio. ','Etiam Curabitur Fusce Quisque'),(40,'en','Cum sociis natoque penatibus et magnis','Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. <img pimcore_id=\"21\" pimcore_type=\"asset\" src=\"/website/var/tmp/image-thumbnails/21/thumb__auto_850904660de984af948beee3aee98a4f/img_0037.jpeg\" style=\"width:600px;\" /> Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetuer vestibulum elit. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Vestibulum fringilla pede sit amet augue. In turpis. Pellentesque posuere. Praesent turpis. Aenean posuere, tortor sed cursus feugiat, nunc augue blandit nunc, eu sollicitudin urna dolor sagittis lacus. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Nullam sagittis. Suspendisse pulvinar, augue ac venenatis condimentum, sem libero volutpat nibh, nec pellentesque velit pede quis nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce id purus. Ut varius tincidunt libero. Phasellus dolor. Maecenas vestibulum mollis diam. Pellentesque ut neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In dui magna, posuere eget, vestibulum et, tempor auctor, justo. In ac felis quis tortor malesuada pretium. Pellentesque auctor neque nec urna. Proin sapien ipsum, porta a, auctor quis, euismod ut, mi. Aenean viverra rhoncus pede. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. ','Fusce Quisque Maecenas Donec');
/*!40000 ALTER TABLE `object_localized_query_5_en` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_localized_query_6_de`
--

DROP TABLE IF EXISTS `object_localized_query_6_de`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_localized_query_6_de` (
  `ooo_id` int(11) NOT NULL DEFAULT '0',
  `language` varchar(10) NOT NULL DEFAULT '',
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ooo_id`,`language`),
  KEY `ooo_id` (`ooo_id`),
  KEY `language` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_localized_query_6_de`
--

LOCK TABLES `object_localized_query_6_de` WRITE;
/*!40000 ALTER TABLE `object_localized_query_6_de` DISABLE KEYS */;
INSERT INTO `object_localized_query_6_de` VALUES (36,'de','Curabitur ullamcorper'),(37,'de','Nam eget dui'),(38,'de','Etiam rhoncus');
/*!40000 ALTER TABLE `object_localized_query_6_de` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_localized_query_6_en`
--

DROP TABLE IF EXISTS `object_localized_query_6_en`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_localized_query_6_en` (
  `ooo_id` int(11) NOT NULL DEFAULT '0',
  `language` varchar(10) NOT NULL DEFAULT '',
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ooo_id`,`language`),
  KEY `ooo_id` (`ooo_id`),
  KEY `language` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_localized_query_6_en`
--

LOCK TABLES `object_localized_query_6_en` WRITE;
/*!40000 ALTER TABLE `object_localized_query_6_en` DISABLE KEYS */;
INSERT INTO `object_localized_query_6_en` VALUES (36,'en','Curabitur ullamcorper'),(37,'en','Nam eget dui'),(38,'en','Etiam rhoncus');
/*!40000 ALTER TABLE `object_localized_query_6_en` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_query_2`
--

DROP TABLE IF EXISTS `object_query_2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_query_2` (
  `oo_id` int(11) NOT NULL DEFAULT '0',
  `oo_classId` int(11) DEFAULT '2',
  `oo_className` varchar(255) DEFAULT 'news',
  `date` bigint(20) DEFAULT NULL,
  `image_1` int(11) DEFAULT NULL,
  `image_2` int(11) DEFAULT NULL,
  `image_3` int(11) DEFAULT NULL,
  PRIMARY KEY (`oo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_query_2`
--

LOCK TABLES `object_query_2` WRITE;
/*!40000 ALTER TABLE `object_query_2` DISABLE KEYS */;
INSERT INTO `object_query_2` VALUES (3,2,'news',1374147900,49,43,52),(4,2,'news',1369761300,51,0,0),(5,2,'news',1370037600,0,0,0),(6,2,'news',1354558500,25,0,0),(7,2,'news',1360606500,18,0,0),(8,2,'news',1360001700,20,0,0),(9,2,'news',1352830500,21,0,0);
/*!40000 ALTER TABLE `object_query_2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_query_3`
--

DROP TABLE IF EXISTS `object_query_3`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_query_3` (
  `oo_id` int(11) NOT NULL DEFAULT '0',
  `oo_classId` int(11) DEFAULT '3',
  `oo_className` varchar(255) DEFAULT 'inquiry',
  `person__id` int(11) DEFAULT NULL,
  `person__type` enum('document','asset','object') DEFAULT NULL,
  `date` bigint(20) DEFAULT NULL,
  `message` longtext,
  `terms` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`oo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_query_3`
--

LOCK TABLES `object_query_3` WRITE;
/*!40000 ALTER TABLE `object_query_3` DISABLE KEYS */;
INSERT INTO `object_query_3` VALUES (29,3,'inquiry',28,'object',1368630902,'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.',1),(31,3,'inquiry',30,'object',1368630916,'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.',1);
/*!40000 ALTER TABLE `object_query_3` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_query_4`
--

DROP TABLE IF EXISTS `object_query_4`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_query_4` (
  `oo_id` int(11) NOT NULL DEFAULT '0',
  `oo_classId` int(11) DEFAULT '4',
  `oo_className` varchar(255) DEFAULT 'persons',
  `gender` varchar(255) DEFAULT NULL,
  `firstname` varchar(255) DEFAULT NULL,
  `lastname` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `newsletterActive` tinyint(1) DEFAULT NULL,
  `newsletterConfirmed` tinyint(1) DEFAULT NULL,
  `dateRegister` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`oo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_query_4`
--

LOCK TABLES `object_query_4` WRITE;
/*!40000 ALTER TABLE `object_query_4` DISABLE KEYS */;
INSERT INTO `object_query_4` VALUES (28,4,'persons','male','John','Doe','john@doe.com',0,0,1368630902),(30,4,'persons','female','Jane','Doe','jane@doe.com',0,0,1368630916),(47,4,'persons','male','Demo','User','pimcore@byom.de',1,1,1388412534);
/*!40000 ALTER TABLE `object_query_4` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_query_5`
--

DROP TABLE IF EXISTS `object_query_5`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_query_5` (
  `oo_id` int(11) NOT NULL DEFAULT '0',
  `oo_classId` int(11) DEFAULT '5',
  `oo_className` varchar(255) DEFAULT 'blogArticle',
  `date` bigint(20) DEFAULT NULL,
  `categories` text,
  `posterImage__image` int(11) DEFAULT NULL,
  `posterImage__hotspots` text,
  PRIMARY KEY (`oo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_query_5`
--

LOCK TABLES `object_query_5` WRITE;
/*!40000 ALTER TABLE `object_query_5` DISABLE KEYS */;
INSERT INTO `object_query_5` VALUES (35,5,'blogArticle',1388649120,',37,38,',0,''),(39,5,'blogArticle',1389167640,',38,',23,'a:3:{s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}s:4:\"crop\";a:5:{s:9:\"cropWidth\";d:99.599999999999994;s:10:\"cropHeight\";d:50.133333333333333;s:7:\"cropTop\";d:15.733333333333333;s:8:\"cropLeft\";d:1.8;s:11:\"cropPercent\";b:1;}}'),(40,5,'blogArticle',1388390100,',36,',20,'a:3:{s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}s:4:\"crop\";a:5:{s:9:\"cropWidth\";d:98.799999999999997;s:10:\"cropHeight\";d:54.133333333333333;s:7:\"cropTop\";d:27.466666666666665;s:8:\"cropLeft\";i:2;s:11:\"cropPercent\";b:1;}}');
/*!40000 ALTER TABLE `object_query_5` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_query_6`
--

DROP TABLE IF EXISTS `object_query_6`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_query_6` (
  `oo_id` int(11) NOT NULL DEFAULT '0',
  `oo_classId` int(11) DEFAULT '6',
  `oo_className` varchar(255) DEFAULT 'blogCategory',
  PRIMARY KEY (`oo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_query_6`
--

LOCK TABLES `object_query_6` WRITE;
/*!40000 ALTER TABLE `object_query_6` DISABLE KEYS */;
INSERT INTO `object_query_6` VALUES (36,6,'blogCategory'),(37,6,'blogCategory'),(38,6,'blogCategory');
/*!40000 ALTER TABLE `object_query_6` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_relations_2`
--

DROP TABLE IF EXISTS `object_relations_2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_relations_2` (
  `src_id` int(11) NOT NULL DEFAULT '0',
  `dest_id` int(11) NOT NULL DEFAULT '0',
  `type` varchar(50) NOT NULL DEFAULT '',
  `fieldname` varchar(70) NOT NULL DEFAULT '0',
  `index` int(11) unsigned NOT NULL DEFAULT '0',
  `ownertype` enum('object','fieldcollection','localizedfield','objectbrick') NOT NULL DEFAULT 'object',
  `ownername` varchar(70) NOT NULL DEFAULT '',
  `position` varchar(70) NOT NULL DEFAULT '0',
  PRIMARY KEY (`src_id`,`dest_id`,`ownertype`,`ownername`,`fieldname`,`type`,`position`),
  KEY `index` (`index`),
  KEY `src_id` (`src_id`),
  KEY `dest_id` (`dest_id`),
  KEY `fieldname` (`fieldname`),
  KEY `position` (`position`),
  KEY `ownertype` (`ownertype`),
  KEY `type` (`type`),
  KEY `ownername` (`ownername`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_relations_2`
--

LOCK TABLES `object_relations_2` WRITE;
/*!40000 ALTER TABLE `object_relations_2` DISABLE KEYS */;
/*!40000 ALTER TABLE `object_relations_2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_relations_3`
--

DROP TABLE IF EXISTS `object_relations_3`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_relations_3` (
  `src_id` int(11) NOT NULL DEFAULT '0',
  `dest_id` int(11) NOT NULL DEFAULT '0',
  `type` varchar(50) NOT NULL DEFAULT '',
  `fieldname` varchar(70) NOT NULL DEFAULT '0',
  `index` int(11) unsigned NOT NULL DEFAULT '0',
  `ownertype` enum('object','fieldcollection','localizedfield','objectbrick') NOT NULL DEFAULT 'object',
  `ownername` varchar(70) NOT NULL DEFAULT '',
  `position` varchar(70) NOT NULL DEFAULT '0',
  PRIMARY KEY (`src_id`,`dest_id`,`ownertype`,`ownername`,`fieldname`,`type`,`position`),
  KEY `index` (`index`),
  KEY `src_id` (`src_id`),
  KEY `dest_id` (`dest_id`),
  KEY `fieldname` (`fieldname`),
  KEY `position` (`position`),
  KEY `ownertype` (`ownertype`),
  KEY `type` (`type`),
  KEY `ownername` (`ownername`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_relations_3`
--

LOCK TABLES `object_relations_3` WRITE;
/*!40000 ALTER TABLE `object_relations_3` DISABLE KEYS */;
INSERT INTO `object_relations_3` VALUES (29,28,'object','person',0,'object','','0'),(31,30,'object','person',0,'object','','0');
/*!40000 ALTER TABLE `object_relations_3` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_relations_4`
--

DROP TABLE IF EXISTS `object_relations_4`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_relations_4` (
  `src_id` int(11) NOT NULL DEFAULT '0',
  `dest_id` int(11) NOT NULL DEFAULT '0',
  `type` varchar(50) NOT NULL DEFAULT '',
  `fieldname` varchar(70) NOT NULL DEFAULT '0',
  `index` int(11) unsigned NOT NULL DEFAULT '0',
  `ownertype` enum('object','fieldcollection','localizedfield','objectbrick') NOT NULL DEFAULT 'object',
  `ownername` varchar(70) NOT NULL DEFAULT '',
  `position` varchar(70) NOT NULL DEFAULT '0',
  PRIMARY KEY (`src_id`,`dest_id`,`ownertype`,`ownername`,`fieldname`,`type`,`position`),
  KEY `index` (`index`),
  KEY `src_id` (`src_id`),
  KEY `dest_id` (`dest_id`),
  KEY `fieldname` (`fieldname`),
  KEY `position` (`position`),
  KEY `ownertype` (`ownertype`),
  KEY `type` (`type`),
  KEY `ownername` (`ownername`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_relations_4`
--

LOCK TABLES `object_relations_4` WRITE;
/*!40000 ALTER TABLE `object_relations_4` DISABLE KEYS */;
/*!40000 ALTER TABLE `object_relations_4` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_relations_5`
--

DROP TABLE IF EXISTS `object_relations_5`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_relations_5` (
  `src_id` int(11) NOT NULL DEFAULT '0',
  `dest_id` int(11) NOT NULL DEFAULT '0',
  `type` varchar(50) NOT NULL DEFAULT '',
  `fieldname` varchar(70) NOT NULL DEFAULT '0',
  `index` int(11) unsigned NOT NULL DEFAULT '0',
  `ownertype` enum('object','fieldcollection','localizedfield','objectbrick') NOT NULL DEFAULT 'object',
  `ownername` varchar(70) NOT NULL DEFAULT '',
  `position` varchar(70) NOT NULL DEFAULT '0',
  PRIMARY KEY (`src_id`,`dest_id`,`ownertype`,`ownername`,`fieldname`,`type`,`position`),
  KEY `index` (`index`),
  KEY `src_id` (`src_id`),
  KEY `dest_id` (`dest_id`),
  KEY `fieldname` (`fieldname`),
  KEY `position` (`position`),
  KEY `ownertype` (`ownertype`),
  KEY `type` (`type`),
  KEY `ownername` (`ownername`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_relations_5`
--

LOCK TABLES `object_relations_5` WRITE;
/*!40000 ALTER TABLE `object_relations_5` DISABLE KEYS */;
INSERT INTO `object_relations_5` VALUES (35,37,'object','categories',1,'object','','0'),(39,38,'object','categories',1,'object','','0'),(40,36,'object','categories',1,'object','','0'),(35,38,'object','categories',2,'object','','0');
/*!40000 ALTER TABLE `object_relations_5` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_relations_6`
--

DROP TABLE IF EXISTS `object_relations_6`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_relations_6` (
  `src_id` int(11) NOT NULL DEFAULT '0',
  `dest_id` int(11) NOT NULL DEFAULT '0',
  `type` varchar(50) NOT NULL DEFAULT '',
  `fieldname` varchar(70) NOT NULL DEFAULT '0',
  `index` int(11) unsigned NOT NULL DEFAULT '0',
  `ownertype` enum('object','fieldcollection','localizedfield','objectbrick') NOT NULL DEFAULT 'object',
  `ownername` varchar(70) NOT NULL DEFAULT '',
  `position` varchar(70) NOT NULL DEFAULT '0',
  PRIMARY KEY (`src_id`,`dest_id`,`ownertype`,`ownername`,`fieldname`,`type`,`position`),
  KEY `index` (`index`),
  KEY `src_id` (`src_id`),
  KEY `dest_id` (`dest_id`),
  KEY `fieldname` (`fieldname`),
  KEY `position` (`position`),
  KEY `ownertype` (`ownertype`),
  KEY `type` (`type`),
  KEY `ownername` (`ownername`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_relations_6`
--

LOCK TABLES `object_relations_6` WRITE;
/*!40000 ALTER TABLE `object_relations_6` DISABLE KEYS */;
/*!40000 ALTER TABLE `object_relations_6` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_store_2`
--

DROP TABLE IF EXISTS `object_store_2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_store_2` (
  `oo_id` int(11) NOT NULL DEFAULT '0',
  `date` bigint(20) DEFAULT NULL,
  `image_1` int(11) DEFAULT NULL,
  `image_2` int(11) DEFAULT NULL,
  `image_3` int(11) DEFAULT NULL,
  PRIMARY KEY (`oo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_store_2`
--

LOCK TABLES `object_store_2` WRITE;
/*!40000 ALTER TABLE `object_store_2` DISABLE KEYS */;
INSERT INTO `object_store_2` VALUES (3,1374147900,49,43,52),(4,1369761300,51,0,0),(5,1370037600,0,0,0),(6,1354558500,25,0,0),(7,1360606500,18,0,0),(8,1360001700,20,0,0),(9,1352830500,21,0,0);
/*!40000 ALTER TABLE `object_store_2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_store_3`
--

DROP TABLE IF EXISTS `object_store_3`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_store_3` (
  `oo_id` int(11) NOT NULL DEFAULT '0',
  `date` bigint(20) DEFAULT NULL,
  `message` longtext,
  `terms` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`oo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_store_3`
--

LOCK TABLES `object_store_3` WRITE;
/*!40000 ALTER TABLE `object_store_3` DISABLE KEYS */;
INSERT INTO `object_store_3` VALUES (29,1368630902,'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.',1),(31,1368630916,'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.',1);
/*!40000 ALTER TABLE `object_store_3` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_store_4`
--

DROP TABLE IF EXISTS `object_store_4`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_store_4` (
  `oo_id` int(11) NOT NULL DEFAULT '0',
  `gender` varchar(255) DEFAULT NULL,
  `firstname` varchar(255) DEFAULT NULL,
  `lastname` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `newsletterActive` tinyint(1) DEFAULT NULL,
  `newsletterConfirmed` tinyint(1) DEFAULT NULL,
  `dateRegister` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`oo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_store_4`
--

LOCK TABLES `object_store_4` WRITE;
/*!40000 ALTER TABLE `object_store_4` DISABLE KEYS */;
INSERT INTO `object_store_4` VALUES (28,'male','John','Doe','john@doe.com',0,0,1368630902),(30,'female','Jane','Doe','jane@doe.com',0,0,1368630916),(47,'male','Demo','User','pimcore@byom.de',1,1,1388412534);
/*!40000 ALTER TABLE `object_store_4` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_store_5`
--

DROP TABLE IF EXISTS `object_store_5`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_store_5` (
  `oo_id` int(11) NOT NULL DEFAULT '0',
  `date` bigint(20) DEFAULT NULL,
  `posterImage__image` int(11) DEFAULT NULL,
  `posterImage__hotspots` text,
  PRIMARY KEY (`oo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_store_5`
--

LOCK TABLES `object_store_5` WRITE;
/*!40000 ALTER TABLE `object_store_5` DISABLE KEYS */;
INSERT INTO `object_store_5` VALUES (35,1388649120,0,''),(39,1389167640,23,'a:3:{s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}s:4:\"crop\";a:5:{s:9:\"cropWidth\";d:99.599999999999994;s:10:\"cropHeight\";d:50.133333333333333;s:7:\"cropTop\";d:15.733333333333333;s:8:\"cropLeft\";d:1.8;s:11:\"cropPercent\";b:1;}}'),(40,1388390100,20,'a:3:{s:8:\"hotspots\";a:0:{}s:6:\"marker\";a:0:{}s:4:\"crop\";a:5:{s:9:\"cropWidth\";d:98.799999999999997;s:10:\"cropHeight\";d:54.133333333333333;s:7:\"cropTop\";d:27.466666666666665;s:8:\"cropLeft\";i:2;s:11:\"cropPercent\";b:1;}}');
/*!40000 ALTER TABLE `object_store_5` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_store_6`
--

DROP TABLE IF EXISTS `object_store_6`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_store_6` (
  `oo_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`oo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_store_6`
--

LOCK TABLES `object_store_6` WRITE;
/*!40000 ALTER TABLE `object_store_6` DISABLE KEYS */;
INSERT INTO `object_store_6` VALUES (36),(37),(38);
/*!40000 ALTER TABLE `object_store_6` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `objects`
--

DROP TABLE IF EXISTS `objects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `objects` (
  `o_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `o_parentId` int(11) unsigned DEFAULT NULL,
  `o_type` enum('object','folder','variant') DEFAULT NULL,
  `o_key` varchar(255) DEFAULT '',
  `o_path` varchar(765) CHARACTER SET ascii DEFAULT NULL,
  `o_index` int(11) unsigned DEFAULT '0',
  `o_published` tinyint(1) unsigned DEFAULT '1',
  `o_creationDate` bigint(20) unsigned DEFAULT NULL,
  `o_modificationDate` bigint(20) unsigned DEFAULT NULL,
  `o_userOwner` int(11) unsigned DEFAULT NULL,
  `o_userModification` int(11) unsigned DEFAULT NULL,
  `o_classId` int(11) unsigned DEFAULT NULL,
  `o_className` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`o_id`),
  UNIQUE KEY `fullpath` (`o_path`,`o_key`),
  KEY `key` (`o_key`),
  KEY `path` (`o_path`),
  KEY `published` (`o_published`),
  KEY `parentId` (`o_parentId`),
  KEY `type` (`o_type`),
  KEY `o_modificationDate` (`o_modificationDate`)
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `objects`
--

LOCK TABLES `objects` WRITE;
/*!40000 ALTER TABLE `objects` DISABLE KEYS */;
INSERT INTO `objects` VALUES (1,0,'folder','','/',999999,1,1368522989,1368522989,1,1,0,''),(2,1,'folder','news','/',0,1,1368613451,1368613451,0,0,0,''),(3,2,'object','lorem-ipsum','/news/',0,1,1368613483,1382958769,0,0,2,'news'),(4,2,'object','in-enim-justo','/news/',0,1,1368613645,1382958711,0,0,2,'news'),(5,2,'object','nam-eget-dui','/news/',0,1,1368613700,1382958801,0,0,2,'news'),(6,2,'object','in-enim-justo_2','/news/',0,1,1368615188,1382958710,0,0,2,'news'),(7,2,'object','in-enim-justo_3','/news/',0,1,1368615191,1382958709,0,0,2,'news'),(8,2,'object','in-enim-justo_4','/news/',0,1,1368615194,1382958708,0,0,2,'news'),(9,2,'object','in-enim-justo_5','/news/',0,1,1368615197,1382958706,0,0,2,'news'),(10,1,'folder','crm','/',0,1,1368620607,1368620607,0,0,0,''),(11,1,'folder','inquiries','/',0,1,1368620624,1368620624,0,0,0,''),(28,42,'object','john-doe.com','/crm/inquiries/',0,1,1368630902,1388409139,0,0,4,'person'),(29,11,'object','may-15-2013-5-15-02-pm~john-doe.com','/inquiries/',0,1,1368630902,1368630902,0,0,3,'inquiry'),(30,42,'object','jane-doe.com','/crm/inquiries/',0,1,1368630916,1388409137,0,0,4,'person'),(31,11,'object','may-15-2013-5-15-16-pm~jane-doe.com','/inquiries/',0,1,1368630916,1368630916,0,0,3,'inquiry'),(32,1,'folder','blog','/',0,1,1388389170,1388389170,7,7,0,''),(33,32,'folder','categories','/blog/',0,1,1388389428,1388389428,7,7,0,''),(34,32,'folder','articles','/blog/',0,1,1388389435,1388389435,7,7,0,''),(35,34,'object','maecenas-nec-odio','/blog/articles/',0,1,1388389641,1388393754,7,7,5,'blogArticle'),(36,33,'object','curabitur-ullamcorper','/blog/categories/',0,1,1388389865,1388389870,7,7,6,'blogCategory'),(37,33,'object','nam-eget-dui','/blog/categories/',0,1,1388389881,1388393730,7,7,6,'blogCategory'),(38,33,'object','etiam-rhoncus','/blog/categories/',0,1,1388389892,1388389900,7,7,6,'blogCategory'),(39,34,'object','lorem-ipsum-dolor-sit-amet','/blog/articles/',0,1,1388390090,1388393711,7,7,5,'blogArticle'),(40,34,'object','cum-sociis-natoque-penatibus-et-magnis','/blog/articles/',0,1,1388390120,1388393706,7,7,5,'blogArticle'),(41,10,'folder','newsletter','/crm/',0,1,1388408967,1388408967,0,0,0,''),(42,10,'folder','inquiries','/crm/',0,1,1388409135,1388409135,0,0,0,''),(47,41,'object','pimcore-byom.de~7a3','/crm/newsletter/',0,1,1388412533,1388412544,0,0,4,'person');
/*!40000 ALTER TABLE `objects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `properties`
--

DROP TABLE IF EXISTS `properties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `properties` (
  `cid` int(11) unsigned NOT NULL DEFAULT '0',
  `ctype` enum('document','asset','object') NOT NULL DEFAULT 'document',
  `cpath` varchar(765) CHARACTER SET ascii DEFAULT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `type` enum('text','document','asset','object','bool','select') DEFAULT NULL,
  `data` text,
  `inheritable` tinyint(1) unsigned DEFAULT '1',
  PRIMARY KEY (`cid`,`ctype`,`name`),
  KEY `cpath` (`cpath`),
  KEY `inheritable` (`inheritable`),
  KEY `ctype` (`ctype`),
  KEY `cid` (`cid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `properties`
--

LOCK TABLES `properties` WRITE;
/*!40000 ALTER TABLE `properties` DISABLE KEYS */;
INSERT INTO `properties` VALUES (1,'document','/','blog','document','60',1),(1,'document','/','language','text','en',1),(1,'document','/','leftNavStartNode','document','40',1),(1,'document','/','mainNavStartNode','document','40',1),(1,'document','/','navigation_name','text','Home',0),(1,'document','/','sidebar','document','57',1),(3,'document','/en/basic-examples','leftNavStartNode','document','3',1),(3,'document','/en/basic-examples','navigation_name','text','Basic Examples',0),(4,'document','/en/introduction','navigation_name','text','Introduction',0),(4,'document','/en/introduction','sidebar','document','59',1),(5,'document','/en/advanced-examples','leftNavStartNode','document','5',1),(5,'document','/en/advanced-examples','navigation_name','text','Advanced Examples',0),(5,'document','/en/advanced-examples','sidebar','document','69',1),(6,'document','/en/experiments','navigation_name','text','Experiments',0),(7,'document','/en/basic-examples/html5-video','navigation_name','text','HTML5 Video',0),(9,'document','/en/advanced-examples/creating-objects-using-forms','navigation_name','text','Creating Objects with a Form',0),(18,'document','/en/basic-examples/pdf-viewer','navigation_name','text','Document Viewer',0),(19,'document','/en/basic-examples/galleries','navigation_name','text','Galleries',0),(20,'document','/en/basic-examples/glossary','navigation_name','text','Glossary',0),(21,'document','/en/basic-examples/thumbnails','navigation_name','text','Thumbnails',0),(22,'document','/en/basic-examples/website-translations','navigation_name','text','Website Translations',0),(23,'document','/de/einfache-beispiele/website-uebersetzungen','language','text','de',1),(23,'document','/de/einfache-beispiele/website-uebersetzungen','navigation_name','text','Website Übersetzungen',0),(24,'document','/en/basic-examples/content-page','navigation_name','text','Content Page',0),(25,'document','/en/basic-examples/editable-roundup','navigation_name','text','Editable Round-Up',0),(26,'document','/en/basic-examples/form','navigation_name','text','Simple Form',0),(27,'document','/en/basic-examples/news','navigation_name','text','News',0),(28,'document','/en/basic-examples/properties','headerColor','select','blue',1),(28,'document','/en/basic-examples/properties','leftNavHide','bool','1',0),(28,'document','/en/basic-examples/properties','navigation_name','text','Properties',0),(29,'document','/en/basic-examples/tag-and-snippet-management','navigation_name','text','Tag & Snippet Management',0),(30,'document','/en/advanced-examples/content-inheritance','navigation_name','text','Content Inheritance',0),(31,'document','/en/advanced-examples/content-inheritance/content-inheritance','navigation_name','text','Slave Document',0),(32,'document','/en/basic-examples/pimcore.org','navigation_name','text','External Link',0),(32,'document','/en/basic-examples/pimcore.org','navigation_target','text','_blank',0),(33,'document','/en/advanced-examples/hard-link/basic-examples','leftNavStartNode','document','5',1),(34,'document','/en/advanced-examples/hard-link','navigation_name','text','Hard Link',0),(35,'document','/en/advanced-examples/image-with-hotspots-and-markers','navigation_name','text','Image with Hotspots',0),(36,'document','/en/advanced-examples/search','navigation_name','text','Search',0),(36,'asset','/documents/documentation.pdf','document_page_count','text','39',0),(37,'document','/en/advanced-examples/contact-form','email','document','38',1),(37,'document','/en/advanced-examples/contact-form','navigation_name','text','Contact Form',0),(40,'document','/en','navigation_name','text','Home',0),(41,'document','/de','language','text','de',1),(41,'document','/de','leftNavStartNode','document','41',1),(41,'document','/de','mainNavStartNode','document','41',1),(41,'document','/de','navigation_name','text','Startseite',0),(41,'document','/de','sidebar','document','58',1),(47,'object','/crm/newsletter/pimcore-byom.de~7a3','token','text','YTozOntzOjQ6InNhbHQiO3M6MzI6IjNlMGRkYTk3MWU1YTY5MWViYmM0OGVkNGQ5NzA4MDFmIjtzOjU6ImVtYWlsIjtzOjE1OiJwaW1jb3JlQGJ5b20uZGUiO3M6MjoiaWQiO2k6NDc7fQ==',0),(50,'document','/de/einfuehrung','navigation_name','text','Einführung',0),(51,'document','/de/einfache-beispiele','navigation_name','text','Einfache Beispiele',1),(52,'document','/de/beispiele-fur-fortgeschrittene','navigation_name','text','Beispiele für Fortgeschrittene',1),(53,'document','/de/einfache-beispiele/neuigkeiten','navigation_name','text','Neuigkeiten',0),(60,'document','/en/advanced-examples/blog','navigation_name','text','Blog',0),(61,'document','/en/advanced-examples/sitemap','navigation_name','text','Sitemap',1),(63,'document','/en/advanced-examples/newsletter','navigation_name','text','Newsletter',1),(64,'document','/en/advanced-examples/newsletter/confirm','navigation_name','text','',1),(65,'document','/en/advanced-examples/newsletter/unsubscribe','navigation_name','text','Unsubscribe',1),(68,'document','/en/advanced-examples/asset-thumbnail-list','navigation_name','text','Asset Thumbnail List',1),(70,'document','/en/advanced-examples/product-information-management','navigation_name','text','Product Information Management',0),(71,'document','/en/advanced-examples/e-commerce','navigation_name','text','E-Commerce',1),(72,'document','/en/advanced-examples/sub-modules','navigation_exclude','text','',0),(72,'document','/en/advanced-examples/sub-modules','navigation_name','text','Sub-Modules',0),(72,'document','/en/advanced-examples/sub-modules','navigation_target','text','',0),(72,'document','/en/advanced-examples/sub-modules','navigation_title','text','',0);
/*!40000 ALTER TABLE `properties` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quantityvalue_units`
--

DROP TABLE IF EXISTS `quantityvalue_units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quantityvalue_units` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `group` varchar(50) COLLATE utf8_bin DEFAULT NULL,
  `abbreviation` varchar(10) COLLATE utf8_bin NOT NULL,
  `longname` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `baseunit` varchar(10) COLLATE utf8_bin DEFAULT NULL,
  `factor` double DEFAULT NULL,
  `conversionOffset` double DEFAULT NULL,
  `reference` varchar(50) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quantityvalue_units`
--

LOCK TABLES `quantityvalue_units` WRITE;
/*!40000 ALTER TABLE `quantityvalue_units` DISABLE KEYS */;
/*!40000 ALTER TABLE `quantityvalue_units` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recyclebin`
--

DROP TABLE IF EXISTS `recyclebin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recyclebin` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(20) DEFAULT NULL,
  `subtype` varchar(20) DEFAULT NULL,
  `path` varchar(765) DEFAULT NULL,
  `amount` int(3) DEFAULT NULL,
  `date` bigint(20) DEFAULT NULL,
  `deletedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recyclebin`
--

LOCK TABLES `recyclebin` WRITE;
/*!40000 ALTER TABLE `recyclebin` DISABLE KEYS */;
/*!40000 ALTER TABLE `recyclebin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `redirects`
--

DROP TABLE IF EXISTS `redirects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `redirects` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `source` varchar(255) DEFAULT NULL,
  `sourceEntireUrl` tinyint(1) DEFAULT NULL,
  `sourceSite` int(11) DEFAULT NULL,
  `passThroughParameters` tinyint(1) DEFAULT NULL,
  `target` varchar(255) DEFAULT NULL,
  `targetSite` int(11) DEFAULT NULL,
  `statusCode` varchar(3) DEFAULT NULL,
  `priority` int(2) DEFAULT '0',
  `expiry` bigint(20) DEFAULT NULL,
  `creationDate` bigint(20) unsigned DEFAULT '0',
  `modificationDate` bigint(20) unsigned DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `priority` (`priority`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `redirects`
--

LOCK TABLES `redirects` WRITE;
/*!40000 ALTER TABLE `redirects` DISABLE KEYS */;
/*!40000 ALTER TABLE `redirects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sanitycheck`
--

DROP TABLE IF EXISTS `sanitycheck`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sanitycheck` (
  `id` int(11) unsigned NOT NULL,
  `type` enum('document','asset','object') NOT NULL,
  PRIMARY KEY (`id`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sanitycheck`
--

LOCK TABLES `sanitycheck` WRITE;
/*!40000 ALTER TABLE `sanitycheck` DISABLE KEYS */;
/*!40000 ALTER TABLE `sanitycheck` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schedule_tasks`
--

DROP TABLE IF EXISTS `schedule_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schedule_tasks` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `cid` int(11) unsigned DEFAULT NULL,
  `ctype` enum('document','asset','object') DEFAULT NULL,
  `date` bigint(20) unsigned DEFAULT NULL,
  `action` enum('publish','unpublish','delete','publish-version') DEFAULT NULL,
  `version` bigint(20) unsigned DEFAULT NULL,
  `active` tinyint(1) unsigned DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `cid` (`cid`),
  KEY `ctype` (`ctype`),
  KEY `active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schedule_tasks`
--

LOCK TABLES `schedule_tasks` WRITE;
/*!40000 ALTER TABLE `schedule_tasks` DISABLE KEYS */;
/*!40000 ALTER TABLE `schedule_tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `search_backend_data`
--

DROP TABLE IF EXISTS `search_backend_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `search_backend_data` (
  `id` int(11) NOT NULL,
  `fullpath` varchar(765) CHARACTER SET ascii DEFAULT NULL,
  `maintype` varchar(8) NOT NULL DEFAULT '',
  `type` varchar(20) DEFAULT NULL,
  `subtype` varchar(255) DEFAULT NULL,
  `published` bigint(20) DEFAULT NULL,
  `creationDate` bigint(20) DEFAULT NULL,
  `modificationDate` bigint(20) DEFAULT NULL,
  `userOwner` int(11) DEFAULT NULL,
  `userModification` int(11) DEFAULT NULL,
  `data` longtext,
  `properties` text,
  PRIMARY KEY (`id`,`maintype`),
  KEY `id` (`id`),
  KEY `fullpath` (`fullpath`),
  KEY `maintype` (`maintype`),
  KEY `type` (`type`),
  KEY `subtype` (`subtype`),
  KEY `published` (`published`),
  FULLTEXT KEY `data` (`data`),
  FULLTEXT KEY `properties` (`properties`),
  FULLTEXT KEY `fulltext` (`data`,`properties`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `search_backend_data`
--

LOCK TABLES `search_backend_data` WRITE;
/*!40000 ALTER TABLE `search_backend_data` DISABLE KEYS */;
INSERT INTO `search_backend_data` VALUES (1,'/','asset','folder','folder',1,1368522989,1368522989,1,1,'ID: 1  \nPath: /  \n',''),(1,'/','document','page','page',1,1368522989,1395151306,1,0,'ID: 1  \nPath: /  \nAlbert Einstein Isla Colón, Bocas del Toro, Republic of Panama Bocas del Toro 3 Ready to be impressed? It\'ll blow your mind. Oh yeah, it\'s that good See it in Action See it in Action Checkmate In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Donec ullamcorper nulla non metus auctor fringilla. Vestibulum id ligula porta felis euismod semper. Praesent commodo cursus magna, vel scelerisque nisl consectetur. Fusce dapibus, tellus ac cursus commodo. Donec ullamcorper nulla non metus auctor fringilla. Vestibulum id ligula porta felis euismod semper. Praesent commodo cursus magna, vel scelerisque nisl consectetur. Fusce dapibus, tellus ac cursus commodo. Check out our examples and dive into the next generation of digital data management. See for yourself. See for yourself pimcore is the only open-source multi-channel experience and engagement management platform available. With complete creative freedom, flexibility, and agility, pimcore is a dream come true for designers and developers. pimcore makes it easier to manage large international sites with key features like advanced content reuse, inheritance, and distribution. pimcore is based on UTF-8 standards and is compatible to any language including Right-to-Left (RTL). Good looking and completely custom galleries Lorem ipsum. Oh yeah, it\'s that good. And lastly, this one. About Us 100% Flexible 100% Editable International and Multi-site phone bullhorn screenshot left Are integrated within minutes Read More Read More Read More What is pimcore? and enjoy creative freedom 中國人嗎？沒問題。 About us Think different International and Multi-site left We can\'t solve problems by using the same kind of thinking we used when we created them. 1 3 3 Cum sociis. See for yourself. Checkmate. This demo is based on the Bootstrap framework which is the most popular, intuitive and powerful front-end framework available. HTML5, Javascript, CSS3, jQuery as well as concepts like responsive, mobile-apps or non-linear design-patterns. Content is created by simply dragging &amp; dropping blocks, that can be editited in-place and wysiwyg in a very intuitive and comfortable way. Fully Responsive 100% Buzzword Compatible Drag & Drop Interface video ','navigation_name:Home sidebar:/en/sidebar mainNavStartNode:/en leftNavStartNode:/en language:en blog:/en/advanced-examples/blog '),(1,'/','object','folder','folder',1,1368522989,1368522989,1,1,'ID: 1  \nPath: /  \n',''),(2,'/news','object','folder','folder',1,1368613451,1368613451,0,0,'ID: 2  \nPath: /news  \nnews',''),(3,'/portal-sujets','asset','folder','folder',1,1368530371,1368632469,0,0,'ID: 3  \nPath: /portal-sujets  \nportal-sujets',''),(3,'/en/basic-examples','document','page','page',1,1368523212,1388738504,0,0,'ID: 3  \nPath: /en/basic-examples  \n 1 1 1 1 1 1 Basic Examples HTML5 Video Glossary Simple Content News PDF Viewer Thumbnails Round-Up Properties Galleries Website Translations Simple Form Tag Manager See it in Action See it in Action See it in Action See it in Action See it in Action See it in Action See it in Action See it in Action See it in Action See it in Action See it in Action Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. direct direct direct direct direct direct direct direct direct direct direct direct ','sidebar:/en/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/basic-examples language:en navigation_name:Basic Examples '),(3,'/news/lorem-ipsum','object','object','news',1,1368613483,1382958769,0,0,'ID: 3  \nPath: /news/lorem-ipsum  \nEr hörte leise Schritte hinter sich Das bedeutete nichts Gutes. Wer würde ihm schon folgen, spät in der Nacht und dazu noch in dieser engen Gasse mitten im übel beleumundeten Hafenviertel? Oder geh&ouml;rten die Schritte hinter ihm zu einem der unz&auml;hligen Gesetzesh&uuml;ter dieser Stadt, und die st&auml;hlerne Acht um seine Handgelenke w&uuml;rde gleich zuschnappen? Er konnte die Aufforderung stehen zu bleiben schon h&ouml;ren. Gehetzt sah er sich um. Pl&ouml;tzlich erblickte er den schmalen Durchgang. Blitzartig drehte er sich nach rechts und verschwand zwischen den beiden Geb&auml;uden. Beinahe w&auml;re er dabei &uuml;ber den umgest&uuml;rzten M&uuml;lleimer gefallen, der mitten im Weg lag. Er versuchte, sich in der Dunkelheit seinen Weg zu ertasten und erstarrte: Anscheinend gab es keinen anderen Ausweg aus diesem kleinen Hof als den Durchgang, durch den er gekommen war. Die Schritte wurden lauter und lauter, er sah eine dunkle Gestalt um die Ecke biegen. Fieberhaft irrten seine Augen durch die n&auml;chtliche Dunkelheit und suchten einen Ausweg. War jetzt wirklich alles vorbei. Lorem ipsum dolor sit amet Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam&nbsp;ultricies&nbsp;nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget&nbsp;condimentum&nbsp;rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Jul 18, 2013 1:45:00 PM /examples/south-africa/img_2155.jpg /examples/south-africa/img_1414.jpg /examples/south-africa/img_1920.jpg ',''),(4,'/portal-sujets/slide-01.jpg','asset','image','image',1,1368530684,1370432846,0,0,'ID: 4  \nPath: /portal-sujets/slide-01.jpg  \nslide-01.jpg',''),(4,'/en/introduction','document','page','page',1,1368523285,1395042868,0,0,'ID: 4  \nPath: /en/introduction  \n Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. &nbsp; Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. &nbsp; Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles. &nbsp; It va esser tam simplic quam Occidental in fact, it va esser Occidental. A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es. Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. &nbsp; Donec ullamcorper nulla non metus auctor fringilla. Vestibulum id ligula porta felis euismod semper. Praesent commodo cursus magna, vel scelerisque nisl consectetur. Fusce dapibus, tellus ac cursus commodo. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Overview of the project and how to get started with a simple template. Introduction Maecenas tempus, tellus eget condimentum rhoncu Ullamcorper Scelerisque Getting started Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Etiam rhoncu Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. snippet snippet ','sidebar:/en/introduction/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en language:en navigation_name:Introduction '),(4,'/news/in-enim-justo','object','object','news',1,1368613645,1382958711,0,0,'ID: 4  \nPath: /news/in-enim-justo  \nLi Europan lingues es membres Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li nov lingua franca va esser plu simplic e regulari quam li existent Europan lingues. It va esser tam simplic quam Occidental in fact, it va esser Occidental. A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles. In enim justo Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Nam eget dui. Etiam rhoncus.&nbsp;Maecenas&nbsp;tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed&nbsp;fringilla&nbsp;mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, May 28, 2013 7:15:00 PM /examples/south-africa/img_1842.jpg ',''),(5,'/portal-sujets/slide-02.jpg','asset','image','image',1,1368530764,1370432868,0,0,'ID: 5  \nPath: /portal-sujets/slide-02.jpg  \nslide-02.jpg',''),(5,'/en/advanced-examples','document','page','page',1,1368523389,1388738496,0,0,'ID: 5  \nPath: /en/advanced-examples  \n The following list is generated automatically. See controller/action to see how it\'s done.&nbsp; Advanced Examples ','sidebar:/en/advanced-examples/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/advanced-examples language:en navigation_name:Advanced Examples '),(5,'/news/nam-eget-dui','object','object','news',1,1368613700,1382958801,0,0,'ID: 5  \nPath: /news/nam-eget-dui  \nZwei flinke Boxer jagen die quirlige Eva Franz jagt im komplett verwahrlosten Taxi quer durch Bayern. Zwölf Boxkämpfer jagen Viktor quer über den großen Sylter Deich. Vogel Quax zwickt Johnys Pferd Bim. Victor jagt zw&ouml;lf Boxk&auml;mpfer quer &uuml;ber den gro&szlig;en Sylter Deich. Falsches &Uuml;ben von Xylophonmusik qu&auml;lt jeden gr&ouml;&szlig;eren Zwerg. Heiz&ouml;lr&uuml;cksto&szlig;abd&auml;mpfung. Zwei flinke Boxer jagen die quirlige Eva und ihren Mops durch Sylt. Franz jagt im komplett verwahrlosten Taxi quer durch Bayern. Zw&ouml;lf Boxk&auml;mpfer jagen Viktor quer &uuml;ber den gro&szlig;en Sylter Deich. Vogel Quax zwickt Johnys Pferd Bim. Sylvia wagt quick den Jux bei Pforzheim. Polyfon zwitschernd a&szlig;en M&auml;xchens V&ouml;gel R&uuml;ben, Joghurt und Quark. &quot;Fix, Schwyz!&quot; qu&auml;kt J&uuml;rgen bl&ouml;d vom Pa&szlig;. Victor jagt zw&ouml;lf Boxk&auml;mpfer quer &uuml;ber den gro&szlig;en Sylter Deich. Falsches &Uuml;ben von Xylophonmusik qu&auml;lt jeden gr&ouml;&szlig;eren Zwerg. Heiz&ouml;lr&uuml;cksto&szlig;abd&auml;mpfung.Zwei flinke Boxer jagen die quirlige Eva und ihren Mops durch Sylt. Franz jagt im komplett verwahrlosten Taxi quer durch Bayern. Zw&ouml;lf Boxk&auml;mpfer jagen Viktor quer &uuml;ber den gro&szlig;en Sylter Deich. Vogel Quax zwickt Johnys Pferd Bim. Sylvia wagt quick den Jux Nam eget dui Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, Jun 1, 2013 12:00:00 AM ',''),(6,'/portal-sujets/slide-03.jpg','asset','image','image',1,1368530764,1370432860,0,0,'ID: 6  \nPath: /portal-sujets/slide-03.jpg  \nslide-03.jpg',''),(6,'/en/experiments','document','page','page',1,1368523410,1395043974,0,0,'ID: 6  \nPath: /en/experiments  \n Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. &nbsp; Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. &nbsp; Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, Experiments This space is reserved for your individual experiments & tests. ','sidebar:/en/sidebar mainNavStartNode:/en leftNavStartNode:/en blog:/en/advanced-examples/blog language:en navigation_name:Experiments '),(6,'/news/in-enim-justo_2','object','object','news',1,1368615188,1382958710,0,0,'ID: 6  \nPath: /news/in-enim-justo_2  \nLi Europan lingues es membres Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li nov lingua franca va esser plu simplic e regulari quam li existent Europan lingues. It va esser tam simplic quam Occidental in fact, it va esser Occidental. A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles. In enim justo Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Dec 3, 2012 7:15:00 PM /examples/panama/img_0160.jpg ',''),(7,'/examples','asset','folder','folder',1,1368531816,1368632468,0,0,'ID: 7  \nPath: /examples  \nexamples',''),(7,'/en/basic-examples/html5-video','document','page','page',1,1368525394,1395042970,0,0,'ID: 7  \nPath: /en/basic-examples/html5-video  \n HTML5 Video is just as simple as that .... Just drop an video from your assets, the video will be automatically converted to the different HTML5 formats and to the correct size.&nbsp; Just drop an video from your assets, the video will be automatically converted to the different HTML5 formats and to the correct size. ','sidebar:/en/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/basic-examples language:en navigation_name:HTML5 Video '),(7,'/news/in-enim-justo_3','object','object','news',1,1368615191,1382958709,0,0,'ID: 7  \nPath: /news/in-enim-justo_3  \nLi Europan lingues es membres Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li nov lingua franca va esser plu simplic e regulari quam li existent Europan lingues. It va esser tam simplic quam Occidental in fact, it va esser Occidental. A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles. In enim justo Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Feb 11, 2013 7:15:00 PM /examples/panama/img_0117.jpg ',''),(8,'/news/in-enim-justo_4','object','object','news',1,1368615194,1382958708,0,0,'ID: 8  \nPath: /news/in-enim-justo_4  \nLi Europan lingues es membres Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li nov lingua franca va esser plu simplic e regulari quam li existent Europan lingues. It va esser tam simplic quam Occidental in fact, it va esser Occidental. A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles. In enim justo Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Feb 4, 2013 7:15:00 PM /examples/panama/img_0089.jpg ',''),(9,'/en/advanced-examples/creating-objects-using-forms','document','page','page',1,1368525933,1382956042,0,0,'ID: 9  \nPath: /en/advanced-examples/creating-objects-using-forms  \n &nbsp; In this example we dynamically create objects out of the data submitted via the form. The you can use the same approach to create objects using a commandline script, or wherever you need it. After submitting the form you\'ll find the data in \"Objects\" /crm and /inquiries.&nbsp; &nbsp; &nbsp; And here\'s the form:&nbsp; Please fill all fields and accept the terms of use. Creating Objects & Assets with a Form ','sidebar:/en/advanced-examples/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/advanced-examples language:en navigation_name:Creating Objects with a Form '),(9,'/news/in-enim-justo_5','object','object','news',1,1368615197,1382958706,0,0,'ID: 9  \nPath: /news/in-enim-justo_5  \nLi Europan lingues es membres Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li nov lingua franca va esser plu simplic e regulari quam li existent Europan lingues. It va esser tam simplic quam Occidental in fact, it va esser Occidental. A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles. In enim justo Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Nov 13, 2012 7:15:00 PM /examples/panama/img_0037.jpg ',''),(10,'/en/shared','document','folder','folder',1,1368527956,1382956831,0,0,'ID: 10  \nPath: /en/shared  \nshared','sidebar:/en/sidebar mainNavStartNode:/en leftNavStartNode:/en language:en blog:/en/advanced-examples/blog '),(10,'/crm','object','folder','folder',1,1368620607,1368620607,0,0,'ID: 10  \nPath: /crm  \ncrm',''),(11,'/en/shared/includes','document','folder','folder',1,1368527961,1382956831,0,0,'ID: 11  \nPath: /en/shared/includes  \nincludes','sidebar:/en/sidebar mainNavStartNode:/en leftNavStartNode:/en language:en blog:/en/advanced-examples/blog '),(11,'/inquiries','object','folder','folder',1,1368620624,1368620624,0,0,'ID: 11  \nPath: /inquiries  \ninquiries',''),(12,'/en/shared/includes/footer','document','snippet','snippet',1,1368527967,1382956852,0,0,'ID: 12  \nPath: /en/shared/includes/footer  \npimcore.org Documentation Bug Tracker Designed and built with all the love in the world by&nbsp;@mdo&nbsp;and&nbsp;@fat. Code licensed under&nbsp;Apache License v2.0,&nbsp;Glyphicons Free&nbsp;licensed under&nbsp;CC BY 3.0. © Templates pimcore.org licensed under BSD License ','sidebar:/en/sidebar mainNavStartNode:/en leftNavStartNode:/en language:en blog:/en/advanced-examples/blog '),(13,'/en/shared/teasers','document','folder','folder',1,1368531657,1382956831,0,0,'ID: 13  \nPath: /en/shared/teasers  \nteasers','sidebar:/en/sidebar mainNavStartNode:/en leftNavStartNode:/en language:en blog:/en/advanced-examples/blog '),(14,'/en/shared/teasers/standard','document','folder','folder',1,1368531665,1382956831,0,0,'ID: 14  \nPath: /en/shared/teasers/standard  \nstandard','sidebar:/en/sidebar mainNavStartNode:/en leftNavStartNode:/en language:en blog:/en/advanced-examples/blog '),(15,'/en/shared/teasers/standard/basic-examples','document','snippet','snippet',1,1368531692,1382956831,0,0,'ID: 15  \nPath: /en/shared/teasers/standard/basic-examples  \n Fully Responsive Lorem ipsum This demo is based on Bootstrap, the most popular, intuitive, and powerful front-end framework. ','sidebar:/en/sidebar mainNavStartNode:/en leftNavStartNode:/en language:en blog:/en/advanced-examples/blog '),(16,'/en/shared/teasers/standard/advanced-examples','document','snippet','snippet',1,1368534298,1382956831,0,0,'ID: 16  \nPath: /en/shared/teasers/standard/advanced-examples  \n Drag & Drop Interface Etiam rhoncu Content is created by simply dragging &amp; dropping blocks, that can&nbsp;be editited in-place and wysiwyg.&nbsp; ','sidebar:/en/sidebar mainNavStartNode:/en leftNavStartNode:/en language:en blog:/en/advanced-examples/blog '),(17,'/examples/panama','asset','folder','folder',1,1368532826,1368632468,0,0,'ID: 17  \nPath: /examples/panama  \npanama',''),(17,'/en/shared/teasers/standard/experiments','document','snippet','snippet',1,1368534344,1382956831,0,0,'ID: 17  \nPath: /en/shared/teasers/standard/experiments  \n HTML5 omnipresent Quisque rutrum Drag &amp; drop upload directly&nbsp;into the asset tree, automatic html5 video transcoding, and much more ... ','sidebar:/en/sidebar mainNavStartNode:/en leftNavStartNode:/en language:en blog:/en/advanced-examples/blog '),(18,'/examples/panama/img_0117.jpg','asset','image','image',1,1368532831,1368632468,0,0,'ID: 18  \nPath: /examples/panama/img_0117.jpg  \nimg_0117.jpg',''),(18,'/en/basic-examples/pdf-viewer','document','page','page',1,1368548449,1395042961,0,0,'ID: 18  \nPath: /en/basic-examples/pdf-viewer  \n Isn\'t that amazing? Just drop a PDF, doc(x), xls(x) or many other formats, et voilá ...&nbsp; Just drop a PDF, doc(x), xls(x) or many other formats, et voilá ... + &#x21e9; x var pimcore_pdf_pdfcontent1 = new pimcore.pdf({ id: \"pimcore-pdf-5436334873272\", data: {\"pages\":[{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-1\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-1\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-2\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-2\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-3\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-3\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-4\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-4\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-5\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-5\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-6\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-6\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-7\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-7\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-8\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-8\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-9\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-9\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-10\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-10\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-11\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-11\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-12\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-12\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-13\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-13\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-14\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-14\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-15\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-15\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-16\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-16\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-17\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-17\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-18\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-18\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-19\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-19\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-20\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-20\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-21\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-21\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-22\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-22\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-23\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-23\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-24\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-24\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-25\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-25\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-26\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-26\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-27\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-27\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-28\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-28\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-29\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-29\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-30\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-30\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-31\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-31\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-32\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-32\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-33\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-33\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-34\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-34\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-35\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-35\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-36\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-36\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-37\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-37\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-38\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-38\\/documentation.pjpeg\"},{\"thumbnail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_ca35914f842e48731761eda9e1b55fa1-39\\/documentation.pjpeg\",\"detail\":\"\\/website\\/var\\/tmp\\/image-thumbnails\\/0\\/36\\/thumb__document_auto_55c4d1de803e2f89c46b9a22287c3b50-39\\/documentation.pjpeg\"}],\"pdf\":\"\\/documents\\/documentation.pdf\",\"fullscreen\":true} }); ','sidebar:/en/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/basic-examples language:en navigation_name:Document Viewer '),(19,'/examples/panama/img_0201.jpg','asset','image','image',1,1368532832,1368632468,0,0,'ID: 19  \nPath: /examples/panama/img_0201.jpg  \nimg_0201.jpg',''),(19,'/en/basic-examples/galleries','document','page','page',1,1368549805,1395043436,0,0,'ID: 19  \nPath: /en/basic-examples/galleries  \nWhite beaches and the indian ocean National Nature Reserve Plettenberg Bay The Robberg Creating custom galleries is very simple Autogenerated Gallery (using Renderlet) Custom assembled Gallery Drag an asset folder on the following drop area, and the \"renderlet\" will create automatically a gallery out of the images in the folder. Drag an asset folder on the following drop area, and the \"renderlet\" will create automatically a gallery out of the images in the folder. 1 5 4 ','sidebar:/en/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/basic-examples language:en navigation_name:Galleries '),(20,'/examples/panama/img_0089.jpg','asset','image','image',1,1368532833,1368632468,0,0,'ID: 20  \nPath: /examples/panama/img_0089.jpg  \nimg_0089.jpg',''),(20,'/en/basic-examples/glossary','document','page','page',1,1368559903,1395043487,0,0,'ID: 20  \nPath: /en/basic-examples/glossary  \n Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles. &nbsp; Ma quande lingues coalesce, li grammatica del resultant lingue es plu simplic e regulari quam ti del coalescent lingues. Li nov lingua franca va esser plu simplic e regulari quam li existent Europan lingues. It va esser tam simplic quam Occidental in fact, it va esser Occidental. A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es. &nbsp; Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles. The Glossary ... ... makes it very simple to automatically link keywords, abbreviation and acronyms. This is not only perfect for SEO but also makes it super easy to navigate in the content.&nbsp; &nbsp; ... this is how it looks in the admin interface. ... makes it very simple to automatically link keywords, abbreviation and acronyms. This is not only perfect for SEO but also makes it super easy to navigate in the content. ... this is how it looks in the admin interface. ','sidebar:/en/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/basic-examples language:en navigation_name:Glossary '),(21,'/examples/panama/img_0037.jpg','asset','image','image',1,1368532834,1368632468,0,0,'ID: 21  \nPath: /examples/panama/img_0037.jpg  \nimg_0037.jpg',''),(21,'/en/basic-examples/thumbnails','document','page','page',1,1368602443,1395043532,0,0,'ID: 21  \nPath: /en/basic-examples/thumbnails  \n Incredible Possibilities This is the original image This is how it looks in the admin interface ... ','sidebar:/en/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/basic-examples language:en navigation_name:Thumbnails '),(22,'/examples/panama/img_0399.jpg','asset','image','image',1,1368532836,1368632468,0,0,'ID: 22  \nPath: /examples/panama/img_0399.jpg  \nimg_0399.jpg',''),(22,'/en/basic-examples/website-translations','document','page','page',1,1368607207,1395043561,0,0,'ID: 22  \nPath: /en/basic-examples/website-translations  \n &nbsp; Please visit this page to see the German translation of this page. &nbsp; Following some examples:&nbsp; &nbsp; Website Translations Common used terms across the website can be translated centrally, hassle-free and comfortable.&nbsp; Common used terms across the website can be translated centrally, hassle-free and comfortable. &nbsp; &nbsp; This is how it looks in the admin interface ...&nbsp; This is how it looks in the admin interface ... ','sidebar:/en/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/basic-examples language:en navigation_name:Website Translations '),(23,'/examples/panama/img_0411.jpg','asset','image','image',1,1368532837,1368632468,0,0,'ID: 23  \nPath: /examples/panama/img_0411.jpg  \nimg_0411.jpg',''),(23,'/de/einfache-beispiele/website-uebersetzungen','document','page','page',1,1368608357,1382958135,0,0,'ID: 23  \nPath: /de/einfache-beispiele/website-uebersetzungen  \n Folgend ein paar Beispiele:&nbsp; Website Übersetzungen Häufig genutzte Begriffe auf der gesamten Website können komfortabel, zentral und einfach übersetzt werden. ','blog:/en/advanced-examples/blog mainNavStartNode:/de sidebar:/de/sidebar leftNavStartNode:/de language:de navigation_name:Website Übersetzungen '),(24,'/examples/panama/img_0410.jpg','asset','image','image',1,1368532838,1368632468,0,0,'ID: 24  \nPath: /examples/panama/img_0410.jpg  \nimg_0410.jpg',''),(24,'/en/basic-examples/content-page','document','page','page',1,1368609059,1405923178,0,0,'ID: 24  \nPath: /en/basic-examples/content-page  \n Albert Einstein Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: &nbsp; On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles. Ma quande lingues coalesce, li grammatica del resultant lingue es plu simplic e regulari quam ti del coalescent lingues. Li nov lingua franca va esser plu simplic e regulari quam li existent Europan lingues. It va esser tam simplic quam Occidental in fact, it va esser Occidental. &nbsp; A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. &nbsp; Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. &nbsp; Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. This is just a simple Content-Page ... Where some Content-Blocks are mixed together. Lorem ipsum dolor sit amet Cum sociis natoque penatibus et magnis dis parturient montes Donec pede justo, fringilla vel Maecenas tempus, tellus eget condimentum rhoncus Lorem ipsum. Etiam ultricies. thumbs-up qrcode trash African Animals Donec pede justo, fringilla vel, aliquet nec See in Action Read More Try it now left We can\'t solve problems by using the same kind of thinking we used when we created them. Dolor sit amet. Nam eget dui. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. &nbsp; Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. &nbsp; Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: &nbsp; On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles. Ma quande lingues coalesce, li grammatica del resultant lingue es plu simplic e regulari quam ti del coalescent lingues. Li nov lingua franca va esser plu simplic e regulari quam li existent Europan lingues. It va esser tam simplic quam Occidental in fact, it va esser Occidental. &nbsp; A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. It va esser tam simplic quam Occidental in fact, it va esser Occidental. A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es.Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. &nbsp; Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles. At solmen va esser necessi far uniform grammatica. Curabitur ullamcorper ultricies nisi. Nam eget dui. On refusa continuar payar custosi traductores. Social Media Integration QR-Code Management Recycle Bin video ','sidebar:/en/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/basic-examples language:en navigation_name:Content Page '),(25,'/examples/panama/img_0160.jpg','asset','image','image',1,1368532839,1368632468,0,0,'ID: 25  \nPath: /examples/panama/img_0160.jpg  \nimg_0160.jpg',''),(25,'/en/basic-examples/editable-roundup','document','page','page',1,1368609569,1395043587,0,0,'ID: 25  \nPath: /en/basic-examples/editable-roundup  \n This is an overview of all available \"editables\" (except area/areablock/block) Please view this page in the editmode (admin interface)! ... nothing to see here ;-)&nbsp; ... nothing to see here ;-) 1 May 16, 2013 2:00:00 AM /en/basic-examples/thumbnails Some Text My Link document: /en/basic-examples/glossarydocument: /en/basic-examples/thumbnailsdocument: /en/basic-examples/editable-roundupasset: /examples/south-africa/img_1842.jpgasset: /examples/south-africa/img_2133.jpgasset: /examples/south-africa/img_2240.jpg value2,value4 123 option2 Some Text Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. &nbsp; Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. &nbsp; Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, Value 1Value 2Value 3thisistest ','sidebar:/en/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/basic-examples language:en navigation_name:Editable Round-Up '),(26,'/videos','asset','folder','folder',1,1368542684,1368632471,0,0,'ID: 26  \nPath: /videos  \nvideos',''),(26,'/en/basic-examples/form','document','page','page',1,1368610663,1388733533,0,0,'ID: 26  \nPath: /en/basic-examples/form  \n Just a simple form ','sidebar:/en/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/basic-examples language:en navigation_name:Simple Form '),(27,'/videos/home-trailer-english.mp4','asset','video','video',1,1368542794,1405922844,0,0,'ID: 27  \nPath: /videos/home-trailer-english.mp4  \nhome-trailer-english.mp4',''),(27,'/en/basic-examples/news','document','page','page',1,1368613137,1395043614,0,0,'ID: 27  \nPath: /en/basic-examples/news  \n News Any kind of structured data is stored in \"Objects\".&nbsp; Any kind of structured data is stored in \"Objects\". ','sidebar:/en/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/basic-examples language:en navigation_name:News '),(28,'/en/basic-examples/properties','document','page','page',1,1368615986,1382956040,0,0,'ID: 28  \nPath: /en/basic-examples/properties  \n On this page we use \"Properties\" to hide the navigation on the left and to change the color of the header to blue.&nbsp; Properties are very useful to control the behavior or to store meta data of documents, assets and objects. And the best: they are inheritable.&nbsp; &nbsp; On the following screens you can see how this is done in this example. Properties ','blog:/en/advanced-examples/blog mainNavStartNode:/en sidebar:/en/sidebar language:en leftNavStartNode:/en/basic-examples navigation_name:Properties leftNavHide:1 headerColor:blue '),(28,'/crm/inquiries/john-doe.com','object','object','person',1,1368630902,1388409139,0,0,'ID: 28  \nPath: /crm/inquiries/john-doe.com  \nmale John Doe john@doe.com May 15, 2013 5:15:02 PM ',''),(29,'/documents','asset','folder','folder',1,1368548619,1368632467,0,0,'ID: 29  \nPath: /documents  \ndocuments',''),(29,'/en/basic-examples/tag-and-snippet-management','document','page','page',1,1368617118,1395043636,0,0,'ID: 29  \nPath: /en/basic-examples/tag-and-snippet-management  \n This page demonstrates how to use the \"Tag &amp; Snippet Management\" to inject codes into the HTML source code. This functionality can be used to easily integrate tracking codes, conversion codes, social plugins and whatever that needs to go into the HTML. &nbsp; The functionality is similar to this products:&nbsp; http://www.google.com/tagmanager/&nbsp; http://www.searchdiscovery.com/satellite/&nbsp; http://www.tagcommander.com/en/ &nbsp; In our example we use it to integrate a facebook social plugin. Tag & Snippet Management ... gives all the freedom back to the marketing dept. ','sidebar:/en/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/basic-examples language:en navigation_name:Tag & Snippet Management '),(29,'/inquiries/may-15-2013-5-15-02-pm~john-doe.com','object','object','inquiry',1,1368630902,1368630902,0,0,'ID: 29  \nPath: /inquiries/may-15-2013-5-15-02-pm~john-doe.com  \nMay 15, 2013 5:15:02 PM object:/crm/inquiries/john-doe.com Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. 1 ',''),(30,'/en/advanced-examples/content-inheritance','document','page','page',1,1368623726,1395043816,0,0,'ID: 30  \nPath: /en/advanced-examples/content-inheritance  \n Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet.&nbsp; Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, Content Inheritance First Headline Second Headline This is the Master Document This is the Master Document ','sidebar:/en/advanced-examples/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/advanced-examples language:en navigation_name:Content Inheritance '),(30,'/crm/inquiries/jane-doe.com','object','object','person',1,1368630916,1388409137,0,0,'ID: 30  \nPath: /crm/inquiries/jane-doe.com  \nfemale Jane Doe jane@doe.com May 15, 2013 5:15:16 PM ',''),(31,'/en/advanced-examples/content-inheritance/content-inheritance','document','page','page',1,1368623866,1395043901,0,0,'ID: 31  \nPath: /en/advanced-examples/content-inheritance/content-inheritance  \n This is the Slave Document This is the Slave Document ','sidebar:/en/advanced-examples/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/advanced-examples language:en navigation_name:Slave Document '),(31,'/inquiries/may-15-2013-5-15-16-pm~jane-doe.com','object','object','inquiry',1,1368630916,1368630916,0,0,'ID: 31  \nPath: /inquiries/may-15-2013-5-15-16-pm~jane-doe.com  \nMay 15, 2013 5:15:16 PM object:/crm/inquiries/jane-doe.com Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. 1 ',''),(32,'/en/basic-examples/pimcore.org','document','link','link',1,1368626404,1382956040,0,0,'ID: 32  \nPath: /en/basic-examples/pimcore.org  \n http://www.pimcore.org/','sidebar:/en/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en language:en leftNavStartNode:/en/basic-examples navigation_target:_blank navigation_name:External Link '),(32,'/blog','object','folder','folder',1,1388389170,1388389170,7,7,'ID: 32  \nPath: /blog  \nblog',''),(33,'/en/advanced-examples/hard-link/basic-examples','document','hardlink','hardlink',0,1368626461,1382956042,0,0,'ID: 33  \nPath: /en/advanced-examples/hard-link/basic-examples  \n','sidebar:/en/advanced-examples/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/advanced-examples language:en navigation_name:Basic Examples '),(33,'/blog/categories','object','folder','folder',1,1388389428,1388389428,7,7,'ID: 33  \nPath: /blog/categories  \ncategories',''),(34,'/screenshots','asset','folder','folder',1,1368560793,1368632470,0,0,'ID: 34  \nPath: /screenshots  \nscreenshots',''),(34,'/en/advanced-examples/hard-link','document','page','page',1,1368626655,1382956042,0,0,'ID: 34  \nPath: /en/advanced-examples/hard-link  \n This page has a hardlink as child (see navigation on the left).&nbsp; This hardlink points to \"Basic Examples\", so the whole content of /basic-examples is available in /advaned-examples/hardlink/basic-examples.&nbsp; &nbsp; Want to know more about hardlinks?&nbsp; http://en.wikipedia.org/wiki/Hard_link see also:&nbsp;http://en.wikipedia.org/wiki/Symbolic_link&nbsp; &nbsp; Hard Link Example ','sidebar:/en/advanced-examples/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/advanced-examples language:en navigation_name:Hard Link '),(34,'/blog/articles','object','folder','folder',1,1388389435,1388389435,7,7,'ID: 34  \nPath: /blog/articles  \narticles',''),(35,'/screenshots/glossary.png','asset','image','image',1,1368560809,1368632470,0,0,'ID: 35  \nPath: /screenshots/glossary.png  \nglossary.png',''),(35,'/en/advanced-examples/image-with-hotspots-and-markers','document','page','page',1,1368626888,1382956042,0,0,'ID: 35  \nPath: /en/advanced-examples/image-with-hotspots-and-markers  \n Image with Hotspots & Markers ','sidebar:/en/advanced-examples/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/advanced-examples language:en navigation_name:Image with Hotspots '),(35,'/blog/articles/maecenas-nec-odio','object','object','blogArticle',1,1388389641,1388393754,7,7,'ID: 35  \nPath: /blog/articles/maecenas-nec-odio  \nMaecenas nec odio et ante tincidunt tempus Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetuer vestibulum elit. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Vestibulum fringilla pede sit amet augue. In turpis. Pellentesque posuere. Praesent turpis. Aenean posuere, tortor sed cursus feugiat, nunc augue blandit nunc, eu sollicitudin urna dolor sagittis lacus. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Nullam sagittis. Suspendisse pulvinar, augue ac venenatis condimentum, sem libero volutpat nibh, nec pellentesque velit pede quis nunc. Aenean Vestibulum Etiam Curabitur Maecenas nec odio et ante tincidunt tempus Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetuer vestibulum elit. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Vestibulum fringilla pede sit amet augue. In turpis. Pellentesque posuere. Praesent turpis. Aenean posuere, tortor sed cursus feugiat, nunc augue blandit nunc, eu sollicitudin urna dolor sagittis lacus. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Nullam sagittis. Suspendisse pulvinar, augue ac venenatis condimentum, sem libero volutpat nibh, nec pellentesque velit pede quis nunc. Aenean Vestibulum Etiam Curabitur Jan 2, 2014 8:52:00 AM /blog/categories/nam-eget-dui,/blog/categories/etiam-rhoncus ',''),(36,'/documents/documentation.pdf','asset','document','document',1,1368562442,1368632467,0,0,'ID: 36  \nPath: /documents/documentation.pdf  \ndocumentation.pdf Documentation 1. Pimcore Documentation . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1 Templates (Views) . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1.1 Editables . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1.1.1 Areablock (since 1.3.2) . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1.1.1.1 Create your own bricks . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1.1.2 Area (since 1.4.3) . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1.1.3 Block . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1.1.4 Checkbox . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1.1.5 Date . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1.1.6 Href (1 to 1 Relation) . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1.1.7 Image . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1.1.8 Input . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1.1.9 Link . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1.1.10 Multihref (since 1.4.2) . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1.1.11 Multiselect . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1.1.12 Numeric . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1.1.13 Renderlet . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1.1.14 Select . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1.1.15 Snippet (embed) . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1.1.16 Table . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1.1.17 Textarea . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1.1.18 Video . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1.1.19 WYSIWYG . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1.1.2 Helpers (Available View Methods) . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3 5 6 7 9 13 14 17 17 18 19 23 25 26 27 27 28 30 31 32 33 33 36 38 Pimcore Documentation Table of Contents Installation and Upgrade Guide System Requirements Deployment using Capistrano Upgrade Notes Develop with pimcore Overview Documents Quick Start Guide Types Controllers Templates (Views) Editables Areablock (since 1.3.2) Create your own bricks Area (since 1.4.3) Block Checkbox Date Href (1 to 1 Relation) Image Input Link Multihref (since 1.4.2) Multiselect Numeric Renderlet Select Snippet (embed) Table Textarea Video WYSIWYG Helpers (Available View Methods) Document-Types Thumbnails Glossary Redirects Document Lists Localize your Documents (i18n) Translation of Document Editables Website Translations Navigation (since pimcore 1.4.0) Document Tree Copy documents and rewrite relations to new documents (since 1.4.2) Hardlinks for documents (since 1.4.2) Assets Asset Lists Custom Settings (Properties) Image Thumbnails Video Thumbnails (since 1.4.3) Data Objects Object Classes Data Fields Date, Date & Time, Time Geographic Fields - Point, Bounds, Polygon Href, Multihref, Objects - Relations, Dependencies and Lazy Loading Localized Fields (since 1.3.2) Non-Owner Objects Number Fields - Numeric, Slider Other Fields - Image, Image with Hotspots, Checkbox, Link Select Fields - Select, Multiselect, User, Country, Language Structured Data Fields Key Value Pairs (since 1.4.9) Structured Data Fields - Fieldcollections Structured Data Fields - Objectbricks Structured Data Fields - Structured Table Structured Data Fields - Table Text Input Fields - Input, Password,Textarea, WYSIWYG Layout Elements Object Lists External System Interaction Inheritance Custom Icons Locking fields Object Variants Object Preview (since 1.4.2) Object Tree Custom icons and style in object-tree (since 1.4.2) General Building URL\'s Cache Custom Cache Backends Output-Cache Custom Routes (Static Routes) Extending pimcore Class-Mappings - Overwrite pimcore models (since 1.3.2) Custom persistent models Hook into the startup-process (since 1.4.3) Google Custom Search Engine (Site Search) Integration (since 1.4.6) Magic Parameters Newsletter Properties Predefined Properties SQL Reports Static Helpers System Settings Email Tag & Snippet Management Versioning Website Settings Working with Sites (Multisite) Best Practices CLI Script for Object Import Eric Meyer reset.css Extending the Pimcore User with User - Object Relation High Traffic Server Setup (*nix based Environment) Reports & Marketing Google Analytics Setup Google Analytics Reporting with OAuth2 Service Accounts (since 1.4.6) API-Reference Web Services REST (since 1.4.9) SOAP (since pimcore 1.3.0) Localization Outputfilters Image base64 embed LESS (CSS Compiler) Install lessc on your server (Debian) Minify HTML, CSS & Javascript Mailing Framework (since build 1595) Pimcore_Mail Class Placeholders Object Text Administrator\'s Guide Backups Commandline Interface Backend Search Reindex Backups (since 1.3.0) Cache Warming Image Thumbnail Generator (since 1.4.6) MySQL Tools Install Plugins Setting up WebDav Translations User Permissions User\'s Guide Google Analytics Integration Keyboard Shortcuts Working with WebDAV BitKinex as WebDAV Client Cyberduck as WebDAV Client NetDrive as WebDAV Client Windows Explorer as WebDAV Client Extensions Extension Hub and Extension Manager Hooks Official Plugins Pimcore Demo Side - The Dev4Demo Project Plugin Developer\'s Guide Example Plugin Anatomy and Design Plugin Backend (PHP) UI Development and JS Hooks Useful Hints Develop for pimcore Releasing a new Version SVN Code-Repository and GitHub FAQ Archive Screencasts Install Example Data VMware Demo Image Commandline Updater CDN (Content Delivery Network) Google Summer of Code 2012 Ideas PhpUnit Tests Templates (Views) As mentioned already before, Pimcore uses Zend_View as its template engine, and the standard template language is PHP. The Pimcore implementation of Zend_View offers special methods to increase the usability: Method Description inc Use this function to directly include a document template Use this method to include a template cache In template caching translate i18n / translations glossary Glossary Additionally you can use the Zend_View helpers which are shipped with ZF. There are some really cool helpers which are really useful when used in combination with Pimcore. Some Examples Method Description action http://framework.zend.com/manual/en/zend.view.helpers.html#zend.view.helpers.initial.action headMeta http://framework.zend.com/manual/en/zend.view.helpers.html#zend.view.helpers.initial.headmeta headTitle http://framework.zend.com/manual/en/zend.view.helpers.html#zend.view.helpers.initial.headtitle translate http://framework.zend.com/manual/en/zend.view.helpers.html#zend.view.helpers.initial.translate You can use your own custom Zend_View helpers, or create some new one to make your life easier. There are some properties which are automatic available in the view: Name Type Description editmode boolean Is true if you are in editmode (admin), false if you are on the website controller Pimcore_Controller_Action_Frontend A reference to the controller document Document Reference to the current document object you can directly access the properties of the document in the view (eg. $this?document?getTitle();) Editables (Placeholders for content) Pimcore offers a basic set of placeholders which can be placed directly into the template. In editmode they appear as an editable widget, where you can put your content in. While in frontend-mode the content is directly embedded into the HTML. There is a standard scheme for how to call the editables. The first argument is always the name of the element (as string), the second argument is an array with multiple options (configurations) in it. Because most of the elements are based directly on Ext.form elements, you can also pass configurations directly to the Ext components (see API reference of Ext) Click here to get a detailed overview about the editables. Example Editables The editables are placeholders in the templates, which are input widgets in the admin (editmode) and output the content in frontend mode. Area (since 1.4.3) Areablock (since 1.3.2) Block Checkbox Date Href (1 to 1 Relation) Image Input Link Multihref (since 1.4.2) Multiselect Numeric Renderlet Select Snippet (embed) Table Textarea Video WYSIWYG General Most of the editables use ExtJS widgets, these editables can be also configured with options of the underlying ExtJS widget. For example: You can also use Zend_Json_Expr to add \"native\" Javascript to an editable: ','document_page_count:39 '),(36,'/en/advanced-examples/search','document','page','page',1,1368629524,1388733927,0,0,'ID: 36  \nPath: /en/advanced-examples/search  \n The search is using the contents from&nbsp;pimcore.org.&nbsp;TIP: Search for \"web\". Search ','sidebar:/en/advanced-examples/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/advanced-examples language:en navigation_name:Search '),(36,'/blog/categories/curabitur-ullamcorper','object','object','blogCategory',1,1388389865,1388389870,7,7,'ID: 36  \nPath: /blog/categories/curabitur-ullamcorper  \nCurabitur ullamcorper Curabitur ullamcorper ',''),(37,'/examples/italy','asset','folder','folder',1,1368596763,1368632468,0,0,'ID: 37  \nPath: /examples/italy  \nitaly',''),(37,'/en/advanced-examples/contact-form','document','page','page',1,1368630444,1382956042,0,0,'ID: 37  \nPath: /en/advanced-examples/contact-form  \n Contact Form ','blog:/en/advanced-examples/blog mainNavStartNode:/en sidebar:/en/advanced-examples/sidebar leftNavStartNode:/en/advanced-examples language:en navigation_name:Contact Form email:/en/advanced-examples/contact-form/email '),(37,'/blog/categories/nam-eget-dui','object','object','blogCategory',1,1388389881,1388393730,7,7,'ID: 37  \nPath: /blog/categories/nam-eget-dui  \nNam eget dui Nam eget dui ',''),(38,'/examples/italy/dsc04346.jpg','asset','image','image',1,1368596767,1368632468,0,0,'ID: 38  \nPath: /examples/italy/dsc04346.jpg  \ndsc04346.jpg',''),(38,'/en/advanced-examples/contact-form/email','document','email','email',1,1368631410,1382956042,0,0,'ID: 38  \nPath: /en/advanced-examples/contact-form/email  \nGender: %Text(gender);&nbsp; Firstname: %Text(firstname); Lastname: %Text(lastname); E-Mail: %Text(email);&nbsp; &nbsp; Message: %Text(message);&nbsp; &nbsp; You\'ve got a new E-Mail! ','sidebar:/en/advanced-examples/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/advanced-examples language:en email:/en/advanced-examples/contact-form/email '),(38,'/blog/categories/etiam-rhoncus','object','object','blogCategory',1,1388389892,1388389900,7,7,'ID: 38  \nPath: /blog/categories/etiam-rhoncus  \nEtiam rhoncus Etiam rhoncus ',''),(39,'/examples/italy/dsc04344.jpg','asset','image','image',1,1368596768,1368632468,0,0,'ID: 39  \nPath: /examples/italy/dsc04344.jpg  \ndsc04344.jpg',''),(39,'/error','document','page','page',1,1369854325,1369854422,0,0,'ID: 39  \nPath: /error  \n Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. &nbsp; Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. &nbsp; Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, &nbsp; It seems that the page you were trying to find isn\'t around anymore. Oh no! ','sidebar:/en/sidebar mainNavStartNode:/en leftNavStartNode:/en language:en blog:/en/advanced-examples/blog '),(39,'/blog/articles/lorem-ipsum-dolor-sit-amet','object','object','blogArticle',1,1388390090,1388393711,7,7,'ID: 39  \nPath: /blog/articles/lorem-ipsum-dolor-sit-amet  \nLorem ipsum dolor sit amet Quisque id mi. Ut tincidunt tincidunt erat. Etiam feugiat lorem non metus. Vestibulum dapibus nunc ac augue. Curabitur vestibulum aliquam leo. Praesent egestas neque eu enim. In hac habitasse platea dictumst. Fusce a quam. Etiam ut purus mattis mauris sodales aliquam. Curabitur nisi. Quisque malesuada placerat nisl. Nam ipsum risus, rutrum vitae, vestibulum eu, molestie vel, lacus. Sed augue ipsum, egestas nec, vestibulum et, malesuada adipiscing, dui. Vestibulum facilisis, purus nec pulvinar iaculis, ligula mi congue nunc, vitae euismod ligula urna in dolor. Mauris sollicitudin fermentum libero. Praesent nonummy mi in odio. Nunc interdum lacus sit amet orci. Vestibulum rutrum, mi nec elementum vehicula, eros quam gravida nisl, id fringilla neque ante vel mi. Morbi mollis tellus ac sapien. Phasellus volutpat, metus eget egestas mollis, lacus lacus blandit dui, id egestas quam mauris ut lacus. Fusce vel dui. Sed in libero ut nibh placerat accumsan. Proin faucibus arcu quis ante. In consectetuer turpis ut velit. Nulla sit amet est. Praesent metus tellus, elementum eu, semper a, adipiscing nec, purus. Cras risus ipsum, faucibus ut, ullamcorper id, varius ac, leo. Suspendisse feugiat. Suspendisse enim turpis, dictum sed, iaculis a, condimentum nec, nisi. Praesent nec nisl a purus blandit viverra. Praesent ac massa at ligula laoreet iaculis. Nulla neque dolor, sagittis eget, iaculis quis, molestie non, velit. Mauris turpis nunc, blandit et, volutpat molestie, porta ut, ligula. Fusce pharetra convallis urna. Quisque ut nisi. Donec mi odio, faucibus at, scelerisque quis, convallis in, nisi. Suspendisse non nisl sit amet velit hendrerit rutrum. Ut leo. Ut a nisl id ante tempus hendrerit. Proin pretium, leo ac pellentesque mollis, felis nunc ultrices eros, sed gravida augue augue mollis justo. Suspendisse eu ligula. Nulla facilisi. Donec id justo. Praesent porttitor, nulla vitae posuere iaculis, arcu nisl dignissim dolor, a pretium mi sem ut ipsum. Curabitur suscipit suscipit tellus. Praesent vestibulum dapibus nibh. Etiam iaculis nunc ac metus. Ut id nisl quis enim dignissim sagittis. Etiam sollicitudin, ipsum eu pulvinar rutrum, tellus ipsum laoreet sapien, quis venenatis ante odio sit amet eros. Proin magna. Duis vel nibh at velit scelerisque suscipit. Curabitur turpis. Vestibulum suscipit nulla quis orci. Fusce ac felis sit amet ligula pharetra condimentum. Maecenas egestas arcu quis ligula mattis placerat. Duis lobortis massa imperdiet quam. Suspendisse potenti. Pellentesque commodo eros a enim. Vestibulum turpis sem, aliquet eget, lobortis pellentesque, rutrum eu, nisl. Sed libero. Aliquam erat volutpat. Etiam vitae tortor. Morbi vestibulum volutpat enim. Aliquam eu nunc. Nunc sed turpis. Sed mollis, eros et ultrices tempus, mauris ipsum aliquam libero, non adipiscing dolor urna a orci. Nulla porta dolor. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos. Pellentesque dapibus hendrerit tortor. Praesent egestas tristique nibh. Sed a libero. Cras varius. Donec vitae orci sed dolor rutrum auctor. Fusce egestas elit eget lorem. Suspendisse nisl elit, rhoncus eget, elementum ac, condimentum eget, diam. Nam at tortor in tellus interdum sagittis. Aliquam lobortis. Donec orci lectus, aliquam ut, faucibus non, euismod id, nulla. Curabitur blandit mollis lacus. Nam adipiscing. Vestibulum eu odio. Etiam Curabitur Fusce Quisque Lorem ipsum dolor sit amet Quisque id mi. Ut tincidunt tincidunt erat. Etiam feugiat lorem non metus. Vestibulum dapibus nunc ac augue. Curabitur vestibulum aliquam leo. Praesent egestas neque eu enim. In hac habitasse platea dictumst. Fusce a quam. Etiam ut purus mattis mauris sodales aliquam. Curabitur nisi. Quisque malesuada placerat nisl. Nam ipsum risus, rutrum vitae, vestibulum eu, molestie vel, lacus. Sed augue ipsum, egestas nec, vestibulum et, malesuada adipiscing, dui. Vestibulum facilisis, purus nec pulvinar iaculis, ligula mi congue nunc, vitae euismod ligula urna in dolor. Mauris sollicitudin fermentum libero. Praesent nonummy mi in odio. Nunc interdum lacus sit amet orci. Vestibulum rutrum, mi nec elementum vehicula, eros quam gravida nisl, id fringilla neque ante vel mi. Morbi mollis tellus ac sapien. Phasellus volutpat, metus eget egestas mollis, lacus lacus blandit dui, id egestas quam mauris ut lacus. Fusce vel dui. Sed in libero ut nibh placerat accumsan. Proin faucibus arcu quis ante. In consectetuer turpis ut velit. Nulla sit amet est. Praesent metus tellus, elementum eu, semper a, adipiscing nec, purus. Cras risus ipsum, faucibus ut, ullamcorper id, varius ac, leo. Suspendisse feugiat. Suspendisse enim turpis, dictum sed, iaculis a, condimentum nec, nisi. Praesent nec nisl a purus blandit viverra. Praesent ac massa at ligula laoreet iaculis. Nulla neque dolor, sagittis eget, iaculis quis, molestie non, velit. Mauris turpis nunc, blandit et, volutpat molestie, porta ut, ligula. Fusce pharetra convallis urna. Quisque ut nisi. Donec mi odio, faucibus at, scelerisque quis, convallis in, nisi. Suspendisse non nisl sit amet velit hendrerit rutrum. Ut leo. Ut a nisl id ante tempus hendrerit. Proin pretium, leo ac pellentesque mollis, felis nunc ultrices eros, sed gravida augue augue mollis justo. Suspendisse eu ligula. Nulla facilisi. Donec id justo. Praesent porttitor, nulla vitae posuere iaculis, arcu nisl dignissim dolor, a pretium mi sem ut ipsum. Curabitur suscipit suscipit tellus. Praesent vestibulum dapibus nibh. Etiam iaculis nunc ac metus. Ut id nisl quis enim dignissim sagittis. Etiam sollicitudin, ipsum eu pulvinar rutrum, tellus ipsum laoreet sapien, quis venenatis ante odio sit amet eros. Proin magna. Duis vel nibh at velit scelerisque suscipit. Curabitur turpis. Vestibulum suscipit nulla quis orci. Fusce ac felis sit amet ligula pharetra condimentum. Maecenas egestas arcu quis ligula mattis placerat. Duis lobortis massa imperdiet quam. Suspendisse potenti. Pellentesque commodo eros a enim. Vestibulum turpis sem, aliquet eget, lobortis pellentesque, rutrum eu, nisl. Sed libero. Aliquam erat volutpat. Etiam vitae tortor. Morbi vestibulum volutpat enim. Aliquam eu nunc. Nunc sed turpis. Sed mollis, eros et ultrices tempus, mauris ipsum aliquam libero, non adipiscing dolor urna a orci. Nulla porta dolor. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos. Pellentesque dapibus hendrerit tortor. Praesent egestas tristique nibh. Sed a libero. Cras varius. Donec vitae orci sed dolor rutrum auctor. Fusce egestas elit eget lorem. Suspendisse nisl elit, rhoncus eget, elementum ac, condimentum eget, diam. Nam at tortor in tellus interdum sagittis. Aliquam lobortis. Donec orci lectus, aliquam ut, faucibus non, euismod id, nulla. Curabitur blandit mollis lacus. Nam adipiscing. Vestibulum eu odio. Etiam Curabitur Fusce Quisque Jan 8, 2014 8:54:00 AM /blog/categories/etiam-rhoncus TzoyNDoiT2JqZWN0X0RhdGFfSG90c3BvdGltYWdlIjo0OntzOjU6ImltYWdlIjtPOjExOiJBc3NldF9JbWFnZSI6MTU6e3M6NDoidHlwZSI7czo1OiJpbWFnZSI7czoyOiJpZCI7aToyMztzOjg6InBhcmVudElkIjtpOjE3O3M6ODoiZmlsZW5hbWUiO3M6MTI6ImltZ18wNDExLmpwZyI7czo0OiJwYXRoIjtzOjE3OiIvZXhhbXBsZXMvcGFuYW1hLyI7czo4OiJtaW1ldHlwZSI7czoxMDoiaW1hZ2UvanBlZyI7czoxMjoiY3JlYXRpb25EYXRlIjtpOjEzNjg1MzI4Mzc7czoxNjoibW9kaWZpY2F0aW9uRGF0ZSI7aToxMzY4NjMyNDY4O3M6OToidXNlck93bmVyIjtpOjA7czoxNjoidXNlck1vZGlmaWNhdGlvbiI7aTowO3M6ODoibWV0YWRhdGEiO2E6MDp7fXM6NjoibG9ja2VkIjtOO3M6MTQ6ImN1c3RvbVNldHRpbmdzIjthOjM6e3M6MTA6ImltYWdlV2lkdGgiO2k6MjAwMDtzOjExOiJpbWFnZUhlaWdodCI7aToxNTAwO3M6MjU6ImltYWdlRGltZW5zaW9uc0NhbGN1bGF0ZWQiO2I6MTt9czoxNToiACoAX2RhdGFDaGFuZ2VkIjtiOjA7czoyNDoiX19fX3BpbWNvcmVfY2FjaGVfaXRlbV9fIjtzOjE2OiJwaW1jb3JlX2Fzc2V0XzIzIjt9czo4OiJob3RzcG90cyI7YTowOnt9czo2OiJtYXJrZXIiO2E6MDp7fXM6NDoiY3JvcCI7YTo1OntzOjk6ImNyb3BXaWR0aCI7ZDo5OS41OTk5OTk5OTk5OTk5OTQ7czoxMDoiY3JvcEhlaWdodCI7ZDo1MC4xMzMzMzMzMzMzMzMzMzM7czo3OiJjcm9wVG9wIjtkOjE1LjczMzMzMzMzMzMzMzMzMztzOjg6ImNyb3BMZWZ0IjtkOjEuODtzOjExOiJjcm9wUGVyY2VudCI7YjoxO319 ',''),(40,'/examples/italy/dsc04462.jpg','asset','image','image',1,1368596769,1368632468,0,0,'ID: 40  \nPath: /examples/italy/dsc04462.jpg  \ndsc04462.jpg',''),(40,'/en','document','link','link',1,1382956013,1382956551,0,0,'ID: 40  \nPath: /en  \n /','sidebar:/en/sidebar mainNavStartNode:/en leftNavStartNode:/en blog:/en/advanced-examples/blog language:en navigation_name:Home '),(40,'/blog/articles/cum-sociis-natoque-penatibus-et-magnis','object','object','blogArticle',1,1388390120,1388393706,7,7,'ID: 40  \nPath: /blog/articles/cum-sociis-natoque-penatibus-et-magnis  \nCum sociis natoque penatibus et magnis Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetuer vestibulum elit. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Vestibulum fringilla pede sit amet augue. In turpis. Pellentesque posuere. Praesent turpis. Aenean posuere, tortor sed cursus feugiat, nunc augue blandit nunc, eu sollicitudin urna dolor sagittis lacus. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Nullam sagittis. Suspendisse pulvinar, augue ac venenatis condimentum, sem libero volutpat nibh, nec pellentesque velit pede quis nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce id purus. Ut varius tincidunt libero. Phasellus dolor. Maecenas vestibulum mollis diam. Pellentesque ut neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In dui magna, posuere eget, vestibulum et, tempor auctor, justo. In ac felis quis tortor malesuada pretium. Pellentesque auctor neque nec urna. Proin sapien ipsum, porta a, auctor quis, euismod ut, mi. Aenean viverra rhoncus pede. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Fusce Quisque Maecenas Donec Cum sociis natoque penatibus et magnis Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetuer vestibulum elit. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Vestibulum fringilla pede sit amet augue. In turpis. Pellentesque posuere. Praesent turpis. Aenean posuere, tortor sed cursus feugiat, nunc augue blandit nunc, eu sollicitudin urna dolor sagittis lacus. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Nullam sagittis. Suspendisse pulvinar, augue ac venenatis condimentum, sem libero volutpat nibh, nec pellentesque velit pede quis nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce id purus. Ut varius tincidunt libero. Phasellus dolor. Maecenas vestibulum mollis diam. Pellentesque ut neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In dui magna, posuere eget, vestibulum et, tempor auctor, justo. In ac felis quis tortor malesuada pretium. Pellentesque auctor neque nec urna. Proin sapien ipsum, porta a, auctor quis, euismod ut, mi. Aenean viverra rhoncus pede. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Fusce Quisque Maecenas Donec Dec 30, 2013 8:55:00 AM /blog/categories/curabitur-ullamcorper TzoyNDoiT2JqZWN0X0RhdGFfSG90c3BvdGltYWdlIjo0OntzOjU6ImltYWdlIjtPOjExOiJBc3NldF9JbWFnZSI6MTU6e3M6NDoidHlwZSI7czo1OiJpbWFnZSI7czoyOiJpZCI7aToyMDtzOjg6InBhcmVudElkIjtpOjE3O3M6ODoiZmlsZW5hbWUiO3M6MTI6ImltZ18wMDg5LmpwZyI7czo0OiJwYXRoIjtzOjE3OiIvZXhhbXBsZXMvcGFuYW1hLyI7czo4OiJtaW1ldHlwZSI7czoxMDoiaW1hZ2UvanBlZyI7czoxMjoiY3JlYXRpb25EYXRlIjtpOjEzNjg1MzI4MzM7czoxNjoibW9kaWZpY2F0aW9uRGF0ZSI7aToxMzY4NjMyNDY4O3M6OToidXNlck93bmVyIjtpOjA7czoxNjoidXNlck1vZGlmaWNhdGlvbiI7aTowO3M6ODoibWV0YWRhdGEiO2E6MDp7fXM6NjoibG9ja2VkIjtOO3M6MTQ6ImN1c3RvbVNldHRpbmdzIjthOjM6e3M6MTA6ImltYWdlV2lkdGgiO2k6MjAwMDtzOjExOiJpbWFnZUhlaWdodCI7aToxNTAwO3M6MjU6ImltYWdlRGltZW5zaW9uc0NhbGN1bGF0ZWQiO2I6MTt9czoxNToiACoAX2RhdGFDaGFuZ2VkIjtiOjA7czoyNDoiX19fX3BpbWNvcmVfY2FjaGVfaXRlbV9fIjtzOjE2OiJwaW1jb3JlX2Fzc2V0XzIwIjt9czo4OiJob3RzcG90cyI7YTowOnt9czo2OiJtYXJrZXIiO2E6MDp7fXM6NDoiY3JvcCI7YTo1OntzOjk6ImNyb3BXaWR0aCI7ZDo5OC43OTk5OTk5OTk5OTk5OTc7czoxMDoiY3JvcEhlaWdodCI7ZDo1NC4xMzMzMzMzMzMzMzMzMzM7czo3OiJjcm9wVG9wIjtkOjI3LjQ2NjY2NjY2NjY2NjY2NTtzOjg6ImNyb3BMZWZ0IjtpOjI7czoxMToiY3JvcFBlcmNlbnQiO2I6MTt9fQ== ',''),(41,'/examples/italy/dsc04399.jpg','asset','image','image',1,1368596770,1368632468,0,0,'ID: 41  \nPath: /examples/italy/dsc04399.jpg  \ndsc04399.jpg',''),(41,'/de','document','page','page',1,1382956716,1382962917,0,0,'ID: 41  \nPath: /de  \nAlbert Einstein 3 Bereit beeindruckt zu werden? Es wird dich umhauen! Oh ja, es ist wirklich so gut See it in Action See it in Action Checkmate In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Donec ullamcorper nulla non metus auctor fringilla. Vestibulum id ligula porta felis euismod semper. Praesent commodo cursus magna, vel scelerisque nisl consectetur. Fusce dapibus, tellus ac cursus commodo. Donec ullamcorper nulla non metus auctor fringilla. Vestibulum id ligula porta felis euismod semper. Praesent commodo cursus magna, vel scelerisque nisl consectetur. Fusce dapibus, tellus ac cursus commodo. Teste unsere Beispiele und tauche ein in die nächste Generation von digitalem Inhaltsmanagement Sieh\' selbst Sieh\' selbst! Lorem ipsum. Oh yeah, it\'s that good. And lastly, this one. left left We can\'t solve problems by using the same kind of thinking we used when we created them. Cum sociis. See for yourself. Checkmate. video ','blog:/en/advanced-examples/blog mainNavStartNode:/de sidebar:/de/sidebar leftNavStartNode:/de language:de navigation_name:Startseite '),(41,'/crm/newsletter','object','folder','folder',1,1388408967,1388408967,0,0,'ID: 41  \nPath: /crm/newsletter  \nnewsletter',''),(42,'/examples/south-africa','asset','folder','folder',1,1368596785,1368632468,0,0,'ID: 42  \nPath: /examples/south-africa  \nsouth-africa',''),(42,'/de/shared','document','folder','folder',1,1382956884,1382956887,0,0,'ID: 42  \nPath: /de/shared  \nshared','blog:/en/advanced-examples/blog mainNavStartNode:/de sidebar:/de/sidebar leftNavStartNode:/de language:de '),(42,'/crm/inquiries','object','folder','folder',1,1388409135,1388409135,0,0,'ID: 42  \nPath: /crm/inquiries  \ninquiries',''),(43,'/examples/south-africa/img_1414.jpg','asset','image','image',1,1368596789,1368632468,0,0,'ID: 43  \nPath: /examples/south-africa/img_1414.jpg  \nimg_1414.jpg',''),(43,'/de/shared/includes','document','folder','folder',1,1382956885,1382956888,0,0,'ID: 43  \nPath: /de/shared/includes  \nincludes','blog:/en/advanced-examples/blog mainNavStartNode:/de sidebar:/de/sidebar leftNavStartNode:/de language:de '),(44,'/examples/south-africa/img_2133.jpg','asset','image','image',1,1368596791,1368632468,0,0,'ID: 44  \nPath: /examples/south-africa/img_2133.jpg  \nimg_2133.jpg',''),(44,'/de/shared/teasers','document','folder','folder',1,1382956885,1382956888,0,0,'ID: 44  \nPath: /de/shared/teasers  \nteasers','blog:/en/advanced-examples/blog mainNavStartNode:/de sidebar:/de/sidebar leftNavStartNode:/de language:de '),(45,'/examples/south-africa/img_2240.jpg','asset','image','image',1,1368596793,1368632468,0,0,'ID: 45  \nPath: /examples/south-africa/img_2240.jpg  \nimg_2240.jpg',''),(45,'/de/shared/teasers/standard','document','folder','folder',1,1382956885,1382956888,0,0,'ID: 45  \nPath: /de/shared/teasers/standard  \nstandard','blog:/en/advanced-examples/blog mainNavStartNode:/de sidebar:/de/sidebar leftNavStartNode:/de language:de '),(46,'/examples/south-africa/img_1752.jpg','asset','image','image',1,1368596795,1368632468,0,0,'ID: 46  \nPath: /examples/south-africa/img_1752.jpg  \nimg_1752.jpg',''),(46,'/de/shared/includes/footer','document','snippet','snippet',1,1382956886,1382956919,0,0,'ID: 46  \nPath: /de/shared/includes/footer  \npimcore.org Dokumentation Bug Tracker Designed and built with all the love in the world by&nbsp;@mdo&nbsp;and&nbsp;@fat. Code licensed under&nbsp;Apache License v2.0,&nbsp;Glyphicons Free&nbsp;licensed under&nbsp;CC BY 3.0. © Templates pimcore.org licensed under BSD License ','blog:/en/advanced-examples/blog mainNavStartNode:/de sidebar:/de/sidebar leftNavStartNode:/de language:de '),(47,'/examples/south-africa/img_1739.jpg','asset','image','image',1,1368596798,1368632468,0,0,'ID: 47  \nPath: /examples/south-africa/img_1739.jpg  \nimg_1739.jpg',''),(47,'/de/shared/teasers/standard/basic-examples','document','snippet','snippet',1,1382956886,1382957000,0,0,'ID: 47  \nPath: /de/shared/teasers/standard/basic-examples  \n Voll Responsive Lorem ipsum Diese Demo basiert auf Bootstrap, dem wohl bekanntesten,&nbsp;beliebtesten und flexibelsten Fontend-Framework. ','blog:/en/advanced-examples/blog mainNavStartNode:/de sidebar:/de/sidebar leftNavStartNode:/de language:de '),(47,'/crm/newsletter/pimcore-byom.de~7a3','object','object','person',1,1388412533,1388412544,0,0,'ID: 47  \nPath: /crm/newsletter/pimcore-byom.de~7a3  \nmale Demo User pimcore@byom.de 1 1 Dec 30, 2013 3:08:54 PM ','token:YTozOntzOjQ6InNhbHQiO3M6MzI6IjNlMGRkYTk3MWU1YTY5MWViYmM0OGVkNGQ5NzA4MDFmIjtzOjU6ImVtYWlsIjtzOjE1OiJwaW1jb3JlQGJ5b20uZGUiO3M6MjoiaWQiO2k6NDc7fQ== '),(48,'/examples/south-africa/img_0391.jpg','asset','image','image',1,1368596800,1368632468,0,0,'ID: 48  \nPath: /examples/south-africa/img_0391.jpg  \nimg_0391.jpg',''),(48,'/de/shared/teasers/standard/advanced-examples','document','snippet','snippet',1,1382956886,1382957114,0,0,'ID: 48  \nPath: /de/shared/teasers/standard/advanced-examples  \n Drag & Drop Inhaltserstellung Etiam rhoncu Inhalt wird einfach per drag &amp; drop mit Inhaltsblöcken erstellt, welche dann direkt in-line editiert werden können. ','blog:/en/advanced-examples/blog mainNavStartNode:/de sidebar:/de/sidebar leftNavStartNode:/de language:de '),(49,'/examples/south-africa/img_2155.jpg','asset','image','image',1,1368596801,1368632468,0,0,'ID: 49  \nPath: /examples/south-africa/img_2155.jpg  \nimg_2155.jpg',''),(49,'/de/shared/teasers/standard/experiments','document','snippet','snippet',1,1382956887,1382957197,0,0,'ID: 49  \nPath: /de/shared/teasers/standard/experiments  \n HTML5 immer & überall Quisque rutrum &nbsp; Bilder direkt per drag &amp; drop vom Desktop&nbsp;in den Baum in pimcore hochladen, automatische HTML5 Video Konvertierung&nbsp;und viel mehr ... ','blog:/en/advanced-examples/blog mainNavStartNode:/de sidebar:/de/sidebar leftNavStartNode:/de language:de '),(50,'/examples/south-africa/img_1544.jpg','asset','image','image',1,1368596804,1368632468,0,0,'ID: 50  \nPath: /examples/south-africa/img_1544.jpg  \nimg_1544.jpg',''),(50,'/de/einfuehrung','document','page','page',1,1382957658,1382957760,0,0,'ID: 50  \nPath: /de/einfuehrung  \n Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. &nbsp; Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. &nbsp; Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. Omnicos directe al desirabilite de un nov lingua franca: On refusa continuar payar custosi traductores. At solmen va esser necessi far uniform grammatica, pronunciation e plu sommun paroles. &nbsp; It va esser tam simplic quam Occidental in fact, it va esser Occidental. A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge amico dit me que Occidental es. Li Europan lingues es membres del sam familie. Lor separat existentie es un myth. Por scientie, musica, sport etc, litot Europa usa li sam vocabular. Li lingues differe solmen in li grammatica, li pronunciation e li plu commun vocabules. &nbsp; Donec ullamcorper nulla non metus auctor fringilla. Vestibulum id ligula porta felis euismod semper. Praesent commodo cursus magna, vel scelerisque nisl consectetur. Fusce dapibus, tellus ac cursus commodo. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Überblick über das Projekt und wie man mit einer einfachen Vorlage loslegen kann. Einführung Ullamcorper Scelerisque Erste Schritte Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Etiam rhoncu Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. snippet snippet ','blog:/en/advanced-examples/blog mainNavStartNode:/de sidebar:/de/sidebar leftNavStartNode:/de language:de navigation_name:Einführung '),(51,'/examples/south-africa/img_1842.jpg','asset','image','image',1,1368596806,1368632468,0,0,'ID: 51  \nPath: /examples/south-africa/img_1842.jpg  \nimg_1842.jpg',''),(51,'/de/einfache-beispiele','document','page','page',1,1382957793,1382957910,0,0,'ID: 51  \nPath: /de/einfache-beispiele  \n Übersicht über einfache Beispiele Diese Seite dient nur zur Demonstration einer mehrsprachigen Seite.&nbsp; Um die Beispiele zu sehen verwende bitte die Englische Beispielseite.&nbsp; Einfache Beispiele ','blog:/en/advanced-examples/blog mainNavStartNode:/de sidebar:/de/sidebar leftNavStartNode:/de language:de navigation_name:Einfache Beispiele '),(52,'/examples/south-africa/img_1920.jpg','asset','image','image',1,1368596808,1368632468,0,0,'ID: 52  \nPath: /examples/south-africa/img_1920.jpg  \nimg_1920.jpg',''),(52,'/de/beispiele-fur-fortgeschrittene','document','page','page',1,1382957961,1382957999,0,0,'ID: 52  \nPath: /de/beispiele-fur-fortgeschrittene  \n Übersicht über fortgeschrittene Beispiele Diese Seite dient nur zur Demonstration einer mehrsprachigen Seite.&nbsp; Um die Beispiele zu sehen verwende bitte die Englische Beispielseite.&nbsp; Beispiele für Fortgeschrittene ','blog:/en/advanced-examples/blog mainNavStartNode:/de sidebar:/de/sidebar leftNavStartNode:/de language:de navigation_name:Beispiele für Fortgeschrittene '),(53,'/examples/south-africa/img_0322.jpg','asset','image','image',1,1368596810,1368632468,0,0,'ID: 53  \nPath: /examples/south-africa/img_0322.jpg  \nimg_0322.jpg',''),(53,'/de/einfache-beispiele/neuigkeiten','document','page','page',1,1382958188,1382958240,0,0,'ID: 53  \nPath: /de/einfache-beispiele/neuigkeiten  \n Neuigkeiten Alle strukturierten Daten werden in \"Objects\" gespeichert.&nbsp; ','blog:/en/advanced-examples/blog sidebar:/de/sidebar mainNavStartNode:/de language:de leftNavStartNode:/de navigation_name:Neuigkeiten '),(54,'/examples/singapore','asset','folder','folder',1,1368596871,1368632468,0,0,'ID: 54  \nPath: /examples/singapore  \nsingapore',''),(55,'/examples/singapore/dsc03778.jpg','asset','image','image',1,1368597116,1368632468,0,0,'ID: 55  \nPath: /examples/singapore/dsc03778.jpg  \ndsc03778.jpg',''),(56,'/examples/singapore/dsc03807.jpg','asset','image','image',1,1368597117,1368632468,0,0,'ID: 56  \nPath: /examples/singapore/dsc03807.jpg  \ndsc03807.jpg',''),(57,'/examples/singapore/dsc03835.jpg','asset','image','image',1,1368597119,1368632468,0,0,'ID: 57  \nPath: /examples/singapore/dsc03835.jpg  \ndsc03835.jpg',''),(57,'/en/sidebar','document','snippet','snippet',1,1382962826,1388735598,0,0,'ID: 57  \nPath: /en/sidebar  \n3 ','sidebar:/en/sidebar mainNavStartNode:/en leftNavStartNode:/en language:en blog:/en/advanced-examples/blog '),(58,'/de/sidebar','document','snippet','snippet',1,1382962891,1382962906,0,0,'ID: 58  \nPath: /de/sidebar  \n ','blog:/en/advanced-examples/blog mainNavStartNode:/de sidebar:/de/sidebar leftNavStartNode:/de language:de '),(59,'/screenshots/thumbnail-configuration.png','asset','image','image',1,1368606782,1368632470,0,0,'ID: 59  \nPath: /screenshots/thumbnail-configuration.png  \nthumbnail-configuration.png',''),(59,'/en/introduction/sidebar','document','snippet','snippet',1,1382962940,1388738272,0,0,'ID: 59  \nPath: /en/introduction/sidebar  \n2 ','sidebar:/en/introduction/sidebar mainNavStartNode:/en leftNavStartNode:/en blog:/en/advanced-examples/blog language:en '),(60,'/screenshots/website-translations.png','asset','image','image',1,1368608949,1368632470,0,0,'ID: 60  \nPath: /screenshots/website-translations.png  \nwebsite-translations.png',''),(60,'/en/advanced-examples/blog','document','page','page',1,1388391128,1395043669,7,0,'ID: 60  \nPath: /en/advanced-examples/blog  \n Blog A blog is also just a simple list of objects. You can easily modify the structure of an article in Settings -&gt; Object -&gt; Classes.&nbsp; A blog is also just a simple list of objects. You can easily modify the structure of an article in Settings -&gt; Object -&gt; Classes. Blog ','sidebar:/en/advanced-examples/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/advanced-examples language:en navigation_name:Blog '),(61,'/screenshots/properties-1.png','asset','image','image',1,1368616805,1368632470,0,0,'ID: 61  \nPath: /screenshots/properties-1.png  \nproperties-1.png',''),(61,'/en/advanced-examples/sitemap','document','page','page',1,1388406334,1388406406,0,0,'ID: 61  \nPath: /en/advanced-examples/sitemap  \n Auto-generated Sitemap Sitemap ','sidebar:/en/advanced-examples/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/advanced-examples language:en navigation_name:Sitemap '),(62,'/screenshots/properties-2.png','asset','image','image',1,1368616805,1368632470,0,0,'ID: 62  \nPath: /screenshots/properties-2.png  \nproperties-2.png',''),(62,'/newsletters','document','folder','folder',1,1388409377,1388409377,0,0,'ID: 62  \nPath: /newsletters  \nnewsletters','sidebar:/en/sidebar mainNavStartNode:/en leftNavStartNode:/en language:en blog:/en/advanced-examples/blog '),(63,'/screenshots/properties-3.png','asset','image','image',1,1368616847,1368632470,0,0,'ID: 63  \nPath: /screenshots/properties-3.png  \nproperties-3.png',''),(63,'/en/advanced-examples/newsletter','document','page','page',1,1388409438,1388409571,0,0,'ID: 63  \nPath: /en/advanced-examples/newsletter  \n Newsletter Newsletter ','sidebar:/en/advanced-examples/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/advanced-examples language:en navigation_name:Newsletter '),(64,'/screenshots/tag-snippet-management.png','asset','image','image',1,1368617634,1368632470,0,0,'ID: 64  \nPath: /screenshots/tag-snippet-management.png  \ntag-snippet-management.png',''),(64,'/en/advanced-examples/newsletter/confirm','document','page','page',1,1388409594,1388409641,0,0,'ID: 64  \nPath: /en/advanced-examples/newsletter/confirm  \n ','blog:/en/advanced-examples/blog mainNavStartNode:/en sidebar:/en/advanced-examples/sidebar leftNavStartNode:/en/advanced-examples language:en navigation_name: '),(65,'/screenshots/objects-forms.png','asset','image','image',1,1368623266,1368632470,0,0,'ID: 65  \nPath: /screenshots/objects-forms.png  \nobjects-forms.png',''),(65,'/en/advanced-examples/newsletter/unsubscribe','document','page','page',1,1388409614,1388412346,0,0,'ID: 65  \nPath: /en/advanced-examples/newsletter/unsubscribe  \n Newsletter Unsubscribe Unsubscribe ','blog:/en/advanced-examples/blog mainNavStartNode:/en sidebar:/en/advanced-examples/sidebar leftNavStartNode:/en/advanced-examples language:en navigation_name:Unsubscribe '),(66,'/documents/example-excel.xlsx','asset','document','document',1,1378992590,1378992590,0,0,'ID: 66  \nPath: /documents/example-excel.xlsx  \nexample-excel.xlsx Firmenname Zwölf Monate GEWINN- UND VERLUSTPROJEKTION JÄN 12 UMSATZ (VERKAUF) TREND FEB 12 GESCHÄFTSJAHR BEGINNT: MÄR 12 APR 12Y MAI 12 JUN 12 JUL 12 AUG 12 SEP 12 OKT 12 NOV 12 DEZ 12 JÄHRLICH IND % J% F% M% A% M% J% J% A% S% O% N% JAN 2012 D% JAHR % TREND TREND TREND TREND TREND TREND TREND TREND TREND TREND TREND TREND TRENDTRENDTRENDRENDRENDRENDRENDRENDRENDRENDRENDRENDRENDREND TREND Umsatz 1 186.00 € 108.00 € 92.00 € 122.00 € 190.00 € 71.00 € 21.00 € 37.00 € 24.00 € 178.00 € 92.00 € 97.00 € Err:508 12% Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Umsatz 2 15.00 € 16.00 € 198.00 € 44.00 € 25.00 € 68.00 € 43.00 € 119.00 € 37.00 € 118.00 € 29.00 € 171.00 € Err:508 18% Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Umsatz 3 166.00 € 185.00 € 89.00 € 170.00 € 131.00 € 70.00 € 50.00 € 149.00 € 179.00 € 104.00 € 119.00 € 187.00 € Err:508 19% Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Umsatz 4 21.00 € 113.00 € 83.00 € 17.00 € 130.00 € 26.00 € 167.00 € 102.00 € 82.00 € 33.00 € 88.00 € 193.00 € Err:508 11% Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Umsatz 5 70.00 € 160.00 € 125.00 € 84.00 € 191.00 € 97.00 € 52.00 € 45.00 € 173.00 € 136.00 € 144.00 € 167.00 € Err:508 20% Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Umsatz 6 61.00 € 99.00 € 70.00 € 162.00 € 28.00 € 163.00 € 101.00 € 103.00 € 78.00 € 33.00 € 162.00 € 159.00 € Err:508 10% Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Umsatz 7 105.00 € 55.00 € 163.00 € 12.00 € 117.00 € 83.00 € 163.00 € 120.00 € 171.00 € 79.00 € 105.00 € 69.00 € Err:508 10% Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 GESAMTUMSATZ UMSATZKOSTEN Err:508 TREND Err:508 TREND TREND Err:508 TREND Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 TREND TREND TREND TREND TREND TREND TREND TREND Err:508 TREND Err:508 TREND TREND TREND TREND TREND TREND TREND TREND TREND TREND TREND TREND TREND TREND TREND Kosten 1 61.00 € 78.00 € 65.00 € 29.00 € 125.00 € 49.00 € 14.00 € 26.00 € 14.00 € 129.00 € 60.00 € 65.00 € Err:508 12% Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Kosten 2 7.00 € 5.00 € 69.00 € 32.00 € 11.00 € 30.00 € 27.00 € 32.00 € 10.00 € 41.00 € 13.00 € 105.00 € Err:508 18% Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Kosten 3 99.00 € 95.00 € 51.00 € 90.00 € 21.00 € 34.00 € 30.00 € 24.00 € 109.00 € 16.00 € 21.00 € 52.00 € Err:508 19% Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Kosten 4 13.00 € 28.00 € 15.00 € 8.00 € 84.00 € 12.00 € 54.00 € 72.00 € 49.00 € 24.00 € 60.00 € 39.00 € Err:508 11% Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Kosten 5 34.00 € 78.00 € 43.00 € 30.00 € 77.00 € 54.00 € 26.00 € 13.00 € 56.00 € 30.00 € 40.00 € 63.00 € Err:508 20% Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Kosten 6 33.00 € 61.00 € 42.00 € 43.00 € 19.00 € 94.00 € 46.00 € 15.00 € 55.00 € 15.00 € 37.00 € 89.00 € Err:508 10% Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Kosten 7 18.00 € 11.00 € 30.00 € 9.00 € 62.00 € 39.00 € 102.00 € 44.00 € 121.00 € 19.00 € 33.00 € 40.00 € Err:508 10% Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 7% Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 SUMME UMSATZKOSTEN Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Bruttogewinn Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 TREND TREND TREND TREND TREND TREND TREND TREND TREND TREND TREND TREND AUSGABEN TREND Gehaltsaufwendungen 10.00 € 18.00 € 13.00 € 8.00 € 22.00 € 18.00 € 8.00 € 17.00 € 20.00 € 8.00 € 4.00 € Personalaufwand 23.00 € 11.00 € 7.00 € 14.00 € 12.00 € 19.00 € 19.00 € 4.00 € 7.00 € 13.00 € Fremdleistungen 23.00 € 20.00 € 3.00 € 16.00 € 10.00 € 5.00 € 20.00 € 7.00 € 4.00 € 22.00 € Energie (Büro und Betrieb) 19.00 € 4.00 € 7.00 € 14.00 € 22.00 € 10.00 € 22.00 € 5.00 € 4.00 € Reparaturen und Wartung 11.00 € 11.00 € 17.00 € 12.00 € 2.00 € 14.00 € 12.00 € 10.00 € Werbung 2.00 € 16.00 € 6.00 € 13.00 € 11.00 € 22.00 € 21.00 € Kfz, Lieferungen und Reisen 8.00 € 17.00 € 11.00 € 11.00 € 21.00 € 9.00 € Buchhaltung und Rechtsabteilung 5.00 € 13.00 € 6.00 € 15.00 € 19.00 € TRENDTREND TREND TREND TREND TREND TREND TREND TREND TREND TREND TREND TREND TREND TREND 12.00 € Err:508 12% Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 25.00 € 5.00 € Err:508 9% Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 13.00 € 14.00 € Err:508 2% Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 12.00 € 18.00 € 24.00 € Err:508 8% Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 18.00 € 11.00 € 23.00 € 11.00 € Err:508 3% Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 3.00 € 12.00 € 7.00 € 17.00 € 20.00 € Err:508 15% Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 20.00 € 3.00 € 14.00 € 22.00 € 16.00 € 12.00 € Err:508 12% Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 10.00 € 12.00 € 9.00 € 15.00 € 16.00 € 4.00 € 9.00 € Err:508 9% Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Miete 8.00 € 4.00 € 23.00 € 25.00 € 10.00 € 24.00 € 22.00 € 5.00 € 12.00 € 24.00 € 24.00 € 12.00 € Err:508 1% Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Telefon 25.00 € 2.00 € 12.00 € 25.00 € 10.00 € 24.00 € 3.00 € 20.00 € 3.00 € 9.00 € 20.00 € 18.00 € Err:508 1% Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Nebenkosten 16.00 € 19.00 € 9.00 € 16.00 € 13.00 € 2.00 € 4.00 € 24.00 € 16.00 € 22.00 € 7.00 € 18.00 € Err:508 1% Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Versicherung 12.00 € 9.00 € 16.00 € 19.00 € 25.00 € 17.00 € 20.00 € 14.00 € 5.00 € 14.00 € 5.00 € 2.00 € Err:508 1% Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Steuern (Grundsteuer usw.) 16.00 € 13.00 € 10.00 € 7.00 € 13.00 € 3.00 € 13.00 € 17.00 € 9.00 € 4.00 € 22.00 € 18.00 € Err:508 14% Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Zinsen 3.00 € 2.00 € 19.00 € 21.00 € 13.00 € 9.00 € 7.00 € 13.00 € 3.00 € 6.00 € 10.00 € 13.00 € Err:508 6% Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Abschreibung 8.00 € 7.00 € 6.00 € 7.00 € 6.00 € 15.00 € 23.00 € 21.00 € 16.00 € 19.00 € 7.00 € Err:508 1% Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Sonstige Ausgaben (angeben) 14.00 € 4.00 € 24.00 € 6.00 € 20.00 € ### 14.00 € 21.00 € 20.00 € 22.00 € 3.00 € 14.00 € 6.00 € Err:508 1% Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Sonstige Ausgaben (angeben) 14.00 € 7.00 € 24.00 € 10.00 € 7.00 € 24.00 € 2.00 € 11.00 € 21.00 € 19.00 € 19.00 € 20.00 € Err:508 1% Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Sonstige Ausgaben (angeben) 11.00 € 8.00 € 25.00 € 11.00 € 9.00 € 24.00 € 13.00 € 14.00 € 19.00 € 24.00 € 15.00 € 7.00 € Err:508 1% Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Sonstiges (nicht angegeben) 8.00 € 20.00 € 11.00 € 11.00 € 20.00 € 12.00 € 16.00 € 5.00 € 7.00 € 21.00 € 3.00 € Err:508 2% Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 7% Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 ### GESAMTAUSGABEN Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Err:508 Reingewinn Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 Err:509 ',''),(66,'/en/advanced-examples/newsletter/confirmation-email','document','email','email',1,1388409670,1388412587,0,0,'ID: 66  \nPath: /en/advanced-examples/newsletter/confirmation-email  \nContact Info Example Inc. Evergreen Terrace 123 XX 89234 Springfield +8998 487563 34234 info@example.inc Hi %Text(firstname);&nbsp;%Text(lastname);,&nbsp; &nbsp; You have just subscribed our cool newsletter with the email address: %Text(email);.&nbsp; To finish the process please click the following link to confirm your email address.&nbsp; &nbsp; CLICK HERE TO CONFIRM &nbsp; Thanks &amp; have a nice day! Terms Privacy About ','sidebar:/en/advanced-examples/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/advanced-examples language:en navigation_name:Newsletter '),(67,'/documents/example.docx','asset','document','document',1,1378992591,1378992591,0,0,'ID: 67  \nPath: /documents/example.docx  \nexample.docx ﻿Example Document Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. One Two Three Four 1,23134.032 123.123 Some Value Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam semper libero, sit amet adipiscing sem neque sed ipsum. Consectetuer adipiscing elit Aenean commodo ligula eget dolor Aenean massa. 1. Cum sociis natoque penatibus et magnis dis parturient montes 2. Nascetur ridiculus mus. Donec quam felis, ultricies nec 3. Pellentesque eu, pretium quis, sem 4. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, ',''),(67,'/newsletters/example-mailing','document','email','email',1,1388412605,1388412917,0,0,'ID: 67  \nPath: /newsletters/example-mailing  \nContact Info Example Inc. Evergreen Terrace 123 XX 89234 Springfield +8998 487563 34234 info@example.inc Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. &nbsp; &nbsp; &nbsp; Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante.&nbsp; &nbsp; &nbsp; &nbsp; Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. &nbsp; Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Terms Privacy Unsubscribe ','sidebar:/en/sidebar mainNavStartNode:/en leftNavStartNode:/en language:en blog:/en/advanced-examples/blog '),(68,'/documents/example.pptx','asset','document','document',1,1378992592,1378992592,0,0,'ID: 68  \nPath: /documents/example.pptx  \nexample.pptx Example Just a simple example Image Example ',''),(68,'/en/advanced-examples/asset-thumbnail-list','document','page','page',1,1388414727,1388414883,0,0,'ID: 68  \nPath: /en/advanced-examples/asset-thumbnail-list  \n Asset Thumbnail List Asset Thumbnail List ','sidebar:/en/advanced-examples/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/advanced-examples language:en navigation_name:Asset Thumbnail List '),(69,'/screenshots/e-commerce1.png','asset','image','image',1,1388740480,1388740490,0,0,'ID: 69  \nPath: /screenshots/e-commerce1.png  \ne-commerce1.png',''),(69,'/en/advanced-examples/sidebar','document','snippet','snippet',1,1388734403,1388738477,0,0,'ID: 69  \nPath: /en/advanced-examples/sidebar  \n ','sidebar:/en/advanced-examples/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/advanced-examples language:en '),(70,'/screenshots/pim1.png','asset','image','image',1,1388740572,1388740580,0,0,'ID: 70  \nPath: /screenshots/pim1.png  \npim1.png',''),(70,'/en/advanced-examples/product-information-management','document','page','page',1,1388740191,1388740585,0,0,'ID: 70  \nPath: /en/advanced-examples/product-information-management  \n Please visit our&nbsp;PIM, E-Commerce &amp; Asset Management demo to see it in action.&nbsp; Product Information Management Product Information Management ','sidebar:/en/advanced-examples/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/advanced-examples language:en navigation_name:Product Information Management '),(71,'/en/advanced-examples/e-commerce','document','page','page',1,1388740265,1388740613,0,0,'ID: 71  \nPath: /en/advanced-examples/e-commerce  \n Please visit our&nbsp;PIM, E-Commerce &amp; Asset Management demo to see it in action.&nbsp; E-Commerce E-Commerce ','sidebar:/en/advanced-examples/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/advanced-examples language:en navigation_name:E-Commerce '),(72,'/en/advanced-examples/sub-modules','document','page','page',1,1419933647,1419933980,32,32,'ID: 72  \nPath: /en/advanced-examples/sub-modules  \n ','sidebar:/en/advanced-examples/sidebar blog:/en/advanced-examples/blog mainNavStartNode:/en leftNavStartNode:/en/advanced-examples language:en navigation_title: navigation_target: navigation_name:Sub-Modules navigation_exclude: ');
/*!40000 ALTER TABLE `search_backend_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sites`
--

DROP TABLE IF EXISTS `sites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sites` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `mainDomain` varchar(255) DEFAULT NULL,
  `domains` text,
  `rootId` int(11) unsigned DEFAULT NULL,
  `errorDocument` varchar(255) DEFAULT NULL,
  `redirectToMainDomain` tinyint(1) DEFAULT NULL,
  `creationDate` bigint(20) unsigned DEFAULT '0',
  `modificationDate` bigint(20) unsigned DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `rootId` (`rootId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sites`
--

LOCK TABLES `sites` WRITE;
/*!40000 ALTER TABLE `sites` DISABLE KEYS */;
/*!40000 ALTER TABLE `sites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `parentId` int(10) unsigned DEFAULT NULL,
  `idPath` varchar(255) DEFAULT NULL,
  `name` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idpath` (`idPath`),
  KEY `parentid` (`parentId`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tags`
--

LOCK TABLES `tags` WRITE;
/*!40000 ALTER TABLE `tags` DISABLE KEYS */;
INSERT INTO `tags` VALUES (12,0,'/','imagetype'),(13,0,'/','format'),(14,0,'/','country'),(15,13,'/13/','portrait'),(16,13,'/13/','landscape'),(17,12,'/12/','jpg'),(18,12,'/12/','png'),(19,14,'/14/','italy'),(20,14,'/14/','panama'),(21,14,'/14/','singapore'),(22,14,'/14/','south-africa'),(23,12,'/12/','screenshot'),(25,12,'/12/','svg');
/*!40000 ALTER TABLE `tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags_assignment`
--

DROP TABLE IF EXISTS `tags_assignment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags_assignment` (
  `tagid` int(10) unsigned NOT NULL DEFAULT '0',
  `cid` int(10) NOT NULL DEFAULT '0',
  `ctype` enum('document','asset','object') NOT NULL,
  PRIMARY KEY (`tagid`,`cid`,`ctype`),
  KEY `ctype` (`ctype`),
  KEY `ctype_cid` (`cid`,`ctype`),
  KEY `tagid` (`tagid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tags_assignment`
--

LOCK TABLES `tags_assignment` WRITE;
/*!40000 ALTER TABLE `tags_assignment` DISABLE KEYS */;
/*!40000 ALTER TABLE `tags_assignment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `targeting_personas`
--

DROP TABLE IF EXISTS `targeting_personas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `targeting_personas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `description` text,
  `conditions` longtext,
  `threshold` int(11) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `targeting_personas`
--

LOCK TABLES `targeting_personas` WRITE;
/*!40000 ALTER TABLE `targeting_personas` DISABLE KEYS */;
/*!40000 ALTER TABLE `targeting_personas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `targeting_rules`
--

DROP TABLE IF EXISTS `targeting_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `targeting_rules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `description` text,
  `scope` varchar(50) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `conditions` longtext,
  `actions` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `targeting_rules`
--

LOCK TABLES `targeting_rules` WRITE;
/*!40000 ALTER TABLE `targeting_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `targeting_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tmp_store`
--

DROP TABLE IF EXISTS `tmp_store`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tmp_store` (
  `id` varchar(255) NOT NULL DEFAULT '',
  `tag` varchar(255) DEFAULT NULL,
  `data` longtext,
  `serialized` tinyint(2) NOT NULL DEFAULT '0',
  `date` int(10) DEFAULT NULL,
  `expiryDate` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `tag` (`tag`),
  KEY `date` (`date`),
  KEY `expiryDate` (`expiryDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tmp_store`
--

LOCK TABLES `tmp_store` WRITE;
/*!40000 ALTER TABLE `tmp_store` DISABLE KEYS */;
/*!40000 ALTER TABLE `tmp_store` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tracking_events`
--

DROP TABLE IF EXISTS `tracking_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tracking_events` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `category` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `data` varchar(255) DEFAULT NULL,
  `timestamp` bigint(20) unsigned DEFAULT NULL,
  `year` int(5) unsigned DEFAULT NULL,
  `month` int(2) unsigned DEFAULT NULL,
  `day` int(2) unsigned DEFAULT NULL,
  `dayOfWeek` int(1) unsigned DEFAULT NULL,
  `dayOfYear` int(3) unsigned DEFAULT NULL,
  `weekOfYear` int(2) unsigned DEFAULT NULL,
  `hour` int(2) unsigned DEFAULT NULL,
  `minute` int(2) unsigned DEFAULT NULL,
  `second` int(2) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `timestamp` (`timestamp`),
  KEY `year` (`year`),
  KEY `month` (`month`),
  KEY `day` (`day`),
  KEY `dayOfWeek` (`dayOfWeek`),
  KEY `dayOfYear` (`dayOfYear`),
  KEY `weekOfYear` (`weekOfYear`),
  KEY `hour` (`hour`),
  KEY `minute` (`minute`),
  KEY `second` (`second`),
  KEY `category` (`category`),
  KEY `action` (`action`),
  KEY `label` (`label`),
  KEY `data` (`data`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tracking_events`
--

LOCK TABLES `tracking_events` WRITE;
/*!40000 ALTER TABLE `tracking_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `tracking_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translations_admin`
--

DROP TABLE IF EXISTS `translations_admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translations_admin` (
  `key` varchar(255) NOT NULL DEFAULT '',
  `language` varchar(10) NOT NULL DEFAULT '',
  `text` text,
  `creationDate` bigint(20) unsigned DEFAULT NULL,
  `modificationDate` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`key`,`language`),
  KEY `language` (`language`),
  KEY `key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translations_admin`
--

LOCK TABLES `translations_admin` WRITE;
/*!40000 ALTER TABLE `translations_admin` DISABLE KEYS */;
INSERT INTO `translations_admin` VALUES ('blockquote','de','',1368611528,1368611528),('blockquote','en','',1368611528,1368611528),('blog','en','',1388389180,1388389180),('blogarticle','en','Blog Article',1388389510,1388396937),('blogcategories','en','',1388389420,1388389420),('blogcategory','en','Blog Category',1388389840,1388396950),('categories','en','',1388389661,1388389661),('content-page','en','',1368523214,1368523214),('contents','en','',1382958363,1382958363),('date','en','',1368613497,1368613497),('dateregister','en','',1368621929,1368621929),('email','en','',1368621928,1368621928),('featurette ','de','',1368608412,1368608412),('featurette ','en','',1368608412,1368608412),('female','en','',1368621928,1368621928),('firstname','en','',1368621928,1368621928),('gallery (carousel)','de','',NULL,NULL),('gallery (carousel)','en','',NULL,NULL),('gallery (folder)','de','',1368608412,1368608412),('gallery (folder)','en','',1368608412,1368608412),('gallery (single)','de','',1368608412,1368608412),('gallery (single)','en','',1368608412,1368608412),('gender','en','',1368621928,1368621928),('header color','en','',1368616347,1368616347),('headlines','de','',NULL,NULL),('headlines','en','',NULL,NULL),('hide left navigation','en','',1368616017,1368616017),('horiz. line','de','',NULL,NULL),('horiz. line','en','',NULL,NULL),('icon teaser','de','',NULL,NULL),('icon teaser','en','',NULL,NULL),('image','de','',1368608412,1368608412),('image','en','',1368608412,1368608412),('image hotspot','de','',1368627186,1368627186),('image hotspot','en','',1368627186,1368627186),('image hotspot & marker','de','',1368627476,1368627476),('image hotspot & marker','en','',1368627476,1368627476),('inquiry','en','Inquiry',1368620428,1388396996),('lastname','en','',1368621928,1368621928),('left navigation start node','en','',1368612685,1368612685),('male','en','',1368621928,1368621928),('message','en','',1368622768,1368622768),('name','en','',1388389870,1388389870),('news','en','News',1368613317,1388396966),('newsletter active','en','',1368621928,1368621928),('newsletter confirmed','en','',1368621928,1368621928),('pdf','de','',1368608412,1368608412),('pdf','en','',1368608412,1368608412),('person','en','Person',1368621928,1388397002),('persons','en','',1368620458,1368620458),('poster image','en','',1388389661,1388389661),('short text','en','',1368613497,1368613497),('sidebar','en','',1382962847,1382962847),('slider (tabs/text)','de','',NULL,NULL),('slider (tabs/text)','en','',NULL,NULL),('standard teaser','de','',1368608412,1368608412),('standard teaser','en','',1368608412,1368608412),('standard-mail','en','',1388409372,1388409372),('standard-teaser','en','',1368531641,1368531641),('tags','en','',1388389660,1388389660),('terms of use','en','',1368622768,1368622768),('text','en','',1368613497,1368613497),('text accordion','de','',NULL,NULL),('text accordion','en','',NULL,NULL),('title','en','',1368613497,1368613497),('unittest','en','',1368561373,1368561373),('video','de','',1368608412,1368608412),('video','en','',1368608412,1368608412),('wysiwyg','de','',1368608412,1368608412),('wysiwyg','en','',1368608412,1368608412),('wysiwyg w. images','de','',NULL,NULL),('wysiwyg w. images','en','',NULL,NULL);
/*!40000 ALTER TABLE `translations_admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translations_website`
--

DROP TABLE IF EXISTS `translations_website`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translations_website` (
  `key` varchar(255) NOT NULL DEFAULT '',
  `language` varchar(10) NOT NULL DEFAULT '',
  `text` text,
  `creationDate` bigint(20) unsigned DEFAULT NULL,
  `modificationDate` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`key`,`language`),
  KEY `language` (`language`),
  KEY `key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translations_website`
--

LOCK TABLES `translations_website` WRITE;
/*!40000 ALTER TABLE `translations_website` DISABLE KEYS */;
INSERT INTO `translations_website` VALUES ('\'%value%\' is not a valid email address in the basic format local-part@hostname','de','',1368631595,1368631595),('\'%value%\' is not a valid email address in the basic format local-part@hostname','en','',1368631595,1368631595),('advanced examples','de','',0,0),('advanced examples','en','',0,0),('aktuelles','de','',0,0),('aktuelles','en','',0,0),('all categories','de','',0,0),('all categories','en','',0,0),('all dates','de','',0,0),('all dates','en','',0,0),('archive','de','',0,0),('archive','en','',0,0),('asset thumbnail list','de','',0,0),('asset thumbnail list','en','',0,0),('back to top','de','',0,0),('back to top','en','',0,0),('basic examples','de','',0,0),('basic examples','en','',0,0),('beispiele für fortgeschrittene','de','',0,0),('beispiele für fortgeschrittene','en','',0,0),('blog','de','',0,0),('blog','en','',0,0),('categories','de','',0,0),('categories','en','',0,0),('check me out','de','',1368610820,1368610820),('check me out','en','',1368610820,1368610820),('combined 1','en','',1368606496,1368606496),('combined 2','en','',1368606637,1368606637),('combined 3','en','',1368606637,1368606637),('contact form','de','',0,0),('contact form','en','',0,0),('contain','en','',1368603255,1368603255),('contain &amp; overlay','en','',1368605819,1368605819),('content inheritance','de','',NULL,NULL),('content inheritance','en','',NULL,NULL),('content page','de','',0,0),('content page','en','',0,0),('cover','en','',1368602697,1368602697),('creating objects with a form','de','',NULL,NULL),('creating objects with a form','en','',NULL,NULL),('deutsche übersetzung','de','',0,0),('deutsche übersetzung','en','',0,0),('dimensions','en','',1368604632,1368604632),('document viewer','de','',NULL,NULL),('document viewer','en','',NULL,NULL),('download','de','Herunterladen',1368608523,1368608523),('download','en','',1368608523,1368608523),('download compiled','de','Herunterladen (kompiliert)',1368608505,1368608505),('download compiled','en','',1368608505,1368608505),('download now (%s)','de','',1368619727,1368619727),('download now (%s)','en','',1368619727,1368619727),('download source','de','Herunterladen (Quellen)',1368608508,1368608508),('download source','en','',1368608508,1368608508),('e-commerce','de','',0,0),('e-commerce','en','',0,0),('e-mail','de','',1368610820,1368610820),('e-mail','en','',1368610820,1368610820),('editable round-up','de','',NULL,NULL),('editable round-up','en','',NULL,NULL),('einfache beispiele','de','',0,0),('einfache beispiele','en','',0,0),('einführung','de','',0,0),('einführung','en','',0,0),('experiments','de','',0,0),('experiments','en','',0,0),('fastest way to get started: get the compiled and minified versions of our css, js, and images. no docs or original source files.','de','Der schnellste Weg um loszulegen: Lade die kompilierten und reduzierten Versionen unserer CSS, JS und Grafiken. Keine Dokumentation oder Quelldateien.',1368608611,1368608611),('fastest way to get started: get the compiled and minified versions of our css, js, and images. no docs or original source files.','en','',1368608611,1368608611),('female','de','',0,0),('female','en','',0,0),('firstname','de','',1368610819,1368610819),('firstname','en','',1368610819,1368610819),('frame','en','',1368603255,1368603255),('galleries','de','',0,0),('galleries','en','',0,0),('gender','de','',1368622092,1368622092),('gender','en','',1368622092,1368622092),('get the original files for all css and javascript, along with a local copy of the docs by downloading the latest version directly from github.','de','Lade die originalen  CSS und Javascript Dateien zusammen mit einer lokalen Kopie der Dokumentation von github.com',1368608698,1368608698),('get the original files for all css and javascript, along with a local copy of the docs by downloading the latest version directly from github.','en','',1368608698,1368608698),('glossary','de','',0,0),('glossary','en','',0,0),('grayscale','en','',1368606077,1368606077),('hard link','de','',NULL,NULL),('hard link','en','',NULL,NULL),('home','de','Startseite',0,1382961053),('home','en','Home',0,1382961053),('html5 video','de','',0,0),('html5 video','en','',0,0),('i accept the terms of use','de','',1368620808,1368620808),('i accept the terms of use','en','',1368620808,1368620808),('image with hotspots','de','',NULL,NULL),('image with hotspots','en','',NULL,NULL),('introduction','de','',0,0),('introduction','en','',0,0),('keyword','de','',0,0),('keyword','en','',0,0),('lastname','de','',1368610820,1368610820),('lastname','en','',1368610820,1368610820),('male','de','',0,0),('male','en','',0,0),('mask','en','',1368606259,1368606259),('message','de','',1368620708,1368620708),('message','en','',1368620708,1368620708),('neuigkeiten','de','',0,0),('neuigkeiten','en','',0,0),('news','de','',0,0),('news','en','',0,0),('newsletter','de','',1368620340,1368620340),('newsletter','en','',1368620340,1368620340),('original dimensions of the image','en','',1368604779,1368604779),('overlay','en','',1368605562,1368605562),('product information management','de','',0,0),('product information management','en','',0,0),('product information managment','de','',0,0),('product information managment','en','',0,0),('properties','de','',0,0),('properties','en','',0,0),('recently in the blog','de','',0,0),('recently in the blog','en','',0,0),('resize','en','',1368603801,1368603801),('rotate','en','',1368603255,1368603255),('rounded corners','en','',1368605936,1368605936),('scale by height','en','',1368603959,1368603959),('scale by width','en','',1368603959,1368603959),('search','de','',1368629830,1368629830),('search','en','',1368629830,1368629830),('sepia','en','',1368606075,1368606075),('simple form','de','',0,0),('simple form','en','',0,0),('sitemap','de','',0,0),('sitemap','en','',0,0),('slave document','de','',NULL,NULL),('slave document','en','',NULL,NULL),('sorry, something went wrong, please check the data in the form and try again!','de','',0,0),('sorry, something went wrong, please check the data in the form and try again!','en','',0,0),('submit','de','',1368610820,1368610820),('submit','en','',1368610820,1368610820),('success, please check your mailbox!','de','',0,0),('success, please check your mailbox!','en','',0,0),('tag & snippet management','de','',NULL,NULL),('tag & snippet management','en','',NULL,NULL),('thank you very much','de','',1368611300,1368611300),('thank you very much','en','',1368611300,1368611300),('thanks for confirming your address!','de','',0,0),('thanks for confirming your address!','en','',0,0),('thumbnails','de','',NULL,NULL),('thumbnails','en','',NULL,NULL),('total %s','de','',1368619656,1368619656),('total %s','en','',1368619656,1368619656),('total: %s','de','',1368619663,1368619663),('total: %s','en','',1368619663,1368619663),('unsubscribe','de','',0,0),('unsubscribe','en','',0,0),('website translations','de','',0,0),('website translations','en','',0,0),('website übersetzungen','de','',0,0),('website übersetzungen','en','',0,0);
/*!40000 ALTER TABLE `translations_website` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tree_locks`
--

DROP TABLE IF EXISTS `tree_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tree_locks` (
  `id` int(11) NOT NULL DEFAULT '0',
  `type` enum('asset','document','object') NOT NULL DEFAULT 'asset',
  `locked` enum('self','propagate') DEFAULT NULL,
  PRIMARY KEY (`id`,`type`),
  KEY `id` (`id`),
  KEY `type` (`type`),
  KEY `locked` (`locked`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tree_locks`
--

LOCK TABLES `tree_locks` WRITE;
/*!40000 ALTER TABLE `tree_locks` DISABLE KEYS */;
INSERT INTO `tree_locks` VALUES (12,'document','self'),(46,'document','self');
/*!40000 ALTER TABLE `tree_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `parentId` int(11) unsigned DEFAULT NULL,
  `type` enum('user','userfolder','role','rolefolder') NOT NULL DEFAULT 'user',
  `name` varchar(50) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `firstname` varchar(255) DEFAULT NULL,
  `lastname` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `language` varchar(10) DEFAULT NULL,
  `contentLanguages` longtext,
  `admin` tinyint(1) unsigned DEFAULT '0',
  `active` tinyint(1) unsigned DEFAULT '1',
  `permissions` varchar(1000) DEFAULT NULL,
  `roles` varchar(1000) DEFAULT NULL,
  `welcomescreen` tinyint(1) DEFAULT NULL,
  `closeWarning` tinyint(1) DEFAULT NULL,
  `memorizeTabs` tinyint(1) DEFAULT NULL,
  `docTypes` varchar(255) DEFAULT NULL,
  `classes` varchar(255) DEFAULT NULL,
  `apiKey` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `type_name` (`type`,`name`),
  KEY `parentId` (`parentId`),
  KEY `name` (`name`),
  KEY `password` (`password`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (0,0,'user','system','',NULL,NULL,NULL,'','',1,1,'','',0,0,0,'','',NULL),(39,0,'user','admin','$2y$10$bhwMTy.Nl15ZzmJtbtikCOS/SwHQ.28AFVvK99RR5Th1wUvQg4lFe',NULL,NULL,NULL,'en',NULL,1,1,'','',0,1,1,'','',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users_permission_definitions`
--

DROP TABLE IF EXISTS `users_permission_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users_permission_definitions` (
  `key` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_permission_definitions`
--

LOCK TABLES `users_permission_definitions` WRITE;
/*!40000 ALTER TABLE `users_permission_definitions` DISABLE KEYS */;
INSERT INTO `users_permission_definitions` VALUES ('assets'),('backup'),('bounce_mail_inbox'),('classes'),('clear_cache'),('clear_temp_files'),('dashboards'),('documents'),('document_types'),('emails'),('glossary'),('http_errors'),('newsletter'),('notes_events'),('objects'),('plugins'),('predefined_properties'),('qr_codes'),('recyclebin'),('redirects'),('reports'),('robots.txt'),('routes'),('seemode'),('seo_document_editor'),('system_settings'),('tag_snippet_management'),('targeting'),('thumbnails'),('translations'),('users'),('website_settings');
/*!40000 ALTER TABLE `users_permission_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users_workspaces_asset`
--

DROP TABLE IF EXISTS `users_workspaces_asset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users_workspaces_asset` (
  `cid` int(11) unsigned NOT NULL DEFAULT '0',
  `cpath` varchar(765) CHARACTER SET ascii DEFAULT NULL,
  `userId` int(11) NOT NULL DEFAULT '0',
  `list` tinyint(1) DEFAULT '0',
  `view` tinyint(1) DEFAULT '0',
  `publish` tinyint(1) DEFAULT '0',
  `delete` tinyint(1) DEFAULT '0',
  `rename` tinyint(1) DEFAULT '0',
  `create` tinyint(1) DEFAULT '0',
  `settings` tinyint(1) DEFAULT '0',
  `versions` tinyint(1) DEFAULT '0',
  `properties` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`cid`,`userId`),
  KEY `cid` (`cid`),
  KEY `userId` (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_workspaces_asset`
--

LOCK TABLES `users_workspaces_asset` WRITE;
/*!40000 ALTER TABLE `users_workspaces_asset` DISABLE KEYS */;
/*!40000 ALTER TABLE `users_workspaces_asset` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users_workspaces_document`
--

DROP TABLE IF EXISTS `users_workspaces_document`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users_workspaces_document` (
  `cid` int(11) unsigned NOT NULL DEFAULT '0',
  `cpath` varchar(765) CHARACTER SET ascii DEFAULT NULL,
  `userId` int(11) NOT NULL DEFAULT '0',
  `list` tinyint(1) unsigned DEFAULT '0',
  `view` tinyint(1) unsigned DEFAULT '0',
  `save` tinyint(1) unsigned DEFAULT '0',
  `publish` tinyint(1) unsigned DEFAULT '0',
  `unpublish` tinyint(1) unsigned DEFAULT '0',
  `delete` tinyint(1) unsigned DEFAULT '0',
  `rename` tinyint(1) unsigned DEFAULT '0',
  `create` tinyint(1) unsigned DEFAULT '0',
  `settings` tinyint(1) unsigned DEFAULT '0',
  `versions` tinyint(1) unsigned DEFAULT '0',
  `properties` tinyint(1) unsigned DEFAULT '0',
  PRIMARY KEY (`cid`,`userId`),
  KEY `cid` (`cid`),
  KEY `userId` (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_workspaces_document`
--

LOCK TABLES `users_workspaces_document` WRITE;
/*!40000 ALTER TABLE `users_workspaces_document` DISABLE KEYS */;
/*!40000 ALTER TABLE `users_workspaces_document` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users_workspaces_object`
--

DROP TABLE IF EXISTS `users_workspaces_object`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users_workspaces_object` (
  `cid` int(11) unsigned NOT NULL DEFAULT '0',
  `cpath` varchar(765) CHARACTER SET ascii DEFAULT NULL,
  `userId` int(11) NOT NULL DEFAULT '0',
  `list` tinyint(1) unsigned DEFAULT '0',
  `view` tinyint(1) unsigned DEFAULT '0',
  `save` tinyint(1) unsigned DEFAULT '0',
  `publish` tinyint(1) unsigned DEFAULT '0',
  `unpublish` tinyint(1) unsigned DEFAULT '0',
  `delete` tinyint(1) unsigned DEFAULT '0',
  `rename` tinyint(1) unsigned DEFAULT '0',
  `create` tinyint(1) unsigned DEFAULT '0',
  `settings` tinyint(1) unsigned DEFAULT '0',
  `versions` tinyint(1) unsigned DEFAULT '0',
  `properties` tinyint(1) unsigned DEFAULT '0',
  `lEdit` text,
  `lView` text,
  `layouts` text,
  PRIMARY KEY (`cid`,`userId`),
  KEY `cid` (`cid`),
  KEY `userId` (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_workspaces_object`
--

LOCK TABLES `users_workspaces_object` WRITE;
/*!40000 ALTER TABLE `users_workspaces_object` DISABLE KEYS */;
/*!40000 ALTER TABLE `users_workspaces_object` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `uuids`
--

DROP TABLE IF EXISTS `uuids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uuids` (
  `uuid` char(36) NOT NULL,
  `itemId` bigint(20) unsigned NOT NULL,
  `type` varchar(25) NOT NULL,
  `instanceIdentifier` varchar(50) NOT NULL,
  PRIMARY KEY (`itemId`,`type`,`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `uuids`
--

LOCK TABLES `uuids` WRITE;
/*!40000 ALTER TABLE `uuids` DISABLE KEYS */;
/*!40000 ALTER TABLE `uuids` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `versions`
--

DROP TABLE IF EXISTS `versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `versions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `cid` int(11) unsigned DEFAULT NULL,
  `ctype` enum('document','asset','object') DEFAULT NULL,
  `userId` int(11) unsigned DEFAULT NULL,
  `note` text,
  `date` bigint(1) unsigned DEFAULT NULL,
  `public` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `serialized` tinyint(1) unsigned DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `cid` (`cid`),
  KEY `ctype` (`ctype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `versions`
--

LOCK TABLES `versions` WRITE;
/*!40000 ALTER TABLE `versions` DISABLE KEYS */;
/*!40000 ALTER TABLE `versions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `website_settings`
--

DROP TABLE IF EXISTS `website_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `website_settings` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `type` enum('text','document','asset','object','bool') DEFAULT NULL,
  `data` text,
  `siteId` int(11) unsigned DEFAULT NULL,
  `creationDate` bigint(20) unsigned DEFAULT '0',
  `modificationDate` bigint(20) unsigned DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `name` (`name`),
  KEY `siteId` (`siteId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `website_settings`
--

LOCK TABLES `website_settings` WRITE;
/*!40000 ALTER TABLE `website_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `website_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `object_2`
--

/*!50001 DROP VIEW IF EXISTS `object_2`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`pimcore`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `object_2` AS select `object_query_2`.`oo_id` AS `oo_id`,`object_query_2`.`oo_classId` AS `oo_classId`,`object_query_2`.`oo_className` AS `oo_className`,`object_query_2`.`date` AS `date`,`object_query_2`.`image_1` AS `image_1`,`object_query_2`.`image_2` AS `image_2`,`object_query_2`.`image_3` AS `image_3`,`objects`.`o_id` AS `o_id`,`objects`.`o_parentId` AS `o_parentId`,`objects`.`o_type` AS `o_type`,`objects`.`o_key` AS `o_key`,`objects`.`o_path` AS `o_path`,`objects`.`o_index` AS `o_index`,`objects`.`o_published` AS `o_published`,`objects`.`o_creationDate` AS `o_creationDate`,`objects`.`o_modificationDate` AS `o_modificationDate`,`objects`.`o_userOwner` AS `o_userOwner`,`objects`.`o_userModification` AS `o_userModification`,`objects`.`o_classId` AS `o_classId`,`objects`.`o_className` AS `o_className` from (`object_query_2` join `objects` on((`objects`.`o_id` = `object_query_2`.`oo_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `object_3`
--

/*!50001 DROP VIEW IF EXISTS `object_3`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`pimcore`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `object_3` AS select `object_query_3`.`oo_id` AS `oo_id`,`object_query_3`.`oo_classId` AS `oo_classId`,`object_query_3`.`oo_className` AS `oo_className`,`object_query_3`.`person__id` AS `person__id`,`object_query_3`.`person__type` AS `person__type`,`object_query_3`.`date` AS `date`,`object_query_3`.`message` AS `message`,`object_query_3`.`terms` AS `terms`,`objects`.`o_id` AS `o_id`,`objects`.`o_parentId` AS `o_parentId`,`objects`.`o_type` AS `o_type`,`objects`.`o_key` AS `o_key`,`objects`.`o_path` AS `o_path`,`objects`.`o_index` AS `o_index`,`objects`.`o_published` AS `o_published`,`objects`.`o_creationDate` AS `o_creationDate`,`objects`.`o_modificationDate` AS `o_modificationDate`,`objects`.`o_userOwner` AS `o_userOwner`,`objects`.`o_userModification` AS `o_userModification`,`objects`.`o_classId` AS `o_classId`,`objects`.`o_className` AS `o_className` from (`object_query_3` join `objects` on((`objects`.`o_id` = `object_query_3`.`oo_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `object_4`
--

/*!50001 DROP VIEW IF EXISTS `object_4`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`pimcore`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `object_4` AS select `object_query_4`.`oo_id` AS `oo_id`,`object_query_4`.`oo_classId` AS `oo_classId`,`object_query_4`.`oo_className` AS `oo_className`,`object_query_4`.`gender` AS `gender`,`object_query_4`.`firstname` AS `firstname`,`object_query_4`.`lastname` AS `lastname`,`object_query_4`.`email` AS `email`,`object_query_4`.`newsletterActive` AS `newsletterActive`,`object_query_4`.`newsletterConfirmed` AS `newsletterConfirmed`,`object_query_4`.`dateRegister` AS `dateRegister`,`objects`.`o_id` AS `o_id`,`objects`.`o_parentId` AS `o_parentId`,`objects`.`o_type` AS `o_type`,`objects`.`o_key` AS `o_key`,`objects`.`o_path` AS `o_path`,`objects`.`o_index` AS `o_index`,`objects`.`o_published` AS `o_published`,`objects`.`o_creationDate` AS `o_creationDate`,`objects`.`o_modificationDate` AS `o_modificationDate`,`objects`.`o_userOwner` AS `o_userOwner`,`objects`.`o_userModification` AS `o_userModification`,`objects`.`o_classId` AS `o_classId`,`objects`.`o_className` AS `o_className` from (`object_query_4` join `objects` on((`objects`.`o_id` = `object_query_4`.`oo_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `object_5`
--

/*!50001 DROP VIEW IF EXISTS `object_5`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`pimcore`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `object_5` AS select `object_query_5`.`oo_id` AS `oo_id`,`object_query_5`.`oo_classId` AS `oo_classId`,`object_query_5`.`oo_className` AS `oo_className`,`object_query_5`.`date` AS `date`,`object_query_5`.`categories` AS `categories`,`object_query_5`.`posterImage__image` AS `posterImage__image`,`object_query_5`.`posterImage__hotspots` AS `posterImage__hotspots`,`objects`.`o_id` AS `o_id`,`objects`.`o_parentId` AS `o_parentId`,`objects`.`o_type` AS `o_type`,`objects`.`o_key` AS `o_key`,`objects`.`o_path` AS `o_path`,`objects`.`o_index` AS `o_index`,`objects`.`o_published` AS `o_published`,`objects`.`o_creationDate` AS `o_creationDate`,`objects`.`o_modificationDate` AS `o_modificationDate`,`objects`.`o_userOwner` AS `o_userOwner`,`objects`.`o_userModification` AS `o_userModification`,`objects`.`o_classId` AS `o_classId`,`objects`.`o_className` AS `o_className` from (`object_query_5` join `objects` on((`objects`.`o_id` = `object_query_5`.`oo_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `object_6`
--

/*!50001 DROP VIEW IF EXISTS `object_6`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`pimcore`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `object_6` AS select `object_query_6`.`oo_id` AS `oo_id`,`object_query_6`.`oo_classId` AS `oo_classId`,`object_query_6`.`oo_className` AS `oo_className`,`objects`.`o_id` AS `o_id`,`objects`.`o_parentId` AS `o_parentId`,`objects`.`o_type` AS `o_type`,`objects`.`o_key` AS `o_key`,`objects`.`o_path` AS `o_path`,`objects`.`o_index` AS `o_index`,`objects`.`o_published` AS `o_published`,`objects`.`o_creationDate` AS `o_creationDate`,`objects`.`o_modificationDate` AS `o_modificationDate`,`objects`.`o_userOwner` AS `o_userOwner`,`objects`.`o_userModification` AS `o_userModification`,`objects`.`o_classId` AS `o_classId`,`objects`.`o_className` AS `o_className` from (`object_query_6` join `objects` on((`objects`.`o_id` = `object_query_6`.`oo_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `object_localized_2_de`
--

/*!50001 DROP VIEW IF EXISTS `object_localized_2_de`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`pimcore`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `object_localized_2_de` AS select `object_query_2`.`oo_id` AS `oo_id`,`object_query_2`.`oo_classId` AS `oo_classId`,`object_query_2`.`oo_className` AS `oo_className`,`object_query_2`.`date` AS `date`,`object_query_2`.`image_1` AS `image_1`,`object_query_2`.`image_2` AS `image_2`,`object_query_2`.`image_3` AS `image_3`,`objects`.`o_id` AS `o_id`,`objects`.`o_parentId` AS `o_parentId`,`objects`.`o_type` AS `o_type`,`objects`.`o_key` AS `o_key`,`objects`.`o_path` AS `o_path`,`objects`.`o_index` AS `o_index`,`objects`.`o_published` AS `o_published`,`objects`.`o_creationDate` AS `o_creationDate`,`objects`.`o_modificationDate` AS `o_modificationDate`,`objects`.`o_userOwner` AS `o_userOwner`,`objects`.`o_userModification` AS `o_userModification`,`objects`.`o_classId` AS `o_classId`,`objects`.`o_className` AS `o_className`,`object_localized_query_2_de`.`ooo_id` AS `ooo_id`,`object_localized_query_2_de`.`language` AS `language`,`object_localized_query_2_de`.`title` AS `title`,`object_localized_query_2_de`.`shortText` AS `shortText`,`object_localized_query_2_de`.`text` AS `text` from ((`object_query_2` join `objects` on((`objects`.`o_id` = `object_query_2`.`oo_id`))) left join `object_localized_query_2_de` on((`object_query_2`.`oo_id` = `object_localized_query_2_de`.`ooo_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `object_localized_2_en`
--

/*!50001 DROP VIEW IF EXISTS `object_localized_2_en`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`pimcore`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `object_localized_2_en` AS select `object_query_2`.`oo_id` AS `oo_id`,`object_query_2`.`oo_classId` AS `oo_classId`,`object_query_2`.`oo_className` AS `oo_className`,`object_query_2`.`date` AS `date`,`object_query_2`.`image_1` AS `image_1`,`object_query_2`.`image_2` AS `image_2`,`object_query_2`.`image_3` AS `image_3`,`objects`.`o_id` AS `o_id`,`objects`.`o_parentId` AS `o_parentId`,`objects`.`o_type` AS `o_type`,`objects`.`o_key` AS `o_key`,`objects`.`o_path` AS `o_path`,`objects`.`o_index` AS `o_index`,`objects`.`o_published` AS `o_published`,`objects`.`o_creationDate` AS `o_creationDate`,`objects`.`o_modificationDate` AS `o_modificationDate`,`objects`.`o_userOwner` AS `o_userOwner`,`objects`.`o_userModification` AS `o_userModification`,`objects`.`o_classId` AS `o_classId`,`objects`.`o_className` AS `o_className`,`object_localized_query_2_en`.`ooo_id` AS `ooo_id`,`object_localized_query_2_en`.`language` AS `language`,`object_localized_query_2_en`.`title` AS `title`,`object_localized_query_2_en`.`shortText` AS `shortText`,`object_localized_query_2_en`.`text` AS `text` from ((`object_query_2` join `objects` on((`objects`.`o_id` = `object_query_2`.`oo_id`))) left join `object_localized_query_2_en` on((`object_query_2`.`oo_id` = `object_localized_query_2_en`.`ooo_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `object_localized_5_de`
--

/*!50001 DROP VIEW IF EXISTS `object_localized_5_de`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`pimcore`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `object_localized_5_de` AS select `object_query_5`.`oo_id` AS `oo_id`,`object_query_5`.`oo_classId` AS `oo_classId`,`object_query_5`.`oo_className` AS `oo_className`,`object_query_5`.`date` AS `date`,`object_query_5`.`categories` AS `categories`,`object_query_5`.`posterImage__image` AS `posterImage__image`,`object_query_5`.`posterImage__hotspots` AS `posterImage__hotspots`,`objects`.`o_id` AS `o_id`,`objects`.`o_parentId` AS `o_parentId`,`objects`.`o_type` AS `o_type`,`objects`.`o_key` AS `o_key`,`objects`.`o_path` AS `o_path`,`objects`.`o_index` AS `o_index`,`objects`.`o_published` AS `o_published`,`objects`.`o_creationDate` AS `o_creationDate`,`objects`.`o_modificationDate` AS `o_modificationDate`,`objects`.`o_userOwner` AS `o_userOwner`,`objects`.`o_userModification` AS `o_userModification`,`objects`.`o_classId` AS `o_classId`,`objects`.`o_className` AS `o_className`,`object_localized_query_5_de`.`ooo_id` AS `ooo_id`,`object_localized_query_5_de`.`language` AS `language`,`object_localized_query_5_de`.`title` AS `title`,`object_localized_query_5_de`.`text` AS `text`,`object_localized_query_5_de`.`tags` AS `tags` from ((`object_query_5` join `objects` on((`objects`.`o_id` = `object_query_5`.`oo_id`))) left join `object_localized_query_5_de` on((`object_query_5`.`oo_id` = `object_localized_query_5_de`.`ooo_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `object_localized_5_en`
--

/*!50001 DROP VIEW IF EXISTS `object_localized_5_en`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`pimcore`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `object_localized_5_en` AS select `object_query_5`.`oo_id` AS `oo_id`,`object_query_5`.`oo_classId` AS `oo_classId`,`object_query_5`.`oo_className` AS `oo_className`,`object_query_5`.`date` AS `date`,`object_query_5`.`categories` AS `categories`,`object_query_5`.`posterImage__image` AS `posterImage__image`,`object_query_5`.`posterImage__hotspots` AS `posterImage__hotspots`,`objects`.`o_id` AS `o_id`,`objects`.`o_parentId` AS `o_parentId`,`objects`.`o_type` AS `o_type`,`objects`.`o_key` AS `o_key`,`objects`.`o_path` AS `o_path`,`objects`.`o_index` AS `o_index`,`objects`.`o_published` AS `o_published`,`objects`.`o_creationDate` AS `o_creationDate`,`objects`.`o_modificationDate` AS `o_modificationDate`,`objects`.`o_userOwner` AS `o_userOwner`,`objects`.`o_userModification` AS `o_userModification`,`objects`.`o_classId` AS `o_classId`,`objects`.`o_className` AS `o_className`,`object_localized_query_5_en`.`ooo_id` AS `ooo_id`,`object_localized_query_5_en`.`language` AS `language`,`object_localized_query_5_en`.`title` AS `title`,`object_localized_query_5_en`.`text` AS `text`,`object_localized_query_5_en`.`tags` AS `tags` from ((`object_query_5` join `objects` on((`objects`.`o_id` = `object_query_5`.`oo_id`))) left join `object_localized_query_5_en` on((`object_query_5`.`oo_id` = `object_localized_query_5_en`.`ooo_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `object_localized_6_de`
--

/*!50001 DROP VIEW IF EXISTS `object_localized_6_de`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`pimcore`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `object_localized_6_de` AS select `object_query_6`.`oo_id` AS `oo_id`,`object_query_6`.`oo_classId` AS `oo_classId`,`object_query_6`.`oo_className` AS `oo_className`,`objects`.`o_id` AS `o_id`,`objects`.`o_parentId` AS `o_parentId`,`objects`.`o_type` AS `o_type`,`objects`.`o_key` AS `o_key`,`objects`.`o_path` AS `o_path`,`objects`.`o_index` AS `o_index`,`objects`.`o_published` AS `o_published`,`objects`.`o_creationDate` AS `o_creationDate`,`objects`.`o_modificationDate` AS `o_modificationDate`,`objects`.`o_userOwner` AS `o_userOwner`,`objects`.`o_userModification` AS `o_userModification`,`objects`.`o_classId` AS `o_classId`,`objects`.`o_className` AS `o_className`,`object_localized_query_6_de`.`ooo_id` AS `ooo_id`,`object_localized_query_6_de`.`language` AS `language`,`object_localized_query_6_de`.`name` AS `name` from ((`object_query_6` join `objects` on((`objects`.`o_id` = `object_query_6`.`oo_id`))) left join `object_localized_query_6_de` on((`object_query_6`.`oo_id` = `object_localized_query_6_de`.`ooo_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `object_localized_6_en`
--

/*!50001 DROP VIEW IF EXISTS `object_localized_6_en`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`pimcore`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `object_localized_6_en` AS select `object_query_6`.`oo_id` AS `oo_id`,`object_query_6`.`oo_classId` AS `oo_classId`,`object_query_6`.`oo_className` AS `oo_className`,`objects`.`o_id` AS `o_id`,`objects`.`o_parentId` AS `o_parentId`,`objects`.`o_type` AS `o_type`,`objects`.`o_key` AS `o_key`,`objects`.`o_path` AS `o_path`,`objects`.`o_index` AS `o_index`,`objects`.`o_published` AS `o_published`,`objects`.`o_creationDate` AS `o_creationDate`,`objects`.`o_modificationDate` AS `o_modificationDate`,`objects`.`o_userOwner` AS `o_userOwner`,`objects`.`o_userModification` AS `o_userModification`,`objects`.`o_classId` AS `o_classId`,`objects`.`o_className` AS `o_className`,`object_localized_query_6_en`.`ooo_id` AS `ooo_id`,`object_localized_query_6_en`.`language` AS `language`,`object_localized_query_6_en`.`name` AS `name` from ((`object_query_6` join `objects` on((`objects`.`o_id` = `object_query_6`.`oo_id`))) left join `object_localized_query_6_en` on((`object_query_6`.`oo_id` = `object_localized_query_6_en`.`ooo_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-03-07  9:42:38
