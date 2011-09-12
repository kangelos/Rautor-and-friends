
#===vptk widgets definition===< DO NOT WRITE UNDER THIS LINE >===
use Tk::Balloon;
$vptk_balloon=$mw->Balloon(-background=>"lightyellow",-initwait=>550);
$w_LabFrame_001 = $mw -> LabFrame ( -label=>'w_LabFrame_001', -relief=>'ridge', -labelside=>'acrosstop' ) -> pack();
$w_Checkbutton_003 = $w_LabFrame_001 -> Checkbutton ( -justify=>'left', -overrelief=>'raised', -offrelief=>'raised', -relief=>'flat', -indicatoron=>1, -text=>'w_Checkbutton_003', -state=>'normal' ) -> pack(-anchor=>'w');
$w_LabEntry_004 = $w_LabFrame_001 -> LabEntry ( -label=>'w_LabEntry_004', -relief=>'sunken', -labelPack=>[-side=>'left',-anchor=>'n'] ) -> pack();

