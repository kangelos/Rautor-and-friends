#!wperl.exe
#
# 


package coliau;

use common::sense;

sub initRepeatHeader(){
	my $RepeatHeader ="";
	while(<DATA>){
		chomp($_);
		$RepeatHeader .= $_. "\r\n";
	}
	return($RepeatHeader);
}

1;

####################################################
####################################################

__DATA__

<!DOCTYPE html>
 <html lang="en">
 <head>
 <META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">
   <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
   <title>Live Session Monitor (http://www.unix.gr for more)</title>     
   
   <style>
   
	#controlPanel {
		position:absolute;
		top:0px;
		left:0px;
		width: 200px; 
		height: 350px;
		visibility:hidden;
		border: 3px solid rgb(0, 0, 250);
	}	

	
   #buttons {
		position:absolute;
		top:0px;
		left:0px;		
		bgcolor: gold;
		border: 0px solid rgb(0, 0, 0);
	}	
	
   #keylog {
		position:absolute;
		top:0px;
		right:0px;
		width: 650px; 
		height: 54px;
		border: 2px solid rgb(0, 0, 250);
		visibility:hidden;
	}	

	#scrape {
		position:absolute;
		top:130px;
		left:250px;
		width: 500px; 
		height: 300px;
		visibility:hidden;
		border: 2px solid rgb(0, 0, 250);
	}	

	</style>

  <link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css" rel="stylesheet" type="text/css"/>
  <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4/jquery.min.js"></script>
  <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js"></script>

   <script type="text/javascript">
   var clock;
   
    $(document).ready(
		function(){
			refreshScreens();
			blinkButton();
			$("#controlPanel").draggable();
			$("#scrape").draggable();
			$("#keylog").draggable();
		}
	 );

	function ReloadText(){
		var iskeyvis=document.getElementById('keylog').style.visibility;		
		if ( (iskeyvis=='hidden') ||  (iskeyvis=='') ) { 
			return;
		}
		
		var now = new Date();
		$.get('/keylog?' + now.getTime(),		 
				function(data) {							
					if ( data.length < 1 ) {return;	}			 					
					var val=document.getkeylog.keylog.value;	
					if ( val.length >  90) {
						document.getkeylog.keylog.value =data;
					} else {			
						document.getkeylog.keylog.value += data;
					}
				}
			);
	}
	
	
	function showScrape(){
		document.getElementById('scrape').style.visibility= 'visible';
		var now = new Date();
		$.get('/scrape?' + now.getTime(),		 
			function(data) {							
				document.scrapearea.contents.value = data;
			}
		);
	}
	
	
	function faster() {		
		var refresh=document.refreshtime.timeout.value * 1000;	
		refresh=refresh-1000;
		if (refresh<=1000 ) {
			refresh=1000;
		}
		document.refreshtime.timeout.value =refresh/1000;
	}
	
	function slower() {
		var refresh=document.refreshtime.timeout.value * 1000;
		refresh=refresh+1000;
		document.refreshtime.timeout.value =refresh/1000;		
	}
	
	
	
	function refreshScreens() {
		clearTimeout(clock);
		var now = new Date();
		var refresh=document.refreshtime.timeout.value * 1000;
		ReloadText();
		for ( var i=1;i<=document.images.length;i++) {
			var imgname="screen"+i;	
			var myImage = new Image();
			myImage.src = imgname+'.png?' + now.getTime();
			document.images[imgname].src = myImage.src;
		}		
		clock=setTimeout('refreshScreens()',refresh);
	}


	function hidediv(divname) {
		document.getElementById(divname).style.visibility = 'hidden';
	}

	function showdiv(divname) {	
		document.getElementById(divname).style.visibility = 'visible';	 
	}

	var i=0;
	function blinkButton() {
        if (i%2 == 0) {              
              document.getElementById('cp').style.backgroundColor = '#4050ff';
         } else {
              document.getElementById('cp').style.backgroundColor = '#ff0000';
         }
		i++;
		if ( i > 10 ) { i=0}
		setTimeout('blinkButton()',1200);
}

