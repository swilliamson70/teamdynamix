# TDX People Import
# 2023-08-23sw Added crosswalks for Acct/Dept and Location,
#              Added email replacement for legacy user accounts (133 non-IT users)

Import-Module ActiveDirectory

$date = Get-Date 
$groups = $Null
$users = $Null
$xwalk_dept = ""
$ad_dept = ""
$xwalk_loc = ""
$ad_loc = ""
$dq = [char]34
$temp_email = ""
$legacy_email = ""

# $filepath = $env:USERPROFILE + "\Desktop\PeopleImport.csv"
$filepath = $env:USERPROFILE + "\Repos\Projects\TDX Utilities\People Import Untility\Pending\PeopleImport_"
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
#exclude admins
#  -and $admins -Notcontains SamAccountName `
$admins ="scott.williamson","rcowan","laura.sheppard","cwillia","jwebb"
$users = Get-ADUser -SearchBase "OU=Staff Members OU,DC=central,DC=local" `
    -Filter {Enabled -eq 'True' -and ObjectClass -eq 'user' -and Title -like "*" -and SAMAccountName -ne 'casemanager'} `
    -Properties Title, physicalDeliveryOfficeName, Department, employeeNumber, telephoneNumber, StreetAddress, City, State, PostalCode, Country, Manager, mail
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
        
    Write-Host("user: " + $user.SamAccountName) 
    #Department crosswalk - take AD Department and translate to TDX Values
    $xwalk_dept = ""
    if (!$user.Department)
        {
            $ad_dept = "Not Present"
            #write-host("****Null dept")
        } else {
            $ad_dept = $user.Department.Trim()  
        }
    #write-host($user.Department + " :dept - ad_dept: " + $ad_dept)

    $ad_dept = $ad_dept.replace('  ' , ' ')
    #write-host($ad_dept + " :ad_dept - loc: " + $user.physicalDeliveryOfficeName)
    switch ($ad_dept) {
        "AARC" {$xwalk_dept = "Rudisill Regional"}
        "Bixby Library" {$xwalk_dept = "Bixby"}
        "Broken Arrow Library" {$xwalk_dept = "Broken Arrow"}
        "Brookside Library" {$xwalk_dept = "Brookside"}
        "Business Office" {$xwalk_dept = "Finance Department"}
        "Central Adult Services" {$xwalk_dept = "Adult Services"}
        "Central Circulation" {$xwalk_dept = "Circulation"}
        "Central Library" {$xwalk_dept = "Central"}
        "Charles Page Library" {$xwalk_dept = "Charles Page"}
        "Childrens'" {$xwalk_dept = "Children's Department"}
        "Children's" {$xwalk_dept = "Children's Department"}
        "Children's Services" {$xwalk_dept = "Children's Department"}
        "Collinsville Library" {$xwalk_dept = "Collinsville"}
        "Collinsville  Library" {$xwalk_dept = "Collinsville"}
        "Coverage" {$xwalk_dept = "Floaters"}
        "Customer Care Department" {$xwalk_dept = "Customer Care"}
        "Events" {$xwalk_dept = "Events and Venues Department"}
        "Executive Offices" {$xwalk_dept = "Executive Office"}
        "Facilities" {$xwalk_dept = "Facilities & Engineering"}
        "Finance & Operations" {$xwalk_dept = "Finance Department"}
        "Floater" {$xwalk_dept = "Floaters"}
        "Genealogy Center" {$xwalk_dept = "Genealogy"}
        "Glenpool Library" {$xwalk_dept = "Glenpool"}
        "Hardesty Childrens" {$xwalk_dept = "Hardesty Regional"}
        "Hardesty Regional Library" {$xwalk_dept = "Hardesty Regional"}
        "Harry Pratt Library" {$xwalk_dept = "Pratt"}
        "Herman & Kate Kaiser" {$xwalk_dept = "Herman and Kate Kaiser"}
        "Herman & Kate Kaiser Library" {$xwalk_dept = "Herman and Kate Kaiser"}
        "Hispanic Resource Coordinator" {$xwalk_dept = "Martin Regional"}
        "Jenks Library" {$xwalk_dept = "Jenks"}
        "Judy Z. Kishner Library" {$xwalk_dept = "Judy Z Kishner"}
        "Kendall Whittier Library" {$xwalk_dept = "Kendall Whittier"}
        "Kendall-Whittier Library" {$xwalk_dept = "Kendall Whittier"}
        "Literacy" {$xwalk_dept = "Literacy Services"}
        "Literacy Office" {$xwalk_dept = "Literacy Services"}
        "Literacy Outreach & Volunteer Services" {$xwalk_dept = "Literacy Services"}
        "LOVS" {$xwalk_dept = "Literacy Services"}
        "Martin Regional Library" {$xwalk_dept = "Martin Regional"}
        "Martin Regional  Library" {$xwalk_dept = "Martin Regional"}
        "Maxwell Park Library" {$xwalk_dept = "Maxwell Park"}
        "Nahan Hale Library" {$xwalk_dept = "Nathan Hale"}
        "Nathan Hale Library" {$xwalk_dept = "Nathan Hale"}
        "North Region" {$xwalk_dept = "Rudisill Regional"}
        "Outreach" {$xwalk_dept = "Outreach Services & Bookmobile"}
        "Outreach Services" {$xwalk_dept = "Outreach Services & Bookmobile"}
        "Owasso Library" {$xwalk_dept = "Owasso"}
        "Peggy Helmerich Library" {$xwalk_dept = "Peggy Helmerich"}
        "Physical Processing" {$xwalk_dept = "Collection Management"}
        "Pratt Library" {$xwalk_dept = "Pratt"}
        "Public Relations" {$xwalk_dept = "Public Relations Office"}
        "Public Services" 
            {if ($user.physicalDeliveryOfficeName -eq "Collinsville Library") 
                {$xwalk_dept = "Collinsville"} 
            elseif ($user.physicalDeliveryOfficeName -eq "Schusterman-Benson Library")
                {$xwalk_dept = "Schusterman-Benson"}
            }
        "Reference" 
            {if ($user.physicalDeliveryOfficeName -eq "Hardesty Regional Library")
                {$xwalk_dept = "Hardesty Regional"}
            elseif ($user.physicalDeliveryOfficeName -eq "Rudisill Regional Library")
                {$xwalk_dept = "Rudisill Regional"}
            }
        "Research" {$xwalk_dept = "Central Research Center"}
        "Research Center" {$xwalk_dept = "Central Research Center"}
        "Research Services" {$xwalk_dept = "Central Research Center"}
        "Rudisill Regional Library" {$xwalk_dept = "Rudisill Regional"}
        "Schusterman-Benson Library" {$xwalk_dept = "Schusterman-Benson"}
        "SE Region" {$xwalk_dept = "Martin Regional"}
        "Skiatook Library" {$xwalk_dept = "Skiatook"}
        "South B.A. Library" {$xwalk_dept = "South Broken Arrow"}
        "South Broken Arrow Library" {$xwalk_dept = "South Broken Arrow"}
        "Subs" {if ($user.physicalDeliveryOfficeName -eq "Zarrow Regional Library") {$xwalk_dept = "Zarrow Regional"}}
        "Suburban Acres Library" {$xwalk_dept = "Suburban Acres"}
        "Support Services Center" {$xwalk_dept = "Collection Management"}
        "Technical Services" {$xwalk_dept = "Collection Management"}
        "Trust" {$xwalk_dept = "Tulsa Library Trust"}
        "Volunteers" {$xwalk_dept = "Volunteer Office"}
        "Youth Services" {$xwalk_dept = "Youth Services Department"}
        "Zarrow Regional Library" {$xwalk_dept = "Zarrow Regional"}

        "Adult Services" {$xwalk_dept = $ad_dept}
        "Bixby" {$xwalk_dept = $ad_dept}
        "Bookmobile" {$xwalk_dept = $ad_dept}
        "Broken Arrow" {$xwalk_dept = $ad_dept}
        "Brookside" {$xwalk_dept = $ad_dept}
        "Central" {$xwalk_dept = $ad_dept}
        "Central Research Center" {$xwalk_dept = $ad_dept}
        "Charles Page" {$xwalk_dept = $ad_dept}
        "Children's Department" {$xwalk_dept = $ad_dept}
        "Circulation" {$xwalk_dept = $ad_dept}
        "Collection Management" {$xwalk_dept = $ad_dept}
        "Collinsville" {$xwalk_dept = $ad_dept}
        "Customer Care" {$xwalk_dept = $ad_dept}
        "ECM" {$xwalk_dept = $ad_dept}
        "Events and Venues Department" {$xwalk_dept = $ad_dept}
        "Executive Office" {$xwalk_dept = $ad_dept}
        "Facilities & Engineering" {$xwalk_dept = $ad_dept}
        "Finance Department" {$xwalk_dept = $ad_dept}
        "Floaters" {$xwalk_dept = $ad_dept}
        "Friends of the Tulsa City-County Library" {$xwalk_dept = $ad_dept}
        "Genealogy" {$xwalk_dept = $ad_dept}
        "Glenpool" {$xwalk_dept = $ad_dept}
        "Hardesty Regional" {$xwalk_dept = $ad_dept}
        "Herman and Kate Kaiser" {$xwalk_dept = $ad_dept}
        "Human Resources" {$xwalk_dept = $ad_dept}
        "Information Technology" {$xwalk_dept = $ad_dept}
        "Jenks" {$xwalk_dept = $ad_dept}
        "Judy Z Kishner" {$xwalk_dept = $ad_dept}
        "Kendall Whittier" {$xwalk_dept = $ad_dept}
        "Literacy Services" {$xwalk_dept = $ad_dept}
        "Martin Regional" {$xwalk_dept = $ad_dept}
        "Maxwell Park" {$xwalk_dept = $ad_dept}
        "Nathan Hale" {$xwalk_dept = $ad_dept}
        "Outreach Services & Bookmobile" {$xwalk_dept = $ad_dept}
        "Owasso" {$xwalk_dept = $ad_dept}
        "Peggy Helmerich" {$xwalk_dept = $ad_dept}
        "Pratt" {$xwalk_dept = $ad_dept}
        "Public Relations Office" {$xwalk_dept = $ad_dept}
        "Rudisill Regional" {$xwalk_dept = $ad_dept}
        "Schusterman-Benson" {$xwalk_dept = $ad_dept}
        "Security" {$xwalk_dept = $ad_dept}
        "Skiatook" {$xwalk_dept = $ad_dept}
        "South Broken Arrow" {$xwalk_dept = $ad_dept}
        "Suburban Acres" {$xwalk_dept = $ad_dept}
        "Tulsa Library Trust" {$xwalk_dept = $ad_dept}
        "Volunteer Office" {$xwalk_dept = $ad_dept}
        "Youth Services Department" {$xwalk_dept = $ad_dept}
        "Zarrow Regional" {$xwalk_dept = $ad_dept}
        
        "Not Present" {$xwalk_dept = $ad_dept}
        Default {$xwalk_dept = "No Match"}
    }
    #write-host($xwalk_dept)

    #Location crosswalk
    $ad_loc = $user.physicalDeliveryOfficeName.Trim()
    $ad_loc = $ad_loc.replace("  ", " ")
    switch ($ad_loc) {
        "Bixby Library" {$xwalk_loc = "Bixby (BX)"}
        "Broken Arrow Library" {$xwalk_loc = "Broken Arrow (BA)"}
        "Brookside Library" {$xwalk_loc = "Brookside (BR)"}
        "Central Library" {$xwalk_loc = "Central (CE)"}
        "Charles Page Library" {$xwalk_loc = "Charles Page (CP)"}
        "Collinsville Library" {$xwalk_loc = "Collinsville (CV)"}
        "Glenpool Library" {$xwalk_loc = "Glenpool (GP)"}
        "Hardesty Regional Library" {$xwalk_loc = "Hardesty Regional (HRL)"}
        "Harry Pratt Library" {$xwalk_loc = "Pratt (PR)"}
        "Herman & Kate Kaiser" {$xwalk_loc = "Herman and Kate Kaiser (HKK)"}
        "Herman & Kate Kaiser Library" {$xwalk_loc = "Herman and Kate Kaiser (HKK)"}
        "Jenks Library" {$xwalk_loc = "Jenks (JK)"}
        "Judy Z. Kishner Library" {$xwalk_loc = "Judy Z Kishner (KI)"}
        "Kendall Whittier Library" {$xwalk_loc = "Kendall-Whittier (KW)"}
        "Kendall-Whittier Library" {$xwalk_loc = "Kendall-Whittier (KW)"}
        "Literacy Outreach & Volunteer Services" {$xwalk_loc = $dq + "Literacy, Outreach, and Volunteer Service (LOVS)" + $dq}
        "Martin Regional Library" {$xwalk_loc = "Martin Regional (MRL)"}
        "Maxwell Park Library" {$xwalk_loc = "Maxwell Park (MX)"}
        "Nathan Hale Library" {$xwalk_loc = "Nathan Hale (NA)"}
        "Outreach Services" {$xwalk_loc = $dq + "Literacy, Outreach, and Volunteer Service (LOVS)" +$dq }
        "Owasso Library" {$xwalk_loc = "Owasso (OW)"}
        "Peggy Helmerich Library" {$xwalk_loc = "Peggy Helmerich (PH)"}
        "Pratt Library" {$xwalk_loc = "Pratt (PR)"}
        "Rudisill Regional Library" {$xwalk_loc = "Rudisill Regional (RRL)"}
        "Schusterman-Benson Library" {$xwalk_loc = "Schusterman-Benson (SC)"}
        "Service Center" {$xwalk_loc = "Support Services Center"}
        "Services Support Center" {$xwalk_loc = "Support Services Center"}
        "Skiatook Library" {$xwalk_loc = "Skiatook (SK)"}
        "South B.A. Library" {$xwalk_loc = "South Broken Arrow (SB)"}
        "South Broken Arrow Library" {$xwalk_loc = "South Broken Arrow (SB)"}
        "Suburban Acres Library" {$xwalk_loc = "Suburban Acres (SA)"}
        "Support Services Center" {$xwalk_loc = "Support Services Center"}
        "Zarrow Regional Library" {$xwalk_loc = "Zarrow Regional (ZRL)"}

        "Aaronson Auditorium" {$xwalk_loc = $ad_loc}
        "Bixby (BX)" {$xwalk_loc = $ad_loc}
        "Bookmobile" {$xwalk_loc = $ad_loc}
        "Broken Arrow (BA)" {$xwalk_loc = $ad_loc}
        "Brookside (BR)" {$xwalk_loc = $ad_loc}
        "Central (CE)" {$xwalk_loc = $ad_loc}
        "Central Adult Services" {$xwalk_loc = $ad_loc}
        "Central Audio Lab" {$xwalk_loc = $ad_loc}
        "Central Children's Department" {$xwalk_loc = $ad_loc}
        "Central Maker Space" {$xwalk_loc = $ad_loc}
        "Charles Page (CP)" {$xwalk_loc = $ad_loc}
        "Circulation" {$xwalk_loc = $ad_loc}
        "Collection Management" {$xwalk_loc = $ad_loc}
        "Collinsville (CV)" {$xwalk_loc = $ad_loc}
        "Customer Care" {$xwalk_loc = $ad_loc}
        "Executive Offices" {$xwalk_loc = $ad_loc}
        "Facilities - Central Library" {$xwalk_loc = $ad_loc}
        "Finance Department" {$xwalk_loc = $ad_loc}
        "Glenpool (GP)" {$xwalk_loc = $ad_loc}
        "Hardesty Regional (HRL)" {$xwalk_loc = $ad_loc}
        "Herman and Kate Kaiser (HKK)" {$xwalk_loc = $ad_loc}
        "Human Resources (HR)" {$xwalk_loc = $ad_loc}
        "Information Technology (IT)" {$xwalk_loc = $ad_loc}
        "Jenks (JK)" {$xwalk_loc = $ad_loc}
        "Judy Z Kishner (KI)" {$xwalk_loc = $ad_loc}
        "Kendall-Whittier (KW)" {$xwalk_loc = $ad_loc}
        "Literacy, Outreach, and Volunteer Service (LOVS)" {$xwalk_loc = $ad_loc}
        "Martin Regional (MRL)" {$xwalk_loc = $ad_loc}
        "Maxwell Park (MX)" {$xwalk_loc = $ad_loc}
        "Nathan Hale (NA)" {$xwalk_loc = $ad_loc}
        "Owasso (OW)" {$xwalk_loc = $ad_loc}
        "Peggy Helmerich (PH)" {$xwalk_loc = $ad_loc}
        "Pocahontas Greadington" {$xwalk_loc = $ad_loc}
        "Pratt (PR)" {$xwalk_loc = $ad_loc}
        "Public Relations Office (PRO)" {$xwalk_loc = $ad_loc}
        "Research Center" {$xwalk_loc = $ad_loc}
        "Rudisill Regional (RRL)" {$xwalk_loc = $ad_loc}
        "Schusterman-Benson (SC)" {$xwalk_loc = $ad_loc}
        "Security" {$xwalk_loc = $ad_loc}
        "Skiatook (SK)" {$xwalk_loc = $ad_loc}
        "South Broken Arrow (SB)" {$xwalk_loc = $ad_loc}
        "Suburban Acres (SA)" {$xwalk_loc = $ad_loc}
        "Support Services Center" {$xwalk_loc = $ad_loc}
        "Tandy Garden" {$xwalk_loc = $ad_loc}
        "Tulsa Library Trust" {$xwalk_loc = $ad_loc}
        "Youth Services" {$xwalk_loc = $ad_loc}
        "Zarrow Regional (ZRL)" {$xwalk_loc = $ad_loc}

        Default {$xwalk_loc = "No Match"}
    }

    $legacy_email = ""
    if ($null -eq $user.mail) {
        $user.mail = ""
    }
    $temp_email = $user.SamAccountName.replace('.','')
    #write-host("sam - legacy: " + [string]$user.SamAccountName.Length + " " + [string]$temp_email.Length )
    if ( $user.SamAccountName.Length -eq $temp_email.Length )
        {
            $legacy_email = $user.SamAccountName.ToLower() + "@tulsalibrary.org"
            $user.mail = ""
            #write-host($legacy_email)
        }

    $userRecord =
         
        #User Type *
        $userType + "," +

        #Username *
        #$user.UserPrincipalName.ToLower() + "," + 
        $user.SamAccountName.ToLower() + "@tulsalibrary.org," +

        #Password
        #$user.mail.ToLower() +
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
        #$user.physicalDeliveryOfficeName + "," +
        $xwalk_loc + "," +

        #Acct/Dept ** - crosswalk
        #$user.Department + "," +
        $xwalk_dept + "," +

        #Organizational ID **
        $user.employeeNumber + "," +

        #Alternate ID
        "," +

        #Is Employee **
        "True," +
        
        #Primary Email *
        #$user.UserPrincipalName.ToLower() + "," +
        $legacy_email.ToLower() +
        $user.mail.ToLower() + "," + 

        #Alert Email *
        #$user.UserPrincipalName.ToLower() + "," +
        $legacy_email.ToLower() + 
        $user.mail.ToLower() + "," +

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
    #write-host($userRecord)
    Add-Content -Path $filepath -Value $userRecord

} #end for each $user

