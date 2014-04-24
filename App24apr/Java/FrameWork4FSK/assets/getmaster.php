<?php
	$latestFileName = "kth_message_server/master.ip";
	$latestFileHandle = fopen($latestFileName, 'r') or die("can't open file");
	$latestFileLength = filesize($latestFileName);
	$projectName = $_GET['pname'];
	$projectIP = $_GET['ip'];
	if($latestFileLength > 0)
	{
		$ipData = fread($latestFileHandle, $latestFileLength);
	}
	$projPos = strpos($ipData,$projectName);
	$masterIP = $projectIP;

	if($projPos > 0)
	{
		$ipPos = $projPos + strlen($projectName) + 1;

		$startIpPos  = $ipPos;
		$masterIP = "";
		
		while($ipData[$ipPos] != ' ')
		{
			$masterIP = $masterIP . $ipData[$ipPos];
			$ipPos = $ipPos + 1;
		}

		$ipData = str_replace($masterIP, $projectIP, $ipData);
	}
	else
		$ipData = $ipData . "\n" . $projectName . ":" . $projectIP . " \n";
	fclose($latestFileHandle);
	$latestFileHandle = fopen($latestFileName, 'w') or die("can't open file");
	fwrite($latestFileHandle, $ipData);
	fclose($latestFileHandle);
	print $masterIP;
?>