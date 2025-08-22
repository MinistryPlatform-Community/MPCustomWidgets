DROP PROCEDURE IF EXISTS [dbo].[api_custom_VolunteerTrackerWidget_JSON]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- api_custom_VolunteerTrackerWidget_JSON
-- =============================================
-- Description: Returns the status of requirements for a response to a volunteer opportunity.
--              Created at MP Dev Lab 2025 at Perimeter Church in Atlanta, Georgia.
-- Last Modified: 8/22/2025
-- Stephan Swinford
-- =============================================

CREATE PROCEDURE [dbo].[api_custom_VolunteerTrackerWidget_JSON]
    @DomainID      INT,
    @Username      NVARCHAR(75) = NULL,
    @BGCWebUrl     NVARCHAR(255) = 'https://my.church.org/portal/backgroundcheck.aspx?background=',
    @FormWebUrl    NVARCHAR(255) = 'https://www.mychurch.org/form-widget?id=',
    @ContactGUID   NVARCHAR(75),
    @ResponseID    INT,
    @EnforceVolunteerGroup INT = 0 --Enforce whether associated opportunity group must be a 'volunteer group' or not
AS
BEGIN
    SET NOCOUNT ON;

    SELECT [JsonResult] =
    (
        SELECT
            
            /* 1) Volunteer Information -> object (embedded without escaping) */
            JSON_QUERY(
                COALESCE(
                    (
                        SELECT TOP 1
                            C.Nickname,
                            C.Last_Name,
                            C2.Nickname    AS Opportunity_Contact_Nickname,
                            C2.Last_Name   AS Opportunity_Contact_Last_Name,
                            C2.Email_Address AS Opportunity_Contact_Email,
                            O.Opportunity_Title,
                            R.Response_Date,
                            CASE WHEN R.Closed = 1 AND ISNULL(RR.Response_Result_ID, 2) = 2 THEN 1 ELSE 0 END AS Closed,
                            RR.Response_Result AS [Leader_Review],
                            CASE WHEN @EnforceVolunteerGroup = 0 THEN 1 ELSE GT.Volunteer_Group END AS [Is_Volunteer_Group]
                        FROM Contacts C
                            JOIN Responses      R ON R.Response_ID = @ResponseID
                            JOIN Opportunities  O ON O.Opportunity_ID = R.Opportunity_ID
                            JOIN Contacts      C2 ON C2.Contact_ID = O.Contact_Person
                            LEFT JOIN Groups    G ON G.Group_ID = O.Add_to_Group
                            LEFT JOIN Group_Types   GT ON GT.Group_Type_ID = G.Group_Type_ID
                            LEFT JOIN Response_Results RR ON RR.Response_Result_ID = R.Response_Result_ID
                        WHERE R.Response_ID = @ResponseID
                          AND C.Contact_GUID = @ContactGUID
                        ORDER BY C.Contact_ID DESC
                        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                    ),
                    N'{}'  -- fallback to an empty object if no match
                )
            ) AS volunteer_information,

            /* 2) Background Check Requirements -> array */
            (
                SELECT DISTINCT
                    ISNULL(BCT.Background_Check_Type, 'Basic') AS Background_Check_Type,
                    CASE WHEN EXISTS
                    (
                        SELECT 1
                        FROM Background_Checks BC 
                        WHERE BC.Background_Check_Type_ID = BCT.Background_Check_Type_ID
                          AND BC.Contact_ID = P.Contact_ID
                          AND BC.All_Clear = 1
                          AND BC.Background_Check_Expires > GETDATE()
                    )
                    THEN 'Completed' ELSE 'Needed' END AS Background_Check_Status,
                    CASE WHEN @BGCWebUrl IS NOT NULL THEN
                        (SELECT TOP 1
                            CONCAT(@BGCWebUrl, BC.Background_Check_GUID)
                        FROM Background_Checks BC
                        WHERE BC.Background_Check_Type_ID = BCT.Background_Check_Type_ID
                          AND BC.Contact_ID = P.Contact_ID
                          AND BC.Background_Check_Started >= GetDate()-30
                          AND BC.Background_Check_Submitted IS NULL
                        ORDER BY BC.Background_Check_Started DESC
                    ) ELSE NULL END AS Background_Check_URL
                FROM Participation_Requirements PR
                INNER JOIN Group_Roles GR               ON GR.Group_Role_ID = PR.Group_Role_ID
                INNER JOIN Opportunities O              ON O.Group_Role_ID = GR.Group_Role_ID
                INNER JOIN Responses R                  ON R.Opportunity_ID = O.Opportunity_ID
                INNER JOIN Background_Check_Types BCT   ON BCT.Background_Check_Type_ID = PR.Background_Check_Type_ID
                INNER JOIN Participants P               ON P.Participant_ID = R.Participant_ID
                INNER JOIN Contacts C                   ON C.Contact_ID = P.Contact_ID
                WHERE R.Response_ID = @ResponseID
                AND C.Contact_GUID = @ContactGUID
                FOR JSON PATH
            ) AS background_checks,

            /* 3) Milestone Requirements -> array */
            (
                SELECT DISTINCT
                    M.Milestone_Title,
                    CASE WHEN EXISTS
                    (
                        SELECT 1
                        FROM Participant_Milestones PM 
                        WHERE PM.Milestone_ID  = M.Milestone_ID
                          AND PM.Participant_ID = P.Participant_ID
                          AND (DATEADD(MONTH, ISNULL(M.Expires_in_Months, 0), PM.Date_Accomplished) > GETDATE()
                           OR M.Expires_in_Months IS NULL)
                    )
                    THEN 'Completed' ELSE 'Needed' END AS Milestone_Status
                FROM Participation_Requirements PR
                INNER JOIN Group_Roles GR   ON GR.Group_Role_ID = PR.Group_Role_ID
                INNER JOIN Opportunities O  ON O.Group_Role_ID = GR.Group_Role_ID
                INNER JOIN Responses R      ON R.Opportunity_ID = O.Opportunity_ID
                INNER JOIN Milestones M     ON M.Milestone_ID = PR.Milestone_ID
                INNER JOIN Participants P   ON P.Participant_ID = R.Participant_ID
                INNER JOIN Contacts C       ON C.Contact_ID = P.Contact_ID
                WHERE R.Response_ID = @ResponseID
                AND C.Contact_GUID = @ContactGUID
                FOR JSON PATH
            ) AS milestones,

            /* 4) Certification Requirements -> array */
            (
                SELECT DISTINCT
                    CT.Certification_Type,
                    CASE WHEN EXISTS
                    (
                        SELECT 1
                        FROM Participant_Certifications PC
                        WHERE PC.Certification_Type_ID = CT.Certification_Type_ID
                          AND PC.Participant_ID = P.Participant_ID
                          AND ISNULL(PC.Certification_Expires, GETDATE()) > GETDATE()
                    )
                    THEN 'Completed' ELSE 'Needed' END AS Certification_Status
                FROM Participation_Requirements PR
                INNER JOIN Group_Roles GR         ON GR.Group_Role_ID = PR.Group_Role_ID
                INNER JOIN Opportunities O        ON O.Group_Role_ID = GR.Group_Role_ID
                INNER JOIN Responses R            ON R.Opportunity_ID = O.Opportunity_ID
                INNER JOIN Certification_Types CT ON CT.Certification_Type_ID = PR.Certification_Type_ID
                INNER JOIN Participants P         ON P.Participant_ID = R.Participant_ID
                INNER JOIN Contacts C             ON C.Contact_ID = P.Contact_ID
                WHERE R.Response_ID = @ResponseID
                AND C.Contact_GUID = @ContactGUID
                FOR JSON PATH
            ) AS certifications,

            /* 5) Form Requirements -> array */
            (
                SELECT DISTINCT
                    F.Form_Title,
                    CASE WHEN EXISTS
                    (
                        SELECT 1
                        FROM Form_Responses FR
                        WHERE FR.Form_ID   = F.Form_ID
                          AND FR.Contact_ID = P.Contact_ID
                          AND DATEADD(MONTH, ISNULL(F.Months_Till_Expires, 1), FR.Response_Date) > GETDATE()
                    )
                    THEN 'Completed' ELSE 'Needed' END AS Form_Status,
                    CASE WHEN @FormWebUrl IS NOT NULL THEN CONCAT(@FormWebUrl, F.Form_GUID) ELSE NULL END AS Form_URL
                FROM Participation_Requirements PR
                INNER JOIN Group_Roles GR  ON GR.Group_Role_ID = PR.Group_Role_ID
                INNER JOIN Opportunities O ON O.Group_Role_ID = GR.Group_Role_ID
                INNER JOIN Responses R     ON R.Opportunity_ID = O.Opportunity_ID
                INNER JOIN Forms F         ON F.Form_ID = PR.Custom_Form_ID
                INNER JOIN Participants P  ON P.Participant_ID = R.Participant_ID
                INNER JOIN Contacts C      ON C.Contact_ID = P.Contact_ID
                WHERE R.Response_ID = @ResponseID
                AND C.Contact_GUID = @ContactGUID
                FOR JSON PATH
            ) AS forms

        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    );
