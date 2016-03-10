-- MySQL dump 10.13  Distrib 5.6.28, for Linux (i686)
--
-- Host: localhost    Database: rucaro
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
-- Table structure for table `accountingAccess`
--

DROP TABLE IF EXISTS `accountingAccess`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingAccess` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idAccess` int(10) unsigned NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `strTitle` varchar(100) DEFAULT NULL,
  `jsonData` longtext,
  `arrSpaceStrTag` mediumtext,
  `flagDefault` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingAccess`
--

LOCK TABLES `accountingAccess` WRITE;
/*!40000 ALTER TABLE `accountingAccess` DISABLE KEYS */;
INSERT INTO `accountingAccess` VALUES (1,1457615946,1457615946,1,0,'全項目アクセス可能',NULL,NULL,1),(2,1457615946,1457615946,2,0,'全項目アクセス不可',NULL,NULL,1);
/*!40000 ALTER TABLE `accountingAccess` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingAccount`
--

DROP TABLE IF EXISTS `accountingAccount`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingAccount` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idAccount` int(10) unsigned DEFAULT NULL,
  `flagAdmin` int(10) unsigned DEFAULT '1',
  `idEntityCurrent` int(10) unsigned DEFAULT '1',
  `numFiscalPeriodCurrent` int(10) unsigned DEFAULT '1',
  `arrCommaIdEntity` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingAccount`
--

LOCK TABLES `accountingAccount` WRITE;
/*!40000 ALTER TABLE `accountingAccount` DISABLE KEYS */;
INSERT INTO `accountingAccount` VALUES (1,1457615946,1457615946,1,1,NULL,NULL,'');
/*!40000 ALTER TABLE `accountingAccount` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingAccountEntity`
--

DROP TABLE IF EXISTS `accountingAccountEntity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingAccountEntity` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `idAccount` int(10) unsigned DEFAULT '1',
  `idEntity` int(10) unsigned DEFAULT '1',
  `idAuthority` int(10) unsigned DEFAULT '1',
  `idAccess` int(10) unsigned DEFAULT '1',
  `strMailFile` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingAccountEntity`
--

LOCK TABLES `accountingAccountEntity` WRITE;
/*!40000 ALTER TABLE `accountingAccountEntity` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingAccountEntity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingAccountId`
--

DROP TABLE IF EXISTS `accountingAccountId`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingAccountId` (
  `id` int(10) unsigned DEFAULT NULL,
  `strCodeName` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingAccountId`
--

