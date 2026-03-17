# Stored Procedure Definition

Use this folder to include any SQL scripts designed to install stored procedures required for the Custom Widget to work. Please follow the pattern of including a fully installable script including required MinistryPlatform metadata. Examples are included to aid in quickly developing installable Stored Procedure scripts.

## Installation Notes

All examples in this repository will install the stored procedure, then check API_Procedures for the relevant metadata that defines the stored procedure. Additionally, the install scripts will give the Administrators security role access to the script.

## Standard Parameters

The Custom Widget API will attempt to pass `@UserName` when the website user is logged into widgets. It is highly recommended that you include the `@UserName` parameter in all Custom Widget Stored Procedures. If `@UserName` is not required, you should default this parameter to null. When NOT NULL, the absence of this parameter will cause the stored procedure to fail.

Example:

```sql
@UserName nvarchar(75) = null
```