</script>
</head>





<body>

<!-- ------------------------------------------------------------------------ -->
<div id="buttons">
	<button id="cp" onclick="javascript:showdiv('controlPanel')" style="background-color:gold">&gt;</button>
</div>


<!-- ------------------------------------------------------------------------ -->
<div id="controlPanel">
<table border=0 cellpadding=3 cellspacing=0 bgcolor=gold width="100%" height="100%">		
<tr height=10>
	<td align=center bgcolor=blue>
		<font color=white face=arial>&nbsp;&nbsp;CONTROL&nbsp;PANEL</font>
	</td>
	<td bgcolor=blue align=right>
		<button onclick="javascript:hidediv('controlPanel')" style="background-color:RED"><font color=white size=-1><b>X</b></font></button>
	</td>
</tr>
<tr>	
	<td colspan=2 align=center>
	<font face=arial>
		<b>Refresh Rate</b><br>
		<button onclick="slower()">&lt;&lt;Slow</button>
		<button onclick="refreshScreens()">Now</button></font>
		<button onclick="faster()">&gt;&gt;Fast</button>	
	<font face=arial>
		<form method=get name="refreshtime">
		Every:<input readonly size=1 type=text name="timeout" value=1>Seconds</form></td>
</tr>


<tr>
	<td colspan=2 align=center>
			<font face=arial>
			<b>Viewing Mode</b><br> 
			<button onclick="location.href='/monitor8bits'">8</button>
			<button onclick="location.href='/monitor16bits'">16</button>
			<button onclick="location.href='/monitor32bits'">All</button> Bits
	</td>
</tr>
<tr>
	<td colspan=2 align=center>		
	<font face=arial>
		<b>Screen Image Size</b><br>
		<button onclick="location.href='/mobile'">Tiny</button>
		<button onclick="location.href='/scale'">Small</button>
		<button onClick="location.href='/noscale'">Normal</button>		
	</td>
</tr>
<tr>
	<td colspan=2 align=center>		
	<font face=arial>
		<b>Utilities</b><br>
		<button onclick="javascript:showdiv('keylog')">Key Logger</button>		
		<button onClick="javascript:showScrape();">Screen Scraper</button>
		<button onClick="window.open('/netstat','netstat','left=100,top=50,width=320,height=480,toolbar=0,location=0,scrollbars=1,scrollbar=1,resizable=1');">Quick NetStat</button>
</form> 
	</td>
</tr>


</table>

</div>

<!-- ------------------------------------------------------------------------ -->
<!--             Keyboard log -->

<div id="keylog">
<table border=0 cellpadding=2 cellspacing=0 bgcolor=gold width="100%" height="100%">
<tr height=10>
	<td align=center bgcolor=blue><font color=white face=arial>KEYBOARD LOG</font></td>
	<td bgcolor=blue align=right><button onclick="javascript:hidediv('keylog')" style="background-color:RED"><font color=white><b>X</b></font></button></td>
</tr>
<tr>
<td colspan=2 align=center><form method=get name="getkeylog"><input readonly type=text name="keylog" size=100></form></td>
</tr>
</table>
</div>

<!-- ------------------------------------------------------------------------ -->
<!--              screen scraping  -->

<div id="scrape">
<table border=0 cellpadding=2 cellspacing=0 bgcolor=gold width="100%" height="100%">
<tr height=15>
	<td align=center bgcolor=blue>
		<font color=white face=arial>&nbsp;&nbsp;&nbsp;TEXTUAL SCREEN CONTENTS</font>
	</td>
	<td bgcolor=blue align=right>
		<button onclick="javascript:hidediv('scrape')" style="background-color:RED"><font color=white><b>X</b></font></button>
	</td>
</tr> 
<tr>
<td colspan=2 align=center valign=center>
	<form method=get name="scrapearea"><textarea readonly name="contents" rows="14" cols="57" ></textarea></form>
</td>
</tr>
</table>
</div>



<!-- ------------------------------------------------------------------------ -->
<!-- <div id="screens"> -->