<?php


$conn=mysql_connect ('localhost','root','banana');
$db_selected = mysql_select_db('rautor', $conn);


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

$editor->noDisplay('sessionid');
$editor->noDisplay('ipaddress');
$editor->noDisplay('port');
$editor->noDisplay('clearedtime');
$editor->noDisplay('status');

$editor->setDefaultOrderby('username');

#function validateAge(&$obj, $data)
#{
#    $data = (int)$data;
#
#    if ($data < 18 OR $data > 80) {
#        $obj->addError('Invalid age! Please enter an age between 18 and 80');
#    }
#
#    return $data;
#}
#
#$editor->addValidationCallback('clearedtime', 'validateAge');

#$editor->addDisplayFilter('username', create_function('$v', 'return substr($v, 0, 100) . "...";'));

$editor->display();

?> 
