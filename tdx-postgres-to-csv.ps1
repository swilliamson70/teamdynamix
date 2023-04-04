# tdx-postgres-to-csv.ps1 
# tdx job - postgres to csv  (at localhost:staffdb)
# pulls staff from people table and writes out csv for tdx people import tool
# 2023-March SW
#  - April 03 sw: added csv headers, body, writes; added tdx field logic based on people.technician_group
#
# need to add location, department crosswalks in tdx-ad-to-postgres - manual correction of csv required until this is complete
#

# Define a ODBC DSN connection string for localhost DSN entry
$ConnectionString = 'DSN=PostgreSQL35W'

# staffdb/people contains:
    # samaccountname
    # userprincipalname
    # givenname
    # surname
    # title
    # physicaldeliveryofficename
    # department
    # employeenumber
    # telephonenumber
    # streetaddress
    # city
    # state
    # postalcode
    # country
    # manager
    # technician_group
    # ad_pull_date
    # tdx_post_date
    # changed_code

function Get-ODBC-Data{
    param([string]$query=$(throw 'query is required.'))
    $conn = New-Object System.Data.Odbc.OdbcConnection;
    $conn.ConnectionString = $ConnectionString
    $conn.open()
    $cmd = New-object System.Data.Odbc.OdbcCommand($query,$conn)
    $kds = New-Object system.Data.DataSet
    (New-Object system.Data.odbc.odbcDataAdapter($cmd)).fill($kds) # | out-null
    $conn.close()
    $kds.Tables[0]
 }
 
 function Set-ODBC-Data{
    param([string]$query=$(throw 'query is required.'))
   $conn = New-Object System.Data.Odbc.OdbcConnection;
   $conn.ConnectionString = $ConnectionString
   $cmd = new-object System.Data.Odbc.OdbcCommand($query,$conn)
   $conn.open()
   $cmd.ExecuteNonQuery()
   $conn.close()
 }

# Open fresh CSV 
# $filepath = $env:USERPROFILE + "\Desktop\PeopleImport.csv"
$filepath = $env:USERPROFILE + "\Repos\Projects\TDX Utilities\People Import Untility\Pending\PeopleImport_"
$filepath = $filepath + (Get-Date -format "yyyyMMddhhmm") + ".csv"

If (Test-Path $filepath) 
    {
        Remove-Item $filepath
    } 
New-Item $filepath

# The TDX People Import Tool doesn't care about spaces in the names. It processes the contents of a folder.
Write-Host('TDX People Import File ' + $date + "`n")  
Set-Content -Path $filepath -value ('TDX People Import File ' + $date + "`n") 

# Write headers to CSV
$lineout = 
    "User Type," +
    "Username," +
    "Password," +
    "Authentication Provider," +
    "Authentication Username," +
    "Security Role," +
    "First Name," +
    "Last Name," +
    "Middle Name," +
    "Nickname," +
    "Salutation," +
    "Organization," +
    "Title," +
    "Location," +
    "Acct/Dept," +
    "Organizational ID," +
    "Alternate ID," +
    "Is Employee," +
    "Primary Email," +
    "Alert Email," +
    "Alternate Email," +
    "Work Phone," +
    "Mobile Phone," +
    "Home Phone," +
    "Pager," +
    "Fax," +
    "Other Phone," +
    "Phone Preference," +
    "Work Address," +
    "Work City," +
    "Work State," +
    "Work Postal Code," +
    "Work Country," +
    "Home Address," +
    "Home City," +
    "Home State," +
    "Home Postal Code," +
    "Home Country," +
    "Time Zone ID," +
    "Capacity Is Managed," +
    "Workable Hours," +
    "Bill Rate," +
    "Cost Rate," +
    "Should Report Time," +
    "Resource Pool," +
    "Reports To Username," +
    "Default TDNext Desktop," +
    "Default TDClient Desktop," +
    "HasTDNext," +
    "HasMyWork," +
    "HasTDAnalysis," +
    "HasTDFileCabinet," +
    "HasTDFinance," +
    "HasTDPortfolios," +
    "HasTDPP," +
    "HasTDProjectRequest," +
    "HasTDProjects," +
    "HasTDResourceManagement," +
    "HasTDTemplate," +
    "HasTDTimeExpense," +
    "HasTDPeople," +
    "HasTDWorkspaces," +
    "TDClient-####," +
    "TDTickets-####"

Add-Content -Path $filepath -Value $lineout

# Get list from people table
$query = "SELECT * FROM people WHERE tdx_post_date is null OR changed_code = 'Y';"
$result = Get-ODBC-Data -query $query

