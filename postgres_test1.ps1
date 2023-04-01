# Define a ODBC DSN connection string.
$ConnectionString = 'DSN=PostgreSQL35W'
 
# Define a MySQL Command Object for a non-query.
$Connection = New-Object System.Data.Odbc.OdbcConnection;
$Connection.ConnectionString = $ConnectionString
 
# Attempt connection.
try {
  $Connection.Open()
 
  # Create a SQL command.
  $Command = $Connection.CreateCommand();
  $Command.CommandText = "SELECT current_database();";
 
  # Attempt to read SQL command.
  try {
    $Reader = $Command.ExecuteReader();
 
    # Read while records are found.
    while ($Reader.Read()) {
      Write-Host "Current Database [" $Reader[0] "]"}
 
  } catch {
    Write-Error "Message: $($_.Exception.Message)"
    Write-Error "StackTrace: $($_.Exception.StackTrace)"
    Write-Error "LoaderExceptions: $($_.Exception.LoaderExceptions)"
  } finally {
    # Close the reader.
    $Reader.Close() }
 
} catch {
  Write-Error "Message: $($_.Exception.Message)"
  Write-Error "StackTrace: $($_.Exception.StackTrace)"
  Write-Error "LoaderExceptions: $($_.Exception.LoaderExceptions)"
} finally {
  $Connection.Close() }