END
GO


-- =============================================
-- SP MetaData Install
-- =============================================
DECLARE @spName NVARCHAR(128) = 'api_custom_VolunteerTrackerWidget_JSON'
DECLARE @spDescription NVARCHAR(500) = 'Returns the status of requirements for a response to a volunteer opportunity.'

IF NOT EXISTS (
    SELECT API_Procedure_ID FROM dp_API_Procedures WHERE Procedure_Name = @spName
)
BEGIN
    INSERT INTO dp_API_Procedures (Procedure_Name, Description)
    VALUES (@spName, @spDescription)
END

-- Grant to Administrators Role
DECLARE @AdminRoleID INT = (
    SELECT Role_ID FROM dp_Roles WHERE Role_Name = 'Administrators'
)

IF NOT EXISTS (
    SELECT * 
    FROM dp_Role_API_Procedures RP
    INNER JOIN dp_API_Procedures AP ON AP.API_Procedure_ID = RP.API_Procedure_ID
    WHERE AP.Procedure_Name = @spName AND RP.Role_ID = @AdminRoleID
)
BEGIN
    INSERT INTO dp_Role_API_Procedures (Domain_ID, API_Procedure_ID, Role_ID)
    VALUES (
        1,
        (SELECT API_Procedure_ID FROM dp_API_Procedures WHERE Procedure_Name = @spName),
        @AdminRoleID
    )
END
GO
