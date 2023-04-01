# teamdynamix
Misc tdx tools

After setting up the bulk of TeamDynamix, I'm spending some quality sparetime hours to creating tools and docs to make my admin life easier
Tools (so far):

November 2023
TDX People Import.ps1        Initial loader - pulls Active Directory information and writes out csv to be fed to TDX's People Import Utility 
                             - needed this to load Sandbox and initial production environments

March 2023
tdx-ad-to-postgres.ps1       under dev/quick and dirty - pieces of above that updates table in postgresql database across an ODBC connection
 - need to finish logic to flag changes in people info
tdx-postgress-to-csv.ps1     under dev/quick and dirty - pieces of above that queries table in postgresql database across an ODBC connection

Hopefully, I'll have time to rewrite these in Python using the ldap3, teamdynamix, etc. libraries - one of these days...