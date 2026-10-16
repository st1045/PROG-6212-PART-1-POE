IF DB_ID('RaceDayDB') IS NOT NULL
BEGIN
    ALTER DATABASE RaceDayDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RaceDayDB;
END;
GO

CREATE DATABASE RaceDayDB;
GO
USE RaceDayDB;
GO

CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(150) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    PhoneNumber NVARCHAR(30) NULL,
    Role NVARCHAR(20) NOT NULL,
    ProfilePictureUrl NVARCHAR(500) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT CK_Users_Role CHECK (Role IN ('Organiser','Participant'))
);
GO

CREATE TABLE Events (
    EventId INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserId INT NOT NULL,
    Name NVARCHAR(150) NOT NULL,
    Description NVARCHAR(1000) NOT NULL,
    EventDate DATE NOT NULL,
    Location NVARCHAR(200) NOT NULL,
    DistanceKm DECIMAL(6,2) NOT NULL,
    EventType NVARCHAR(20) NOT NULL,
    BannerImageUrl NVARCHAR(500) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Events_Organiser FOREIGN KEY (OrganiserId) REFERENCES Users(UserId),
    CONSTRAINT CK_Events_Distance CHECK (DistanceKm > 0),
    CONSTRAINT CK_Events_Type CHECK (EventType IN ('Run','Walk','Cycle'))
);
GO

CREATE TABLE Categories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    EventId INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(300) NULL,
    CONSTRAINT FK_Categories_Event FOREIGN KEY (EventId) REFERENCES Events(EventId) ON DELETE CASCADE,
    CONSTRAINT UQ_Categories_Event_Name UNIQUE (EventId, Name)
);
GO

CREATE TABLE Enrolments (
    EnrolmentId INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantId INT NOT NULL,
    EventId INT NOT NULL,
    CategoryId INT NOT NULL,
    EnrolmentDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Status NVARCHAR(20) NOT NULL DEFAULT 'Confirmed',
    CONSTRAINT FK_Enrolments_Participant FOREIGN KEY (ParticipantId) REFERENCES Users(UserId),
    CONSTRAINT FK_Enrolments_Event FOREIGN KEY (EventId) REFERENCES Events(EventId),
    CONSTRAINT FK_Enrolments_Category FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId),
    CONSTRAINT UQ_Enrolments_Participant_Event UNIQUE (ParticipantId, EventId),
    CONSTRAINT CK_Enrolments_Status CHECK (Status IN ('Pending','Confirmed','Cancelled'))
);
GO

CREATE TABLE Results (
    ResultId INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentId INT NOT NULL UNIQUE,
    FinishTime TIME(0) NULL,
    FinishingPosition INT NULL,
    Published BIT NOT NULL DEFAULT 0,
    RecordedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Results_Enrolment FOREIGN KEY (EnrolmentId) REFERENCES Enrolments(EnrolmentId) ON DELETE CASCADE,
    CONSTRAINT CK_Results_Position CHECK (FinishingPosition IS NULL OR FinishingPosition > 0)
);
GO

-- Minimum required seed data: 2 organisers, 2 participants, 3 events,
-- categories for each event, and sample enrolments.
INSERT INTO Users (FirstName, LastName, Email, PasswordHash, PhoneNumber, Role)
VALUES
('Thabo','Mokoena','thabo.organiser@raceday.co.za','HASH_PLACEHOLDER_1','0825550101','Organiser'),
('Naledi','Dlamini','naledi.organiser@raceday.co.za','HASH_PLACEHOLDER_2','0825550102','Organiser'),
('Sipho','Nkosi','sipho.participant@raceday.co.za','HASH_PLACEHOLDER_3','0825550103','Participant'),
('Aisha','Naidoo','aisha.participant@raceday.co.za','HASH_PLACEHOLDER_4','0825550104','Participant');
GO

INSERT INTO Events
(OrganiserId, Name, Description, EventDate, Location, DistanceKm, EventType)
VALUES
(1,'Johannesburg City Run','A community road running event through central Johannesburg.','2026-10-18','Johannesburg, Gauteng',10.00,'Run'),
(1,'Soweto Community Walk','A family-friendly walking event supporting community participation.','2026-11-08','Soweto, Gauteng',5.00,'Walk'),
(2,'Cape Cycle Challenge','A road cycling event for recreational and competitive cyclists.','2026-12-06','Cape Town, Western Cape',42.00,'Cycle');
GO

INSERT INTO Categories (EventId, Name, Description)
VALUES
(1,'Under 20','Participants aged 19 and under.'),
(1,'Senior','Open senior category.'),
(1,'10km Open','Open 10 kilometre category.'),
(2,'5km Family','Family and recreational walkers.'),
(2,'Senior Walk','Senior walking category.'),
(3,'42km Open','Open road cycling category.'),
(3,'Veteran','Veteran cycling category.');
GO

INSERT INTO Enrolments (ParticipantId, EventId, CategoryId, Status)
VALUES
(3,1,3,'Confirmed'),
(4,1,2,'Confirmed'),
(3,2,4,'Confirmed'),
(4,3,6,'Pending');
GO

INSERT INTO Results (EnrolmentId, FinishTime, FinishingPosition, Published)
VALUES
(1,'00:52:34',47,1),
(2,'01:04:18',91,1);
GO

SELECT * FROM Users;
SELECT * FROM Events;
SELECT * FROM Categories;
SELECT * FROM Enrolments;
SELECT * FROM Results;
GO
