-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Jan 16, 2021 at 10:43 PM
-- Server version: 5.7.31
-- PHP Version: 7.3.21

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db3`
--
CREATE DATABASE IF NOT EXISTS `db3` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `db3`;

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `find_employee_rank_date`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_employee_rank_date` (IN `var_Rank` VARCHAR(50), IN `var_Date` DATE)  BEGIN

#This query will help track an employee with a specific rank that got hired before a specific date.

SELECT CONCAT(Person_FName," ", Person_LName) as "Receptionist Names", Employee_DateHired 
FROM person p, employee e, receptionist r 
WHERE p.person_ID = e.employee_ID 
AND e.employee_ID = r.receptionist_ID 
AND Receptionist_Rank = var_Rank
AND Employee_DateHired < var_Date;

END$$

DROP PROCEDURE IF EXISTS `find_med_by_date_price`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_med_by_date_price` (IN `var_date` DATE, IN `var_price1` DECIMAL(20,2), IN `var_price2` DECIMAL(20,2))  BEGIN

#Retrieves the names of medication that was prescribed that has not expired within a specific price range.
#This query will help track the medication that has not gone over their expiration date where it matches their price range.

SELECT Medication_Name, Medication_Expire, Medication_Price
FROM medication
WHERE Medication_Expire <= var_date 
AND Medication_Price BETWEEN var_price1 AND var_price2;

END$$

DROP PROCEDURE IF EXISTS `find_patient_allergy`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_patient_allergy` (IN `var_Allergy` VARCHAR(50))  BEGIN

#This query will help track patients with a specific allergy or whether if they have one or not.

SELECT DISTINCT CONCAT(Person_FName," ", Person_LName) as "Patient Name", Record_Allergy as Allergy 
FROM person p, patient pa, treatment t, record r 
WHERE p.Person_ID = pa.Patient_ID 
AND pa.Patient_ID = t.Patient_ID 
AND t.Patient_ID = r.Patient_ID 
AND Record_Allergy = var_Allergy;

END$$

DROP PROCEDURE IF EXISTS `find_patient_by_blood_letter`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_patient_by_blood_letter` (IN `var_letter` VARCHAR(5))  BEGIN

#This query will help track patients that have a specific letter in their blood type. 

SELECT DISTINCT CONCAT(Person_FName," ", Person_LName) as "Patient Names", Record_Bloodtype as "Blood Type" 
FROM person p, patient pa, treatment t, record r 
WHERE p.Person_ID = pa.Patient_ID 
AND pa.Patient_ID = t.Patient_ID 
AND t.Patient_ID = r.Patient_ID 
AND Record_Bloodtype RLIKE var_letter;

END$$

DROP PROCEDURE IF EXISTS `find_patient_by_date`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_patient_by_date` (IN `var_StartDate` DATE, IN `var_EndDate` DATE)  BEGIN

#  This query will be flexible to help track patients between the range of specific dates.

SELECT CONCAT(p.Person_FName," ",p.Person_LName) as "Patient Names", Treatment_Date 
FROM person p, treatment t, patient pa 
WHERE p.Person_ID = pa.Patient_ID 
AND pa.Patient_ID = t.Patient_ID 
AND t.Treatment_Date BETWEEN var_StartDate AND var_EndDate;

END$$

DROP PROCEDURE IF EXISTS `find_patient_by_med_letter`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_patient_by_med_letter` (IN `var_MedLetter` VARCHAR(5))  BEGIN

#This query will help track patients that received medication that has a specific letter within desirable position.

SELECT CONCAT (Person_FName," ", Person_LName) as "Patient Names", Medication_Name
FROM person p, treatment t, patient pa, prescription pr, medication m 
WHERE p.Person_ID = pa.Patient_ID 
AND pa.Patient_ID = t.Patient_ID 
AND t.Patient_ID = pr.Patient_ID 
AND pr.Medication_ID = m.Medication_ID 
AND m.Medication_Name RLIKE var_MedLetter;

END$$

DROP PROCEDURE IF EXISTS `find_patient_by_med_price`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_patient_by_med_price` (IN `var_MedPrice` DECIMAL(20,2))  BEGIN

#This query will help track patients that received medication that is under specific price.

SELECT DISTINCT CONCAT(p.Person_FName," ",p.Person_LName) as "Patient Names", CONCAT("$",FORMAT(m.Medication_Price,2)) as "Medication Price" 
FROM person p, patient pa, treatment t, prescription pr, medication m 
WHERE p.Person_ID = pa.Patient_ID 
AND pa.Patient_ID = t.Patient_ID 
AND t.Patient_ID = pr.Patient_ID 
AND pr.Medication_ID = m.Medication_ID 
AND m.Medication_Price <= var_MedPrice;

