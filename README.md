# Aecorsoft Log Parser Using PowerShell Script

# Notes : 

Aecorsoft Data Integrator is a ELT/ETL tool which extracts SAP data and can load them to Azure Data Lake (ADLS) or other sinks. In our project landscape Aecorsoft extracts the data and loads in the ADLS and then from the ADLS, Agile Data Engine (ADE) and Data build Tool (dbt) transforms the data and loads into Snowflake. So as to build a End to End a monitoring solution I wanted to check the Aecorsoft’s daily log for any error and its corresponding error job and store it in the Azure Log Analytics Workspace for a monitoring dashboard solution.

# PowerShell Code : 

```
# location the log files
$dir = 'C:\ProgramData\AecorsoftDataIntegrator\logs\
$startTime = get-date
# get the latest file
$fileList = (Get-ChildItem -Path $dir -Filter '2022*.log' | Sort-Object LastWriteTime -Descending | Select-Object -First 1).fullname
# get the latest file details if the file has any 'error' pattern
#$fileDetails = Select-String  -LiteralPath $fileList -Pattern 'error' -Context 0,14 | Select-Object -First 1 | Select-Object Path, FileName, Pattern, Linenumber
# display the first object in the array
#$fileDetails[0]
#$logLines=  Get-Content $fileList-split '\r?\n'
if ($fileList) {
	# get the lines from the file which has the pattern error
	$message =  Get-Content $fileList | Where-Object {$_ -like ‘*error*’}
	$search = (Get-Content $fileList | Select-String -Pattern 'error').Matches.Success
    if($search){
	# loop through the 'error' lines in the logfile and extract the jobName & timestamp
		$message | ForEach-Object {
		# ... by matching it ($_) against a regex with capture groups - (...) - using the -match operator.
		if ($_ -match '\| (\d{4}-.+?) - \[.+? Name:(\w+)') {
			# The line matched.
			# Capture groups 1 and 2 in the automatic $Matches variable contain
			# Retrieve the tokens of interest and assign them to variables.
			$timestamp = $Matches.1
			$jobName = $Matches.2

			"Error Found for Aecorsoft Job: $jobName occured at $timestamp and absolute path for the current logfile: $fileList"
			}
		}
	}else {
			"No Error Found for any Aecorsoft Job today and absolute path for the current logfile: $fileList"
    }
}else {
			"No Aecorsoft Logs Files Found Today in $dir at $StartTime"
}

```
# Screens :

![image](https://github.com/user-attachments/assets/a1f25c97-1725-4909-9bf7-5e9b63232fb6)


Run the script anywhere from the VM by pointing to the Aecorsoft tool log location (generally available at : C:\ProgramData\AecorsoftDataIntegrator\logs\ )

![image](https://github.com/user-attachments/assets/25064c5c-6fdc-44a4-b12c-e0a8d56e3ad7)


Shows multiple instance of the job failure (if any)