# Loop and write out csv records
# - it doesn't matter if its an update or a new record, csv formatting is the same
ForEach($user in $result){
    Write-Host($user.SamAccountName) 
    If ($user.samaccountname -eq $null) {continue}

    #determine tdx values
    If ($user.technician_group -ne "" ) {
        Write-Host($user.SamAccountName + "Not a tech")
        $userType = "user"
        $usersecurityRole = "Technician"
        $workableHours = "8"
        $shouldReportTime = "False" #we don't track time or effort
        $HasTDNext = "True"
        $HasMyWork = "True"
        $HasTDAnalysis = "True"
        $HasTDFileCabinet = "True"
        $HasTDFinance = "False"
        $HasTDPortfolios = "True"
        $HasTDPP = "True"
        $HasTDProjectRequest = "True"
        $HasTDProjects = "True"
        $HasTDResourceManagement = "True"
        $HasTDTemplate = "True"
        $HasTDTimeExpense = "True"
        $HasTDPeople = "True"
        $HasTDWorkspaces = "True"
    } Else {
        $userType = "user"
        $userSecurityRole = "Staff"
        $workableHours = "" #only used for technicians
        $shouldReportTime = "" #only used for technicians
        $HasTDNext = "" #only used for technicians
        $HasMyWork = "" #only used for technicians
        $HasTDAnalysis = "" #
        $HasTDFileCabinet = "" #only used for projectss
        $HasTDFinance = "" #not used
        $HasTDPortfolios = "" #only used by PMs
        $HasTDPP = "" #only used by PMs
        $HasTDProjectRequest = "" #to be assigned later manually
        $HasTDProjects = "" #to be assigned later manually
        $HasTDResourceManagement = "" #only used for technicians
        $HasTDTemplate = "" #only used for technicians
        $HasTDTimeExpense = "" #only used for technicians
        $HasTDPeople = "" #only used for technicians
        $HasTDWorkspaces = "" #not used
    }

    #create csv row
    $lineout =
        #A: User Type
        $userType + "," + 

        #B: Username
        $user.samAccountName + "@tulsalibrary.org," +

        #C: Password
        "," +  

        #D: Authentication Provider
        "TeamDynamix," +

        #E: Authentication Username
        $user.UserPrincipalName.ToLower() + "," +

        #F: Security Role
        $usersecurityRole + "," +

        #G: First Name
        $user.givenname + "," +
    
        #H: Last Name
        $user.surname + "," +

        #I: Middle Name
        "," +

        #J: Nickname
        "," +

        #K: Salutation
        "," +

        #L: Organization
        "Tulsa City County Library," +

        #M: Title
        "`"" + $user.title + "`"," +
    
        #N: Location
        $user.physicalDeliveryOfficeName + "," +

        #O: Acct/Dept
        $user.Department + "," +

        #P: Organizational ID
        $user.employeeNumber + "," +

        #Q: Alternate ID
        "," +

        #R: Is Employee **
        "True," +
        
        #S: Primary Email *
        $user.UserPrincipalName + "," +

        #T: Alert Email *
        $user.UserPrincipalName + "," +

        #U: Alternate Email
        "," +

        #V: Work Phone
        $user.telephoneNumber + "," +

        #W: Mobile Phone
        "," +

        #X: Home Phone
        "," +

        #Y: Pager
        "," +

        #Z: Fax
        "," +

        #AA: Other Phone
        "," +

        #AB: Phone Preference
        "Work," +

        #AC: Work Address
        "`"" + $user.StreetAddress + "`"," +

        #AD: Work City
        $user.City + "," +
        
        #AE: Work State
        $user.State + "," +

        #AF: Work Postal Code *
        $user.PostalCode + "," +

        #AG: Work Country
        $user.Country + "," +
        
        #AH: Home Address
        "," +

        #AI: Home City
        "," +

        #AJ: Home State
        "," +

        #AK: Home Postal Code
        "," +

        #AL: Home Country
        "," +

        #AM: Time Zone ID *
        "4," +
        
        #AN: Capacity Is Managed
        "False," +
    
        #AO: Workable Hours
        $workableHours + "," +
        
        #AP: Bill Rate
        "," +

        #AQ: Cost Rate
        "," +
        
        #AR: Should Report Time
        $shouldReportTime + "," +

        #AS: Resource Pool
        "," +

        #AT: Reports To Username  **
        $user.manager + "," +

        #AU Default TDNext Desktop
        "Technician Default," +

        #AV: Default TDClient Desktop
        "Client Default," +

        #HasTDNext
        $HasTDNext + "," +

        #HasMyWork
        $HasMyWork + "," +

        #HasTDAnalysis
        $HasTDAnalysis  + "," +

        #HasTDFileCabinet
        $HasTDFileCabinet + "," +

        #HasTDFinance
        $HasTDFinance + "," +

        #HasTDPortfolios
        $HasTDPortfolios + "," +

        #HasTDPP
        $HasTDPP + "," +

        #HasTDProjectRequest
        $HasTDProjectRequest + "," +

        #HasTDProjects
        $HasTDProjects + "," +

        #HasTDResourceManagement
        $HasTDResourceManagement + "," +
        
        #HasTDTemplate
        $HasTDTemplate + "," +
        
        #HasTDTimeExpense
        $HasTDTimeExpense + "," +
        
        #HasTDPeople
        $HasTDPeople + "," +
        
        #HasTDWorkspaces
        $HasTDWorkspaces + "," +
        
        #TDClient-####
        "," +
        
        #TDTickets-####
        ","

        #"**End of record" 
    
    Write-Host($lineout)
    Add-Content -Path $filepath -Value $lineout

}