END$$

DROP PROCEDURE IF EXISTS `find_person_by_date_state`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_person_by_date_state` (IN `var_state` VARCHAR(2), IN `var_date1` DATE, IN `var_date2` DATE)  BEGIN

#This query will help track people that were born within a certain date range and within a certain state.   
#Type in the specific state and range of dates in order to retrieve its data.

SELECT CONCAT(Person_FName," ", Person_LName) as "Names", Person_DOB Person_State
FROM person
WHERE Person_DOB BETWEEN var_date1 AND var_date2
AND Person_State = var_state;

END$$

DROP PROCEDURE IF EXISTS `find_salary_rating`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_salary_rating` (IN `var_excellent` DECIMAL(20,2), IN `var_bad` DECIMAL(20,2))  BEGIN

#This query will help track the employees’ salaries and see if they are paid reasonably or not by setting up the range of excellent and bad salary

SELECT Person_LName as "Last Names", CONCAT("$", FORMAT(Employee_Salary,2)) as Salary, 
IF(e.Employee_Salary < var_bad, "bad", IF(e.Employee_Salary >= var_excellent, "excellent", "moderate")) as Rating 
FROM person p, employee e 
WHERE p.Person_ID = e.Employee_ID;

END$$

DROP PROCEDURE IF EXISTS `SameDate`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SameDate` ()  BEGIN

# Retrieve the patients who have received a treatment the same day they visited the hospital.
#This query will help to see whether the hospital treated the patients right away. They might have not treated them right away if it was not an emergency.

SELECT CONCAT(Person_FName," ", Person_LName) as "Patient Names", Treatment_Date, Patient_DateVisted as "Date Visited"
FROM person p, patient pa, treatment t 
WHERE p.Person_ID = pa.Patient_ID 
AND pa.Patient_ID = t.Patient_ID 
AND t.Treatment_Date = pa.Patient_DateVisted;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `doctor`
--

DROP TABLE IF EXISTS `doctor`;
CREATE TABLE IF NOT EXISTS `doctor` (
  `Doctor_ID` int(11) NOT NULL AUTO_INCREMENT,
  `Doctor_Specialty` varchar(50) NOT NULL,
  PRIMARY KEY (`Doctor_ID`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `doctor`
--

INSERT INTO `doctor` (`Doctor_ID`, `Doctor_Specialty`) VALUES
(1, 'Cardiologist'),
(2, 'Surgeon'),
(3, 'Pediatrician'),
(4, 'Dermatologist'),
(5, 'Surgeon');

-- --------------------------------------------------------

--
-- Table structure for table `employee`
--

DROP TABLE IF EXISTS `employee`;
CREATE TABLE IF NOT EXISTS `employee` (
  `Employee_ID` int(20) NOT NULL AUTO_INCREMENT,
  `Employee_DateHired` date NOT NULL,
  `Employee_Salary` decimal(20,2) NOT NULL,
  PRIMARY KEY (`Employee_ID`)
) ENGINE=MyISAM AUTO_INCREMENT=21 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `employee`
--

INSERT INTO `employee` (`Employee_ID`, `Employee_DateHired`, `Employee_Salary`) VALUES
(1, '2015-02-09', '80000.00'),
(2, '2010-11-15', '95000.00'),
(3, '2002-04-25', '100000.00'),
(4, '1999-07-03', '150000.00'),
(5, '2020-08-24', '50000.00'),
(11, '2009-05-12', '35000.00'),
(12, '2008-08-23', '45000.00'),
(13, '2012-07-09', '30000.00'),
(14, '2019-06-28', '25000.00'),
(15, '2020-02-23', '20000.00');

-- --------------------------------------------------------

--
-- Table structure for table `medication`
--

DROP TABLE IF EXISTS `medication`;
CREATE TABLE IF NOT EXISTS `medication` (
  `Medication_ID` int(11) NOT NULL AUTO_INCREMENT,
  `Medication_Name` varchar(50) NOT NULL,
  `Medication_Price` decimal(20,2) NOT NULL,
  `Medication_Expire` date NOT NULL,
  PRIMARY KEY (`Medication_ID`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `medication`
--

INSERT INTO `medication` (`Medication_ID`, `Medication_Name`, `Medication_Price`, `Medication_Expire`) VALUES
(1, 'Adderall', '200.00', '2030-02-20'),
(2, 'Finasteride', '700.00', '2028-12-10'),
(3, 'Viagra', '300.00', '2035-05-25'),
(4, 'Azithromycin', '400.00', '2040-04-12'),
(5, 'Codeine', '200.00', '2032-07-20');

-- --------------------------------------------------------

--
-- Table structure for table `patient`
--

DROP TABLE IF EXISTS `patient`;
CREATE TABLE IF NOT EXISTS `patient` (
  `Patient_ID` int(11) NOT NULL AUTO_INCREMENT,
  `Patient_DateVisted` date NOT NULL,
  `Receptionist_ID` int(20) NOT NULL,
  PRIMARY KEY (`Patient_ID`),
  KEY `Receptionist_ID` (`Receptionist_ID`)
) ENGINE=MyISAM AUTO_INCREMENT=17 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `patient`
--

INSERT INTO `patient` (`Patient_ID`, `Patient_DateVisted`, `Receptionist_ID`) VALUES
(6, '2018-02-13', 11),
(7, '2020-06-15', 12),
(8, '2019-11-29', 13),
(9, '2020-03-27', 14),
(10, '2018-04-21', 15);

-- --------------------------------------------------------

--
-- Table structure for table `person`
--

DROP TABLE IF EXISTS `person`;
CREATE TABLE IF NOT EXISTS `person` (
  `Person_ID` int(20) NOT NULL AUTO_INCREMENT,
  `Person_FName` varchar(50) NOT NULL,
  `Person_LName` varchar(50) NOT NULL,
  `Person_DOB` date NOT NULL,
  `Person_Street` varchar(50) NOT NULL,
  `Person_City` varchar(50) NOT NULL,
  `Person_State` varchar(50) NOT NULL,
  `Person_Zip` varchar(5) NOT NULL,
  `Person_Phone` varchar(20) NOT NULL,
  PRIMARY KEY (`Person_ID`)
) ENGINE=MyISAM AUTO_INCREMENT=21 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `person`
--

INSERT INTO `person` (`Person_ID`, `Person_FName`, `Person_LName`, `Person_DOB`, `Person_Street`, `Person_City`, `Person_State`, `Person_Zip`, `Person_Phone`) VALUES
(1, 'John', 'Doe', '1992-05-15', 'Bowling dr', 'Annandale', 'PA', '51684', '703-452-8138'),
(2, 'Kylie', 'Anders', '1994-08-19', 'Davis st', 'Sterling', 'VA', '20165', '703-486-5746'),
(3, 'James', 'Brown', '1984-06-14', 'Signal ct', 'Chantilly', 'NY', '19345', '851-452-7295'),
(4, 'Jack', 'Meoff', '1969-04-20', 'Ligma st', 'Ashburn', 'VA', '80085', '571-5821-2496'),
(5, 'Annitta', 'Levin', '1997-04-05', 'Cosmic st', 'Dansvile', 'GA', '40245', '854-204-6851'),
(6, 'Mike', 'Kunt', '1989-05-26', 'Sona dr', 'Gainesville', 'CA', '60452', '589-516-2015'),
(7, 'Young', 'Sosa', '2012-12-12', 'Cash av', 'Shootaville', 'GA', '52046', '517-254-2018'),
(8, 'Derik', 'FIsher', '1981-05-22', 'Draco rd', 'Centerville', 'IL', '52048', '504-592-5027'),
(9, 'Savana', 'Lezio', '2005-01-24', 'Jenkins st', 'Berryville', 'NY', '70562', '578-520-5862'),
(10, 'Bob', 'Bizzle', '2002-08-21', 'Logington ln', 'Gettysburg', 'VA', '21085', '571-504-5686'),
(11, 'Jeff', 'Benitez', '1990-09-12', 'Feiliz dr', 'Montgomery', 'VA', '20598', '703-647-0826'),
(12, 'Nike ', 'Dilburg', '1984-06-19', 'Haris st', 'Nashville', 'PA', '56272', '587-065-5029'),
(13, 'George', 'Lontill', '1985-04-12', 'Binington dr', 'Brooklyn', 'NY', '45682', '456-852-1594'),
(14, 'Joe', 'Mama', '1978-12-05', 'Senet dr', 'Harrington', 'NY', '45201', '854-2545-5021'),
(15, 'Giuseppe', 'Gozollo', '2000-03-15', 'OX rd', 'Kenneyville', 'TN', '51062', '512-204-5024');

--
-- Triggers `person`
--
DROP TRIGGER IF EXISTS `update_EmployeeID`;
DELIMITER $$
CREATE TRIGGER `update_EmployeeID` AFTER UPDATE ON `person` FOR EACH ROW #When Person_ID is changed in the person table, it will update the Employee_ID in the employee table.
#This trigger helps update the sub entity tables when its parent table is updated.

BEGIN   
UPDATE employee SET employee.Employee_ID = NEW.Person_ID
WHERE employee.Employee_ID = OLD.Person_ID;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `update_PatientID`;
DELIMITER $$
CREATE TRIGGER `update_PatientID` AFTER UPDATE ON `person` FOR EACH ROW BEGIN   
UPDATE patient SET patient.Patient_ID = NEW.Person_ID                       
WHERE patient.Patient_ID = OLD.Person_ID;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `prescription`
--

DROP TABLE IF EXISTS `prescription`;
CREATE TABLE IF NOT EXISTS `prescription` (
  `Doctor_ID` int(11) NOT NULL,
  `Patient_ID` int(11) NOT NULL,
  `Medication_ID` int(11) NOT NULL,
  `Prescription_Date` date NOT NULL,
  PRIMARY KEY (`Doctor_ID`,`Patient_ID`,`Medication_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `prescription`
