<?php
error_reporting(E_ERROR);

function LogDeparture($beaconName, $checkpointID, $gps, $time) {
		//Check for valid inputs
		//Attempt to write to SQL
		//Communicate success or failure
	
		//$error will be blank if no error, or a list of errors found
		$error = "";
		//Check that beacon name is valid
		$sql = "Select * from Beacons where Name = '" . $beaconName . "'";
		$result = mysql_query($sql);
		if (mysql_num_rows ($result) < 1) 
			$error = $error . "\nInvalid Beacon";
	
		//Check that checkpoint is valid
		$sql = "Select * from Checkpoints where ID = " . $checkpointID;
		$result = mysql_query($sql);
	
		if (mysql_num_rows ($result) < 1) 
			$error = $error . "\nInvalid CheckPoint";	
	
		//Check for a valid GPS
		if (preg_match('/^(\-?\d+(\.\d+)?),\s*(\-?\d+(\.\d+)?)$/', $gps) == 0)
			$error = $error . "\nInvalid GPS";
		
		//Check for a valid DateTime
		if (preg_match(('/[-+]?[0-9]*\.?[0-9]+/'), $time) == 0)
			$error = $error . "\nInvalid Time";
	
	
		// IF THERE ARE NO ERRORS, PROCEED WITH ATTEMPTING TO WRITE TO THE DB
		if ($error == "") {
//			echo nl2br("LogDeparture\r\n" . "\r\n[BeaconName]:" . $beaconName . "\r\n[CheckpointID]:" . $checkpointID . "\r\n[GPS]:" . $gps . "\r\n[Time]:" . $time);
			$query = 'INSERT INTO Departures (BeaconName, CheckpointID, GPS, Time) Values ("'. $beaconName . '", ' . $checkpointID . ', "' . $gps . '", "' . $time . '")';
//			echo "<br>" . $query;
			$result = mysql_query($query);
			if (!$result) {
    			$sqlError = mysql_error();
			}	
			
		} else {
			//Get Rid of the first \n in the $result
			//Inform the user of the error
			$error = ltrim($error);
//			echo nl2br($error);
			
		}
	
		//Create JSON and output results
		$json = array
					(
						'Action' => "LogDeparture",
						'BeaconName' => $beaconName,
						'CheckPointID' => $checkpointID,
						'GPS' => $gps,
						'Time' => $time,
						'ResultQuery' => $query,
						'mysql_error' => mysql_error(),
						'error' => $error
					);

		echo json_encode($json);
}

function LogArrival($beaconName, $checkpointID, $gps, $time) {
		//Check for valid inputs
		//Attempt to write to SQL
		//Communicate success or failure
		
		//$error will be blank if no error, or a list of errors found
		$error = "";
		//Check that beacon name is valid
		$sql = "Select * from Beacons where Name = '" . $beaconName . "'";
		$result = mysql_query($sql);
		if (mysql_num_rows ($result) < 1) 
			$error = $error . "\nInvalid Beacon";
	
		//Check that checkpoint is valid
		$sql = "Select * from Checkpoints where ID = " . $checkpointID;
		$result = mysql_query($sql);
		if (mysql_num_rows ($result) < 1) 
			$error = $error . "\nInvalid CheckPoint";	
	
		//Check for a valid GPS
		if (preg_match('/^(\-?\d+(\.\d+)?),\s*(\-?\d+(\.\d+)?)$/', $gps) == 0)
			$error = $error . "\nInvalid GPS";
		
		//Check for a valid DateTime
		if (preg_match(('/[-+]?[0-9]*\.?[0-9]+/'), $time) == 0)
			$error = $error . "\nInvalid Time";
	
	
		// IF THERE ARE NO ERRORS, PROCEED WITH ATTEMPTING TO WRITE TO THE DB
		if ($error == "") {
//			echo nl2br("LogArrival\r\n" . "\r\n[BeaconName]:" . $beaconName . "\r\n[CheckpointID]:" . $checkpointID . "\r\n[GPS]:" . $gps . "\r\n[Time]:" . $time);
			$query = 'INSERT INTO Arrivals (BeaconName, CheckpointID, GPS, Time) Values ("'. $beaconName . '", ' . $checkpointID . ', "' . $gps . '", "' . $time . '")';
//			echo "<br>" . $query;
			$result = mysql_query($query);
			if (!$result) {
    			$sqlError = mysql_error();
			}		
			
		} else {
			//Get Rid of the first \n in the $result
			//Inform the user of the error
			$error = ltrim($error);
//			echo nl2br($error);
			
		}
		
		//Create JSON and output results
		$json = array
					(
						'Action' => "LogArrival",
						'BeaconName' => $beaconName,
						'CheckPointID' => $checkpointID,
						'GPS' => $gps,
						'Time' => $time,
						'ResultQuery' => $query,
						'mysql_error' => mysql_error(),
						'error' => $error
					);

		echo json_encode($json);
}

