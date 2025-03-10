USE [master]
GO
/****** Object:  Database [FHubDB]    Script Date: 11-11-2016 11:14:23 ******/
CREATE DATABASE [FHubDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'FHubDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\FHubDB.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'FHubDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\FHubDB_log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [FHubDB] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [FHubDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [FHubDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [FHubDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [FHubDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [FHubDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [FHubDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [FHubDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [FHubDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [FHubDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [FHubDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [FHubDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [FHubDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [FHubDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [FHubDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [FHubDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [FHubDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [FHubDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [FHubDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [FHubDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [FHubDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [FHubDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [FHubDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [FHubDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [FHubDB] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [FHubDB] SET  MULTI_USER 
GO
ALTER DATABASE [FHubDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [FHubDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [FHubDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [FHubDB] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [FHubDB] SET DELAYED_DURABILITY = DISABLED 
GO
USE [FHubDB]
GO
/****** Object:  UserDefinedFunction [dbo].[FunRetString]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FunRetString]
(    
      @Input NVARCHAR(MAX),
      @Character CHAR(1),
	  @TableName nvarchar(50)
)
RETURNS nvarchar(max)
AS
BEGIN
      DECLARE @StartIndex INT, @EndIndex INT
	  Declare @StringData nvarchar(max) = '' ;
 
	  If(@Input <> '')
	  Begin
		  SET @StartIndex = 1
		  IF SUBSTRING(@Input, LEN(@Input) - 1, LEN(@Input)) <> @Character
		  BEGIN
				SET @Input = @Input + @Character;
		  END

		  WHILE CHARINDEX(@Character, @Input) > 0
		  BEGIN
				SET @EndIndex = CHARINDEX(@Character, @Input)
			
				if(@TableName = 'Group')
					Select @StringData = @StringData + b.GroupName + ',' From GroupMas b Where b.GroupId = Cast(SUBSTRING(@Input, @StartIndex, @EndIndex - 1) as int) ;
				else if(@TableName = 'Contact')
					Select @StringData = @StringData + b.AUName + ',' From AppUsers b Where b.AUId = Cast(SUBSTRING(@Input, @StartIndex, @EndIndex - 1) as int) ;

				SET @Input = SUBSTRING(@Input, @EndIndex + 1, LEN(@Input))
		  END

		  Set @StringData  = SUBSTRING(@StringData ,1,Len(@StringData) - 1);
	  End

      RETURN @StringData ;
END


GO
/****** Object:  UserDefinedFunction [dbo].[SplitString]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[SplitString]
(    
      @Input NVARCHAR(MAX),
      @Character CHAR(1)
)
RETURNS @Output TABLE (
      Item NVARCHAR(1000)
)
AS
BEGIN
      DECLARE @StartIndex INT, @EndIndex INT
 
      SET @StartIndex = 1
      IF SUBSTRING(@Input, LEN(@Input) - 1, LEN(@Input)) <> @Character
      BEGIN
            SET @Input = @Input + @Character
      END
 
      WHILE CHARINDEX(@Character, @Input) > 0
      BEGIN
            SET @EndIndex = CHARINDEX(@Character, @Input)
           
            INSERT INTO @Output(Item)
            SELECT SUBSTRING(@Input, @StartIndex, @EndIndex - 1)
           
            SET @Input = SUBSTRING(@Input, @EndIndex + 1, LEN(@Input))
      END
 
      RETURN
END


GO
/****** Object:  Table [dbo].[AppLog]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RefAUId] [int] NOT NULL,
	[RefVendorId] [int] NULL,
	[LogType] [nvarchar](50) NOT NULL,
	[RefId] [int] NULL,
	[LogDesc] [nvarchar](1000) NULL,
	[InsUser] [int] NOT NULL,
	[InsDate] [datetime] NOT NULL,
	[InsTerminal] [nvarchar](60) NOT NULL,
	[UpdUser] [int] NULL,
	[UpdDate] [datetime] NULL,
	[UpdTerminal] [nvarchar](60) NULL,
 CONSTRAINT [PK_AppLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AppUsers]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppUsers](
	[AUId] [int] IDENTITY(1,1) NOT NULL,
	[AUName] [nvarchar](100) NOT NULL,
	[CompanyName] [nvarchar](50) NOT NULL,
	[Address] [nvarchar](100) NULL,
	[LandMark] [nvarchar](100) NULL,
	[Country] [nvarchar](50) NULL,
	[State] [nvarchar](50) NULL,
	[City] [nvarchar](50) NULL,
	[Pincode] [nvarchar](50) NULL,
	[ContactNo1] [nvarchar](50) NULL,
	[ContactNo2] [nvarchar](50) NULL,
	[MobileNo1] [nvarchar](50) NOT NULL,
	[MobileNo2] [nvarchar](50) NULL,
	[EmailId] [nvarchar](100) NOT NULL,
	[WebSite] [nvarchar](100) NULL,
	[GCMID] [nvarchar](200) NULL,
	[AppVersion] [numeric](5, 2) NULL,
	[DeviceID] [nvarchar](100) NULL,
	[DeviceOS] [nvarchar](50) NULL CONSTRAINT [DF_AppUsers_DeviceOS]  DEFAULT ('Android'),
	[IsActive] [bit] NULL CONSTRAINT [DF_AppUsers_IsActive]  DEFAULT ((1)),
	[IsNotify] [bit] NULL CONSTRAINT [DF_AppUsers_IsNotify]  DEFAULT ((1)),
	[DefaultView] [nvarchar](20) NULL CONSTRAINT [DF_AppUsers_DefaultView]  DEFAULT (N'ByCatalog'),
	[AppUserImg] [nvarchar](200) NULL,
	[RateUs] [int] NULL,
	[InsUser] [int] NOT NULL CONSTRAINT [DF_AppUsers_InsUser]  DEFAULT ((1)),
	[InsDate] [datetime] NOT NULL CONSTRAINT [DF_AppUsers_InsDate]  DEFAULT (getdate()),
	[InsTerminal] [nvarchar](30) NOT NULL CONSTRAINT [DF_AppUsers_InsTerminal]  DEFAULT (N'127.0.0.1'),
	[UpdUser] [int] NULL,
	[UpdDate] [datetime] NULL,
	[UpdTerminal] [nvarchar](30) NULL,
 CONSTRAINT [PK_AppUsers] PRIMARY KEY CLUSTERED 
(
	[AUId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetRoles]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetRoles](
	[Id] [nvarchar](128) NOT NULL,
	[Name] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_AspNetRoles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUserClaims]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserClaims](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ClaimType] [nvarchar](max) NULL,
	[ClaimValue] [nvarchar](max) NULL,
	[User_Id] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK_AspNetUserClaims] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUserLogins]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserLogins](
	[UserId] [nvarchar](128) NOT NULL,
	[UserProvider] [nvarchar](128) NOT NULL,
	[ProviderKey] [nvarchar](128) NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUserRoles]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserRoles](
	[UserId] [nvarchar](128) NULL,
	[RoleId] [nvarchar](128) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUsers]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUsers](
	[Id] [nvarchar](128) NOT NULL,
	[UserName] [nvarchar](max) NOT NULL,
	[PasswordHash] [nvarchar](max) NOT NULL,
	[SecurityStamp] [nvarchar](max) NULL,
	[Discriminator] [nvarchar](128) NULL,
 CONSTRAINT [PK_AspNetUsers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CatalogMas]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CatalogMas](
	[CatId] [int] IDENTITY(1,1) NOT NULL,
	[RefVendorId] [int] NOT NULL,
	[CatCode] [nvarchar](50) NOT NULL,
	[CatName] [nvarchar](100) NOT NULL,
	[CatImg] [nvarchar](200) NULL,
	[CatDescription] [nvarchar](500) NULL,
	[CatLaunchDate] [date] NULL,
	[IsFullset] [bit] NULL CONSTRAINT [DF_CatalogMas_IsFullset]  DEFAULT ((0)),
	[IsActive] [bit] NULL,
	[RefCatId] [int] NULL,
	[RefStoreId] [int] NULL,
	[InsUser] [int] NOT NULL,
	[InsDate] [datetime] NOT NULL,
	[InsTerminal] [nvarchar](60) NOT NULL,
	[UpdUser] [int] NULL,
	[UpdDate] [datetime] NULL,
	[UpdTerminal] [nvarchar](60) NULL,
 CONSTRAINT [PK_CatalogMas] PRIMARY KEY CLUSTERED 
(
	[CatId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CompanyProfile]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CompanyProfile](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CompanyName] [nvarchar](100) NOT NULL,
	[EmailId] [nvarchar](100) NULL,
	[Description] [nvarchar](max) NULL,
	[LogoImg] [nvarchar](50) NULL,
	[AppType] [nvarchar](50) NULL,
	[FolderPath] [nvarchar](200) NOT NULL,
	[WebSite] [nvarchar](50) NULL,
	[AboutUs] [nvarchar](max) NULL,
	[Vision] [nvarchar](max) NULL,
	[Mission] [nvarchar](max) NULL,
	[AppVersion] [numeric](5, 2) NULL,
	[InsUser] [int] NOT NULL,
	[InsDate] [datetime] NOT NULL,
	[InsTerminal] [nvarchar](50) NOT NULL,
	[UpdUser] [int] NULL,
	[UpdDate] [datetime] NULL,
	[UpdTerminal] [nvarchar](50) NULL,
 CONSTRAINT [PK_CompanyProfile] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DeleteLog]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeleteLog](
	[DLId] [int] IDENTITY(1,1) NOT NULL,
	[RefVendorId] [int] NOT NULL,
	[Flag] [nvarchar](10) NOT NULL,
	[RId] [int] NOT NULL,
	[InsUser] [int] NOT NULL,
	[InsDate] [datetime] NOT NULL,
	[InsTerminal] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_DeleteLog] PRIMARY KEY CLUSTERED 
(
	[DLId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EnquiryList]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnquiryList](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RefAUId] [int] NOT NULL,
	[RefVendorId] [int] NOT NULL,
	[RefProdId] [int] NULL,
	[RefCatId] [int] NULL,
	[Remark] [nvarchar](150) NULL,
	[Status] [nvarchar](1) NOT NULL,
	[RepRemark] [nvarchar](1000) NULL,
	[EnquiryDate] [datetime] NOT NULL,
	[EnquiryRepDate] [datetime] NULL,
	[ReadDateTime] [datetime] NULL,
	[RefRepAUId] [int] NULL,
 CONSTRAINT [PK_EnquiryList] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ErrLog]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ErrLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ErrDate] [datetime] NULL,
	[ErrCode] [nchar](30) NULL,
	[ErrMethod] [nvarchar](200) NULL,
	[ErrDesc] [nvarchar](max) NULL,
	[ErrInternal] [nvarchar](max) NULL,
 CONSTRAINT [PK_ErrLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[GroupContactList]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GroupContactList](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RefGroupId] [int] NOT NULL,
	[RefAUId] [int] NOT NULL,
	[InsUser] [int] NOT NULL,
	[InsDate] [date] NOT NULL,
	[InsTerminal] [nvarchar](60) NOT NULL,
	[UpdUser] [int] NULL,
	[UpdDate] [date] NULL,
	[UpdTerminal] [nvarchar](60) NULL,
 CONSTRAINT [PK_GroupContactList] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[GroupMas]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GroupMas](
	[GroupId] [int] IDENTITY(1,1) NOT NULL,
	[RefVendorId] [int] NOT NULL,
	[GroupName] [nvarchar](50) NOT NULL,
	[InsUser] [int] NOT NULL,
	[InsDate] [datetime] NOT NULL,
	[InsTerminal] [nvarchar](60) NOT NULL,
	[UpdUser] [int] NULL,
	[UpdDate] [datetime] NULL,
	[UpdTerminal] [nvarchar](50) NULL,
 CONSTRAINT [PK_ContactGroup] PRIMARY KEY CLUSTERED 
(
	[GroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MastersList]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MastersList](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[MasterName] [nvarchar](50) NOT NULL,
	[OrdNo] [numeric](5, 2) NULL,
	[IsSystem] [bit] NOT NULL CONSTRAINT [DF_MastersList_AllowFilter]  DEFAULT ((0)),
 CONSTRAINT [PK_MastersList] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MasterValue]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MasterValue](
	[RefMasterId] [int] NOT NULL,
	[RefVendorId] [int] NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ValueName] [nvarchar](50) NOT NULL,
	[ValueDesc] [nvarchar](200) NULL,
	[OrdNo] [numeric](5, 2) NULL CONSTRAINT [DF_MasterValue_OrdNo]  DEFAULT ((0)),
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_MasterValue_IsActive]  DEFAULT ((1)),
	[InsUser] [int] NOT NULL CONSTRAINT [DF_MasterValue_InsUser]  DEFAULT ((1)),
	[InsDate] [datetime] NOT NULL CONSTRAINT [DF_MasterValue_InsDate]  DEFAULT (getdate()),
	[InsTerminal] [nvarchar](30) NOT NULL CONSTRAINT [DF_MasterValue_InsTerminal]  DEFAULT (N'127.0.0.1'),
	[UpdUser] [int] NULL,
	[UpdDate] [datetime] NULL,
	[UpdTerminal] [nvarchar](30) NULL,
 CONSTRAINT [PK_MasterValue] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MenuGroup]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MenuGroup](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MenuGroupName] [nvarchar](100) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_MenuGroup] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MenuMaster]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MenuMaster](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MenuName] [nvarchar](100) NULL,
	[MenuDes] [nvarchar](250) NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_Menus_IsActive]  DEFAULT ((1)),
	[ParentMenuID] [int] NULL,
	[OrderNo] [numeric](5, 2) NOT NULL,
	[ControllerName] [nvarchar](50) NULL,
	[ActionName] [nvarchar](50) NULL,
	[MenuPath] [nvarchar](50) NULL,
	[MenuIcon] [nvarchar](50) NULL,
 CONSTRAINT [PK_Menus] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MenuRoleRights]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MenuRoleRights](
	[RefRoleId] [int] NOT NULL,
	[RefMenuId] [int] NOT NULL,
	[CanInsert] [bit] NOT NULL,
	[CanUpdate] [bit] NOT NULL,
	[CanDelete] [bit] NOT NULL,
	[CanView] [bit] NOT NULL,
	[InsUser] [int] NOT NULL CONSTRAINT [DF_MenuRoleRights_InsUser]  DEFAULT ((1)),
	[InsDate] [datetime] NOT NULL CONSTRAINT [DF_MenuRoleRights_InsDate]  DEFAULT (getdate()),
	[InsTerminal] [nvarchar](30) NOT NULL CONSTRAINT [DF_MenuRoleRights_InsTerminal]  DEFAULT (N'127.0.0.1'),
	[UpdUser] [int] NULL,
	[UpdDate] [datetime] NULL,
	[UpdTerminal] [nvarchar](30) NULL,
 CONSTRAINT [PK_MenuRoleRights] PRIMARY KEY CLUSTERED 
(
	[RefRoleId] ASC,
	[RefMenuId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NotificationDet]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NotificationDet](
	[NotifyDetId] [int] IDENTITY(1,1) NOT NULL,
	[RefNotifyId] [int] NULL,
	[RefAppUserId] [int] NULL,
	[Status] [nvarchar](20) NULL,
	[Response] [nvarchar](500) NULL,
	[InsUser] [nchar](10) NOT NULL,
	[InsDate] [datetime] NOT NULL,
	[InsTerminal] [nvarchar](60) NOT NULL,
	[UpdUser] [nchar](10) NULL,
	[UpdDate] [datetime] NULL,
	[UpdTerminal] [nvarchar](60) NULL,
 CONSTRAINT [PK_NotificationDet] PRIMARY KEY CLUSTERED 
(
	[NotifyDetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NotificationMas]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NotificationMas](
	[NotifyId] [int] IDENTITY(1,1) NOT NULL,
	[RefVendorId] [int] NOT NULL,
	[NotifyDate] [date] NOT NULL,
	[RefGroupId] [nvarchar](500) NULL,
	[RefAppUserId] [nvarchar](500) NULL,
	[Message] [nvarchar](500) NULL,
	[ImgPath] [nvarchar](100) NULL,
	[InsUser] [int] NOT NULL,
	[InsDate] [datetime] NOT NULL,
	[InsTerminal] [nvarchar](60) NOT NULL,
	[UpdUser] [int] NULL,
	[UpdDate] [datetime] NULL,
	[UpdTerminal] [nvarchar](60) NULL,
 CONSTRAINT [PK_NotificationMas] PRIMARY KEY CLUSTERED 
(
	[NotifyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ParameterMapping]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ParameterMapping](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RefMasterId] [int] NOT NULL,
	[RefVendorId] [int] NOT NULL,
	[RefVendorValId] [int] NOT NULL,
	[RefStoreId] [int] NOT NULL,
	[RefStoreValId] [int] NULL,
	[InsUser] [int] NOT NULL,
	[InsDate] [datetime] NOT NULL,
	[InsTerminal] [nvarchar](50) NOT NULL,
	[UpdUser] [int] NULL,
	[UpdDate] [datetime] NULL,
	[UpdTerminal] [nvarchar](50) NULL,
 CONSTRAINT [PK_ParameterMapping] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProductCategory]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductCategory](
	[PCId] [int] IDENTITY(1,1) NOT NULL,
	[RefVendorId] [int] NOT NULL,
	[ProdCategoryName] [nvarchar](50) NOT NULL,
	[ProdCategoryDesc] [nvarchar](200) NULL,
	[RefPCId] [int] NULL,
	[Ord] [int] NULL,
	[ProdCategoryImg] [nvarchar](200) NULL,
	[InsUser] [int] NULL,
	[InsDate] [datetime] NULL,
	[InsTerminal] [nvarchar](50) NULL,
	[UpdUser] [int] NULL,
	[UpdDate] [datetime] NULL,
	[UpdTerminal] [nvarchar](50) NULL,
 CONSTRAINT [PK_ProductCategory] PRIMARY KEY CLUSTERED 
(
	[PCId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProductImgDet]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductImgDet](
	[ProdImgId] [int] IDENTITY(1,1) NOT NULL,
	[RefProdId] [int] NOT NULL,
	[ImgName] [nvarchar](50) NOT NULL,
	[Ord] [int] NULL,
	[IsGlobal] [bit] NULL CONSTRAINT [DF_ProductImgDet_IsGlobal]  DEFAULT ((0)),
	[InsUser] [int] NOT NULL,
	[InsDate] [datetime] NOT NULL,
	[InsTerminal] [nvarchar](60) NOT NULL,
	[UpdUser] [int] NULL,
	[UpdDate] [datetime] NULL,
	[UpdTerminal] [nvarchar](60) NULL,
 CONSTRAINT [PK_ProductImgDet] PRIMARY KEY CLUSTERED 
(
	[ProdImgId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProductMas]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductMas](
	[ProdId] [int] IDENTITY(1,1) NOT NULL,
	[ProdName] [nvarchar](100) NULL,
	[RefVendorId] [int] NOT NULL,
	[RefCatId] [int] NULL,
	[ProdCode] [nvarchar](50) NOT NULL,
	[ProdDescription] [nvarchar](500) NULL,
	[RefProdCategory] [nvarchar](50) NULL,
	[RefColor] [nvarchar](500) NULL,
	[RefProdType] [nvarchar](50) NULL,
	[RefSize] [nvarchar](500) NULL,
	[RefFabric] [nvarchar](50) NULL,
	[RefDesign] [nvarchar](50) NULL,
	[RefBrand] [nvarchar](30) NULL,
	[Celebrity] [nvarchar](50) NULL,
	[ProdImgPath] [nvarchar](100) NULL,
	[ActivetillDate] [date] NULL,
	[IsActive] [bit] NULL,
	[RetailPrice] [numeric](10, 2) NULL,
	[WholeSalePrice] [numeric](10, 2) NULL,
	[RefProdId] [int] NULL,
	[RefStoreId] [int] NULL,
	[InsUser] [int] NOT NULL,
	[InsDate] [datetime] NOT NULL,
	[InsTerminal] [nvarchar](60) NOT NULL,
	[UpdUser] [int] NULL,
	[UpdDate] [datetime] NULL,
	[UpdTerminal] [nvarchar](60) NULL,
 CONSTRAINT [PK_ProductMas] PRIMARY KEY CLUSTERED 
(
	[ProdId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[StoreAssociation]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StoreAssociation](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RefStoreId] [int] NOT NULL,
	[RefVendorId] [int] NOT NULL,
	[StoreCode] [nvarchar](6) NOT NULL,
	[StoreStatus] [nvarchar](50) NOT NULL,
	[VendorStatus] [nvarchar](50) NOT NULL,
	[ReqDate] [datetime] NOT NULL,
	[ApprovedDate] [datetime] NULL,
	[InsUser] [int] NOT NULL,
	[InsDate] [datetime] NOT NULL,
	[InsTerminal] [nvarchar](50) NOT NULL,
	[UpdUser] [int] NULL,
	[UpdDate] [datetime] NULL,
	[UpdTerminal] [nvarchar](50) NULL,
 CONSTRAINT [PK_StoreAssociation\] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Subscription]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Subscription](
	[SubId] [int] IDENTITY(1,1) NOT NULL,
	[SubType] [nvarchar](50) NOT NULL,
	[NoOfProducts] [int] NOT NULL,
	[NoOfAppUser] [int] NOT NULL,
	[NoOfDays] [int] NOT NULL,
	[NoOfSlider] [int] NOT NULL,
	[InsUser] [nchar](10) NOT NULL,
	[InsDate] [nchar](10) NOT NULL,
	[InsTerminal] [nchar](10) NOT NULL,
	[UpdUser] [nchar](10) NULL,
	[UpdDate] [nchar](10) NULL,
	[UpdTerminal] [nchar](10) NULL,
 CONSTRAINT [PK_Subscription] PRIMARY KEY CLUSTERED 
(
	[SubId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Vendor]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Vendor](
	[VendorId] [int] IDENTITY(1,1) NOT NULL,
	[VendorName] [nvarchar](100) NOT NULL,
	[UserName] [nvarchar](50) NOT NULL,
	[Address] [nvarchar](100) NULL,
	[Landmark] [nvarchar](100) NULL,
	[Country] [nvarchar](50) NULL,
	[State] [nvarchar](50) NULL,
	[City] [nvarchar](50) NULL,
	[Pincode] [nvarchar](50) NULL,
	[ContactName] [nvarchar](50) NULL,
	[ContactNo1] [nvarchar](50) NULL,
	[ContactNo2] [nvarchar](50) NULL,
	[MobileNo1] [nvarchar](50) NULL,
	[MobileNo2] [nvarchar](50) NULL,
	[FaxNo] [nvarchar](50) NULL,
	[EmailId] [nvarchar](100) NULL,
	[WebSite] [nvarchar](100) NULL,
	[LogoImg] [nvarchar](200) NULL,
	[VendorCode] [nvarchar](50) NULL,
	[ReferalCode] [nvarchar](10) NULL,
	[ReferenceCode] [nvarchar](10) NULL,
	[IsActive] [bit] NULL,
	[AboutUs] [nvarchar](max) NULL,
	[ProdDispName] [nvarchar](50) NULL,
	[CatDispName] [nvarchar](50) NULL,
	[BGImage] [nvarchar](50) NULL,
	[InsUser] [int] NOT NULL,
	[InsDate] [datetime] NOT NULL,
	[InsTerminal] [nvarchar](50) NOT NULL,
	[UpdUser] [int] NULL,
	[UpdDate] [datetime] NULL,
	[UpdTerminal] [nvarchar](50) NULL,
 CONSTRAINT [PK_Vendor] PRIMARY KEY CLUSTERED 
(
	[VendorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[VendorAssociation]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VendorAssociation](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RefVendorId] [int] NULL,
	[RefAUId] [int] NULL,
	[VendorCode] [nvarchar](50) NULL,
	[VendorStatus] [nvarchar](15) NOT NULL,
	[AppUserStatus] [nvarchar](15) NULL,
	[IsNotify] [bit] NOT NULL,
	[ReqDate] [datetime] NULL,
	[ApproveDate] [datetime] NULL,
	[IsAdmin] [bit] NULL,
	[IsAdminNotification] [bit] NULL,
	[RateVendor] [int] NULL,
	[VisitDateTime] [datetime] NULL,
	[InsUser] [int] NOT NULL CONSTRAINT [DF_VendorAssociation_InsUser]  DEFAULT ((1)),
	[InsDate] [datetime] NOT NULL CONSTRAINT [DF_VendorAssociation_InsDate]  DEFAULT (getdate()),
	[InsTerminal] [nvarchar](30) NOT NULL CONSTRAINT [DF_VendorAssociation_InsTerminal]  DEFAULT (N'127.0.0.1'),
	[UpdUser] [int] NULL,
	[UpdDate] [datetime] NULL,
	[UpdTerminal] [nvarchar](30) NULL,
 CONSTRAINT [PK_VendorAssociation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[VendorSlider]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VendorSlider](
	[SliderId] [int] IDENTITY(1,1) NOT NULL,
	[RefVendorId] [int] NOT NULL,
	[SliderTitle] [nvarchar](50) NULL,
	[SliderImg] [nvarchar](50) NULL,
	[SliderUrl] [nvarchar](500) NULL,
	[Ord] [int] NULL,
	[DisplayPage] [nvarchar](50) NULL,
	[Category] [nvarchar](500) NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NOT NULL,
	[InsUser] [int] NOT NULL,
	[InsDate] [datetime] NOT NULL,
	[InsTerminal] [nvarchar](60) NOT NULL,
	[UpdUser] [int] NULL,
	[UpdDate] [datetime] NULL,
	[UpdTerminal] [nvarchar](60) NULL,
 CONSTRAINT [PK_VendorSlider] PRIMARY KEY CLUSTERED 
(
	[SliderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[VendorSubDet]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VendorSubDet](
	[VendorSubId] [int] IDENTITY(1,1) NOT NULL,
	[RefVendorId] [int] NOT NULL,
	[RefSubId] [int] NOT NULL,
	[ValidFromDate] [date] NULL,
	[ValidTodate] [date] NULL,
	[InsUser] [int] NOT NULL,
	[InsDate] [datetime] NOT NULL,
	[InsTerminal] [nvarchar](50) NOT NULL,
	[UpdUser] [int] NULL,
	[UpdDate] [datetime] NULL,
	[UpdTerminal] [nvarchar](50) NULL,
 CONSTRAINT [PK_VendorSubDet] PRIMARY KEY CLUSTERED 
(
	[VendorSubId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[WishList]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WishList](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RefAUId] [int] NOT NULL,
	[RefVendorId] [int] NOT NULL,
	[RefProdId] [int] NOT NULL,
	[WishValue] [bit] NOT NULL,
	[InsDate] [datetime] NOT NULL,
 CONSTRAINT [PK_WishList] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[WriteToUs]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WriteToUs](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RefAUId] [int] NOT NULL,
	[Remark] [nvarchar](max) NULL,
	[InsUser] [int] NOT NULL,
	[InsDate] [date] NOT NULL,
	[InsTerminal] [nvarchar](60) NOT NULL,
	[UpdUser] [int] NULL,
	[UpdDate] [date] NULL,
	[UpdTerminal] [nvarchar](60) NULL,
 CONSTRAINT [PK_WriteToUs] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[AppLog] ON 

INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 2, NULL, N'Login', 2, N'Desc Login', 2, CAST(N'2016-06-08 00:00:00.000' AS DateTime), N'22', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, NULL, N'Login', 2, N'Desc Login', 2, CAST(N'2016-06-08 00:00:00.000' AS DateTime), N'22', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, NULL, N'Login', 2, N'Desc Login', 2, CAST(N'2016-06-09 00:00:00.000' AS DateTime), N'22', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 2, NULL, N'Login', NULL, N'Desc Login', 2, CAST(N'2016-06-09 00:00:00.000' AS DateTime), N'22', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, 2, NULL, N'Product', NULL, N'Desc Login', 2, CAST(N'2016-06-09 00:00:00.000' AS DateTime), N'22', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (7, 2, 2, N'Product', NULL, N'Desc Login', 2, CAST(N'2016-06-09 00:00:00.000' AS DateTime), N'22', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (8, 2, 2, N'Product', 132, N'Desc Login', 2, CAST(N'2016-06-09 00:00:00.000' AS DateTime), N'22', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (9, 2, 2, N'Product', 132, N'Desc Login', 2, CAST(N'2016-06-09 00:00:00.000' AS DateTime), N'22', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (10, 2, 2, N'Product', 132, N'Desc Login', 2, CAST(N'2016-06-09 00:00:00.000' AS DateTime), N'22', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (131, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-09 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (132, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-09 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (133, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-09 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (134, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-09 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (135, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-09 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (155, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-09 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (156, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-09 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (157, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-09 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (158, 19, 2, N'Category', 5, N'null', 19, CAST(N'2016-06-09 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (159, 19, 2, N'Product', 93, N'null', 19, CAST(N'2016-06-09 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (160, 19, 2, N'Product', 93, N'null', 19, CAST(N'2016-06-09 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (161, 19, 2, N'Product', 92, N'null', 19, CAST(N'2016-06-09 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (162, 19, 2, N'Product', 92, N'null', 19, CAST(N'2016-06-09 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (163, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-09 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (164, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (165, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (166, 19, 2, N'Category', 5, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (167, 19, 2, N'Product', 93, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (168, 19, 2, N'WAProduct', 93, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (169, 19, 2, N'WAProduct', 93, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (170, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (171, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (172, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (173, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (174, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (175, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (228, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (258, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (327, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (328, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (331, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (333, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (334, 19, 2, N'Category', 5, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (340, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (341, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (342, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (346, 19, 2, N'Category', 5, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (347, 19, 2, N'Product', 93, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (348, 19, 2, N'WAProduct', 93, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (349, 19, 2, N'Product', 93, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (350, 19, 2, N'Product', 93, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (351, 19, 2, N'Product', 92, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (352, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (353, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (354, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (355, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (356, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (357, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (358, 19, 2, N'Catalog', 6, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (359, 19, 2, N'Product', 92, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (360, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (449, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (450, 19, 4, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (451, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (452, 19, 2, N'Category', 5, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (453, 19, 2, N'Product', 93, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (454, 19, 2, N'Product', 92, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (455, 19, 2, N'Product', 92, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (456, 19, 2, N'Product', 93, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (457, 19, 2, N'Product', 92, N'null', 19, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (464, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (465, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (466, 19, 2, N'Category', 5, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (467, 19, 2, N'Product', 93, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (468, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (469, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (470, 19, 2, N'Category', 5, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (471, 19, 2, N'Product', 93, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (472, 19, 2, N'Product', 93, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (473, 19, 2, N'Category', 5, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (474, 19, 2, N'Product', 92, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (475, 19, 2, N'Product', 98, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (476, 19, 2, N'Product', 98, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (477, 19, 2, N'Product', 98, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (478, 19, 2, N'WAProduct', 98, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (479, 19, 2, N'WAProduct', 98, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (480, 19, 2, N'Product', 99, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (481, 19, 2, N'WAProduct', 99, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (482, 19, 2, N'WAProduct', 99, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (483, 19, 4, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (484, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (485, 19, 4, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (486, 19, 4, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (487, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (488, 19, 4, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (489, 19, 4, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (490, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (491, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (492, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (493, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
GO
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (506, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (507, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (508, 19, 2, N'Category', 5, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (509, 19, 2, N'Product', 93, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (510, 19, 2, N'Product', 92, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (512, 19, 2, N'Product', 92, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (514, 19, 2, N'Product', 89, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (517, 19, 2, N'Product', 89, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (519, 19, 2, N'Product', 90, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (523, 19, 2, N'Product', 108, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (526, 19, 2, N'Product', 92, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (527, 19, 2, N'Product', 92, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (528, 19, 2, N'WAProduct', 92, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (531, 19, 2, N'Category', 5, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (532, 19, 2, N'Product', 91, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (533, 19, 2, N'Product', 91, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (534, 19, 2, N'Product', 91, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (544, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (545, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (546, 19, 2, N'Category', 5, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (547, 19, 2, N'Product', 90, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (548, 19, 2, N'Catalog', 6, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (566, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (567, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (568, 19, 2, N'Category', 5, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (569, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (570, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (571, 19, 2, N'Category', 5, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (579, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (581, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (582, 19, 2, N'Category', 5, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (583, 19, 2, N'Product', 93, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (587, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (635, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (637, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (638, 19, 2, N'Category', 5, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (639, 19, 2, N'Product', 93, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (642, 19, 2, N'Category', 5, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (643, 19, 2, N'Product', 92, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (645, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (646, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (647, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (648, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (649, 19, 2, N'Category', 5, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (652, 19, 2, N'Product', 92, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (663, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (664, 19, 4, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (665, 19, 4, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (668, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (669, 19, 2, N'Category', 5, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (672, 19, 4, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (673, 19, 4, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (680, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (681, 19, 2, N'Catalog', 5, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (685, 19, 2, N'Category', 5, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (686, 19, 2, N'Catalog', 3, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (687, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (691, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (703, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (706, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (711, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (714, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (716, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (719, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (721, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (760, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (789, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (790, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (829, 19, 2, N'VendorLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (830, 19, 2, N'Category', 5, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (831, 19, 2, N'Product', 87, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (832, 19, 2, N'Product', 87, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (833, 19, 2, N'Product', 72, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (874, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (890, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (891, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (922, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-11 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (999, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-12 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1022, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-12 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1338, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-12 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1432, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-12 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1487, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-12 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1491, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-12 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1624, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-13 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1677, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-13 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1678, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-13 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1704, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-13 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1706, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-13 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1708, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-13 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1711, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-13 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
INSERT [dbo].[AppLog] ([Id], [RefAUId], [RefVendorId], [LogType], [RefId], [LogDesc], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1739, 19, 2, N'AppLogin', 19, N'null', 19, CAST(N'2016-06-13 00:00:00.000' AS DateTime), N'b5263f2504dedec9', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[AppLog] OFF
SET IDENTITY_INSERT [dbo].[AppUsers] ON 

INSERT [dbo].[AppUsers] ([AUId], [AUName], [CompanyName], [Address], [LandMark], [Country], [State], [City], [Pincode], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [EmailId], [WebSite], [GCMID], [AppVersion], [DeviceID], [DeviceOS], [IsActive], [IsNotify], [DefaultView], [AppUserImg], [RateUs], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, N'Kush', N'DFG', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'3423423', NULL, N'gangadwaladarshan@gmail.com', NULL, N'fT1MUAjGn40:APA91bFBx0pRxIuIu6L9P3yS3-KwSRhDGXR2C8sBFsiforUTp7VBfx1PHf3fMHCgywttHTPBrQNH8atBSPJpYDf_4VHmwXZ3O-AZllI29zMxDEWY35xSfdt_YMZZ7NxMgHfXotgMpuoa', NULL, N'23423razsdfas', N'Android', 1, 1, N'Product', NULL, NULL, 1, CAST(N'2016-04-16 13:50:13.460' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-04-21 12:59:12.853' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AppUsers] ([AUId], [AUName], [CompanyName], [Address], [LandMark], [Country], [State], [City], [Pincode], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [EmailId], [WebSite], [GCMID], [AppVersion], [DeviceID], [DeviceOS], [IsActive], [IsNotify], [DefaultView], [AppUserImg], [RateUs], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, N'Darshan', N'Radheshyam texttile Pvt Ltd.', N'Nityanand', N'Katargam', N'India', N'Gujarat', N'Surat', N'395004', N'1455268', NULL, N'856965455', N'Darshan', N'gangadwaladarshan@gmail.com', NULL, N'fT1MUAjGn40:APA91bFBx0pRxIuIu6L9P3yS3-KwSRhDGXR2C8sBFsiforUTp7VBfx1PHf3fMHCgywttHTPBrQNH8atBSPJpYDf_4VHmwXZ3O-AZllI29zMxDEWY35xSfdt_YMZZ7NxMgHfXotgMpuoa', CAST(2.10 AS Numeric(5, 2)), N'22', N'Android', 1, 1, NULL, NULL, 3, 1, CAST(N'2016-04-16 13:54:04.440' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[AppUsers] ([AUId], [AUName], [CompanyName], [Address], [LandMark], [Country], [State], [City], [Pincode], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [EmailId], [WebSite], [GCMID], [AppVersion], [DeviceID], [DeviceOS], [IsActive], [IsNotify], [DefaultView], [AppUserImg], [RateUs], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3, N'Darshan', N'GD', N'Nityanand', N'Katargam', N'India', N'Gujarat', N'Surat', N'395004', N'1455268', NULL, N'856965455', N'Darshan', N'gangadwaladarshan@gmail.com', NULL, N'fT1MUAjGn40:APA91bFBx0pRxIuIu6L9P3yS3-KwSRhDGXR2C8sBFsiforUTp7VBfx1PHf3fMHCgywttHTPBrQNH8atBSPJpYDf_4VHmwXZ3O-AZllI29zMxDEWY35xSfdt_YMZZ7NxMgHfXotgMpuoa', NULL, N'33', N'Android', 1, 1, NULL, NULL, NULL, 1, CAST(N'2016-04-16 13:54:46.690' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[AppUsers] ([AUId], [AUName], [CompanyName], [Address], [LandMark], [Country], [State], [City], [Pincode], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [EmailId], [WebSite], [GCMID], [AppVersion], [DeviceID], [DeviceOS], [IsActive], [IsNotify], [DefaultView], [AppUserImg], [RateUs], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, N'Darshan Gangadwala', N'GDY', N'B/95 Nityanand', N'Katargam', N'India', N'Gujarat', N'Surat', N'395004', N'5555555', NULL, N'999999999', N'Darshan', N'gangadwaladarshan@gmail.com', NULL, N'fT1MUAjGn40:APA91bFBx0pRxIuIu6L9P3yS3-KwSRhDGXR2C8sBFsiforUTp7VBfx1PHf3fMHCgywttHTPBrQNH8atBSPJpYDf_4VHmwXZ3O-AZllI29zMxDEWY35xSfdt_YMZZ7NxMgHfXotgMpuoa', NULL, N'44', N'Android', 1, 1, NULL, NULL, NULL, 1, CAST(N'2016-04-16 15:44:36.950' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[AppUsers] ([AUId], [AUName], [CompanyName], [Address], [LandMark], [Country], [State], [City], [Pincode], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [EmailId], [WebSite], [GCMID], [AppVersion], [DeviceID], [DeviceOS], [IsActive], [IsNotify], [DefaultView], [AppUserImg], [RateUs], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, N'Darshan Gangadwala', N'GDY', N'B/95 Nityanand', N'Katargam', N'India', N'Gujarat', N'Surat', N'395004', N'5555555', NULL, N'999999999', N'Darshan', N'gangadwaladarshan@gmail.com', NULL, N'fT1MUAjGn40:APA91bFBx0pRxIuIu6L9P3yS3-KwSRhDGXR2C8sBFsiforUTp7VBfx1PHf3fMHCgywttHTPBrQNH8atBSPJpYDf_4VHmwXZ3O-AZllI29zMxDEWY35xSfdt_YMZZ7NxMgHfXotgMpuoa', NULL, N'55', N'Android', 1, 1, NULL, NULL, NULL, 1, CAST(N'2016-04-16 15:45:26.953' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[AppUsers] ([AUId], [AUName], [CompanyName], [Address], [LandMark], [Country], [State], [City], [Pincode], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [EmailId], [WebSite], [GCMID], [AppVersion], [DeviceID], [DeviceOS], [IsActive], [IsNotify], [DefaultView], [AppUserImg], [RateUs], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, N'Darshan Gangadwala', N'GDY', N'B/95 Nityanand', N'Katargam', N'India', N'Gujarat', N'Surat', N'395004', N'5555555', NULL, N'999999999', N'Darshan', N'gangadwaladarshan@gmail.com', NULL, N'fT1MUAjGn40:APA91bFBx0pRxIuIu6L9P3yS3-KwSRhDGXR2C8sBFsiforUTp7VBfx1PHf3fMHCgywttHTPBrQNH8atBSPJpYDf_4VHmwXZ3O-AZllI29zMxDEWY35xSfdt_YMZZ7NxMgHfXotgMpuoa', NULL, N'66', N'Android', 1, 1, NULL, NULL, NULL, 1, CAST(N'2016-04-16 15:47:42.967' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[AppUsers] ([AUId], [AUName], [CompanyName], [Address], [LandMark], [Country], [State], [City], [Pincode], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [EmailId], [WebSite], [GCMID], [AppVersion], [DeviceID], [DeviceOS], [IsActive], [IsNotify], [DefaultView], [AppUserImg], [RateUs], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (7, N'Darshan Gangadwala', N'GDY', N'B/95 Nityanand', N'Katargam', N'India', N'Gujarat', N'Surat', N'395004', N'5555555', NULL, N'999999999', N'Darshan', N'gangadwaladarshan@gmail.com', NULL, N'fT1MUAjGn40:APA91bFBx0pRxIuIu6L9P3yS3-KwSRhDGXR2C8sBFsiforUTp7VBfx1PHf3fMHCgywttHTPBrQNH8atBSPJpYDf_4VHmwXZ3O-AZllI29zMxDEWY35xSfdt_YMZZ7NxMgHfXotgMpuoa', NULL, N'77', N'Android', 1, 1, NULL, NULL, NULL, 1, CAST(N'2016-04-16 15:48:00.140' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[AppUsers] ([AUId], [AUName], [CompanyName], [Address], [LandMark], [Country], [State], [City], [Pincode], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [EmailId], [WebSite], [GCMID], [AppVersion], [DeviceID], [DeviceOS], [IsActive], [IsNotify], [DefaultView], [AppUserImg], [RateUs], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (8, N'Darshan Gangadwala', N'GDY', N'B/95 Nityanand', N'Katargam', N'India', N'Gujarat', N'Surat', N'395004', N'5555555', NULL, N'999999999', N'Darshan', N'gangadwaladarshan@gmail.com', NULL, NULL, NULL, N'88', N'Android', 1, 1, NULL, NULL, NULL, 1, CAST(N'2016-04-16 15:52:02.340' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[AppUsers] ([AUId], [AUName], [CompanyName], [Address], [LandMark], [Country], [State], [City], [Pincode], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [EmailId], [WebSite], [GCMID], [AppVersion], [DeviceID], [DeviceOS], [IsActive], [IsNotify], [DefaultView], [AppUserImg], [RateUs], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (9, N'Darshan Gangadwala', N'GDY', N'B/95 Nityanand', N'Katargam', N'India', N'Gujarat', N'Surat', N'395004', N'5555555', NULL, N'999999999', N'Darshan', N'gangadwaladarshan@gmail.com', NULL, NULL, NULL, N'99', N'Android', 1, 1, NULL, NULL, NULL, 1, CAST(N'2016-04-16 15:52:30.630' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[AppUsers] ([AUId], [AUName], [CompanyName], [Address], [LandMark], [Country], [State], [City], [Pincode], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [EmailId], [WebSite], [GCMID], [AppVersion], [DeviceID], [DeviceOS], [IsActive], [IsNotify], [DefaultView], [AppUserImg], [RateUs], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (10, N'Kush', N'DFG', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'3423423', NULL, N'gangadwaladarshan@gmail.com', NULL, N'1231231', NULL, N'23423razsdfas', N'Android', 1, 1, NULL, NULL, NULL, 2, CAST(N'2016-04-20 18:38:24.957' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[AppUsers] ([AUId], [AUName], [CompanyName], [Address], [LandMark], [Country], [State], [City], [Pincode], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [EmailId], [WebSite], [GCMID], [AppVersion], [DeviceID], [DeviceOS], [IsActive], [IsNotify], [DefaultView], [AppUserImg], [RateUs], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (13, N'Darshan', N'D&G', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'258453366', NULL, N'gangadwaladarshan@gmail.com', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, CAST(N'2016-04-28 13:13:13.160' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[AppUsers] ([AUId], [AUName], [CompanyName], [Address], [LandMark], [Country], [State], [City], [Pincode], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [EmailId], [WebSite], [GCMID], [AppVersion], [DeviceID], [DeviceOS], [IsActive], [IsNotify], [DefaultView], [AppUserImg], [RateUs], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (14, N'Darshan', N'D&G', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'258453366', NULL, N'gangadwaladarshan@gmail.com', NULL, NULL, NULL, N'2541563525', NULL, NULL, NULL, NULL, NULL, NULL, 1, CAST(N'2016-04-28 13:24:45.823' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-04-28 13:29:29.580' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AppUsers] ([AUId], [AUName], [CompanyName], [Address], [LandMark], [Country], [State], [City], [Pincode], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [EmailId], [WebSite], [GCMID], [AppVersion], [DeviceID], [DeviceOS], [IsActive], [IsNotify], [DefaultView], [AppUserImg], [RateUs], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (15, N'Darshan', N'D&G', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'258453366', NULL, N'gangadwaladarshan@gmail.com', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, CAST(N'2016-04-28 13:29:41.970' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[AppUsers] ([AUId], [AUName], [CompanyName], [Address], [LandMark], [Country], [State], [City], [Pincode], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [EmailId], [WebSite], [GCMID], [AppVersion], [DeviceID], [DeviceOS], [IsActive], [IsNotify], [DefaultView], [AppUserImg], [RateUs], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (16, N'Darshan', N'D&G', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'258453366', NULL, N'gangadwaladarshan@gmail.com', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, CAST(N'2016-04-28 13:29:44.850' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[AppUsers] ([AUId], [AUName], [CompanyName], [Address], [LandMark], [Country], [State], [City], [Pincode], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [EmailId], [WebSite], [GCMID], [AppVersion], [DeviceID], [DeviceOS], [IsActive], [IsNotify], [DefaultView], [AppUserImg], [RateUs], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (17, N'Darshan', N'D&G', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'258453366', NULL, N'gangadwaladarshan@gmail.com', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, CAST(N'2016-04-28 13:29:47.630' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[AppUsers] ([AUId], [AUName], [CompanyName], [Address], [LandMark], [Country], [State], [City], [Pincode], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [EmailId], [WebSite], [GCMID], [AppVersion], [DeviceID], [DeviceOS], [IsActive], [IsNotify], [DefaultView], [AppUserImg], [RateUs], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (18, N'Darshan', N'D&G', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'258453366', NULL, N'gangadwaladarshan@gmail.com', NULL, NULL, NULL, N'2595456', NULL, NULL, NULL, NULL, NULL, NULL, 1, CAST(N'2016-04-28 13:34:56.227' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-04-28 13:34:58.667' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AppUsers] ([AUId], [AUName], [CompanyName], [Address], [LandMark], [Country], [State], [City], [Pincode], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [EmailId], [WebSite], [GCMID], [AppVersion], [DeviceID], [DeviceOS], [IsActive], [IsNotify], [DefaultView], [AppUserImg], [RateUs], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (19, N'hiten', N'jayam', NULL, NULL, NULL, NULL, N'surat', NULL, NULL, NULL, N'9879474078', NULL, N'gangadwaladarshan@gmail.com', NULL, N'', NULL, N'b5263f2504dedec9', N'Android', NULL, NULL, NULL, NULL, NULL, 1, CAST(N'2016-05-10 11:23:33.040' AS DateTime), N'127', NULL, NULL, NULL)
INSERT [dbo].[AppUsers] ([AUId], [AUName], [CompanyName], [Address], [LandMark], [Country], [State], [City], [Pincode], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [EmailId], [WebSite], [GCMID], [AppVersion], [DeviceID], [DeviceOS], [IsActive], [IsNotify], [DefaultView], [AppUserImg], [RateUs], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (21, N'asd', N'asd', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'64351351', NULL, N'adasdasd', NULL, NULL, NULL, N'86454asd', N'asdas', 1, 1, N'ByCatalog', NULL, NULL, 1, CAST(N'2016-08-06 00:00:00.000' AS DateTime), N'127', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[AppUsers] OFF
INSERT [dbo].[AspNetUsers] ([Id], [UserName], [PasswordHash], [SecurityStamp], [Discriminator]) VALUES (N'036374ec-fe25-42e2-ba53-1ba802929832', N'Darshan', N'AMDJZilEyuM5AA6PGqJwgrTZydeMJ1XrWImkHuc7BwvSXpf3NLYVXrnp5WaAJPiBNQ==', N'43ed6755-19ae-4fbf-a236-3d3304fad130', N'ApplicationUser')
INSERT [dbo].[AspNetUsers] ([Id], [UserName], [PasswordHash], [SecurityStamp], [Discriminator]) VALUES (N'264b0a16-1e75-4480-8178-7c9bc6035b81', N'Dharmik', N'AAJX+ROIDWf1JhjFqJuz0zal9kVodzFPf/TH1QK6G+A2LV2ZiElDW6vaYDv2WBPX/Q==', N'5a783704-7177-406b-bdd7-e15630bb8469', N'ApplicationUser')
INSERT [dbo].[AspNetUsers] ([Id], [UserName], [PasswordHash], [SecurityStamp], [Discriminator]) VALUES (N'388ba2d7-872a-4288-83ad-092e676ee864', N'Yash', N'AN2pCcBd0axRcdrVrpPcfVbyM2uXJS2wRDEIchh4+DtL0iO8bca5zHiGoYlYtmot2w==', N'398a8713-a5b9-4118-959d-0f80cb7e603c', N'ApplicationUser')
INSERT [dbo].[AspNetUsers] ([Id], [UserName], [PasswordHash], [SecurityStamp], [Discriminator]) VALUES (N'49c08cab-ee67-4785-823d-c8dc811d9e00', N'Satish', N'AAXHvHUlCMVYIFixrHd383IyNPpySrc3mrzsdEU28L9oKwjt9TRhk0SPzdxjUbGumw==', N'edfcd8a2-e916-41cc-8bd3-c292430816a4', N'ApplicationUser')
INSERT [dbo].[AspNetUsers] ([Id], [UserName], [PasswordHash], [SecurityStamp], [Discriminator]) VALUES (N'722a73ae-a971-4f36-b926-d1023d7fadb6', N'SIMARAN', N'ABR4iVVR2yimEOycf0VxiBGWTQeSsjwN8KMDAubn0N2dPXyxZJag1sGwmh/QQrrq4g==', N'4c22977d-2b5c-4c6d-abed-e20980387cc7', N'ApplicationUser')
INSERT [dbo].[AspNetUsers] ([Id], [UserName], [PasswordHash], [SecurityStamp], [Discriminator]) VALUES (N'88eb9509-a3ae-4daa-9cfd-5718d769049d', N'Kush', N'ANmhQZNu7zBvjLt3ZYjBiL/INA80mZoaQonOT59CpF3M2xionsEDKKt+6FlnpH4NrA==', N'462cf866-c47e-48af-966e-2a9534699a6b', N'ApplicationUser')
INSERT [dbo].[AspNetUsers] ([Id], [UserName], [PasswordHash], [SecurityStamp], [Discriminator]) VALUES (N'975a6a5d-c615-4866-a821-b7bc56798d15', N'Hiten', N'ADBtifboPEf1ExBXKr9jn8JjczHJ3aJg9X+Lufs5pgGgc7GNTmILLE4T+EcBr9mC3Q==', N'e60ba384-5b56-4b39-b463-c04fc3c5e75f', N'ApplicationUser')
INSERT [dbo].[AspNetUsers] ([Id], [UserName], [PasswordHash], [SecurityStamp], [Discriminator]) VALUES (N'b3ece7db-5e2d-4ac7-8878-1cabd064b2fd', N'Divy', N'ACWo0v1S/zJIFJzNyTRYUGwNv4QUvW+ycDeCUDNg40siE+RjGpybG6qbd5hTmaxdwA==', N'708a58dd-bc90-4d4b-a6b4-e65342015f22', N'ApplicationUser')
SET IDENTITY_INSERT [dbo].[CatalogMas] ON 

INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 2, N'201', N'ABC', N'saree royal 1-2-113206841.jpeg', N'201 Desc', CAST(N'2016-08-21' AS Date), 1, 1, NULL, NULL, 2, CAST(N'2016-04-26 00:00:00.000' AS DateTime), N'127.0.0.1 ', 2, CAST(N'2016-07-12 11:32:06.830' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3, 2, N'202', N'XYZ', N'40542-045510345.jpeg', N'202 Desc', CAST(N'2016-08-21' AS Date), 1, 1, NULL, NULL, 2, CAST(N'2016-04-26 00:00:00.000' AS DateTime), N'127.0.0.1 ', 2, CAST(N'2016-06-13 16:55:10.333' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 2, N'203', N'PQR', N'40533-043856578.jpeg', N'203 Desc', CAST(N'2016-08-21' AS Date), 1, 1, NULL, NULL, 2, CAST(N'2016-04-26 00:00:00.000' AS DateTime), N'127.0.0.1 ', 2, CAST(N'2016-06-13 16:38:56.563' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, 2, N'204', N'STU', N'40542-043832180.jpeg', N'204 Desc', CAST(N'2016-08-21' AS Date), 1, 0, NULL, NULL, 2, CAST(N'2016-04-26 00:00:00.000' AS DateTime), N'127.0.0.1 ', 2, CAST(N'2016-06-13 16:38:32.147' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (11, 2, N'205', N'Catalog 123', N'40526-043821891.jpeg', N'On the Insert tab, the galleries include items that are designed to coordinate with the overall look of your document. You can use these galleries to insert tables, headers, footers, lists, cover page', CAST(N'2016-08-21' AS Date), 1, 1, NULL, NULL, 1, CAST(N'2016-04-30 17:38:33.983' AS DateTime), N'127.0.0.1 ', 2, CAST(N'2016-06-13 16:38:21.877' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (19, 2, N'1500', N'1500 Cat', N'extra-02696929-2-025325452.jpeg', NULL, CAST(N'2016-08-21' AS Date), 1, 1, NULL, NULL, 1, CAST(N'2016-05-11 15:34:51.457' AS DateTime), N'127.0.0.1', 6, CAST(N'2016-07-13 14:53:35.060' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (20, 2, N'CAT1600', N'1600 Cat', N'40520-043525641.jpeg', NULL, CAST(N'2016-08-21' AS Date), 0, 1, NULL, NULL, 1, CAST(N'2016-05-11 15:34:51.477' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-13 16:35:25.623' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (21, 2, N'1200', N'1200 Cat', N'SLIDER006-980x4-2-102302540.jpeg', N'Desc 1200', CAST(N'2016-08-21' AS Date), 1, 1, NULL, NULL, 1, CAST(N'2016-05-11 15:34:51.480' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-04 10:22:56.660' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (22, 2, N'1300', N'1300 Cat', N'saree banner up-2-115731795.jpeg', NULL, CAST(N'2016-08-21' AS Date), 0, 1, NULL, NULL, 1, CAST(N'2016-05-11 15:34:51.483' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-06 11:57:31.777' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (23, 2, N'CAT1400', N'1400 Cat', N'40543-043743237.jpeg', NULL, CAST(N'2016-08-21' AS Date), 0, 1, NULL, NULL, 1, CAST(N'2016-05-11 15:34:51.483' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-13 16:37:43.220' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1014, 2, N'2002', N'Cat 2', N'40537-043647492.jpeg', NULL, CAST(N'2016-08-21' AS Date), 1, 1, NULL, NULL, 1, CAST(N'2016-05-12 11:43:35.930' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-13 16:36:47.470' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1015, 2, N'CAT2003', N'Cat 3', N'40530-043635664.jpeg', NULL, CAST(N'2016-08-21' AS Date), 0, 1, NULL, NULL, 1, CAST(N'2016-05-12 11:43:35.943' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-13 16:36:35.650' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1017, 2, N'CAT2005', N'Cat 5', N'40527-043542216.jpeg', NULL, CAST(N'2016-08-21' AS Date), 1, 1, NULL, NULL, 1, CAST(N'2016-05-12 11:43:35.997' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-13 16:35:42.200' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1019, 2, N'3001', N'Cat 1', N'40549-043659012.jpeg', N'Desc Cat', CAST(N'2016-08-21' AS Date), 0, 1, NULL, NULL, 1, CAST(N'2016-05-12 11:58:12.843' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-13 16:36:58.997' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1020, 2, N'3002', N'Cat 2', N'40515-045531206.jpeg', NULL, CAST(N'2016-08-21' AS Date), 0, 1, NULL, NULL, 1, CAST(N'2016-05-12 11:58:12.857' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-13 16:55:31.203' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1021, 2, N'3003', N'Cat 3', N'40538-043616252.jpeg', NULL, CAST(N'2016-08-21' AS Date), 1, 1, NULL, NULL, 1, CAST(N'2016-05-12 11:58:12.860' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-13 16:36:16.233' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1022, 2, N'3004', N'Cat 4', N'40540-043600326.jpeg', N'Desc Cat 54r3', CAST(N'2016-08-21' AS Date), 0, 1, NULL, NULL, 1, CAST(N'2016-05-12 11:58:12.860' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-13 16:36:00.310' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1023, 2, N'3005', N'Cat 5', N'40545-043753962.jpeg', NULL, CAST(N'2016-08-21' AS Date), 1, 1, NULL, NULL, 1, CAST(N'2016-05-12 11:58:12.870' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-13 16:37:53.947' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1024, 2, N'3006', N'Cat 6', N'40519-043508706.jpeg', NULL, CAST(N'2016-08-21' AS Date), 0, 1, NULL, NULL, 1, CAST(N'2016-05-12 11:58:12.873' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-13 16:35:08.690' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1025, 2, N'4001', N'Cat 1', N'40548-043706832.jpeg', N'Desc Cat', CAST(N'2016-08-21' AS Date), 0, 1, NULL, NULL, 1, CAST(N'2016-05-12 12:30:43.193' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-13 16:37:06.817' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1026, 2, N'4002', N'Cat 2', N'40518-045547636.jpeg', NULL, CAST(N'2016-08-21' AS Date), 1, 1, NULL, NULL, 1, CAST(N'2016-05-12 12:30:43.227' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-13 16:55:47.633' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1027, 2, N'4003', N'Cat 3', N'40534-043624383.jpeg', NULL, CAST(N'2016-08-21' AS Date), 0, 1, NULL, NULL, 1, CAST(N'2016-05-12 12:30:43.240' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-13 16:36:24.370' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1028, 2, N'4004', N'Cat 4', N'40535-043608261.jpeg', N'Desc Cat 54r3', CAST(N'2016-08-21' AS Date), 1, 1, NULL, NULL, 1, CAST(N'2016-05-12 12:30:43.253' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-13 16:36:08.247' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1029, 2, N'4005', N'Cat 5', N'40518-043810478.jpeg', NULL, CAST(N'2016-08-21' AS Date), 0, 1, NULL, NULL, 1, CAST(N'2016-05-12 12:30:43.280' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-13 16:38:10.460' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1030, 2, N'4006', N'Cat 6', N'40528-043533685.jpeg', NULL, CAST(N'2016-08-21' AS Date), 0, 1, NULL, NULL, 1, CAST(N'2016-05-12 12:30:43.293' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-13 16:35:33.670' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2062, 4, N'201', N'ABC', N'xslide03.jpg.pa-4-115820479.jpeg', N'201 Desc', CAST(N'2016-07-07' AS Date), 1, 1, 1, NULL, 4, CAST(N'2016-07-02 11:48:16.473' AS DateTime), N'127.0.0.1', 4, CAST(N'2016-08-05 11:58:20.477' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2063, 6, N'201', N'ABC', N'Eid-Specil-Salw-114826560.jpeg', N'201 Desc', CAST(N'2016-08-21' AS Date), 1, 1, 2062, 4, 6, CAST(N'2016-07-02 11:53:26.713' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2064, 4, N'202', N'XYZ', N'Eid-Specil-Salw-114826560.jpeg', N'202 Desc', CAST(N'2016-08-21' AS Date), 1, 1, 3, 2, 4, CAST(N'2016-07-02 14:12:10.380' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2065, 2, N'Cat1', N'CatName1', NULL, NULL, NULL, 0, 1, NULL, NULL, 2, CAST(N'2016-07-04 11:34:57.867' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2067, 4, N'203', N'PQR', N'Eid-Specil-Salw-114826560.jpeg', N'203 Desc', CAST(N'2016-08-21' AS Date), 1, 1, 5, 2, 4, CAST(N'2016-07-04 13:04:35.040' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2068, 4, N'1500', N'1500 Cat', N'Eid-Specil-Salw-114826560.jpeg', NULL, CAST(N'2016-08-21' AS Date), 1, 1, 19, 2, 4, CAST(N'2016-07-04 13:06:12.603' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2069, 4, N'204', N'STU', N'Eid-Specil-Salw-114826560.jpeg', N'204 Desc', CAST(N'2016-08-21' AS Date), 1, 0, 6, 2, 4, CAST(N'2016-07-06 10:08:57.757' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2070, 4, N'1200', N'1200 Cat', N'unnamed-4-113818144.png', N'Desc 1200', CAST(N'2016-08-21' AS Date), 1, 1, 21, NULL, 4, CAST(N'2016-07-06 10:14:31.310' AS DateTime), N'127.0.0.1', 4, CAST(N'2016-08-05 11:38:18.120' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2071, 6, N'202', N'XYZ', N'slider3-1140x38-6-014621655.jpeg', N'202 Desc', CAST(N'2016-08-21' AS Date), 1, 1, 3, NULL, 6, CAST(N'2016-07-07 13:37:12.037' AS DateTime), N'127.0.0.1', 6, CAST(N'2016-07-07 13:46:21.640' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2072, 6, N'20111', N'ABC1', N'xslide03.jpg.pa-6-014609184.jpeg', N'201 Desc', CAST(N'2016-08-21' AS Date), 1, 1, 1, NULL, 6, CAST(N'2016-07-07 13:45:40.080' AS DateTime), N'127.0.0.1', 6, CAST(N'2016-07-08 11:15:30.130' AS DateTime), N'127.0.0.1')
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3071, 6, N'1136', N'1136', NULL, N'', CAST(N'2016-06-13' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.613' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3072, 6, N'1273', N'1273', NULL, N'', CAST(N'2016-06-14' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.690' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3073, 6, N'1846', N'1846', NULL, N'', CAST(N'2016-06-15' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.703' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3074, 6, N'1905', N'1905', NULL, N'', CAST(N'2016-06-16' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.713' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3075, 6, N'1982', N'1982', NULL, N'', CAST(N'2016-06-19' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.727' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3076, 6, N'1983', N'1983', NULL, N'', CAST(N'2016-06-20' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.730' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3077, 6, N'1984', N'1984', NULL, N'', CAST(N'2016-06-21' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.733' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3078, 6, N'1985', N'1985', NULL, N'', CAST(N'2016-06-22' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.740' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3079, 6, N'1986', N'1986', NULL, N'', CAST(N'2016-06-23' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.750' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3080, 6, N'1987', N'1987', NULL, N'', CAST(N'2016-06-24' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.750' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3081, 6, N'1989', N'1989', NULL, N'', CAST(N'2016-06-26' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.767' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3082, 6, N'1990', N'1990', NULL, N'', CAST(N'2016-06-27' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.767' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3083, 6, N'1991', N'1991', NULL, N'', CAST(N'2016-06-28' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.783' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3084, 6, N'1992', N'1992', NULL, N'', CAST(N'2016-06-29' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.830' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3085, 6, N'1993', N'1993', NULL, N'', CAST(N'2016-06-30' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.833' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3086, 6, N'1994', N'1994', NULL, N'', CAST(N'2016-07-01' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.837' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3087, 6, N'1995', N'1995', NULL, N'', CAST(N'2016-07-02' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.840' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3088, 6, N'1996', N'1996', NULL, N'', CAST(N'2016-07-03' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.840' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3089, 6, N'1997', N'1997', NULL, N'', CAST(N'2016-07-04' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.843' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3090, 6, N'1998', N'1998', NULL, N'', CAST(N'2016-07-05' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.847' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3091, 6, N'1999', N'1999', NULL, N'', CAST(N'2016-07-06' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.850' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3092, 6, N'2000', N'2000', NULL, N'', CAST(N'2016-07-07' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.863' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3093, 6, N'2001', N'2001', NULL, N'', CAST(N'2016-07-08' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.867' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3094, 6, N'2002', N'2002', NULL, N'', CAST(N'2016-07-09' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.883' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3095, 6, N'2003', N'2003', NULL, N'', CAST(N'2016-07-10' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.883' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3096, 6, N'2004', N'2004', NULL, N'', CAST(N'2016-07-11' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.887' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3097, 6, N'2005', N'2005', NULL, N'', CAST(N'2016-07-12' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.890' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3098, 6, N'2006', N'2006', NULL, N'', CAST(N'2016-07-13' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.890' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3099, 6, N'2007', N'2007', NULL, N'', CAST(N'2016-07-14' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.893' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3100, 6, N'2008', N'2008', NULL, N'', CAST(N'2016-07-15' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.897' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3101, 6, N'2009', N'2009', NULL, N'', CAST(N'2016-07-16' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.900' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3102, 6, N'2010', N'2010', NULL, N'', CAST(N'2016-07-17' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.900' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3103, 6, N'2011', N'2011', NULL, N'', CAST(N'2016-07-18' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.903' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3104, 6, N'2012', N'2012', NULL, N'', CAST(N'2016-07-19' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.907' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3105, 6, N'2013', N'2013', NULL, N'', CAST(N'2016-07-20' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.907' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3106, 6, N'2014', N'2014', NULL, N'', CAST(N'2016-07-21' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.910' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3107, 6, N'2015', N'2015', NULL, N'', CAST(N'2016-07-22' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.920' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3108, 6, N'2016', N'2016', NULL, N'', CAST(N'2016-07-23' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.923' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3109, 6, N'2017', N'2017', NULL, N'', CAST(N'2016-07-24' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.923' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3110, 6, N'2018', N'2018', NULL, N'', CAST(N'2016-07-25' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.927' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3111, 6, N'2019', N'2019', NULL, N'', CAST(N'2016-07-26' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.930' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3112, 6, N'2020', N'2020', NULL, N'', CAST(N'2016-07-27' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.933' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3113, 6, N'2021', N'2021', NULL, N'', CAST(N'2016-07-28' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.937' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3114, 6, N'2022', N'2022', NULL, N'', CAST(N'2016-07-29' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.937' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3115, 6, N'2023', N'2023', NULL, N'', CAST(N'2016-07-30' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.940' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3116, 6, N'2024', N'2024', NULL, N'', CAST(N'2016-07-31' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.950' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3117, 6, N'2025', N'2025', NULL, N'', CAST(N'2016-08-01' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.950' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3118, 6, N'2026', N'2026', NULL, N'', CAST(N'2016-08-02' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.953' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3119, 6, N'2027', N'2027', NULL, N'', CAST(N'2016-08-03' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.957' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3120, 6, N'2028', N'2028', NULL, N'', CAST(N'2016-08-04' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.960' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3121, 6, N'2029', N'2029', NULL, N'', CAST(N'2016-08-05' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.967' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3122, 6, N'2030', N'2030', NULL, N'', CAST(N'2016-08-06' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.970' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3123, 6, N'2031', N'2031', NULL, N'', CAST(N'2016-08-07' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.973' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3124, 6, N'2032', N'2032', NULL, N'', CAST(N'2016-08-08' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.973' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3125, 6, N'2033', N'2033', NULL, N'', CAST(N'2016-08-09' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.977' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3126, 6, N'2034', N'2034', NULL, N'', CAST(N'2016-08-10' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.980' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3127, 6, N'2035', N'2035', NULL, N'', CAST(N'2016-08-11' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.980' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3128, 6, N'2036', N'2036', NULL, N'', CAST(N'2016-08-12' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.983' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3129, 6, N'2037', N'2037', NULL, N'', CAST(N'2016-08-13' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.987' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3130, 6, N'2038', N'2038', NULL, N'', CAST(N'2016-08-14' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:44.990' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3131, 6, N'2039', N'2039', NULL, N'', CAST(N'2016-08-15' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.007' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3132, 6, N'2040', N'2040', NULL, N'', CAST(N'2016-08-16' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.010' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3133, 6, N'2041', N'2041', NULL, N'', CAST(N'2016-08-17' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.013' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3134, 6, N'2042', N'2042', NULL, N'', CAST(N'2016-08-18' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.013' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
GO
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3135, 6, N'2043', N'2043', NULL, N'', CAST(N'2016-08-19' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.023' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3136, 6, N'2044', N'2044', NULL, N'', CAST(N'2016-08-20' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.030' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3137, 6, N'2045', N'2045', NULL, N'', CAST(N'2016-08-21' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.037' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3138, 6, N'2046', N'2046', NULL, N'', CAST(N'2016-08-22' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.040' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3139, 6, N'2047', N'2047', NULL, N'', CAST(N'2016-08-23' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.050' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3140, 6, N'2048', N'2048', NULL, N'', CAST(N'2016-08-24' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.063' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3141, 6, N'2049', N'2049', NULL, N'', CAST(N'2016-08-25' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.067' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3142, 6, N'2050', N'2050', NULL, N'', CAST(N'2016-08-26' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.070' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3143, 6, N'2051', N'2051', NULL, N'', CAST(N'2016-08-27' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.070' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3144, 6, N'2052', N'2052', NULL, N'', CAST(N'2016-08-28' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.073' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3145, 6, N'2053', N'2053', NULL, N'', CAST(N'2016-08-29' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.073' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3146, 6, N'2054', N'2054', NULL, N'', CAST(N'2016-08-30' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.077' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3147, 6, N'2055', N'2055', NULL, N'', CAST(N'2016-08-31' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.080' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3148, 6, N'2056', N'2056', NULL, N'', CAST(N'2016-09-01' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.083' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3149, 6, N'2057', N'2057', NULL, N'', CAST(N'2016-09-02' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.083' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3150, 6, N'2058', N'2058', NULL, N'', CAST(N'2016-09-03' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.093' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3151, 6, N'2059', N'2059', NULL, N'', CAST(N'2016-09-04' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.097' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3152, 6, N'2060', N'2060', NULL, N'', CAST(N'2016-09-05' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.100' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3153, 6, N'2061', N'2061', NULL, N'', CAST(N'2016-09-06' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.100' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3154, 6, N'2062', N'2062', NULL, N'', CAST(N'2016-09-07' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.103' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3155, 6, N'2063', N'2063', NULL, N'', CAST(N'2016-09-08' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.103' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3156, 6, N'2064', N'2064', NULL, N'', CAST(N'2016-09-09' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.107' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3157, 6, N'2065', N'2065', NULL, N'', CAST(N'2016-09-10' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.110' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3158, 6, N'2066', N'2066', NULL, N'', CAST(N'2016-09-11' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.110' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3159, 6, N'2067', N'2067', NULL, N'', CAST(N'2016-09-12' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.113' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3160, 6, N'2068', N'2068', NULL, N'', CAST(N'2016-09-13' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.117' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3161, 6, N'2069', N'2069', NULL, N'', CAST(N'2016-09-14' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.120' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3162, 6, N'2070', N'2070', NULL, N'', CAST(N'2016-09-15' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.120' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3163, 6, N'2071', N'2071', NULL, N'', CAST(N'2016-09-16' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.123' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3164, 6, N'2072', N'2072', NULL, N'', CAST(N'2016-09-17' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.127' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3165, 6, N'2073', N'2073', NULL, N'', CAST(N'2016-09-18' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.137' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3166, 6, N'2074', N'2074', NULL, N'', CAST(N'2016-09-19' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.137' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3167, 6, N'2075', N'2075', NULL, N'', CAST(N'2016-09-20' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.140' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3168, 6, N'2076', N'2076', NULL, N'', CAST(N'2016-09-21' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.150' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3169, 6, N'2077', N'2077', NULL, N'', CAST(N'2016-09-22' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.153' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3170, 6, N'2078', N'2078', NULL, N'', CAST(N'2016-09-23' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.153' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3171, 6, N'2079', N'2079', NULL, N'', CAST(N'2016-09-24' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.157' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3172, 6, N'2080', N'2080', NULL, N'', CAST(N'2016-09-25' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.160' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3173, 6, N'2081', N'2081', NULL, N'', CAST(N'2016-09-26' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.160' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3174, 6, N'2082', N'2082', NULL, N'', CAST(N'2016-09-27' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.163' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3175, 6, N'2083', N'2083', NULL, N'', CAST(N'2016-09-28' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.167' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3176, 6, N'2084', N'2084', NULL, N'', CAST(N'2016-09-29' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.180' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3177, 6, N'2085', N'2085', NULL, N'', CAST(N'2016-09-30' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.183' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3178, 6, N'2086', N'2086', NULL, N'', CAST(N'2016-10-01' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.187' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3179, 6, N'2087', N'2087', NULL, N'', CAST(N'2016-10-02' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.190' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3180, 6, N'2088', N'2088', NULL, N'', CAST(N'2016-10-03' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.190' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3181, 6, N'2089', N'2089', NULL, N'', CAST(N'2016-10-04' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.193' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3182, 6, N'2090', N'2090', NULL, N'', CAST(N'2016-10-05' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.193' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3183, 6, N'2091', N'2091', NULL, N'', CAST(N'2016-10-06' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.197' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3184, 6, N'2092', N'2092', NULL, N'', CAST(N'2016-10-07' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.197' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3185, 6, N'2093', N'2093', NULL, N'', CAST(N'2016-10-08' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.200' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3186, 6, N'2094', N'2094', NULL, N'', CAST(N'2016-10-09' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.203' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3187, 6, N'2095', N'2095', NULL, N'', CAST(N'2016-10-10' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.207' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3188, 6, N'2096', N'2096', NULL, N'', CAST(N'2016-10-11' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.210' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3189, 6, N'2097', N'2097', NULL, N'', CAST(N'2016-10-12' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.210' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3190, 6, N'2098', N'2098', NULL, N'', CAST(N'2016-10-13' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.213' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3191, 6, N'2099', N'2099', NULL, N'', CAST(N'2016-10-14' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.213' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3192, 6, N'2100', N'2100', NULL, N'', CAST(N'2016-10-15' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.217' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3193, 6, N'2101', N'2101', NULL, N'', CAST(N'2016-10-16' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.217' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3194, 6, N'2102', N'2102', NULL, N'', CAST(N'2016-10-17' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.230' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3195, 6, N'2103', N'2103', NULL, N'', CAST(N'2016-10-18' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.240' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3196, 6, N'2104', N'2104', NULL, N'', CAST(N'2016-10-19' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.243' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3197, 6, N'2105', N'2105', NULL, N'', CAST(N'2016-10-20' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.247' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3198, 6, N'2106', N'2106', NULL, N'', CAST(N'2016-10-21' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.247' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3199, 6, N'2107', N'2107', NULL, N'', CAST(N'2016-10-22' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.247' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3200, 6, N'2108', N'2108', NULL, N'', CAST(N'2016-10-23' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.250' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3201, 6, N'2109', N'2109', NULL, N'', CAST(N'2016-10-24' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.250' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3202, 6, N'2110', N'2110', NULL, N'', CAST(N'2016-10-25' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.250' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3203, 6, N'2111', N'2111', NULL, N'', CAST(N'2016-10-26' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.253' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3204, 6, N'2112', N'2112', NULL, N'', CAST(N'2016-10-27' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.263' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3205, 6, N'2113', N'2113', NULL, N'', CAST(N'2016-10-28' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.267' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3206, 6, N'2114', N'2114', NULL, N'', CAST(N'2016-10-29' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.267' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3207, 6, N'2115', N'2115', NULL, N'', CAST(N'2016-10-30' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.273' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3208, 6, N'2116', N'2116', NULL, N'', CAST(N'2016-10-31' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.277' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3209, 6, N'2117', N'2117', NULL, N'', CAST(N'2016-11-01' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.280' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3210, 6, N'2118', N'2118', NULL, N'', CAST(N'2016-11-02' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.280' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3211, 6, N'2119', N'2119', NULL, N'', CAST(N'2016-11-03' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.280' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3212, 6, N'2120', N'2120', NULL, N'', CAST(N'2016-11-04' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.283' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3213, 6, N'2121', N'2121', NULL, N'', CAST(N'2016-11-05' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.283' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3214, 6, N'2122', N'2122', NULL, N'', CAST(N'2016-11-06' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.283' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3215, 6, N'2123', N'2123', NULL, N'', CAST(N'2016-11-07' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.287' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3216, 6, N'2124', N'2124', NULL, N'', CAST(N'2016-11-08' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.287' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3217, 6, N'2125', N'2125', NULL, N'', CAST(N'2016-11-09' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.290' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3218, 6, N'2126', N'2126', NULL, N'', CAST(N'2016-11-10' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.290' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3219, 6, N'2127', N'2127', NULL, N'', CAST(N'2016-11-11' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.303' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3220, 6, N'2128', N'2128', NULL, N'', CAST(N'2016-11-12' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.310' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3221, 6, N'2129', N'2129', NULL, N'', CAST(N'2016-11-13' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.310' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3222, 6, N'2130', N'2130', NULL, N'', CAST(N'2016-11-14' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.310' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3223, 6, N'2131', N'2131', NULL, N'', CAST(N'2016-11-15' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.317' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3224, 6, N'2132', N'2132', NULL, N'', CAST(N'2016-11-16' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.317' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3225, 6, N'2133', N'2133', NULL, N'', CAST(N'2016-11-17' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.320' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3226, 6, N'2134', N'2134', NULL, N'', CAST(N'2016-11-18' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.320' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3227, 6, N'2135', N'2135', NULL, N'', CAST(N'2016-11-19' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.330' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3228, 6, N'2136', N'2136', NULL, N'', CAST(N'2016-11-20' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.330' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3229, 6, N'2137', N'2137', NULL, N'', CAST(N'2016-11-21' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.333' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3230, 6, N'2138', N'2138', NULL, N'', CAST(N'2016-11-22' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.333' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3231, 6, N'2139', N'2139', NULL, N'', CAST(N'2016-11-23' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.337' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3232, 6, N'2140', N'2140', NULL, N'', CAST(N'2016-11-24' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.337' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3233, 6, N'2141', N'2141', NULL, N'', CAST(N'2016-11-25' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.337' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3234, 6, N'2142', N'2142', NULL, N'', CAST(N'2016-11-26' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.340' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
GO
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3235, 6, N'2143', N'2143', NULL, N'', CAST(N'2016-11-27' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.340' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3236, 6, N'2144', N'2144', NULL, N'', CAST(N'2016-11-28' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.340' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3237, 6, N'2145', N'2145', NULL, N'', CAST(N'2016-11-29' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.340' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3238, 6, N'2146', N'2146', NULL, N'', CAST(N'2016-11-30' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.343' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3239, 6, N'2147', N'2147', NULL, N'', CAST(N'2016-12-01' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.363' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3240, 6, N'2148', N'2148', NULL, N'', CAST(N'2016-12-02' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.363' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3241, 6, N'2149', N'2149', NULL, N'', CAST(N'2016-12-03' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.367' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3242, 6, N'2150', N'2150', NULL, N'', CAST(N'2016-12-04' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.367' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3243, 6, N'2151', N'2151', NULL, N'', CAST(N'2016-12-05' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.370' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3244, 6, N'2152', N'2152', NULL, N'', CAST(N'2016-12-06' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.370' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3245, 6, N'2153', N'2153', NULL, N'', CAST(N'2016-12-07' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.370' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3246, 6, N'2154', N'2154', NULL, N'', CAST(N'2016-12-08' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.370' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3247, 6, N'2155', N'2155', NULL, N'', CAST(N'2016-12-09' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.373' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3248, 6, N'2156', N'2156', NULL, N'', CAST(N'2016-12-10' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.373' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3249, 6, N'2157', N'2157', NULL, N'', CAST(N'2016-12-11' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.373' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3250, 6, N'2158', N'2158', NULL, N'', CAST(N'2016-12-12' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.377' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3251, 6, N'2159', N'2159', NULL, N'', CAST(N'2016-12-13' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.377' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3252, 6, N'2160', N'2160', NULL, N'', CAST(N'2016-12-14' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.377' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3253, 6, N'2161', N'2161', NULL, N'', CAST(N'2016-12-15' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.380' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3254, 6, N'2162', N'2162', NULL, N'', CAST(N'2016-12-16' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.380' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3255, 6, N'2163', N'2163', NULL, N'', CAST(N'2016-12-17' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.380' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3256, 6, N'2164', N'2164', NULL, N'', CAST(N'2016-12-18' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.380' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3257, 6, N'2165', N'2165', NULL, N'', CAST(N'2016-12-19' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.383' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3258, 6, N'2166', N'2166', NULL, N'', CAST(N'2016-12-20' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.387' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3259, 6, N'2167', N'2167', NULL, N'', CAST(N'2016-12-21' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.387' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3260, 6, N'2168', N'2168', NULL, N'', CAST(N'2016-12-22' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.387' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3261, 6, N'2169', N'2169', NULL, N'', CAST(N'2016-12-23' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.390' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3262, 6, N'2170', N'2170', NULL, N'', CAST(N'2016-12-24' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.390' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3263, 6, N'2171', N'2171', NULL, N'', CAST(N'2016-12-25' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.390' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3264, 6, N'2172', N'2172', NULL, N'', CAST(N'2016-12-26' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.390' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3265, 6, N'2173', N'2173', NULL, N'', CAST(N'2016-12-27' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.393' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3266, 6, N'2174', N'2174', NULL, N'', CAST(N'2016-12-28' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.393' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3267, 6, N'2175', N'2175', NULL, N'', CAST(N'2016-12-29' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.393' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3268, 6, N'2176', N'2176', NULL, N'', CAST(N'2016-12-30' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.397' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3269, 6, N'2177', N'2177', NULL, N'', CAST(N'2016-12-31' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.397' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3270, 6, N'2178', N'2178', NULL, N'', CAST(N'2017-01-01' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.397' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3271, 6, N'2179', N'2179', NULL, N'', CAST(N'2017-01-02' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.400' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3272, 6, N'2180', N'2180', NULL, N'', CAST(N'2017-01-03' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.400' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3273, 6, N'2181', N'2181', NULL, N'', CAST(N'2017-01-04' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.400' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3274, 6, N'2182', N'2182', NULL, N'', CAST(N'2017-01-05' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.400' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3275, 6, N'2183', N'2183', NULL, N'', CAST(N'2017-01-06' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.403' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3276, 6, N'2184', N'2184', NULL, N'', CAST(N'2017-01-07' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.403' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3277, 6, N'2185', N'2185', NULL, N'', CAST(N'2017-01-08' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.403' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3278, 6, N'2186', N'2186', NULL, N'', CAST(N'2017-01-09' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.407' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3279, 6, N'2187', N'2187', NULL, N'', CAST(N'2017-01-10' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.407' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3280, 6, N'2188', N'2188', NULL, N'', CAST(N'2017-01-11' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.407' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3281, 6, N'2189', N'2189', NULL, N'', CAST(N'2017-01-12' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.407' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3282, 6, N'2190', N'2190', NULL, N'', CAST(N'2017-01-13' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.410' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3283, 6, N'2191', N'2191', NULL, N'', CAST(N'2017-01-14' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.410' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3284, 6, N'2192', N'2192', NULL, N'', CAST(N'2017-01-15' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.410' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3285, 6, N'2193', N'2193', NULL, N'', CAST(N'2017-01-16' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.410' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3286, 6, N'2194', N'2194', NULL, N'', CAST(N'2017-01-17' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.413' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3287, 6, N'2195', N'2195', NULL, N'', CAST(N'2017-01-18' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.413' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3288, 6, N'2196', N'2196', NULL, N'', CAST(N'2017-01-19' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.420' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3289, 6, N'2197', N'2197', NULL, N'', CAST(N'2017-01-20' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.420' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3290, 6, N'2198', N'2198', NULL, N'', CAST(N'2017-01-21' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.423' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3291, 6, N'2199', N'2199', NULL, N'', CAST(N'2017-01-22' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.423' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3292, 6, N'2200', N'2200', NULL, N'', CAST(N'2017-01-23' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.433' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3293, 6, N'2201', N'2201', NULL, N'', CAST(N'2017-01-24' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.433' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3294, 6, N'2202', N'2202', NULL, N'', CAST(N'2017-01-25' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.433' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3295, 6, N'2203', N'2203', NULL, N'', CAST(N'2017-01-26' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.437' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3296, 6, N'2204', N'2204', NULL, N'', CAST(N'2017-01-27' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.443' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3297, 6, N'2205', N'2205', NULL, N'', CAST(N'2017-01-28' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.457' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3298, 6, N'2206', N'2206', NULL, N'', CAST(N'2017-01-29' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.460' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3299, 6, N'2207', N'2207', NULL, N'', CAST(N'2017-01-30' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.470' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3300, 6, N'2208', N'2208', NULL, N'', CAST(N'2017-01-31' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.473' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3301, 6, N'2209', N'2209', NULL, N'', CAST(N'2017-02-01' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.477' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3302, 6, N'2210', N'2210', NULL, N'', CAST(N'2017-02-02' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.483' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3303, 6, N'2211', N'2211', NULL, N'', CAST(N'2017-02-03' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.487' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3304, 6, N'2212', N'2212', NULL, N'', CAST(N'2017-02-04' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.490' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3305, 6, N'2213', N'2213', NULL, N'', CAST(N'2017-02-05' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.490' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3306, 6, N'2214', N'2214', NULL, N'', CAST(N'2017-02-06' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.493' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3307, 6, N'2215', N'2215', NULL, N'', CAST(N'2017-02-07' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.497' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3308, 6, N'2216', N'2216', NULL, N'', CAST(N'2017-02-08' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.497' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3309, 6, N'2217', N'2217', NULL, N'', CAST(N'2017-02-09' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.500' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3310, 6, N'2218', N'2218', NULL, N'', CAST(N'2017-02-10' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.500' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3311, 6, N'2219', N'2219', NULL, N'', CAST(N'2017-02-11' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.503' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3312, 6, N'2220', N'2220', NULL, N'', CAST(N'2017-02-12' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.507' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3313, 6, N'2221', N'2221', NULL, N'', CAST(N'2017-02-13' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.507' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3314, 6, N'2222', N'2222', NULL, N'', CAST(N'2017-02-14' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.510' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3315, 6, N'2223', N'2223', NULL, N'', CAST(N'2017-02-15' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.513' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3316, 6, N'2224', N'2224', NULL, N'', CAST(N'2017-02-16' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.513' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3317, 6, N'2225', N'2225', NULL, N'', CAST(N'2017-02-17' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.517' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3318, 6, N'2226', N'2226', NULL, N'', CAST(N'2017-02-18' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.517' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3319, 6, N'2227', N'2227', NULL, N'', CAST(N'2017-02-19' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.520' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3320, 6, N'2228', N'2228', NULL, N'', CAST(N'2017-02-20' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.520' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3321, 6, N'2229', N'2229', NULL, N'', CAST(N'2017-02-21' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.520' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3322, 6, N'2230', N'2230', NULL, N'', CAST(N'2017-02-22' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.523' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3323, 6, N'2231', N'2231', NULL, N'', CAST(N'2017-02-23' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.523' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[CatalogMas] ([CatId], [RefVendorId], [CatCode], [CatName], [CatImg], [CatDescription], [CatLaunchDate], [IsFullset], [IsActive], [RefCatId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3324, 6, N'2232', N'2232', NULL, N'', CAST(N'2017-02-24' AS Date), 0, 1, NULL, NULL, 6, CAST(N'2016-07-08 11:15:45.523' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[CatalogMas] OFF
SET IDENTITY_INSERT [dbo].[CompanyProfile] ON 

INSERT [dbo].[CompanyProfile] ([Id], [CompanyName], [EmailId], [Description], [LogoImg], [AppType], [FolderPath], [WebSite], [AboutUs], [Vision], [Mission], [AppVersion], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3, N'D&G', N'gangadwala@gmail.com', N'Desc DG', NULL, NULL, N'/Images/', N'http://admin.fashiondiva.biz', NULL, NULL, NULL, CAST(1.00 AS Numeric(5, 2)), 1, CAST(N'2016-04-23 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[CompanyProfile] OFF
SET IDENTITY_INSERT [dbo].[DeleteLog] ON 

INSERT [dbo].[DeleteLog] ([DLId], [RefVendorId], [Flag], [RId], [InsUser], [InsDate], [InsTerminal]) VALUES (1, 2, N'Product', 2, 2, CAST(N'2016-06-13 00:00:00.000' AS DateTime), N'127.0.0.1')
INSERT [dbo].[DeleteLog] ([DLId], [RefVendorId], [Flag], [RId], [InsUser], [InsDate], [InsTerminal]) VALUES (2, 2, N'Catalog', 1013, 2, CAST(N'2016-06-13 00:00:00.000' AS DateTime), N'127.0.0.1')
INSERT [dbo].[DeleteLog] ([DLId], [RefVendorId], [Flag], [RId], [InsUser], [InsDate], [InsTerminal]) VALUES (3, 4, N'Catalog', 1048, 4, CAST(N'2016-07-01 14:29:52.790' AS DateTime), N'127.0.0.1')
INSERT [dbo].[DeleteLog] ([DLId], [RefVendorId], [Flag], [RId], [InsUser], [InsDate], [InsTerminal]) VALUES (4, 4, N'Catalog', 2047, 4, CAST(N'2016-07-01 15:54:39.130' AS DateTime), N'127.0.0.1')
INSERT [dbo].[DeleteLog] ([DLId], [RefVendorId], [Flag], [RId], [InsUser], [InsDate], [InsTerminal]) VALUES (5, 4, N'Catalog', 2048, 4, CAST(N'2016-07-01 15:54:42.463' AS DateTime), N'127.0.0.1')
INSERT [dbo].[DeleteLog] ([DLId], [RefVendorId], [Flag], [RId], [InsUser], [InsDate], [InsTerminal]) VALUES (6, 4, N'Product', 1050, 4, CAST(N'2016-07-02 11:47:03.947' AS DateTime), N'127.0.0.1')
INSERT [dbo].[DeleteLog] ([DLId], [RefVendorId], [Flag], [RId], [InsUser], [InsDate], [InsTerminal]) VALUES (7, 4, N'Product', 1051, 4, CAST(N'2016-07-02 11:47:06.630' AS DateTime), N'127.0.0.1')
INSERT [dbo].[DeleteLog] ([DLId], [RefVendorId], [Flag], [RId], [InsUser], [InsDate], [InsTerminal]) VALUES (8, 4, N'Catalog', 2061, 4, CAST(N'2016-07-02 11:47:11.350' AS DateTime), N'127.0.0.1')
INSERT [dbo].[DeleteLog] ([DLId], [RefVendorId], [Flag], [RId], [InsUser], [InsDate], [InsTerminal]) VALUES (9, 2, N'Category', 1057, 2, CAST(N'2016-07-04 11:23:36.317' AS DateTime), N'127.0.0.1')
INSERT [dbo].[DeleteLog] ([DLId], [RefVendorId], [Flag], [RId], [InsUser], [InsDate], [InsTerminal]) VALUES (10, 2, N'Product', 1070, 2, CAST(N'2016-07-04 13:52:32.673' AS DateTime), N'127.0.0.1')
INSERT [dbo].[DeleteLog] ([DLId], [RefVendorId], [Flag], [RId], [InsUser], [InsDate], [InsTerminal]) VALUES (11, 2, N'Catalog', 1018, 2, CAST(N'2016-07-16 16:00:50.967' AS DateTime), N'127.0.0.1')
INSERT [dbo].[DeleteLog] ([DLId], [RefVendorId], [Flag], [RId], [InsUser], [InsDate], [InsTerminal]) VALUES (12, 2, N'Catalog', 1016, 2, CAST(N'2016-07-16 16:11:28.240' AS DateTime), N'127.0.0.1')
SET IDENTITY_INSERT [dbo].[DeleteLog] OFF
SET IDENTITY_INSERT [dbo].[EnquiryList] ON 

INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (1, 1, 2, 1, NULL, N'1000 pice available of this product', N'P', N'azsdasd', CAST(N'2016-05-14 13:58:44.447' AS DateTime), CAST(N'2016-06-07 16:09:02.017' AS DateTime), CAST(N'2016-07-09 17:32:32.653' AS DateTime), NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (3, 1, 2, NULL, 1, N'500 pice available of this product', N'P', NULL, CAST(N'2016-06-08 17:46:35.737' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (4, 2, 2, 3, NULL, N'price ', N'R', N'2000', CAST(N'2016-06-29 18:39:49.117' AS DateTime), CAST(N'2016-07-19 17:44:22.633' AS DateTime), CAST(N'2016-07-19 17:44:12.390' AS DateTime), NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (5, 19, 2, 3, NULL, N'hfhdhf hfjfjf ', N'C', N'OKay', CAST(N'2016-06-29 16:24:02.280' AS DateTime), CAST(N'2016-06-30 11:37:56.430' AS DateTime), NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (6, 2, 2, 5, NULL, N'hi', N'C', N'Yes but what about that not geting', CAST(N'2016-06-29 18:39:41.840' AS DateTime), CAST(N'2016-06-30 11:38:38.160' AS DateTime), NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (7, 3, 2, 5, NULL, N'1000 pice available of this product', N'P', NULL, CAST(N'2016-05-14 15:56:21.980' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (8, 4, 2, 6, NULL, N'nice popup', N'P', NULL, CAST(N'2016-05-17 05:12:21.377' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (9, 3, 2, 6, NULL, N'test remarks', N'P', NULL, CAST(N'2016-06-03 16:54:49.113' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (10, 6, 2, 7, NULL, N'ygfigogog gogogogkg', N'P', NULL, CAST(N'2016-06-15 09:44:55.957' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (11, 5, 2, 7, NULL, N'100 qty price? ', N'P', NULL, CAST(N'2016-06-18 18:41:52.970' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (12, 8, 2, 8, NULL, N'2', N'P', NULL, CAST(N'2016-06-20 16:55:49.133' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (13, 9, 2, 8, NULL, N'100 pieces price', N'P', NULL, CAST(N'2016-06-21 19:15:21.680' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (14, 7, 2, 9, NULL, N'', N'P', NULL, CAST(N'2016-06-21 20:38:47.027' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (15, 7, 2, 9, NULL, N'ndjdjdjddh', N'P', NULL, CAST(N'2016-06-21 20:38:54.063' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (16, 9, 2, 10, NULL, N'available...?', N'P', NULL, CAST(N'2016-06-21 20:39:04.030' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (17, 19, 2, 10, NULL, N'hi', N'P', N'Testing for replay is displaying on screen or not of mobile.', CAST(N'2016-06-21 20:39:06.540' AS DateTime), CAST(N'2016-06-24 11:03:14.693' AS DateTime), NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (18, 19, 2, 11, NULL, N'okay', N'P', NULL, CAST(N'2016-06-21 20:39:23.170' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (19, 19, 2, 12, NULL, N'fine', N'P', N'fine too', CAST(N'2016-06-21 20:39:30.060' AS DateTime), CAST(N'2016-06-24 11:21:57.790' AS DateTime), NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (20, 19, 2, 12, NULL, N'fine', N'P', N'okay', CAST(N'2016-06-23 12:22:05.393' AS DateTime), CAST(N'2016-06-23 12:44:54.847' AS DateTime), NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (21, 19, 2, 13, NULL, N'okay', N'P', NULL, CAST(N'2016-06-23 12:26:07.897' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (23, 8, 2, 13, NULL, N'supply time?', N'P', NULL, CAST(N'2016-06-23 21:22:29.423' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (25, 8, 2, 14, NULL, N'ndjdj dhfhfj', N'P', NULL, CAST(N'2016-06-24 22:21:44.150' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (26, 19, 2, 15, NULL, N'idjtkk', N'P', NULL, CAST(N'2016-06-25 22:18:40.097' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (27, 10, 2, 14, NULL, N'gjjfhf fjjgig', N'R', N'asfasdasd', CAST(N'2016-06-26 20:24:42.807' AS DateTime), CAST(N'2016-07-19 17:45:03.343' AS DateTime), CAST(N'2016-07-19 17:44:58.847' AS DateTime), NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (28, 10, 2, 16, NULL, N'', N'C', N'Blank moklu kem?', CAST(N'2016-06-28 15:51:56.967' AS DateTime), CAST(N'2016-06-28 15:53:51.303' AS DateTime), NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (29, 1, 2, 1067, 21, N'60000', N'P', NULL, CAST(N'2016-07-09 17:34:56.180' AS DateTime), NULL, CAST(N'2016-07-09 17:43:49.510' AS DateTime), NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (30, 1, 2, NULL, 21, N'30000', N'P', NULL, CAST(N'2016-07-09 17:35:27.000' AS DateTime), NULL, CAST(N'2016-07-09 17:43:55.477' AS DateTime), NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (31, 1, 4, NULL, 2062, N'Catalogue Enq.', N'P', NULL, CAST(N'2016-07-09 17:40:04.143' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (32, 1, 4, 1053, 2062, N'Product Enq.', N'P', NULL, CAST(N'2016-07-09 17:40:29.510' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (1029, 1, 4, 1053, 2062, N'Product Enq.', N'P', NULL, CAST(N'2016-08-06 18:23:14.377' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (1030, 1, 4, 1053, 2062, N'Product Enq.', N'P', NULL, CAST(N'2016-08-06 18:24:13.110' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (1031, 1, 4, 1053, 2062, N'Product Enq.', N'P', NULL, CAST(N'2016-08-06 18:25:01.553' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (1032, 1, 4, 1053, 2062, N'Product Enq.', N'P', NULL, CAST(N'2016-08-06 18:25:28.617' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (1033, 1, 4, 1053, 2062, N'Product Enq.', N'P', NULL, CAST(N'2016-08-06 18:28:08.490' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (1034, 1, 4, 1053, 2062, N'Product Enq.', N'P', NULL, CAST(N'2016-08-06 18:28:28.607' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (1035, 1, 4, 1053, 2062, N'Product Enq.', N'P', NULL, CAST(N'2016-08-06 18:36:30.270' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[EnquiryList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [RefCatId], [Remark], [Status], [RepRemark], [EnquiryDate], [EnquiryRepDate], [ReadDateTime], [RefRepAUId]) VALUES (1036, 1, 4, 1053, 2062, N'Product Enq.', N'P', NULL, CAST(N'2016-08-06 18:38:38.143' AS DateTime), NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[EnquiryList] OFF
SET IDENTITY_INSERT [dbo].[ErrLog] ON 

INSERT [dbo].[ErrLog] ([Id], [ErrDate], [ErrCode], [ErrMethod], [ErrDesc], [ErrInternal]) VALUES (1, CAST(N'2016-04-21 12:26:56.423' AS DateTime), N'-2146233088                   ', N'GetAppUser', N'Exception of type ''System.Exception'' was thrown.', NULL)
INSERT [dbo].[ErrLog] ([Id], [ErrDate], [ErrCode], [ErrMethod], [ErrDesc], [ErrInternal]) VALUES (2, CAST(N'2016-04-21 12:27:57.907' AS DateTime), N'FHub                          ', N'GetAppUser', N'Exception of type ''System.Exception'' was thrown.', NULL)
INSERT [dbo].[ErrLog] ([Id], [ErrDate], [ErrCode], [ErrMethod], [ErrDesc], [ErrInternal]) VALUES (3, CAST(N'2016-04-28 12:23:41.833' AS DateTime), N'Newtonsoft.Json               ', N'GetAppUser', N'Value cannot be null.
Parameter name: token', NULL)
INSERT [dbo].[ErrLog] ([Id], [ErrDate], [ErrCode], [ErrMethod], [ErrDesc], [ErrInternal]) VALUES (4, CAST(N'2016-04-28 12:23:50.960' AS DateTime), N'Newtonsoft.Json               ', N'GetAppUser', N'Value cannot be null.
Parameter name: token', NULL)
INSERT [dbo].[ErrLog] ([Id], [ErrDate], [ErrCode], [ErrMethod], [ErrDesc], [ErrInternal]) VALUES (5, CAST(N'2016-04-28 12:28:09.750' AS DateTime), N'Newtonsoft.Json               ', N'GetAppUser', N'Value cannot be null.
Parameter name: token', NULL)
INSERT [dbo].[ErrLog] ([Id], [ErrDate], [ErrCode], [ErrMethod], [ErrDesc], [ErrInternal]) VALUES (6, CAST(N'2016-04-28 12:28:25.430' AS DateTime), N'Newtonsoft.Json               ', N'GetAppUser', N'Value cannot be null.
Parameter name: token', NULL)
INSERT [dbo].[ErrLog] ([Id], [ErrDate], [ErrCode], [ErrMethod], [ErrDesc], [ErrInternal]) VALUES (7, CAST(N'2016-04-28 12:30:23.430' AS DateTime), N'Newtonsoft.Json               ', N'GetAppUser', N'Value cannot be null.
Parameter name: token', NULL)
INSERT [dbo].[ErrLog] ([Id], [ErrDate], [ErrCode], [ErrMethod], [ErrDesc], [ErrInternal]) VALUES (8, CAST(N'2016-04-28 12:40:22.200' AS DateTime), N'Newtonsoft.Json               ', N'GetAppUser', N'Value cannot be null.
Parameter name: token', NULL)
INSERT [dbo].[ErrLog] ([Id], [ErrDate], [ErrCode], [ErrMethod], [ErrDesc], [ErrInternal]) VALUES (9, CAST(N'2016-04-28 13:03:23.117' AS DateTime), N'EntityFramework               ', N'GetAppUser', N'System.Data.SqlClient.SqlException (0x80131904): Cannot insert the value NULL into column ''InsTerminal'', table ''FHubDB.dbo.AppUsers''; column does not allow nulls. INSERT fails.
The statement has been terminated.
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.SqlInternalConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean asyncWrite)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteDbDataReader(CommandBehavior behavior)
   at System.Data.Common.DbCommand.ExecuteReader(CommandBehavior behavior)
   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.<>c__DisplayClassb.<Reader>b__8()
   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TInterceptionContext,TResult](Func`1 operation, TInterceptionContext interceptionContext, Action`1 executing, Action`1 executed)
   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)
   at System.Data.Entity.Internal.InterceptableDbCommand.ExecuteDbDataReader(CommandBehavior behavior)
   at System.Data.Common.DbCommand.ExecuteReader(CommandBehavior behavior)
   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)
ClientConnectionId:2012bc37-8ee2-4493-9c01-dd7691ff8c22
Error Number:515,State:2,Class:16', NULL)
INSERT [dbo].[ErrLog] ([Id], [ErrDate], [ErrCode], [ErrMethod], [ErrDesc], [ErrInternal]) VALUES (10, CAST(N'2016-04-30 10:32:54.400' AS DateTime), N'EntityFramework               ', N'GetAppUser', N'An error occurred while executing the command definition. See the inner exception for details.', N'System.Data.SqlClient.SqlException (0x80131904): Must declare the scalar variable "@vFolderPath".
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.SqlInternalConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean asyncWrite)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteDbDataReader(CommandBehavior behavior)
   at System.Data.Common.DbCommand.ExecuteReader(CommandBehavior behavior)
   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.<>c__DisplayClassb.<Reader>b__8()
   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TInterceptionContext,TResult](Func`1 operation, TInterceptionContext interceptionContext, Action`1 executing, Action`1 executed)
   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)
   at System.Data.Entity.Internal.InterceptableDbCommand.ExecuteDbDataReader(CommandBehavior behavior)
   at System.Data.Common.DbCommand.ExecuteReader(CommandBehavior behavior)
   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)
ClientConnectionId:e612e823-4599-46e0-b12e-f7b1029a7266
Error Number:137,State:2,Class:15')
INSERT [dbo].[ErrLog] ([Id], [ErrDate], [ErrCode], [ErrMethod], [ErrDesc], [ErrInternal]) VALUES (11, CAST(N'2016-04-30 10:34:26.777' AS DateTime), N'EntityFramework               ', N'GetAppUser', N'An error occurred while executing the command definition. See the inner exception for details.', N'System.Data.SqlClient.SqlException (0x80131904): Incorrect syntax near ''/''.
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.SqlInternalConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean asyncWrite)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteDbDataReader(CommandBehavior behavior)
   at System.Data.Common.DbCommand.ExecuteReader(CommandBehavior behavior)
   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.<>c__DisplayClassb.<Reader>b__8()
   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TInterceptionContext,TResult](Func`1 operation, TInterceptionContext interceptionContext, Action`1 executing, Action`1 executed)
   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)
   at System.Data.Entity.Internal.InterceptableDbCommand.ExecuteDbDataReader(CommandBehavior behavior)
   at System.Data.Common.DbCommand.ExecuteReader(CommandBehavior behavior)
   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)
ClientConnectionId:e612e823-4599-46e0-b12e-f7b1029a7266
Error Number:102,State:1,Class:15')
INSERT [dbo].[ErrLog] ([Id], [ErrDate], [ErrCode], [ErrMethod], [ErrDesc], [ErrInternal]) VALUES (12, CAST(N'2016-04-30 10:35:20.530' AS DateTime), N'EntityFramework               ', N'GetAppUser', N'An error occurred while executing the command definition. See the inner exception for details.', N'System.Data.SqlClient.SqlException (0x80131904): Incorrect syntax near ''/''.
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.SqlInternalConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean asyncWrite)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteDbDataReader(CommandBehavior behavior)
   at System.Data.Common.DbCommand.ExecuteReader(CommandBehavior behavior)
   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.<>c__DisplayClassb.<Reader>b__8()
   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TInterceptionContext,TResult](Func`1 operation, TInterceptionContext interceptionContext, Action`1 executing, Action`1 executed)
   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)
   at System.Data.Entity.Internal.InterceptableDbCommand.ExecuteDbDataReader(CommandBehavior behavior)
   at System.Data.Common.DbCommand.ExecuteReader(CommandBehavior behavior)
   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)
ClientConnectionId:e612e823-4599-46e0-b12e-f7b1029a7266
Error Number:102,State:1,Class:15')
INSERT [dbo].[ErrLog] ([Id], [ErrDate], [ErrCode], [ErrMethod], [ErrDesc], [ErrInternal]) VALUES (13, CAST(N'2016-05-03 16:42:03.713' AS DateTime), N'EntityFramework               ', N'GetAppUser', N'An error occurred while executing the command definition. See the inner exception for details.', N'System.Data.SqlClient.SqlException (0x80131904): The INSERT statement conflicted with the FOREIGN KEY constraint "FK_AppLog_Vendor". The conflict occurred in database "FHubDB", table "dbo.Vendor", column ''VendorId''.
The statement has been terminated.
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.SqlInternalConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean asyncWrite)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteDbDataReader(CommandBehavior behavior)
   at System.Data.Common.DbCommand.ExecuteReader(CommandBehavior behavior)
   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.<>c__DisplayClassb.<Reader>b__8()
   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TInterceptionContext,TResult](Func`1 operation, TInterceptionContext interceptionContext, Action`1 executing, Action`1 executed)
   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)
   at System.Data.Entity.Internal.InterceptableDbCommand.ExecuteDbDataReader(CommandBehavior behavior)
   at System.Data.Common.DbCommand.ExecuteReader(CommandBehavior behavior)
   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)
ClientConnectionId:6a0fc90f-bb59-4704-90f4-7035b6866187
Error Number:547,State:0,Class:16')
INSERT [dbo].[ErrLog] ([Id], [ErrDate], [ErrCode], [ErrMethod], [ErrDesc], [ErrInternal]) VALUES (14, CAST(N'2016-08-06 18:23:14.593' AS DateTime), N'FHub                          ', N'   at FHub.Controllers.EnquiryListController.<PostEnquiry>d__8.MoveNext() in d:\FHub\FHub\FHub\Controllers\EnquiryListController.cs:line 159', N'Object reference not set to an instance of an object.', NULL)
INSERT [dbo].[ErrLog] ([Id], [ErrDate], [ErrCode], [ErrMethod], [ErrDesc], [ErrInternal]) VALUES (15, CAST(N'2016-08-06 18:25:23.037' AS DateTime), N'FHub                          ', N'   at FHub.Controllers.EnquiryListController.<PostEnquiry>d__8.MoveNext() in d:\FHub\FHub\FHub\Controllers\EnquiryListController.cs:line 146', N'Object reference not set to an instance of an object.', NULL)
INSERT [dbo].[ErrLog] ([Id], [ErrDate], [ErrCode], [ErrMethod], [ErrDesc], [ErrInternal]) VALUES (16, CAST(N'2016-08-06 18:28:08.660' AS DateTime), N'FHub                          ', N'   at FHub.Controllers.EnquiryListController.<PostEnquiry>d__8.MoveNext() in d:\FHub\FHub\FHub\Controllers\EnquiryListController.cs:line 146', N'Object reference not set to an instance of an object.', NULL)
INSERT [dbo].[ErrLog] ([Id], [ErrDate], [ErrCode], [ErrMethod], [ErrDesc], [ErrInternal]) VALUES (17, CAST(N'2016-08-06 18:36:25.760' AS DateTime), N'FHub                          ', N'   at FHub.Controllers.EnquiryListController.<PostEnquiry>d__8.MoveNext() in d:\FHub\FHub\FHub\Controllers\EnquiryListController.cs:line 146', N'Object reference not set to an instance of an object.', NULL)
INSERT [dbo].[ErrLog] ([Id], [ErrDate], [ErrCode], [ErrMethod], [ErrDesc], [ErrInternal]) VALUES (18, CAST(N'2016-08-06 18:38:36.427' AS DateTime), N'FHub                          ', N'   at FHub.Controllers.EnquiryListController.<PostEnquiry>d__8.MoveNext() in d:\FHub\FHub\FHub\Controllers\EnquiryListController.cs:line 146', N'Object reference not set to an instance of an object.', NULL)
SET IDENTITY_INSERT [dbo].[ErrLog] OFF
SET IDENTITY_INSERT [dbo].[GroupContactList] ON 

INSERT [dbo].[GroupContactList] ([Id], [RefGroupId], [RefAUId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (9, 1, 2, 2, CAST(N'2016-05-24' AS Date), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[GroupContactList] ([Id], [RefGroupId], [RefAUId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (12, 4, 1, 2, CAST(N'2016-05-24' AS Date), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[GroupContactList] ([Id], [RefGroupId], [RefAUId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (14, 4, 3, 2, CAST(N'2016-05-24' AS Date), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[GroupContactList] ([Id], [RefGroupId], [RefAUId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (15, 6, 1, 2, CAST(N'2016-07-04' AS Date), N'127.0.0.1', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[GroupContactList] OFF
SET IDENTITY_INSERT [dbo].[GroupMas] ON 

INSERT [dbo].[GroupMas] ([GroupId], [RefVendorId], [GroupName], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 2, N'Y5D Group', 2, CAST(N'2016-05-24 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-05-25 00:00:00.000' AS DateTime), N'127.0.0.1')
INSERT [dbo].[GroupMas] ([GroupId], [RefVendorId], [GroupName], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, N'GD Group', 2, CAST(N'2016-05-24 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[GroupMas] ([GroupId], [RefVendorId], [GroupName], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, N'Dress Group', 2, CAST(N'2016-05-24 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[GroupMas] ([GroupId], [RefVendorId], [GroupName], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 2, N'3D Group', 2, CAST(N'2016-05-25 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-05-25 00:00:00.000' AS DateTime), N'127.0.0.1')
INSERT [dbo].[GroupMas] ([GroupId], [RefVendorId], [GroupName], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, 2, N'Dress Diller', 2, CAST(N'2016-07-04 12:55:31.540' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-04 12:55:41.267' AS DateTime), N'127.0.0.1')
SET IDENTITY_INSERT [dbo].[GroupMas] OFF
SET IDENTITY_INSERT [dbo].[MastersList] ON 

INSERT [dbo].[MastersList] ([Id], [MasterName], [OrdNo], [IsSystem]) VALUES (1, N'Brand', CAST(1.00 AS Numeric(5, 2)), 1)
INSERT [dbo].[MastersList] ([Id], [MasterName], [OrdNo], [IsSystem]) VALUES (2, N'Color', CAST(2.00 AS Numeric(5, 2)), 1)
INSERT [dbo].[MastersList] ([Id], [MasterName], [OrdNo], [IsSystem]) VALUES (3, N'ProdType', CAST(3.00 AS Numeric(5, 2)), 1)
INSERT [dbo].[MastersList] ([Id], [MasterName], [OrdNo], [IsSystem]) VALUES (4, N'Size', CAST(4.00 AS Numeric(5, 2)), 1)
INSERT [dbo].[MastersList] ([Id], [MasterName], [OrdNo], [IsSystem]) VALUES (5, N'Fabric', CAST(5.00 AS Numeric(5, 2)), 1)
INSERT [dbo].[MastersList] ([Id], [MasterName], [OrdNo], [IsSystem]) VALUES (6, N'Design', CAST(6.00 AS Numeric(5, 2)), 1)
INSERT [dbo].[MastersList] ([Id], [MasterName], [OrdNo], [IsSystem]) VALUES (7, N'Role', CAST(7.00 AS Numeric(5, 2)), 0)
SET IDENTITY_INSERT [dbo].[MastersList] OFF
SET IDENTITY_INSERT [dbo].[MasterValue] ON 

INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 1, 19, N'Red', NULL, CAST(0.00 AS Numeric(5, 2)), 0, 1, CAST(N'2016-04-21 17:29:22.460' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 1, 20, N'Size 0', N'Desc Size', CAST(0.00 AS Numeric(5, 2)), 0, 1, CAST(N'2016-04-21 17:36:18.090' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, 1021, N'Red', N'#ff0000', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-02 13:44:04.993' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-03 11:35:55.543' AS DateTime), N'127.0.0.1')
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, 1022, N'Green', N'#3ee22f', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-02 13:44:19.993' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-03 11:33:37.597' AS DateTime), N'127.0.0.1')
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, 1023, N'Blue', N'#1d3ad3', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-02 13:44:31.327' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-13 12:03:56.777' AS DateTime), N'127.0.0.1')
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, 1024, N'Yellow', N'#faff16', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-02 13:44:44.080' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-03 11:36:40.833' AS DateTime), N'127.0.0.1')
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, 1025, N'Black', N'#000000', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-02 13:44:54.543' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-03 11:31:00.530' AS DateTime), N'127.0.0.1')
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, 1026, N'Maroon', N'#aa2727', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-02 13:45:06.193' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-03 11:34:39.707' AS DateTime), N'127.0.0.1')
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, 1027, N'purple', N'#b31ccc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-02 13:45:29.680' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-03 11:35:46.277' AS DateTime), N'127.0.0.1')
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1028, N'X', N'Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-02 14:45:52.343' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1029, N'XL', N'Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-02 14:46:02.727' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1030, N'XXL', N'Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-02 14:46:10.847' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1031, N'30', N'Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-02 14:46:18.960' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1032, N'40', N'Descs', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-02 14:46:26.353' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1033, N'45', N'Description of size 45', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-02 14:46:48.580' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1034, N'M', N'Medium', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-02 14:47:03.333' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1035, N'S', N'Small', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-02 14:47:09.220' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1036, N'L', N'Large', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-02 14:47:17.337' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, 1037, N'Pink', N'#ff059b', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-02 17:51:22.753' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-03 11:35:35.750' AS DateTime), N'127.0.0.1')
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3, 2, 1038, N'Stitched', N'Stitched Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:30:50.590' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3, 2, 1039, N'Semi Stitched', N'Semi Stitched Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:31:11.610' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3, 2, 1040, N'UnStitched', N'UnStitched Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:31:24.183' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-03 09:35:26.227' AS DateTime), N'127.0.0.1')
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 2, 1041, N'Georgette', N'Georgette Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:36:04.910' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 2, 1042, N'Chiffon', N'Chiffon Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:36:24.563' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 2, 1043, N'Faux Georgette', N'Faux Georgette Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:36:41.040' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 2, 1044, N'Silk', N'Silk Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:36:57.403' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 2, 1045, N'Cotton', N'Cotton DEsc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:37:11.097' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 2, 1046, N'Bhagalpuri Silk', N'Bhagalpuri Silk Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:37:27.240' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 2, 1047, N'Art Silk', N'Art Silk Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:37:40.787' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 2, 1048, N'Net', N'Net Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:37:55.290' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 2, 1049, N'Crepe', N'Crepe Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:38:10.500' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, 2, 1050, N'Embellised', N'Embellised Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:39:54.747' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, 2, 1051, N'Embroidered', N'Embroidered Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:40:04.877' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, 2, 1052, N'Plain', N'Plain Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:40:15.780' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, 2, 1053, N'Printed', N'Printed Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:40:25.637' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1054, N'XS', N'Extra Small', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:55:12.160' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1055, N'Free', N'Free Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:55:31.627' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1056, N'44', N'Description', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:55:43.623' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1057, N'38', N'Description', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:55:53.900' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1058, N'36', N'36 Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:56:53.400' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1059, N'46', N'46 Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:57:04.720' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1060, N'34', N'34 Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:57:14.793' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1061, N'48', N'48 Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:57:24.747' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1062, N'10', N'10 Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:57:34.763' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1063, N'XXS', N'XXS Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:58:08.503' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1064, N'XXXL', N'XXXL Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:58:18.140' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1065, N'XXXS', N'XXXS Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:58:29.590' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1066, N'20', N'20 Desc', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:58:54.760' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, 1067, N'White', N'#ffffff', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:59:21.597' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-03 11:36:29.573' AS DateTime), N'127.0.0.1')
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, 1068, N'Orange', N'#ce6921', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 09:59:39.793' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-03 11:35:17.930' AS DateTime), N'127.0.0.1')
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, 1069, N'Cream', N'#c98b30', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 10:00:00.873' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-11 11:57:45.313' AS DateTime), N'127.0.0.1')
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, 1070, N'Gray', N'#756363', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 10:00:09.017' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-03 11:33:29.540' AS DateTime), N'127.0.0.1')
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, 1071, N'Brown', N'#8e3636', CAST(3.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 10:00:16.580' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-11 11:57:24.343' AS DateTime), N'127.0.0.1')
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, 1072, N'Navy Blue', N'#160c89', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 10:00:42.420' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-03 11:34:59.400' AS DateTime), N'127.0.0.1')
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, 1073, N'Light Blue', N'#00b2ff', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 10:01:06.393' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-03 11:34:26.590' AS DateTime), N'127.0.0.1')
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, 1074, N'Magenta', N'#941f96', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 10:01:26.600' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-03 11:33:50.527' AS DateTime), N'127.0.0.1')
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, 1075, N'Golden', N'#d6b60e', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 10:01:57.987' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-03 11:32:27.953' AS DateTime), N'127.0.0.1')
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, 1076, N'Silver', N'#bfb5bd', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 10:02:08.410' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-03 11:36:17.683' AS DateTime), N'127.0.0.1')
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, 1077, N'Olive', N'#bcbf26', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 10:02:35.860' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-03 11:35:08.093' AS DateTime), N'127.0.0.1')
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, 1078, N'Dark Pink', N'#d121ca', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 10:03:12.420' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-03 11:32:15.467' AS DateTime), N'127.0.0.1')
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 2, 1079, N'NALLI SILK SAREES', N'NALLI SILK SAREES', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 12:05:06.467' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 2, 1080, N'MEENA BAZAAR SAREES', N'MEENA BAZAAR SAREES', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 12:05:18.323' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 2, 1081, N' KALANJALI SAREES', N' KALANJALI SAREES', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 12:05:27.300' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 2, 1082, N'BOMBAY SELECTIONS PRIVATE LTD', N'BOMBAY SELECTIONS PRIVATE LTD', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 12:05:36.240' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 2, 1083, N'SATYA PAUL', N'SATYA PAUL', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 12:05:45.783' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 2, 1084, N' KALAMANDIR', N' KALAMANDIR', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 12:05:56.700' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 2, 1085, N'KALANIKETAN', N'KALANIKETAN', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 12:06:08.577' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 2, 1086, N' DEEPAM', N' DEEPAM', CAST(1.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 12:06:21.143' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-11 10:07:34.210' AS DateTime), N'127.0.0.1')
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 2, 1087, N'FAB INDIA', N'FAB INDIA', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 12:06:30.067' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 2, 1088, N'GAURANG', N'GAURANG', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 12:06:39.467' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 2, 1089, N'Manish Malhotra', N'Manish Malhotra', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 12:07:33.127' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 2, 1090, N'Sabyasachi Mukherjee', N'Sabyasachi Mukherjee', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 12:07:44.657' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 2, 1091, N'Tarun Tahiliani', N'Tarun Tahiliani', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 12:08:00.080' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 2, 1092, N'Ritu Kumar', N'Ritu Kumar', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 12:08:30.073' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 2, 1093, N'J.J Valaya', N'J.J Valaya', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 12:09:16.910' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 2, 1094, N'Neeta Lulla', N'Neeta Lulla', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-03 12:09:33.767' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (7, 0, 1095, N'Vendor', N'Vendor', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-16 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (7, 0, 1096, N'Admin', N'Admin', CAST(0.00 AS Numeric(5, 2)), 1, 1, CAST(N'2016-05-16 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 4, 1097, N'Yellow', N'#f2e90e', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-06-27 11:03:04.290' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 4, 1098, N'Blue', N'#175ee8', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-06-27 11:03:21.043' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 4, 1099, N'Black', N'#000000', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-06-27 12:04:32.247' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 4, 1100, N'Green', N'#3ee22f', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-06-27 12:05:25.340' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 4, 1101, N'Red', N'#ff0000', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-06-27 12:06:50.043' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 4, 1102, N'Maroon', N'#aa2727', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-06-27 12:10:33.690' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 4, 1103, N'Pink', N'#ff059b', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-06-27 12:11:56.007' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 4, 1104, N'Orange', N'#ce6921', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-06-27 12:14:08.330' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 4, 1105, N'White', N'#ffffff', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-06-27 12:19:02.413' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 4, 1106, N'purple', N'#b31ccc', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-06-27 12:21:24.197' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 4, 1107, N'Gray', N'#756363', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-06-27 12:23:22.107' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 4, 1108, N'Navy Blue', N'#160c89', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-06-27 12:26:18.103' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 4, 1109, N'Magenta', N'#941f96', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-06-27 12:26:24.420' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 4, 1110, N'BOMBAY SELECTIONS PRIVATE LTD', N'BOMBAY SELECTIONS PRIVATE LTD', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-06-27 12:26:58.370' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 4, 1111, N'KALANIKETAN', N'KALANIKETAN', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-06-27 12:27:00.180' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 4, 1112, N'GAURANG', N'GAURANG', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-06-27 12:27:01.900' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 4, 1113, N'Sabyasachi Mukherjee', N'Sabyasachi Mukherjee', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-06-27 12:29:33.687' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 4, 1114, N'Manish Malhotra', N'Manish Malhotra', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-06-27 14:41:58.253' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 4, 1115, N' KALANJALI SAREES', N' KALANJALI SAREES', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-06-27 14:47:02.173' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 4, 1116, N'20', N'20 Desc', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-07-01 10:53:50.627' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 4, 1117, N'Golden', N'#d6b60e', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-07-01 11:07:33.027' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
GO
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 4, 1118, N'30', N'Desc', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-07-01 11:08:01.207' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 4, 1119, N'40', N'Descs', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-07-01 11:08:03.483' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3, 4, 1120, N'Semi Stitched', N'Semi Stitched Desc', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-07-01 11:26:26.423' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 4, 1121, N'Silk', N'Silk Desc', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-07-01 11:26:35.973' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 4, 1122, N'Cotton', N'Cotton DEsc', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-07-01 11:26:42.963' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 4, 1123, N'Georgette', N'Georgette Desc', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-07-01 11:26:51.693' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, 4, 1124, N'Embellised', N'Embellised Desc', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-07-01 11:27:28.470' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, 4, 1125, N'Embroidered', N'Embroidered Desc', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-07-01 11:27:33.667' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, 4, 1126, N'Plain', N'Plain Desc', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-07-01 11:27:39.773' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 4, 2120, N'Chiffon', N'Chiffon Desc', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-07-01 14:39:14.597' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, 4, 2121, N'Printed', N'Printed Desc', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-07-01 14:39:28.090' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 4, 2122, N'45', N'Description of size 45', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-07-01 16:23:03.127' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 4, 2123, N'Art Silk', N'Art Silk Desc', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-07-01 16:23:29.713' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 4, 2124, N'Silver', N'#bfb5bd', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-07-01 16:37:07.480' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 6, 2125, N' KALANJALI SAREES', N' KALANJALI SAREES', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-01 18:06:19.080' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 6, 2126, N'Yellow', N'#f2e90e', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-01 18:20:24.873' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 6, 2127, N'Blue', N'#175ee8', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-01 18:20:59.487' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 6, 2128, N'Manish Malhotra', N'Manish Malhotra', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-01 18:33:14.180' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 6, 2129, N'Sabyasachi Mukherjee', N'Sabyasachi Mukherjee', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-01 18:33:33.817' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 6, 2130, N'GAURANG', N'GAURANG', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-01 18:33:34.560' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 6, 2131, N'KALANIKETAN', N'KALANIKETAN', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-01 18:33:35.157' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 6, 2132, N'BOMBAY SELECTIONS PRIVATE LTD', N'BOMBAY SELECTIONS PRIVATE LTD', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-01 18:33:35.750' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 6, 2133, N'Black', N'#000000', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-01 18:35:13.590' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 6, 2134, N'Green', N'#3ee22f', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-01 18:35:14.077' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 6, 2135, N'Maroon', N'#aa2727', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-01 18:35:15.123' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 6, 2136, N'White', N'#ffffff', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-01 18:35:15.650' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 6, 2137, N'Pink', N'#ff059b', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-01 18:35:25.877' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 6, 2138, N'purple', N'#b31ccc', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-01 18:35:26.630' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 6, 2139, N'Silver', N'#bfb5bd', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-01 18:35:27.120' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 6, 2140, N'20', N'20 Desc', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-02 11:39:44.773' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 6, 2141, N'30', N'Desc', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-02 11:39:45.153' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 6, 2142, N'40', N'Descs', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-02 11:39:45.750' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 6, 2143, N'45', N'Description of size 45', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-02 11:39:46.807' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3, 6, 2144, N'Semi Stitched', N'Semi Stitched Desc', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-02 11:52:44.997' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 6, 2145, N'Art Silk', N'Art Silk Desc', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-02 11:52:58.680' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 6, 2146, N'Chiffon', N'Chiffon Desc', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-02 11:53:10.373' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, 6, 2147, N'Embellised', N'Embellised Desc', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-02 11:53:18.240' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, 6, 2148, N'Embroidered', N'Embroidered Desc', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-02 11:53:24.540' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 4, 2149, N'Dark Pink', N'#d121ca', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-07-06 10:12:56.443' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 4, 2150, N'38', N'Description', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-07-06 10:13:02.430' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 4, 2151, N'36', N'36 Desc', CAST(0.00 AS Numeric(5, 2)), 1, 4, CAST(N'2016-07-06 10:13:03.760' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 6, 2152, N'Georgette', N'Georgette Desc', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-07 13:36:57.600' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 6, 2153, N'Cotton', N'Cotton DEsc', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-07 13:37:00.853' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 6, 2154, N'Silk', N'Silk Desc', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-07 13:37:01.600' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, 6, 2155, N'Plain', N'Plain Desc', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-07 13:37:05.370' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MasterValue] ([RefMasterId], [RefVendorId], [ID], [ValueName], [ValueDesc], [OrdNo], [IsActive], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, 6, 2156, N'Printed', N'Printed Desc', CAST(0.00 AS Numeric(5, 2)), 1, 6, CAST(N'2016-07-07 13:37:06.040' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[MasterValue] OFF
SET IDENTITY_INSERT [dbo].[MenuMaster] ON 

INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (1, N'Setup', N'Setup', 1, NULL, CAST(4.00 AS Numeric(5, 2)), NULL, NULL, NULL, N'fa fa-cogs')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (2, N'Brand', N'Brand', 1, 1, CAST(4.00 AS Numeric(5, 2)), NULL, NULL, N'editSessionMasterID(''1'')', N'fa fa-btc')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (3, N'Color', N'Color', 1, 1, CAST(4.00 AS Numeric(5, 2)), NULL, NULL, N'editSessionMasterID(''2'')', N'fa fa-paint-brush')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (4, N'Type', N'Type', 1, 1, CAST(4.00 AS Numeric(5, 2)), NULL, NULL, N'editSessionMasterID(''3'')', N'fa fa-try')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (5, N'Size', N'Size', 1, 1, CAST(4.00 AS Numeric(5, 2)), NULL, NULL, N'editSessionMasterID(''4'')', N'fa fa-arrows-alt')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (6, N'Fabric', N'Fabric', 1, 1, CAST(4.00 AS Numeric(5, 2)), NULL, NULL, N'editSessionMasterID(''5'')', N'fa fa-yelp')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (7, N'Design', N'Design', 1, 1, CAST(4.00 AS Numeric(5, 2)), NULL, NULL, N'editSessionMasterID(''6'')', N'fa  fa-gg')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (8, N'Products', N'Products', 1, NULL, CAST(3.00 AS Numeric(5, 2)), NULL, NULL, NULL, N'fa fa-paypal')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (9, N'Vendor', N'Vendor', 1, 17, CAST(7.00 AS Numeric(5, 2)), N'Vendor', N'Index', NULL, N'fa  fa-user')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (11, N'Category', N'Category', 1, 8, CAST(3.00 AS Numeric(5, 2)), N'ProductCategory', N'Index', NULL, N'fa fa-th')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (12, N'Catalogue', N'Catalogue', 1, 8, CAST(3.00 AS Numeric(5, 2)), N'Catalog', N'Index', NULL, N'fa fa-delicious')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (13, N'Product', N'Product', 1, 8, CAST(3.00 AS Numeric(5, 2)), N'Product', N'Index', NULL, N'fa fa-rub')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (14, N'Banners', N'Banners', 1, 18, CAST(6.00 AS Numeric(5, 2)), N'VendorSlider', N'Index', NULL, N'fa fa-image (alias)')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (15, N'Role Rights', N'Role Rights', 1, 17, CAST(7.00 AS Numeric(5, 2)), N'MenuRoleRights', N'Index', NULL, N'fa fa-user-secret')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (16, N'Dashboard', N'Dashboard', 1, NULL, CAST(1.00 AS Numeric(5, 2)), N'Home', N'Index', NULL, N'fa fa-dashboard (alias)')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (17, N'Admin', N'Admin', 1, NULL, CAST(7.00 AS Numeric(5, 2)), NULL, NULL, NULL, N'fa fa-buysellads')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (18, N'Marketing', N'Marketing', 1, NULL, CAST(6.00 AS Numeric(5, 2)), NULL, NULL, NULL, N'fa fa-medium')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (20, N'Notification', N'Notification', 1, 18, CAST(6.00 AS Numeric(5, 2)), N'Notification', N'Index', NULL, N'fa fa-flag')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (22, N'Customer', N'Customer', 1, NULL, CAST(5.00 AS Numeric(5, 2)), NULL, NULL, NULL, N'fa fa-phone-square')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (23, N'Customers', N'Customers', 1, 22, CAST(5.00 AS Numeric(5, 2)), N'Contact', N'Index', NULL, N'fa fa-list-alt')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (24, N'Group', N'Group', 1, 22, CAST(5.00 AS Numeric(5, 2)), N'ContactGroup', N'Index', NULL, N'fa fa-group (alias)')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (25, N'Product Enquiry', N'Product Enquiry', 1, 18, CAST(6.00 AS Numeric(5, 2)), N'Enquiry', N'Index', NULL, N'fa fa-envelope')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (26, N'Stores', N'Stores', 1, 1028, CAST(2.10 AS Numeric(5, 2)), N'StoreAssociation', N'Index', NULL, N'fa fa-strikethrough')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (27, N'Download Catalogues', N'Download Catalogues', 1, 1028, CAST(2.30 AS Numeric(5, 2)), N'ProductMerge', N'Index', NULL, N' fa fa-download')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (29, N'Parameter Mapping', N'Parameter Mapping', 1, 1028, CAST(2.20 AS Numeric(5, 2)), N'ParameterMapping', N'Index', NULL, N'fa fa-map')
INSERT [dbo].[MenuMaster] ([ID], [MenuName], [MenuDes], [IsActive], [ParentMenuID], [OrderNo], [ControllerName], [ActionName], [MenuPath], [MenuIcon]) VALUES (1028, N'Connect Store', N'Connect Store', 1, NULL, CAST(2.00 AS Numeric(5, 2)), NULL, NULL, NULL, N'fa  fa-chain')
SET IDENTITY_INSERT [dbo].[MenuMaster] OFF
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 1, 0, 0, 0, 1, 0, CAST(N'2016-07-11 17:52:02.397' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 2, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:52:02.400' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 3, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:52:02.403' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 4, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:52:02.410' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 5, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:52:02.413' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 6, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:52:02.420' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 7, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:52:02.443' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 8, 0, 0, 0, 1, 0, CAST(N'2016-07-11 17:52:02.360' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 9, 0, 0, 0, 0, 0, CAST(N'2016-07-11 17:52:02.500' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 11, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:52:02.363' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 12, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:52:02.390' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 13, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:52:02.393' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 14, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:52:02.477' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 15, 0, 0, 0, 0, 0, CAST(N'2016-07-11 17:52:02.513' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 16, 0, 0, 0, 1, 0, CAST(N'2016-07-11 17:52:02.280' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 17, 0, 0, 0, 0, 0, CAST(N'2016-07-11 17:52:02.483' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 18, 0, 0, 0, 1, 0, CAST(N'2016-07-11 17:52:02.453' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 20, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:52:02.467' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 22, 0, 0, 0, 1, 0, CAST(N'2016-07-11 17:52:02.443' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 23, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:52:02.447' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 24, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:52:02.450' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 25, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:52:02.473' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 26, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:52:02.310' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 27, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:52:02.317' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 29, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:52:02.350' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1095, 1028, 0, 0, 0, 1, 0, CAST(N'2016-07-11 17:52:02.293' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 1, 0, 0, 0, 1, 0, CAST(N'2016-07-11 17:51:01.800' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 2, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:51:01.800' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 3, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:51:01.800' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 4, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:51:01.800' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 5, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:51:01.800' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 6, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:51:01.820' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 7, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:51:01.823' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 8, 0, 0, 0, 1, 0, CAST(N'2016-07-11 17:51:01.783' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 9, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:51:01.837' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 11, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:51:01.797' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 12, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:51:01.800' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 13, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:51:01.800' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 14, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:51:01.833' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 15, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:51:01.840' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 16, 0, 0, 0, 1, 0, CAST(N'2016-07-11 17:51:01.753' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 17, 0, 0, 0, 1, 0, CAST(N'2016-07-11 17:51:01.837' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 18, 0, 0, 0, 1, 0, CAST(N'2016-07-11 17:51:01.830' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 20, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:51:01.830' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 22, 0, 0, 0, 1, 0, CAST(N'2016-07-11 17:51:01.827' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 23, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:51:01.827' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 24, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:51:01.830' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 25, 0, 0, 0, 0, 0, CAST(N'2016-07-11 17:51:01.833' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 26, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:51:01.773' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 27, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:51:01.780' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 29, 1, 1, 1, 1, 0, CAST(N'2016-07-11 17:51:01.780' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[MenuRoleRights] ([RefRoleId], [RefMenuId], [CanInsert], [CanUpdate], [CanDelete], [CanView], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1096, 1028, 0, 0, 0, 1, 0, CAST(N'2016-07-11 17:51:01.760' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[NotificationDet] ON 

INSERT [dbo].[NotificationDet] ([NotifyDetId], [RefNotifyId], [RefAppUserId], [Status], [Response], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 10, 2, N'Pending', NULL, N'2         ', CAST(N'2016-07-09 10:11:01.133' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[NotificationDet] ([NotifyDetId], [RefNotifyId], [RefAppUserId], [Status], [Response], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 12, 2, N'Pending', NULL, N'2         ', CAST(N'2016-07-09 10:29:37.257' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[NotificationDet] ([NotifyDetId], [RefNotifyId], [RefAppUserId], [Status], [Response], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3, 13, 1, N'Pending', NULL, N'2         ', CAST(N'2016-07-09 10:33:34.460' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[NotificationDet] ([NotifyDetId], [RefNotifyId], [RefAppUserId], [Status], [Response], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 13, 3, N'Pending', NULL, N'2         ', CAST(N'2016-07-09 10:33:34.463' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[NotificationDet] ([NotifyDetId], [RefNotifyId], [RefAppUserId], [Status], [Response], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 13, 6, N'Pending', NULL, N'2         ', CAST(N'2016-07-09 10:33:34.463' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[NotificationDet] OFF
SET IDENTITY_INSERT [dbo].[NotificationMas] ON 

INSERT [dbo].[NotificationMas] ([NotifyId], [RefVendorId], [NotifyDate], [RefGroupId], [RefAppUserId], [Message], [ImgPath], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 0, CAST(N'0001-01-01' AS Date), N'1,2', NULL, N'Testing Message', NULL, 2, CAST(N'2016-06-02 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[NotificationMas] ([NotifyId], [RefVendorId], [NotifyDate], [RefGroupId], [RefAppUserId], [Message], [ImgPath], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, CAST(N'2016-06-02' AS Date), N'1,5', NULL, N'Testing MEssage........', NULL, 2, CAST(N'2016-06-02 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[NotificationMas] ([NotifyId], [RefVendorId], [NotifyDate], [RefGroupId], [RefAppUserId], [Message], [ImgPath], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3, 2, CAST(N'2016-06-03' AS Date), N'2,4', NULL, N'Testing Second Notification...............', NULL, 2, CAST(N'2016-06-03 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[NotificationMas] ([NotifyId], [RefVendorId], [NotifyDate], [RefGroupId], [RefAppUserId], [Message], [ImgPath], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, CAST(N'2016-06-03' AS Date), N'1,2', N'1,3', N'Third Testing', NULL, 2, CAST(N'2016-06-03 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[NotificationMas] ([NotifyId], [RefVendorId], [NotifyDate], [RefGroupId], [RefAppUserId], [Message], [ImgPath], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 2, CAST(N'2016-06-03' AS Date), N'1,2,5', N'1,3', N'4th Testing of notification', NULL, 2, CAST(N'2016-06-03 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[NotificationMas] ([NotifyId], [RefVendorId], [NotifyDate], [RefGroupId], [RefAppUserId], [Message], [ImgPath], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, 4, CAST(N'2016-06-03' AS Date), NULL, N'1,3', N'Notification Testing', NULL, 4, CAST(N'2016-06-03 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[NotificationMas] ([NotifyId], [RefVendorId], [NotifyDate], [RefGroupId], [RefAppUserId], [Message], [ImgPath], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (9, 2, CAST(N'2016-06-06' AS Date), N'2,4', N'2', N'Testing of det table entry', NULL, 2, CAST(N'2016-06-06 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[NotificationMas] ([NotifyId], [RefVendorId], [NotifyDate], [RefGroupId], [RefAppUserId], [Message], [ImgPath], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (10, 2, CAST(N'2016-07-09' AS Date), N'1', NULL, N'50', NULL, 2, CAST(N'2016-07-09 10:11:01.040' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[NotificationMas] ([NotifyId], [RefVendorId], [NotifyDate], [RefGroupId], [RefAppUserId], [Message], [ImgPath], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (11, 2, CAST(N'2016-07-09' AS Date), N'2', NULL, N'222', NULL, 2, CAST(N'2016-07-09 10:11:46.530' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[NotificationMas] ([NotifyId], [RefVendorId], [NotifyDate], [RefGroupId], [RefAppUserId], [Message], [ImgPath], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (12, 2, CAST(N'2016-07-09' AS Date), N'2', N'2', N'sfsdfsdf', NULL, 2, CAST(N'2016-07-09 10:29:37.207' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[NotificationMas] ([NotifyId], [RefVendorId], [NotifyDate], [RefGroupId], [RefAppUserId], [Message], [ImgPath], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (13, 2, CAST(N'2016-07-09' AS Date), N'4', N'6', N'sefsdfs', NULL, 2, CAST(N'2016-07-09 10:33:34.460' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[NotificationMas] OFF
SET IDENTITY_INSERT [dbo].[ParameterMapping] ON 

INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, 4, 1100, 2, 1022, 4, CAST(N'2016-06-27 12:05:25.363' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3, 2, 4, 1101, 2, 1021, 4, CAST(N'2016-06-27 12:06:59.207' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 4, 1102, 2, 1026, 4, CAST(N'2016-06-27 12:10:33.703' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 2, 4, 1103, 2, 1037, 4, CAST(N'2016-06-27 12:11:56.020' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, 2, 4, 1104, 2, 1068, 4, CAST(N'2016-06-27 12:14:08.357' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (7, 2, 4, 1105, 2, 1067, 4, CAST(N'2016-06-27 12:19:03.220' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (8, 2, 4, 1106, 2, 1027, 4, CAST(N'2016-06-27 12:21:25.397' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (9, 2, 4, 1107, 2, 1070, 4, CAST(N'2016-06-27 12:23:22.127' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (10, 2, 4, 1108, 2, 1072, 4, CAST(N'2016-06-27 12:26:18.117' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (11, 2, 4, 1109, 2, 1074, 4, CAST(N'2016-06-27 12:26:24.430' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (13, 1, 4, 1111, 2, 1085, 4, CAST(N'2016-06-27 12:27:00.197' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (14, 1, 4, 1112, 2, 1088, 4, CAST(N'2016-06-27 12:27:01.913' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (15, 1, 4, 1113, 2, 1090, 4, CAST(N'2016-06-27 12:29:33.700' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (16, 1, 4, 1114, 2, 1089, 4, CAST(N'2016-06-27 14:41:59.320' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (20, 1, 4, 1110, 2, 1082, 4, CAST(N'2016-06-27 15:50:15.503' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (21, 1, 4, 1115, 2, 1083, 4, CAST(N'2016-06-27 16:23:16.910' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (22, 1, 4, 1110, 2, 1081, 4, CAST(N'2016-06-27 16:47:28.910' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (23, 1, 4, 1115, 2, 1086, 4, CAST(N'2016-06-27 17:42:58.883' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (25, 4, 4, 1116, 2, 1066, 4, CAST(N'2016-07-01 10:53:50.680' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (26, 2, 4, 1099, 2, 1025, 4, CAST(N'2016-07-01 11:04:15.587' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (27, 2, 4, 1117, 2, 1075, 4, CAST(N'2016-07-01 11:07:33.037' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (28, 2, 4, 1098, 2, 1023, 4, CAST(N'2016-07-01 11:07:47.040' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (29, 4, 4, 1118, 2, 1031, 4, CAST(N'2016-07-01 11:08:01.220' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (30, 4, 4, 1119, 2, 1032, 4, CAST(N'2016-07-01 11:08:03.500' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (31, 3, 4, 1120, 2, 1039, 4, CAST(N'2016-07-01 11:26:26.447' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (32, 5, 4, 1121, 2, 1044, 4, CAST(N'2016-07-01 11:26:35.987' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (33, 5, 4, 1122, 2, 1045, 4, CAST(N'2016-07-01 11:26:42.983' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (34, 5, 4, 1123, 2, 1041, 4, CAST(N'2016-07-01 11:26:51.707' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (35, 6, 4, 1124, 2, 1050, 4, CAST(N'2016-07-01 11:27:28.480' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (36, 6, 4, 1125, 2, 1051, 4, CAST(N'2016-07-01 11:27:33.693' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (37, 6, 4, 1126, 2, 1052, 4, CAST(N'2016-07-01 11:27:39.783' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1031, 2, 4, 1097, 2, 1024, 4, CAST(N'2016-07-01 14:38:47.997' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1032, 5, 4, 2120, 2, 1042, 4, CAST(N'2016-07-01 14:39:14.617' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1033, 6, 4, 2121, 2, 1053, 4, CAST(N'2016-07-01 14:39:28.100' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1034, 4, 4, 2122, 2, 1033, 4, CAST(N'2016-07-01 16:23:03.150' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1035, 5, 4, 2123, 2, 1047, 4, CAST(N'2016-07-01 16:23:29.787' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1036, 2, 4, 2124, 2, 1076, 4, CAST(N'2016-07-01 16:37:07.490' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1038, 2, 6, 2126, 4, 1097, 6, CAST(N'2016-07-01 18:20:24.887' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1040, 2, 6, 2127, 4, 1098, 6, CAST(N'2016-07-01 18:20:59.490' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1050, 2, 6, 2133, 4, 1099, 6, CAST(N'2016-07-01 18:35:13.590' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1051, 2, 6, 2134, 4, 1100, 6, CAST(N'2016-07-01 18:35:14.080' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1052, 2, 6, 2135, 4, 1102, 6, CAST(N'2016-07-01 18:35:15.123' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1053, 2, 6, 2136, 4, 1105, 6, CAST(N'2016-07-01 18:35:15.650' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1054, 2, 6, 2137, 4, 1103, 6, CAST(N'2016-07-01 18:35:25.877' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1055, 2, 6, 2138, 4, 1106, 6, CAST(N'2016-07-01 18:35:26.630' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1056, 2, 6, 2139, 4, 2124, 6, CAST(N'2016-07-01 18:35:27.123' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1057, 4, 6, 2140, 4, 1116, 6, CAST(N'2016-07-02 11:39:44.777' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1058, 4, 6, 2141, 4, 1118, 6, CAST(N'2016-07-02 11:39:45.153' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1059, 4, 6, 2142, 4, 1119, 6, CAST(N'2016-07-02 11:39:45.750' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1060, 4, 6, 2143, 4, 2122, 6, CAST(N'2016-07-02 11:39:46.810' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1061, 1, 6, 2130, 4, 1112, 6, CAST(N'2016-07-02 11:40:05.513' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1062, 3, 6, 2144, 4, 1120, 6, CAST(N'2016-07-02 11:52:45.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1063, 5, 6, 2145, 4, 2123, 6, CAST(N'2016-07-02 11:52:58.683' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1064, 5, 6, 2146, 4, 2120, 6, CAST(N'2016-07-02 11:53:10.377' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1065, 6, 6, 2147, 4, 1124, 6, CAST(N'2016-07-02 11:53:18.240' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1066, 6, 6, 2148, 4, 1125, 6, CAST(N'2016-07-02 11:53:24.543' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1067, 2, 4, 2149, 2, 1078, 4, CAST(N'2016-07-06 10:12:56.467' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1068, 4, 4, 2150, 2, 1057, 4, CAST(N'2016-07-06 10:13:02.443' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1069, 4, 4, 2151, 2, 1058, 4, CAST(N'2016-07-06 10:13:03.760' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1070, 2, 6, 2137, 2, 1037, 6, CAST(N'2016-07-07 13:31:43.327' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1071, 2, 6, 2127, 2, 1023, 6, CAST(N'2016-07-07 13:31:54.177' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1072, 2, 6, 2138, 2, 1027, 6, CAST(N'2016-07-07 13:32:06.397' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1073, 2, 6, 2126, 2, 1024, 6, CAST(N'2016-07-07 13:32:10.870' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1074, 2, 6, 2139, 2, 1076, 6, CAST(N'2016-07-07 13:32:15.103' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1075, 4, 6, 2141, 2, 1031, 6, CAST(N'2016-07-07 13:36:43.893' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1076, 4, 6, 2142, 2, 1032, 6, CAST(N'2016-07-07 13:36:44.617' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1077, 4, 6, 2140, 2, 1066, 6, CAST(N'2016-07-07 13:36:45.447' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1078, 1, 6, 2130, 2, 1088, 6, CAST(N'2016-07-07 13:36:48.490' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1079, 3, 6, 2144, 2, 1039, 6, CAST(N'2016-07-07 13:36:54.290' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1080, 5, 6, 2152, 2, 1041, 6, CAST(N'2016-07-07 13:36:57.630' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1081, 5, 6, 2146, 2, 1042, 6, CAST(N'2016-07-07 13:36:58.267' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1082, 5, 6, 2153, 2, 1045, 6, CAST(N'2016-07-07 13:37:00.870' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1083, 5, 6, 2154, 2, 1044, 6, CAST(N'2016-07-07 13:37:01.613' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1084, 6, 6, 2148, 2, 1051, 6, CAST(N'2016-07-07 13:37:04.640' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1085, 6, 6, 2155, 2, 1052, 6, CAST(N'2016-07-07 13:37:05.397' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1086, 6, 6, 2156, 2, 1053, 6, CAST(N'2016-07-07 13:37:06.053' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1087, 6, 6, 2147, 2, 1050, 6, CAST(N'2016-07-07 13:44:24.923' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1088, 2, 6, 2134, 2, 1022, 6, CAST(N'2016-07-07 13:44:30.223' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1089, 2, 6, 2133, 2, 1025, 6, CAST(N'2016-07-07 13:44:37.897' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1090, 2, 6, 2135, 2, 1026, 6, CAST(N'2016-07-07 13:44:38.943' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1091, 2, 6, 2136, 2, 1067, 6, CAST(N'2016-07-07 13:44:39.763' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1092, 4, 6, 2143, 2, 1033, 6, CAST(N'2016-07-07 13:44:47.530' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ParameterMapping] ([Id], [RefMasterId], [RefVendorId], [RefVendorValId], [RefStoreId], [RefStoreValId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1093, 5, 6, 2145, 2, 1047, 6, CAST(N'2016-07-07 13:44:51.193' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[ParameterMapping] OFF
SET IDENTITY_INSERT [dbo].[ProductCategory] ON 

INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, N'Dresses', N'Dresses Desc On the Insert tab, the galleries include items that are designed to coordinate with the overall look of your document. You can use these galleries to insert tables, headers, footers, list', NULL, 1, N'40510-40515-1-2-015406264.jpeg', 1, CAST(N'2016-04-25 10:33:50.023' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-08 13:54:06.253' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, 2, N'Dress Material', N'Dress Material Desc', NULL, 3, N'2-2.jpg', 1, CAST(N'2016-04-25 17:22:14.447' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-02 12:45:50.473' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (8, 2, N'Ethic Gowne', N'Ethic Gowne Desc', NULL, 4, N'3-3.jpg', 1, CAST(N'2016-04-25 17:23:36.310' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-02 12:45:59.047' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (9, 2, N'Kurta Kurti', N'Kurta Kurti Desc', NULL, 5, N'41302-2-015551076.jpeg', 1, CAST(N'2016-04-25 17:24:02.563' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-08 13:55:51.057' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (10, 2, N'Lehenga Choli', N'Lehenga Choli Desc', NULL, 6, N'4-4.jpg', 1, CAST(N'2016-04-25 17:24:34.590' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-02 12:46:14.197' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (11, 2, N'Salawar', N'Salawar Desc', NULL, 7, N'004.jpg', 1, CAST(N'2016-04-25 17:25:06.757' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-04 11:05:41.723' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (12, 2, N'Suits Dupatta', N'Suits Dupatta Desc', NULL, 8, N'41280-2-015613687.jpeg', 1, CAST(N'2016-04-25 17:25:38.990' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-08 13:56:13.683' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (13, 2, N'Skart', N'Skart Desc', NULL, 9, N'2222.Jpg', 1, CAST(N'2016-04-25 17:26:48.660' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-14 19:11:35.163' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (16, 2, N'Anarkali', NULL, 10, 11, N'1. (2).jpg', 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-11 11:46:03.797' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (17, 2, N'Anarkali Suit', NULL, 12, 12, N'fashionHUBLogo--2-111426779.png', 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-04 11:14:26.753' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (18, 2, N'Churidar Suit', NULL, 12, 13, NULL, 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-04 11:20:28.930' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (19, 2, N'Contemporary', NULL, 4, 14, N'40517.jpg', 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-11 10:43:25.237' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (20, 2, N'Designer', NULL, 4, 15, N'004-1.jpg', 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-11 12:12:38.037' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (22, 2, N'Designer Saree', N'Designer Saree Description', 5, 17, N'download (1).jpg', 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-11 11:37:07.717' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (23, 2, N'Designer Suit', NULL, 12, 18, N'40518-1.jpg', 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-04 11:05:57.407' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (24, 2, N'Floor Length', NULL, 11, 19, N'download2222.jpg', 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-11 11:47:03.650' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (25, 2, N'Floor Length Anarkali', NULL, 11, 20, N'download (1)1111.jpg', 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-11 11:46:51.847' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (27, 2, N'Lehenga Saree', NULL, 5, 22, N'download (2).jpg', 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-11 11:50:13.213' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (28, 2, N'Lehenga Suit', NULL, 12, 23, NULL, 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (29, 2, N'NO', NULL, 13, 24, N'001.jpg', 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-11 12:13:13.380' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (30, 2, N'NONE', NULL, 13, 25, NULL, 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (31, 2, N'Pakistani Suit', NULL, 12, 26, NULL, 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (32, 2, N'Palazzo Suit', NULL, 12, 27, NULL, 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (33, 2, N'Patiala', NULL, 5, 28, N'download.jpg', 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-11 11:37:26.010' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (34, 2, N'Patiala Suit', NULL, 12, 29, NULL, 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (35, 2, N'Patiyala', NULL, 12, 30, NULL, 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (36, 2, N'Salwar suit', NULL, 12, 31, NULL, 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-11 11:20:59.767' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (37, 2, N'Staright', NULL, 11, 32, NULL, 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (38, 2, N'Straight', NULL, 11, 33, NULL, 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (39, 2, N'Straight Suit', NULL, 12, 34, NULL, 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (40, 2, N'Traditional Saree', NULL, 5, 35, N'005.jpg', 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-11 11:47:52.690' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (41, 2, N'Trendy Saree', NULL, 5, 36, N'003.jpg', 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-11 11:48:00.607' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (42, 2, N'Trendy Suit', NULL, 12, 37, NULL, 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (43, 2, N'Wedding Gown', NULL, 8, 38, N'1 (1).jpg', 1, CAST(N'2016-05-11 00:00:00.000' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-11 11:45:42.437' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (44, 2, N'Lehenga', N'Desc', 10, 21, N'2 (2).jpeg', 1, CAST(N'2016-05-11 10:57:40.450' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (45, 2, N'Designer Kurti', N'Desg Kurti', 9, 20, N'2 (2).jpg', 1, CAST(N'2016-05-11 10:58:39.130' AS DateTime), N'127.0.0.1', 1, CAST(N'2016-05-11 11:34:44.317' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1044, 4, N'Saree', N'Desc', NULL, 1, N'333.jpg', 1, CAST(N'2016-05-17 14:54:21.180' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1045, 4, N'Dresses', N'Dress Description', NULL, 2, N'a5f7609c6b752a8dbd3e7ae87d4d63eb.jpg', 1, CAST(N'2016-05-17 14:59:46.323' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1046, 4, N'Designer', NULL, 1044, 1, N'222.Jpg', 1, CAST(N'2016-05-17 15:00:18.687' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1047, 4, N'Cottan', NULL, 1044, 2, N'444.jpg', 1, CAST(N'2016-05-17 15:00:33.810' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1048, 4, N'Weding', NULL, 1044, 3, N'555.jpg', 1, CAST(N'2016-05-17 15:00:51.020' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1049, 4, N'Gown Dress', NULL, 1045, 1, N'High-Neck-2015-font-b-Prom-b-font-Dresses-with-Cap-Sleeves-Sexy-font-b-Navy.jpg', 1, CAST(N'2016-05-17 15:01:32.650' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1050, 4, N'Nack less Dress', NULL, 1045, 2, N'navy-dress-DQ-9247-a.jpg', 1, CAST(N'2016-05-17 15:02:02.303' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1051, 4, N'Single Fabric Dress', NULL, 1045, 3, N'navy-dress-FB-GL2070-a.jpg', 1, CAST(N'2016-05-17 15:02:37.827' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1052, 4, N'Designer Dress ', NULL, 1045, 4, N'Popular-A-line-Plus-Size-Masquerade-Formal-Party-Gowns-font-b-Puffy-b-font-Tulle-Sexy.jpg', 1, CAST(N'2016-05-17 15:03:01.980' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1053, 2, N'Styles Dupatta', NULL, 12, 2, NULL, 1, CAST(N'2016-05-17 15:08:38.993' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1054, 2, N'Designer Dupatta', NULL, 12, 3, NULL, 1, CAST(N'2016-05-17 15:09:11.747' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1058, 6, N'Saree', NULL, NULL, 1, NULL, 6, CAST(N'2016-07-07 13:45:34.970' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2058, 6, N'Dress', NULL, NULL, 2, NULL, 6, CAST(N'2016-07-08 14:06:45.697' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductCategory] ([PCId], [RefVendorId], [ProdCategoryName], [ProdCategoryDesc], [RefPCId], [Ord], [ProdCategoryImg], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2063, 2, N'Saree', N'Saree', NULL, 5, NULL, 2, CAST(N'2016-07-12 10:53:28.940' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[ProductCategory] OFF
SET IDENTITY_INSERT [dbo].[ProductImgDet] ON 

INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 1, N'40518.jpeg', 1, 0, 2, CAST(N'2016-05-07 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, 8, N'41306-2-014124116.jpeg', 8, 0, 2, CAST(N'2016-05-07 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:41:24.160' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (13, 13, N'41277-2-014242969.jpeg', 104, 0, 2, CAST(N'2016-05-09 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:42:43.000' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (14, 14, N'41301-2-014003867.jpeg', 105, 0, 2, CAST(N'2016-05-09 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:40:03.903' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (15, 15, N'41276-2-014229457.jpeg', 106, 0, 2, CAST(N'2016-05-09 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:42:29.487' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (118, 10, N'41305-2-014105708.jpeg', 101, 0, 2, CAST(N'2016-05-09 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:41:05.740' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (119, 9, N'41307-2-014211816.jpeg', 9, 0, 2, CAST(N'2016-05-09 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:42:11.850' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (129, 16, N'41299-2-014329258.jpeg', 1500, 0, 2, CAST(N'2016-05-12 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:43:29.293' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (132, 17, N'41288-2-014359043.jpeg', 1501, 0, 2, CAST(N'2016-05-12 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:43:59.080' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (136, 7, N'41304-2-014031613.jpeg', 1, 0, 2, CAST(N'2016-06-13 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:40:31.703' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1304, 1052, N'201-001-001.jpg', 1, 1, 4, CAST(N'2016-07-02 11:48:16.557' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1305, 1052, N'40518.jpeg', 1, 1, 4, CAST(N'2016-07-02 11:48:16.557' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1306, 1053, N'003.jpg', 3, 1, 4, CAST(N'2016-07-02 11:48:16.557' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1307, 1053, N'003.jpg', 3, 1, 4, CAST(N'2016-07-02 11:48:16.557' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1308, 1053, N'003.jpg', 3, 1, 4, CAST(N'2016-07-02 11:48:16.557' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1309, 1053, N'003.jpg', 3, 1, 4, CAST(N'2016-07-02 11:48:16.557' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1310, 1053, N'003.jpg', 3, 1, 4, CAST(N'2016-07-02 11:48:16.557' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1311, 1053, N'003.jpg', 3, 1, 4, CAST(N'2016-07-02 11:48:16.557' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1312, 1053, N'003.jpg', 3, 1, 4, CAST(N'2016-07-02 11:48:16.557' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1313, 1053, N'003.jpg', 3, 1, 4, CAST(N'2016-07-02 11:48:16.557' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1314, 1053, N'003.jpg', 3, 1, 4, CAST(N'2016-07-02 11:48:16.557' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1315, 1053, N'003.jpg', 3, 1, 4, CAST(N'2016-07-02 11:48:16.557' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1316, 1053, N'003.jpg', 3, 1, 4, CAST(N'2016-07-02 11:48:16.557' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1317, 1054, N'201-001-001.jpg', 1, 1, 6, CAST(N'2016-07-02 11:53:26.747' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1318, 1054, N'40518.jpeg', 1, 1, 6, CAST(N'2016-07-02 11:53:26.747' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1319, 1055, N'003.jpg', 3, 1, 6, CAST(N'2016-07-02 11:53:26.750' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1320, 1055, N'003.jpg', 3, 1, 6, CAST(N'2016-07-02 11:53:26.750' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1321, 1055, N'003.jpg', 3, 1, 6, CAST(N'2016-07-02 11:53:26.750' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1322, 1055, N'003.jpg', 3, 1, 6, CAST(N'2016-07-02 11:53:26.750' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1323, 1055, N'003.jpg', 3, 1, 6, CAST(N'2016-07-02 11:53:26.750' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1324, 1055, N'003.jpg', 3, 1, 6, CAST(N'2016-07-02 11:53:26.750' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1325, 1055, N'003.jpg', 3, 1, 6, CAST(N'2016-07-02 11:53:26.750' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1326, 1055, N'003.jpg', 3, 1, 6, CAST(N'2016-07-02 11:53:26.750' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1327, 1055, N'003.jpg', 3, 1, 6, CAST(N'2016-07-02 11:53:26.750' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1328, 1055, N'003.jpg', 3, 1, 6, CAST(N'2016-07-02 11:53:26.750' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1329, 1055, N'003.jpg', 3, 1, 6, CAST(N'2016-07-02 11:53:26.750' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1330, 1056, N'005.JPG', 5, 1, 4, CAST(N'2016-07-02 14:12:10.463' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1331, 1056, N'005.JPG', 5, 1, 4, CAST(N'2016-07-02 14:12:10.463' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1332, 1056, N'005.JPG', 5, 1, 4, CAST(N'2016-07-02 14:12:10.463' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1333, 1056, N'005.JPG', 5, 1, 4, CAST(N'2016-07-02 14:12:10.463' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1334, 1056, N'005.JPG', 5, 1, 4, CAST(N'2016-07-02 14:12:10.463' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1335, 1056, N'005.JPG', 5, 1, 4, CAST(N'2016-07-02 14:12:10.463' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1336, 1056, N'005.JPG', 5, 1, 4, CAST(N'2016-07-02 14:12:10.463' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1337, 1056, N'005.JPG', 5, 1, 4, CAST(N'2016-07-02 14:12:10.463' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1338, 1056, N'005.JPG', 5, 1, 4, CAST(N'2016-07-02 14:12:10.463' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1339, 1056, N'005.JPG', 5, 1, 4, CAST(N'2016-07-02 14:12:10.463' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1340, 1056, N'005.JPG', 5, 1, 4, CAST(N'2016-07-02 14:12:10.463' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1341, 1057, N'006.JPG', 6, 1, 4, CAST(N'2016-07-02 14:12:10.497' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1342, 1057, N'006.JPG', 6, 1, 4, CAST(N'2016-07-02 14:12:10.497' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1343, 1057, N'006.JPG', 6, 1, 4, CAST(N'2016-07-02 14:12:10.497' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1344, 1057, N'006.JPG', 6, 1, 4, CAST(N'2016-07-02 14:12:10.497' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1345, 1057, N'006.JPG', 6, 1, 4, CAST(N'2016-07-02 14:12:10.497' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1346, 1057, N'006.JPG', 6, 1, 4, CAST(N'2016-07-02 14:12:10.497' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1347, 1057, N'006.JPG', 6, 1, 4, CAST(N'2016-07-02 14:12:10.497' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1348, 1057, N'006.JPG', 6, 1, 4, CAST(N'2016-07-02 14:12:10.497' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1349, 1057, N'006.JPG', 6, 1, 4, CAST(N'2016-07-02 14:12:10.497' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1350, 1057, N'006.JPG', 6, 1, 4, CAST(N'2016-07-02 14:12:10.497' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1351, 1057, N'006.JPG', 6, 1, 4, CAST(N'2016-07-02 14:12:10.497' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1352, 1058, N'007--104659750-104716858.jpg', 1, 1, 4, CAST(N'2016-07-02 14:12:10.503' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1353, 1058, N'007-1-104739211.jpg', 1, 1, 4, CAST(N'2016-07-02 14:12:10.503' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1354, 1059, N'202-008.jpg', 8, 1, 4, CAST(N'2016-07-02 14:12:10.510' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1355, 12, N'41274-2-014501734.jpeg', 0, 0, 2, CAST(N'2016-07-04 10:34:39.213' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:45:01.767' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1358, 1062, N'009.jpg', 9, 1, 4, CAST(N'2016-07-04 13:04:35.210' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1359, 1062, N'009.jpg', 9, 1, 4, CAST(N'2016-07-04 13:04:35.210' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1360, 1062, N'009.jpg', 9, 1, 4, CAST(N'2016-07-04 13:04:35.210' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1361, 1062, N'009.jpg', 9, 1, 4, CAST(N'2016-07-04 13:04:35.210' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1362, 1062, N'009.jpg', 9, 1, 4, CAST(N'2016-07-04 13:04:35.210' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1363, 1062, N'009.jpg', 9, 1, 4, CAST(N'2016-07-04 13:04:35.210' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1364, 1062, N'009.jpg', 9, 1, 4, CAST(N'2016-07-04 13:04:35.210' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1365, 1062, N'009.jpg', 9, 1, 4, CAST(N'2016-07-04 13:04:35.210' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1366, 1062, N'009.jpg', 9, 1, 4, CAST(N'2016-07-04 13:04:35.210' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1367, 1062, N'009.jpg', 9, 1, 4, CAST(N'2016-07-04 13:04:35.210' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1368, 1062, N'009.jpg', 9, 1, 4, CAST(N'2016-07-04 13:04:35.210' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1369, 1063, N'101.jpg', 101, 1, 4, CAST(N'2016-07-04 13:04:35.247' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1370, 1063, N'101.jpg', 101, 1, 4, CAST(N'2016-07-04 13:04:35.247' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1371, 1063, N'101.jpg', 101, 1, 4, CAST(N'2016-07-04 13:04:35.247' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1372, 1063, N'101.jpg', 101, 1, 4, CAST(N'2016-07-04 13:04:35.247' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1373, 1063, N'101.jpg', 101, 1, 4, CAST(N'2016-07-04 13:04:35.247' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1374, 1063, N'101.jpg', 101, 1, 4, CAST(N'2016-07-04 13:04:35.247' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1375, 1063, N'101.jpg', 101, 1, 4, CAST(N'2016-07-04 13:04:35.247' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1376, 1063, N'101.jpg', 101, 1, 4, CAST(N'2016-07-04 13:04:35.247' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1377, 1063, N'101.jpg', 101, 1, 4, CAST(N'2016-07-04 13:04:35.247' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1378, 1063, N'101.jpg', 101, 1, 4, CAST(N'2016-07-04 13:04:35.247' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1379, 1063, N'101.jpg', 101, 1, 4, CAST(N'2016-07-04 13:04:35.247' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1380, 1064, N'203-102.jpg', 102, 1, 4, CAST(N'2016-07-04 13:04:35.280' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1381, 1064, N'102.jpg', 102, 1, 4, CAST(N'2016-07-04 13:04:35.280' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1382, 1064, N'102.jpg', 102, 1, 4, CAST(N'2016-07-04 13:04:35.280' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1383, 1064, N'102.jpg', 102, 1, 4, CAST(N'2016-07-04 13:04:35.280' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1384, 1064, N'102.jpg', 102, 1, 4, CAST(N'2016-07-04 13:04:35.280' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1385, 1064, N'102.jpg', 102, 1, 4, CAST(N'2016-07-04 13:04:35.280' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1386, 1064, N'102.jpg', 102, 1, 4, CAST(N'2016-07-04 13:04:35.280' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1387, 1064, N'102.jpg', 102, 1, 4, CAST(N'2016-07-04 13:04:35.280' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1388, 1064, N'102.jpg', 102, 1, 4, CAST(N'2016-07-04 13:04:35.280' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1389, 1064, N'102.jpg', 102, 1, 4, CAST(N'2016-07-04 13:04:35.280' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1390, 1064, N'102.jpg', 102, 1, 4, CAST(N'2016-07-04 13:04:35.280' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1391, 1064, N'102.jpg', 102, 1, 4, CAST(N'2016-07-04 13:04:35.280' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1392, 1064, N'fashionHUBLogo-2-115415071.png', 0, 1, 4, CAST(N'2016-07-04 13:04:35.280' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1393, 1065, N'1500-1500.jpg', 1500, 1, 4, CAST(N'2016-07-04 13:06:12.703' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1394, 1065, N'1500-1500-1.jpg', 1, 1, 4, CAST(N'2016-07-04 13:06:12.703' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
GO
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1395, 1065, N'1500-1500-2.jpg', 2, 1, 4, CAST(N'2016-07-04 13:06:12.703' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1396, 1066, N'1500-1501.jpg', 1501, 1, 4, CAST(N'2016-07-04 13:06:12.780' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1397, 1066, N'1500-1501-2.jpg', 2, 1, 4, CAST(N'2016-07-04 13:06:12.780' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1398, 1066, N'1500-1501-1.jpg', 1, 1, 4, CAST(N'2016-07-04 13:06:12.780' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1399, 1071, N'001-2-103439075.jpeg', 0, 1, 4, CAST(N'2016-07-06 10:08:58.070' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1400, 1072, N'104.jpg', 104, 1, 4, CAST(N'2016-07-06 10:08:58.167' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1401, 1073, N'105.jpg', 105, 1, 4, CAST(N'2016-07-06 10:08:58.170' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1402, 1074, N'106.jpg', 106, 1, 4, CAST(N'2016-07-06 10:08:58.177' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1403, 1076, N'005.JPG', 5, 1, 6, CAST(N'2016-07-07 13:37:12.270' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1404, 1076, N'005.JPG', 5, 1, 6, CAST(N'2016-07-07 13:37:12.270' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1405, 1076, N'005.JPG', 5, 1, 6, CAST(N'2016-07-07 13:37:12.270' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1406, 1076, N'005.JPG', 5, 1, 6, CAST(N'2016-07-07 13:37:12.270' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1407, 1076, N'005.JPG', 5, 1, 6, CAST(N'2016-07-07 13:37:12.270' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1408, 1076, N'005.JPG', 5, 1, 6, CAST(N'2016-07-07 13:37:12.270' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1409, 1076, N'005.JPG', 5, 1, 6, CAST(N'2016-07-07 13:37:12.270' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1410, 1076, N'005.JPG', 5, 1, 6, CAST(N'2016-07-07 13:37:12.270' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1411, 1076, N'005.JPG', 5, 1, 6, CAST(N'2016-07-07 13:37:12.270' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1412, 1076, N'005.JPG', 5, 1, 6, CAST(N'2016-07-07 13:37:12.270' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1413, 1076, N'005.JPG', 5, 1, 6, CAST(N'2016-07-07 13:37:12.270' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1414, 1077, N'006.JPG', 6, 1, 6, CAST(N'2016-07-07 13:37:12.360' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1415, 1077, N'006.JPG', 6, 1, 6, CAST(N'2016-07-07 13:37:12.360' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1416, 1077, N'006.JPG', 6, 1, 6, CAST(N'2016-07-07 13:37:12.360' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1417, 1077, N'006.JPG', 6, 1, 6, CAST(N'2016-07-07 13:37:12.360' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1418, 1077, N'006.JPG', 6, 1, 6, CAST(N'2016-07-07 13:37:12.360' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1419, 1077, N'006.JPG', 6, 1, 6, CAST(N'2016-07-07 13:37:12.360' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1420, 1077, N'006.JPG', 6, 1, 6, CAST(N'2016-07-07 13:37:12.360' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1421, 1077, N'006.JPG', 6, 1, 6, CAST(N'2016-07-07 13:37:12.360' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1422, 1077, N'006.JPG', 6, 1, 6, CAST(N'2016-07-07 13:37:12.360' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1423, 1077, N'006.JPG', 6, 1, 6, CAST(N'2016-07-07 13:37:12.360' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1424, 1077, N'006.JPG', 6, 1, 6, CAST(N'2016-07-07 13:37:12.360' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1425, 1078, N'007--104659750-104716858.jpg', 1, 1, 6, CAST(N'2016-07-07 13:37:12.390' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1426, 1078, N'007-1-104739211.jpg', 1, 1, 6, CAST(N'2016-07-07 13:37:12.390' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1427, 1079, N'202-008.jpg', 8, 1, 6, CAST(N'2016-07-07 13:37:12.417' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1428, 1080, N'201-001-001.jpg', 1, 1, 6, CAST(N'2016-07-07 13:45:40.190' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1429, 1080, N'40518.jpeg', 1, 1, 6, CAST(N'2016-07-07 13:45:40.190' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1430, 1081, N'003.jpg', 3, 1, 6, CAST(N'2016-07-07 13:45:40.203' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1431, 1081, N'003.jpg', 3, 1, 6, CAST(N'2016-07-07 13:45:40.203' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1432, 1081, N'003.jpg', 3, 1, 6, CAST(N'2016-07-07 13:45:40.203' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1433, 1081, N'003.jpg', 3, 1, 6, CAST(N'2016-07-07 13:45:40.203' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1434, 1081, N'003.jpg', 3, 1, 6, CAST(N'2016-07-07 13:45:40.203' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1435, 1081, N'003.jpg', 3, 1, 6, CAST(N'2016-07-07 13:45:40.203' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1436, 1081, N'003.jpg', 3, 1, 6, CAST(N'2016-07-07 13:45:40.203' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1437, 1081, N'003.jpg', 3, 1, 6, CAST(N'2016-07-07 13:45:40.203' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1438, 1081, N'003.jpg', 3, 1, 6, CAST(N'2016-07-07 13:45:40.203' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1439, 1081, N'003.jpg', 3, 1, 6, CAST(N'2016-07-07 13:45:40.203' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1440, 1081, N'003.jpg', 3, 1, 6, CAST(N'2016-07-07 13:45:40.203' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2403, 5, N'41272-2-013652274.jpeg', 0, 0, 2, CAST(N'2016-07-14 13:36:52.520' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2404, 3, N'41302-2-013803846.jpeg', 0, 0, 2, CAST(N'2016-07-14 13:38:03.880' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2405, 6, N'41303-2-013844844.jpeg', 0, 0, 2, CAST(N'2016-07-14 13:38:44.880' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2406, 17, N'41291-2-014553830.jpeg', 0, 0, 2, CAST(N'2016-07-14 13:45:53.867' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2407, 17, N'41292-2-014620939.jpeg', 0, 0, 2, CAST(N'2016-07-14 13:46:20.973' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductImgDet] ([ProdImgId], [RefProdId], [ImgName], [Ord], [IsGlobal], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2408, 12, N'41278-2-014644806.jpeg', 0, 0, 2, CAST(N'2016-07-14 13:46:44.840' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[ProductImgDet] OFF
SET IDENTITY_INSERT [dbo].[ProductMas] ON 

INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, N'Prod001', 2, 1, N'001', N'On the Insert tab, the galleries include items that are designed to coordinate with the overall look of your document. You can use these galleries to insert tables, headers, footers, lists, cover page', N'Saree', N'Black,Green,Maroon', N'Semi Stitched', N'30,40,45', N'Art Silk', N'Embellised', N'GAURANG', N'Katrina', NULL, CAST(N'2016-06-22' AS Date), 1, CAST(2000.00 AS Numeric(10, 2)), CAST(1500.00 AS Numeric(10, 2)), NULL, NULL, 1, CAST(N'2016-04-28 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:44:13.047' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3, N'Prod003', 2, 1, N'003', NULL, N'Saree', N'Black,White', N'Semi Stitched', N'20,30,40', N'Chiffon', N'Embroidered', N'GAURANG', NULL, NULL, NULL, 1, CAST(300.00 AS Numeric(10, 2)), CAST(280.00 AS Numeric(10, 2)), NULL, NULL, 1, CAST(N'2016-04-28 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:38:03.843' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, N'Prod005', 2, 3, N'005', NULL, N'Dresses', N'Pink', N'Semi Stitched', N'20,30,40', N'Silk', N'Printed', N'GAURANG', NULL, NULL, NULL, 1, CAST(250.00 AS Numeric(10, 2)), CAST(230.00 AS Numeric(10, 2)), NULL, NULL, 1, CAST(N'2016-04-28 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:36:52.267' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, N'Prod006', 2, 3, N'006', NULL, N'Dresses', N'Blue,purple', N'Semi Stitched', N'20,30,40', N'Cotton', N'Embroidered', N'GAURANG', NULL, NULL, NULL, 1, CAST(350.00 AS Numeric(10, 2)), CAST(300.00 AS Numeric(10, 2)), NULL, NULL, 1, CAST(N'2016-04-28 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:38:44.840' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (7, N'Prod007', 2, 3, N'007', NULL, N'Dresses', N'Blue,Yellow', N'Semi Stitched', N'20,30,40', N'Chiffon', N'Plain', N'GAURANG', NULL, NULL, NULL, 1, CAST(450.00 AS Numeric(10, 2)), CAST(400.00 AS Numeric(10, 2)), NULL, NULL, 1, CAST(N'2016-04-28 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:40:31.580' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (8, N'Prod008', 2, 3, N'008', NULL, N'Dresses', N'Blue,Silver', N'Semi Stitched', N'20,30,40', N'Georgette', N'Printed', N'GAURANG', NULL, NULL, NULL, 1, CAST(550.00 AS Numeric(10, 2)), CAST(450.00 AS Numeric(10, 2)), NULL, NULL, 1, CAST(N'2016-04-28 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:41:24.093' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (9, N'Prod009', 2, 5, N'009', NULL, N'Dresses', N'Black,Red', N'Semi Stitched', N'20,30,40', N'Silk', N'Embellised', N'GAURANG', NULL, NULL, NULL, 1, CAST(560.00 AS Numeric(10, 2)), CAST(500.00 AS Numeric(10, 2)), NULL, NULL, 1, CAST(N'2016-04-28 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:42:11.813' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (10, N'HHH', 2, 5, N'101', NULL, N'Dresses', N'Golden,Red', N'Semi Stitched', N'20,30,40', N'Cotton', N'Embroidered', N' DEEPAM', N'Deepika', NULL, NULL, 1, CAST(480.00 AS Numeric(10, 2)), CAST(300.00 AS Numeric(10, 2)), NULL, NULL, 1, CAST(N'2016-04-28 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:41:05.693' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (11, N'Peod 102', 2, 5, N'102', NULL, N'Dresses', N'Blue,Green', N'Semi Stitched', N'20,30,40', N'Georgette', N'Plain', N'GAURANG', NULL, NULL, NULL, 1, CAST(360.00 AS Numeric(10, 2)), CAST(250.00 AS Numeric(10, 2)), NULL, NULL, 1, CAST(N'2016-04-28 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:39:28.423' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (12, N'Kasmiri', 2, 6, N'103', NULL, N'Kurta Kurti', N'Black,Maroon', N'Semi Stitched', N'20,30,40', N'Georgette', N'Printed', N'GAURANG', NULL, NULL, CAST(N'2016-07-13' AS Date), 1, CAST(200.00 AS Numeric(10, 2)), CAST(100.00 AS Numeric(10, 2)), NULL, NULL, 1, CAST(N'2016-04-28 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:46:44.803' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (13, N'prod104', 2, 6, N'104', NULL, N'Kurta Kurti', N'Black,Golden,purple,Red,Yellow', N'Semi Stitched', N'20,30,40', N'Silk', N'Embellised', N'GAURANG', NULL, NULL, NULL, 1, CAST(950.00 AS Numeric(10, 2)), CAST(800.00 AS Numeric(10, 2)), NULL, NULL, 1, CAST(N'2016-04-28 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:42:42.953' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (14, N'Prod105', 2, 6, N'105', NULL, N'Kurta Kurti', N'Golden,Red', N'Semi Stitched', N'20,30,40', N'Cotton', N'Embroidered', N' DEEPAM', NULL, NULL, NULL, 1, CAST(420.00 AS Numeric(10, 2)), CAST(320.00 AS Numeric(10, 2)), NULL, NULL, 1, CAST(N'2016-04-28 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:40:03.863' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (15, N'Prod106', 2, 6, N'106', NULL, N'Kurta Kurti', N'Black,Golden,Red', N'Semi Stitched', N'20,30,40', N'Chiffon', N'Printed', N'GAURANG', NULL, NULL, NULL, 1, CAST(650.00 AS Numeric(10, 2)), CAST(550.00 AS Numeric(10, 2)), NULL, NULL, 1, CAST(N'2016-04-28 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:42:29.453' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (16, N'prod1500', 2, 19, N'1500', N'On the Insert tab, the galleries include items that are designed to coordinate with the overall look of your document. You can use these galleries to insert tables, headers, footers, lists, cover page', N'Saree', N'Black,Green,Maroon', N'Semi Stitched', N'30,40,45', N'Art Silk', N'Embellised', N' DEEPAM', N'Katrina', NULL, CAST(N'2016-06-22' AS Date), 1, CAST(2000.00 AS Numeric(10, 2)), CAST(1500.00 AS Numeric(10, 2)), NULL, NULL, 1, CAST(N'2016-05-12 16:23:05.587' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:43:29.253' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (17, N'Prod1501', 2, 19, N'1501', N'On the Insert tab, the galleries include items that are designed to coordinate with the overall look of your document. You can use these galleries to insert tables, headers, footers, lists, cover page', N'Saree', N'Black,Green,Maroon', N'Semi Stitched', N'30,40,45', N'Art Silk', N'Embellised', N' DEEPAM', N'Katrina', NULL, CAST(N'2016-06-22' AS Date), 1, CAST(2000.00 AS Numeric(10, 2)), CAST(1500.00 AS Numeric(10, 2)), NULL, NULL, 1, CAST(N'2016-05-12 16:37:33.507' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-14 13:46:20.937' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1052, N'AAA', 4, 2062, N'001', NULL, N'Saree', N'Black,Green,Maroon', N'Semi Stitched', N'30,40,45', N'Art Silk', N'Embellised', N'GAURANG', NULL, NULL, CAST(N'2016-06-22' AS Date), 1, CAST(2000.00 AS Numeric(10, 2)), CAST(1500.00 AS Numeric(10, 2)), 1, 2, 4, CAST(N'2016-07-02 11:48:16.557' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1053, N'BBB', 4, 2062, N'003', NULL, N'Saree', N'Black,White', N'Semi Stitched', N'20,30,40', N'Chiffon', N'Embroidered', N'GAURANG', NULL, NULL, CAST(N'2016-09-12' AS Date), 1, CAST(300.00 AS Numeric(10, 2)), CAST(280.00 AS Numeric(10, 2)), 3, 2, 4, CAST(N'2016-07-02 11:48:16.557' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1054, N'AAA', 6, 2063, N'001', NULL, N'Saree', N'Black,Green,Maroon', N'Semi Stitched', N'30,40,45', N'Art Silk', N'Embellised', N'GAURANG', NULL, NULL, CAST(N'2016-06-22' AS Date), 1, CAST(2000.00 AS Numeric(10, 2)), CAST(1500.00 AS Numeric(10, 2)), 1052, 4, 6, CAST(N'2016-07-02 11:53:26.747' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1055, N'BBB', 6, 2063, N'003', NULL, N'Saree', N'Black,White', N'Semi Stitched', N'20,30,40', N'Chiffon', N'Embroidered', N'GAURANG', NULL, NULL, NULL, 1, CAST(300.00 AS Numeric(10, 2)), CAST(280.00 AS Numeric(10, 2)), 1053, 4, 6, CAST(N'2016-07-02 11:53:26.750' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1056, N'A', 4, 2064, N'005', NULL, N'Dresses', N'Pink', N'Semi Stitched', N'20,30,40', N'Silk', N'Printed', N'GAURANG', NULL, NULL, CAST(N'2016-07-13' AS Date), 1, CAST(250.00 AS Numeric(10, 2)), CAST(230.00 AS Numeric(10, 2)), 5, 2, 4, CAST(N'2016-07-02 14:12:10.463' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1057, N'B', 4, 2064, N'006', NULL, N'Dresses', N'Blue,purple', N'Semi Stitched', N'20,30,40', N'Cotton', N'Embroidered', N'GAURANG', NULL, NULL, NULL, 1, CAST(350.00 AS Numeric(10, 2)), CAST(300.00 AS Numeric(10, 2)), 6, 2, 4, CAST(N'2016-07-02 14:12:10.497' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1058, N'C', 4, 2064, N'007', NULL, N'Dresses', N'Yellow,Blue', N'Semi Stitched', N'20,30,40', N'Chiffon', N'Plain', N'GAURANG', NULL, NULL, CAST(N'2016-07-21' AS Date), 1, CAST(450.00 AS Numeric(10, 2)), CAST(400.00 AS Numeric(10, 2)), 7, 2, 4, CAST(N'2016-07-02 14:12:10.503' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1059, N'D', 4, 2064, N'008', NULL, N'Dresses', N'Blue,Silver', N'Semi Stitched', N'20,30,40', N'Georgette', N'Printed', N'GAURANG', NULL, NULL, NULL, 1, CAST(550.00 AS Numeric(10, 2)), CAST(450.00 AS Numeric(10, 2)), 8, 2, 4, CAST(N'2016-07-02 14:12:10.510' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1062, N'VVV', 4, 2067, N'009', NULL, N'Dresses', N'Black,Red', N'Semi Stitched', N'20,30,40', N'Silk', N'Embellised', N'GAURANG', NULL, NULL, NULL, 1, CAST(560.00 AS Numeric(10, 2)), CAST(500.00 AS Numeric(10, 2)), 9, 2, 4, CAST(N'2016-07-04 13:04:35.200' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1063, N'HHH', 4, 2067, N'101', NULL, N'Dresses', N'Red,Golden', N'Semi Stitched', N'20,30,40', N'Cotton', N'Embroidered', N' KALANJALI SAREES', NULL, NULL, NULL, 1, CAST(480.00 AS Numeric(10, 2)), CAST(300.00 AS Numeric(10, 2)), 10, 2, 4, CAST(N'2016-07-04 13:04:35.247' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1064, N'Peod 102', 4, 2067, N'102', NULL, N'Dresses', N'Blue,Green', N'Semi Stitched', N'20,30,40', N'Georgette', N'Plain', N'GAURANG', NULL, NULL, NULL, 1, CAST(360.00 AS Numeric(10, 2)), CAST(250.00 AS Numeric(10, 2)), 11, 2, 4, CAST(N'2016-07-04 13:04:35.280' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1065, N'WWWW', 4, 2068, N'1500', NULL, N'Saree', N'Black,Green,Maroon', N'Semi Stitched', N'30,40,45', N'Art Silk', N'Embellised', N' KALANJALI SAREES', NULL, NULL, CAST(N'2016-06-22' AS Date), 1, CAST(3037.10 AS Numeric(10, 2)), CAST(1992.77 AS Numeric(10, 2)), 16, 2, 4, CAST(N'2016-07-04 13:06:12.703' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1066, N'SSSSS', 4, 2068, N'1501', NULL, N'Saree', N'Black,Green,Maroon', N'Semi Stitched', N'30,40,45', N'Art Silk', N'Embellised', N' KALANJALI SAREES', NULL, NULL, CAST(N'2016-06-22' AS Date), 1, CAST(3037.10 AS Numeric(10, 2)), CAST(1992.77 AS Numeric(10, 2)), 17, 2, 4, CAST(N'2016-07-04 13:06:12.780' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1067, N'ProductName1', 2, 21, N'Prod1', N'Desc Prod', N'Dresses', N'Black,Dark Pink', N'Semi Stitched', N'36,38', N'Art Silk', N'Embellised', N' DEEPAM', N'Deepika', NULL, CAST(N'2016-07-20' AS Date), 1, CAST(1000.00 AS Numeric(10, 2)), CAST(500.00 AS Numeric(10, 2)), NULL, NULL, 6, CAST(N'2016-07-04 13:18:19.773' AS DateTime), N'127.0.0.1', 4, CAST(N'2016-07-06 10:14:18.440' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1068, N'pn1', 2, 2065, N'p1', NULL, N'Dresses', NULL, NULL, NULL, N'Art Silk', N'Embellised', N' DEEPAM', N'Deepika', NULL, CAST(N'2016-07-28' AS Date), 1, NULL, NULL, NULL, NULL, 2, CAST(N'2016-07-04 13:29:42.453' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1069, N'erwer', 2, 2065, N'sdf', NULL, N'Dresses', N'Blue,Dark Pink', N'Semi Stitched', N'20', N'Art Silk', N'Embellised', N' DEEPAM', NULL, NULL, CAST(N'2016-07-28' AS Date), 1, NULL, NULL, NULL, NULL, 2, CAST(N'2016-07-04 13:30:32.150' AS DateTime), N'127.0.0.1', 4, CAST(N'2016-07-04 14:01:14.513' AS DateTime), N'127.0.0.1')
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1071, N'Kasmiri', 4, 2069, N'103', NULL, N'Kurta Kurti', N'Black,Maroon', N'Semi Stitched', N'20,30,40', N'Georgette', N'Printed', N'GAURANG', NULL, NULL, CAST(N'2016-07-13' AS Date), 1, CAST(200.00 AS Numeric(10, 2)), CAST(100.00 AS Numeric(10, 2)), 12, 2, 4, CAST(N'2016-07-06 10:08:58.060' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1072, N'ad', 4, 2069, N'104', NULL, N'Kurta Kurti', N'Yellow,Black,Red,purple,Golden', N'Semi Stitched', N'20,30,40', N'Silk', N'Embellised', N'GAURANG', NULL, NULL, NULL, 1, CAST(950.00 AS Numeric(10, 2)), CAST(800.00 AS Numeric(10, 2)), 13, 2, 4, CAST(N'2016-07-06 10:08:58.167' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1073, N'awrqw', 4, 2069, N'105', NULL, N'Kurta Kurti', N'Red,Golden', N'Semi Stitched', N'20,30,40', N'Cotton', N'Embroidered', N' KALANJALI SAREES', NULL, NULL, NULL, 1, CAST(420.00 AS Numeric(10, 2)), CAST(320.00 AS Numeric(10, 2)), 14, 2, 4, CAST(N'2016-07-06 10:08:58.170' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1074, N'qweqw', 4, 2069, N'106', NULL, N'Kurta Kurti', N'Black,Red,Golden', N'Semi Stitched', N'20,30,40', N'Chiffon', N'Printed', N'GAURANG', NULL, NULL, NULL, 1, CAST(650.00 AS Numeric(10, 2)), CAST(550.00 AS Numeric(10, 2)), 15, 2, 4, CAST(N'2016-07-06 10:08:58.177' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1075, N'ProductName1', 4, 2070, N'Prod1', NULL, N'Dresses', N'Black,Dark Pink', N'Semi Stitched', N'38,36', N'Art Silk', N'Embellised', N' KALANJALI SAREES', NULL, NULL, CAST(N'2016-07-20' AS Date), 1, CAST(1000.00 AS Numeric(10, 2)), CAST(500.00 AS Numeric(10, 2)), 1067, 2, 4, CAST(N'2016-07-06 10:14:31.450' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1076, N'p', 6, 2071, N'005', NULL, N'Dresses', N'Pink,Pink', N'Semi Stitched', N'20,30,40,20,30,40', N'Silk', N'Printed', N'GAURANG', NULL, NULL, NULL, 1, CAST(250.00 AS Numeric(10, 2)), CAST(230.00 AS Numeric(10, 2)), 5, 2, 6, CAST(N'2016-07-07 13:37:12.270' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1077, N'p', 6, 2071, N'006', NULL, N'Dresses', N'Blue,purple,Blue,purple', N'Semi Stitched', N'20,30,40,20,30,40', N'Cotton', N'Embroidered', N'GAURANG', NULL, NULL, NULL, 1, CAST(350.00 AS Numeric(10, 2)), CAST(300.00 AS Numeric(10, 2)), 6, 2, 6, CAST(N'2016-07-07 13:37:12.360' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1078, N'p', 6, 2071, N'007', NULL, N'Saree', N'Yellow,Blue,Yellow,Blue', N'Semi Stitched', N'20,30,40,20,30,40', N'Chiffon', N'Plain', N'GAURANG', NULL, NULL, NULL, 1, CAST(450.00 AS Numeric(10, 2)), CAST(400.00 AS Numeric(10, 2)), 7, 2, 6, CAST(N'2016-07-07 13:37:12.390' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1079, N'p', 6, 2071, N'008', NULL, N'Saree', N'Blue,Silver,Blue,Silver', N'Semi Stitched', N'20,30,40,20,30,40', N'Georgette', N'Printed', N'GAURANG', NULL, NULL, NULL, 1, CAST(550.00 AS Numeric(10, 2)), CAST(450.00 AS Numeric(10, 2)), 8, 2, 6, CAST(N'2016-07-07 13:37:12.417' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1080, N's', 6, 2072, N'0011', NULL, N'Saree', N'Black,Green,Maroon,Black,Green,Maroon', N'Semi Stitched', N'30,40,45,30,40,45', N'Art Silk', N'Embellised', N'GAURANG', NULL, NULL, CAST(N'2016-06-22' AS Date), 1, CAST(2000.00 AS Numeric(10, 2)), CAST(1500.00 AS Numeric(10, 2)), 1, 2, 6, CAST(N'2016-07-07 13:45:40.177' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[ProductMas] ([ProdId], [ProdName], [RefVendorId], [RefCatId], [ProdCode], [ProdDescription], [RefProdCategory], [RefColor], [RefProdType], [RefSize], [RefFabric], [RefDesign], [RefBrand], [Celebrity], [ProdImgPath], [ActivetillDate], [IsActive], [RetailPrice], [WholeSalePrice], [RefProdId], [RefStoreId], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1081, N's', 6, 2072, N'0033', NULL, N'Saree', N'Black,White,Black,White', N'Semi Stitched', N'20,30,40,20,30,40', N'Chiffon', N'Embroidered', N'GAURANG', NULL, NULL, NULL, 1, CAST(300.00 AS Numeric(10, 2)), CAST(280.00 AS Numeric(10, 2)), 3, 2, 6, CAST(N'2016-07-07 13:45:40.203' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[ProductMas] OFF
SET IDENTITY_INSERT [dbo].[StoreAssociation] ON 

INSERT [dbo].[StoreAssociation] ([Id], [RefStoreId], [RefVendorId], [StoreCode], [StoreStatus], [VendorStatus], [ReqDate], [ApprovedDate], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 4, 2, N'644956', N'Approved', N'Deleted', CAST(N'2016-06-24 12:02:59.003' AS DateTime), NULL, 2, CAST(N'2016-06-24 12:02:59.003' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-06 16:16:02.303' AS DateTime), N'127.0.0.1')
INSERT [dbo].[StoreAssociation] ([Id], [RefStoreId], [RefVendorId], [StoreCode], [StoreStatus], [VendorStatus], [ReqDate], [ApprovedDate], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 5, 2, N'214331', N'Approved', N'Deleted', CAST(N'2016-06-24 12:07:27.590' AS DateTime), NULL, 2, CAST(N'2016-06-24 12:07:27.590' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-06 16:20:23.693' AS DateTime), N'127.0.0.1')
INSERT [dbo].[StoreAssociation] ([Id], [RefStoreId], [RefVendorId], [StoreCode], [StoreStatus], [VendorStatus], [ReqDate], [ApprovedDate], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1002, 6, 2, N'479825', N'Approved', N'Deleted', CAST(N'2016-06-24 13:40:46.980' AS DateTime), CAST(N'2016-07-07 13:23:30.143' AS DateTime), 2, CAST(N'2016-06-24 13:40:46.980' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-08-12 11:51:11.043' AS DateTime), N'127.0.0.1')
INSERT [dbo].[StoreAssociation] ([Id], [RefStoreId], [RefVendorId], [StoreCode], [StoreStatus], [VendorStatus], [ReqDate], [ApprovedDate], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2003, 7, 2, N'147760', N'Pending', N'Requested', CAST(N'2016-06-24 15:42:56.317' AS DateTime), NULL, 2, CAST(N'2016-06-24 15:42:56.317' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[StoreAssociation] ([Id], [RefStoreId], [RefVendorId], [StoreCode], [StoreStatus], [VendorStatus], [ReqDate], [ApprovedDate], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2004, 8, 2, N'214169', N'Pending', N'Requested', CAST(N'2016-06-24 15:54:34.740' AS DateTime), NULL, 2, CAST(N'2016-06-24 15:54:34.740' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-07-12 14:07:04.860' AS DateTime), N'127.0.0.1')
INSERT [dbo].[StoreAssociation] ([Id], [RefStoreId], [RefVendorId], [StoreCode], [StoreStatus], [VendorStatus], [ReqDate], [ApprovedDate], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2009, 6, 4, N'800040', N'Rejected', N'Approved', CAST(N'2016-07-07 13:00:19.613' AS DateTime), CAST(N'2016-07-07 13:02:43.487' AS DateTime), 4, CAST(N'2016-07-07 13:00:19.613' AS DateTime), N'127.0.0.1', 6, CAST(N'2016-08-12 11:51:56.570' AS DateTime), N'127.0.0.1')
INSERT [dbo].[StoreAssociation] ([Id], [RefStoreId], [RefVendorId], [StoreCode], [StoreStatus], [VendorStatus], [ReqDate], [ApprovedDate], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3008, 9, 2, N'524201', N'Pending', N'Requested', CAST(N'2016-07-12 13:48:12.047' AS DateTime), NULL, 2, CAST(N'2016-07-12 13:48:12.047' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[StoreAssociation] OFF
SET IDENTITY_INSERT [dbo].[Subscription] ON 

INSERT [dbo].[Subscription] ([SubId], [SubType], [NoOfProducts], [NoOfAppUser], [NoOfDays], [NoOfSlider], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, N'Free', 100, 5, 90, 10, N'1         ', N'08/06/2016', N'127.0.0.1 ', NULL, NULL, NULL)
INSERT [dbo].[Subscription] ([SubId], [SubType], [NoOfProducts], [NoOfAppUser], [NoOfDays], [NoOfSlider], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3, N'Business', 50000, 50, 365, 75, N'1         ', N'08-06-2016', N'127.0.0.1 ', NULL, NULL, NULL)
INSERT [dbo].[Subscription] ([SubId], [SubType], [NoOfProducts], [NoOfAppUser], [NoOfDays], [NoOfSlider], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, N'Premium', 100000, 1000, 1825, 500, N'1         ', N'08-06-2016', N'127.0.0.1 ', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[Subscription] OFF
SET IDENTITY_INSERT [dbo].[Vendor] ON 

INSERT [dbo].[Vendor] ([VendorId], [VendorName], [UserName], [Address], [Landmark], [Country], [State], [City], [Pincode], [ContactName], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [FaxNo], [EmailId], [WebSite], [LogoImg], [VendorCode], [ReferalCode], [ReferenceCode], [IsActive], [AboutUs], [ProdDispName], [CatDispName], [BGImage], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, N'Dharmik G', N'Dharmik', N'Nityanand Soc.', N'Katargam', N'India', N'Gijarat', N'Surat', N'395004', N'Dharmik', N'8545622', NULL, N'8445632266', NULL, N'1546548', N'gangadwaladarshan@gmail.com', NULL, N'2.jpg', N'856900', NULL, NULL, 1, N'Whether you’re building your own website or are just browsing for information on a business, organization, or individual, the ‘About Us’ page is a vital part of every website and blog. Why? Because it’s usually one of the first destinations visitors will click when arriving to a site.

If they aren’t impressed, you can expect them to leave without reading your awesome content, signing up for your newsletter or making a purchase on your e-commerce site.', N'Name', N'CodeName', N'BG-2-011433132.png', 1, CAST(N'2016-04-23 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-08-06 17:39:50.667' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Vendor] ([VendorId], [VendorName], [UserName], [Address], [Landmark], [Country], [State], [City], [Pincode], [ContactName], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [FaxNo], [EmailId], [WebSite], [LogoImg], [VendorCode], [ReferalCode], [ReferenceCode], [IsActive], [AboutUs], [ProdDispName], [CatDispName], [BGImage], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, N'Divy', N'Divy', N'Katargam', N'Maharashtra', N'India', N'Maharashtra', N'Mumbai', N'395004', N'Darshan S Gangadwala', N'08866804728', NULL, N'8866804728', N'8866804728', N'8866804728', N'gangadwaladarshan@gmail.com', NULL, N'4.jpg', N'644956', NULL, NULL, 1, NULL, N'Code', N'Code', N'BG-4-123311325.jpg', 1, CAST(N'2016-05-16 00:00:00.000' AS DateTime), N'127.0.0.1', 4, CAST(N'2016-07-08 12:33:11.313' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Vendor] ([VendorId], [VendorName], [UserName], [Address], [Landmark], [Country], [State], [City], [Pincode], [ContactName], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [FaxNo], [EmailId], [WebSite], [LogoImg], [VendorCode], [ReferalCode], [ReferenceCode], [IsActive], [AboutUs], [ProdDispName], [CatDispName], [BGImage], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, N'Hiten Patel', N'Hiten', NULL, NULL, NULL, NULL, N'Surat', NULL, NULL, NULL, NULL, N'9542663256', NULL, NULL, N'gangadwaladarshan@gmail.com', NULL, NULL, N'214331', NULL, NULL, 1, NULL, NULL, NULL, NULL, 0, CAST(N'2016-06-08 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[Vendor] ([VendorId], [VendorName], [UserName], [Address], [Landmark], [Country], [State], [City], [Pincode], [ContactName], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [FaxNo], [EmailId], [WebSite], [LogoImg], [VendorCode], [ReferalCode], [ReferenceCode], [IsActive], [AboutUs], [ProdDispName], [CatDispName], [BGImage], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, N'Yash Gandhi', N'Yash', N'adfsdf', NULL, NULL, N'sdfsd', N'Banglore', N'4645', NULL, NULL, NULL, N'98745566352', NULL, NULL, N'gangadwaladarshan@gmail.com', NULL, N'6-113538226.jpg', N'800040', NULL, NULL, 1, NULL, N'Code', N'Code', N'BG-6-121715212.jpg', 0, CAST(N'2016-06-08 00:00:00.000' AS DateTime), N'127.0.0.1', 4, CAST(N'2016-07-08 12:17:15.200' AS DateTime), N'127.0.0.1')
INSERT [dbo].[Vendor] ([VendorId], [VendorName], [UserName], [Address], [Landmark], [Country], [State], [City], [Pincode], [ContactName], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [FaxNo], [EmailId], [WebSite], [LogoImg], [VendorCode], [ReferalCode], [ReferenceCode], [IsActive], [AboutUs], [ProdDispName], [CatDispName], [BGImage], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (7, N'Kushal Patel', N'Kush', NULL, NULL, NULL, NULL, N'Kim', NULL, NULL, NULL, NULL, N'987864654', NULL, NULL, N'gangadwaladarshan@gmail.com', NULL, NULL, N'147760', NULL, NULL, 1, NULL, NULL, NULL, NULL, 0, CAST(N'2016-06-08 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[Vendor] ([VendorId], [VendorName], [UserName], [Address], [Landmark], [Country], [State], [City], [Pincode], [ContactName], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [FaxNo], [EmailId], [WebSite], [LogoImg], [VendorCode], [ReferalCode], [ReferenceCode], [IsActive], [AboutUs], [ProdDispName], [CatDispName], [BGImage], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (8, N'Satish Dungarani', N'Satish', NULL, NULL, NULL, NULL, N'Surat', NULL, NULL, NULL, NULL, N'9542663256', NULL, NULL, N'gangadwaladarshan@gmail.com', NULL, NULL, N'214169', N'V1B7J1', NULL, 1, NULL, NULL, NULL, NULL, 0, CAST(N'2016-06-08 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[Vendor] ([VendorId], [VendorName], [UserName], [Address], [Landmark], [Country], [State], [City], [Pincode], [ContactName], [ContactNo1], [ContactNo2], [MobileNo1], [MobileNo2], [FaxNo], [EmailId], [WebSite], [LogoImg], [VendorCode], [ReferalCode], [ReferenceCode], [IsActive], [AboutUs], [ProdDispName], [CatDispName], [BGImage], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (9, N'Simaran Fashion', N'SIMARAN', NULL, NULL, NULL, NULL, N'surat', NULL, NULL, NULL, NULL, N'984556352', NULL, NULL, N'gangadwaladarshan@gmail.com', NULL, NULL, N'524201', N'O3CCQ1', NULL, 1, NULL, NULL, NULL, NULL, 0, CAST(N'2016-07-11 15:46:16.220' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[Vendor] OFF
SET IDENTITY_INSERT [dbo].[VendorAssociation] ON 

INSERT [dbo].[VendorAssociation] ([Id], [RefVendorId], [RefAUId], [VendorCode], [VendorStatus], [AppUserStatus], [IsNotify], [ReqDate], [ApproveDate], [IsAdmin], [IsAdminNotification], [RateVendor], [VisitDateTime], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 4, 1, N'447010', N'Approved', N'Approved', 1, CAST(N'2016-04-27 12:38:19.127' AS DateTime), CAST(N'2016-06-28 10:29:44.657' AS DateTime), NULL, NULL, NULL, CAST(N'2016-07-11 11:09:47.903' AS DateTime), 1, CAST(N'2016-04-27 12:38:19.127' AS DateTime), N'23423razsdfas', NULL, NULL, NULL)
INSERT [dbo].[VendorAssociation] ([Id], [RefVendorId], [RefAUId], [VendorCode], [VendorStatus], [AppUserStatus], [IsNotify], [ReqDate], [ApproveDate], [IsAdmin], [IsAdminNotification], [RateVendor], [VisitDateTime], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 4, 2, N'447010', N'Rejected', N'Requested', 1, CAST(N'2016-04-28 11:07:43.900' AS DateTime), NULL, NULL, NULL, 3, NULL, 2, CAST(N'2016-04-28 11:07:43.900' AS DateTime), N'22', NULL, NULL, NULL)
INSERT [dbo].[VendorAssociation] ([Id], [RefVendorId], [RefAUId], [VendorCode], [VendorStatus], [AppUserStatus], [IsNotify], [ReqDate], [ApproveDate], [IsAdmin], [IsAdminNotification], [RateVendor], [VisitDateTime], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3, 4, 3, N'447010', N'Rejected', N'Requested', 1, CAST(N'2016-04-28 12:33:28.727' AS DateTime), NULL, NULL, NULL, NULL, NULL, 3, CAST(N'2016-04-28 12:33:28.727' AS DateTime), N'33', NULL, NULL, NULL)
INSERT [dbo].[VendorAssociation] ([Id], [RefVendorId], [RefAUId], [VendorCode], [VendorStatus], [AppUserStatus], [IsNotify], [ReqDate], [ApproveDate], [IsAdmin], [IsAdminNotification], [RateVendor], [VisitDateTime], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1, N'447010', N'Approved', N'Approved', 1, CAST(N'2016-04-27 12:38:19.127' AS DateTime), CAST(N'2016-08-06 17:36:47.730' AS DateTime), NULL, 0, 2, NULL, 1, CAST(N'2016-04-27 12:38:19.127' AS DateTime), N'23423razsdfas', 2, CAST(N'2016-06-28 12:54:58.913' AS DateTime), N'127.0.0.1')
INSERT [dbo].[VendorAssociation] ([Id], [RefVendorId], [RefAUId], [VendorCode], [VendorStatus], [AppUserStatus], [IsNotify], [ReqDate], [ApproveDate], [IsAdmin], [IsAdminNotification], [RateVendor], [VisitDateTime], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 2, 2, N'447010', N'Approved', N'Cancelled', 1, CAST(N'2016-04-28 11:07:43.900' AS DateTime), CAST(N'2016-06-02 10:36:32.163' AS DateTime), NULL, NULL, 1, NULL, 2, CAST(N'2016-04-28 11:07:43.900' AS DateTime), N'22', 2, CAST(N'2016-06-01 11:01:54.293' AS DateTime), N'22')
INSERT [dbo].[VendorAssociation] ([Id], [RefVendorId], [RefAUId], [VendorCode], [VendorStatus], [AppUserStatus], [IsNotify], [ReqDate], [ApproveDate], [IsAdmin], [IsAdminNotification], [RateVendor], [VisitDateTime], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, 2, 3, N'447010', N'Approved', N'Approved', 1, CAST(N'2016-05-21 09:33:28.727' AS DateTime), CAST(N'2016-08-12 11:30:37.513' AS DateTime), 1, 1, 4, NULL, 3, CAST(N'2016-04-28 12:33:28.727' AS DateTime), N'33', 2, CAST(N'2016-06-28 13:20:08.187' AS DateTime), N'127.0.0.1')
INSERT [dbo].[VendorAssociation] ([Id], [RefVendorId], [RefAUId], [VendorCode], [VendorStatus], [AppUserStatus], [IsNotify], [ReqDate], [ApproveDate], [IsAdmin], [IsAdminNotification], [RateVendor], [VisitDateTime], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1007, 2, 4, N'939443', N'Approved', N'Approved', 1, CAST(N'2016-06-02 00:00:00.000' AS DateTime), CAST(N'2016-08-12 11:41:00.900' AS DateTime), 1, 1, 2, NULL, 4, CAST(N'2016-06-02 00:00:00.000' AS DateTime), N'11', 2, CAST(N'2016-07-11 13:57:48.897' AS DateTime), N'127.0.0.1')
INSERT [dbo].[VendorAssociation] ([Id], [RefVendorId], [RefAUId], [VendorCode], [VendorStatus], [AppUserStatus], [IsNotify], [ReqDate], [ApproveDate], [IsAdmin], [IsAdminNotification], [RateVendor], [VisitDateTime], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1008, 2, 5, N'939443', N'Approved', N'Approved', 1, CAST(N'2016-06-02 00:00:00.000' AS DateTime), CAST(N'2016-08-06 17:47:21.237' AS DateTime), NULL, NULL, NULL, NULL, 5, CAST(N'2016-06-02 00:00:00.000' AS DateTime), N'22', NULL, NULL, NULL)
INSERT [dbo].[VendorAssociation] ([Id], [RefVendorId], [RefAUId], [VendorCode], [VendorStatus], [AppUserStatus], [IsNotify], [ReqDate], [ApproveDate], [IsAdmin], [IsAdminNotification], [RateVendor], [VisitDateTime], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1009, 2, 6, N'939443', N'Approved', N'Approved', 1, CAST(N'2016-06-02 00:00:00.000' AS DateTime), CAST(N'2016-07-09 10:17:12.973' AS DateTime), NULL, NULL, NULL, NULL, 6, CAST(N'2016-06-02 00:00:00.000' AS DateTime), N'33', NULL, NULL, NULL)
INSERT [dbo].[VendorAssociation] ([Id], [RefVendorId], [RefAUId], [VendorCode], [VendorStatus], [AppUserStatus], [IsNotify], [ReqDate], [ApproveDate], [IsAdmin], [IsAdminNotification], [RateVendor], [VisitDateTime], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1010, 2, 7, N'939443', N'Rejected', N'Approved', 1, CAST(N'2016-06-02 00:00:00.000' AS DateTime), CAST(N'2016-07-09 10:17:16.960' AS DateTime), NULL, NULL, NULL, NULL, 7, CAST(N'2016-06-02 00:00:00.000' AS DateTime), N'44', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[VendorAssociation] OFF
SET IDENTITY_INSERT [dbo].[VendorSlider] ON 

INSERT [dbo].[VendorSlider] ([SliderId], [RefVendorId], [SliderTitle], [SliderImg], [SliderUrl], [Ord], [DisplayPage], [Category], [StartDate], [EndDate], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, N'Fashion', N'Slider_03-013946907.jpeg', NULL, 1, N'Home', N'Dresses,Saree', CAST(N'2016-05-04' AS Date), CAST(N'2016-07-09' AS Date), 1, CAST(N'2016-05-04 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-18 00:00:00.000' AS DateTime), N'127.0.0.1')
INSERT [dbo].[VendorSlider] ([SliderId], [RefVendorId], [SliderTitle], [SliderImg], [SliderUrl], [Ord], [DisplayPage], [Category], [StartDate], [EndDate], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, N'FHUB', N'slider_06-020210612.jpeg', NULL, 3, N'Home', N'Ethic Gowne', CAST(N'2016-05-16' AS Date), CAST(N'2016-04-13' AS Date), 1, CAST(N'2016-05-04 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-18 00:00:00.000' AS DateTime), N'127.0.0.1')
INSERT [dbo].[VendorSlider] ([SliderId], [RefVendorId], [SliderTitle], [SliderImg], [SliderUrl], [Ord], [DisplayPage], [Category], [StartDate], [EndDate], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 2, N'Priyanka', N'Eid-Specil-Salw-020702046.jpeg', NULL, 5, N'Home', N'Dresses,Dress Material', CAST(N'2016-05-12' AS Date), CAST(N'2016-07-09' AS Date), 1, CAST(N'2016-05-04 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-18 00:00:00.000' AS DateTime), N'127.0.0.1')
INSERT [dbo].[VendorSlider] ([SliderId], [RefVendorId], [SliderTitle], [SliderImg], [SliderUrl], [Ord], [DisplayPage], [Category], [StartDate], [EndDate], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (6, 2, N'Sujee Fashion', N'slider12-980x45-020721655.jpeg', NULL, 6, N'Home', N'Dresses,Saree,Salawar', CAST(N'2016-05-10' AS Date), CAST(N'2016-05-19' AS Date), 1, CAST(N'2016-05-04 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-18 00:00:00.000' AS DateTime), N'127.0.0.1')
INSERT [dbo].[VendorSlider] ([SliderId], [RefVendorId], [SliderTitle], [SliderImg], [SliderUrl], [Ord], [DisplayPage], [Category], [StartDate], [EndDate], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (7, 2, N'Silpa Saree', N'xslide03.jpg.pa-020732679.jpeg', NULL, 7, N'Home', N'Saree,Lehenga Choli,Suits Dupatta', CAST(N'2016-05-18' AS Date), CAST(N'2016-07-09' AS Date), 1, CAST(N'2016-05-04 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-18 00:00:00.000' AS DateTime), N'127.0.0.1')
INSERT [dbo].[VendorSlider] ([SliderId], [RefVendorId], [SliderTitle], [SliderImg], [SliderUrl], [Ord], [DisplayPage], [Category], [StartDate], [EndDate], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (8, 2, N'Great Style', N'slider1014_-020753545.jpeg', NULL, 8, N'Catalog', N'Dress Material,Kurta Kurti,Salawar', CAST(N'2016-05-11' AS Date), CAST(N'2016-05-18' AS Date), 1, CAST(N'2016-05-04 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-18 00:00:00.000' AS DateTime), N'127.0.0.1')
INSERT [dbo].[VendorSlider] ([SliderId], [RefVendorId], [SliderTitle], [SliderImg], [SliderUrl], [Ord], [DisplayPage], [Category], [StartDate], [EndDate], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (10, 2, N'Garment', N'unnamed-020742338.png', NULL, 8, N'Product', N'Dresses,Dress Material', CAST(N'2016-05-11' AS Date), CAST(N'2016-07-09' AS Date), 1, CAST(N'2016-05-10 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-18 00:00:00.000' AS DateTime), N'127.0.0.1')
INSERT [dbo].[VendorSlider] ([SliderId], [RefVendorId], [SliderTitle], [SliderImg], [SliderUrl], [Ord], [DisplayPage], [Category], [StartDate], [EndDate], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1009, 2, N'Slwar Banner', N'SLIDER006-980x4-012252269.jpeg', NULL, 2, N'Home', N'Salawar', CAST(N'2016-06-10' AS Date), CAST(N'2016-07-09' AS Date), 2, CAST(N'2016-06-10 00:00:00.000' AS DateTime), N'127.0.0.1', 2, CAST(N'2016-06-18 00:00:00.000' AS DateTime), N'127.0.0.1')
INSERT [dbo].[VendorSlider] ([SliderId], [RefVendorId], [SliderTitle], [SliderImg], [SliderUrl], [Ord], [DisplayPage], [Category], [StartDate], [EndDate], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1010, 2, N'Royal', N'saree royal 1-2-094936155.jpeg', NULL, 10, N'Home', N'Saree', CAST(N'2016-07-14' AS Date), CAST(N'2016-08-25' AS Date), 2, CAST(N'2016-07-14 09:49:36.080' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[VendorSlider] ([SliderId], [RefVendorId], [SliderTitle], [SliderImg], [SliderUrl], [Ord], [DisplayPage], [Category], [StartDate], [EndDate], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1012, 2, N'Bollywood Saree', N'banner-2-101810406.jpeg', NULL, 11, N'Home', N'Saree', CAST(N'2016-07-14' AS Date), CAST(N'2016-08-25' AS Date), 2, CAST(N'2016-07-14 10:18:10.393' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[VendorSlider] OFF
SET IDENTITY_INSERT [dbo].[VendorSubDet] ON 

INSERT [dbo].[VendorSubDet] ([VendorSubId], [RefVendorId], [RefSubId], [ValidFromDate], [ValidTodate], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 8, 1, CAST(N'2016-06-08' AS Date), CAST(N'2016-09-06' AS Date), 8, CAST(N'2016-06-08 00:00:00.000' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[VendorSubDet] ([VendorSubId], [RefVendorId], [RefSubId], [ValidFromDate], [ValidTodate], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 9, 1, CAST(N'2016-07-11' AS Date), CAST(N'2016-07-14' AS Date), 9, CAST(N'2016-07-11 15:46:16.310' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[VendorSubDet] ([VendorSubId], [RefVendorId], [RefSubId], [ValidFromDate], [ValidTodate], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3, 6, 1, CAST(N'2016-07-11' AS Date), CAST(N'2016-10-09' AS Date), 9, CAST(N'2016-07-11 15:46:16.310' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[VendorSubDet] ([VendorSubId], [RefVendorId], [RefSubId], [ValidFromDate], [ValidTodate], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (4, 2, 1, CAST(N'2016-07-11' AS Date), CAST(N'2016-10-09' AS Date), 9, CAST(N'2016-07-11 15:46:16.310' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[VendorSubDet] ([VendorSubId], [RefVendorId], [RefSubId], [ValidFromDate], [ValidTodate], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (5, 4, 1, CAST(N'2016-07-11' AS Date), CAST(N'2016-10-09' AS Date), 9, CAST(N'2016-07-11 15:46:16.310' AS DateTime), N'127.0.0.1', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[VendorSubDet] OFF
SET IDENTITY_INSERT [dbo].[WishList] ON 

INSERT [dbo].[WishList] ([Id], [RefAUId], [RefVendorId], [RefProdId], [WishValue], [InsDate]) VALUES (1002, 1, 2, 17, 1, CAST(N'2016-05-16 10:27:41.820' AS DateTime))
SET IDENTITY_INSERT [dbo].[WishList] OFF
SET IDENTITY_INSERT [dbo].[WriteToUs] ON 

INSERT [dbo].[WriteToUs] ([Id], [RefAUId], [Remark], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (1, 2, N'Login', 2, CAST(N'2016-05-03' AS Date), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[WriteToUs] ([Id], [RefAUId], [Remark], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (2, 2, N'Login', 2, CAST(N'2016-05-03' AS Date), N'127.0.0.1', NULL, NULL, NULL)
INSERT [dbo].[WriteToUs] ([Id], [RefAUId], [Remark], [InsUser], [InsDate], [InsTerminal], [UpdUser], [UpdDate], [UpdTerminal]) VALUES (3, 2, N'Login', 2, CAST(N'2016-05-07' AS Date), N'127.0.0.1', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[WriteToUs] OFF
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_AspNetUserLogins]    Script Date: 11-11-2016 11:14:24 ******/
ALTER TABLE [dbo].[AspNetUserLogins] ADD  CONSTRAINT [IX_AspNetUserLogins] UNIQUE NONCLUSTERED 
(
	[UserId] ASC,
	[UserProvider] ASC,
	[ProviderKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_AspNetUserRoles]    Script Date: 11-11-2016 11:14:24 ******/
ALTER TABLE [dbo].[AspNetUserRoles] ADD  CONSTRAINT [IX_AspNetUserRoles] UNIQUE NONCLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [UQ_Vendor_VendorCode]    Script Date: 11-11-2016 11:14:24 ******/
ALTER TABLE [dbo].[Vendor] ADD  CONSTRAINT [UQ_Vendor_VendorCode] UNIQUE NONCLUSTERED 
(
	[VendorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AppLog]  WITH CHECK ADD  CONSTRAINT [FK_AppLog_AppUsers] FOREIGN KEY([RefAUId])
REFERENCES [dbo].[AppUsers] ([AUId])
GO
ALTER TABLE [dbo].[AppLog] CHECK CONSTRAINT [FK_AppLog_AppUsers]
GO
ALTER TABLE [dbo].[AppLog]  WITH CHECK ADD  CONSTRAINT [FK_AppLog_Vendor] FOREIGN KEY([RefVendorId])
REFERENCES [dbo].[Vendor] ([VendorId])
GO
ALTER TABLE [dbo].[AppLog] CHECK CONSTRAINT [FK_AppLog_Vendor]
GO
ALTER TABLE [dbo].[AspNetUserClaims]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserClaims_AspNetUsers] FOREIGN KEY([User_Id])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[AspNetUserClaims] CHECK CONSTRAINT [FK_AspNetUserClaims_AspNetUsers]
GO
ALTER TABLE [dbo].[AspNetUserLogins]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserLogins_AspNetUserLogins] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[AspNetUserLogins] CHECK CONSTRAINT [FK_AspNetUserLogins_AspNetUserLogins]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserRoles_AspNetRoles] FOREIGN KEY([RoleId])
REFERENCES [dbo].[AspNetRoles] ([Id])
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_AspNetUserRoles_AspNetRoles]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserRoles_AspNetUsers] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_AspNetUserRoles_AspNetUsers]
GO
ALTER TABLE [dbo].[CatalogMas]  WITH CHECK ADD  CONSTRAINT [FK_CatalogMas_Vendor] FOREIGN KEY([RefVendorId])
REFERENCES [dbo].[Vendor] ([VendorId])
GO
ALTER TABLE [dbo].[CatalogMas] CHECK CONSTRAINT [FK_CatalogMas_Vendor]
GO
ALTER TABLE [dbo].[GroupContactList]  WITH CHECK ADD  CONSTRAINT [FK_GroupContactList_AppUsers] FOREIGN KEY([RefAUId])
REFERENCES [dbo].[AppUsers] ([AUId])
GO
ALTER TABLE [dbo].[GroupContactList] CHECK CONSTRAINT [FK_GroupContactList_AppUsers]
GO
ALTER TABLE [dbo].[GroupContactList]  WITH CHECK ADD  CONSTRAINT [FK_GroupContactList_GroupMas] FOREIGN KEY([RefGroupId])
REFERENCES [dbo].[GroupMas] ([GroupId])
GO
ALTER TABLE [dbo].[GroupContactList] CHECK CONSTRAINT [FK_GroupContactList_GroupMas]
GO
ALTER TABLE [dbo].[GroupMas]  WITH CHECK ADD  CONSTRAINT [FK_ContactGroup_Vendor] FOREIGN KEY([RefVendorId])
REFERENCES [dbo].[Vendor] ([VendorId])
GO
ALTER TABLE [dbo].[GroupMas] CHECK CONSTRAINT [FK_ContactGroup_Vendor]
GO
ALTER TABLE [dbo].[MasterValue]  WITH CHECK ADD  CONSTRAINT [FK_MasterValue_MastersList] FOREIGN KEY([RefMasterId])
REFERENCES [dbo].[MastersList] ([Id])
GO
ALTER TABLE [dbo].[MasterValue] CHECK CONSTRAINT [FK_MasterValue_MastersList]
GO
ALTER TABLE [dbo].[MenuMaster]  WITH CHECK ADD  CONSTRAINT [FK_MenuMaster_MenuMaster] FOREIGN KEY([ID])
REFERENCES [dbo].[MenuMaster] ([ID])
GO
ALTER TABLE [dbo].[MenuMaster] CHECK CONSTRAINT [FK_MenuMaster_MenuMaster]
GO
ALTER TABLE [dbo].[MenuRoleRights]  WITH CHECK ADD  CONSTRAINT [FK_MenuRoleRights_MasterValue] FOREIGN KEY([RefRoleId])
REFERENCES [dbo].[MasterValue] ([ID])
GO
ALTER TABLE [dbo].[MenuRoleRights] CHECK CONSTRAINT [FK_MenuRoleRights_MasterValue]
GO
ALTER TABLE [dbo].[MenuRoleRights]  WITH CHECK ADD  CONSTRAINT [FK_MenuRoleRights_MenuMaster] FOREIGN KEY([RefMenuId])
REFERENCES [dbo].[MenuMaster] ([ID])
GO
ALTER TABLE [dbo].[MenuRoleRights] CHECK CONSTRAINT [FK_MenuRoleRights_MenuMaster]
GO
ALTER TABLE [dbo].[NotificationDet]  WITH CHECK ADD  CONSTRAINT [FK_NotificationDet_AppUsers] FOREIGN KEY([RefAppUserId])
REFERENCES [dbo].[AppUsers] ([AUId])
GO
ALTER TABLE [dbo].[NotificationDet] CHECK CONSTRAINT [FK_NotificationDet_AppUsers]
GO
ALTER TABLE [dbo].[NotificationDet]  WITH CHECK ADD  CONSTRAINT [FK_NotificationDet_NotificationDet] FOREIGN KEY([RefNotifyId])
REFERENCES [dbo].[NotificationMas] ([NotifyId])
GO
ALTER TABLE [dbo].[NotificationDet] CHECK CONSTRAINT [FK_NotificationDet_NotificationDet]
GO
ALTER TABLE [dbo].[ParameterMapping]  WITH CHECK ADD  CONSTRAINT [FK_ParameterMapping_MastersList] FOREIGN KEY([RefMasterId])
REFERENCES [dbo].[MastersList] ([Id])
GO
ALTER TABLE [dbo].[ParameterMapping] CHECK CONSTRAINT [FK_ParameterMapping_MastersList]
GO
ALTER TABLE [dbo].[ParameterMapping]  WITH CHECK ADD  CONSTRAINT [FK_ParameterMapping_MasterValue] FOREIGN KEY([RefVendorValId])
REFERENCES [dbo].[MasterValue] ([ID])
GO
ALTER TABLE [dbo].[ParameterMapping] CHECK CONSTRAINT [FK_ParameterMapping_MasterValue]
GO
ALTER TABLE [dbo].[ParameterMapping]  WITH CHECK ADD  CONSTRAINT [FK_ParameterMapping_MasterValue1] FOREIGN KEY([RefVendorValId])
REFERENCES [dbo].[MasterValue] ([ID])
GO
ALTER TABLE [dbo].[ParameterMapping] CHECK CONSTRAINT [FK_ParameterMapping_MasterValue1]
GO
ALTER TABLE [dbo].[ParameterMapping]  WITH CHECK ADD  CONSTRAINT [FK_ParameterMapping_Vendor] FOREIGN KEY([RefVendorId])
REFERENCES [dbo].[Vendor] ([VendorId])
GO
ALTER TABLE [dbo].[ParameterMapping] CHECK CONSTRAINT [FK_ParameterMapping_Vendor]
GO
ALTER TABLE [dbo].[ParameterMapping]  WITH CHECK ADD  CONSTRAINT [FK_ParameterMapping_Vendor1] FOREIGN KEY([RefStoreId])
REFERENCES [dbo].[Vendor] ([VendorId])
GO
ALTER TABLE [dbo].[ParameterMapping] CHECK CONSTRAINT [FK_ParameterMapping_Vendor1]
GO
ALTER TABLE [dbo].[ProductCategory]  WITH CHECK ADD  CONSTRAINT [FK_ProductCategory_Vendor] FOREIGN KEY([RefVendorId])
REFERENCES [dbo].[Vendor] ([VendorId])
GO
ALTER TABLE [dbo].[ProductCategory] CHECK CONSTRAINT [FK_ProductCategory_Vendor]
GO
ALTER TABLE [dbo].[ProductImgDet]  WITH CHECK ADD  CONSTRAINT [FK_ProductImgDet_ProductMas] FOREIGN KEY([RefProdId])
REFERENCES [dbo].[ProductMas] ([ProdId])
GO
ALTER TABLE [dbo].[ProductImgDet] CHECK CONSTRAINT [FK_ProductImgDet_ProductMas]
GO
ALTER TABLE [dbo].[ProductMas]  WITH CHECK ADD  CONSTRAINT [FK_ProductMas_Vendor] FOREIGN KEY([RefVendorId])
REFERENCES [dbo].[Vendor] ([VendorId])
GO
ALTER TABLE [dbo].[ProductMas] CHECK CONSTRAINT [FK_ProductMas_Vendor]
GO
ALTER TABLE [dbo].[StoreAssociation]  WITH CHECK ADD  CONSTRAINT [FK_StoreAssociation\_StoreAssociation\] FOREIGN KEY([Id])
REFERENCES [dbo].[StoreAssociation] ([Id])
GO
ALTER TABLE [dbo].[StoreAssociation] CHECK CONSTRAINT [FK_StoreAssociation\_StoreAssociation\]
GO
ALTER TABLE [dbo].[VendorAssociation]  WITH CHECK ADD  CONSTRAINT [FK_VendorAssociation_Vendor] FOREIGN KEY([RefVendorId])
REFERENCES [dbo].[Vendor] ([VendorId])
GO
ALTER TABLE [dbo].[VendorAssociation] CHECK CONSTRAINT [FK_VendorAssociation_Vendor]
GO
ALTER TABLE [dbo].[VendorAssociation]  WITH CHECK ADD  CONSTRAINT [FK_VendorAssociation_VendorAssociation] FOREIGN KEY([RefAUId])
REFERENCES [dbo].[AppUsers] ([AUId])
GO
ALTER TABLE [dbo].[VendorAssociation] CHECK CONSTRAINT [FK_VendorAssociation_VendorAssociation]
GO
ALTER TABLE [dbo].[VendorSlider]  WITH CHECK ADD  CONSTRAINT [FK_VendorSlider_Vendor] FOREIGN KEY([RefVendorId])
REFERENCES [dbo].[Vendor] ([VendorId])
GO
ALTER TABLE [dbo].[VendorSlider] CHECK CONSTRAINT [FK_VendorSlider_Vendor]
GO
ALTER TABLE [dbo].[WriteToUs]  WITH CHECK ADD  CONSTRAINT [FK_WriteToUs_AppUsers] FOREIGN KEY([RefAUId])
REFERENCES [dbo].[AppUsers] ([AUId])
GO
ALTER TABLE [dbo].[WriteToUs] CHECK CONSTRAINT [FK_WriteToUs_AppUsers]
GO
/****** Object:  StoredProcedure [dbo].[sp_AppLog_DailyAppVisitor]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 16/06/2016
-- Description:	Daily App Visitor
-- =============================================
CREATE PROCEDURE [dbo].[sp_AppLog_DailyAppVisitor]
	-- Add the parameters for the stored procedure here
	@pRefVendorId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Declare @tWeekWiseVisiorts Table (FromToDate nvarchar(50), VisitorCount int);
	Declare @dFromDate Date, @dToDate Date,@iCount int;
	Set @dFromDate = Cast(DateAdd(Day,1-DatePart(Weekday,GetDate()),GetDate()) as Date) 
	Set @dToDate =  Cast(GetDate() as Date)
	Declare @iNoofWeeks int = 4;
	
	While @iNoofWeeks != 0
	Begin
		Select @iCount = Count(*) From (
			Select RefAUId, Cast(InsDate as Date) InsDate 
			From AppLog 
			Where RefVendorId = @pRefVendorId
			and Cast(InsDate as Date) between @dFromDate and @dToDate
			and LogType = 'VendorLogin'
			Group By RefAUId, Cast(InsDate as Date) 
		) x

		Insert Into @tWeekWiseVisiorts Values(Cast(@dFromDate as nvarchar) +'/'+ Cast(@dToDate as nvarchar), @iCount)

		Set @dToDate = DateAdd(Day,-1,@dFromDate);
		Set @dFromDate = DateAdd(Day,-7,@dFromDate);

		Set @iNoofWeeks  = @iNoofWeeks - 1;
	End

	Select FromToDate, VisitorCount
	From @tWeekWiseVisiorts
END

GO
/****** Object:  StoredProcedure [dbo].[sp_AppLog_DailyAppVisitorPerDay]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 16/06/2016
-- Description:	Daily App Visitor
-- =============================================
CREATE PROCEDURE [dbo].[sp_AppLog_DailyAppVisitorPerDay]
	-- Add the parameters for the stored procedure here
	@pRefVendorId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Declare @tDailyWiseVisiorts Table (RefWeel nvarchar(50),DateValue Date, DayValue nvarchar(30), VisitorCount int);
	Declare @dFromDate Date, @dToDate Date,@iCount int, @dDateVal Date, @nRefWeek nvarchar(50);
	Set @dFromDate = Cast(DateAdd(Day,1-DatePart(Weekday,GetDate()),GetDate()) as Date) 
	Set @dToDate =  Cast(GetDate() as Date)
	Declare @iNoofWeeks int = 4;
	
	While @iNoofWeeks != 0
	Begin
		Set @nRefWeek  = Cast(@dFromDate as nvarchar) +'/'+ Cast(@dToDate as nvarchar)
		While @dToDate != DateAdd(Day,-1,@dFromDate)
		Begin
			Select @iCount = Count(*) From (
				Select RefAUId, Cast(InsDate as Date) InsDate
				From AppLog 
				Where RefVendorId = @pRefVendorId
				and Cast(InsDate as Date) = @dToDate  
				and LogType = 'VendorLogin'
				Group By RefAUId, Cast(InsDate as Date) 
			) x	

			Insert Into @tDailyWiseVisiorts  Values(@nRefWeek, @dToDate, datename(weekday,@dToDate) , @iCount)

			Set @dToDate = DateAdd(Day,-1,@dToDate);
		End

		Set @dToDate = DateAdd(Day,-1,@dFromDate);
		Set @dFromDate = DateAdd(Day,-7,@dFromDate);

		Set @iNoofWeeks  = @iNoofWeeks - 1;
	End

	Select *
	From @tDailyWiseVisiorts  
END

GO
/****** Object:  StoredProcedure [dbo].[sp_AppLog_Save]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 03/05/2016
-- Description:	Save Applog Detail
-- =============================================
CREATE PROCEDURE [dbo].[sp_AppLog_Save]
	-- Add the parameters for the stored procedure here
	@pRefAUId int ,
	@pRefVendorId int = null,
	@pLogType nvarchar(50),
	@pRefId int,
	@pLogDesc nvarchar(max) = null,
	@pUser int,
	@pTerminal nvarchar(60)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @Result int = 0;

    -- Insert statements for procedure here
	Insert Into AppLog (RefAUId ,	RefVendorId ,	LogType ,	RefId , LogDesc , InsUser , InsDate, InsTerminal )
	values (@pRefAUId ,	@pRefVendorId ,	@pLogType ,	@pRefId , @pLogDesc , @pUser , GetDate(),	@pTerminal )

	Select @Result = @@IDENTITY 

	Select @Result Result
END

GO
/****** Object:  StoredProcedure [dbo].[sp_AppUser_Save]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 16/04/2016
-- Description:	Save App USer Data
-- =============================================
CREATE PROCEDURE [dbo].[sp_AppUser_Save]
	-- Add the parameters for the stored procedure here
	@pAUId int = null,
	@pAUName nvarchar(100),
	@pCompanyName nvarchar(50),
	@pAddress nvarchar(100),
	@pLandMark nvarchar(100),
	@pCountry nvarchar(30),
	@pState nvarchar(30),
	@pCity nvarchar(30),
	@pPincode nvarchar(10),
	@pContactNo1 nvarchar(20),
	@pContactNo2 nvarchar(20),
	@pMobileNo1 nvarchar(20),
	@pMobileNo2 nvarchar(20),
	@pEmailId nvarchar(100),
	@pWebSite nvarchar(100),
	@pGCMID nvarchar(200),
	@pDeviceID nvarchar(50),
	@pDeviceOS nvarchar(10),
	@pIsActive bit,
	@pIsNotify bit,
	@pDefaultView nvarchar(20),
	@pAppUserImg nvarchar(200),
	@pUser int,
	@pTerminal nvarchar(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @vAUId int = null;

    -- Insert statements for procedure here

	If(Not Exists(Select * From AppUsers Where DeviceId = @pDeviceID and MobileNo1 = @pMobileNo1))
	Begin
		Insert Into AppUsers ( AUName, CompanyName, [Address], LandMark, Country,
			[State], City, Pincode, ContactNo1, ContactNo2, MobileNo1, MobileNo2,
			EmailId, WebSite, GCMID, DeviceID, DeviceOS, IsActive, IsNotify,DefaultView,
			AppUserImg,InsUser , InsDate, InsTerminal)
		Values (@pAUName, @pCompanyName, @pAddress, @pLandMark, @pCountry,
			@pState, @pCity, @pPincode, @pContactNo1, @pContactNo2, @pMobileNo1, @pMobileNo2,
			@pEmailId, @pWebSite, @pGCMID, @pDeviceID, @pDeviceOS, @pIsActive, @pIsNotify,@pDefaultView,
			@pAppUserImg,@pUser ,GETDATE(), @pTerminal)

		Select @vAUId = IDENT_CURRENT('AppUsers') 
	End
	Else
	Begin
		Update AppUsers 
		Set AUName = @pAUName,
			[Address] = @pAddress, 
			LandMark = @pLandMark,  
			Country = @pCountry,
			[State] = @pState, 
			City = @pCity,   
			Pincode = @pPincode, 
			ContactNo1 = @pContactNo1, 
			ContactNo2 = @pContactNo2,  			
			EmailId = @pEmailId, 
			WebSite = @pWebSite,
			--AppUserImg = @pAppUserImg,
			UpdUser  = @pUser, 
			UpdDate = GetDate(), 
			UpdTerminal = @pTerminal
		Where AUId = @pAUId 

		--Select @vAUId = AUId From AppUsers Where DeviceId = @pDeviceID and MobileNo1 = @pMobileNo1
		Set @vAUId = @pAUId;
	End

	Select @vAUId As Result
END

GO
/****** Object:  StoredProcedure [dbo].[sp_AppUser_Select]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 16/04/2016
-- Description:	Get App User Data base In AppUser Id
-- =============================================
CREATE PROCEDURE [dbo].[sp_AppUser_Select] 
	-- Add the parameters for the stored procedure here
	@pAUId int = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT a.AUId, a.AUName, a.CompanyName, IsNULL(a.[Address] ,'') [Address], IsNULL(a.LandMark,'') LandMark,
			IsNULL(a.Country,'') Country, IsNULL(a.[State],'') [State], IsNULL(a.City,'') City, 
			IsNULL(a.Pincode,'') Pincode, IsNULL(a.ContactNo1,'') ContactNo1, IsNULL(a.ContactNo2,'') ContactNo2,
			a.MobileNo1, IsNULL(a.MobileNo2,'') MobileNo2, IsNULL(a.EmailId,'') EmailId, 
			IsnULL(a.WebSite,'') WebSite, a.GCMID,
			a.DeviceID, a.DeviceOS, a.IsActive, a.IsNotify, a.DefaultView,
			IsNULL(a.AppUserImg,'') AppUserImg, IsNULL(a.RateUs ,0) RateUs ,
			a.InsUser, a.InsTerminal, a.InsDate,
			a.UpdUser, a.UpdTerminal, a.UpdDate
	From AppUsers a
	Where a.AUId = Case When @pAUId Is Null Then a.AUId Else @pAUId End
		
END

GO
/****** Object:  StoredProcedure [dbo].[sp_AppUser_SelectBaseOnVendor]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 23/05/2016
-- Description:	Select AppUser base on Vendor Association
-- =============================================
CREATE PROCEDURE [dbo].[sp_AppUser_SelectBaseOnVendor]
	-- Add the parameters for the stored procedure here
	@pSearch nvarchar(max),
	@pVendorStatus nvarchar(20),
	@pRefVendorId int,
	@pPageSize int = 10,
	@pPageIndex int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @Sql nvarchar(max) = '';
	Declare @defstr nvarchar(max) = '';

	if(@pSearch <> '' And @pSearch Is Not null)
	Begin
		Set @defstr = ' and ( a.AUName Like ''%'+ @pSearch +'%'' 
					or  a.CompanyName Like ''%'+ @pSearch +'%''
					or  a.City Like ''%'+ @pSearch +'%''
					or  a.State Like ''%'+ @pSearch +'%'') '
	End

	--Select a.AUId, a.AUName, a.CompanyName, a.[Address], a.LandMark,
	--	a.State, a.City, a.Country, a.Pincode, a.ContactNo1, a.ContactNo2, a.MobileNo1, 
	--	a.MobileNo2, a.AppUserImg, a.DeviceID, a.DeviceOS, a.GCMID, a.EmailId, 
	--	a.WebSite, a.DefaultView, a.IsActive, a.IsNotify, a.InsDate, a.InsTerminal, 
	--	a.InsUser, a.UpdUser, a.UpdDate, a.UpdTerminal,b.Id VendorAssociationId,
	--	b.VendorStatus, b.AppUserStatus,b.RateVendor,b.IsAdmin,b.IsAdminNotification,
	--	(Select Count(*) From EnquiryList c Where c.RefAUId = a.AUId) EnqCount
	--From AppUsers a
	--inner Join VendorAssociation b
	--on a.AUId = b.RefAUId
	--Where b.RefVendorId = @pRefVendorId 
	--and VendorStatus = @pVendorStatus 

    -- Insert statements for procedure here
	Set @Sql = 'Select a.AUId, a.AUName, a.CompanyName, a.[Address], a.LandMark,
		a.State, a.City, a.Country, a.Pincode, a.ContactNo1, a.ContactNo2, a.MobileNo1, 
		a.MobileNo2, a.AppUserImg, a.DeviceID, a.DeviceOS, a.GCMID, a.EmailId, 
		a.WebSite, a.DefaultView, a.IsActive, a.IsNotify, a.InsDate, a.InsTerminal, 
		a.InsUser, a.UpdUser, a.UpdDate, a.UpdTerminal,b.Id VendorAssociationId,
		b.VendorStatus, b.AppUserStatus,b.RateVendor,ISNULL(b.IsAdmin,0) IsAdmin,
		ISNULL(b.IsAdminNotification,0) IsAdminNotification, 
		(Select Count(*) From EnquiryList c Where c.RefAUId = a.AUId and c.RefVendorId = b.RefVendorId) EnqCount
	From AppUsers a
	inner Join VendorAssociation b
	on a.AUId = b.RefAUId
	Where b.RefVendorId = ' + Cast(@pRefVendorId as nvarchar) + ' 
	and (AppUserStatus <> ''Cancelled'' and AppUserStatus <> ''Deleted'')
	and VendorStatus = ' + Case When @pVendorStatus = 'All' Then  'b.VendorStatus' Else '''' + @pVendorStatus + '''' End + '
	' + @defstr + '
	Order By a.AUId
	OFFSET ' + Cast(@pPageSize * @pPageIndex as nvarchar) +' Rows
	Fetch Next '+Cast(@pPageSize as nvarchar) +' Rows ONLY OPTION (RECOMPILE)'

	Print @Sql;

	exec sp_executesql @Sql;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_AppUser_SelectWhere]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 16/04/2016
-- Description:	Get App User Data base on Device Id
-- =============================================
CREATE PROCEDURE [dbo].[sp_AppUser_SelectWhere] 
	-- Add the parameters for the stored procedure here
	@pDeviceId nvarchar(100) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @nAppVersion numeric(5,2) 
	Select top 1 @nAppVersion = AppVersion From CompanyProfile

    -- Insert statements for procedure here
	SELECT a.AUId, a.AUName, a.CompanyName, a.[Address], a.LandMark,
			a.Country, a.[State], a.City, a.Pincode, a.ContactNo1, a.ContactNo2,
			a.MobileNo1, a.MobileNo2, a.EmailId, a.WebSite, a.GCMID,
			a.DeviceID, a.DeviceOS, a.IsActive, a.IsNotify, a.DefaultView,
			a.AppUserImg,IsNULL(a.RateUs,0) RateUs, @nAppVersion AppVersion,
			a.InsUser, a.InsTerminal, a.InsDate,
			a.UpdUser, a.UpdTerminal, a.UpdDate
	From AppUsers a
	Where a.DeviceId = @pDeviceId
		
END

GO
/****** Object:  StoredProcedure [dbo].[sp_CatalogMas_Filter]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 26/04/2016
-- Description:	Get Catalog detail base on filetr (Producttype, Febaric, Design, ProductCategory)
-- =============================================
CREATE PROCEDURE [dbo].[sp_CatalogMas_Filter]
	-- Add the parameters for the stored procedure here
	@pRefVendorId int,
	@pRefCategory nvarchar(30),
	@pCatCode nvarchar(30) = null,
	@pPageSize int = 10,
	@pPageIndex int = 0,
	@pRefProdType nvarchar(max) = null,
	@pRefFabric nvarchar(max) = null,
	@pRefDesign nvarchar(max) = null,
	@pRefBrand nvarchar(max) = null,
	@pStartPrice numeric(18,2) = 0,
	@pEndPrice numeric(18,2) = null,
	@pFullSet bit = 0,
	@pOrderBy nvarchar(5) = 'LD'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @vMainPath nvarchar(max) = null
	Select Top 1 @vMainPath = FolderPath From CompanyProfile 

	--Declare @vStrOrderby nvarchar(max) = null
	--if(@pOrderBy = 'LD')
	--	Set @vStrOrderby = ' R.CatLaunchDate Desc ';
	--else if(@pOrderBy = 'LHP')
	--	Set @vStrOrderby = ' R.TotalPrice, R.CatLaunchDate Desc ';
	--else if(@pOrderBy = 'HLP')
	--	Set @vStrOrderby = ' R.TotalPrice Desc, R.CatLaunchDate Desc ';

	if(@pEndPrice Is NULL)
	Begin
		Select @pStartPrice  = Min(FinalPrice),
		@pEndPrice  = Max(FinalPrice) From (
		Select SUM(ISNULL(a.WholeSalePrice,0)) as FinalPrice
		From ProductMas a
		Inner Join CatalogMas b
		On a.RefCatId = b.CatId
		Where a.RefVendorId = @pRefVendorId
		and a.RefProdCategory = @pRefCategory ) R
	End

	--1	Brand
	--2	Color
	--3	ProdType
	--4	Size
	--5	Fabric
	--6	Design

	--Product Type filter data
	Declare @tProdType Table (Item nvarchar(50));
	if(@pRefProdType IS null)
	Begin
		Insert Into @tProdType (Item)
		Select ValueName
		From MasterValue 
		Where RefMasterId = 3 and RefVendorId In (@pRefVendorId,0)
	End
	Else
	Begin
		Insert Into @tProdType (Item)
		Select Item
		From SplitString(@pRefProdType,',') 
	End

	--Brand filter data
	Declare @tBrand Table (Item nvarchar(50));
	if(@pRefBrand IS null)
	Begin
		Insert Into @tBrand (Item)
		Select ValueName
		From MasterValue 
		Where RefMasterId = 1 and RefVendorId In (@pRefVendorId,0)
	End
	Else
	Begin
		Insert Into @tBrand (Item)
		Select Item
		From SplitString(@pRefBrand,',') 
	End

	--Fabric filter data
	Declare @tFabric Table (Item nvarchar(50));
	if(@pRefFabric IS null)
	Begin
		Insert Into @tFabric  (Item)
		Select ValueName
		From MasterValue 
		Where RefMasterId = 5 and RefVendorId In (@pRefVendorId,0)
	End
	Else
	Begin
		Insert Into @tFabric  (Item)
		Select Item
		From SplitString(@pRefFabric,',') 
	End

	--Design filter data
	Declare @tDesign Table (Item nvarchar(50));
	if(@pRefDesign IS null)
	Begin
		Insert Into @tDesign (Item)
		Select ValueName
		From MasterValue 
		Where RefMasterId = 6 and RefVendorId In (@pRefVendorId,0)
	End
	Else
	Begin
		Insert Into @tDesign (Item)
		Select Item
		From SplitString(@pRefDesign,',') 
	End

    -- Insert statements for procedure here

	Select * 
	From(
	Select a.CatCode, a.CatDescription, a.CatId, 
		a.CatImg, a.CatLaunchDate,
		(@vMainPath + Cast(@pRefVendorId as nvarchar) + '/Catalog/Original/' +a.CatImg)  OriginalImgPath, 
		(@vMainPath + Cast(@pRefVendorId as nvarchar)+ '/Catalog/Thumbnail/' +a.CatImg) ThumbnailImgPath,
		a.CatName, a.RefVendorId, 
		(Select b.VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName,
		Count(c.ProdId) TotalProduct, SUM(ISNULL(c.WholeSalePrice, 0 )) TotalPrice, a.IsFullset
	From CatalogMas a
	Inner Join ProductMas c
	On a.CatId = c.RefCatId
	Where a.RefVendorId = @pRefVendorId
	and c.RefProdCategory  = @pRefCategory  
	and a.CatCode Like Case When @pCatCode Is Null Then a.CatCode Else @pCatCode+'%' End
	and c.RefProdType In ( Select Upper(Item) From @tProdType)
	and c.RefFabric In ( Select Upper(Item) From @tFabric)
	and c.RefDesign In ( Select Upper(Item) From @tDesign)
	and c.RefBrand In ( Select Upper(Item) From @tBrand)
	and a.IsActive = 1
	Group By a.CatId, a.CatCode, a.CatDescription, a.CatImg, a.CatName, a.RefVendorId,a.CatLaunchDate,a.IsFullset
	) 
	R
	Where R.TotalPrice between @pStartPrice and  @pEndPrice 
	and R.IsFullset = Case When @pFullSet = 0 Then R.IsFullset Else @pFullSet End
	Order BY
	Case When @pOrderBy = 'LHP' Then R.TotalPrice End,
	Case When @pOrderBy = 'HLP' Then R.TotalPrice End Desc,
	Case When @pOrderBy = 'LD' or @pOrderBy <> 'LD' Then R.CatLaunchDate End Desc 
	OFFSET @pPageSize * @pPageIndex ROWS
	FETCH NEXT @pPageSize ROWS ONLY OPTION (RECOMPILE)

	Declare @Sql nvarchar(max) = null

END

GO
/****** Object:  StoredProcedure [dbo].[sp_CatalogMas_Save]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 30/04/2016
-- Description:	Save Catalog Detail
-- =============================================
CREATE PROCEDURE [dbo].[sp_CatalogMas_Save]
	-- Add the parameters for the stored procedure here
	@pCatId int = null,
	@pRefVendorId int = null,
	@pCatCode nvarchar(100),
	@pCatName nvarchar(200),
	@pCatDescription nvarchar(1000),
	@pCatImg nvarchar(400),
	@pCatLaunchDate DateTime,
	@pIsFullset bit,
	@pIsActive bit,
	@pUser int,
	@pTerminal nvarchar(60)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @ResultId int = 0; 
    -- Insert statements for procedure here
	if(Not Exists (Select * From CatalogMas Where CatId = @pCatId) )
	Begin
		Insert Into CatalogMas (RefVendorId, CatCode, CatName, CatDescription, CatImg, CatLaunchDate, IsFullset
		,IsActive, InsUser, InsDate, InsTerminal)
		Values (@pRefVendorId,@pCatCode, @pCatName, @pCatDescription, @pCatImg, @pCatLaunchDate, @pIsFullset, 
			@pIsActive ,@pUser, GetDate(), @pTerminal);

		Select @ResultId = @@IDENTITY 
	End
	Else
	Begin
		Update CatalogMas
		Set CatCode = @pCatCode, 
			CatName = @pCatName, 
			CatDescription = @pCatDescription, 
			CatLaunchDate = @pCatLaunchDate, 
			IsFullset = @pIsFullset, 
			IsActive = @pIsActive ,
			--RefStoreId = null,
			UpdUser = @pUser, 
			UpdDate = GetDate(), 
			UpdTerminal = @pTerminal
		Where CatId = @pCatId

		Set @ResultId = @pCatId 
	End

	Select @ResultId Result
END

GO
/****** Object:  StoredProcedure [dbo].[sp_CatalogMas_Select]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		JayamSoft
-- Create date: 26/04/2016
-- Description:	Get Catalog detail base on vendor and category
-- =============================================
CREATE PROCEDURE [dbo].[sp_CatalogMas_Select]
	-- Add the parameters for the stored procedure here
	@pRefVendorId int = null,
	@pRefCategory nvarchar(30)= null,
	@pLastDate date = null,
	@pPageSize int = 10,
	@pPageIndex int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @vMainPath nvarchar(max) = null
	Select Top 1 @vMainPath =  FolderPath  From CompanyProfile 

    -- Insert statements for procedure here
	Select a.CatCode, a.CatDescription, 
		a.CatId, a.CatImg, a.CatLaunchDate,a.IsFullset,
		--(@vMainPath + Cast(@pRefVendorId as varchar) + '/Catalog/Original/' +a.CatImg)  OriginalImgPath, 
		isnull(STUFF((Select Distinct ','  + p.RefProdCategory  From ProductMas p Where p.RefCatId = a.CatId and p.IsActive  = 1 and p.ActiveTillDate>= cast(getdate() as date)
		FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,' '),'') RefProdCategory, 
		'' RefColor,isnull(STUFF((Select Distinct ','  + p.RefProdType From ProductMas p Where p.RefCatId = a.CatId and p.IsActive  = 1 and p.ActiveTillDate>= cast(getdate() as date)
		FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,' '),'')  RefProdType, 
		'' RefSize,isnull(STUFF((Select Distinct ','  + p.RefFabric From ProductMas p Where p.RefCatId = a.CatId and p.IsActive  = 1 and p.ActiveTillDate>= cast(getdate() as date)
		FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,' '),'')  RefFabric,
		isnull(STUFF((Select Distinct ','  + p.RefDesign  From ProductMas p Where p.RefCatId = a.CatId and p.IsActive  = 1 and p.ActiveTillDate>= cast(getdate() as date)
		FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,' '),'')  RefDesign,
		(Case When a.RefStoreId Is NULL 
		Then (@vMainPath + Cast(@pRefVendorId as varchar)+ '/Catalog/Thumbnail/' +a.CatImg) 
		Else (@vMainPath + 'Global/Catalog/Thumbnail/' + a.CatImg) End) ThumbnailImgPath,
		a.CatName, a.RefVendorId, 
		(Select VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName,
		isnull(c.RefBrand,'') RefBrand,isnull(c.TotalProduct,0) TotalProduct, isnull(c.TotalPrice,0) TotalPrice ,
		isnull(c.TotalRetailPrice,0) TotalRetailPrice, isnull(c.AvgWholeSalePrice,0) AvgWholeSalePrice 
		--MIN(c.RefBrand) RefBrand,
		--Count(c.ProdId) TotalProduct, SUM(ISNULL(c.WholeSalePrice, 0 )) TotalPrice,
		--SUM(ISNULL(c.RetailPrice, 0 )) TotalRetailPrice,(SUM(ISNULL(c.WholeSalePrice, 0 ))/Count(c.ProdId)) AvgWholeSalePrice 
	From CatalogMas a
	inner Join  (select  RefCatId,RefProdCategory,MIN(cc.RefBrand) RefBrand,Count(cc.ProdId) TotalProduct, SUM(ISNULL(cc.WholeSalePrice, 0 )) TotalPrice,
							SUM(ISNULL(cc.RetailPrice, 0 )) TotalRetailPrice,(SUM(ISNULL(cc.WholeSalePrice, 0 ))/Count(cc.ProdId)) AvgWholeSalePrice 
				 from	ProductMas cc
				 where  cc.isActive = 1
				group by RefCatId,RefProdCategory ) c
	On a.CatId = c.RefCatId
	Where a.RefVendorId = @pRefVendorId
	and c.RefProdCategory = Case When @pRefCategory Is NULL Then c.RefProdCategory Else @pRefCategory End
	and a.IsActive = 1
	and (a.InsDate >= (Case When @pLastDate Is NULL Then a.InsDate Else @pLastDate End) or a.UpdDate >= (Case When @pLastDate Is NULL Then a.UpdDate Else @pLastDate End)) 
	--Group By a.CatId, a.CatCode, a.CatDescription, a.CatImg, a.CatName, a.RefVendorId,a.CatLaunchDate, a.IsFullset,a.RefStoreId
	Order BY a.CatLaunchDate Desc,a.CatId Desc
	OFFSET @pPageSize * @pPageIndex ROWS
	FETCH NEXT @pPageSize ROWS ONLY OPTION (RECOMPILE)

END



GO
/****** Object:  StoredProcedure [dbo].[sp_CatalogMas_SelectForAdmin]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 26/04/2016
-- Description:	Get Catalog detail base on vendor and category
-- =============================================
CREATE PROCEDURE [dbo].[sp_CatalogMas_SelectForAdmin]
	-- Add the parameters for the stored procedure here
	@pRefVendorId int = null,
	@pSearchvalue nvarchar(max) = '',
	@pPageSize int = 10,
	@pPageIndex int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @StrWhere nvarchar(max) = '';
	if(@pSearchvalue Is NOT NULL And @pSearchvalue <> '')
	Begin
		Set @StrWhere = ' and (R.CatCode Like ''%'+ @pSearchvalue +'%'' 
			or R.CatName Like ''%'+ @pSearchvalue +'%''
			or R.RefProdCategory Like ''%'+ @pSearchvalue +'%'') ';
	End

	Declare @vMainPath nvarchar(max) = null
	Select Top 1 @vMainPath = FolderPath From CompanyProfile 

    -- Insert statements for procedure here
	--Select a.CatCode, a.CatDescription, a.CatId, 
	--	a.CatImg, c.RefProdCategory,
	--	(Case When a.RefStoreId Is NULL Then (@vMainPath + Cast(@pRefVendorId as varchar) + '/Catalog/Original/' +a.CatImg) 
	--	Else (@vMainPath + 'Global/Catalog/Original/' +a.CatImg) End) OriginalImgPath, 
	--	(Case When a.RefStoreId Is NULL Then (@vMainPath + Cast(@pRefVendorId as varchar) + '/Catalog/Thumbnail/' +a.CatImg) 
	--	When a.RefStoreId Is Not NULL Then (@vMainPath + 'Global/Catalog/Thumbnail/' +a.CatImg) 
	--	When (Select Top 1 v.BGImage From Vendor v Where v.VendorId = a.RefVendorId) Is Not NULL
	--	Then (@vMainPath + Cast(a.RefStoreId as varchar) + '/ThumbCata' + (Select Top 1 v.BGImage From Vendor v Where v.VendorId = a.RefVendorId))  
	--	Else '\Content\dist\img\CatalogueNoImage.png' End) ThumbnailImgPath,
	--	a.CatName, a.RefVendorId, a.IsActive,a.IsFullset,
	--	(Select VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName,
	--	Count(c.ProdId) TotalProduct, SUM(ISNULL(c.WholeSalePrice, 0 )) TotalPrice, a.CatLaunchDate
	--From CatalogMas a
	--Inner Join ProductMas c
	--On a.CatId = c.RefCatId
	--Where a.RefVendorId = @pRefVendorId
	--Group By a.CatId, a.CatCode, a.CatDescription, a.CatImg, a.CatName, a.RefVendorId,a.CatLaunchDate,c.RefProdCategory,a.RefStoreId,a.IsActive,a.IsFullset
	--Order BY a.CatLaunchDate Desc
	--OFFSET @pPageSize * @pPageIndex ROWS
	--FETCH NEXT @pPageSize ROWS ONLY OPTION (RECOMPILE)

	print @StrWhere

	Declare @Sql nvarchar(max) = null;
	Set @Sql = 'Select * From (
	Select a.CatCode, Cast(a.CatDescription as nvarchar(50)) + ''...'' CatDescription , a.CatId, 
		a.CatImg, c.RefProdCategory,
		(Case When a.RefStoreId Is NULL 
		Then (''' + @vMainPath + Cast(@pRefVendorId as varchar) + '''+''/Catalog/Original/'' + a.CatImg) 
		Else ('''+ @vMainPath + ''' + ''Global/Catalog/Original/'' + a.CatImg) End) OriginalImgPath, 
		(Case When a.RefStoreId Is NULL and a.CatImg Is Not NULL
		Then (''' + @vMainPath + Cast(@pRefVendorId as varchar)  + ''' + ''/Catalog/Thumbnail/'' +a.CatImg) 
		When a.RefStoreId Is Not NULL and a.CatImg Is Not NULL 
		Then  ('''+@vMainPath +'''+''Global/Catalog/Thumbnail/'' + a.CatImg) 
		When (Select Top 1 v.BGImage From Vendor v Where v.VendorId = a.RefVendorId) Is Not NULL
		Then (''' + @vMainPath +'''+ Cast(a.RefVendorId as varchar) + ''/ThumbCata'' + (Select Top 1 v.BGImage From Vendor v Where v.VendorId = a.RefVendorId)) 
		Else ''\Content\dist\img\CatalogueNoImage.png'' End) ThumbnailImgPath,
		a.CatName, a.RefVendorId, a.IsActive,a.IsFullset,
		(Select VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName,
		Count(c.ProdId) TotalProduct, SUM(ISNULL(c.WholeSalePrice, 0 )) TotalPrice, a.CatLaunchDate
	From CatalogMas a
	Left Join ProductMas c
	On a.CatId = c.RefCatId
	Where a.RefVendorId = ' + Cast(@pRefVendorId as varchar)+ ' 
	Group By a.CatId, a.CatCode, a.CatDescription, a.CatImg, a.CatName, a.RefVendorId,a.CatLaunchDate,c.RefProdCategory,a.RefStoreId,a.IsActive,a.IsFullset) R
	Where 1=1 ' + @StrWhere  + ' 
	Order BY R.CatLaunchDate Desc, R.CatCode
	OFFSET ' +Cast(@pPageSize * @pPageIndex as varchar)+ ' ROWS
	FETCH NEXT ' + Cast(@pPageSize as varchar)+ ' ROWS ONLY OPTION (RECOMPILE)'

	print @Sql

	exec sp_executesql @Sql
END

GO
/****** Object:  StoredProcedure [dbo].[sp_CatalogMas_SelectWhere]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 26/04/2016
-- Description:	Get Catalog detail base on filetr (Producttype, Febaric, Design, ProductCategory)
-- =============================================
CREATE PROCEDURE [dbo].[sp_CatalogMas_SelectWhere]
	-- Add the parameters for the stored procedure here
	@pdefstr nvarchar(max) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @vMainPath nvarchar(max) = null
	Select Top 1 @vMainPath = FolderPath From CompanyProfile 

    -- Insert statements for procedure here

	--Select a.CatId, a.CatCode, a.CatName, a.CatDescription, 
	--	a.RefVendorId, 
	--	(Select b.VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName, 
	--	a.CatImg, a.CatLaunchDate,
	--	(Case When a.RefStoreId Is NULL Then (@vMainPath + Cast(a.RefVendorId as nvarchar) + '/Catalog/Original/' +a.CatImg)  
	--	Else (@vMainPath   + 'Global/' + Cast(a.RefStoreId as nvarchar) + '/Catalog/Original/' +a.CatImg) End) OriginalImgPath, 
	--	(Case When a.RefStoreId Is NULL Then (@vMainPath + Cast(a.RefVendorId as nvarchar) + '/Catalog/Thumbnail/' +a.CatImg)  
	--	Else (@vMainPath   + 'Global/' + Cast(a.RefStoreId as nvarchar) + '/Catalog/Thumbnail/' +a.CatImg) End) ThumbnailImgPath,
	--	a.IsFullset, a.IsActive,InsUser, InsDate, InsTerminal, UpdUser, UpdDate, UpdTerminal
	--From CatalogMas a

	Declare @Sql nvarchar(max);

	Set @Sql  = 'Select * 
	From(
	Select a.CatId, a.CatCode, a.CatName, a.CatDescription, 
		a.RefVendorId, 
		(Select b.VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName, 
		a.CatImg, a.CatLaunchDate,
		(Case When a.RefStoreId Is NULL 
		Then (''' + @vMainPath + '''+ Cast(a.RefVendorId as nvarchar) + ''/Catalog/Original/'' +a.CatImg)  
		Else (''' + @vMainPath + ''' + ''Global/Catalog/Original/'' +a.CatImg) End) OriginalImgPath, 
		(Case When a.RefStoreId Is NULL 
		Then ('''+@vMainPath + ''' + Cast(a.RefVendorId as nvarchar) + ''/Catalog/Thumbnail/'' +a.CatImg)  
		Else (''' + @vMainPath +'''  + ''Global/Catalog/Thumbnail/'' +a.CatImg) End) ThumbnailImgPath,
		a.IsFullset, a.IsActive,InsUser, InsDate, InsTerminal, UpdUser, UpdDate, UpdTerminal
	From CatalogMas a
	) 
	R
	Where 1=1 ' + @pdefstr  

	exec sp_executesql @Sql
END

GO
/****** Object:  StoredProcedure [dbo].[sp_CatatlogMas_SelectBaseOnCatId]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 30/04/2016
-- Description:	Get Catalog data on catalog uniqueid
-- =============================================
CREATE PROCEDURE [dbo].[sp_CatatlogMas_SelectBaseOnCatId]
	-- Add the parameters for the stored procedure here
	@pCatId int = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @vMainPath nvarchar(max) = '';
	Select top 1 @vMainPath = FolderPath From CompanyProfile 

    -- Insert statements for procedure here
	Select a.CatId, a.RefVendorId, (Select b.VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName,
	a.CatCode, a.CatName, 
	(Case When a.RefStoreId Is NULL 
	Then (@vMainPath + Cast(a.RefVendorId as nvarchar) + '/Catalog/Original/' +a.CatImg)  
	Else (@vMainPath   + 'Global/Catalog/Original/' +a.CatImg) End) OriginalImgPath, 
	(Case When a.RefStoreId Is NULL 
	Then (@vMainPath + Cast(a.RefVendorId as nvarchar) + '/Catalog/Thumbnail/' +a.CatImg)  
	Else (@vMainPath   + 'Global/Catalog/Thumbnail/' +a.CatImg) End) ThumbnailImgPath,
	a.CatDescription, a.CatImg,a.CatLaunchDate,IsNULL(a.IsFullset,0) IsFullset,a.IsActive,
	a.InsUser ,a.InsDate, a.InsTerminal, a.UpdUser,a.UpdDate, a.UpdTerminal
	From CatalogMas a
	Where a.CatId = Case When @pCatId Is NULL Then a.CatId Else @pCatId End
END

GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteLog_Save]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 13/06/2016
-- Description:	Save DeleteLog
-- =============================================
CREATE PROCEDURE [dbo].[sp_DeleteLog_Save]
	-- Add the parameters for the stored procedure here
	@pRefVendorId int,
	@pFlag nvarchar(50),
	@pRId int,
	@pTerminal nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Insert Into DeleteLog (RefVendorId , Flag, RId, InsUser, InsDate, InsTerminal)
	Values (@pRefVendorId , @pFlag, @pRId, @pRefVendorId, GETDATE(), @pTerminal)

	Select Cast(1 as bit) Result
END

GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteLog_SelectBaseOnDate]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		JayamSoft	
-- Create date: 13/06/2016
-- Description:	Deletelog data select base on date
-- =============================================
CREATE PROCEDURE [dbo].[sp_DeleteLog_SelectBaseOnDate]
	-- Add the parameters for the stored procedure here
	@pRefVendorId int,
	@pFlag nvarchar(10),
	@pLastDate date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @DelLog table (RId int );
	if (@pFlag= 'Catalog')
	begin
		--Update and Catalogue launch date is changed at that time send data as deleted.
		insert into @DelLog	
		select a.catid from catalogmas a
		where	a.refVendorid = @pRefVendorId
				and (a.InsDate >= (Case When @pLastDate Is NULL Then a.InsDate Else @pLastDate End) or 
					a.UpdDate >= (Case When @pLastDate Is NULL Then a.UpdDate Else @pLastDate End))
				and a.catlaunchDate > cast(getdate() as date);

		--Catalogue is marked as inactive at that time send data as deleted.
		insert into @DelLog	
		select catid from catalogmas a
		where	a.refVendorid = @pRefVendorId
				and (a.InsDate >= (Case When @pLastDate Is NULL Then a.InsDate Else @pLastDate End) or 
					a.UpdDate >= (Case When @pLastDate Is NULL Then a.UpdDate Else @pLastDate End))
				and a.IsActive = 0;

		insert into @DelLog	
		select catid from catalogmas a
		where	a.refVendorid = @pRefVendorId
				and (a.InsDate >= (Case When @pLastDate Is NULL Then a.InsDate Else @pLastDate End) or 
					a.UpdDate >= (Case When @pLastDate Is NULL Then a.UpdDate Else @pLastDate End))
				and a.IsActive = 1
				and 0 = (select isnull(count(1),0) from productmas as aa where aa.refCatid = a.catid and aa.isActive = 1 )
	end
	if (@pFlag= 'Product')
	begin
		--Update and Catalogue launch date is changed at that time send product as deleted.
		insert into @DelLog	
		select	p.ProdId from	productmas p
		where	p.refCatid in (select catid from catalogmas a
							 where	a.refVendorid = @pRefVendorId
									and (a.InsDate >= (Case When @pLastDate Is NULL Then a.InsDate Else @pLastDate End) or 
										 a.UpdDate >= (Case When @pLastDate Is NULL Then a.UpdDate Else @pLastDate End))
									and a.catlaunchDate > cast(getdate() as date))

		--Catalogue is marked as inactive at that time send product data as deleted.
		insert into @DelLog	
		select	p.ProdId from	productmas p
		where	p.refCatid in (select catid from catalogmas a
							 where	a.refVendorid = @pRefVendorId
									and (a.InsDate >= (Case When @pLastDate Is NULL Then a.InsDate Else @pLastDate End) or 
										 a.UpdDate >= (Case When @pLastDate Is NULL Then a.UpdDate Else @pLastDate End))
									and a.IsActive = 0)
		--When active till date is lessthen current date then remove from list.
		insert into @DelLog	
		select	ProdId from	productmas
		where	ActiveTillDate < cast(getdate()  as date) and
				ActiveTillDate >= (Case When @pLastDate Is NULL Then ActiveTillDate Else @pLastDate End)

		--When make product from active to inactive
		insert into @DelLog	
		select	ProdId from	productmas p
		where	p.IsActive = 0
				and (p.InsDate >= (Case When @pLastDate Is NULL Then p.InsDate Else @pLastDate End) or 
					 p.UpdDate >= (Case When @pLastDate Is NULL Then p.UpdDate Else @pLastDate End))
	end

	Select	a.RId
	From	DeleteLog a
	Where	a.RefVendorId = @pRefVendorId
			and a.Flag = @pFlag
			and a.InsDate >= Cast(@pLastDate as Date)
	union 
	select RId from @DelLog
END



GO
/****** Object:  StoredProcedure [dbo].[sp_EnquiryList_Save]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 14/05/2016
-- Description:	Save Enquiry Detail
-- =============================================
CREATE PROCEDURE [dbo].[sp_EnquiryList_Save]
	-- Add the parameters for the stored procedure here
	@pId int,
	@pRefAUId int,
	@pRefVendorId int,
	@pRefProdId int = null,
	@pRefCatId int = null,
	@pRemark nvarchar(150),
	@pRepRemark nvarchar(1000) = null, 
	@pStatus nvarchar(1) --(P-Pending/R-Replied/C-Cancel)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if(@pStatus = 'P')
	Begin
		If(@pRefProdId Is NOT NULL)
		Begin
			Select @pRefCatId = RefCatId From ProductMas Where ProdId = @pRefProdId;
		End

		INsert Into EnquiryList (RefAUId, RefVendorId , RefProdId, RefCatId, Remark, [Status], EnquiryDate)
		Values (@pRefAUId, @pRefVendorId , @pRefProdId, @pRefCatId, @pRemark, @pStatus, GETDATE())

		Select 'Enquiry sent successfully!' Result
	End
	else if(@pStatus = 'R')
	Begin
		if(@pRefAUId = 0)
		Begin
			Select 'Please pass proper user id!' Result
			return;
		End

		Update EnquiryList 
		Set RepRemark = @pRepRemark,
			[Status]  = @pStatus,
			EnquiryRepDate = GETDATE(),
			RefRepAUId = @pRefAUId 
		Where Id = @pId 

		Select 'Enquiry replay sent successfully!' Result
	End
	else if(@pStatus = 'C')
	Begin
		
		Update EnquiryList 
		Set [Status] = @pStatus
		Where RefAUId = @pRefAUId 
		and RefVendorId = @pRefVendorId 
		and RefProdId = @pRefProdId

		Select 'Enquiry canceled by user!' Result
	End
END

GO
/****** Object:  StoredProcedure [dbo].[sp_EnquiryList_SelectForAPI]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 14/05/2016
-- Description:	Select Enqi=uiry list base in appuser (For API)
-- =============================================
CREATE PROCEDURE [dbo].[sp_EnquiryList_SelectForAPI]
	-- Add the parameters for the stored procedure here
	@pRefAUId int = null,
	@pRefVendoreId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @MainPath nvarchar(50) = '';
	Select top 1 @MainPath  = FolderPath From CompanyProfile 

    -- Insert statements for procedure here
	Select a.Id, a.RefAUId, (select u.AUName from AppUsers u Where u.AUId = a.RefAUId) AUName,
	(select u.MobileNo1 from AppUsers u Where u.AUId = a.RefAUId) MobileNo,
	(select u.CompanyName from AppUsers u Where u.AUId = a.RefAUId) CompanyName,
	a.RefVendorId,(Select b.VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName, 
	ISNULL(a.RefProdId,0) RefProdId, IsNULL(c.ProdCode,'') ProdCode, IsNULL(c.ProdName,'') ProdName, 
	ISNULL((Case When a.RefProdId Is Not NULL 
	Then c.RefFabric 
	Else STUFF((Select Distinct ',' + p.RefFabric From ProductMas p Where p.RefCatId = e.CatId
		FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,' ') End),'') Fabric,
	ISNULL((Case When a.RefProdId Is Not NULL 
	Then c.RefColor
	Else STUFF((Select Distinct ','  + p.RefColor From ProductMas p Where p.RefCatId = e.CatId
		FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,' ') End),'') Color,
	ISNULL((Case When a.RefProdId Is Not NULL and  (Select Top 1 IsNULL(x.IsGlobal,0) From ProductImgDet x Where x.RefProdId = a.RefProdId ORder By x.Ord) = 0
	Then (@MainPath + Cast(a.RefVendorId as nvarchar) + '/Products/Thumbnail/' + (Select Top 1 x.ImgName From ProductImgDet x Where x.RefProdId = a.RefProdId ORder By x.Ord)) 
	When a.RefProdId Is Not NULL and  (Select Top 1 IsNULL(x.IsGlobal,0) From ProductImgDet x Where x.RefProdId = a.RefProdId ORder By x.Ord) = 1
	Then (@MainPath + 'Global/Products/Thumbnail/' + (Select Top 1 x.ImgName From ProductImgDet x Where x.RefProdId = a.RefProdId ORder By x.Ord)) 
	When a.RefCatId Is Not NULL and  (Select Top 1 x.RefStoreId From CatalogMas x Where x.CatId = a.RefCatId) Is NULL and (Select Top 1 x.CatImg From CatalogMas x Where x.CatId = a.RefCatId) IS NOT NULL
	Then (@MainPath + Cast(a.RefVendorId as nvarchar) + '/Catalog/Thumbnail/' + (Select Top 1 x.CatImg From CatalogMas x Where x.CatId = a.RefCatId))
	When a.RefCatId Is Not NULL and  (Select Top 1 x.RefStoreId From CatalogMas x Where x.CatId = a.RefCatId) Is Not NULL and (Select Top 1 x.CatImg From CatalogMas x Where x.CatId = a.RefCatId) IS NOT NULL
	Then (@MainPath + 'Global/Catalog/Thumbnail/' + (Select Top 1 x.CatImg From CatalogMas x Where x.CatId = a.RefCatId)) 
	Else (@MainPath + Cast(a.RefVendorId as nvarchar)  + '/ThumbProd' + (Select Top 1 BGImage From Vendor Where VendorId = a.RefVendorId)) End),'')ThumbnailImgPath,
	IsNULL(e.CatId,0) CatId,ISNULL(e.CatCode,'') CatCode,ISNULL(e.CatName,'') CatName,
	c.RetailPrice, (Select Sum(z.WholeSalePrice) From ProductMas z Where z.RefCatId = a.RefCatId) WholeSalePrice,
	IsNULL(a.Remark,'') Remark,Cast(a.EnquiryDate as Datetime) EnquiryDate,
	a.[Status],ISNULL(a.RepRemark,'') RepRemark,a.EnquiryRepDate,
	a.RefRepAUId, Case When a.RefRepAUId Is NULL Then 'Admin' Else (Select u.AUName From AppUsers u Where u.AUId = a.RefRepAUId) End RepAUName
	From EnquiryList a
	Left Join ProductMas c
	On a.RefProdId = c.ProdId
	Left Join CatalogMas e
	On a.RefCatId = e.CatId
	Where a.RefAUId = Case When @pRefAUId Is NULL Then a.RefAUId Else @pRefAUId End
	and a.RefVendorId = @pRefVendoreId
	Order By a.EnquiryDate Desc
END

GO
/****** Object:  StoredProcedure [dbo].[sp_EnquiryList_SelectWhere]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		JayamSoft
-- Create date: 06/06/2016
-- Description:	Select Where Enqiuiry list 
-- =============================================
CREATE PROCEDURE [dbo].[sp_EnquiryList_SelectWhere]
	-- Add the parameters for the stored procedure here
	@pdefstr nvarchar(max) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @Sql nvarchar(max) = ''
	Declare @MainFolder nvarchar(max) = '';
	Select top 1 @MainFolder = FolderPath From CompanyProfile

	--Select a.Id, a.RefAUID, (Select c.AUName From AppUsers c Where c.AUId = a.RefAUId) AUName , 
	--	(Select c.CompanyName From AppUsers c Where c.AUId = a.RefAUId) CompanyName , 
	--	a.RefVendorId,(Select c.VendorName From Vendor c Where c.VendorId = a.RefVendorId) VendorName, 
	--	a.RefProdId, b.ProdCode,b.ProdName, (Select Top 1 x.ImgName From ProductImgDet x Where x.RefProdId = a.RefProdId ORder By x.Ord) ProdImg,
	--	(Case When a.RefProdId Is Not NULL and  (Select Top 1 x.IsGlobal From ProductImgDet x Where x.RefProdId = a.RefProdId ORder By x.Ord) = 0
	--	Then (@MainFolder + Cast(a.RefVendorId as nvarchar) + '/Products/Thumbnail/' + (Select Top 1 x.ImgName From ProductImgDet x Where x.RefProdId = a.RefProdId ORder By x.Ord)) 
	--	When a.RefProdId Is Not NULL and  (Select Top 1 x.IsGlobal From ProductImgDet x Where x.RefProdId = a.RefProdId ORder By x.Ord) = 1
	--	Then (@MainFolder + 'Global/Products/Thumbnail/' + (Select Top 1 x.ImgName From ProductImgDet x Where x.RefProdId = a.RefProdId ORder By x.Ord)) 
	--	When a.RefCatId Is Not NULL and  (Select Top 1 x.RefStoreId From CatalogMas x Where x.CatId = a.RefCatId) Is NULL
	--	Then (@MainFolder + Cast(a.RefVendorId as nvarchar) + '/Catalog/Thumbnail/' + (Select Top 1 x.CatImg From CatalogMas x Where x.CatId = a.RefCatId))
	--	When a.RefCatId Is Not NULL and  (Select Top 1 x.RefStoreId From CatalogMas x Where x.CatId = a.RefCatId) Is Not NULL
	--	Then (@MainFolder + 'Global/Catalog/Thumbnail/' + (Select Top 1 x.CatImg From CatalogMas x Where x.CatId = a.RefCatId))
	--	When (Select Top 1 BGImage From Vendors Where VendorId = a.RefVendorId ) Is Not NULL 
	--	Then (@MainFolder + Cast(a.RefVendorId as nvarchar)  + '/ThumbProd' + (Select Top 1 BGImage From Vendors Where VendorId = a.RefVendorId))
	--	Else '/Content/dist/img/Thumbnail/ProductNoImage.png' End)ThumbnailImgPath,
	--	e.CatId,e.CatCode,e.CatName,
	--	a.Remark,a.EnquiryDate,
	--	a.ReadDateTime,
	--	a.[Status],a.RepRemark,a.EnquiryRepDate
	--From EnquiryList a
	--Left join ProductMas b 
	--On a.RefProdId = b.ProdId
	--Left Join CatalogMas e
	--On a.RefCatId  = e.CatId

    -- Insert statements for procedure here
	Set @Sql = ' Select * From (Select a.Id, a.RefAUID, (Select c.AUName From AppUsers c Where c.AUId = a.RefAUId) AUName , 
	(Select c.CompanyName From AppUsers c Where c.AUId = a.RefAUId) CompanyName , 
	a.RefVendorId,(Select c.VendorName From Vendor c Where c.VendorId = a.RefVendorId) VendorName, 
	a.RefProdId, b.ProdCode,b.ProdName, (Select Top 1 x.ImgName From ProductImgDet x Where x.RefProdId = a.RefProdId ORder By x.Ord) ProdImg,
	(Case When a.RefProdId Is Not NULL and  (Select Top 1 IsNULL(x.IsGlobal,0) From ProductImgDet x Where x.RefProdId = a.RefProdId ORder By x.Ord) = 0
		Then (''' + @MainFolder + '''+ Cast(a.RefVendorId as nvarchar) + ''/Products/Thumbnail/'' + (Select Top 1 x.ImgName From ProductImgDet x Where x.RefProdId = a.RefProdId ORder By x.Ord)) 
		When a.RefProdId Is Not NULL and  (Select Top 1 IsNULL(x.IsGlobal,0) From ProductImgDet x Where x.RefProdId = a.RefProdId ORder By x.Ord) = 1
		Then (''' + @MainFolder + '''+ ''Global/Products/Thumbnail/'' + (Select Top 1 x.ImgName From ProductImgDet x Where x.RefProdId = a.RefProdId ORder By x.Ord)) 
		When a.RefCatId Is Not NULL and  (Select Top 1 x.RefStoreId From CatalogMas x Where x.CatId = a.RefCatId) Is NULL
		Then (''' + @MainFolder +'''+ Cast(a.RefVendorId as nvarchar) + ''/Catalog/Thumbnail/'' + (Select Top 1 x.CatImg From CatalogMas x Where x.CatId = a.RefCatId))
		When a.RefCatId Is Not NULL and  (Select Top 1 x.RefStoreId From CatalogMas x Where x.CatId = a.RefCatId) Is Not NULL
		Then (''' + @MainFolder +'''+ ''Global/Catalog/Thumbnail/'' + (Select Top 1 x.CatImg From CatalogMas x Where x.CatId = a.RefCatId))
		When (Select Top 1 BGImage From Vendor Where VendorId = a.RefVendorId ) Is Not NULL 
		Then (''' + @MainFolder +'''+ Cast(a.RefVendorId as nvarchar)  + ''/ThumbProd'' + (Select Top 1 BGImage From Vendor Where VendorId = a.RefVendorId))
		Else ''/Content/dist/img/Thumbnail/ProductNoImage.png'' End)ThumbnailImgPath,
	e.CatId,e.CatCode,e.CatName,
	a.Remark,a.EnquiryDate,
	a.ReadDateTime,
	a.[Status],a.RepRemark,a.EnquiryRepDate
	From EnquiryList a
	Left join ProductMas b 
	On a.RefProdId = b.ProdId
	Left Join CatalogMas e
	On a.RefCatId  = e.CatId) x
	Where 1=1 ' + @pdefstr

	--Print @Sql

	exec sp_executesql @Sql;

END


GO
/****** Object:  StoredProcedure [dbo].[sp_GroupContact_DeleteBaseOnGroupId]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 24/05/2016
-- Description:	Delete GroupContacts base on GroupId
-- =============================================
CREATE PROCEDURE [dbo].[sp_GroupContact_DeleteBaseOnGroupId]
	-- Add the parameters for the stored procedure here
	@pRefGroupId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Delete From GroupContactList
	Where RefGroupId = @pRefGroupId

	Select Cast(1 as bit) Result
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GroupContact_Save]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 24/05/2016
-- Description:	Save Contact with specific group
-- =============================================
CREATE PROCEDURE [dbo].[sp_GroupContact_Save]
	-- Add the parameters for the stored procedure here
	@pId int,
	@pRefGroupId int,
	@pRefAUId int,
	@pUser int,
	@pTerminal nvarchar(60)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @Result bit = 0;

    -- Insert statements for procedure here
	If(Not Exists (Select * from GroupContactList Where RefGroupId = @pRefGroupId and RefAUId = @pRefAUId))
	Begin
		Insert Into GroupContactList (RefGroupId, RefAUId, InsUser, InsDate, InsTerminal)
		Values (@pRefGroupId, @pRefAUId, @pUser, GETDATE(), @pTerminal)

		Set @Result = 1;
	End
	
	Select @Result  Result
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GroupContact_SelectBaseOnGroupId]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 24/05/2016
-- Description:	Get Group of Contact Using GroupId
-- =============================================
CREATE PROCEDURE [dbo].[sp_GroupContact_SelectBaseOnGroupId]
	-- Add the parameters for the stored procedure here
	@pGroupId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select a.Id, a.RefGroupId, a.RefAUId,
		b.AUName, (Select b.GroupName From GroupMas b Where b.GroupId= a.RefGroupId) GroupName,
		b.CompanyName, b.EmailId, b.MobileNo1
	from  GroupContactList a
	Inner Join AppUsers b
	On b.AUId = a.RefAUId
	Where a.RefGroupId = @pGroupId
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GroupMas_Save]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft	
-- Create date: 24/05/2016
-- Description:	Save Contact Group 
-- =============================================
CREATE PROCEDURE [dbo].[sp_GroupMas_Save]
	-- Add the parameters for the stored procedure here
	@pGroupId int,
	@pRefVendorId int,
	@pGroupName nvarchar(50),
	@pUser int,
	@pTerminal nvarchar(60)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @pResult bit = 0;

    -- Insert statements for procedure here
	If(Not Exists (Select * from GroupMas Where GroupId = @pGroupId))
	Begin
		Insert Into GroupMas (RefVendorId, GroupName, InsUser, InsDate, InsTerminal)
		Values (@pRefVendorId, @pGroupName, @pUser, GETDATE(),  @pTerminal)

		Set @pResult  = 1
	End
	Else
	Begin
		Update GroupMas
		Set GroupName = @pGroupName, 
			UpdUser = @pUser, 
			UpdDate = GETDATE(), 
			UpdTerminal = @pTerminal
		Where GroupId = @pGroupId

		Set @pResult  = 1
	End

	Select @pResult  Result
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GroupMas_SelectBaseOnVendor]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 24/05/2016
-- Description:	select list of Contact group
-- =============================================
CREATE PROCEDURE [dbo].[sp_GroupMas_SelectBaseOnVendor]
	-- Add the parameters for the stored procedure here
	@pSearch nvarchar(max) ,
	@pRefVendorId int
	--@pPageSize int = 6, 
	--@pPageIndex int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @Sql nvarchar(max) = '';
	Declare @defstr nvarchar(max) = '';
	if(@pSearch is not null and @pSearch <> '')
	Begin
		Set @defstr = ' and ( a.GroupName Like ''%' + @pSearch + '%'')'
	End

    -- Insert statements for procedure here
	--Select a.GroupId, a.GroupName,
	--	a.RefVendorId, 
	--	(Select Count (*) From GroupContactList c Where c.RefGroupId = a.GroupId) TotalContact, 
	--	a.InsUser, a.InsDate, a.InsTerminal,
	--	a.UpdUser,a.UpdDate, a.UpdTerminal 
	--From GroupMas a

	Set @Sql = 'Select a.GroupId, a.GroupName,
		a.RefVendorId, 
		(Select Count (*) From GroupContactList c Where c.RefGroupId = a.GroupId) TotalContact, 
		a.InsUser, a.InsDate, a.InsTerminal,
		a.UpdUser,a.UpdDate, a.UpdTerminal 
	From GroupMas a 
	Where a.RefVendorId = ' + Cast(@pRefVendorId as nvarchar) + 
	@defstr + '
	Order By a.GroupId '
	--OFFSET ' + Cast(@pPageSize * @pPageIndex as nvarchar) + ' ROWS
	--FETCH NEXT ' + Cast(@pPageSize as nvarchar) + ' ROWS ONLY OPTION (RECOMPILE)'

	exec sp_executesql @Sql
END

GO
/****** Object:  StoredProcedure [dbo].[sp_MasterValue_GetMinMaxPrice]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 28/04/2016
-- Description:	Get Min and max price for catalog filetr
-- =============================================
CREATE PROCEDURE [dbo].[sp_MasterValue_GetMinMaxPrice]
	-- Add the parameters for the stored procedure here
	@pRefVendorId int ,
	@pRefCategory  nvarchar(max) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select Min(FinalPrice) MinPrice,
		Max(FinalPrice) MaxPrice 
	From (
	Select SUM(ISNULL(a.WholeSalePrice,0)) as FinalPrice
	From ProductMas a
		Inner Join CatalogMas b
		On a.RefCatId = b.CatId
	Where a.RefVendorId = @pRefVendorId
		and a.RefProdCategory = @pRefCategory) R
END

GO
/****** Object:  StoredProcedure [dbo].[sp_MasterValue_Save]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 20/04/2016
-- Description:	Save Master Value Data Base on VendorId and MasterId
-- =============================================
CREATE PROCEDURE [dbo].[sp_MasterValue_Save]
	-- Add the parameters for the stored procedure here
	@pId int = NULL,
	@pRefMasterId int,
	@pRefVendorId int,
	@pValueName nvarchar(50),
	@pValueDesc nvarchar(200),
	@pOrdNo numeric(5,2),
	@pIsActive bit,
	@pUser int,
	@pTerminal nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @pResult int = 0;

    -- Insert statements for procedure here
	If(Not Exists (Select * from MasterValue Where Id = @pId ))
	Begin
		Insert Into MasterValue (RefMasterId, RefVendorId, ValueName ,
				ValueDesc, OrdNo, IsActive, InsUser, InsDate, InsTerminal)
		Values (@pRefMasterId, @pRefVendorId, @pValueName ,
				@pValueDesc, @pOrdNo, @pIsActive, @pUser, GETDATE() , @pTerminal)
		Select @pResult = IDENT_CURRENT('MasterValue');
	End
	Else
	Begin
		Update MasterValue 
		Set RefMasterId = @pRefMasterId, 
			RefVendorId = @pRefVendorId, 
			ValueName = @pValueName,
			ValueDesc = @pValueDesc, 
			OrdNo = @pOrdNo, 
			IsActive = @pIsActive, 
			UpdUser = @pUser, 
			UpdDate = GETDATE(), 
			UpdTerminal = @pTerminal
		Where Id = @pId
		Set @pResult = @pId;
	End

	Select @pResult Result; 
END

GO
/****** Object:  StoredProcedure [dbo].[sp_MasterValue_Select]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 20/04/2016
-- Description:	Get Master Value Data base On MasterId, VendorId and Id
-- =============================================
CREATE PROCEDURE [dbo].[sp_MasterValue_Select] 
	-- Add the parameters for the stored procedure here
	@pId int = NULL,
	@pRefMasterId int = NULL,
	@pRefVendorId int = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select a.ID, a.RefMasterId, (Select b.MasterName From MastersList b Where b.Id = a.RefMasterId) MasterName,
	a.RefVendorId , (Select b.VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName,
	a.ValueName, a.ValueDesc, a.OrdNo, a.IsActive, a.InsUser, a.InsDate, a.InsTerminal, a.UpdUser, a.UpdDate, a.UpdTerminal
	From MasterValue a
	Where a.ID = Case When @pId Is NULL Then a.Id  Else @pId End
	and a.RefMasterId  = Case When @pRefMasterId Is NULL Then a.RefMasterId  Else @pRefMasterId End
	and a.RefVendorId In (Case When @pRefVendorId Is NULL Then a.RefVendorId Else @pRefVendorId End, 0)
	Order By a.ValueName
END

GO
/****** Object:  StoredProcedure [dbo].[sp_MasterValue_SelectWhere]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 20/04/2016
-- Description:	Get Master Value Data base on Where Condition
-- =============================================
CREATE PROCEDURE [dbo].[sp_MasterValue_SelectWhere] 
	-- Add the parameters for the stored procedure here
	@pdefWhere nvarchar(max) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @pSql nvarchar(max);

	--Select a.ID, a.RefMasterId, (Select b.MasterName From MastersList b Where b.Id = a.RefMasterId) MasterName,
	--a.RefVendorId , (Select b.VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName,
	--a.ValueName, a.ValueDesc, a.OrdNo, a.IsActive, a.InsUser, a.InsDate, a.InsTerminal, a.UpdUser, a.UpdDate, a.UpdTerminal
	--From MasterValue a

	Set @pSql = 'Select * from (
	Select a.ID, a.RefMasterId, (Select b.MasterName From MastersList b Where b.Id = a.RefMasterId) MasterName,
	a.RefVendorId , (Select b.VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName,
	a.ValueName, a.ValueDesc, a.OrdNo, a.IsActive, 
	a.InsUser, a.InsDate, a.InsTerminal, 
	a.UpdUser, a.UpdDate, a.UpdTerminal
	From MasterValue a ) m
	Where 1=1 ' + @pdefWhere;

	exec sp_executesql @pSql;
		
END

GO
/****** Object:  StoredProcedure [dbo].[sp_MenuRoleRights_Delete]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft	
-- Create date: 23/05/2016
-- Description:	Menu Role Rights Delete
-- =============================================
CREATE PROCEDURE [dbo].[sp_MenuRoleRights_Delete]
	-- Add the parameters for the stored procedure here
	@pRefRoleId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Delete From MenuRoleRights 
	Where RefRoleId = @pRefRoleId;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_MenuRoleRights_Save]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		JayamSoft
-- Create date: 14/Mar/2016
-- Description:	To insert / update value in Menu Role Rights
-- =============================================
CREATE PROCEDURE [dbo].[sp_MenuRoleRights_Save] 
	-- Add the parameters for the stored procedure here
	@pRefRoleId int,
	@pRefMenuId int,
	@pCanInsert bit,
	@pCanUpdate bit,
	@pCanDelete bit,
	@pCanView bit,
	@pUser int,
	@pTerminal nvarchar(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @retVal bit = 0;
		
			Insert into MenuRoleRights(RefRoleId ,RefMenuId ,CanInsert ,CanUpdate ,
				CanDelete ,CanView ,InsUser, InsDate, InsTerminal)
			values(@pRefRoleId ,@pRefMenuId ,@pCanInsert ,@pCanUpdate ,
				@pCanDelete ,@pCanView , @pUser, GETDATE(), @pTerminal)
			       
			set @retVal = 1;
	
	Select @retVal Result
	
END


GO
/****** Object:  StoredProcedure [dbo].[sp_MenuRoleRights_Select]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jayam Soft
-- Create date: 14/Mar/2016	
-- Description:	Retrive menu rights details from MenuRoleRights
-- =============================================
CREATE PROCEDURE [dbo].[sp_MenuRoleRights_Select]
	-- Add the parameters for the stored procedure here
	@pRoleId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Select statements for Menu Role Rights
	select MenuName,  isnull(RefRoleId,@pRoleId ) RefRoleId, isnull(RefMenuId,b.ID) RefMenuId,
		isnull(CanInsert ,0) CanInsert , isnull(CanUpdate ,0) CanUpdate, isnull(CanDelete ,0) CanDelete , 
		isnull(CanView ,0) CanView , b.ParentMenuID, b.MenuIcon,
		a.InsUser, a.InsDate, a.InsTerminal,
		a.UpdUser, a.UpdDate, a.UpdTerminal
	from MenuMaster as b left join 
		menurolerights as a  
		on b.ID = a.RefMenuId
		and a.refroleid = @pRoleId 
	Order By b.OrderNo,b.ParentMenuID
		
END


GO
/****** Object:  StoredProcedure [dbo].[sp_Notification_Save]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 02/06/2016
-- Description:	Notification Save
-- =============================================
CREATE PROCEDURE [dbo].[sp_Notification_Save]
	-- Add the parameters for the stored procedure here
	@pNotifyId int,
	@pRefVendorId int,
	@pNotifyDate date,
	@pRefGroupId nvarchar(500),
	@pRefAppUserId nvarchar(500),
	@pMessage nvarchar(500),
	@pImgPath nvarchar(50),
	@pUser int,
	@pTerminal nvarchar(60)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Insert Into NotificationMas (RefVendorId, NotifyDate, RefGroupId, RefAppUserId, 
		[Message], ImgPath, InsUser, InsDate, InsTerminal)
	Values (@pRefVendorId, @pNotifyDate, @pRefGroupId, @pRefAppUserId, 
		@pMessage, @pImgPath, @pUser, GETDATE(), @pTerminal)

	Select @pNotifyId = IDENT_CURRENT('NotificationMas');

	Declare @GroupId int;
	Declare @AUId int;

	Declare CurGroupId Cursor 
	For Select Item From SplitString(@pRefGroupId, ',')

	Open CurGroupId 
	Fetch Next From CurGroupId Into @GroupId 

		While (@@FETCH_STATUS = 0 )
		Begin
			Declare CurAppUserId Cursor
			For Select RefAUId From GroupContactList Where RefGroupId = @GroupId

			Open CurAppUserId 
			Fetch Next From CurAppUserId Into @AUId 

				While @@FETCH_STATUS = 0
				Begin
					if(Not Exists (Select * From NotificationDet Where RefNotifyId = @pNotifyId and RefAppUserId = @AUId))
					Begin
						Insert into NotificationDet (RefNotifyId, RefAppUserId,[Status], InsUser,InsDate, InsTerminal)
							Values (@pNotifyId,@AUId, 'Pending', @pUser, GETDATE(), @pTerminal)
					End

					Fetch Next From CurAppUserId Into @AUId 
				End
				
			Close CurAppUserId 
			Deallocate CurAppUserId

			Fetch Next From CurGroupId Into @GroupId 
		End

	Close CurGroupId;
	Deallocate CurGroupId ;

	Declare CurAUId Cursor 
	For Select Item From SplitString(@pRefAppUserId, ',')

	Open CurAUId  
	Fetch Next From CurAUId  Into @AUId 
		
			While @@FETCH_STATUS = 0
			Begin
				if(Not Exists (Select * From NotificationDet Where RefNotifyId = @pNotifyId and RefAppUserId = @AUId))
				Begin
					Insert into NotificationDet (RefNotifyId, RefAppUserId,[Status], InsUser,InsDate, InsTerminal)
						Values (@pNotifyId,@AUId, 'Pending', @pUser, GETDATE(), @pTerminal)
				End

				Fetch Next From CurAUId  Into @AUId 
			End

	Close CurAUId ;
	Deallocate CurAUId  ;

	Select Cast(1 as bit) Result 
END

GO
/****** Object:  StoredProcedure [dbo].[sp_NotificationMas_Select]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 02-06-2016
-- Description:	Get Notification Base on Vendor
-- =============================================
CREATE PROCEDURE [dbo].[sp_NotificationMas_Select]
	-- Add the parameters for the stored procedure here
	@pRefVendorId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select a.NotifyId, a.RefVendorId, a.NotifyDate,
			a.RefGroupId,[dbo].[FunRetString](a.RefGroupId, ',', 'Group') GroupName, 
			a.RefAppUserId, [dbo].[FunRetString](IsNUll(a.RefAppUserId,''), ',', 'Contact') AUName, 
			a.[Message], a.ImgPath, 
			a.InsUser, a.InsDate, a.InsTerminal,
			a.UpdUser, a.UpdDate, a.UpdTerminal
	From NotificationMas a
	Where a.RefVendorId = @pRefVendorId
	Order By a.NotifyDate Desc

END

GO
/****** Object:  StoredProcedure [dbo].[sp_ParameterMapping_Save]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 27-06-2016
-- Description:	Save Parameter Mapping
-- =============================================
CREATE PROCEDURE [dbo].[sp_ParameterMapping_Save]
	-- Add the parameters for the stored procedure here
	@pId int = null,
	@pRefMasterId int,
	@pRefVendorId int,
	@pRefStoreId int,
	@pRefVendorValId int,
	@pRefStoreValId int,
	@pUser int,
	@pTerminal nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @iResult int = 0;

    -- Insert statements for procedure here
	If(Not Exists(Select * From ParameterMapping Where Id = @pId))
	Begin
		Insert Into ParameterMapping(RefMasterId,RefVendorId, RefStoreId, RefVendorValId, RefStoreValId, InsUser, InsDate, InsTerminal)
		Values (@pRefMasterId,@pRefVendorId, @pRefStoreId, @pRefVendorValId, @pRefStoreValId, @pUser, GETDATE(), @pTerminal);

		Select @iResult  = IDENT_CURRENT('ParameterMapping');
	End

	Select @iResult Result;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ParameterMapping_Select]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft	
-- Create date: 27-06-2016
-- Description:	Get Value For Parameter Mapping
-- =============================================
CREATE PROCEDURE [dbo].[sp_ParameterMapping_Select]
	-- Add the parameters for the stored procedure here
	@pRefStoreId int,
	@pRefVendorId int,
	@pRefMasterId int,
	@pRefCatId int = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Declare @tMasterValCat Table  (Id int,ValueName nvarchar(50), ValueDesc nvarchar(200),OrdNo numeric(5,2))
	Declare @sValueName nvarchar(50),@sValName nvarchar(max) = '';
	Declare @sMasterName nvarchar(50) = '';

	if(@pRefCatId Is NOT NULL)
	Begin
		Select @sMasterName = c.MasterName From MastersList c Where c.Id = @pRefMasterId;
		if(@sMasterName = 'Brand')
		Begin
			Declare CurValueName Cursor 
			For Select RefBrand From ProductMas a Where a.RefCatId = @pRefCatId
		End
		else if(@sMasterName = 'Color')
		Begin
			Declare CurValueName Cursor 
			For Select RefColor From ProductMas a Where a.RefCatId = @pRefCatId
		End
		else if(@sMasterName = 'ProdType')
		Begin
			Declare CurValueName Cursor 
			For Select RefProdType From ProductMas a Where a.RefCatId = @pRefCatId
		End
		else if(@sMasterName = 'Size')
		Begin
			Declare CurValueName Cursor 
			For Select RefSize From ProductMas a Where a.RefCatId = @pRefCatId
		End
		else if(@sMasterName = 'Fabric')
		Begin
			Declare CurValueName Cursor 
			For Select RefFabric From ProductMas a Where a.RefCatId = @pRefCatId
		End
		else if(@sMasterName = 'Design')
		Begin
			Declare CurValueName Cursor 
			For Select RefDesign From ProductMas a Where a.RefCatId = @pRefCatId
		End

		Open CurValueName;

		Fetch Next From CurValueName Into @sValueName;
		While(@@FETCH_STATUS = 0)
		Begin
			if(@sValName <> '')
			Begin
				Set @sValName = @sValName + ',';
			End
			Set @sValName = @sValName + @sValueName;
			Fetch Next From CurValueName Into @sValueName;
		End

		Close CurValueName;
		Deallocate CurValueName ;
	End

	--Select Distinct Item From SplitString(@sValName,',')

    -- Insert statements for procedure here
	if(@pRefCatId Is NULL)
	Begin
		--Print 'With Out CatId'
		Select x.ID StoreValId,x.ValueName StoreValName ,x.ValueDesc StoreValDesc,
			x.OrdNo StoreValOrdNo ,x.RefMasterId , x.RefVendorId StoreId ,
			(Case When x.RefVendorValId Is NOT NULL Then x.RefVendorValId Else y.ID End) VendorValId,
			(Case When  x.RefVendorValId Is NOT NULL Then x.VendorValName Else y.ValueName End) VendorValName,
			(Case When  x.RefVendorValId Is NOT NULL Then x.VendorValDesc Else y.ValueDesc End) VendorValDesc,
			(Case When  x.RefVendorValId Is NOT NULL Then x.VendorValOrd Else y.OrdNo End) VendorValOrdNo,
			x.RefVendorId VendorId, 
			--y.RefVendorId VendorId,
			--x.RefVendorValId, x.VendorValName,	x.VendorValDesc,x.VendorValOrd,x.RefVendorId,y.ID,
			(Case When x.RefVendorValId Is Not NULL and 
			(Select Count(*) From ParameterMapping c Where c.RefStoreValId = x.ID and c.RefVendorValId = x.RefVendorValId) > 0 Then 'M'
			 When y.ID Is Not NULL Then 'A' 
			Else 'U' End) MappedStatus,x.ParamMappingId
		From
		(
		Select  a.ID,a.ValueName,a.ValueDesc,a.OrdNo,a.RefMasterId,a.RefVendorId,a.IsActive,
			p.RefVendorValId, 
			(Select m.ValueName from MasterValue m Where m.ID = p.RefVendorValId) VendorValName,
			(Select m.ValueDesc from MasterValue m Where m.ID = p.RefVendorValId) VendorValDesc,
			(Select m.OrdNo from MasterValue m Where m.ID = p.RefVendorValId) VendorValOrd,	p.Id ParamMappingId
			From MasterValue a
			Left Join ParameterMapping p
			On a.ID = p.RefStoreValId
			and p.RefVendorId = @pRefVendorId
			Where a.RefVendorId = @pRefStoreId
			and a.RefMasterId = @pRefMasterId
			) x --Store
		Left Join (
		Select b.ID,b.ValueName,b.ValueDesc,b.OrdNo,b.RefMasterId,b.RefVendorId,b.IsActive
			--p.RefVendorValId, 
			--(Select m.ValueName from MasterValue m Where m.ID = p.RefVendorValId) VendorValName,
			--(Select m.ValueDesc from MasterValue m Where m.ID = p.RefVendorValId) VendorValDesc,
			--(Select m.OrdNo from MasterValue m Where m.ID = p.RefVendorValId) VendorValOrd
			From MasterValue b
			Left Join ParameterMapping p
			On b.ID = p.RefStoreValId
			Where b.RefVendorId = @pRefVendorId
			and b.RefMasterId = @pRefMasterId
			) y --Vendor
		On x.ValueName = y.ValueName
		Left Join 
		(Select p.Id, p.RefStoreValId, 
			(Select m.ValueName from MasterValue m Where m.ID = p.RefStoreValId) StoreValName,
			(Select m.ValueDesc from MasterValue m Where m.ID = p.RefStoreValId) StoreValDesc,
			(Select m.OrdNo from MasterValue m Where m.ID = p.RefStoreValId) StoreValOrd,
			p.RefVendorValId,
			(Select m.ValueName from MasterValue m Where m.ID = p.RefVendorValId) VendorValName,
			(Select m.ValueDesc from MasterValue m Where m.ID = p.RefVendorValId) VendorValDesc,
			(Select m.OrdNo from MasterValue m Where m.ID = p.RefVendorValId) VendorValOrd
		 From ParameterMapping p
		 Where p.RefVendorId = @pRefVendorId
			and p.RefStoreId = @pRefStoreId
			and p.RefMasterId = @pRefMasterId
		 ) z
		 On x.ID = z.RefStoreValId
	End
	Else
	Begin
		--Print 'With CatId'
		Select x.ID StoreValId,x.ValueName StoreValName ,x.ValueDesc StoreValDesc,
			x.OrdNo StoreValOrdNo ,x.RefMasterId , x.RefVendorId StoreId ,
			(Case When x.RefVendorValId Is NOT NULL Then x.RefVendorValId Else y.ID End) VendorValId,
			(Case When  x.RefVendorValId Is NOT NULL Then x.VendorValName Else y.ValueName End) VendorValName,
			(Case When  x.RefVendorValId Is NOT NULL Then x.VendorValDesc Else y.ValueDesc End) VendorValDesc,
			(Case When  x.RefVendorValId Is NOT NULL Then x.VendorValOrd Else y.OrdNo End) VendorValOrdNo,
			x.RefVendorId VendorId, 
			--y.RefVendorId VendorId,
			--x.RefVendorValId, x.VendorValName,	x.VendorValDesc,x.VendorValOrd,x.RefVendorId,y.ID,
			(Case When x.RefVendorValId Is Not NULL and 
			(Select Count(*) From ParameterMapping c Where c.RefStoreValId = x.ID and c.RefVendorValId = x.RefVendorValId) > 0 Then 'M'
			 When y.ID Is Not NULL Then 'A' 
			Else 'U' End) MappedStatus,x.ParamMappingId
		From
		(
		Select  a.ID,a.ValueName,a.ValueDesc,a.OrdNo,a.RefMasterId,p.RefVendorId,a.IsActive,
			p.RefVendorValId, 
			(Select m.ValueName from MasterValue m Where m.ID = p.RefVendorValId) VendorValName,
			(Select m.ValueDesc from MasterValue m Where m.ID = p.RefVendorValId) VendorValDesc,
			(Select m.OrdNo from MasterValue m Where m.ID = p.RefVendorValId) VendorValOrd,p.Id ParamMappingId
			From MasterValue a
			Left Join ParameterMapping p
			On a.ID = p.RefStoreValId
			and p.RefVendorId = @pRefVendorId
			Where a.RefVendorId = @pRefStoreId
			and a.RefMasterId = @pRefMasterId
			and a.ValueName In (Select Distinct Item From SplitString(@sValName,','))
			) x --Store
		Left Join (
		Select b.ID,b.ValueName,b.ValueDesc,b.OrdNo,b.RefMasterId,b.RefVendorId,b.IsActive
			--p.Id ParamMappingId,
			--p.RefVendorValId, 
			--(Select m.ValueName from MasterValue m Where m.ID = p.RefVendorValId) VendorValName,
			--(Select m.ValueDesc from MasterValue m Where m.ID = p.RefVendorValId) VendorValDesc,
			--(Select m.OrdNo from MasterValue m Where m.ID = p.RefVendorValId) VendorValOrd
			From MasterValue b
			Left Join ParameterMapping p
			On b.ID = p.RefStoreValId
			Where b.RefVendorId = @pRefVendorId
			and b.RefMasterId = @pRefMasterId
			) y --Vendor
		On x.ValueName = y.ValueName
		Left Join 
		(Select p.Id, p.RefStoreValId, 
			(Select m.ValueName from MasterValue m Where m.ID = p.RefStoreValId) StoreValName,
			(Select m.ValueDesc from MasterValue m Where m.ID = p.RefStoreValId) StoreValDesc,
			(Select m.OrdNo from MasterValue m Where m.ID = p.RefStoreValId) StoreValOrd,
			p.RefVendorValId,
			(Select m.ValueName from MasterValue m Where m.ID = p.RefVendorValId) VendorValName,
			(Select m.ValueDesc from MasterValue m Where m.ID = p.RefVendorValId) VendorValDesc,
			(Select m.OrdNo from MasterValue m Where m.ID = p.RefVendorValId) VendorValOrd
		 From ParameterMapping p
		 Where p.RefVendorId = @pRefVendorId
			and p.RefStoreId = @pRefStoreId
			and p.RefMasterId = @pRefMasterId
		 ) z
		 On x.ID = z.RefStoreValId


		--Select x.ID StoreValId,x.ValueName StoreValName ,x.ValueDesc StoreValDesc,
		--	x.OrdNo StoreValOrdNo ,x.RefMasterId , x.RefVendorId StoreId ,
		--	y.ID VendorValId,y.ValueName VendorValName ,y.ValueDesc VendorValDesc,
		--	y.OrdNo VendorValOrdNo,y.RefVendorId VendorId,
		--	(Case When y.ID Is Not NULL and 
		--	(Select Count(*) From ParameterMapping c Where c.RefVendorValId = y.ID and c.RefVendorId = @pRefVendorId) > 0 Then 'M'
		--	 When y.ID Is Not NULL Then 'A' 
		--	Else 'U' End) MappedStatus, y.ParamMappingId
		--From
		--(
		--Select a.ID,a.ValueName,a.ValueDesc,a.OrdNo,a.RefMasterId,a.RefVendorId,a.IsActive
		--From MasterValue a
		--Where a.RefVendorId = @pRefStoreId
		--and a.RefMasterId = @pRefMasterId
		--and a.ValueName In (Select Distinct Item From SplitString(@sValName,','))
		--) x --Store
		--Left Join (
		--Select b.ID,b.ValueName,b.ValueDesc,b.OrdNo,b.RefMasterId,b.RefVendorId,b.IsActive,p.Id ParamMappingId
		--From MasterValue b
		--Left Join ParameterMapping p
		--On b.ID = p.RefVendorValId
		--Where b.RefVendorId = @pRefVendorId
		--and b.RefMasterId = @pRefMasterId
		--) y --Vendor
		--On x.ValueName = y.ValueName
	End
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ProductCategory_LazyLoad]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JsyamSoft
-- Create date: 25/04/2016
-- Description:	Get Product Category data using offset
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProductCategory_LazyLoad]
	-- Add the parameters for the stored procedure here
	@pRefVendorId int,
	@pSearchtext nvarchar(max) = '',
	@pPageSize int = 10,
	@pPageIndex int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @_StrWhere nvarchar(max) = '';
	Declare @_SqlStr nvarchar(max) = '';
	Declare @vFolderPath  nvarchar(max) = '';
	Select top 1 @vFolderPath = FolderPath From  CompanyProfile

    -- Insert statements for procedure here
	if(@pSearchtext != '')
	Begin
		Set @_StrWhere = 'and (m.ProdCategoryName Like ''%'+ @pSearchtext +'%''
		or  m.ProdCategoryDesc Like ''%'+ @pSearchtext +'%'')'
	End

	--Select a.PCId, a.ProdCategoryName,
	--	a.ProdCategoryDesc, a.ProdCategoryImg ,
	--	a.RefPCId , a.Ord, 
	--	'' OriginalImgPath,
	--	'' ThumbnailImgPath
	--	From ProductCategory a
	--	Where RefPCId Is NULL
	--	Order By ProdCategoryName 
	--	OFFSET (@pPageSize * @pPageIndex)  ROWS 
	--	Fetch Next @pPageSize  ROWS ONLY OPTION (RECOMPILE)
	
	Set @_SqlStr = 'Select * from 
	(Select a.PCId, a.ProdCategoryName,
		(Cast(a.ProdCategoryDesc as varchar(50)) + ''...'') ProdCategoryDesc , a.ProdCategoryImg ,
		a.RefPCId , a.Ord,
		('''+@vFolderPath +''' + Cast(a.RefVendorId as varchar) + ''/Category/Original/'' + a.ProdCategoryImg) OriginalImgPath,
		(Case When a.ProdCategoryImg Is Not NULL 
		Then (''' + @vFolderPath + ''' + Cast(a.RefVendorId  as varchar)+ ''/Category/Thumbnail/'' + a.ProdCategoryImg) 
		Else (''' + @vFolderPath + ''' + Cast(a.RefVendorId  as varchar)+ ''/ThumbProd'' + (Select Top 1 v.BGImage From Vendor v Where v.VendorId = a.RefVendorId))  End ) ThumbnailImgPath
		From ProductCategory a
		Where a.RefVendorId = '+ Cast(@pRefVendorId as nvarchar) +' ) m 
		Where 1=1 and m.RefPCId Is NULL ' + @_StrWhere + ' 

		Order By IsNULL(m.Ord,9999), m.ProdCategoryName
		OFFSET ' + Cast((@pPageSize * @pPageIndex) as varchar) + ' ROWS 
		Fetch Next '+ Cast(@pPageSize as varchar) + ' ROWS ONLY OPTION (RECOMPILE)'

	exec sp_executesql @_SqlStr;

END

GO
/****** Object:  StoredProcedure [dbo].[sp_ProductCategory_Save]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 23/04/2016
-- Description:	Save Product Category
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProductCategory_Save]
	-- Add the parameters for the stored procedure here
	@pPCId int = null,
	@pRefVendorId int ,
	@pProdCategoryName nvarchar(50),
	@pProdCategoryDesc nvarchar(200),
	@pRefPCId int = null,
	@pOrd int = null,
	@pProdCategoryImg nvarchar(200),
	@pUser int,
	@pTerminal nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @vResult int = 0;

    -- Insert statements for procedure here
	if(Not Exists (Select * from ProductCategory Where PCId = @pPCId))
	Begin
		Insert into ProductCategory (RefVendorId , ProdCategoryName , ProdCategoryDesc, RefPCId, Ord ,
				ProdCategoryImg, InsUser, Insdate, InsTerminal  )
		Values (@pRefVendorId , @pProdCategoryName , @pProdCategoryDesc, @pRefPCId, @pOrd ,
				@pProdCategoryImg, @pUser, GetDate(), @pTerminal )

		Select @vResult = IDENT_CURRENT('ProductCategory');
	End
	Else
	Begin
		Update ProductCategory
		Set RefVendorId = @pRefVendorId , 
			ProdCategoryName = @pProdCategoryName , 
			ProdCategoryDesc = @pProdCategoryDesc, 
			RefPCId = @pRefPCId, 
			Ord = @pOrd ,
			ProdCategoryImg = @pProdCategoryImg, 
			UpdUser = @pUser, 
			UpdDate = GetDate(), 
			UpdTerminal = @pTerminal
		Where PCID = @pPCId 

		Set @vResult = @pPCId ;
	End

	Select @vResult Result;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ProductCategory_Select]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft	
-- Create date: 23/04/2016
-- Description:	Get Product Category List
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProductCategory_Select]
	-- Add the parameters for the stored procedure here
	@pPCId int = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select a.PCId , a.RefVendorId, (Select b.VendorName from Vendor b Where VendorId = a.RefVendorId ) VendorName,
		a.ProdCategoryName, a.ProdCategoryDesc, a.RefPCId, a.Ord,
		a.ProdCategoryImg, a.InsUser, a.InsDate, a.InsTerminal,
		a.UpdUser, a.UpdDate, a.UpdTerminal
	From ProductCategory a
	Where a.PCId = Case When @pPCId Is NULL Then a.PCId Else @pPCId End 
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ProductCategory_SelectWhere]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSfot
-- Create date: 23/04/2016
-- Description:	Get ProductCategory base on Condition
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProductCategory_SelectWhere]
	-- Add the parameters for the stored procedure here
	@pdefWhere nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @vFolderPath nvarchar(max) = null;
	Select Top 1 @vFolderPath =  FolderPath from CompanyProfile

	Declare @Sql nvarchar(max) = null;

     --Insert statements for procedure here
	--Select a.PCId , a.RefVendorId, (Select b.VendorName from Vendor b Where VendorId = a.RefVendorId ) VendorName,
	--	a.ProdCategoryName, a.ProdCategoryDesc, 
	--	a.ProdCategoryImg, 
	--	(@vFolderPath + Cast(a.RefVendorId as varchar) + '/Category/Original/' + a.ProdCategoryImg) OriginalImgPath,
	--	(Case When a.ProdCategoryImg Is Not NULL 
	--	Then (@vFolderPath + Cast(a.RefVendorId  as varchar)+ '/Category/Thumbnail/' + a.ProdCategoryImg) 
	--	Else (@vFolderPath + Cast(a.RefVendorId  as varchar)+ '/ThumbProd' + (Select Top 1 v.BGImage From Vendor v Where v.VendorId = a.RefVendorId))  End ) ThumbnailImgPath,
	--	a.RefPCId, a.Ord,
	--	a.InsUser, a.InsDate, a.InsTerminal,
	--	a.UpdUser, a.UpdDate, a.UpdTerminal
	--From ProductCategory a
	

	Set @Sql = 'Select * From 
	(Select a.PCId , a.RefVendorId, (Select b.VendorName from Vendor b Where VendorId = a.RefVendorId ) VendorName,
		a.ProdCategoryName, a.ProdCategoryDesc, 
		a.ProdCategoryImg, 
		('''+@vFolderPath +''' + Cast(a.RefVendorId as varchar) + ''/Category/Original/'' + a.ProdCategoryImg) OriginalImgPath,
		(Case When a.ProdCategoryImg Is Not NULL 
		Then (''' + @vFolderPath + ''' + Cast(a.RefVendorId  as varchar)+ ''/Category/Thumbnail/'' + a.ProdCategoryImg) 
		Else (''' + @vFolderPath + ''' + Cast(a.RefVendorId  as varchar)+ ''/ThumbProd'' + (Select Top 1 v.BGImage From Vendor v Where v.VendorId = a.RefVendorId))  End ) ThumbnailImgPath,
		a.RefPCId, a.Ord,
		a.InsUser, a.InsDate, a.InsTerminal,
		a.UpdUser, a.UpdDate, a.UpdTerminal
	From ProductCategory a) m
	Where 1=1 ' + @pdefWhere 

	--Print @Sql;

	exec sp_executesql @Sql;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ProductImgDet_Delete]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 10/05/2016
-- Description:	Delete Product Image Detail
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProductImgDet_Delete]
	-- Add the parameters for the stored procedure here
	@pRefProdId int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @pResult int =  0;

	-- Delete product from wishlist
	Delete From WishList
	Where RefProdId = @pRefProdId

	-- Delete product from enquieylist
	Delete From EnquiryList
	Where RefProdId = @pRefProdId

    -- Insert statements for procedure here
	Delete From ProductImgDet 
	Where RefProdId  = @pRefProdId
	Set @pResult  = 1;

	Select @pResult Result
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ProductImgDet_Save]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 05/05/2016
-- Description:	Save Product Image Data
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProductImgDet_Save]
	-- Add the parameters for the stored procedure here
	@pProdImgId int = null,
	@pRefProdId int ,
	@pImgName nvarchar(100),
	@pOrd int,
	@pUser int,
	@pTerminal nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @Result int = 0;

    -- Insert statements for procedure here
	if(Not Exists (Select * from ProductImgDet a Where a.ProdImgId = @pProdImgId))
	Begin
		Insert Into ProductImgDet (RefProdId,ImgName, Ord, InsUser, InsDate, InsTerminal)
			Values (@pRefProdId, @pImgName, @pOrd, @pUser, Getdate(), @pTerminal)

		Select @Result = @@IDENTITY;
	End
	Else
	Begin
		Update ProductImgDet
		Set ImgName = @pImgName,
			--Ord = @pOrd,
			IsGlobal = 0,
			UpdUser = @pUser,
			UpdDate = GetDate(),
			UpdTerminal = @pTerminal
		Where ProdImgId = @pProdImgId

		Set @Result = @pProdImgId;
	End

	Select @Result Result
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ProductImgDet_SelectForAPI]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 09/05/2016
-- Description:	Get Product Image List
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProductImgDet_SelectForAPI]
	-- Add the parameters for the stored procedure here
	@pRefProductId int,
	@pFetchType nvarchar(15) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @MainPath nvarchar(100) =''
	Select Top 1 @MainPath =  FolderPath From CompanyProfile 

    -- Insert statements for procedure here
	Select a.ProdImgId, a.RefProdId, (Select b.ProdCode from ProductMas b Where b.ProdId = a.RefProdId) ProdCode,
	a.Ord, a.ImgName,
	(Case When ISNULL(a.IsGlobal,0) = 0 
	Then (@MainPath + Cast ((Select b.RefVendorId from ProductMas b Where b.ProdId = a.RefProdId) as nvarchar) + '/Products/Original/' + a.ImgName) 
	Else (@MainPath + 'Global/Products/Original/' + a.ImgName) End) OriginalImgPath,
	(Case When ISNULL(a.IsGlobal,0) = 0 
	Then (@MainPath + Cast ((Select b.RefVendorId from ProductMas b Where b.ProdId = a.RefProdId) as nvarchar) + '/Products/Original/' + a.ImgName) 
	Else (@MainPath + 'Global/Products/Thumbnail/' + a.ImgName) End)ThumbnailImgPath
	From ProductImgDet a
	Where a.RefProdId = @pRefProductId
	Order By a.Ord
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ProductMas_Filter]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 26/04/2016
-- Description:	Get Product detail base on filetr (Producttype, Febaric, Design, ProductCategory)
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProductMas_Filter]
	-- Add the parameters for the stored procedure here
	@pRefVendorId int,
	@pRefCatId int,
	@pRefCategory nvarchar(30),
	@pCatCode nvarchar(30) = null,
	@pPageSize int = 10,
	@pPageIndex int = 0,
	@pRefProdType nvarchar(max) = null,
	@pRefColor nvarchar(max) = null,
	@pRefSize nvarchar(max) = null,
	@pRefFabric nvarchar(max) = null,
	@pRefDesign nvarchar(max) = null,
	@pRefBrand nvarchar(max) = null,
	@pStartPrice numeric(18,2) = 0,
	@pEndPrice numeric(18,2) = null,
	@pFullSet bit = 0,
	@pOrderBy nvarchar(5) = 'LD'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @vMainPath nvarchar(max) = null
	Select Top 1 @vMainPath = FolderPath From CompanyProfile 

	--Declare @vStrOrderby nvarchar(max) = null
	--if(@pOrderBy = 'LD')
	--	Set @vStrOrderby = ' R.CatLaunchDate Desc ';
	--else if(@pOrderBy = 'LHP')
	--	Set @vStrOrderby = ' R.TotalPrice, R.CatLaunchDate Desc ';
	--else if(@pOrderBy = 'HLP')
	--	Set @vStrOrderby = ' R.TotalPrice Desc, R.CatLaunchDate Desc ';

	if(@pEndPrice Is NULL)
	Begin
		Select @pStartPrice  = Min(a.RetailPrice),
		@pEndPrice  = Max(a.RetailPrice) 
		From ProductMas a
		Inner Join CatalogMas b
		On a.RefCatId = Case When @pRefCatId Is NULL Then a.RefCatId Else @pRefCatId End
		Where a.RefVendorId = @pRefVendorId
		and a.RefProdCategory = @pRefCategory 
	End

	--1	Brand
	--2	Color
	--3	ProdType
	--4	Size
	--5	Fabric
	--6	Design

	--Product Type filter data
	Declare @tProdType Table (Item nvarchar(50));
	if(@pRefProdType IS null)
	Begin
		Insert Into @tProdType (Item)
		Select ValueName
		From MasterValue 
		Where RefMasterId = 3 and RefVendorId In (@pRefVendorId,0)
	End
	Else
	Begin
		Insert Into @tProdType (Item)
		Select Item
		From SplitString(@pRefProdType,',') 
	End

	--Brand filter data
	Declare @tBrand Table (Item nvarchar(50));
	if(@pRefBrand IS null)
	Begin
		Insert Into @tBrand (Item)
		Select ValueName
		From MasterValue 
		Where RefMasterId = 1 and RefVendorId In (@pRefVendorId,0)
	End
	Else
	Begin
		Insert Into @tBrand (Item)
		Select Item
		From SplitString(@pRefBrand,',') 
	End

	--Fabric filter data
	Declare @tFabric Table (Item nvarchar(50));
	if(@pRefFabric IS null)
	Begin
		Insert Into @tFabric  (Item)
		Select ValueName
		From MasterValue 
		Where RefMasterId = 5 and RefVendorId In (@pRefVendorId,0)
	End
	Else
	Begin
		Insert Into @tFabric  (Item)
		Select Item
		From SplitString(@pRefFabric,',') 
	End

	--Design filter data
	Declare @tDesign Table (Item nvarchar(50));
	if(@pRefDesign IS null)
	Begin
		Insert Into @tDesign (Item)
		Select ValueName
		From MasterValue 
		Where RefMasterId = 6 and RefVendorId In (@pRefVendorId,0)
	End
	Else
	Begin
		Insert Into @tDesign (Item)
		Select Item
		From SplitString(@pRefDesign,',') 
	End

	--Color filter data
	Declare @tColor Table (Item nvarchar(50));
	if(@pRefColor IS null)
	Begin
		Insert Into @tColor (Item)
		Select ValueName
		From MasterValue 
		Where RefMasterId = 2 and RefVendorId In (@pRefVendorId,0)
	End
	Else
	Begin
		Insert Into @tColor (Item)
		Select Item
		From SplitString(@pRefDesign,',') 
	End

	--Size filter data
	Declare @tSize Table (Item nvarchar(50));
	if(@pRefSize IS null)
	Begin
		Insert Into @tSize (Item)
		Select ValueName
		From MasterValue 
		Where RefMasterId = 4 and RefVendorId In (@pRefVendorId,0)
	End
	Else
	Begin
		Insert Into @tSize (Item)
		Select Item
		From SplitString(@pRefDesign,',') 
	End

    -- Insert statements for procedure here

	Select * 
	From(
	Select a.ProdId, a.ProdCode, a.ProdDescription, 
		a.RefProdCategory, a.RefColor,a.RefProdType,a.RefSize,a.RefFabric,a.RefDesign,a.RefBrand,
		a.Celebrity,a.RetailPrice, a.WholeSalePrice,a.IsActive,
		(@vMainPath + Cast(@pRefVendorId as nvarchar) + '/Product/Original/' +a.ProdImgPath)  OriginalImgPath, 
		(@vMainPath + Cast(@pRefVendorId as nvarchar)+ '/Product/Thumbnail/' +a.ProdImgPath) ThumbnailImgPath,
		a.RefVendorId, 
		(Select b.VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName,
		a.RefCatId , (Select b.CatCode from CatalogMas b Where b.CatId = a.RefCatId) CatCode,
		(Select b.IsFullset from CatalogMas b Where b.CatId = a.RefCatId) IsFullset,
		(Select b.CatLaunchDate from CatalogMas b Where b.CatId = a.RefCatId) CatLaunchDate
	From ProductMas a
	Where a.RefCatId = Case When @pRefCatId Is NULL Then a.RefCatId Else @pRefCatId End
	and a.RefVendorId = @pRefVendorId
	and a.RefProdCategory  = @pRefCategory  
	and a.RefProdType In ( Select Upper(Item) From @tProdType)
	and a.RefFabric In ( Select Upper(Item) From @tFabric)
	and a.RefDesign In ( Select Upper(Item) From @tDesign)
	and a.RefBrand In ( Select Upper(Item) From @tBrand)
	and a.RefColor Like ( Select Upper(Item) + '%' From @tColor)
	and a.RefSize Like ( Select Upper(Item) + '%' From @tSize)
	and a.RetailPrice between @pStartPrice and  @pEndPrice 
	and a.IsActive = 1
	) 
	R
	Where CatCode Like Case When @pCatCode Is Null Then CatCode Else @pCatCode+'%' End
	and R.IsFullset = Case When @pFullSet = 0 Then R.IsFullset Else @pFullSet End
	Order BY
	Case When @pOrderBy = 'LHP' Then R.RetailPrice End,
	Case When @pOrderBy = 'HLP' Then R.RetailPrice End Desc,
	Case When @pOrderBy = 'LD' or @pOrderBy <> 'LD' Then R.CatLaunchDate End Desc 
	OFFSET @pPageSize * @pPageIndex ROWS
	FETCH NEXT @pPageSize ROWS ONLY OPTION (RECOMPILE)

	--Declare @Sql nvarchar(max) = '';
	----print 'Print '
	--Set @Sql = 'Select * ';
	--Set @Sql += ' From( ';
	--Set @Sql += ' Select a.ProdId, a.ProdCode, a.ProdDescription, ';
	
	--	Set @Sql += ' a.RefProdCategory, a.RefColor,a.RefProdType,a.RefSize,a.RefFabric,a.RefDesign,a.RefBrand,';
	--	Set @Sql += ' a.Celebrity,a.RetailPrice, a.WholeSalePrice,a.IsActive,';
	--	Set @Sql += ' ('''+@vMainPath +Cast(@pRefVendorId as varchar) +'/Product/Original/'' + a.ProdImgPath)  OriginalImgPath, ' ;
	--	Set @Sql += ' ('''+@vMainPath + Cast(@pRefVendorId as varchar) +'/Product/Thumbnail/'' +a.ProdImgPath) ThumbnailImgPath, ';
	--	Set @Sql += '  a.RefVendorId,  ';
		
	--	Set @Sql += ' (Select b.VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName, ';
	--	Set @Sql += ' a.RefCatId , (Select b.CatCode from CatalogMas b Where b.CatId = a.RefCatId) CatCode, ';
	--	Set @Sql += ' (Select b.IsFullset from CatalogMas b Where b.CatId = a.RefCatId) IsFullset, ';
	--	Set @Sql += ' (Select b.CatLaunchDate from CatalogMas b Where b.CatId = a.RefCatId) CatLaunchDate ';
	--Set @Sql += ' From ProductMas a ';
	--Set @Sql += ' Where 1= 1 ';
	--if (@pRefCatId is not null)
	--	Set @Sql += '  and a.RefCatId = Case When '+ Cast(@pRefCatId as nvarchar) +' Is NULL Then a.RefCatId Else '+ Cast(@pRefCatId as nvarchar) +' End ';

	--Set @Sql += ' and a.RefVendorId = '+ Cast(@pRefVendorId as varchar)+'  ';
	--Set @Sql += ' and a.RefProdCategory  = '''+ @pRefCategory  +'''' ;
	--Set @Sql += ' and a.RefProdType In ( Select Upper(Item) From #tProdType) ';
	--Set @Sql += ' and a.RefFabric In ( Select Upper(Item) From #tFabric) ';
	--Set @Sql += ' and a.RefDesign In ( Select Upper(Item) From #tDesign) ';
	--Set @Sql += ' and a.RefBrand In ( Select Upper(Item) From #tBrand) ';
	--Declare @Color nvarchar(30)= '',
	--Declare Cur_Color Cursor 
	--For Select Item From #tColor

	--Open Cur_Color 
	--Fetch Next From Cur_Color into @Color
	--	Set @Sql +='and ';
	--	While @@FETCH_STATUS = 0 
	--	Begin
	--		Set @Sql +=' a.RefColor Like ' + @Color +'%';
	--		Fetch Next From Cur_Color Into @Color
	--	End
	--Close Cur_Color
	--Deallocate Cur_Color

	--Declare @Size nvarchar(30)= ''
	--Declare Cur_Size Cursor 
	--For Select Item From #tSize

	--Open Cur_Size 
	--Fetch Next From Cur_Size into @Size
	--	Set @Sql +='and (';	
	--	While @@FETCH_STATUS = 0 
	--	Begin
	--		Set @Sql +=' a.RefSize Like ' + @Size +'%';
	--		Fetch Next From Cur_Size Into @Size
	--	End
	--Close Cur_Size
	--Deallocate Cur_Size
	----and a.RefColor Like ( Select Upper(Item) + ''%'' From #tColor) ';
	----and a.RefSize Like ( Select Upper(Item) + ''%'' From #tSize) ';
	--Set @Sql += ' and a.RetailPrice between '+ Cast(@pStartPrice as nvarchar) +' and  '+ Cast(@pEndPrice as nvarchar)+' ';
	--Set @Sql += ' and a.IsActive = 1 ';
	
	--Set @Sql += ' )  ';
	--Set @Sql += ' R ';
	--Set @Sql += ' Where 1= 1 ';
	--if(@pCatCode Is Not Null)
	--	Set @Sql += ' and CatCode Like Case When '+@pCatCode +' Is Null Then CatCode Else '+@pCatCode+'''%'' End ';
	--Set @Sql += ' and R.IsFullset = Case When '+Cast(@pFullSet as varchar) +' = 0 Then R.IsFullset Else '+ Cast(@pFullSet as varchar)+' End ';
	--Set @Sql += ' Order BY ';
	
	--if(@pOrderBy = 'LHP')
	--	Set @Sql += ' R.RetailPrice ';
	--else if(@pOrderBy = 'HLP')
	--	Set @Sql += ' R.RetailPrice Desc ';
	--else if(@pOrderBy = 'LD')
	--	Set @Sql += ' R.CatLaunchDate Desc ';
	--Set @Sql += ' OFFSET '+Cast(@pPageSize * @pPageIndex as Varchar ) +' ROWS ';

	--Set @Sql += ' FETCH NEXT '+ Cast(@pPageSize as varchar) +' ROWS ONLY OPTION (RECOMPILE)';
	----print  @Sql

	----print 'Print '+ Cast(Len(@Sql) as nvarchar)

	--exec sp_executesql @Sql

END

GO
/****** Object:  StoredProcedure [dbo].[sp_ProductMas_Save]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		JayamSoft
-- Create date: 02/05/2016
-- Description:	Save Product Detail in Product Master
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProductMas_Save]
	-- Add the parameters for the stored procedure here
	@pProdId int = null,
	@pProdName nvarchar(100),
	@pRefVendorId int,
	@pRefCatId int,
	@pProdCode nvarchar(10),
	@pProdDescription nvarchar(500),
	@pRefProdCategory nvarchar(50),
	@pRefColor nvarchar(100),
	@pRefProdType nvarchar(50),
	@pRefSize nvarchar(100),
	@pRefFabric nvarchar(50),
	@pRefDesign nvarchar(50),
	@pRefBrand nvarchar(30),
	@pCelebrity nvarchar(50),
	@pProdImgPath nvarchar(100),
	@pActivetillDate date,
	@pIsActive bit,
	@pRetailPrice numeric(10,2),
	@pWholeSalePrice numeric(10,2),
	@pUser int,
	@pTerminal nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @Result int = 0

    -- Insert statements for procedure here
	if(Not Exists (Select * from ProductMas a Where a.ProdId = @pProdId))
	Begin
		Insert Into ProductMas (ProdName ,RefVendorId,ProdCode, ProdDescription, ProdImgPath, RefProdCategory, RefProdType,
			RefBrand, RefCatId, RefColor, RefDesign, RefFabric, RefSize,Celebrity, ActivetillDate, RetailPrice, WholeSalePrice,
			IsActive, InsUser, InsDate, InsTerminal)
		Values(@pProdName ,@pRefVendorId, @pProdCode, @pProdDescription, @pProdImgPath, @pRefProdCategory, @pRefProdType,
			@pRefBrand, @pRefCatId, @pRefColor, @pRefDesign, @pRefFabric, @pRefSize,@pCelebrity, @pActivetillDate, @pRetailPrice, @pWholeSalePrice,
			@pIsActive, @pUser, GEtDate(), @pTerminal)

		Select @Result  = @@IDENTITY
	End
	Else
	Begin
		Update ProductMas
		Set ProdName = @pProdName ,
		ProdCode = @pProdCode,
		ProdDescription = @pProdDescription, 
		ProdImgPath = @pProdImgPath, 
		RefProdCategory = @pRefProdCategory, 
		RefProdType = @pRefProdType,
		RefBrand = @pRefBrand, 
		RefCatId = @pRefCatId, 
		RefColor = @pRefColor, 
		RefDesign = @pRefDesign, 
		RefFabric =	@pRefFabric, 
		RefSize = @pRefSize,
		Celebrity = @pCelebrity, 
		ActivetillDate = @pActivetillDate, 
		RetailPrice = @pRetailPrice, 
		WholeSalePrice = @pWholeSalePrice,
		IsActive = @pIsActive, 
		UpdUser = @pUser, 
		UpdDate = GetDate(), 
		UpdTerminal = @pTerminal
		Where ProdId = @pProdId

		Set @Result  = @pProdId
	End
	
	Update	catalogmas
	set		UpdDate = Getdate()
	where	Catid = @pRefCatId and RefVendorId = @pRefVendorId;

	Select @Result Result
END



GO
/****** Object:  StoredProcedure [dbo].[sp_ProductMas_Select]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 26/04/2016
-- Description:	Get Product detail base on filetr (Producttype, Febaric, Design, ProductCategory)
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProductMas_Select]
	-- Add the parameters for the stored procedure here
	@pRefAUId int,
	@pRefVendorId int,
	@pCatId int = NULL,
	@pCategory nvarchar(30) = NULL,
	@pLastDate date,
	@pPageSize int = 10,
	@pPageIndex int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @vMainPath nvarchar(max) = null
	Select Top 1 @vMainPath =  FolderPath From CompanyProfile 

	--Declare @vStrOrderby nvarchar(max) = null
	--if(@pOrderBy = 'LD')
	--	Set @vStrOrderby = ' R.CatLaunchDate Desc ';
	--else if(@pOrderBy = 'LHP')
	--	Set @vStrOrderby = ' R.TotalPrice, R.CatLaunchDate Desc ';
	--else if(@pOrderBy = 'HLP')
	--	Set @vStrOrderby = ' R.TotalPrice Desc, R.CatLaunchDate Desc ';

	Select a.ProdId, a.ProdName, b.CatCode , a.ProdCode, a.ProdDescription, 
		a.RefProdCategory, a.RefColor,a.RefProdType,a.RefSize,a.RefFabric,a.RefDesign,a.RefBrand,
		a.Celebrity,a.RetailPrice, a.WholeSalePrice,a.IsActive,
		(Case When a.ProdImgPath Is NULL Then (Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord) Else a.ProdImgPath End) ProdImgPath,
		--(Case  When a.ProdImgPath Is NULL 
		--Then (@vMainPath + Cast(@pRefVendorId as nvarchar) + '/Products/Original/' +(Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) 
		--Else (@vMainPath + Cast(@pRefVendorId as nvarchar) + '/Products/Original/' +a.ProdImgPath) End) OriginalImgPath , 
		(Case  When (Select top 1 IsNULL(c.IsGlobal,0) From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord) = 0
		Then (@vMainPath + Cast(@pRefVendorId as nvarchar) + '/Products/Thumbnail/' +(Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) 
		Else (@vMainPath + 'Global/Products/Thumbnail/' +(Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) End) ThumbnailImgPath,
		a.RefVendorId, (Select b.VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName,
		(Case When (Exists (Select c.* From WishList c Where c.RefAUId = @pRefAUId and c.RefVendorId = @pRefVendorId and c.RefProdId = a.ProdId)) 
		Then Cast(1 as bit) Else Cast(0 as bit) End) IsInWishList,
		a.RefCatId , b.IsFullset,b.CatLaunchDate 
	From ProductMas a
	Left Join CatalogMas b 
	On a.RefCatId = b.CatId
	Where a.RefVendorId = @pRefVendorId
	and a.RefCatId = Case When @pCatId  Is NULL Then a.RefCatId Else @pCatId End
	and a.RefProdCategory = Case When @pCategory Is NULL Then a.RefProdCategory Else @pCategory End
	and Cast(a.ActivetillDate as Date) >= GETDATE()
	and a.IsActive = 1
	and (a.InsDate >= @pLastDate or a.UpdDate >= @pLastDate)
	Order BY b.CatLaunchDate Desc 
	OFFSET @pPageSize * @pPageIndex ROWS
	FETCH NEXT @pPageSize ROWS ONLY OPTION (RECOMPILE)
	
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ProductMas_SelectForAdmin]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 26/04/2016
-- Description:	Get Product detail base on Product id
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProductMas_SelectForAdmin]
	-- Add the parameters for the stored procedure here
	@pRefVendorId int,
	@pProdId int = NULL
	--@pPageSize int = 10,
	--@pPageIndex int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @vMainPath nvarchar(max) = null
	Select Top 1 @vMainPath = FolderPath From CompanyProfile 

	Select a.ProdId, a.ProdName, (Select b.CatCode From CatalogMas b Where b.CatId = a.RefCatId) CatCode,a.ProdCode, a.ProdDescription, 
		a.RefProdCategory, a.RefColor,a.RefProdType,a.RefSize,a.RefFabric,a.RefDesign,a.RefBrand,
		a.Celebrity,a.RetailPrice, a.WholeSalePrice,a.IsActive,
		(Case When a.ProdImgPath Is NULL Then (Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord) Else a.ProdImgPath End) ProdImgPath,
		(Case  When (Select top 1 Isnull(c.IsGlobal,0) From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord) = 0
		Then (@vMainPath + Cast(a.RefVendorId as nvarchar) + '/Products/Original/' +(Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) 
		Else (@vMainPath + 'Global/Products/Original/' +(Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) End) OriginalImgPath , 
		(Case  When (Select top 1 Isnull(c.IsGlobal,0) From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord) = 0
		Then (@vMainPath + Cast(a.RefVendorId as nvarchar) + '/Products/Thumbnail/' +(Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) 
		Else (@vMainPath + 'Global/Products/Thumbnail/' +(Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) End) ThumbnailImgPath,
		a.RefVendorId, (Select b.VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName,
		a.RefCatId, (Select b.CatName from CatalogMas b Where b.CatId = a.RefCatId) CatName,a.ActivetillDate,
		a.InsUser, a.InsDate, a.InsTerminal,
		a.UpdUser, a.UpdDate, a.UpdTerminal
	From ProductMas a
	Where a.RefVendorId = @pRefVendorId
	and a.ProdId= Case When @pProdId Is NULL Then a.ProdId Else @pProdId End
	Order By a.InsDate,a.ActivetillDate
	
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ProductMas_SelectWhere]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		JayamSoft
-- Create date: 05/05/2016
-- Description:	Get Product detail base on search
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProductMas_SelectWhere]
	-- Add the parameters for the stored procedure here
	@pdefstr nvarchar(max) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	Declare @vMainPath nvarchar(max) = null
	Select Top 1 @vMainPath = FolderPath From CompanyProfile 

	--Select a.ProdId, a.ProdName ,a.ProdCode, a.ProdDescription, 
	--	a.RefProdCategory, a.RefColor,a.RefProdType,a.RefSize,a.RefFabric,a.RefDesign,a.RefBrand,
	--	a.Celebrity,a.RetailPrice, a.WholeSalePrice,a.IsActive,a.ProdImgPath,a.ActivetillDate,
	--	(Case  When a.RefStoreId Is NULL 
	--	Then (@vMainPath + Cast(a.RefVendorId as nvarchar) + '/Products/Original/' + (Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) 
	--	Else (@vMainPath + 'Global/' + Cast(a.RefStoreId as nvarchar) + '/Products/Original/' +(Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) End) OriginalImgPath , 
	--	(Case  When a.RefStoreId Is NULL 
	--	Then (@vMainPath + Cast(a.RefVendorId  as nvarchar) + '/Products/Thumbnail/' +(Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) 
	--	Else (@vMainPath + 'Global/' + Cast(a.RefStoreId as nvarchar) + '/Products/Thumbnail/' +(Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) End) ThumbnailImgPath,
	--	a.RefVendorId, (Select b.VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName,
	--	a.RefCatId, (Select b.CatName from CatalogMas b Where b.CatId = a.RefCatId) CatName
	--From ProductMas a
	
	Declare @Sql nvarchar(max) = null

	Set @Sql = ' Select * From (
	Select	a.ProdId, a.ProdName, a.ProdCode, Cast(a.ProdDescription as nvarchar(30)) + ''...'' ProdDescription, 
			a.RefProdCategory, a.RefColor,a.RefProdType,a.RefSize,a.RefFabric,a.RefDesign,a.RefBrand,
			a.Celebrity,a.RetailPrice, a.WholeSalePrice,a.IsActive,
			(Case When a.ProdImgPath Is NULL Then (Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord) Else a.ProdImgPath End) ProdImgPath,a.ActivetillDate,
			(Case  When (Select top 1 IsNULL(c.IsGlobal,0) From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord) = 0
			Then (''' + @vMainPath + '''+ Cast(a.RefVendorId as nvarchar) + ''/Products/Original/'' + (Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) 
			Else (''' + @vMainPath + '''+ ''Global/Products/Original/'' +(Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) End) OriginalImgPath , 
			(Case  When (Select top 1 IsNULL(c.IsGlobal,0) From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord) = 0
			Then ('''+@vMainPath +'''+ Cast(a.RefVendorId  as nvarchar) + ''/Products/Thumbnail/'' +(Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) 
			Else ('''+@vMainPath +'''+ ''Global/Products/Thumbnail/'' +(Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) End) ThumbnailImgPath,
			a.RefVendorId, (Select b.VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName,
			a.RefCatId, (Select b.CatName from CatalogMas b Where b.CatId = a.RefCatId) CatName
	From	ProductMas a 
		where	a.RefCatId in (select x.CatId from CatalogMas x where x.IsActive = 1 and x.catlaunchDate <= cast(getdate() as date)) 
			and a.ActivetillDate >= cast(getdate() as date)
			and a.IsActive = 1	
	) R Where 1=1 ' + @pdefstr 
	
	--print @Sql


	exec sp_executesql @Sql;
END
 

GO
/****** Object:  StoredProcedure [dbo].[sp_ProductMas_SelectWhereForAdmin]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 26/04/2016
-- Description:	Get Product detail base on search
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProductMas_SelectWhereForAdmin]
	-- Add the parameters for the stored procedure here
	@pRefVendorId int,
	@pSearchValue nvarchar(max) = NULL,
	@pPageSize int = 10,
	@pPageIndex int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @pdefWhere nvarchar(max) = ''
	if(@pSearchValue Is Not Null)
	Begin
		Set @pdefWhere =  ' and (R.ProdDescription Like ''%'+@pSearchValue +'%''
				or R.RefProdCategory Like  ''%'+@pSearchValue +'%'' 
				or R.ProdCode Like  ''%'+@pSearchValue +'%''
				or R.CatName Like  ''%'+@pSearchValue +'%''
				or R.CatCode Like  ''%'+@pSearchValue +'%''
				or R.RefColor Like  ''%'+@pSearchValue +'%''
				or R.RefProdType Like  ''%'+@pSearchValue +'%''
				or R.RefSize Like  ''%'+@pSearchValue +'%''
				or R.RefFabric Like  ''%'+@pSearchValue +'%''
				or R.RefBrand Like  ''%'+@pSearchValue +'%''
				or R.RefDesign Like  ''%'+@pSearchValue +'%'')'
	End


	Declare @vMainPath nvarchar(max) = null
	Select Top 1 @vMainPath = FolderPath From CompanyProfile 

	--Select a.ProdId, a.ProdName, a.ProdCode, a.ProdDescription, 
	--	a.RefProdCategory, a.RefColor,a.RefProdType,a.RefSize,a.RefFabric,a.RefDesign,a.RefBrand,
	--	a.Celebrity,a.RetailPrice, a.WholeSalePrice,a.IsActive,
	--	(Case When a.ProdImgPath Is NULL Then (Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord) Else a.ProdImgPath End) ProdImgPath,
	--	(Case  When a.RefStoreId Is NULL 
	--	Then (@vMainPath + Cast(a.RefVendorId as nvarchar) + '/Products/Original/' +(Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) 
	--	Else (@vMainPath + 'Global/' + Cast(a.RefStoreId as nvarchar) + '/Products/Original/' +(Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) End) OriginalImgPath , 
	--	(Case  When a.RefStoreId Is NULL 
	--	Then (@vMainPath + Cast(a.RefVendorId as nvarchar) + '/Products/Thumbnail/' +(Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) 
	--	Else (@vMainPath + 'Global/' + Cast(a.RefStoreId as nvarchar) + '/Products/Thumbnail/' +(Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) End) ThumbnailImgPath,
	--	a.RefVendorId, (Select b.VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName,
	--	a.RefCatId, (Select b.CatName from CatalogMas b Where b.CatId = a.RefCatId) CatName
	--From ProductMas a
	
	Declare @Sql nvarchar(max) = null

	Set @Sql = ' Select * From (
	Select a.ProdId, a.ProdName, a.ProdCode, Cast(a.ProdDescription as nvarchar(30)) + ''...'' ProdDescription, 
		a.RefProdCategory, a.RefColor,a.RefProdType,a.RefSize,a.RefFabric,a.RefDesign,a.RefBrand,
		a.Celebrity,a.RetailPrice, a.WholeSalePrice,a.IsActive,
		(Case When a.ProdImgPath Is NULL Then (Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord) Else a.ProdImgPath End) ProdImgPath,
		(Case  When (Select top 1 IsNULL(c.IsGlobal,0) From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord) = 0
		Then (''' +@vMainPath +'''+ Cast(a.RefVendorId as nvarchar) + ''/Products/Original/'' +(Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) 
		Else (''' + @vMainPath +'''+ ''Global/Products/Original/'' +(Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) End) OriginalImgPath , 
		(Case  When (Select top 1 IsNULL(c.IsGlobal,0) From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord) = 0
		Then (''' + @vMainPath +'''+ Cast(a.RefVendorId as nvarchar) + ''/Products/Thumbnail/'' +(Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) 
		When (Select Count(*) From ProductImgDet c Where c.RefProdId = a.ProdId) = 0 
		Then (''' + @vMainPath +'''+ Cast(a.RefVendorId as nvarchar) +''/ThumbProd'' +(Select top 1 c.BGImage From Vendor c Where c.VendorId = a.RefVendorId))
		Else (''' + @vMainPath +'''+ ''Global/Products/Thumbnail/'' +(Select top 1 c.ImgName From ProductImgDet c Where c.RefProdId = a.ProdId Order By c.Ord)) End) ThumbnailImgPath,
		a.RefVendorId, (Select b.VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName,
		a.RefCatId, (Select b.CatName from CatalogMas b Where b.CatId = a.RefCatId) CatName,
		(Select b.CatCode From CatalogMas b Where b.CatId = a.RefCatId) CatCode
	From ProductMas a ) R
	Where R.RefVendorId = '+ Cast(@pRefVendorId as varchar) + @pdefWhere + '
	Order By R.RetailPrice
	OFFSET '+Cast(@pPageSize * @pPageIndex as varchar) +' ROWS
	FETCH NEXT '+ Cast(@pPageSize as varchar) + ' ROWS ONLY OPTION (RECOMPILE)'

	--print @Sql
	
	exec sp_executesql @Sql;
END
 
GO
/****** Object:  StoredProcedure [dbo].[sp_ProductMaster_SaveFromStore]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 29-06-2016
-- Description:	Save Product detail from store
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProductMaster_SaveFromStore]
	-- Add the parameters for the stored procedure here
	@pRefStoreId int,
	@pProdId int,
	@pProdName nvarchar(50),
	@pRefVendorId int,
	@pRefCatId int,
	@pProdCode nvarchar(10),
	@pProdDescription nvarchar(max),
	@pRefProdCategory nvarchar(50),
	@pRefColor nvarchar(200),
	@pRefProdType nvarchar(50),
	@pRefSize nvarchar(200),
	@pRefFabric nvarchar(50),
	@pRefDesign nvarchar(50),
	@pRefBrand nvarchar(50),
	@pCelebrity nvarchar(50),
	@pActivetillDate date,
	@pRetailPrice numeric(18,2),
	@pWholeSalePrice numeric(18,2),
	@pUser int,
	@pTerminal nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--Master List
	--1	Brand
	--2	Color
	--3	ProdType
	--4	Size
	--5	Fabric
	--6	Design

    -- Insert statements for procedure here
	Declare @cVal nvarchar(50);
	Declare @vColor nvarchar(max) ='', @vSize nvarchar(max)='', @vBrand nvarchar(max)='', 
	@vDesign nvarchar(max)='', @vFabric nvarchar(max)='', @vProdType nvarchar(max)=''; 

	--Color List
	Declare CurParam Cursor
	For Select x.ValueName From MasterValue x Where x.ID In (
	Select Distinct a.RefVendorValId From ParameterMapping a 
	Where a.RefStoreId = @pRefStoreId
	and a.RefMasterId = 2
	and a.RefStoreValId In (
	Select b.ID From MasterValue b 
	Where b.RefVendorId = @pRefStoreId 
	and b.RefMasterId = 2
	and ValueName In (Select Item From SplitString(@pRefColor,','))))

	Open CurParam 
	Fetch Next From CurParam Into @cVal 
		While @@FETCH_STATUS = 0
		Begin
			if(@vColor<>'')
				Set @vColor = @vColor + ',';

			Set @vColor = @vColor + @cVal;
			Fetch Next From CurParam Into @cVal 
		End
	Close CurParam 
	Deallocate CurParam

	Print @vColor

	--Size List
	Declare CurParam Cursor
	For Select x.ValueName From MasterValue x Where x.ID In (
	Select Distinct a.RefVendorValId From ParameterMapping a 
	Where a.RefStoreId = @pRefStoreId
	and a.RefMasterId = 4
	and a.RefStoreValId In (
	Select b.ID From MasterValue b 
	Where b.RefVendorId = @pRefStoreId 
	and b.RefMasterId = 4
	and ValueName In (Select Item From SplitString(@pRefSize,','))))

	Open CurParam 
	Fetch Next From CurParam Into @cVal 
		While @@FETCH_STATUS = 0
		Begin
			if(@vSize <> '')
				Set @vSize = @vSize+ ',';

			Set @vSize = @vSize + @cVal;
			Fetch Next From CurParam Into @cVal 
		End
	Close CurParam 
	Deallocate CurParam

	Print @vSize

	--Brand 
	Select top 1 @vBrand = x.ValueName From MasterValue x Where x.ID = (
	Select top 1 a.RefVendorValId From ParameterMapping a 
	Where a.RefStoreId = @pRefStoreId
	and a.RefMasterId = 1
	and a.RefStoreValId = (
	Select top 1 b.ID From MasterValue b 
	Where b.RefVendorId = @pRefStoreId 
	and b.RefMasterId = 1
	and ValueName  = @pRefBrand))

	--Product Type
	Select top 1 @vProdType = x.ValueName From MasterValue x Where x.ID = (
	Select top 1 a.RefVendorValId From ParameterMapping a 
	Where a.RefStoreId = @pRefStoreId
	and a.RefMasterId = 3
	and a.RefStoreValId = (
	Select top 1 b.ID From MasterValue b 
	Where b.RefVendorId = @pRefStoreId 
	and b.RefMasterId = 3
	and ValueName  = @pRefProdType))


	--Fabric 
	Select top 1 @vFabric = x.ValueName From MasterValue x Where x.ID = (
	Select top 1 a.RefVendorValId From ParameterMapping a 
	Where a.RefStoreId = @pRefStoreId
	and a.RefMasterId = 5
	and a.RefStoreValId = (
	Select top 1 b.ID From MasterValue b 
	Where b.RefVendorId = @pRefStoreId 
	and b.RefMasterId = 5
	and ValueName  = @pRefFabric))


	--Design 
	Select top 1 @vDesign = x.ValueName From MasterValue x Where x.ID = (
	Select top 1 a.RefVendorValId From ParameterMapping a 
	Where a.RefStoreId = @pRefStoreId
	and a.RefMasterId = 6
	and a.RefStoreValId = (
	Select top 1 b.ID From MasterValue b 
	Where b.RefVendorId = @pRefStoreId 
	and b.RefMasterId = 6
	and ValueName  = @pRefDesign))

	Declare @Result int = 0

	Insert Into ProductMas(ProdName,RefVendorId,RefCatId,ProdCode,ProdDescription,RefProdCategory,RefColor,
		RefProdType,RefSize,RefFabric,RefDesign,RefBrand,Celebrity,ProdImgPath,ActivetillDate,IsActive,
		RetailPrice,WholeSalePrice,RefProdId,RefStoreId,InsUser,InsDate,InsTerminal)
	Values(@pProdName,@pRefVendorId,@pRefCatId,@pProdCode,@pProdDescription,@pRefProdCategory,@vColor,
		@vProdType,@vSize,@vFabric,@vDesign,@vBrand,@pCelebrity,null,@pActivetillDate,
		1,@pRetailPrice,@pWholeSalePrice,@pProdId,@pRefStoreId,@pUser,GETDATE(),@pTerminal)

	Select @Result  = @@IDENTITY

	If(@Result > 0)
	Begin
		Insert Into ProductImgDet (RefProdId,ImgName, Ord, IsGlobal,InsUser, InsDate,InsTerminal)
		Select @Result,ImgName,Ord,1,@pUser,GETDATE(),@pTerminal from ProductImgDet  Where RefProdId = @pProdId
	End
	
	Select ProdImgId,RefProdId, ImgName,Ord,IsGlobal From ProductImgDet Where RefProdId = @Result

END

GO
/****** Object:  StoredProcedure [dbo].[sp_ProductMerege_Save]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 28-06-2016
-- Description:	Product Merge From Store
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProductMerege_Save]
	-- Add the parameters for the stored procedure here
	@pRefStoreId int,
	@pRefVendorId int,
	@pRefCatId int,
	@pCatCode nvarchar(10),
	@pCatName nvarchar(50),
	@pCatDescription nvarchar(500),
	@pCatLaunchDate date,
	@pIsFullset bit,
	@pUser int,
	@pTerminal nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	----Master List
	--1	Brand
	--2	Color
	--3	ProdType
	--4	Size
	--5	Fabric
	--6	Design

	SET NOCOUNT ON;
	Declare @cValName nvarchar(max) = '',@sValueName nvarchar(max) = '' ;
	Declare @iValid bit = 1;
    -- Insert statements for procedure here

	--Check Color List Mapped or Not
	Declare CurMasterVal Cursor
	For Select RefColor From ProductMas Where RefCatId = @pRefCatId

	Open CurMasterVal;
		Fetch Next From CurMasterVal Into @cValName
		While @@FETCH_STATUS = 0 
		Begin
			Print @cValName
			Declare CurCheck Cursor
			For Select Item From SplitString(@cValName,',')
			
			Open CurCheck;
				Fetch Next From CurCheck Into @sValueName
				While @@FETCH_STATUS = 0 
				Begin
					Print @sValueName
					
					if(Not Exists(Select * From ParameterMapping a
					Where a.RefMasterId = 2
					and a.RefStoreValId = (Select top 1 b.ID From MasterValue b 
					Where b.RefMasterId = 2 and b.RefVendorId = @pRefStoreId and b.ValueName = @sValueName)
					and a.RefVendorId = @pRefVendorId ))
					Begin
						Select CAST(0 as bit) Result, 'Color Name ' + @sValueName + ' is not mapped.' Msg, Cast(0 as int) Id,'' CatImg 
						Set @iValid = 0;
					End
					Fetch Next From CurCheck Into @sValueName
				End
			Close CurCheck;
			Deallocate CurCheck;

			Fetch Next From CurMasterVal Into @cValName
		End
	Close CurMasterVal;
	Deallocate CurMasterVal;
	
	--Print 'Color Complete'

	--Check Size List Mapped or Not
	Declare CurMasterVal Cursor
	For Select RefSize From ProductMas Where RefCatId = @pRefCatId

	Open CurMasterVal;
		Fetch Next From CurMasterVal Into @cValName
		While @@FETCH_STATUS = 0 
		Begin
			Declare CurCheck Cursor
			For Select Item From SplitString(@cValName,',')
			
			Open CurCheck;
				Fetch Next From CurCheck Into @sValueName
				While @@FETCH_STATUS = 0 
				Begin
					if(Not Exists(Select * From ParameterMapping a
					Where a.RefMasterId = 4
					and a.RefStoreValId = (Select top 1 b.ID From MasterValue b 
					Where b.RefMasterId = 4 and b.RefVendorId = @pRefStoreId and b.ValueName = @sValueName)
					and a.RefVendorId = @pRefVendorId ))
					Begin
						Select CAST(0 as bit) Result, 'Size Name ' + @sValueName + ' is not mapped.' Msg, Cast(0 as int) Id,'' CatImg 
						Set @iValid = 0;
					End
					Fetch Next From CurCheck Into @sValueName
				End
			Close CurCheck;
			Deallocate CurCheck;

			Fetch Next From CurMasterVal Into @cValName
		End
	Close CurMasterVal;
	Deallocate CurMasterVal;

	--Check Brand List Mapped or Not
	Declare CurMasterVal Cursor
	For Select RefBrand From ProductMas Where RefCatId = @pRefCatId

	Open CurMasterVal;
		Fetch Next From CurMasterVal Into @cValName
		While @@FETCH_STATUS = 0 
		Begin
			if(Not Exists(Select * From ParameterMapping a
				Where a.RefMasterId = 1
				and a.RefStoreValId = (Select top 1 b.ID From MasterValue b 
				Where b.RefMasterId = 1 and b.RefVendorId = @pRefStoreId and b.ValueName = @cValName)
				and a.RefVendorId = @pRefVendorId ))
				Begin
					Select CAST(0 as bit) Result, 'Brand Name ' + @cValName + ' is not mapped.' Msg, Cast(0 as int) Id ,'' CatImg 
					Set @iValid = 0;
				End

			Fetch Next From CurMasterVal Into @cValName
		End
	Close CurMasterVal;
	Deallocate CurMasterVal;

	--Check Prod Type List Mapped or Not
	Declare CurMasterVal Cursor
	For Select RefProdType From ProductMas Where RefCatId = @pRefCatId

	Open CurMasterVal;
		Fetch Next From CurMasterVal Into @cValName
		While @@FETCH_STATUS = 0 
		Begin
			if(Not Exists(Select * From ParameterMapping a
				Where a.RefMasterId = 3
				and a.RefStoreValId = (Select top 1 b.ID From MasterValue b 
				Where b.RefMasterId = 3 and b.RefVendorId = @pRefStoreId and b.ValueName = @cValName)
				and a.RefVendorId = @pRefVendorId ))
				Begin
					Select CAST(0 as bit) Result, 'Product Type ' + @cValName + ' is not mapped.' Msg, Cast(0 as int) Id,'' CatImg 
					Set @iValid = 0;
				End

			Fetch Next From CurMasterVal Into @cValName
		End
	Close CurMasterVal;
	Deallocate CurMasterVal;

	--Check Fabric List Mapped or Not
	Declare CurMasterVal Cursor
	For Select RefFabric From ProductMas Where RefCatId = @pRefCatId

	Open CurMasterVal;
		Fetch Next From CurMasterVal Into @cValName
		While @@FETCH_STATUS = 0 
		Begin
			if(Not Exists(Select * From ParameterMapping a
				Where a.RefMasterId = 5
				and a.RefStoreValId = (Select top 1 b.ID From MasterValue b 
				Where b.RefMasterId = 5 and b.RefVendorId = @pRefStoreId and b.ValueName = @cValName)
				and a.RefVendorId = @pRefVendorId ))
				Begin
					Select CAST(0 as bit) Result, 'Fabric Name ' + @cValName + ' is not mapped.' Msg, Cast(0 as int) Id,'' CatImg 
					Set @iValid = 0;
				End

			Fetch Next From CurMasterVal Into @cValName
		End
	Close CurMasterVal;
	Deallocate CurMasterVal;


	--Check Design List Mapped or Not
	Declare CurMasterVal Cursor
	For Select RefDesign From ProductMas Where RefCatId = @pRefCatId

	Open CurMasterVal;
		Fetch Next From CurMasterVal Into @cValName
		While @@FETCH_STATUS = 0 
		Begin
			if(Not Exists(Select * From ParameterMapping a
				Where a.RefMasterId = 6
				and a.RefStoreValId = (Select top 1 b.ID From MasterValue b 
				Where b.RefMasterId = 6 and b.RefVendorId = @pRefStoreId and b.ValueName = @cValName)
				and a.RefVendorId = @pRefVendorId ))
				Begin
					Select CAST(0 as bit) Result, 'Design Name ' + @cValName + ' is not mapped.' Msg, Cast(0 as int) Id,'' CatImg 
					Set @iValid = 0;
				End

			Fetch Next From CurMasterVal Into @cValName
		End
	Close CurMasterVal;
	Deallocate CurMasterVal;

	--Check Prod Category available in master or not
	
	Declare CurMasterVal Cursor
	For Select RefProdCategory From ProductMas Where RefCatId = @pRefCatId

	Open CurMasterVal;
		Fetch Next From CurMasterVal Into @cValName
		While @@FETCH_STATUS = 0 
		Begin
			if(Not Exists(Select * From ProductCategory a
				Where a.RefVendorId = @pRefVendorId and a.ProdCategoryName = @cValName))
				Begin
					Select CAST(0 as bit) Result, 'Product Category Name ' + @cValName + ' is not mapped.' Msg, Cast(0 as int) Id,'' CatImg 
					Set @iValid = 0;
				End

			Fetch Next From CurMasterVal Into @cValName
		End
	Close CurMasterVal;
	Deallocate CurMasterVal;


	Declare @RId int = 0;

	if(@iValid = 1)
	Begin
	--Insert Data in Catalogue Master
		Insert Into CatalogMas (RefVendorId,CatCode,CatName,CatImg,CatDescription,CatLaunchDate,IsFullset,IsActive, RefCatId,RefStoreId,InsUser,InsDate,InsTerminal)
		Select @pRefVendorId,@pCatCode,@pCatName,CatImg,@pCatDescription,@pCatLaunchDate,@pIsFullset,IsActive,@pRefCatId,@pRefStoreId,@pUser,GETDATE(),@pTerminal From CatalogMas Where CatId = @pRefCatId

		Select @RId  = IDENT_CURRENT('CatalogMas');

		Select CAST(1 as bit) Result, 'Catalogue successfully created.' Msg, @RId Id, CatImg From CatalogMas Where CatId = @pRefCatId
	End

	Select CAST(0 as bit) Result, 'Catalogue creation error.' Msg, @RId Id, CatImg From CatalogMas Where CatId = @pRefCatId
END

GO
/****** Object:  StoredProcedure [dbo].[sp_RetrieveMenuRightsWise_Select]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		JayamSoft
-- Create date: 14/Mar/2016	
-- Description:	Retrive menu rights details from MenuRoleRights
-- =============================================
CREATE PROCEDURE [dbo].[sp_RetrieveMenuRightsWise_Select]
	-- Add the parameters for the stored procedure here
	@pUserName nvarchar(50)
AS
BEGIN
	-- 7 - Role 

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Select statements for Menu Role Rights
	 select b.MenuName, b.ID, b.MenuDes, b.IsActive,
		b.ParentMenuID, b.OrderNo, b.ControllerName,
		b.ActionName, b.MenuPath,  a.RefRoleId, a.RefMenuId,
		a.CanInsert , a.CanUpdate , a.CanDelete , b.MenuIcon,
		a.CanView , a.InsUser, a.InsDate, a.InsTerminal,
		a.UpdUser, a.UpdDate, a.UpdTerminal
	from MenuMaster as b inner join 
		menurolerights as a  
		on b.ID = a.RefMenuId
		and a.refroleid = ( select ID from MasterValue  where ValueName = @pUserName and RefMasterId = 7)
		and a.CanView = 1
	order by b.OrderNo

END


GO
/****** Object:  StoredProcedure [dbo].[sp_StoreAssociation_Save]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 23/06/2016
-- Description:	Save Vendor Association Data
-- =============================================
CREATE PROCEDURE [dbo].[sp_StoreAssociation_Save]
	-- Add the parameters for the stored procedure here
	--@pId int = nULL,
	--@pRefVendorId int = NULL,
	@pRefVendorId int,
	@pStoreCode nvarchar(6),
	--@pVendorStatus nvarchar(15),
	--@pAppUserStatus nvarchar(15),
	--@pIsNotify bit,
	--@pIsDeleted bit,
	--@pReqDate Datetime,
	--@pApproveDate DateTime,
	--@pUser int,
	@pTerminal nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @vStoreAssociationId int  = 0;
	--Declare @vStatus bit = 0;
	Declare @pRefStoreId int = NULL;
	Select @pRefStoreId = VendorId from  Vendor Where VendorCode = @pStoreCode;

	-- Insert statements for procedure here
	if(@pRefStoreId Is NOT NULL)
	Begin
		If(Not Exists (Select * from StoreAssociation a Where a.RefStoreId = @pRefStoreId and a.RefVendorId = @pRefVendorId))
		Begin
			Insert Into StoreAssociation (RefStoreId , RefVendorId, StoreCode, StoreStatus, VendorStatus,  
				ReqDate, ApprovedDate, InsUser, InsDate, InsTerminal)
			Values (@pRefStoreId, @pRefVendorId, @pStoreCode, 'Pending' ,'Requested', 
				GetDate(), NULL, @pRefVendorId, GetDate(), @pTerminal)
				
			Select  @vStoreAssociationId = @@IDENTITY;
		End
		Else if(Exists (Select * from StoreAssociation a Where a.RefStoreId = @pRefStoreId and a.RefVendorId = @pRefVendorId and (a.VendorStatus = 'Cancelled' or a.VendorStatus = 'Deleted')))
		Begin
			Update 	StoreAssociation
			Set StoreStatus ='Pending',
				VendorStatus = 'Requested',
				UpdUser = @pRefVendorId,
				UpdDate = GETDATE(),
				UpdTerminal = @pTerminal
			Where RefStoreId = @pRefStoreId 
			and RefVendorId = @pRefVendorId

			Select  @vStoreAssociationId =  Id 
			From StoreAssociation 
			Where RefStoreId = @pRefStoreId 
			and RefVendorId = @pRefVendorId 
		End
		Else
		Begin
		--	Update VendorAssociation 
		--	Set RefVendorId = @pRefVendorId, 
		--		RefAUId = @pRefAUId , 
		--		VendorCode = @pVendorCode, 
		--		VendorStatus = @pVendorStatus , 
		--		AppUserStatus = @pAppUserStatus,
		--		IsNotify = @pIsNotify, 
		--		IsDeleted = @pIsDeleted, 
		--		ReqDate = @pReqDate, 
		--		ApproveDate = @pApproveDate, 
		--		UpdUser = @pUser, 
		--		UpdDate = GetDate(),
		--		UpdTerminal = @pTerminal
		--	Where Id = @pId;

			Set @vStoreAssociationId = -1;
		End

		Select @vStoreAssociationId Result;
	End
	Else
	Begin
		Select @vStoreAssociationId Result;
	End

END

GO
/****** Object:  StoredProcedure [dbo].[sp_StoreAssociation_SelectWhere]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 24/06/2016
-- Description:	Select AppUser base on Vendor Association
-- =============================================
CREATE PROCEDURE [dbo].[sp_StoreAssociation_SelectWhere]
	-- Add the parameters for the stored procedure here
	@pdefstr nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @Sql nvarchar(max) = '';
	Declare @MainFolder nvarchar(max) = '';
	Select top 1 @MainFolder = FolderPath  From CompanyProfile 

	--Select b.Id, a.VendorId,a.VendorCode,a.Address,a.City,a.ContactName,a.ContactNo1,a.ContactNo2,a.Country, 
	--		a.EmailId,a.FaxNo,a.IsActive,a.VendorName,a.WebSite,a.State,a.Pincode,a.Landmark,a.LogoImg,
	--		(@MainFolder + Cast(a.VendorId as nvarchar) + '/' + a.LogoImg) OriginalVendorImgPath,
	--		(@MainFolder + Cast(a.VendorId as nvarchar) + '/Thumb' + a.LogoImg) ThumbnailVendorImgPath,
	--		(@MainFolder + Cast(b.RefStoreId as nvarchar) + '/' + (Select c.LogoImg From Vendor c Where c.VendorId = b.RefStoreId )) OriginalStoreImgPath,
	--		(@MainFolder + Cast(b.RefStoreId as nvarchar) + '/Thumb' + (Select c.LogoImg From Vendor c Where c.VendorId = b.RefStoreId )) ThumbnailStoreImgPath,
	--		a.MobileNo1,a.MobileNo2,b.VendorStatus,b.StoreStatus,b.ApprovedDate,b.ReqDate,b.RefStoreId,
	--		(Select c.VendorName From Vendor c Where c.VendorId = b.RefStoreId ) StoreName,
	--		(Select c.LogoImg From Vendor c Where c.VendorId = b.RefStoreId ) StoreImg,
	--		(Select c.VendorCode From Vendor c Where c.VendorId = b.RefStoreId ) StoreCode,
	--		b.InsUser, b.InsDate, b.InsTerminal,
	--		b.UpdUser, b.UpdDate, b.UpdTerminal
	--From Vendor a
	--inner Join StoreAssociation b
	--on a.VendorId = b.RefVendorId
	

    -- Insert statements for procedure here
	Set @Sql = 'Select * from 
	(Select b.Id, a.VendorId,a.VendorCode,a.Address,a.City,a.ContactName,a.ContactNo1,a.ContactNo2,a.Country, 
			a.EmailId,a.FaxNo,a.IsActive,a.VendorName,a.WebSite,a.State,a.Pincode,a.Landmark,a.LogoImg,
			('''+ @MainFolder +''' + Cast(a.VendorId as nvarchar) + ''/'' + a.LogoImg) OriginalVendorImgPath,
			('''+ @MainFolder +''' + Cast(a.VendorId as nvarchar) + ''/Thumb'' + a.LogoImg) ThumbnailVendorImgPath,
			('''+ @MainFolder +''' + Cast(b.RefStoreId as nvarchar) + ''/'' + (Select c.LogoImg From Vendor c Where c.VendorId = b.RefStoreId )) OriginalStoreImgPath,
			('''+ @MainFolder +''' + Cast(b.RefStoreId as nvarchar) + ''/Thumb'' + (Select c.LogoImg From Vendor c Where c.VendorId = b.RefStoreId )) ThumbnailStoreImgPath,
			a.MobileNo1,a.MobileNo2,b.VendorStatus,b.StoreStatus,b.ApprovedDate,b.ReqDate,b.RefStoreId, 
			(Select c.VendorName From Vendor c Where c.VendorId = b.RefStoreId ) StoreName,
			(Select c.LogoImg From Vendor c Where c.VendorId = b.RefStoreId ) StoreImg,
			(Select c.VendorCode From Vendor c Where c.VendorId = b.RefStoreId ) StoreCode,
			b.InsUser, b.InsDate, b.InsTerminal,
			b.UpdUser, b.UpdDate, b.UpdTerminal
	From Vendor a
	inner Join StoreAssociation b
	on a.VendorId = b.RefVendorId	) x
	Where 1=1 ' + @pdefstr 

	Print @Sql

	exec sp_executesql @Sql;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_StoreAssociation_SelectWhereWithLazyload]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 24/06/2016
-- Description:	Select AppUser base on Vendor Association
-- =============================================
CREATE PROCEDURE [dbo].[sp_StoreAssociation_SelectWhereWithLazyload]
	-- Add the parameters for the stored procedure here
	@pSearch nvarchar(max),
	--@pStoreStatus nvarchar(20),
	--@pVendorStatus nvarchar(20),
	--@pRefStoreId int,
	@pPageSize int = 10,
	@pPageIndex int = 0,
	@pdefstr nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @Sql nvarchar(max) = '';
	Declare @MainFolder nvarchar(max) = '';
	Select top 1 @MainFolder = FolderPath  From CompanyProfile 

	if(@pSearch <> '' And @pSearch Is Not null)
	Begin
		Set @pdefstr = @pdefstr + ' and ( VendorName Like ''%'+ @pSearch +'%'' 
					or  MobileNo1 Like ''%'+ @pSearch +'%''
					or  City Like ''%'+ @pSearch +'%''
					or  State Like ''%'+ @pSearch +'%'') '
	End

	--Select b.Id, a.VendorId,a.VendorCode,a.Address,a.City,a.ContactName,a.ContactNo1,a.ContactNo2,a.Country, 
	--		a.EmailId,a.FaxNo,a.IsActive,a.VendorName,a.WebSite,a.State,a.Pincode,a.Landmark,a.LogoImg,
	--		(@MainFolder + Cast(a.VendorId as nvarchar) + '/' + a.LogoImg) OriginalVendorImgPath,
	--		(@MainFolder + Cast(a.VendorId as nvarchar) + '/Thumb' + a.LogoImg) ThumbnailVendorImgPath,
	--		(@MainFolder + Cast(b.RefStoreId as nvarchar) + '/' + (Select c.LogoImg From Vendor c Where c.VendorId = b.RefStoreId )) OriginalStoreImgPath,
	--		(@MainFolder + Cast(b.RefStoreId as nvarchar) + '/Thumb' + (Select c.LogoImg From Vendor c Where c.VendorId = b.RefStoreId )) ThumbnailStoreImgPath,
	--		a.MobileNo1,a.MobileNo2,b.VendorStatus,b.StoreStatus,b.ApprovedDate,b.ReqDate,b.RefStoreId,
	--		(Select c.VendorName From Vendor c Where c.VendorId = b.RefStoreId ) StoreName,
	--		(Select c.LogoImg From Vendor c Where c.VendorId = b.RefStoreId ) StoreImg,
	--		b.InsUser, b.InsDate, b.InsTerminal,
	--		b.UpdUser, b.UpdDate, b.UpdTerminal
	--From Vendor a
	--inner Join StoreAssociation b
	--on a.VendorId = b.RefVendorId
	

    -- Insert statements for procedure here
	Set @Sql = 'Select * from 
	(Select b.Id, a.VendorId,a.VendorCode,a.Address,a.City,a.ContactName,a.ContactNo1,a.ContactNo2,a.Country, 
			a.EmailId,a.FaxNo,a.IsActive,a.VendorName,a.WebSite,a.State,a.Pincode,a.Landmark,a.LogoImg,
			('''+ @MainFolder +''' + Cast(a.VendorId as nvarchar) + ''/'' + a.LogoImg) OriginalVendorImgPath,
			('''+ @MainFolder +''' + Cast(a.VendorId as nvarchar) + ''/Thumb'' + a.LogoImg) ThumbnailVendorImgPath,
			('''+ @MainFolder +''' + Cast(b.RefStoreId as nvarchar) + ''/'' + (Select c.LogoImg From Vendor c Where c.VendorId = b.RefStoreId )) OriginalStoreImgPath,
			('''+ @MainFolder +''' + Cast(b.RefStoreId as nvarchar) + ''/Thumb'' + (Select c.LogoImg From Vendor c Where c.VendorId = b.RefStoreId )) ThumbnailStoreImgPath,
			a.MobileNo1,a.MobileNo2,b.VendorStatus,b.StoreStatus,b.ApprovedDate,b.ReqDate,b.RefStoreId, 
			(Select c.VendorName From Vendor c Where c.VendorId = b.RefStoreId ) StoreName,
			(Select c.LogoImg From Vendor c Where c.VendorId = b.RefStoreId ) StoreImg,
			b.InsUser, b.InsDate, b.InsTerminal,
			b.UpdUser, b.UpdDate, b.UpdTerminal
	From Vendor a
	inner Join StoreAssociation b
	on a.VendorId = b.RefVendorId	) x
	Where 1=1
	' + @pdefstr + '
	Order By x.VendorName
	OFFSET ' + Cast(@pPageSize * @pPageIndex as nvarchar) +' Rows
	Fetch Next '+Cast(@pPageSize as nvarchar) +' Rows ONLY OPTION (RECOMPILE)'

	Print @Sql

	exec sp_executesql @Sql;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_Subscription_SelectBaseOnType]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 08-06-2016
-- Description:	Subscription detail select base on type name
-- =============================================
CREATE PROCEDURE [dbo].[sp_Subscription_SelectBaseOnType]
	-- Add the parameters for the stored procedure here
	@pSubType nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select a.SubId, a.SubType, a.NoOfAppUser, 
		a.NoOfDays, a.NoOfProducts, a.NoOfSlider,
		a.InsDate,a.InsUser,a.InsTerminal,
		a.UpdUser, a.UpdDate, a.UpdTerminal
	From Subscription a
	Where a.SubType = @pSubType
END

GO
/****** Object:  StoredProcedure [dbo].[sp_Vendor_ResetCode]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft	
-- Create date: 23/05/2016
-- Description:	sp for Reset Vendor Code
-- =============================================
CREATE PROCEDURE [dbo].[sp_Vendor_ResetCode]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @viCtr int = 1;
	Declare @pVendorCode nvarchar(6);

    -- Insert statements for procedure here
	While @viCtr = 1
		Begin
			Select @pVendorCode = LEFT(Cast(Round (RAND() * 1000000,0,0) as nvarchar) + '000000',6)

			If(Not Exists (Select * From Vendor Where VendorCode = @pVendorCode))
			Begin
				Set @viCtr = 0;
			End
		End

	Select @pVendorCode VendorCode
END

GO
/****** Object:  StoredProcedure [dbo].[sp_Vendor_Save]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 16/04/2016
-- Description:	Save Vendor Data
-- =============================================
CREATE PROCEDURE [dbo].[sp_Vendor_Save]
	-- Add the parameters for the stored procedure here
	@pVendorId int = null,
	@pVendorName varchar(100),
	@pUserName nvarchar(50),
	@pVendorCode varchar(6),
	@pAddress nvarchar(100),
	@pLandMark nvarchar(100),
	@pCountry nvarchar(30),
	@pState nvarchar(30),
	@pCity nvarchar(30),
	@pPincode nvarchar(10),
	@pContactName nvarchar(50),
	@pContactNo1 nvarchar(20),
	@pContactNo2 nvarchar(20),
	@pMobileNo1 nvarchar(20),
	@pMobileNo2 nvarchar(20),
	@pFaxNo nvarchar(20),
	@pEmailId nvarchar(100),
	@pWebSite nvarchar(100),
	@pLogoImg nvarchar(200),
	@pIsActive bit,
	@pSubscriptionType nvarchar(50),
	@pReferenceCode nvarchar(10), 
	@pAboutUs nvarchar(max),
	@pProdDispName nvarchar(50),
	@pCatDispName nvarchar(50),
	@pBGImage nvarchar(50),
	@pUser int,
	@pTerminal nvarchar(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @vVendorId int = null;
	Declare @viCtr int = 1;
	Declare @pReferalCode nvarchar(6)

	--Declare @pVendorCode varchar(6);
    -- Insert statements for procedure here

	If(Not Exists(Select * From Vendor Where VendorId = @pVendorId))
	Begin
		While @viCtr = 1
		Begin
			Select @pVendorCode = LEFT(Cast(Round (RAND() * 1000000,0,0) as nvarchar) + '000000',6)

			If(Not Exists (Select * From Vendor Where VendorCode = @pVendorCode))
			Begin
				Set @viCtr = 0;
			End
		End

		Set  @viCtr = 1;

		While @viCtr = 1
		Begin
			select @pReferalCode = Upper(Cast(CHAR(ASCII('a')+(ABS(CHECKSUM(NewID()))%25)) + LEFT(NEWID(),3) + CHAR(ASCII('A')+(ABS(CHECKSUM(NewID()))%25)) + Cast(ABS(CHECKSUM(newid())) as nvarchar) as nvarchar(6)))

			If(Not Exists (Select * From Vendor Where ReferalCode = @pReferalCode))
			Begin
				Set @viCtr = 0;
			End
		End
		
		Insert Into Vendor ( VendorName, UserName , VendorCode, ReferalCode, ReferenceCode , [Address], LandMark, Country,
				[State], City, Pincode, ContactName ,ContactNo1, ContactNo2, MobileNo1, MobileNo2,
				FaxNo,EmailId, WebSite, LogoImg, IsActive, AboutUs,ProdDispName, CatDispName,BGImage ,
				  InsUser , InsDate, InsTerminal)
		Values (@pVendorName, @pUserName , @pVendorCode, @pReferalCode, @pReferenceCode, @pAddress, @pLandMark, @pCountry,
				@pState, @pCity, @pPincode, @pContactName, @pContactNo1, @pContactNo2, @pMobileNo1, @pMobileNo2,
				@pFaxNo, @pEmailId, @pWebSite, @pLogoImg, @pIsActive, @pAboutUs,@pProdDispName, @pCatDispName,@pBGImage ,
				@pUser ,GETDATE(), @pTerminal)

		Select @vVendorId  = IDENT_CURRENT('Vendor') 

		if(@psubscriptionType <> '' and @psubscriptionType Is Not NULL)
		Begin
			Declare @pRefSubId int;
			Declare @pValidaFromDate date ,@pValidToDate Date;
			Select @pRefSubId = SubId, @pValidToDate = DATEADD(DAY,NoOfDays,GETDATE()) from  Subscription Where SubType = @psubscriptionType;
			Set @pValidaFromDate = GETDATE();
			
			Insert Into VendorSubDet (RefVendorId, RefSubId, ValidFromDate, ValidTodate, InsUser, InsDate, InsTerminal)
			values (@vVendorId, @pRefSubId , @pValidaFromDate, @pValidToDate , @vVendorId, GETDATE(), @pTerminal)
		End
		
	End
	Else
	Begin
		Update Vendor
		Set VendorName = @pVendorName,
			VendorCode = @pVendorCode, 
			[Address] = @pAddress, 
			LandMark = @pLandMark,  
			Country = @pCountry,
			[State] = @pState, 
			City = @pCity,   
			Pincode = @pPincode, 
			ContactName = @pContactName,
			ContactNo1 = @pContactNo1, 
			ContactNo2 = @pContactNo2,  
			MobileNo1 = @pMobileNo1, 
			MobileNo2 = @pMobileNo2,
			FaxNo = @pFaxNo,
			EmailId = @pEmailId, 
			WebSite = @pWebSite, 
			LogoImg = @pLogoImg,
			IsActive = @pIsActive, 
			AboutUs = @pAboutUs,
			ProdDispName = @pProdDispName,
			CatDispName = @pCatDispName,
			BGImage = @pBGImage ,
			UpdUser  = @pUser, 
			UpdDate = GetDate(), 
			UpdTerminal = @pTerminal
		Where VendorId = @pVendorId

		Set @vVendorId  =  @pVendorId
	End

	Select @vVendorId  As Result
END

GO
/****** Object:  StoredProcedure [dbo].[sp_Vendor_Select]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 18/04/2016
-- Description:	Get Vendor Data
-- =============================================
CREATE PROCEDURE [dbo].[sp_Vendor_Select]
	-- Add the parameters for the stored procedure here
	@pVendorId int = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @MainPath nvarchar(50) 
	Select top 1 @MainPath = FolderPath From CompanyProfile

    -- Insert statements for procedure here
	Select a.VendorId , a.VendorName, a.UserName  , a.[Address], a.Landmark, 
		a.Country, a.[State], a.City, a.Pincode, a.ContactName, a.ContactNo1, a.ContactNo2,
		a.MobileNo1, a.MobileNo2, a.FaxNo, a.EmailId, a.WebSite, 
		a.LogoImg, (@MainPath + Cast(a.VendorId as nvarchar) + '/Thumb' + a.LogoImg) ThumbnailImgPath ,
		a.VendorCode, a.ReferalCode, a.ReferenceCode, a.IsActive, a.AboutUs,a.ProdDispName,a.CatDispName,
		a.BGImage,(@MainPath + Cast(a.VendorId as nvarchar) + '/' + a.BGImage) ThumbnailBGImgPath ,
		a.InsUser, a.InsDate, a.InsTerminal, a.UpdUser, a.UpdDate ,a.UpdTerminal
	From Vendor a
	Where a.VendorId = Case When @pVendorId Is NULL Then a.VendorId Else @pVendorId End
END

GO
/****** Object:  StoredProcedure [dbo].[sp_Vendor_SelectWhere]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 18/04/2016
-- Description:	Get Vendor Data
-- =============================================
CREATE PROCEDURE [dbo].[sp_Vendor_SelectWhere]
	-- Add the parameters for the stored procedure here
	@pdefWhere nvarchar(max)  = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare  @Sql nvarchar(max) = null;
	Declare @MainFolder nvarchar(max) = '';
	Select top 1 @MainFolder = FolderPath From CompanyProfile;

	--main query
	--Select a.VendorId , a.VendorName , a.UserName  , a.[Address], a.Landmark, 
	--	a.Country, a.[State], a.City, a.Pincode, a.ContactName, a.ContactNo1, a.ContactNo2,
	--	a.MobileNo1, a.MobileNo2, a.FaxNo, a.EmailId, a.WebSite, a.LogoImg,
	-- a.VendorCode, a.ReferalCode, a.ReferenceCode, a.IsActive, a.AboutUs,a.ProdDispName,a.CatDispName,
	-- a.BGImage,(@MainFolder + Cast(a.VendorId as nvarchar) + a.BGImage) ThumbnailBGImgPath,
	--	a.InsUser, a.InsDate, a.InsTerminal, a.UpdUser, a.UpdDate ,a.UpdTerminal
	--From Vendor a

    -- Insert statements for procedure here
	Set @Sql = 'Select * from (
	Select a.VendorId , a.VendorName , a.UserName  , a.[Address], a.Landmark, 
		a.Country, a.[State], a.City, a.Pincode, a.ContactName, a.ContactNo1, a.ContactNo2,
		a.MobileNo1, a.MobileNo2, a.FaxNo, a.EmailId, a.WebSite, a.LogoImg, 
		a.VendorCode, a.ReferalCode, a.ReferenceCode, a.IsActive,a.AboutUs,a.ProdDispName,a.CatDispName,
		a.BGImage,(''' + @MainFolder + '''+ Cast(a.VendorId as nvarchar) + a.BGImage) ThumbnailBGImgPath,
		a.InsUser, a.InsDate, a.InsTerminal, a.UpdUser, a.UpdDate ,a.UpdTerminal
	From Vendor a) m
	Where 1=1 ' +  @pdefWhere

	exec sp_executesql @Sql;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_VendorAssociation_MostVisitedUser]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 02-07-2016
-- Description:	Get Most Visited user
-- =============================================
CREATE PROCEDURE [dbo].[sp_VendorAssociation_MostVisitedUser]
	-- Add the parameters for the stored procedure here
	@pRefVendorId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select a.RefAUId, a.Id, a.RefVendorId, a.ApproveDate, a.VendorStatus, a.AppUserStatus, a.VendorCode, 
		(Select b.AUName From AppUsers b Where b.AUId = a.RefAUId) AUName,a.VisitDateTime
	from VendorAssociation a
		Inner join (select top 10 RefAUId, Count(*) ActiveCount from AppLog 
		Where LogType = 'Product' OR LogType = 'Catalog'  
		Group by RefAUId,RefVendorId 
		Having RefVendorId = @pRefVendorId ) x 
		On a.RefAUId = x.RefAUId
		Where a.RefVendorId = @pRefVendorId 
		Order By x.ActiveCount Desc

END

GO
/****** Object:  StoredProcedure [dbo].[sp_VendorAssociation_Rate]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		jayamSoft
-- Create date: 25/05/2016
-- Description:	Rate to Vendor
-- =============================================
CREATE PROCEDURE [dbo].[sp_VendorAssociation_Rate]
	-- Add the parameters for the stored procedure here
	@pVendorId int,
	@pAUId int,
	@pRate int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Update VendorAssociation
	Set RateVendor = @pRate
	Where RefAUId = @pAUId
	and RefVendorId = @pVendorId

	Select Cast(1 as bit) Result
END

GO
/****** Object:  StoredProcedure [dbo].[sp_VendorAssociation_Save]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 16/04/2016
-- Description:	Save Vendor Association Data
-- =============================================
CREATE PROCEDURE [dbo].[sp_VendorAssociation_Save]
	-- Add the parameters for the stored procedure here
	--@pId int = nULL,
	--@pRefVendorId int = NULL,
	@pRefAUId int ,
	@pVendorCode nvarchar(6)
	--@pVendorStatus nvarchar(15),
	--@pAppUserStatus nvarchar(15),
	--@pIsNotify bit,
	--@pIsDeleted bit,
	--@pReqDate Datetime,
	--@pApproveDate DateTime,
	--@pUser int,
	--@pTerminal nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @vVendorAssociationId  int  = 0;
	--Declare @vStatus bit = 0;
	Declare @pRefVendorId int = NULL;
	Select @pRefVendorId = VendorId from  Vendor Where VendorCode = @pVendorCode;

	Declare @pTerminal nvarchar(60) = NULL;
	Select  @pTerminal = DeviceId From AppUsers Where AUId = @pRefAUId;

    -- Insert statements for procedure here
	if(@pRefVendorId Is NOT NULL)
	Begin
		If(Not Exists (Select * from VendorAssociation a Where a.RefVendorId = @pRefVendorId and a.RefAUId = @pRefAUId))
		Begin
			Insert Into VendorAssociation (RefVendorId, RefAUId , VendorCode, VendorStatus, AppUserStatus, IsNotify, 
				ReqDate, ApproveDate, InsUser, InsDate, InsTerminal)
			Values (@pRefVendorId, @pRefAUId , @pVendorCode, 'Pending' ,'Requested', 1, 
				GetDate(), NULL, @pRefAUId, GetDate(), @pTerminal)
				
			Select  @vVendorAssociationId = @@IDENTITY;
		End
		Else if(Exists (Select * from VendorAssociation a Where a.RefVendorId = @pRefVendorId and a.RefAUId = @pRefAUId and (a.AppUserStatus = 'Cancelled' or a.AppUserStatus = 'Deleted')))
		Begin
			Update 	VendorAssociation
			Set VendorStatus ='Pending',
				AppUserStatus = 'Requested',
				UpdUser = @pRefAUId,
				UpdDate = GETDATE(),
				UpdTerminal = @pTerminal
			Where RefVendorId = @pRefVendorId 
			and RefAUId = @pRefAUId

			Select  @vVendorAssociationId =  Id 
			From VendorAssociation 
			Where RefVendorId = @pRefVendorId 
			and RefAUId = @pRefAUId
		End
		Else if(Exists (Select * from VendorAssociation a Where a.RefVendorId = @pRefVendorId and a.RefAUId = @pRefAUId and (a.AppUserStatus = 'Approved' and a.VendorStatus = 'Approved')))
		Begin
			Update VendorAssociation 
			Set VisitDateTime = GETDATE()
			Where RefVendorId = @pRefVendorId 
			and RefAUId = @pRefAUId 

			Select @vVendorAssociationId = Id from VendorAssociation a 
			Where a.RefVendorId = @pRefVendorId 
			and a.RefAUId = @pRefAUId 
			and (a.AppUserStatus = 'Approved' and a.VendorStatus = 'Approved');
		End

		Select @vVendorAssociationId  Result;
	End
	Else
	Begin
		Select @vVendorAssociationId  Result;
	End

END

GO
/****** Object:  StoredProcedure [dbo].[sp_VendorAssociation_Select]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 16/04/2016
-- Description:	Select Vendor Association Data
-- =============================================
CREATE PROCEDURE [dbo].[sp_VendorAssociation_Select]
	-- Add the parameters for the stored procedure here
	@pAUId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @MainPath nvarchar(50) = ''
	Select top 1 @MainPath = FolderPath From CompanyProfile

	Declare @RecordCount int;
	
    -- Insert statements for procedure here
	Select a.Id, a.RefVendorId, (Select b.VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName, 
		(Select IsNULL(b.LogoImg,'') From Vendor b Where b.VendorId = a.RefVendorId) LogoImg,
		(Select IsNULL(b.ProdDispName,'') From Vendor b Where b.VendorId = a.RefVendorId) ProdDispName,
		(Select IsNULL(b.CatDispName,'') From Vendor b Where b.VendorId = a.RefVendorId) CatDispName,
		IsNULL((@MainPath + Cast(a.RefVendorId as nvarchar) + '/Thumb'+ (Select b.LogoImg From Vendor b Where b.VendorId = a.RefVendorId)),'') ThumbnailImgPath,
		IsNULL((@MainPath + Cast(a.RefVendorId as nvarchar) + '/'+ (Select b.BGImage From Vendor b Where b.VendorId = a.RefVendorId)),'') BGImgPath,
		a.RefAUId, (Select b.AUName From AppUsers b Where b.AUId = a.RefAUId) AUName,IsNULL(RateVendor,0) RateVendor,
		VendorCode, VendorStatus, AppUserStatus, IsNotify, ReqDate, IsNULL(ApproveDate,'') ApproveDate,
		(Case When (Select Count(*) From ProductMas b Where b.RefVendorId = a.RefVendorId) > 0  and 
		(Select Count(*) From VendorSlider b Where b.RefVendorId = a.RefVendorId and b.DisplayPage = 'Home') > 0 Then 2 Else 0 End) 
		RecordCount ,IsNULL(a.IsAdmin,0) IsAdmin,IsNULL(a.IsAdminNotification,0) IsAdminNotification,
		a.VisitDateTime
		--InsUser, InsDate, InsTerminal, UpdUser, UpdDate, UpdTerminal
	From VendorAssociation a
	Where a.RefAUId = @pAUId
	and a.AppUserStatus <> 'Cancelled'
	and a.VendorStatus <> 'Rejected'
	Order By a.VendorStatus,a.VisitDateTime Desc
END

GO
/****** Object:  StoredProcedure [dbo].[sp_VendorAssociation_SelectBaseOnVendor]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		jayamSoft
-- Create date: 24/05/2016
-- Description:	Get List of Contact Which Associated With Vendor
-- =============================================
CREATE PROCEDURE [dbo].[sp_VendorAssociation_SelectBaseOnVendor]
	-- Add the parameters for the stored procedure here
	@pVendorId int,
	@pGroupId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select * from (Select a.Id, a.RefAUId, a.RefVendorId,
	c.AUName, (Case When a.RefAUId = b.RefAUId Then Cast(1 as bit) Else Cast(0 as bit) End) InGroup,
	c.EmailId,c.MobileNo1,c.CompanyName,a.VendorStatus,a.VisitDateTime
	from VendorAssociation a
	Left Join GroupContactList b
	On a.RefAUId = b.RefAUId
	and b.RefGroupId = @pGroupId
	Inner Join AppUsers c
	On a.RefAUId = c.AUId
	Where a.RefVendorId = @pVendorId) x
	Where x.InGroup = 0
	and x.VendorStatus = 'Approved'
	
	
END

GO
/****** Object:  StoredProcedure [dbo].[sp_VendorAssociation_SelectWhere]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 16/04/2016
-- Description:	Select Vendor Association Data
-- =============================================
CREATE PROCEDURE [dbo].[sp_VendorAssociation_SelectWhere]
	-- Add the parameters for the stored procedure here
	@pdefWhere nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @Sql nvarchar(max) = ''
	Declare @MainPath nvarchar(50) = ''
	Select top 1 @MainPath = FolderPath From CompanyProfile;

	--Select a.Id, a.RefVendorId, b.VendorName, 
	--	b.LogoImg,(@MainPath + Cast(a.RefVendorId as nvarchar) + '/Thumb' + b.LogoImg) ThumbnailImgPath,
	--	IsNULL((@MainPath + Cast(a.RefVendorId as nvarchar) + '/'+ b.BGImage),'') BGImgPath,
	--	a.RefAUId, c.AUName,c.AppUserImg,c.CompanyName,c.EmailId,c.MobileNo1,
	--	b.VendorCode, a.VendorStatus, a.AppUserStatus, a.IsNotify, a.ReqDate, a.ApproveDate,
	--	DATEDIFF(HOUR,  a.ReqDate , GETDATE())  Interval,
	--	a.RateVendor,(Select COUNT(*) From EnquiryList e Where e.RefVendorId = a.RefVendorId and e.RefAUId = a.RefAUId) EnqCount,
	--	a.IsAdmin, a.IsAdminNotification,a.VisitDateTime,
	--	c.GCMID,c.DeviceID,
	--	a.InsUser, a.InsDate, a.InsTerminal, a.UpdUser, a.UpdDate, a.UpdTerminal
	--From VendorAssociation a 
	--inner join Vendor b 
	--on b.VendorId = a.RefVendorId
	--inner join AppUsers c
	--on c.AUId = a.RefAUId

    -- Insert statements for procedure here
	Set @Sql = 'Select * From (
	Select a.Id, a.RefVendorId, b.VendorName, 
		b.LogoImg,('''+ @MainPath + ''' + Cast(a.RefVendorId as nvarchar) + ''/Thumb'' + b.LogoImg) ThumbnailImgPath,
		IsNULL(('''+ @MainPath +'''+ Cast(a.RefVendorId as nvarchar) + ''/''+ b.BGImage),'''') BGImgPath,
		a.RefAUId, c.AUName,c.AppUserImg,c.CompanyName,c.EmailId,c.MobileNo1,
		b.VendorCode, a.VendorStatus, a.AppUserStatus, a.IsNotify, a.ReqDate, a.ApproveDate,
		a.RateVendor,(Select COUNT(*) From EnquiryList e Where e.RefVendorId = a.RefVendorId and e.RefAUId = a.RefAUId) EnqCount,
		a.IsAdmin, a.IsAdminNotification,a.VisitDateTime,
		c.GCMID,c.DeviceID,
		DATEDIFF(HOUR,  a.ReqDate , GETDATE())  Interval,
		a.InsUser, a.InsDate, a.InsTerminal, a.UpdUser, a.UpdDate, a.UpdTerminal
	From VendorAssociation a 
	inner join Vendor b 
	on b.VendorId = a.RefVendorId
	inner join AppUsers c
	on c.AUId = a.RefAUId ) R
	Where 1 = 1 ' + @pdefWhere;

	exec sp_executesql @Sql
	
END

GO
/****** Object:  StoredProcedure [dbo].[sp_VendorSlider_Save]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 04/05/2016
-- Description:	Save VendorSlider 
-- =============================================
CREATE PROCEDURE [dbo].[sp_VendorSlider_Save]
	-- Add the parameters for the stored procedure here
	@pSliderId int,
	@pRefVendorId int,
	@pSliderTitle nvarchar(50),
	@pSliderImg nvarchar(50),
	@pSliderUrl nvarchar(500),
	@pOrd int,
	@pDisplayPage nvarchar(50),
	@pCategory nvarchar(500),
	@pStartDate date,
	@pEndDate date,
	@pUser int,
	@pTerminal nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @Result int = 0;

    -- Insert statements for procedure here
	if(Not Exists (Select * from VendorSlider Where SliderId = @pSliderId))
	Begin
		Insert Into VendorSlider (RefVendorId,SliderTitle, SliderImg, SliderUrl, Ord,DisplayPage, Category,
			StartDate, EndDate, InsUser, InsDate, InsTerminal)
		Values (@pRefVendorId,@pSliderTitle, @pSliderImg, @pSliderUrl, @pOrd,@pDisplayPage, @pCategory,
			@pStartDate, @pEndDate, @pUser, GETDATE(), @pTerminal)

		Select @Result = @@IDENTITY;
	End
	Else
	Begin
		Update VendorSlider
		Set SliderTitle = @pSliderTitle , 
			SliderImg = @pSliderImg , 
			SliderUrl = @pSliderUrl, 
			Ord = @pOrd,
			DisplayPage = @pDisplayPage, 
			Category = @pCategory,
			StartDate = @pStartDate, 
			EndDate = @pEndDate, 
			UpdUser = @pUser, 
			UpdDate = GetDate(), 
			UpdTerminal = @pTerminal
		Where SliderId = @pSliderId

		Set @Result = @pSliderId
	End
	
	Select @Result Result
END

GO
/****** Object:  StoredProcedure [dbo].[sp_VendorSlider_Select]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 04/05/2016
-- Description:	Get Vendor Slider Data base on SliderId or all Slider list
-- =============================================
CREATE PROCEDURE [dbo].[sp_VendorSlider_Select]
	-- Add the parameters for the stored procedure here
	@pSliderId int = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select a.SliderId, 
		a.RefVendorId , (Select b.VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName, 
		a.SliderTitle, a.SliderImg, 
		a.SliderUrl,a.Ord, a.DisplayPage, 
		a.Category,a.StartDate, a.EndDate,
		a.InsUser, a.InsDate, a.InsTerminal, 
		a.UpdUser, a.UpdDate, a.UpdTerminal
	From VendorSlider a
	Where a.SliderId = Case When @pSliderId Is NULl Then a.SliderId Else @pSliderId End

END

GO
/****** Object:  StoredProcedure [dbo].[sp_VendorSlider_SelectForAPI]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 09/05/2016
-- Description:	Get Slider List Base on Category  and vendor
-- =============================================
CREATE PROCEDURE [dbo].[sp_VendorSlider_SelectForAPI]
	-- Add the parameters for the stored procedure here
	@pRefVendorId int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @MainPath nvarchar(50) = ''
	Select Top 1 @MainPath =  FolderPath From CompanyProfile

    -- Insert statements for procedure here
	Select a.RefVendorId, 
	a.Ord,a.SliderTitle, a.SliderUrl, a.DisplayPage ,a.Category ,
	(@MainPath + CAST(@pRefVendorId as nvarchar) + '/Slider/Original/' + a.SliderImg) OriginalImgPath,
	(@MainPath + CAST(@pRefVendorId as nvarchar) + '/Slider/Thumbnail/' + a.SliderImg) ThumbnailImgPath
	From VendorSlider a
	Where a.RefVendorId = @pRefVendorId
	and GETDATE() between Cast(a.StartDate as Date) and Cast(a.EndDate as Date)
	Order By a.Ord

END

GO
/****** Object:  StoredProcedure [dbo].[sp_VendorSlider_SelectWhere]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 04/05/2016
-- Description:	Get Vendor Slider Data base on SliderId or all Slider list
-- =============================================
CREATE PROCEDURE [dbo].[sp_VendorSlider_SelectWhere]
	-- Add the parameters for the stored procedure here
	@pRefVendorId int,
	@pSearch nvarchar(max) = null,
	@pPageSize int,
	@pPageIndex int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @pdefStr nvarchar(max)=  '';
	if(@pSearch Is Not NULL)
	Begin
		Set @pdefStr  = ' and (R.SliderTitle Like ''%'+ @pSearch +'%''
			or R.SliderUrl Like ''%'+ @pSearch +'%''
			or R.DisplayPage Like ''%'+ @pSearch +'%''
			or R.Category Like ''%'+ @pSearch +'%'') ' 
	End

    -- Insert statements for procedure here
	--Select a.SliderId, 
	--	a.RefVendorId , (Select b.VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName, 
	--	a.SliderTitle, a.SliderImg, 
	--	a.SliderUrl,a.Ord, a.DisplayPage, 
	--	a.Category,a.StartDate, a.EndDate,
	--	a.InsUser, a.InsDate, a.InsTerminal, 
	--	a.UpdUser, a.UpdDate, a.UpdTerminal
	--From VendorSlider a

	Declare @Sql nvarchar(max) = ''

	Set @Sql = 'Select * from (
	Select a.SliderId, 
		a.RefVendorId , (Select b.VendorName From Vendor b Where b.VendorId = a.RefVendorId) VendorName, 
		a.SliderTitle, a.SliderImg, 
		a.SliderUrl,a.Ord, a.DisplayPage, 
		a.Category,a.StartDate, a.EndDate,
		a.InsUser, a.InsDate, a.InsTerminal, 
		a.UpdUser, a.UpdDate, a.UpdTerminal
	From VendorSlider a) R
	Where 1=1 and R.RefVendorId = ' + Cast(@pRefVendorId as varchar) + @pdefStr + '
	Order By R.StartDate Desc,R.Ord
	OFFSET ' + Cast(@pPageSize * @pPageIndex as varchar) + ' ROWS 
	FETCH NEXT '+ Cast(@pPageSize as varchar)+' ROWS ONLY OPTION (RECOMPILE)'

	exec sp_executesql @Sql
END

GO
/****** Object:  StoredProcedure [dbo].[sp_VendorSubDet_SelectWhere]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 13/07/2016
-- Description:	Sleect Vendor Sub Detail 
-- =============================================
CREATE PROCEDURE [dbo].[sp_VendorSubDet_SelectWhere]
	-- Add the parameters for the stored procedure here
	@pdefstr nvarchar(max) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--Select a.VendorSubId, a.RefSubId, a.RefVendorId, a.ValidFromDate, a.ValidTodate, b.UserName,b.VendorName,
	--	c.NoOfAppUser,c.NoOfDays,c.NoOfProducts,c.NoOfSlider,c.SubType,
	--	a.InsUser, a.InsDate, a.InsTerminal ,a.UpdUser, a.UpdDate, a.UpdTerminal
	--From VendorSubDet a
	--Left join Vendor b
	--On a.RefVendorId = b.VendorId
	--Left Join Subscription c
	--On a.RefSubId = c.SubId
	--Order by a.ValidTodate Desc

	Declare @Sql nvarchar(max) = '';

	Set @Sql = 'Select * From 
	(Select a.VendorSubId, a.RefSubId, a.RefVendorId, a.ValidFromDate, a.ValidTodate, b.UserName,b.VendorName,
		c.NoOfAppUser,c.NoOfDays,c.NoOfProducts,c.NoOfSlider,c.SubType,
		a.InsUser, a.InsDate, a.InsTerminal ,a.UpdUser, a.UpdDate, a.UpdTerminal
	From VendorSubDet a
	Left join Vendor b
	On a.RefVendorId = b.VendorId
	Left Join Subscription c
	On a.RefSubId = c.SubId	) x
	Where 1=1 ' +
	@pdefstr

	exec sp_executesql @Sql
	
END

GO
/****** Object:  StoredProcedure [dbo].[sp_WishList_Save]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft	
-- Create date: 14/05/2016
-- Description:	Save Wish list 
-- =============================================
CREATE PROCEDURE [dbo].[sp_WishList_Save]
	-- Add the parameters for the stored procedure here
	@pRefAUId int,
	@pRefVendorId int,
	@pRefProdId int,
	@pWishValue bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if(@pWishValue = 1)
	Begin
		if(Not Exists (Select * From WishList Where RefAUId = @pRefAUId and RefVendorId = @pRefVendorId and RefProdId = @pRefProdId))
		Begin
		
			Insert Into WishList (RefAUId, RefVendorId , RefProdId, WishValue, InsDate)
			Values (@pRefAUId, @pRefVendorId , @pRefProdId, @pWishValue, GETDATE())
		End
		Select 'Product added in wishlist!' Result
	End
	Else
	Begin
		Delete From WishList 
		Where RefAUId = @pRefAUId 
		and RefVendorId = @pRefVendorId 
		and RefProdId = @pRefProdId
		Select 'Product removed from wishlist!' Result
	End

END

GO
/****** Object:  StoredProcedure [dbo].[sp_WishList_Select]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft	
-- Create date: 18/05/2016
-- Description:	Get Wish list Base on AppUser
-- =============================================
CREATE PROCEDURE [dbo].[sp_WishList_Select]
	-- Add the parameters for the stored procedure here
	@pRefAUId int,
	@pRefVendorId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @MainPath nvarchar(50)
	Select top 1 @MainPath = FolderPath From CompanyProfile 

    -- Insert statements for procedure here
	Select a.Id, a.RefAUId, a.RefVendorId,
		a.RefProdId,IsNULL(b.ProdName,'') ProdName, b.ProdCode, 
		--b.ProdDescription, 
		--(Select top 1 d.ImgName from ProductImgDet d Where d.RefProdId = a.RefProdId Order By d.Ord) ProdImgPath,
		(@MainPath + Cast(a.RefVendorId as nvarchar) + '/Products/Thumbnail/' + 
		(Select top 1 d.ImgName from ProductImgDet d Where d.RefProdId = a.RefProdId Order By d.Ord)) ThumbnailImgPath,
		b.RetailPrice, b.RefBrand, b.RefColor, b.RefDesign, b.RefFabric, b.RefProdCategory,
		b.RefProdType, b.RefSize, (Select c.CatCode From CatalogMas c Where c.CatId = b.RefCatId) CatCode
	From WishList a
	Inner Join ProductMas b
	On a.RefProdId = b.ProdId
	Where a.RefAUId = @pRefAUId
	and a.RefVendorId = @pRefVendorId 

END

GO
/****** Object:  StoredProcedure [dbo].[sp_WriteToUs_Save]    Script Date: 11-11-2016 11:14:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JayamSoft
-- Create date: 03/05/2016
-- Description:	Save FeedBak of User
-- =============================================
CREATE PROCEDURE [dbo].[sp_WriteToUs_Save]
	-- Add the parameters for the stored procedure here
	@pRefAUId int,
	@pRemark nvarchar(max),
	@pUser int,
	@pTerminal nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @pResult int = 0;

    -- Insert statements for procedure here
	INsert Into WriteToUs (RefAUId, Remark, InsUser, InsDate,InsTerminal)
	Values (@pRefAUId, @pRemark, @pUser, GetDate(),@pTerminal)

	Select @pResult  = @@IDENTITY;
	Select  @pResult Result;
END

GO
USE [master]
GO
ALTER DATABASE [FHubDB] SET  READ_WRITE 
GO
