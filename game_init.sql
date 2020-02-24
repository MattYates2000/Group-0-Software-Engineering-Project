DROP SCHEMA IF EXISTS GAME_DATABASE;
CREATE SCHEMA GAME_DATABASE;
USE GAME_DATABASE;

CREATE TABLE IF NOT EXISTS Tutor(
`tutorId` INT AUTO_INCREMENT NOT NULL,
`title` VARCHAR(4) NOT NULL,
`fName` VARCHAR(50) NOT NULL,
`lName` VARCHAR(50) NOT NULL,
PRIMARY KEY (`tutorId`)
);

CREATE TABLE IF NOT EXISTS Paths(
`pathId` INT AUTO_INCREMENT NOT NULL,
`noOfBuildings` INT NOT NULL,
PRIMARY KEY (`pathId`)
);

CREATE TABLE IF NOT EXISTS Team(
`teamId` INT AUTO_INCREMENT NOT NULL,
`teamName` VARCHAR(50) NOT NULL,
`lastLocation` VARCHAR(50),
`tutorId` INT NOT NULL,
`pathId`INT NOT NULL,
PRIMARY KEY (`teamId`),
FOREIGN KEY (`tutorId`) REFERENCES Tutor(`tutorId`),
FOREIGN KEY (`pathId`) REFERENCES Paths(`pathId`)
);

CREATE TABLE IF NOT EXISTS Users(
`userId` INT AUTO_INCREMENT NOT NULL,
`fName` VARCHAR(50) NOT NULL,
`lName` VARCHAR(50) NOT NULL,
`emailAddress` VARCHAR(255) NOT NULL,
`username` VARCHAR(50) NOT NULL,
`password` VARCHAR(50) NOT NULL,
`tutorId` INT NOT NULL,
`teamId` INT NOT NULL,
PRIMARY KEY (`userID`),
FOREIGN KEY (`tutorId`) REFERENCES Tutor(`tutorId`),
FOREIGN KEY (`teamId`) REFERENCES Team(`teamId`),
UNIQUE (`fName`, `lName`, `emailAddress`)
);

CREATE TABLE IF NOT EXISTS Building(
`buildingId` INT AUTO_INCREMENT NOT NULL,
`buildingName` VARCHAR(100) NOT NULL,
`verificationCode` VARCHAR(100) NOT NULL,
PRIMARY KEY (`buildingId`)
);

CREATE TABLE IF NOT EXISTS Task(
`taskId` INT AUTO_INCREMENT NOT NULL,
`points` INT NOT NULL,
`description` VARCHAR(255) NOT NULL,
`buildingId` INT NOT NULL,
`required` TINYINT NOT NULL,
PRIMARY KEY (`taskId`),
FOREIGN KEY (`buildingId`) REFERENCES Building(`buildingId`)
);

CREATE TABLE IF NOT EXISTS Clue(
`clueLevel` INT AUTO_INCREMENT NOT NULL,
`description` VARCHAR(255) NOT NULL,
`pointsDeducted` INT NOT NULL,
PRIMARY KEY (`clueLevel`)
);

CREATE TABLE IF NOT EXISTS Score(
`scoreId` INT AUTO_INCREMENT NOT NULL,
`clueLevel` INT DEFAULT NULL,
`taskId` INT NOT NULL,
`teamId` INT NOT NULL,
FOREIGN KEY (`clueLevel`) REFERENCES Clue(`clueLevel`) ON DELETE SET NULL,
FOREIGN KEY (`taskId`) REFERENCES Task(`taskId`),
FOREIGN KEY (`teamId`) REFERENCES Team(`teamId`),
PRIMARY KEY (`scoreId`)
);

-- RELATIONSHIP ATTRICBUTES --
CREATE TABLE IF NOT EXISTS VisitBuilding(
`buildingId` INT NOT NULL,
`teamId` INT NOT NULL,
`inputVerification` VARCHAR(100) NOT NULL,
`time` DATETIME NOT NULL,
PRIMARY KEY(`buildingId`, `teamId`),
FOREIGN KEY (`buildingId`) REFERENCES Building(`buildingId`),
FOREIGN KEY (`teamId`) REFERENCES Team(`teamId`)
);

CREATE TABLE IF NOT EXISTS Route(
`pathId` INT NOT NULL,
`buildingId` INT NOT NULL,
`stopNo` INT NOT NULL,
PRIMARY KEY(`buildingId`, `pathId`,`stopNo`),
FOREIGN KEY (`buildingId`) REFERENCES Building(`buildingId`),
FOREIGN KEY (`pathId`) REFERENCES Paths(`pathId`)
);

-- CREATING VIEWS --

-- LEADERBORD --

CREATE OR REPLACE VIEW leaderboard AS

SELECT DISTINCT teamName, sum(totalPoints) AS score FROM
(SELECT teams.teamName, teams.pointsDeducted, tasks.points, (SELECT tasks.points - teams.pointsDeducted) AS totalPoints FROM 
(SELECT clues.pointsDeducted, clues.taskId, t.teamName FROM
	(SELECT c.clueLevel,c.pointsDeducted, s.taskId, s.teamId FROM
		(SELECT cl.clueLevel, cl.pointsDeducted FROM Clue cl) AS c
			JOIN
		(SELECT sc.taskId, sc.teamId, sc.clueLevel FROM Score sc) AS s
			ON c.clueLevel=s.clueLevel) AS clues
				JOIN
			(SELECT tm.teamId, tm.teamName FROM Team tm) AS t
				ON t.teamId=clues.teamId) AS teams
					JOIN
				(SELECT ts.taskId, ts.points FROM Task ts) AS tasks
                ON tasks.taskId=teams.taskId) AS score
