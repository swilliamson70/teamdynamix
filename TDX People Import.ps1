Import-Module ActiveDirectory

$date = Get-Date 
$groups = $Null
$users = $Null

# $filepath = $env:USERPROFILE + "\Desktop\PeopleImport.csv"
$filepath = "C:\Users\scott.williamson\Repos\Projects\TDX Utilities\People Import Untility\Pending\PeopleImport_"
$filepath = $filepath + (Get-Date -format "yyyyMMddhhmm") + ".csv"

If (Test-Path $filepath) 
    {
        Remove-Item $filepath
    } 
New-Item $filepath

Write-Host('TDX People Import File ' + $date + "`n")  
Set-Content -Path $filepath -value ('TDX People Import File ' + $date + "`n") 
$headers = 
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

Add-Content -Path $filepath -Value $headers

$users = Get-ADUser -SearchBase "OU=Staff Members OU,DC=central,DC=local" `
    -Filter {Enabled -eq 'True' -and ObjectClass -eq 'user' -and Title -like "*" -and SAMAccountName -ne 'casemanager' } `
    -Properties Title, physicalDeliveryOfficeName, Department, employeeNumber, telephoneNumber, StreetAddress, City, State, PostalCode, Country, Manager
$itmembers = Get-ADGroupMember -Identity "Information Technology Group" | Select -ExpandProperty Name
$promembers = Get-ADGroupMember -Identity "Public Relations Group" | Select -ExpandProperty Name
$facmembers = Get-ADGroupMember -Identity "Facilities Group" | Select -ExpandProperty Name

ForEach($user in $users)
{
    If ( ($itmembers -contains $user.Name) -or ($promembers -contains $user.Name) -or ($facmembers -contains $user.name)) {
        $userType = "user"
        $usersecurityRole = "Technician"
        $workableHours = "8"
        $shouldReportTime = "True"
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
        $userSecurityRole = "Client"
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

    $ManagerUserName = "nothing"

    try{
        $manager = (Get-AdUser -SearchBase "OU=Staff Members OU,DC=central,DC=local" -Filter {DistinguishedName -eq $user.Manager})
    } catch {
        $ManagerUserName = "n/a"
    }
    
    if (!$Manager) { 
        #$ManagerUserName = $manager.SamAccountName
        $ManagerUserName = "Not in Staff Members OU"
        } else {
            $ManagerUserName = $manager.SamAccountName.ToString() + "@tulsalibrary.org"
        }
        
    #Write-Host(
    $userRecord =
         
        #User Type *
        $userType + "," +

        #Username *
        #$user.UserPrincipalName.ToLower() + "," + 
        $user.SamAccountName.ToLower() + "@tulsalibrary.org," +

        #Password
        "," +

        #Authentication Provider *
        "TeamDynamix," +

        #Authentication Username 
        $user.UserPrincipalName.ToLower() + "," +

        #Security Role *
        $userSecurityRole + "," +

        #First Name *
        $user.GivenName + "," +

        #Last Name *
        "`"" +$user.Surname + "`"," +

        #Middle Name
        "," +

        #Nickname
        "," +

        #Salutation
        "," +

        #Organization *
        "Tulsa City County Library," +
        
        #Title
        "`"" + $user.Title + "`"," +

        #Location
        $user.physicalDeliveryOfficeName + "," +

        #Acct/Dept **
        $user.Department + "," +

        #Organizational ID **
        $user.employeeNumber + "," +

        #Alternate ID
        "," +

        #Is Employee **
        "True," +
        
        #Primary Email *
        $user.UserPrincipalName.ToLower() + "," +

        #Alert Email *
        $user.UserPrincipalName.ToLower() + "," +

        #Alternate Email
        "," +

        #Work Phone
        $user.telephoneNumber + "," +

        #Mobile Phone
        "," +

        #Home Phone
        "," +

        #Pager
        "," +

        #Fax
        "," +

        #Other Phone
        "," +

        #Phone Preference
        "Work," +

        #Work Address
        "`"" + $user.StreetAddress + "`"," +

        #Work City
        $user.City + "," +
        
        #Work State
        $user.State + "," +

        #Work Postal Code *
        $user.PostalCode + "," +

        #Work Country
        $user.Country + "," +
        
        #Home Address
        "," +

        #Home City
        "," +

        #Home State
        "," +

        #Home Postal Code
        "," +

        #Home Country
        "," +

        #Time Zone ID *
        "4," +
        
        #Capacity Is Managed
        "False," +

        #Workable Hours
        $workableHours + "," +
        
        #Bill Rate
        "," +

        #Cost Rate
        "," +
        
        #Should Report Time
        $shouldReportTime + "," +

        #Resource Pool
        "," +

        #Reports To Username  **
        $ManagerUserName.ToLower() + "," +

        #Default TDNext Desktop
        "Technician Default," +

        #Default TDClient Desktop
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

#    )
    write-host($userRecord)
    Add-Content -Path $filepath -Value $userRecord

} #end for each $user

