CREATE TABLE Persons (
    ID INT PRIMARY KEY,
    Name VARCHAR(20) NOT NULL,
    DOB VARCHAR(20) DEFAULT 'Unknown',
    Gender VARCHAR(1) CHECK(Gender = 'M' OR Gender = 'F')
);

-- Inserting each person part of the family
INSERT INTO Persons VALUES(1, 'Jason', '11/30/1996', 'M');
INSERT INTO Persons VALUES(2, 'Nancy', '12/01/1989', 'F');
INSERT INTO Persons VALUES(3, 'Alfredo', '03/03/1987', 'M');
INSERT INTO Persons VALUES(4, 'Raquel', '04/27/1961', 'F');
INSERT INTO Persons VALUES(5, 'Giselo', '05/07/1960', 'M');
INSERT INTO Persons VALUES(6, 'Evelyn', '08/16/2012', 'F');
INSERT INTO Persons VALUES(7, 'Julian', '11/29/2014', 'M');
INSERT INTO Persons VALUES(8, 'Chris', '12/02/1989', 'M');
INSERT INTO Persons VALUES(9, 'Irene', '02/16/1908', 'F');
INSERT INTO Persons VALUES(10, 'Hector', '6/28/1908', 'M');
INSERT INTO Persons VALUES(11, 'Bertha', '6/28/1943', 'F');
INSERT INTO Persons VALUES(12, 'Michael', '6/28/1943', 'M');
INSERT INTO Persons VALUES(13, 'Lisa', '8/15/1996', 'F');
INSERT INTO Persons VALUES(14, 'Oliver', '3/21/2021', 'M');
INSERT INTO Persons VALUES(15, 'Kim', '3/4/1987', 'F');

-- Dispalying all the content of the table Persons
SELECT * FROM Persons;
DROP TABLE Persons;

-- Creating the table for the child and each of their parents
CREATE TABLE Family (
    Child INT,
    Father INT,
    Mother INT,
    PRIMARY KEY (Child),
    FOREIGN KEY (Child) REFERENCES Persons(ID),
    FOREIGN KEY (Father) REFERENCES Persons(ID),
	FOREIGN KEY (Mother) REFERENCES Persons(ID)
 
);

-- Inserting every child to their parents from the table of Persons
INSERT INTO Family VALUES(1, 5, 4);
INSERT INTO Family VALUES(2, 5, 4);
INSERT INTO Family VALUES(3, 5, 4);
INSERT INTO Family VALUES(6, 8, 2);
INSERT INTO Family VALUES(7, 8, 2);
INSERT INTO Family VALUES(5, 10, 9);
INSERT INTO Family VALUES(4, 12, 11);
INSERT INTO Family VALUES(14, 1, 13);

-- Displaying all the contents of table Family
SELECT * FROM Family; 
DROP TABLE Family;
DROP PROCEDURE ChildrenOf;

CREATE TABLE GP (
    GrandChild INT, 
    GrandMother INT, 
    GrandFather INT, 
    FOREIGN KEY (Grandchild) REFERENCES Persons(ID),
    FOREIGN KEY (GrandMother) REFERENCES Persons(ID),
    FOREIGN KEY (GrandFather) REFERENCES Persons(ID)
);

INSERT INTO GP VALUES(6, 4, 5);
INSERT INTO GP VALUES(7, 4, 5);
INSERT INTO GP VALUES(1, 9, 10);
INSERT INTO GP VALUES(1, 11, 12);
INSERT INTO GP VALUES(2, 9, 10);
INSERT INTO GP VALUES(2, 11, 12);
INSERT INTO GP VALUES(3, 9, 10);
INSERT INTO GP VALUES(3, 11, 12);

SELECT * FROM GP;
DROP TABLE GP;
DROP PROCEDURE GrandOf;

CREATE TABLE brother (
	Brother INT,
    Person INT,
    FOREIGN KEY (Brother) REFERENCES Persons(ID),
    FOREIGN KEY (Person) REFERENCES Persons(ID)
);

INSERT INTO brother VALUES(1, 2);
INSERT INTO brother VALUES(1, 3);
INSERT INTO brother VALUES(3, 1);
INSERT INTO brother VALUES(3, 2);
INSERT INTO brother VALUES(7, 6);

SELECT * FROM brother;
DROP TABLE brother;

CREATE TABLE sister (
	Sister INT,
    Person INT,
    FOREIGN KEY (Sister) REFERENCES Persons(ID),
    FOREIGN KEY (Person) REFERENCES Persons(ID)
);

INSERT INTO sister VALUES(2, 1);
INSERT INTO sister VALUES(2, 3);
INSERT INTO sister VALUES(6, 7);

SELECT * FROM sister;
DROP TABLE sister;

CREATE TABLE bro_sis (
	Brother INT,
    Sister INT,
    FOREIGN KEY (Brother) REFERENCES Persons(ID),
    FOREIGN KEY (Sister) REFERENCES Persons(ID)
);

INSERT INTO bro_sis VALUES(1, 2);
INSERT INTO bro_sis VALUES(3, 2);
INSERT INTO bro_sis VALUES(7, 6);

SELECT * FROM bro_sis;
DROP TABLE bro_sis;

CREATE TABLE hus_wif (
	Husband INT,
    Wife INT,
    FOREIGN KEY (Husband) REFERENCES Persons(ID),
    FOREIGN KEY (Wife) REFERENCES Persons(ID)
);

INSERT INTO hus_wif VALUES(1, 13);
INSERT INTO hus_wif VALUES(8, 2);
INSERT INTO hus_wif VALUES(5, 4);
INSERT INTO hus_wif VALUES(10, 9);
INSERT INTO hus_wif VALUES(12, 11);
INSERT INTO hus_wif VALUES(3, 15);


SELECT * FROM hus_wif;
DROP TABLE hus_wif;

/*SELECT Persons.ID, Persons.Name FROM Persons
JOIN bro_sis ON Person.ID = bro_sis.sister
JOIN hus_wif ON Person.ID = hus_wif
FROM*/

CREATE TABLE sislaw (
	Sis_Inlaw INT,
    Person INT,
    FOREIGN KEY (Sis_Inlaw) REFERENCES Persons(ID),
    FOREIGN KEY (Person) REFERENCES Persons(ID)
);

SELECT * FROM sisLaw;
DROP TABLE sislaw;

DELIMITER //
CREATE PROCEDURE inlawOf(IN Person INT)
BEGIN
	SELECT Persons.ID, Persons.Name, Persons.Gender FROM sislaw
    JOIN Persons
    ON Persons.ID = sislaw.Sis_Inlaw
    WHERE sislaw.Person = (SELECT Persons.ID FROM Persons WHERE ID = Person);
END //
DELIMITER ;

CALL inlawOf(2);
DROP PROCEDURE inlawOf;

INSERT INTO sislaw(Sis_Inlaw, Person)
SELECT hus_wif.Wife, brother.Person FROM hus_wif
JOIN brother ON hus_wif.Husband = brother.Brother
WHERE hus_wif.Wife = 13 OR hus_wif.Wife = 15;

INSERT INTO sislaw(Sis_Inlaw, Person)
SELECT sister.Sister, hus_wif.Wife FROM hus_wif
JOIN sister ON hus_wif.Husband = sister.Person
WHERE hus_wif.Husband = 1 OR hus_wif.Husband = 3;