GROUP BY teamName
ORDER BY score DESC;

-- ROUTES --

CREATE OR REPLACE VIEW Routes AS

SELECT r.pathId, b.buildingName, r.stopNo FROM
	(SELECT * FROM Route) AS r
		JOIN
	(SELECT bl.buildingId, bl.buildingName FROM Building bl) AS b
	ON b.buildingId=r.buildingId;
    
-- FULL TASKS AND DESCRIPTIONS --

CREATE OR REPLACE VIEW TaskDescriptions AS

SELECT tasks. description, tasks.points, buildings.buildingName, tasks.required  FROM 
	(SELECT t.taskId, t.points, t.description, t.buildingId, t.required FROM Task t) AS tasks
		JOIN
	(SELECT b.buildingId, b.buildingName FROM Building b) AS buildings
	ON buildings.buildingId=tasks.buildingId;

-- INSERTING DATA --

INSERT INTO Tutor VALUES
(NULL, 'Dr', 'Matthew', 'Collison'),
(NULL, 'Prof', 'Jonathon', 'Fieldsend'),
(NULL, 'Prof', 'Ronaldo', 'Menezes'),
(NULL, 'Dr', 'David', 'Wakeling');

INSERT INTO Paths VALUES
(NULL, 6),
(NULL, 6),
(NULL, 6),
(NULL, 6);

INSERT INTO Team VALUES
(NULL, 'Name1', NULL, 1, 1),
(NULL, 'Name2', NULL, 2, 2),
(NULL, 'Name3', NULL, 3, 3),
(NULL, 'Name4', NULL, 4, 4);

INSERT INTO Users VALUES
(NULL, 'Name1', 'Surname1', 'email1', 'username1', 'password1', 1, 1),
(NULL, 'Name2', 'Surname2', 'email2', 'username2', 'password2', 1, 1),
(NULL, 'Name3', 'Surname3', 'email3', 'username3', 'password3', 2, 2),
(NULL, 'Name4', 'Surname4', 'email4', 'username4', 'password4', 3, 3);

INSERT INTO Building VALUES
(NULL, 'Devonshire House', 'code1'),
(NULL, 'Queens', 'code2'),
(NULL, 'Harrison', 'code3'),
(NULL, 'Innovation Centre', 'code4'),
(NULL, 'Streatham Court', 'code5'),
(NULL, 'Forum', 'code6');

INSERT INTO Task VALUES
(NULL, 0, 'Grab a seat in The Loft', 1, 1),
(NULL, 0, 'Find the hot water point in DH2', 1, 1),
(NULL, 0, 'Locate the drama room', 1, 0),
(NULL, 0, 'Find the Pieminister truck', 1, 0),
(NULL, 0, 'Order curly fries at The Ram', 1, 0),
(NULL, 0, 'Locate LT2', 2, 1),
(NULL, 0, 'Buy a coffee at Costa', 2, 0),
(NULL, 0, 'Find a place to study', 2, 0),
(NULL, 0, 'Visit the Harrison Info Point', 3, 1),
(NULL, 0, 'Find the microwave and hot water point', 3, 1),
(NULL, 0, 'Buy a pasty at cafe', 3, 0),
(NULL, 0, 'Visit the Lovelace and Babbage rooms', 4, 1),
(NULL, 0, 'Login to a Linux machine', 4, 0),
(NULL, 0, 'Visir Ronaldo Menezes office', 4, 1),
(NULL, 0, 'Visit the fountain', 5, 1),
(NULL, 0, 'Find a place to study', 5, 0),
(NULL, 0, 'Locate the SID desk', 6, 1),
(NULL, 0, 'Checkout a computer science book from the library', 6, 1),
(NULL, 0, 'Find the cheapest coffee', 6, 0),
(NULL, 0, 'Visit the Study Zone', 6, 0);

INSERT INTO Clue VALUES
(NULL, 'clue1', 10),
(NULL, 'clue2', 20),
(NULL, 'clue3', 30);

INSERT INTO Score VALUES
(NULL, 1, 1, 1),
(NULL, 1, 1, 2),
(NULL, 2, 2, 1),
(NULL, 1, 2, 2);

INSERT INTO VisitBuilding VALUES
(1, 1, '123456789', '2019-09-25 11:23:10'),
(1, 2, '123456789', '2019-09-25 11:25:10'),
(2, 1, '123456789', '2019-09-25 12:23:10');

INSERT INTO Route VALUES
(1,6,1),
(1,1,2),
(1,2,3),
(1,3,4),
(1,4,5),
(1,5,6),
-- route 2
(2,6,1),
(2,5,2),
(2,4,3),
(2,3,4),
(2,2,5),
(2,1,6),
-- route 3
(3,6,1),
(3,5,2),
(3,2,3),
(3,1,4),
(3,3,5),
(3,4,6),
-- route 4
(4,6,1),
(4,2,2),
(4,5,3),
(4,4,4),
(4,3,5),
(4,2,6);








