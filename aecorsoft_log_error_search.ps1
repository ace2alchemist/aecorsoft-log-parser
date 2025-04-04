# location the log files
$dir = 'C:\ProgramData\AecorsoftDataIntegrator\logs\'
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