function GetBeaconInfo ($beaconname) {
	//Ensure that the beacon name is a valid beacon
	//Provide status on that specific beacon.
	//$error will be blank if no error, or a list of errors found
		$error = "";
		//Check that beacon name is valid
		$sql = "Select * from Beacons where Name = '" . $beaconname . "'";
		$result = mysql_query($sql);
		
		if (mysql_num_rows ($result) < 1) 
			$error = $error . "\nInvalid Beacon";

		// IF THERE ARE NO ERRORS, PROCEED WITH ATTEMPTING TO WREAD FROM THE DB
		if ($error == "") {
				$query = file_get_contents('./GetBeaconInfo.txt');
				$query = str_replace("@B", "'" . $beaconname . "'", $query);
				$result = mysql_query($query);
				if (!$result) {
    				$sqlError = mysql_error();
				}		
					
		} else {
				//Get Rid of the first \n in the $result
				//Inform the user of the error
				$error = ltrim($error);
		}	
			
		//Create JSON and output results
	    $rows = array();
		while($r = mysql_fetch_array($result)) {
			$rows[$beaconname] = $r;
		}

		if ($error == "") {
			array_unshift ( $rows , 'GetBeaconInfo' );
			echo json_encode($rows);
		} else {
			$json = array
			(
				'Action' => "GetBeaconInfo",
				'BeaconName' => $beaconname,
				'ResultQuery' => $query,
				'mysql_error' => mysql_error(),
				'error' => $error
			);
			
			echo json_encode($json);
		}

}

function GetBeaconInfoAll () {
	//Return all info on all beacons
	//Including assigned riders, last known arrival and departure

	//Run a Query to Loop throuhgt all Beacons
	$BeaconLoopQuery = "Select DISTINCT Name from Beacons";
	$BeaconLoopResult = mysql_query($BeaconLoopQuery);
	$rows = array();
	
	while ($Loopr = mysql_fetch_array($BeaconLoopResult)) {
		
			
				$query = file_get_contents('./GetBeaconInfo.txt');
				$query = str_replace("@B", "'" . $Loopr['Name'] . "'", $query);
				$result = mysql_query($query);

				while($r = mysql_fetch_array($result)) {
						$rows[$Loopr['Name']] = $r;
				}

	
	}		
		//Create JSON and output results
		array_unshift ( $rows , 'GetBeaconInfoALL' );
		echo json_encode($rows);
	
}

