# tdx-postgres-to-csv.ps1 
# tdx job - postgres to csv  (at localhost:staffdb)
# pulls staff from people table and writes out csv for tdx people import tool
# 2023-March SW
#

# Define a ODBC DSN connection string for localhost DSN entry
$ConnectionString = 'DSN=PostgreSQL35W'

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
# $filepath = "C:\Users\scott.williamson\Repos\Projects\TDX Utilities\People Import Untility\Pending\PeopleImport_"
# $filepath = $filepath + (Get-Date -format "yyyyMMddhhmm") + ".csv"
# If (Test-Path $filepath) 
#     {
#         Remove-Item $filepath
#     } 
# New-Item $filepath




# Get list from people table
$query = "SELECT * FROM people WHERE tdx_post_date is null OR ad_changed = 'Y';"
$result = Get-ODBC-Data -query $query

# Loop and write out csv records
ForEach($user in $result){
    Write-Host($user.SamAccountName)
}
