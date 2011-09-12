<?php

/**
* Demo of TableEditor class. Uses the following table:
* 
* CREATE TABLE `TableEditorDemo` (
*   `te_id` int(10) unsigned NOT NULL auto_increment,
*   `te_name` varchar(32) NOT NULL default '',
*   `te_password` varchar(32) NOT NULL default '',
*   `te_email` varchar(32) NOT NULL default '',
*   `te_datetime` datetime NOT NULL default '0000-00-00 00:00:00',
*   `te_age` tinyint(3) unsigned NOT NULL default '0',
*   `te_live` enum('LIVE','NOT LIVE') default NULL,
*   `te_desc` mediumtext NOT NULL,
*   PRIMARY KEY  (`te_id`)
* ) TYPE=MyISAM;
*/

require_once('TableEditor.php');

$editor = new TableEditor($conn, 'rautor');
    
// $editor->setConfig('allowView', false);
// $editor->setConfig('allowAdd', false);
// $editor->setConfig('allowEdit', false);
// $editor->setConfig('allowCopy', false);
// $editor->setConfig('allowDelete', false);

$editor->setConfig('perPage', 30);

$editor->setDisplayNames(array('te_id'       => 'ID',
                               'te_name'     => 'Name',
                               'te_password' => 'Password',
                               'te_email'    => 'Email',
                               'te_datetime' => 'Date Added',
                               'te_age'      => 'Age',
                               'te_live'     => 'Live',
                               'te_desc'     => 'Description'));

// $editor->noDisplay('te_password');
$editor->noEdit('te_live');

$editor->setInputType('te_password', 'password');
$editor->setInputType('te_email', 'email');

$editor->setSearchableFields('te_name', 'te_age', 'te_id', 'te_desc', 'te_live');
$editor->setRequiredFields('te_name', 'te_email', 'te_datetime', 'te_age', 'te_desc');

$editor->setDefaultOrderby('te_id');
$editor->setDefaultValues(array('te_id'   => '0',
                                'te_live' => 'NOT LIVE'));

//$editor->addAdditionCallback(create_function('$data', 'foreach($data as $k => $v) {$body[] = "$k => $v";} mail("joe@example.com", "Row added", implode("\n", $body));'));
//$editor->addEditCallback(create_function('$data', 'foreach($data as $k => $v) {$body[] = "$k => $v";} mail("joe@example.com", "Row edited", implode("\n", $body));'));
//$editor->addCopyCallback(create_function('$data', 'foreach($data as $k => $v) {$body[] = "$k => $v";} mail("joe@example.com", "Row copied", implode("\n", $body));'));
//$editor->addDeleteCallback(create_function('$data', 'foreach($data as $k => $v) {$body[] = "$k => $v";} mail("joe@example.com", "Row deleted", implode("\n", $body));'));

function validateAge(&$obj, $data)
{
    $data = (int)$data;

    if ($data < 18 OR $data > 80) {
        $obj->addError('Invalid age! Please enter an age between 18 and 80');
    }

    return $data;
}

$editor->addValidationCallback('te_age', 'validateAge');

$editor->addDisplayFilter('te_desc', create_function('$v', 'return substr($v, 0, 100) . "...";'));

$editor->display();

?> 
