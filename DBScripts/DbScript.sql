USE [master]
GO
/****** Object:  Database [ParkingLotManagement]    Script Date: 9/3/2023 11:43:03 AM ******/
CREATE DATABASE [ParkingLotManagement]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'ParkingLotManagement', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\ParkingLotManagement.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'ParkingLotManagement_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\ParkingLotManagement_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [ParkingLotManagement] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [ParkingLotManagement].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [ParkingLotManagement] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [ParkingLotManagement] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [ParkingLotManagement] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [ParkingLotManagement] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [ParkingLotManagement] SET ARITHABORT OFF 
GO
ALTER DATABASE [ParkingLotManagement] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [ParkingLotManagement] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [ParkingLotManagement] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [ParkingLotManagement] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [ParkingLotManagement] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [ParkingLotManagement] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [ParkingLotManagement] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [ParkingLotManagement] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [ParkingLotManagement] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [ParkingLotManagement] SET  ENABLE_BROKER 
GO
ALTER DATABASE [ParkingLotManagement] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [ParkingLotManagement] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [ParkingLotManagement] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [ParkingLotManagement] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [ParkingLotManagement] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [ParkingLotManagement] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [ParkingLotManagement] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [ParkingLotManagement] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [ParkingLotManagement] SET  MULTI_USER 
GO
ALTER DATABASE [ParkingLotManagement] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [ParkingLotManagement] SET DB_CHAINING OFF 
GO
ALTER DATABASE [ParkingLotManagement] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [ParkingLotManagement] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [ParkingLotManagement] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [ParkingLotManagement] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [ParkingLotManagement] SET QUERY_STORE = OFF
GO
USE [ParkingLotManagement]
GO
/****** Object:  User [saikodari]    Script Date: 9/3/2023 11:43:04 AM ******/
CREATE USER [saikodari] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  Table [dbo].[ParkedCar]    Script Date: 9/3/2023 11:43:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ParkedCar](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TagNumber] [nvarchar](50) NOT NULL,
	[EntryTime] [datetime] NULL,
	[ExitTime] [datetime] NULL,
	[Status] [nvarchar](20) NULL,
	[SpotId] [int] NULL,
	[Amount] [decimal](10, 2) NULL,
 CONSTRAINT [PK__ParkedCa__3214EC07EB55BF95] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ParkingSpot]    Script Date: 9/3/2023 11:43:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ParkingSpot](
	[SpotId] [int] NOT NULL,
	[SpotNumber] [varchar](50) NOT NULL,
	[IsOccupied] [bit] NOT NULL,
 CONSTRAINT [PK__ParkingS__61645F8709D572C2] PRIMARY KEY CLUSTERED 
(
	[SpotId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ParkedCar]  WITH CHECK ADD FOREIGN KEY([SpotId])
REFERENCES [dbo].[ParkingSpot] ([SpotId])
GO
/****** Object:  StoredProcedure [dbo].[CheckInCar]    Script Date: 9/3/2023 11:43:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CheckInCar]
    @TagNumber NVARCHAR(255),
    @EntryTime DATETIME,
    @Status INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SpotId INT;

    SELECT TOP 1 @SpotId = SpotId
    FROM ParkingSpot
    WHERE IsOccupied = 0
    ORDER BY SpotNumber ASC;

    IF @SpotId IS NOT NULL
    BEGIN
        UPDATE ParkingSpot
        SET IsOccupied = 1
        WHERE SpotId = @SpotId;

        INSERT INTO ParkedCar (TagNumber, EntryTime, ExitTime, Status, SpotId)
        VALUES (@TagNumber, @EntryTime, NULL, @Status, @SpotId);

        SELECT @SpotId AS AssignedSpotId;
    END
    ELSE
    BEGIN
       THROW 51000, 'No available parking spots.', 1;
    END
END;


GO
/****** Object:  StoredProcedure [dbo].[CountParkedCarsByTagNumber]    Script Date: 9/3/2023 11:43:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CountParkedCarsByTagNumber]
    @TagNumber NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT COUNT(*) AS CarCount
    FROM ParkedCar
    WHERE TagNumber = @TagNumber AND [Status] = 1
END;
GO
/****** Object:  StoredProcedure [dbo].[GetNextAvailableParkingSpot]    Script Date: 9/3/2023 11:43:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetNextAvailableParkingSpot]
AS
BEGIN
    SELECT TOP 1 SpotId
    FROM ParkingSpot
    WHERE IsOccupied = 0
    ORDER BY SpotNumber ASC;
END
GO
/****** Object:  StoredProcedure [dbo].[GetParkedCar]    Script Date: 9/3/2023 11:43:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetParkedCar]
    @TagNumber NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
	Id, 
	TagNumber,
	EntryTime, 
	ExitTime, 	
	SpotId
    FROM ParkedCar
    WHERE TagNumber = @TagNumber AND [Status] = 1
END;
GO
/****** Object:  StoredProcedure [dbo].[GetParkedCars]    Script Date: 9/3/2023 11:43:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetParkedCars]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Id,
        TagNumber,
        EntryTime,
        GETDATE() AS CurrentTime, -- Get the current time
        --DATEDIFF(HOUR, EntryTime, GETDATE()) AS ElapsedHours,
        DATEDIFF(MINUTE, EntryTime, GETDATE()) AS ElapsedMinutes,
		CASE
        WHEN DATEDIFF(MINUTE, EntryTime, GETDATE()) < 60 THEN 1
        ELSE CONVERT(INT, DATEDIFF(MINUTE, EntryTime, GETDATE()) / 60)
    END AS ElapsedHours,
        Status,
        SpotId
    FROM
        ParkedCar
    WHERE
        [Status] = 1;
END;
GO
/****** Object:  StoredProcedure [dbo].[GetParkingLotStatistics]    Script Date: 9/3/2023 11:43:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetParkingLotStatistics]
AS
BEGIN
    DECLARE @AvailableSpots INT;
    DECLARE @TodayRevenue DECIMAL(10, 2);
    DECLARE @AvgCarsPerDay INT;
    DECLARE @AvgRevenuePerDay DECIMAL(10, 2);

    SELECT @AvailableSpots = COUNT(*) 
    FROM ParkingSpot 
    WHERE IsOccupied = 0;

    SELECT @TodayRevenue = SUM(PC.Amount)
    FROM ParkedCar AS PC
    INNER JOIN ParkingSpot AS PS ON PC.SpotId = PS.SpotId
    WHERE PC.ExitTime IS NOT NULL
    AND CAST(PC.EntryTime AS DATE) = CAST(GETDATE() AS DATE);

    SELECT @AvgCarsPerDay = COUNT(*), @AvgRevenuePerDay = AVG(PC.Amount)
    FROM ParkedCar AS PC
    WHERE PC.ExitTime IS NOT NULL
    AND PC.EntryTime >= DATEADD(DAY, -29, GETDATE());

    SELECT 
        @AvailableSpots AS AvailableSpots,
        @TodayRevenue AS TodayRevenue, 
        @AvgCarsPerDay AS AvgCarsPerDay, 
        @AvgRevenuePerDay AS AvgRevenuePerDay;
END
GO
/****** Object:  StoredProcedure [dbo].[GetUnoccupiedParkingSpotCount]    Script Date: 9/3/2023 11:43:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetUnoccupiedParkingSpotCount]
AS
BEGIN
    SELECT COUNT(*) AS AvailableSpotsCount
    FROM ParkingSpot
    WHERE IsOccupied = 0;
END;
GO
/****** Object:  StoredProcedure [dbo].[InsertCheckInData]    Script Date: 9/3/2023 11:43:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertCheckInData]
    @TagNumber VARCHAR(20),
    @EntryTime DATETIME,
    @Status INT,
    @SpotId INT
AS
BEGIN
    INSERT INTO ParkedCar (TagNumber, EntryTime, Status, SpotId)
    VALUES (@TagNumber, @EntryTime, @Status, @SpotId)
END
GO
/****** Object:  StoredProcedure [dbo].[InsertCheckOutData]    Script Date: 9/3/2023 11:43:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertCheckOutData]
    @TagNumber VARCHAR(20),
    @ExitTime DATETIME,
    @Status INT
    --@SpotId INT
AS
BEGIN
    UPDATE ParkedCar
    SET ExitTime = @ExitTime, Status = @Status
    WHERE TagNumber = @TagNumber
END
GO
/****** Object:  StoredProcedure [dbo].[SP_CheckOutCar]    Script Date: 9/3/2023 11:43:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_CheckOutCar]
    @TagNumber NVARCHAR(255),
    @ExitTime DATETIME,
    @Amount DECIMAL(18, 2)  
AS
BEGIN
    DECLARE @SpotId INT
    SELECT @SpotId = SpotId
    FROM ParkedCar
    WHERE TagNumber = @TagNumber AND Status = 1

    IF @SpotId IS NOT NULL
    BEGIN
        UPDATE ParkedCar
        SET ExitTime = @ExitTime, Status = 0, Amount = @Amount 
        WHERE TagNumber = @TagNumber AND Status = 1

        UPDATE ParkingSpot
        SET IsOccupied = 0
        WHERE SpotId = @SpotId

        SELECT 1 AS Status
    END
    ELSE
    BEGIN
        SELECT 0 AS Status
    END
END
GO
/****** Object:  StoredProcedure [dbo].[SP_GetParkingLotSpotsStatistics]    Script Date: 9/3/2023 11:43:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_GetParkingLotSpotsStatistics]
AS
BEGIN
    DECLARE @SpotsTaken INT;
    DECLARE @AvailableSpots INT;

    SELECT @SpotsTaken = COUNT(*)
    FROM ParkingSpot
    WHERE IsOccupied = 1;

    SELECT @AvailableSpots = COUNT(*)
    FROM ParkingSpot
    WHERE IsOccupied = 0;

    SELECT @SpotsTaken AS SpotsTaken, @AvailableSpots AS AvailableSpots;
END
GO
/****** Object:  StoredProcedure [dbo].[SP_GetParkingLotStatistics]    Script Date: 9/3/2023 11:43:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_GetParkingLotStatistics]
AS
BEGIN
    DECLARE @AvailableSpots INT;
    DECLARE @TodayRevenue DECIMAL(10, 2);
    DECLARE @AvgCarsPerDay INT;
    DECLARE @AvgRevenuePerDay DECIMAL(10, 2);

    SELECT @AvailableSpots = COUNT(*) 
    FROM ParkingSpot 
    WHERE IsOccupied = 0;

    SELECT @TodayRevenue = SUM(PC.Amount)
    FROM ParkedCar AS PC
    INNER JOIN ParkingSpot AS PS ON PC.SpotId = PS.SpotId
    WHERE PC.ExitTime IS NOT NULL
    AND CAST(PC.EntryTime AS DATE) = CAST(GETDATE() AS DATE);

    SELECT @AvgCarsPerDay = COUNT(*), @AvgRevenuePerDay = AVG(PC.Amount)
    FROM ParkedCar AS PC
    WHERE PC.ExitTime IS NOT NULL
    AND PC.EntryTime >= DATEADD(DAY, -29, GETDATE());

    SELECT 
        @AvailableSpots AS AvailableSpots,
        @TodayRevenue AS TodayRevenue, 
        @AvgCarsPerDay AS AvgCarsPerDay, 
        @AvgRevenuePerDay AS AvgRevenuePerDay;
END
GO
/****** Object:  StoredProcedure [dbo].[UpdateParkingSpotOccupancy]    Script Date: 9/3/2023 11:43:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateParkingSpotOccupancy]
    @SpotId INT,
    @IsOccupied BIT
AS
BEGIN
    UPDATE ParkingSpot
    SET IsOccupied = @IsOccupied
    WHERE SpotId = @SpotId;
END
GO
USE [master]
GO
ALTER DATABASE [ParkingLotManagement] SET  READ_WRITE 
GO
