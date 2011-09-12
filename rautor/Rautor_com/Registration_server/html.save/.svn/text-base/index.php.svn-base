<meta http-equiv="refresh" content="10">
<?php


$conn=mysql_connect ('localhost','rautor','\\pass');
$db_selected = mysql_select_db('rautor', $conn);


$ip = $_SERVER['REMOTE_ADDR'];
$user= $_SERVER['PHP_AUTH_USER'];

mysql_query("insert into admin_logins (username,ip,lastreview) values('$user','$ip',now())");
mysql_query("update admin_logins set username='$user',lastreview=now() where ip='$ip'");

?>




<?php   /* session display stuff */
require_once('TableEditor.php');

$editor = new TableEditor($conn, 'sesview');
    
$editor->setConfig('allowCSV', false);
$editor->setConfig('allowView', false);
$editor->setConfig('allowAdd', false);
$editor->setConfig('allowEdit', false);
$editor->setConfig('allowCopy', false);
$editor->setConfig('allowDelete', false);

$editor->setConfig('title', 'Live Sessions Monitor');
$editor->setConfig('footerfile','footer.html');

$editor->setConfig('perPage', 30);

$editor->setDisplayNames(array(
                               'node'     => 'Domain:Terminal',
                               'username'     => 'Login Name',
                               'timestamp'    => 'Sess. Start Time',
                               'Screen'    => 'Live',

));

$editor->setSearchableFields( 'username' , 'node' , 'timestamp' );


$editor->setRequiredFields( 'username' , 'node' , 'domain'  , 'timestamp' ,
	'status', 'clearedtime', 'sessionid' , 'ipadress' , 'port' );

$editor->noDisplay('sessionid');
$editor->noDisplay('ipaddress');
$editor->noDisplay('port');
$editor->noDisplay('clearedtime');
$editor->noDisplay('status');

$editor->setDefaultOrderby('username');

$editor->display();

?> 
