<?php

$conn=mysql_connect ('localhost','rautor','\\pass');
$db_selected = mysql_select_db('rautor', $conn);


require_once('TableEditor.php');

$editor = new TableEditor($conn, 'sessions');
    
$editor->setConfig('allowAdd', false);
$editor->setConfig('allowEdit', false);
$editor->setConfig('allowCopy', false);
#$editor->setConfig('allowDelete', false);
#$editor->setConfig('allowCSV', false);
#$editor->setConfig('allowView', false);

$editor->setConfig('title', 'Manage All Sessions');
$editor->setConfig('footerfile','footer.html');

$editor->setConfig('perPage', 20);

$editor->setDisplayNames(array('domain'       => 'Domain',
                               'node'     => 'PC name',
                               'username'     => 'username',
                               'timestamp'    => 'Start Time',
                               'sessionid' => 'Session ID',
                               'status'     => 'Status',
                               'clearedtime'    => 'Cleared Time',
                               'ipadress' => 'IP Address',
                               'port'      => 'Port',
                               'url'      => 'URL'

));

$editor->setSearchableFields( 'username' , 'node' , 'timestamp' );


$editor->setRequiredFields(
'username' ,
'node' ,
'domain'  ,
'timestamp' ,
'status',
'clearedtime', 
'sessionid' , 
'ipadress' , 
'port' 
);

#$editor->noDisplay('sessionid');
$editor->noDisplay('ipaddress');
$editor->noDisplay('port');
$editor->noDisplay('lastping');
#$editor->noDisplay('clearedtime');
#$editor->noDisplay('status');

$editor->setDefaultOrderby('timestamp,username');

$editor->display();

?> 
