# tdx-ad-to-postgress.ps1
# tdx job - AD to postgres localhost:staffdb
# pulls staff from ad to store in the people table
# 2023-March SW 
# note that group membership for Managers, HR, Events, etc. need to be dealth with

Import-Module ActiveDirectory

# Define a ODBC DSN connection string for localhost DSN entry
# https://www.andersrodland.com/working-with-odbc-connections-in-powershell/
$ConnectionString = 'DSN=PostgreSQL35W'
#$Connection = New-Object System.Data.Odbc.OdbcConnection;
#$Connection.ConnectionString = $ConnectionString

function Get-ODBC-Data{
    param([string]$query=$(throw 'query is required.'))
    #$conn = New-Object System.Data.Odbc.OdbcConnection
    #$conn.ConnectionString = "Driver={PostgreSQL Unicode(x64)};Server=SOMENAME;Port=5432;Database=DBNAME;Uid=SOMEUSER;Pwd=SOMEPASS;"
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
   #$conn = New-Object System.Data.Odbc.OdbcConnection
   #$conn.ConnectionString= "Driver={PostgreSQL Unicode(x64)};Server=SOMENAME;Port=5432;Database=DBNAME;Uid=SOMEUSER;Pwd=SOMEPASS;"
   $conn = New-Object System.Data.Odbc.OdbcConnection;
   $conn.ConnectionString = $ConnectionString
   $cmd = new-object System.Data.Odbc.OdbcCommand($query,$conn)
   $conn.open()
   $cmd.ExecuteNonQuery()
   $conn.close()
 }

$date = Get-Date 
#$groups = $Null
$users = $Null

# get user info from Staff Members OU
$users = Get-ADUser -SearchBase "OU=Staff Members OU,DC=central,DC=local" `
    -Filter {Enabled -eq 'True' -and ObjectClass -eq 'user' -and Title -like "*" -and SAMAccountName -ne 'casemanager' -and SAMAccountName -ne 'fp.coord'} `
    -Properties Title, physicalDeliveryOfficeName, Department, employeeNumber, telephoneNumber, StreetAddress, City, State, PostalCode, Country, Manager

# get list of members for groups - these will get technician licenses
$itmembers = Get-ADGroupMember -Identity "Information Technology Group" | Select -ExpandProperty Name
$promembers = Get-ADGroupMember -Identity "Public Relations Group" | Select -ExpandProperty Name
$facmembers = Get-ADGroupMember -Identity "Facilities Group" | Select -ExpandProperty Name

ForEach($user in $users)
{
    If ( ($itmembers -contains $user.Name) -or ($promembers -contains $user.Name) -or ($facmembers -contains $user.name)) {
        If ($itmembers -contains $user.Name) {
            $technician_group = "IT"
        }
        if ($promembers -contains $user.Name) {
            $technician_group = "PRO"
        }
        if ($facmembers -contains $user.Name) {
            $technician_group = "Fac"
        }    
    } Else {
        $technician_group = ""
    }

    #get manager - this was a pain
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

    #get people record, if different from db rec insert ad into staffdb/people table
    $query = "SELECT * FROM people WHERE samaccountname='" + $user.SamAccountName.ToLower() +"'"
    # Write-Host($query)
    $result = Get-ODBC-Data -query $query
    write-host(" Top user:" + $user.SamAccountName.ToLower() + " result:" + $result.samaccountname)
    write-host( $user.SamAccountName.ToLower() -eq $result.samaccountname)

    if( ($user.SamAccountName.ToLower()  -ne $result.samcccountname) -and
        ($user.UserPrincipalName.ToLower() -ne $result.userPrincipalName) -and
        ($user.GivenName -ne $result.givenName) -and
        ($user.Surname -ne $result.surname) -and
        ($user.Title.Replace("'","") -ne $result.title) -and
        ($user.physicalDeliveryOfficeName -ne $result.physicalDeliveryOfficeName) -and
        ($user.Department -ne $result.Department) -and 
        #skip employee number
        ($user.telephoneNumber -ne $result.telephoneNumber) -and
        ($user.StreetAddress -ne $result.StreetAddress) -and
        ($user.City -ne $result.City) -and
        #skip state
        ($user.PostalCode -ne $result.PostalCode) -and
        #skip country
        ($user.Manager -ne $result.manager) 
        #skip technician_group
        ) {
        Write-Host("no match")
   
        $query = 
        "INSERT INTO people (" +
            "samAccountName," +
            "userPrincipalName," +
            "givenName," +
            "surname," +
            "title," +
            "physicalDeliveryOfficeName," +
            "Department," +
            "employeeNumber," +
            "telephoneNumber," +
            "StreetAddress," +
            "City," +
            "State," +
            "PostalCode," +
            "Country," +
            "Manager," +
            "technician_group," +
            "ad_pull_date," +
            "tdx_post_date," + 
            "ad_changed)"+
        " VALUES "+
            "(" +
            "'" + $user.SamAccountName.ToLower() + "'," +    
            "'" + $user.UserPrincipalName.ToLower() + "'," +
            "'" + $user.GivenName + "'," +
            "E'" + $user.Surname.Replace("'","\'") + "'," +
            "E'" + $user.Title.Replace("'","\'") + "'," +
            "'" + $user.physicalDeliveryOfficeName + "'," +
            "E'" + $user.Department.Replace("'","\'") + "'," +
            "'" + $user.employeeNumber + "'," +
            "'" + $user.telephoneNumber + "'," +
            "'" + $user.StreetAddress + "'," +
            "'" + $user.City + "'," +
            "'" + $user.State + "'," +
            "'" + $user.PostalCode + "'," +
            "'" + $user.Country + "'," +
            "'" + $ManagerUserName.ToLower() + "'," +
            "'" + $technician_group + "'," +
            #"to_date('" + $date.ToString("yyyy/MM/dd") + "','yyyy/MM/dd')," +
            "now()," +
            "NULL," +
            "'Y')"
        
        #try to open connection and write record    
        Write-Host("Insert: " + $query)
        
        set-odbc-data -query $query
        Write-Host("after insert")
    

    } else { 
    Write-Host("match - no insert")}
    
    # if($user.SamAccountName.ToLower() -eq "rebecca.harrison"){
    #     exit
    # }

    Write-Host("bottom")

} #end for each $user