function GetBeaconDetails ($beaconname) {
	//Ensure that the beacon name is a valid beacon
	//Provide details on that specific beacon : basically a timestamp of all actions.: Arrivals, Departures, Assignments in chronological order
		$error = "";
		//Check that beacon name is valid
		$sql = "Select * from Beacons where Name = '" . $beaconname . "'";
		$result = mysql_query($sql);
		
		if (mysql_num_rows ($result) < 1) 
			$error = $error . "\nInvalid Beacon";

		// IF THERE ARE NO ERRORS, PROCEED WITH ATTEMPTING TO WREAD FROM THE DB
		if ($error == "") {
				$query = "SELECT * FROM VIEW_BeaconDetails WHERE BeaconName = '" . $beaconname . "'";
				$result = mysql_query($query);
				if (!$result) {
    				$sqlError = mysql_error();
				}		
					
		} else {
				//Get Rid of the first \n in the $result
				//Inform the user of the error
				$error = ltrim($error);

		}	
			
		//Create JSON and output results
	    $rows = array();
		while($r = mysql_fetch_array($result)) {
			$rows[] = $r;
		}

		if ($error == "") {
			echo json_encode($rows);	
		} else {
			$json = array
				(
					'Action' => "GetBeaconDetails",
					'BeaconName' => $beaconname,
					'ResultQuery' => $query,
					'mysql_error' => mysql_error(),
					'error' => $error
				);
			array_unshift ( $rows , 'GetBeaconDetails' );
			echo json_encode($json);
		}
}

function GetBeaconDetailsALL () {
	//Give Chronological list of all beacon detials.
	$query = 'SELECT * FROM VIEW_BeaconDetails';
	$result = mysql_query($query);
	$rows = array();
	while($r = mysql_fetch_array($result)) {
			$rows[] = $r;
		}
	array_unshift ( $rows , 'GetBeaconInfoDetailsALL' );
	echo json_encode($rows);
	
}

//--------------------------------------------------------------------------------------------------


//Variables for connecting to your database.
//These variable values come from your hosting account.
$hostname = "TrilliumARRR.db.9471354.hostedresource.com";
$username = "TrilliumARRR";
$dbname = "TrilliumARRR";

//These variable values need to be changed by you before deploying
$password = "P@ssw0rd";

//Connecting to your database
mysql_connect($hostname, $username, $password) OR DIE ("Unable to
connect to database! Please try again later.");
mysql_select_db($dbname);


//First Step: Determine action to take
$action = htmlspecialchars($_GET["ACTION"]);
switch ($action) {
    case "LogDeparture":
		//To log a departure, we will need the following parameters:
		// BeaconName
		// CheckPointID
		// GPS
		// Time
		$BeaconName = htmlspecialchars($_GET["BeaconName"]);
		$CheckpointID = htmlspecialchars($_GET["CheckpointID"]);
		$GPS = htmlspecialchars($_GET["GPS"]);
		$Time = htmlspecialchars($_GET["Time"]);
		
		LogDeparture($BeaconName,$CheckpointID, $GPS, $Time);
        break;
	
    case "LogArrival":
		//To log an arrival, we will need the following parameters:
		// BeaconName
		// CheckPointID
		// GPS
		// Time
		$BeaconName = htmlspecialchars($_GET["BeaconName"]);
		$CheckpointID = htmlspecialchars($_GET["CheckpointID"]);
		$GPS = htmlspecialchars($_GET["GPS"]);
		$Time = htmlspecialchars($_GET["Time"]);
		
		LogArrival($BeaconName,$CheckpointID, $GPS, $Time);
        break;
	
    case "GetBeaconInfo":
		//To Get info on a single beacon, we need the BeaconName
        $BeaconName = htmlspecialchars($_GET["BeaconName"]);
		GetBeaconInfo ($BeaconName);
        break;
	
	case "GetBeaconInfoALL":
        GetBeaconInfoAll();
        break;
	
	case "GetBeaconDetails":
		$BeaconName = htmlspecialchars($_GET["BeaconName"]);
		GetBeaconDetails($BeaconName);
		break;

		case "GetBeaconDetailsALL":
		GetBeaconDetailsALL();
		break;
	

	
	default:
				//Create JSON and output results
		$json = array
					(
						'Action' => $action,
						'error' => "That command is not recognized."
					);

		echo json_encode($json);
//		echo "That command is not recognized.  Command: '" . $action . "'";
}





?>