LOCK TABLES `accountingAccountId` WRITE;
/*!40000 ALTER TABLE `accountingAccountId` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingAccountId` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingAccountMemo`
--

DROP TABLE IF EXISTS `accountingAccountMemo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingAccountMemo` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idAccount` int(10) unsigned DEFAULT NULL,
  `idEntity` int(10) unsigned DEFAULT '0',
  `flagColumn` varchar(50) NOT NULL,
  `jsonData` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingAccountMemo`
--

LOCK TABLES `accountingAccountMemo` WRITE;
/*!40000 ALTER TABLE `accountingAccountMemo` DISABLE KEYS */;
INSERT INTO `accountingAccountMemo` VALUES (1,1457615946,1457615946,1,0,'jsonEntityNaviSearch',NULL),(2,1457615946,1457615946,1,0,'jsonAccountNaviSearch',NULL),(3,1457615946,1457615946,1,0,'jsonAuthorityNaviSearch',NULL);
/*!40000 ALTER TABLE `accountingAccountMemo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingAuthority`
--

DROP TABLE IF EXISTS `accountingAuthority`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingAuthority` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `strTitle` varchar(100) DEFAULT NULL,
  `flagMySelect` int(10) unsigned DEFAULT '1',
  `flagMyInsert` int(10) unsigned DEFAULT '1',
  `flagMyDelete` int(10) unsigned DEFAULT '1',
  `flagMyUpdate` int(10) unsigned DEFAULT '1',
  `flagMyOutput` int(10) unsigned DEFAULT '1',
  `flagAllSelect` int(10) unsigned DEFAULT '1',
  `flagAllInsert` int(10) unsigned DEFAULT '1',
  `flagAllDelete` int(10) unsigned DEFAULT '1',
  `flagAllUpdate` int(10) unsigned DEFAULT '1',
  `flagAllOutput` int(10) unsigned DEFAULT '1',
  `arrSpaceStrTag` mediumtext,
  `flagDefault` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingAuthority`
--

LOCK TABLES `accountingAuthority` WRITE;
/*!40000 ALTER TABLE `accountingAuthority` DISABLE KEYS */;
INSERT INTO `accountingAuthority` VALUES (1,1457615946,1457615946,'全権限',1,1,1,1,1,1,1,1,1,1,NULL,1),(2,1457615946,1457615946,'閲覧のみ',1,0,0,0,0,0,0,0,0,0,NULL,1);
/*!40000 ALTER TABLE `accountingAuthority` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingBanks`
--

DROP TABLE IF EXISTS `accountingBanks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingBanks` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `flagAutoImport` int(10) unsigned DEFAULT '1',
  `flagLock` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingBanks`
--

LOCK TABLES `accountingBanks` WRITE;
/*!40000 ALTER TABLE `accountingBanks` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingBanks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingBlueSheetJpn`
--

DROP TABLE IF EXISTS `accountingBlueSheetJpn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingBlueSheetJpn` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `numYearSheet` int(10) unsigned NOT NULL,
  `blobData` blob,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingBlueSheetJpn`
--

LOCK TABLES `accountingBlueSheetJpn` WRITE;
/*!40000 ALTER TABLE `accountingBlueSheetJpn` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingBlueSheetJpn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingBreakEvenPointJpn`
--

DROP TABLE IF EXISTS `accountingBreakEvenPointJpn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingBreakEvenPointJpn` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `idDepartment` int(10) unsigned DEFAULT NULL,
  `jsonJgaapAccountTitlePL` longtext,
  `jsonJgaapAccountTitleCR` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingBreakEvenPointJpn`
--

LOCK TABLES `accountingBreakEvenPointJpn` WRITE;
/*!40000 ALTER TABLE `accountingBreakEvenPointJpn` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingBreakEvenPointJpn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingBudgetJpn`
--

DROP TABLE IF EXISTS `accountingBudgetJpn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingBudgetJpn` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `flagFiscalPeriod` varchar(5) DEFAULT NULL,
  `idDepartment` int(10) unsigned DEFAULT NULL,
  `flagFS` varchar(2) DEFAULT NULL,
  `jsonData` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingBudgetJpn`
--

LOCK TABLES `accountingBudgetJpn` WRITE;
/*!40000 ALTER TABLE `accountingBudgetJpn` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingBudgetJpn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingCash`
--

DROP TABLE IF EXISTS `accountingCash`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingCash` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `jsonCash` text,
  `flagPayWrite` int(10) unsigned DEFAULT '0',
  `flagAutoImport` int(10) unsigned DEFAULT '1',
  `flagPermitImport` int(10) unsigned DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingCash`
--

LOCK TABLES `accountingCash` WRITE;
/*!40000 ALTER TABLE `accountingCash` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingCash` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingCashValue`
--

DROP TABLE IF EXISTS `accountingCashValue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingCashValue` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `numFiscalPeriodValue` int(10) unsigned DEFAULT '1',
  `flagPay` int(11) DEFAULT '0',
  `jsonData` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingCashValue`
--

LOCK TABLES `accountingCashValue` WRITE;
/*!40000 ALTER TABLE `accountingCashValue` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingCashValue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingDetailedAccountJpn`
--

DROP TABLE IF EXISTS `accountingDetailedAccountJpn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingDetailedAccountJpn` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `flagReport` varchar(100) DEFAULT NULL,
  `flagDetail` varchar(100) DEFAULT NULL,
  `numPage` int(10) unsigned DEFAULT '1',
  `jsonData` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingDetailedAccountJpn`
--

LOCK TABLES `accountingDetailedAccountJpn` WRITE;
/*!40000 ALTER TABLE `accountingDetailedAccountJpn` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingDetailedAccountJpn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingEntity`
--

DROP TABLE IF EXISTS `accountingEntity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingEntity` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `strTitle` varchar(100) DEFAULT NULL,
  `strNation` varchar(3) DEFAULT 'jpn',
  `strLang` varchar(3) DEFAULT 'ja',
  `strCurrency` varchar(3) DEFAULT 'JPY',
  `numFiscalPeriodStart` int(10) unsigned DEFAULT '1',
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `numFiscalPeriodLock` int(10) unsigned DEFAULT '0',
  `flagConfig` int(10) unsigned DEFAULT '1',
  `arrSpaceStrTag` mediumtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingEntity`
--

LOCK TABLES `accountingEntity` WRITE;
/*!40000 ALTER TABLE `accountingEntity` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingEntity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingEntityDepartment`
--

DROP TABLE IF EXISTS `accountingEntityDepartment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingEntityDepartment` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idDepartment` int(10) unsigned DEFAULT '0',
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `strTitle` varchar(100) DEFAULT NULL,
  `arrSpaceStrTag` mediumtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingEntityDepartment`
--

LOCK TABLES `accountingEntityDepartment` WRITE;
/*!40000 ALTER TABLE `accountingEntityDepartment` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingEntityDepartment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingEntityDepartmentFSValueJpn`
--

DROP TABLE IF EXISTS `accountingEntityDepartmentFSValueJpn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingEntityDepartmentFSValueJpn` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idDepartment` int(10) unsigned NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `jsonJgaapAccountTitlePL` longtext,
  `jsonJgaapAccountTitleBS` longtext,
  `jsonJgaapAccountTitleCR` longtext,
  `jsonJgaapFSPL` longtext,
  `jsonJgaapFSBS` longtext,
  `jsonJgaapFSCR` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingEntityDepartmentFSValueJpn`
--

LOCK TABLES `accountingEntityDepartmentFSValueJpn` WRITE;
/*!40000 ALTER TABLE `accountingEntityDepartmentFSValueJpn` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingEntityDepartmentFSValueJpn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingEntityJpn`
--

DROP TABLE IF EXISTS `accountingEntityJpn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingEntityJpn` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT NULL,
  `stampFiscalBeginning` bigint(20) DEFAULT NULL,
  `numFiscalBeginningYear` int(10) unsigned DEFAULT NULL,
  `numFiscalBeginningMonth` int(10) unsigned DEFAULT NULL,
  `numFiscalTermMonth` int(10) unsigned DEFAULT '12',
  `flagCorporation` int(10) unsigned DEFAULT '1',
  `numYearSheet` int(10) unsigned DEFAULT '2012',
  `flagCR` int(10) unsigned DEFAULT NULL,
  `flagSubsidiaryMoney` int(10) unsigned DEFAULT '0',
  `flagConsumptionTaxFree` int(10) unsigned DEFAULT '1',
  `flagConsumptionTaxGeneralRule` int(10) unsigned DEFAULT '1',
  `flagConsumptionTaxDeducted` int(10) unsigned DEFAULT '1',
  `flagConsumptionTaxIncluding` int(10) unsigned DEFAULT '1',
  `flagConsumptionTaxCalc` int(10) unsigned DEFAULT '1',
  `flagConsumptionTaxWithoutCalc` int(10) unsigned DEFAULT '1',
  `flagConsumptionTaxBusinessType` int(10) unsigned DEFAULT '1',
  `jsonFlag` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingEntityJpn`
--

LOCK TABLES `accountingEntityJpn` WRITE;
/*!40000 ALTER TABLE `accountingEntityJpn` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingEntityJpn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingFSIdJpn`
--

DROP TABLE IF EXISTS `accountingFSIdJpn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingFSIdJpn` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `jsonJgaapAccountTitlePL` longtext,
  `jsonJgaapAccountTitleBS` longtext,
  `jsonJgaapAccountTitleCR` longtext,
  `jsonJgaapFSPL` longtext,
  `jsonJgaapFSBS` longtext,
  `jsonJgaapFSCR` longtext,
  `jsonJgaapFSCS` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingFSIdJpn`
--

LOCK TABLES `accountingFSIdJpn` WRITE;
/*!40000 ALTER TABLE `accountingFSIdJpn` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingFSIdJpn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingFSJpn`
--

DROP TABLE IF EXISTS `accountingFSJpn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingFSJpn` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT NULL,
  `jsonJgaapAccountTitlePL` longtext,
  `jsonJgaapAccountTitleBS` longtext,
  `jsonJgaapAccountTitleCR` longtext,
  `jsonJgaapFSPL` longtext,
  `jsonJgaapFSBS` longtext,
  `jsonJgaapFSCR` longtext,
  `jsonJgaapFSCS` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingFSJpn`
--

LOCK TABLES `accountingFSJpn` WRITE;
/*!40000 ALTER TABLE `accountingFSJpn` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingFSJpn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingFSValueJpn`
--

DROP TABLE IF EXISTS `accountingFSValueJpn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingFSValueJpn` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT NULL,
  `jsonJgaapAccountTitlePL` longtext,
  `jsonJgaapAccountTitleBS` longtext,
  `jsonJgaapAccountTitleCR` longtext,
  `jsonJgaapFSPL` longtext,
  `jsonJgaapFSBS` longtext,
  `jsonJgaapFSCR` longtext,
  `jsonJgaapFSCS` longtext,
  `jsonConsumptionTax` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingFSValueJpn`
--

LOCK TABLES `accountingFSValueJpn` WRITE;
/*!40000 ALTER TABLE `accountingFSValueJpn` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingFSValueJpn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingFile`
--

DROP TABLE IF EXISTS `accountingFile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingFile` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT NULL,
  `jsonFileType` longtext,
  `jsonMail` longtext,
  `jsonMailHost` longtext,
  `strHost` text,
  `strUser` text,
  `strPassword` tinyblob,
  `numPort` varchar(5) DEFAULT '993',
  `flagSecure` varchar(5) DEFAULT 'ssl',
  `strMail` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingFile`
--

LOCK TABLES `accountingFile` WRITE;
/*!40000 ALTER TABLE `accountingFile` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingFile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingFixedAssetsJpn`
--

DROP TABLE IF EXISTS `accountingFixedAssetsJpn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingFixedAssetsJpn` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT NULL,
  `flagDepWrite` varchar(3) DEFAULT 'f1',
  `flagLossWrite` int(11) DEFAULT '0',
  `flagFractionDepWrite` varchar(5) DEFAULT 'ceil',
  `flagFractionDep` varchar(5) DEFAULT 'ceil',
  `flagFractionDepSurvivalRate` varchar(5) DEFAULT 'floor',
  `flagFractionDepSurvivalRateLimit` varchar(5) DEFAULT 'floor',
  `flagFractionRatioOperate` varchar(5) DEFAULT 'ceil',
  `jsonAccountTitle` longtext,
  `jsonDepSum` longtext,
  `numRatioOperateDepSum` decimal(5,2) DEFAULT '100.00',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingFixedAssetsJpn`
--

LOCK TABLES `accountingFixedAssetsJpn` WRITE;
/*!40000 ALTER TABLE `accountingFixedAssetsJpn` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingFixedAssetsJpn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingLog`
--

DROP TABLE IF EXISTS `accountingLog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingLog` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `stampArrive` bigint(20) DEFAULT NULL,
  `stampBook` bigint(20) NOT NULL,
  `idLog` bigint(20) unsigned DEFAULT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `idAccount` int(10) unsigned NOT NULL,
  `flagFiscalReport` varchar(3) DEFAULT NULL,
  `strTitle` varchar(100) DEFAULT NULL,
  `arrSpaceStrTag` mediumtext,
  `flagApply` int(10) unsigned DEFAULT NULL,
  `idAccountApply` int(10) unsigned DEFAULT NULL,
  `flagApplyBack` int(10) unsigned DEFAULT NULL,
  `arrCommaIdAccountPermit` text,
  `arrCommaIdLogFile` longtext,
  `jsonVersion` longtext,
  `numValue` decimal(19,0) unsigned DEFAULT NULL,
  `arrCommaIdDepartmentDebit` longtext,
  `arrCommaIdAccountTitleDebit` longtext,
  `arrCommaIdSubAccountTitleDebit` longtext,
  `arrCommaRateConsumptionTaxDebit` text,
  `arrCommaConsumptionTaxDebit` longtext,
  `arrCommaConsumptionTaxWithoutCalcDebit` longtext,
  `arrCommaTaxPaymentDebit` text,
  `arrCommaTaxReceiptDebit` text,
  `arrCommaIdDepartmentCredit` longtext,
  `arrCommaIdAccountTitleCredit` longtext,
  `arrCommaIdSubAccountTitleCredit` longtext,
  `arrCommaRateConsumptionTaxCredit` text,
  `arrCommaConsumptionTaxCredit` longtext,
  `arrCommaConsumptionTaxWithoutCalcCredit` longtext,
  `arrCommaTaxPaymentCredit` text,
  `arrCommaTaxReceiptCredit` text,
  `arrCommaIdDepartmentVersion` longtext,
  `arrCommaIdAccountTitleVersion` longtext,
  `arrCommaIdSubAccountTitleVersion` longtext,
  `jsonChargeHistory` longtext,
  `jsonPermitHistory` longtext,
  `flagRemove` int(10) unsigned DEFAULT '0',
  `stampRemove` bigint(20) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingLog`
--

LOCK TABLES `accountingLog` WRITE;
/*!40000 ALTER TABLE `accountingLog` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingLog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingLogBanks`
--

DROP TABLE IF EXISTS `accountingLogBanks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingLogBanks` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `idLogBanks` int(10) unsigned NOT NULL,
  `idLogAccount` int(10) unsigned NOT NULL,
  `idAccount` int(10) unsigned NOT NULL,
  `stampBook` bigint(20) NOT NULL,
  `strTitle` varchar(100) DEFAULT NULL,
  `flagIn` int(11) DEFAULT NULL,
  `numValueIn` decimal(19,0) unsigned DEFAULT NULL,
  `numValueOut` decimal(19,0) unsigned DEFAULT NULL,
  `numBalance` decimal(19,0) DEFAULT NULL,
  `arrSpaceStrTag` mediumtext,
  `jsonChargeHistory` longtext,
  `jsonWriteHistory` longtext,
  `jsonVersion` longtext,
  `flagCaution` int(11) DEFAULT '0',
  `flagRemove` int(10) unsigned DEFAULT '0',
  `stampRemove` bigint(20) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingLogBanks`
--

LOCK TABLES `accountingLogBanks` WRITE;
/*!40000 ALTER TABLE `accountingLogBanks` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingLogBanks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingLogBanksAccount`
--

DROP TABLE IF EXISTS `accountingLogBanksAccount`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingLogBanksAccount` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT NULL,
  `idLogAccount` int(10) unsigned DEFAULT NULL,
  `strTitle` varchar(100) DEFAULT NULL,
  `flagBank` text,
  `blobDetail` blob,
  `stampCheck` bigint(20) DEFAULT NULL,
  `flagLockReason` text,
  `flagLock` int(11) DEFAULT '0',
  `arrSpaceStrTag` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingLogBanksAccount`
--

LOCK TABLES `accountingLogBanksAccount` WRITE;
/*!40000 ALTER TABLE `accountingLogBanksAccount` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingLogBanksAccount` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingLogCalcJpn`
--

DROP TABLE IF EXISTS `accountingLogCalcJpn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingLogCalcJpn` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampBook` bigint(20) NOT NULL,
  `idLog` bigint(20) unsigned DEFAULT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `idAccount` int(10) unsigned NOT NULL,
  `strTitle` varchar(100) DEFAULT NULL,
  `flagFiscalReport` varchar(3) DEFAULT NULL,
  `flagDebit` int(10) unsigned DEFAULT NULL,
  `idAccountTitle` varchar(100) DEFAULT NULL,
  `idDepartment` int(10) unsigned DEFAULT NULL,
  `idSubAccountTitle` int(10) unsigned DEFAULT NULL,
  `idAccountTitleContra` varchar(100) DEFAULT NULL,
  `idDepartmentContra` int(10) unsigned DEFAULT NULL,
  `idSubAccountTitleContra` int(10) unsigned DEFAULT NULL,
  `numValue` decimal(19,0) unsigned DEFAULT NULL,
  `numValueConsumptionTax` decimal(19,0) DEFAULT '0',
  `numRateConsumptionTax` int(10) unsigned DEFAULT NULL,
  `flagConsumptionTax` text,
  `flagConsumptionTaxWithoutCalc` int(10) unsigned DEFAULT NULL,
  `numBalance` decimal(19,0) DEFAULT '0',
  `numBalanceSubAccount` decimal(19,0) DEFAULT '0',
  `numBalanceDepartment` decimal(19,0) DEFAULT '0',
  `numBalanceDepartmentSubAccount` decimal(19,0) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingLogCalcJpn`
--

LOCK TABLES `accountingLogCalcJpn` WRITE;
/*!40000 ALTER TABLE `accountingLogCalcJpn` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingLogCalcJpn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingLogCash`
--

DROP TABLE IF EXISTS `accountingLogCash`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingLogCash` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `stampBook` bigint(20) NOT NULL,
  `idLogCash` bigint(20) unsigned DEFAULT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `idAccount` int(10) unsigned NOT NULL,
  `strTitle` varchar(100) DEFAULT NULL,
  `arrSpaceStrTag` mediumtext,
  `flagIn` int(11) DEFAULT NULL,
  `flagPay` int(11) DEFAULT '0',
  `stampPay` bigint(20) DEFAULT '0',
  `arrCommaIdLogFile` longtext,
  `jsonVersion` longtext,
  `flagApply` int(10) unsigned DEFAULT NULL,
  `idAccountApply` int(10) unsigned DEFAULT NULL,
  `arrCommaIdAccountPermit` text,
  `numValue` decimal(19,0) unsigned DEFAULT NULL,
  `arrCommaIdDepartmentDebit` longtext,
  `arrCommaIdAccountTitleDebit` longtext,
  `arrCommaIdSubAccountTitleDebit` longtext,
  `arrCommaRateConsumptionTaxDebit` text,
  `arrCommaConsumptionTaxDebit` longtext,
  `arrCommaConsumptionTaxWithoutCalcDebit` longtext,
  `arrCommaTaxPaymentDebit` text,
  `arrCommaTaxReceiptDebit` text,
  `arrCommaIdDepartmentCredit` longtext,
  `arrCommaIdAccountTitleCredit` longtext,
  `arrCommaIdSubAccountTitleCredit` longtext,
  `arrCommaRateConsumptionTaxCredit` text,
  `arrCommaConsumptionTaxCredit` longtext,
  `arrCommaConsumptionTaxWithoutCalcCredit` longtext,
  `arrCommaTaxPaymentCredit` text,
  `arrCommaTaxReceiptCredit` text,
  `jsonChargeHistory` longtext,
  `jsonPermitHistory` longtext,
  `jsonWriteHistory` longtext,
  `flagRemove` int(10) unsigned DEFAULT '0',
  `stampRemove` bigint(20) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingLogCash`
--

LOCK TABLES `accountingLogCash` WRITE;
/*!40000 ALTER TABLE `accountingLogCash` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingLogCash` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingLogCashDefer`
--

DROP TABLE IF EXISTS `accountingLogCashDefer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingLogCashDefer` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `stampArrive` bigint(20) DEFAULT NULL,
  `stampBook` bigint(20) NOT NULL,
  `flagType` text,
  `numRow` int(10) unsigned DEFAULT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `idAccount` int(10) unsigned NOT NULL,
  `flagFiscalReport` varchar(3) DEFAULT NULL,
  `strTitle` varchar(100) DEFAULT NULL,
  `arrSpaceStrTag` mediumtext,
  `flagApply` int(10) unsigned DEFAULT NULL,
  `idAccountApply` int(10) unsigned DEFAULT NULL,
  `arrCommaIdAccountPermit` text,
  `jsonVersion` longtext,
  `numValue` decimal(19,0) unsigned DEFAULT NULL,
  `arrCommaIdDepartmentDebit` longtext,
  `arrCommaIdAccountTitleDebit` longtext,
  `arrCommaIdSubAccountTitleDebit` longtext,
  `arrCommaRateConsumptionTaxDebit` text,
  `arrCommaConsumptionTaxDebit` longtext,
  `arrCommaConsumptionTaxWithoutCalcDebit` longtext,
  `arrCommaTaxPaymentDebit` text,
  `arrCommaTaxReceiptDebit` text,
  `arrCommaIdDepartmentCredit` longtext,
  `arrCommaIdAccountTitleCredit` longtext,
  `arrCommaIdSubAccountTitleCredit` longtext,
  `arrCommaRateConsumptionTaxCredit` text,
  `arrCommaConsumptionTaxCredit` longtext,
  `arrCommaConsumptionTaxWithoutCalcCredit` longtext,
  `arrCommaTaxPaymentCredit` text,
  `arrCommaTaxReceiptCredit` text,
  `arrCommaIdDepartmentVersion` longtext,
  `arrCommaIdAccountTitleVersion` longtext,
  `arrCommaIdSubAccountTitleVersion` longtext,
  `jsonChargeHistory` longtext,
  `jsonPermitHistory` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingLogCashDefer`
--

LOCK TABLES `accountingLogCashDefer` WRITE;
/*!40000 ALTER TABLE `accountingLogCashDefer` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingLogCashDefer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingLogFile`
--

DROP TABLE IF EXISTS `accountingLogFile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingLogFile` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `stampArrive` bigint(20) DEFAULT NULL,
  `idLogFile` bigint(20) unsigned DEFAULT NULL,
  `idAccount` int(10) unsigned NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `strTitle` varchar(100) DEFAULT NULL,
  `numByte` bigint(20) unsigned NOT NULL,
  `numWidth` int(10) unsigned DEFAULT NULL,
  `numHeight` int(10) unsigned DEFAULT NULL,
  `strUrl` text,
  `strFileType` varchar(10) NOT NULL,
  `arrSpaceStrTag` mediumtext,
  `jsonVersion` longtext,
  `jsonChargeHistory` longtext,
  `idAccountUpload` int(10) unsigned NOT NULL,
  `flagRemove` int(10) unsigned DEFAULT '0',
  `stampRemove` bigint(20) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingLogFile`
--

LOCK TABLES `accountingLogFile` WRITE;
/*!40000 ALTER TABLE `accountingLogFile` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingLogFile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingLogFixedAssetsJpn`
--

DROP TABLE IF EXISTS `accountingLogFixedAssetsJpn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingLogFixedAssetsJpn` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idFixedAssets` int(10) unsigned NOT NULL,
  `idAccount` int(10) unsigned NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `strTitle` varchar(100) DEFAULT NULL,
  `idAccountTitle` varchar(100) DEFAULT NULL,
  `flagDepMethod` varchar(100) DEFAULT NULL,
  `numUsefulLife` int(11) DEFAULT NULL,
  `numVolume` decimal(7,2) unsigned DEFAULT NULL,
  `flagDepUnit` varchar(100) DEFAULT NULL,
  `idDepartment` int(10) unsigned DEFAULT NULL,
  `flagTaxFixed` varchar(100) DEFAULT NULL,
  `flagTaxFixedType` varchar(100) DEFAULT NULL,
  `flagDepUp` varchar(100) DEFAULT NULL,
  `flagDepDown` varchar(100) DEFAULT NULL,
  `stampBuy` bigint(20) DEFAULT NULL,
  `stampStart` bigint(20) NOT NULL,
  `stampEnd` bigint(20) DEFAULT NULL,
  `stampDrop` bigint(20) DEFAULT NULL,
  `numValue` decimal(19,0) unsigned DEFAULT NULL,
  `numValueCompression` decimal(19,0) unsigned DEFAULT NULL,
  `numValueNet` decimal(19,0) unsigned DEFAULT NULL,
  `numSurvivalRate` decimal(3,0) unsigned DEFAULT NULL,
  `numSurvivalRateLimit` decimal(3,0) unsigned DEFAULT NULL,
  `numValueRemainingBook` decimal(19,0) unsigned DEFAULT NULL,
  `numValueAccumulated` decimal(19,0) unsigned DEFAULT NULL,
  `numValueNetOpening` decimal(19,0) unsigned DEFAULT NULL,
  `numValueDepCalcBase` decimal(19,0) unsigned DEFAULT NULL,
  `numValueDepPrevOver` decimal(19,0) unsigned DEFAULT NULL,
  `arrCommaDepMonth` varchar(28) DEFAULT NULL,
  `numRateDep` decimal(6,5) unsigned DEFAULT NULL,
  `flagDepRateType` int(10) unsigned DEFAULT '1',
  `numValueAssured` decimal(19,0) unsigned DEFAULT NULL,
  `numValueDepCalc` decimal(19,0) unsigned DEFAULT NULL,
  `numValueDepUp` decimal(19,0) unsigned DEFAULT NULL,
  `numValueDepExtra` decimal(19,0) unsigned DEFAULT NULL,
  `numValueDepSpecial` decimal(19,0) unsigned DEFAULT NULL,
  `numValueDepSpecialShortPrev` decimal(19,0) unsigned DEFAULT NULL,
  `numValueDepLimit` decimal(19,0) unsigned DEFAULT NULL,
  `numValueDep` decimal(19,0) unsigned DEFAULT NULL,
  `numValueAccumulatedClosing` decimal(19,0) unsigned DEFAULT NULL,
  `numValueNetClosing` decimal(19,0) unsigned DEFAULT NULL,
  `numRatioOperate` decimal(5,2) DEFAULT '100.00',
  `numValueDepOperate` decimal(19,0) unsigned DEFAULT NULL,
  `numValueDepCurrentOver` decimal(19,0) DEFAULT NULL,
  `numValueDepNextOver` decimal(19,0) unsigned DEFAULT NULL,
  `numValueDepSpecialShortCurrent` decimal(19,0) unsigned DEFAULT NULL,
  `numValueDepSpecialShortCurrentCut` decimal(19,0) unsigned DEFAULT NULL,
  `numValueDepSpecialShortNext` decimal(19,0) unsigned DEFAULT NULL,
  `lossOnDisposalOfFixedAssets` varchar(100) DEFAULT NULL,
  `accumulatedDepreciation` varchar(100) DEFAULT NULL,
  `sellingAdminCost` varchar(100) DEFAULT NULL,
  `productsCost` varchar(100) DEFAULT NULL,
  `nonOperatingExpenses` varchar(100) DEFAULT NULL,
  `agricultureCost` varchar(100) DEFAULT NULL,
  `numRatioSellingAdminCost` decimal(5,2) DEFAULT '100.00',
  `numRatioProductsCost` decimal(5,2) DEFAULT '0.00',
  `numRatioNonOperatingExpenses` decimal(5,2) DEFAULT '0.00',
  `numRatioAgricultureCost` decimal(5,2) DEFAULT '0.00',
  `flagFraction` varchar(100) DEFAULT NULL,
  `strMemo` text,
  `arrSpaceStrTag` mediumtext,
  `jsonChargeHistory` longtext,
  `jsonWriteHistory` longtext,
  `jsonVersion` longtext,
  `flagRemove` int(10) unsigned DEFAULT '0',
  `stampRemove` bigint(20) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingLogFixedAssetsJpn`
--

LOCK TABLES `accountingLogFixedAssetsJpn` WRITE;
/*!40000 ALTER TABLE `accountingLogFixedAssetsJpn` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingLogFixedAssetsJpn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingLogHouseJpn`
--

DROP TABLE IF EXISTS `accountingLogHouseJpn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingLogHouseJpn` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `idLogHouse` bigint(20) unsigned DEFAULT NULL,
  `strTitle` varchar(100) DEFAULT NULL,
  `numRatio` decimal(5,2) DEFAULT '100.00',
  `flagApply` int(10) unsigned DEFAULT NULL,
  `idAccountApply` int(10) unsigned DEFAULT NULL,
  `arrCommaIdAccountPermit` text,
  `arrCommaIdDepartmentDebit` longtext,
  `arrCommaIdAccountTitleDebit` longtext,
  `arrCommaIdSubAccountTitleDebit` longtext,
  `arrCommaRateConsumptionTaxDebit` text,
  `arrCommaConsumptionTaxDebit` longtext,
  `arrCommaConsumptionTaxWithoutCalcDebit` longtext,
  `arrCommaTaxPaymentDebit` text,
  `arrCommaTaxReceiptDebit` text,
  `arrCommaIdDepartmentCredit` longtext,
  `arrCommaIdAccountTitleCredit` longtext,
  `arrCommaIdSubAccountTitleCredit` longtext,
  `arrCommaRateConsumptionTaxCredit` text,
  `arrCommaConsumptionTaxCredit` longtext,
  `arrCommaConsumptionTaxWithoutCalcCredit` longtext,
  `arrCommaTaxPaymentCredit` text,
  `arrCommaTaxReceiptCredit` text,
  `jsonVersion` longtext,
  `jsonPermitHistory` longtext,
  `arrSpaceStrTag` text,
  `jsonWriteHistory` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingLogHouseJpn`
--

LOCK TABLES `accountingLogHouseJpn` WRITE;
/*!40000 ALTER TABLE `accountingLogHouseJpn` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingLogHouseJpn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingLogImportJpn`
--

DROP TABLE IF EXISTS `accountingLogImportJpn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingLogImportJpn` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `idLogImport` bigint(20) unsigned DEFAULT NULL,
  `strTitle` varchar(100) DEFAULT NULL,
  `flagAttest` varchar(5) DEFAULT NULL,
  `flagApply` int(10) unsigned DEFAULT NULL,
  `idAccountApply` int(10) unsigned DEFAULT NULL,
  `arrCommaIdAccountPermit` text,
  `arrCommaIdDepartmentDebit` longtext,
  `arrCommaIdAccountTitleDebit` longtext,
  `arrCommaIdSubAccountTitleDebit` longtext,
  `arrCommaRateConsumptionTaxDebit` text,
  `arrCommaConsumptionTaxDebit` longtext,
  `arrCommaConsumptionTaxWithoutCalcDebit` longtext,
  `arrCommaTaxPaymentDebit` text,
  `arrCommaTaxReceiptDebit` text,
  `arrCommaIdDepartmentCredit` longtext,
  `arrCommaIdAccountTitleCredit` longtext,
  `arrCommaIdSubAccountTitleCredit` longtext,
  `arrCommaRateConsumptionTaxCredit` text,
  `arrCommaConsumptionTaxCredit` longtext,
  `arrCommaConsumptionTaxWithoutCalcCredit` longtext,
  `arrCommaTaxPaymentCredit` text,
  `arrCommaTaxReceiptCredit` text,
  `jsonVersion` longtext,
  `jsonPermitHistory` longtext,
  `numColStampBook` int(11) DEFAULT '1',
  `numColNumValue` int(11) DEFAULT '2',
  `numColStrTitle` int(11) DEFAULT '3',
  `arrSpaceStrTag` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingLogImportJpn`
--

LOCK TABLES `accountingLogImportJpn` WRITE;
/*!40000 ALTER TABLE `accountingLogImportJpn` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingLogImportJpn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingLogImportRetryJpn`
--

DROP TABLE IF EXISTS `accountingLogImportRetryJpn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingLogImportRetryJpn` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idAccount` int(10) unsigned NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `idLogRetry` bigint(20) unsigned DEFAULT NULL,
  `flagType` text,
  `jsonData` longtext,
  `arrSpaceStrTag` mediumtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingLogImportRetryJpn`
--

LOCK TABLES `accountingLogImportRetryJpn` WRITE;
/*!40000 ALTER TABLE `accountingLogImportRetryJpn` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingLogImportRetryJpn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingLogMailJpn`
--

DROP TABLE IF EXISTS `accountingLogMailJpn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingLogMailJpn` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT NULL,
  `jsonMail` longtext,
  `jsonMailHost` longtext,
  `strHost` text,
  `strUser` text,
  `strPassword` tinyblob,
  `numPort` varchar(5) DEFAULT '993',
  `flagSecure` varchar(5) DEFAULT 'ssl',
  `strMail` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingLogMailJpn`
--

LOCK TABLES `accountingLogMailJpn` WRITE;
/*!40000 ALTER TABLE `accountingLogMailJpn` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingLogMailJpn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingNotesFSJpn`
--

DROP TABLE IF EXISTS `accountingNotesFSJpn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingNotesFSJpn` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `strComment` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingNotesFSJpn`
--

LOCK TABLES `accountingNotesFSJpn` WRITE;
/*!40000 ALTER TABLE `accountingNotesFSJpn` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingNotesFSJpn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingPreference`
--

DROP TABLE IF EXISTS `accountingPreference`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingPreference` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `jsonStampUpdate` longtext,
  `flagMaintenance` int(1) unsigned DEFAULT '0',
  `arrCommaIdAccountMaintenance` longtext,
  `strVersion` varchar(11) DEFAULT NULL,
  `flagIdAccountTitle` int(1) unsigned DEFAULT '0',
  `accessCode` varchar(100) DEFAULT NULL,
  `jsonVersion` longtext,
  `jsonIdAutoIncrement` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingPreference`
--

LOCK TABLES `accountingPreference` WRITE;
/*!40000 ALTER TABLE `accountingPreference` DISABLE KEYS */;
INSERT INTO `accountingPreference` VALUES (1,1457615946,1457615946,NULL,0,NULL,'1.43.11',0,NULL,'{\"1.43.11\":1}',NULL);
/*!40000 ALTER TABLE `accountingPreference` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingSubAccountTitleJpn`
--

DROP TABLE IF EXISTS `accountingSubAccountTitleJpn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingSubAccountTitleJpn` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idSubAccountTitle` int(10) unsigned DEFAULT '0',
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `idAccountTitle` varchar(100) DEFAULT NULL,
  `strTitle` text,
  `arrSpaceStrTag` mediumtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingSubAccountTitleJpn`
--

LOCK TABLES `accountingSubAccountTitleJpn` WRITE;
/*!40000 ALTER TABLE `accountingSubAccountTitleJpn` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingSubAccountTitleJpn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingSubAccountTitleValueJpn`
--

DROP TABLE IF EXISTS `accountingSubAccountTitleValueJpn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingSubAccountTitleValueJpn` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idSubAccountTitle` int(10) unsigned NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `jsonData` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingSubAccountTitleValueJpn`
--

LOCK TABLES `accountingSubAccountTitleValueJpn` WRITE;
/*!40000 ALTER TABLE `accountingSubAccountTitleValueJpn` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingSubAccountTitleValueJpn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountingSummaryStatementJpn`
--

DROP TABLE IF EXISTS `accountingSummaryStatementJpn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountingSummaryStatementJpn` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idEntity` int(10) unsigned NOT NULL,
  `numFiscalPeriod` int(10) unsigned DEFAULT '1',
  `flagReport` varchar(100) DEFAULT NULL,
  `flagDetail` varchar(100) DEFAULT NULL,
  `jsonJgaapAccountTitleBS` longtext,
  `jsonJgaapAccountTitlePL` longtext,
  `jsonJgaapAccountTitleCR` longtext,
  `jsonData` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountingSummaryStatementJpn`
--

LOCK TABLES `accountingSummaryStatementJpn` WRITE;
/*!40000 ALTER TABLE `accountingSummaryStatementJpn` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountingSummaryStatementJpn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `baseAccessLog`
--

DROP TABLE IF EXISTS `baseAccessLog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `baseAccessLog` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `ip` varchar(15) NOT NULL,
  `strHost` text,
  `idAccount` bigint(20) unsigned DEFAULT NULL,
  `strDbType` text,
  `strDevice` text,
  `idModule` text,
  `strChild` text,
  `strExt` text,
  `strFunc` text,
  `jsonQuery` mediumtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `baseAccessLog`
--

LOCK TABLES `baseAccessLog` WRITE;
/*!40000 ALTER TABLE `baseAccessLog` DISABLE KEYS */;
/*!40000 ALTER TABLE `baseAccessLog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `baseAccessUnknown`
--

DROP TABLE IF EXISTS `baseAccessUnknown`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `baseAccessUnknown` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ip` varchar(15) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `baseAccessUnknown`
--

LOCK TABLES `baseAccessUnknown` WRITE;
/*!40000 ALTER TABLE `baseAccessUnknown` DISABLE KEYS */;
/*!40000 ALTER TABLE `baseAccessUnknown` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `baseAccount`
--

DROP TABLE IF EXISTS `baseAccount`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `baseAccount` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `flagLock` int(1) unsigned DEFAULT '0',
  `flagWebmaster` int(1) unsigned DEFAULT '0',
  `strCodeName` varchar(100) NOT NULL,
  `idLogin` text NOT NULL,
  `strPassword` text NOT NULL,
  `stampUpdatePassword` bigint(20) DEFAULT NULL,
  `strMailPc` text NOT NULL,
  `flagLoginMail` int(1) unsigned DEFAULT '0',
  `flagLoginSecond` int(1) unsigned DEFAULT '0',
  `strMailMobile` text,
  `idMobile` text,
  `strMobileCarrier` varchar(100) DEFAULT NULL,
  `numTimeZone` int(11) DEFAULT NULL,
  `strLang` varchar(2) DEFAULT NULL,
  `strHoliday` varchar(2) DEFAULT NULL,
  `numList` int(10) unsigned DEFAULT '25',
  `numAutoLogout` int(10) unsigned DEFAULT '0',
  `numAutoPopup` int(10) unsigned DEFAULT '0',
  `strAutoBoot` varchar(100) DEFAULT 'base',
  `idTerm` bigint(20) unsigned DEFAULT NULL,
  `idModule` bigint(20) unsigned DEFAULT NULL,
  `arrSpaceStrTag` mediumtext,
  `jsonStampCheck` mediumtext,
  `flagDefault` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `baseAccount`
--

LOCK TABLES `baseAccount` WRITE;
/*!40000 ALTER TABLE `baseAccount` DISABLE KEYS */;
INSERT INTO `baseAccount` VALUES (1,1457615946,1457615946,0,1,'管理者','admin','70f30ef754f87447f82e4a3c2a396043a4f28aae0bef60d3abe948ec2561b6f3',1457615946,'dummy@dummy.dummy',0,0,NULL,NULL,NULL,9,'ja','jp',25,0,0,'base',1,1,NULL,'[]',1);
/*!40000 ALTER TABLE `baseAccount` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `baseAccountId`
--

DROP TABLE IF EXISTS `baseAccountId`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `baseAccountId` (
  `id` bigint(20) unsigned DEFAULT NULL,
  `strCodeName` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `baseAccountId`
--

LOCK TABLES `baseAccountId` WRITE;
/*!40000 ALTER TABLE `baseAccountId` DISABLE KEYS */;
/*!40000 ALTER TABLE `baseAccountId` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `baseAccountMemo`
--

DROP TABLE IF EXISTS `baseAccountMemo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `baseAccountMemo` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `idAccount` bigint(20) unsigned NOT NULL,
  `flagColumn` varchar(50) NOT NULL,
  `jsonData` mediumtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `baseAccountMemo`
--

LOCK TABLES `baseAccountMemo` WRITE;
/*!40000 ALTER TABLE `baseAccountMemo` DISABLE KEYS */;
INSERT INTO `baseAccountMemo` VALUES (1,1457615946,1457615946,1,'jsonTermNaviSearch',NULL),(2,1457615946,1457615946,1,'jsonModuleNaviSearch',NULL),(3,1457615946,1457615946,1,'jsonAccountNaviSearch',NULL),(4,1457615946,1457615946,1,'jsonLogNaviSearch',NULL),(5,1457615946,1457615946,1,'jsonApiAccountNaviSearch',NULL);
/*!40000 ALTER TABLE `baseAccountMemo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `baseApiAccount`
--

DROP TABLE IF EXISTS `baseApiAccount`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `baseApiAccount` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `ip` varchar(15) NOT NULL,
  `strSiteUrl` text,
  `idAccount` bigint(20) unsigned NOT NULL,
  `arrSpaceStrTag` mediumtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `baseApiAccount`
--

LOCK TABLES `baseApiAccount` WRITE;
/*!40000 ALTER TABLE `baseApiAccount` DISABLE KEYS */;
/*!40000 ALTER TABLE `baseApiAccount` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `baseApplyChange`
--

DROP TABLE IF EXISTS `baseApplyChange`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `baseApplyChange` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `idAccount` bigint(20) unsigned DEFAULT NULL,
  `session` varchar(100) NOT NULL,
  `ip` varchar(15) NOT NULL,
  `strCodeName` text,
  `idLogin` text,
  `strMailPc` text,
  `flagAttest` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `baseApplyChange`
--

LOCK TABLES `baseApplyChange` WRITE;
/*!40000 ALTER TABLE `baseApplyChange` DISABLE KEYS */;
/*!40000 ALTER TABLE `baseApplyChange` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `baseApplyForgot`
--

DROP TABLE IF EXISTS `baseApplyForgot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `baseApplyForgot` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `idAccount` bigint(20) unsigned NOT NULL,
  `session` varchar(100) NOT NULL,
  `ip` varchar(15) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `baseApplyForgot`
--

LOCK TABLES `baseApplyForgot` WRITE;
/*!40000 ALTER TABLE `baseApplyForgot` DISABLE KEYS */;
/*!40000 ALTER TABLE `baseApplyForgot` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `baseApplySign`
--

DROP TABLE IF EXISTS `baseApplySign`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `baseApplySign` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `session` varchar(100) NOT NULL,
  `ip` varchar(15) NOT NULL,
  `strCodeName` text,
  `idLogin` text,
  `strMailPc` text,
  `flagAttest` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `baseApplySign`
--

LOCK TABLES `baseApplySign` WRITE;
/*!40000 ALTER TABLE `baseApplySign` DISABLE KEYS */;
/*!40000 ALTER TABLE `baseApplySign` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `baseLock`
--

DROP TABLE IF EXISTS `baseLock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `baseLock` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `idAccount` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `baseLock`
--

LOCK TABLES `baseLock` WRITE;
/*!40000 ALTER TABLE `baseLock` DISABLE KEYS */;
/*!40000 ALTER TABLE `baseLock` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `baseLoginIdLogin`
--

DROP TABLE IF EXISTS `baseLoginIdLogin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `baseLoginIdLogin` (
  `stampRegister` bigint(20) NOT NULL,
  `idLogin` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `baseLoginIdLogin`
--

LOCK TABLES `baseLoginIdLogin` WRITE;
/*!40000 ALTER TABLE `baseLoginIdLogin` DISABLE KEYS */;
INSERT INTO `baseLoginIdLogin` VALUES (1457615946,'admin');
/*!40000 ALTER TABLE `baseLoginIdLogin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `baseLoginMiss`
--

DROP TABLE IF EXISTS `baseLoginMiss`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `baseLoginMiss` (
  `stampRegister` bigint(20) NOT NULL,
  `ip` varchar(15) NOT NULL,
  `idLogin` text NOT NULL,
  `strPassword` text NOT NULL,
  `strError` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `baseLoginMiss`
--

LOCK TABLES `baseLoginMiss` WRITE;
/*!40000 ALTER TABLE `baseLoginMiss` DISABLE KEYS */;
/*!40000 ALTER TABLE `baseLoginMiss` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `baseLoginPassword`
--

DROP TABLE IF EXISTS `baseLoginPassword`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `baseLoginPassword` (
  `stampRegister` bigint(20) NOT NULL,
  `idAccount` bigint(20) unsigned DEFAULT NULL,
  `strPassword` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `baseLoginPassword`
--

LOCK TABLES `baseLoginPassword` WRITE;
/*!40000 ALTER TABLE `baseLoginPassword` DISABLE KEYS */;
INSERT INTO `baseLoginPassword` VALUES (1457615946,1,'70f30ef754f87447f82e4a3c2a396043a4f28aae0bef60d3abe948ec2561b6f3');
/*!40000 ALTER TABLE `baseLoginPassword` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `baseLoginSecond`
--

DROP TABLE IF EXISTS `baseLoginSecond`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `baseLoginSecond` (
  `stampRegister` bigint(20) NOT NULL,
  `ip` varchar(15) NOT NULL,
  `session` varchar(100) NOT NULL,
  `idAccount` bigint(20) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `baseLoginSecond`
--

LOCK TABLES `baseLoginSecond` WRITE;
/*!40000 ALTER TABLE `baseLoginSecond` DISABLE KEYS */;
/*!40000 ALTER TABLE `baseLoginSecond` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `baseModule`
--

DROP TABLE IF EXISTS `baseModule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `baseModule` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `strTitle` text NOT NULL,
  `arrCommaIdModuleUser` mediumtext,
  `arrCommaIdModuleAdmin` mediumtext,
  `arrSpaceStrTag` mediumtext,
  `flagDefault` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `baseModule`
--

LOCK TABLES `baseModule` WRITE;
/*!40000 ALTER TABLE `baseModule` DISABLE KEYS */;
INSERT INTO `baseModule` VALUES (1,1457615946,1457615946,'全モジュール管理者',',base,',',base,','',1),(2,1457615946,1457615946,'統制モジュールユーザ',',base,','','',1);
/*!40000 ALTER TABLE `baseModule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `basePreference`
--

DROP TABLE IF EXISTS `basePreference`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `basePreference` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `jsonStampUpdate` mediumtext,
  `flagMaintenance` int(1) unsigned DEFAULT '0',
  `arrCommaIdAccountMaintenance` mediumtext,
  `numTimeZone` int(11) DEFAULT NULL,
  `strTopUrl` text,
  `numAutoLock` int(10) unsigned DEFAULT '3',
  `numPasswordLimit` varchar(7) DEFAULT '0',
  `numPassword` int(11) DEFAULT '4',
  `arrCommaLockAccount` mediumtext,
  `flagLoginMail` int(1) unsigned DEFAULT '0',
  `flagAccessUnknownMail` int(1) unsigned DEFAULT '0',
  `flagLoginSecond` int(1) unsigned DEFAULT '0',
  `flagVersionUpdate` int(1) unsigned DEFAULT '0',
  `strSiteName` text NOT NULL,
  `strSiteUrl` text,
  `strSiteMailPc` text NOT NULL,
  `numAutoMustLogout` int(10) unsigned DEFAULT '0',
  `flagForgot` int(1) unsigned DEFAULT '0',
  `flagSign` int(1) unsigned DEFAULT '0',
  `jsonIpAccessAccept` mediumtext,
  `jsonIpSubnetAccessAccept` mediumtext,
  `flagReject` int(1) unsigned DEFAULT '1',
  `jsonIpAccessReject` mediumtext,
  `jsonIpSubnetAccessReject` mediumtext,
  `jsonIpSignReject` mediumtext,
  `jsonIpSubnetSignReject` mediumtext,
  `jsonMailSignReject` mediumtext,
  `jsonMailHostSignReject` mediumtext,
  `jsonModule` mediumtext,
  `strVersion` varchar(11) DEFAULT NULL,
  `jsonVersion` mediumtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `basePreference`
--

LOCK TABLES `basePreference` WRITE;
/*!40000 ALTER TABLE `basePreference` DISABLE KEYS */;
INSERT INTO `basePreference` VALUES (1,1457615946,1457615946,'[]',0,NULL,9,'http://localhost:5000/',3,'0',4,NULL,0,0,0,0,'テストサイト','http://dummy.dummy/','dummy@dummy.dummy',0,0,0,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,'{\"accounting\":1,\"base\":1}','1.43.11','{\"1.43.11\":1}');
/*!40000 ALTER TABLE `basePreference` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `basePublish`
--

DROP TABLE IF EXISTS `basePublish`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `basePublish` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `session` varchar(100) DEFAULT NULL,
  `idAccount` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `basePublish`
--

LOCK TABLES `basePublish` WRITE;
/*!40000 ALTER TABLE `basePublish` DISABLE KEYS */;
/*!40000 ALTER TABLE `basePublish` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `baseSession`
--

DROP TABLE IF EXISTS `baseSession`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `baseSession` (
  `stampRegister` bigint(20) NOT NULL,
  `ip` varchar(15) NOT NULL,
  `idCookie` varchar(100) NOT NULL,
  `idMobile` text,
  `idAccount` bigint(20) unsigned NOT NULL,
  `flagAPI` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `baseSession`
--

LOCK TABLES `baseSession` WRITE;
/*!40000 ALTER TABLE `baseSession` DISABLE KEYS */;
/*!40000 ALTER TABLE `baseSession` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `baseTerm`
--

DROP TABLE IF EXISTS `baseTerm`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `baseTerm` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stampRegister` bigint(20) NOT NULL,
  `stampUpdate` bigint(20) NOT NULL,
  `strTitle` text NOT NULL,
  `stampStart` bigint(20) NOT NULL,
  `stampEnd` bigint(20) DEFAULT NULL,
  `arrSpaceStrTag` mediumtext,
  `flagDefault` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `baseTerm`
--

LOCK TABLES `baseTerm` WRITE;
/*!40000 ALTER TABLE `baseTerm` DISABLE KEYS */;
INSERT INTO `baseTerm` VALUES (1,1457615946,1457615946,'期間制限なし',1457615946,0,'',1),(2,1457615946,1457615946,'期限切れ',1457529546,1457615945,'',1);
/*!40000 ALTER TABLE `baseTerm` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `baseToken`
--

DROP TABLE IF EXISTS `baseToken`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `baseToken` (
  `stampRegister` bigint(20) NOT NULL,
  `token` varchar(100) NOT NULL,
  `idAccount` bigint(20) unsigned DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `baseToken`
--

LOCK TABLES `baseToken` WRITE;
/*!40000 ALTER TABLE `baseToken` DISABLE KEYS */;
/*!40000 ALTER TABLE `baseToken` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-03-10 22:19:25