--

INSERT INTO `prescription` (`Doctor_ID`, `Patient_ID`, `Medication_ID`, `Prescription_Date`) VALUES
(1, 6, 1, '2017-12-05'),
(2, 7, 2, '2019-04-12'),
(3, 8, 3, '2019-07-02'),
(4, 9, 4, '2020-05-06'),
(5, 10, 5, '2018-09-21');

-- --------------------------------------------------------

--
-- Table structure for table `receptionist`
--

DROP TABLE IF EXISTS `receptionist`;
CREATE TABLE IF NOT EXISTS `receptionist` (
  `Receptionist_ID` int(20) NOT NULL AUTO_INCREMENT,
  `Receptionist_Rank` varchar(50) NOT NULL,
  PRIMARY KEY (`Receptionist_ID`)
) ENGINE=MyISAM AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `receptionist`
--

INSERT INTO `receptionist` (`Receptionist_ID`, `Receptionist_Rank`) VALUES
(11, 'Senior'),
(12, 'Senior'),
(13, 'Senior'),
(14, 'Entry'),
(15, 'Entry');

-- --------------------------------------------------------

--
-- Table structure for table `record`
--

DROP TABLE IF EXISTS `record`;
CREATE TABLE IF NOT EXISTS `record` (
  `Record_ID` int(11) NOT NULL AUTO_INCREMENT,
  `Record_Diagnos` varchar(50) NOT NULL,
  `Record_Bloodtype` varchar(5) NOT NULL,
  `Record_Allergy` varchar(50) NOT NULL,
  `Doctor_ID` int(11) NOT NULL,
  `Receptionist_ID` int(11) NOT NULL,
  `Patient_ID` int(11) NOT NULL,
  PRIMARY KEY (`Record_ID`),
  KEY `Doctor_ID` (`Doctor_ID`),
  KEY `Receptionist_ID` (`Receptionist_ID`),
  KEY `Patient_ID` (`Patient_ID`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `record`
--

INSERT INTO `record` (`Record_ID`, `Record_Diagnos`, `Record_Bloodtype`, `Record_Allergy`, `Doctor_ID`, `Receptionist_ID`, `Patient_ID`) VALUES
(1, 'Bronkitis', 'A', 'None', 1, 11, 6),
(2, 'Chlamydia', 'O-', 'None', 2, 12, 7),
(3, 'Hemorrhoids', 'AB', 'Peanut', 3, 13, 8),
(4, 'Mononucleosis', 'B+', 'Shellfish', 4, 14, 9),
(5, 'Covid-19', 'A-', 'None', 5, 15, 10);

-- --------------------------------------------------------

--
-- Table structure for table `treatment`
--

DROP TABLE IF EXISTS `treatment`;
CREATE TABLE IF NOT EXISTS `treatment` (
  `Doctor_ID` int(11) NOT NULL,
  `Patient_ID` int(11) NOT NULL,
  `Treatment_Date` date NOT NULL,
  PRIMARY KEY (`Doctor_ID`,`Patient_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `treatment`
--

INSERT INTO `treatment` (`Doctor_ID`, `Patient_ID`, `Treatment_Date`) VALUES
(1, 6, '2018-02-14'),
(2, 7, '2020-06-15'),
(3, 8, '2019-12-01'),
(4, 9, '2020-03-27'),
(5, 10, '2018-04-22'),
(1, 7, '2020-09-20'),
(2, 6, '2019-05-16'),
(3, 9, '2020-02-13');
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
