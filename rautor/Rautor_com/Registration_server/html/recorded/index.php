<?php


$conn=mysql_connect ('localhost','rautor','\\pass');
$db_selected = mysql_select_db('rautor', $conn);


$ip = $_SERVER['REMOTE_ADDR'];
$user= $_SERVER['PHP_AUTH_USER'];

?>




<?php   /* session display stuff */
require_once('TableEditor.php');

$editor = new TableEditor($conn, 'rautor_sessions');
    
#$editor->setConfig('allowCSV', false);
$editor->setConfig('allowView', false);
$editor->setConfig('allowAdd', false);
$editor->setConfig('allowEdit', false);
$editor->setConfig('allowCopy', false);
$editor->setConfig('allowDelete', false);

$editor->setConfig('title', 'Rautor Sessions\' Listing');
$editor->setConfig('footerfile','footer.html');

$editor->setConfig('perPage', 50);

$editor->setDisplayNames(array(
                               'path'     => 'Full Path where files were saved && PC Name',
                               'node'     => 'Terminal',
                               'domain'     => 'Domain',
                               'username'     => 'Login Name',
                               'starttime'    => 'Session Start Time',
                               'lastping'    => 'Session Last Update',
                               'clearedtime'    => 'Session Stop Time',

));

$editor->setSearchableFields( 'username' , 'node' , 'starttime' , 'domain' );


$editor->setRequiredFields( 'username' , 'node' , 'domain'  , 'timestamp' ,
	'status', 'clearedtime', 'sessionid' , 'ipadress' , 'port' );

$editor->noDisplay('node');
$editor->noDisplay('ipaddress');
$editor->noDisplay('clearedtime');
#$editor->noDisplay('status');

$editor->setDefaultOrderby('username');

$editor->display();

?> 
