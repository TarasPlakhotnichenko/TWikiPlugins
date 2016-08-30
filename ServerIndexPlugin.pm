package TWiki::Plugins::ServerIndexPlugin;
use strict;
use DBI;
use vars qw( $VERSION $RELEASE $SHORTDESCRIPTION $debug $pluginName $NO_PREFS_IN_TOPIC );
$VERSION = '$Rev: 1 (2012-12-06) $';
$RELEASE = '2012-12-06';

$SHORTDESCRIPTION = 'ServerIndex plugin';
$NO_PREFS_IN_TOPIC = 0;
$pluginName = 'ServerIndexPlugin';
my $file='/var/www/html/twiki/data/OSL/Servers.txt';

#USE [HelpDesk]
#GO


#SET ANSI_NULLS ON
#GO

#SET QUOTED_IDENTIFIER ON
#GO

#SET ANSI_PADDING ON
#GO

#CREATE TABLE [dbo].[ServerIndex](
#	[id] [int] IDENTITY(1,1) NOT NULL,
#	[DataCenter] [varchar](200) NULL,
#   [Location] [varchar](500) NULL,
#	[Name] [varchar](100) NULL,
#	[OS] [varchar](100) NULL,
#	[ServerIP1] [varchar](150) NULL,
#	[ServerIP2] [varchar](150) NULL,
#	[iLO] [varchar](100) NULL,
#	[Soft] [varchar](200) NULL,
#	[SysInfo] [varchar](1000) NULL,
#   [Comments] [varchar](1000) NULL,
#	[date] [datetime] NOT NULL,
# CONSTRAINT [PK_ServerIndex] PRIMARY KEY CLUSTERED 
#(
#	[id] ASC
#)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 1) ON [PRIMARY]
#) ON [PRIMARY]

#GO

#SET ANSI_PADDING OFF
#GO

#ALTER TABLE [dbo].[ServerIndex] ADD  CONSTRAINT [DF_ServerIndex_date]  DEFAULT (getdate()) FOR [date]
#GO

#USE [HelpDesk];
#ALTER TABLE dbo.ServerIndex ALTER COLUMN SysInfo varchar(1000);




sub initPlugin {
    my( $topic, $web, $user, $installWeb ) = @_;
	TWiki::Func::registerTagHandler( 'ServerIndex', \&_ServerIndex );
    return 1;
}

sub _ServerIndex {
    my($session, $params, $theTopic, $theWeb) = @_;
    my $sql = '';
    my $data_source = q/dbi:ODBC:mssql_68/;
    my $user = q/nagios/;
    my $password = q/Nag4Read/;
	my $dbh = DBI->connect($data_source, $user, $password);

	$dbh->{'LongTruncOk'} = 1;
    $dbh->{'LongReadLen'} = 200;

	my $ServerIndex_id = $params->{id} || '';
	my $ServerIndex_datacenter = $params->{datacenter} || '';
	my $ServerIndex_location = $params->{location} || '';
	my $ServerIndex_name = $params->{name} || '';
	my $ServerIndex_os = $params->{opsys} || '';
	my $ServerIndex_serverip1 = $params->{serverip1} || '';
	my $ServerIndex_serverip2 = $params->{serverip2} || '';
	my $ServerIndex_ilo = $params->{ilo} || '';
	my $ServerIndex_soft = $params->{soft} || '';
	my $ServerIndex_sysinfo = $params->{sysinfo} || '';
	my $ServerIndex_comments = $params->{comments} || '';
	my $ServerIndex_insert = $params->{insert} || '0';
	my $ServerIndex_update = $params->{update} || '0';
	my $ServerIndex_delete = $params->{delete} || '0';
	#my $ServerIndex_top = $params->{top} || '';
	my @dump=();
	my $twisty_show='hide';
	my $form = '';
	my $section='';
	my $twisty2 = q(%TWISTY{start="hide"}%);
    my $twisty3 = q(%ENDTWISTY%);
	
	
	
	#remove ending spaces and vertical bars-----vvv
	$ServerIndex_datacenter =~s/\s+$//;
	$ServerIndex_datacenter =~s/\n/ /g;
	$ServerIndex_datacenter =~s/\|/\&verbar\;/g;
	
	$ServerIndex_comments =~s/\s+$//;

	$ServerIndex_comments =~s/\|/\&verbar\;/g;
	
	$ServerIndex_soft =~s/\s+$//;
	$ServerIndex_soft =~s/\n/ /g;
	$ServerIndex_soft =~s/\|/\&verbar\;/g;
	
	$ServerIndex_sysinfo =~s/\s+$//;
	$ServerIndex_sysinfo =~s/\|/\&verbar\;/g;
	
	$ServerIndex_location=~s/\s+$//;
	$ServerIndex_location=~s/\n/ /g;
	$ServerIndex_location =~s/\|/\&verbar\;/g;
	
	$ServerIndex_name=~s/\s+$//;
	$ServerIndex_name=~s/\n/ /g;
	$ServerIndex_name =~s/\|/\&verbar\;/g;
	
	$ServerIndex_os=~s/\s+$//;
	$ServerIndex_os=~s/\n/ /g;
	$ServerIndex_os =~s/\|/\&verbar\;/g;
	#remove ending spaces and vertical bars-----^^^
	
    #push(@dump," -$ServerIndex_update- | -$ServerIndex_delete- | -$ServerIndex_id- ");	
    if  (($ServerIndex_delete eq '0') and !($ServerIndex_id eq ''))
	{
	
	$sql = qq(SELECT [id],[datacenter],[location],[name],[os],[serverip1],[serverip2],[ilo],[soft],[sysinfo],[comments]  FROM [HelpDesk].[dbo].[ServerIndex] where id=$ServerIndex_id;);    
	my $sth = $dbh->prepare("$sql");
	$sth->execute();
	
	my $datacenter='';
	my $location='';
	my $name='';
	my $os='';
	my $serverip1='';
	my $serverip2='';
	my $ilo='';
	my $soft='';
	my $sysinfo='';
	my $comments='';
	my $date='';
	if (my $data = $sth->fetchrow_arrayref)
	 {
	  
	  @$data[1] =~s/\s+$//;
	  @$data[1] =~s/\|/\&verbar\;/g;
	  
	  @$data[2] =~s/\s+$//;
	  @$data[2] =~s/\|/\&verbar\;/g;
	  
	  @$data[3] =~s/\s+$//;
	  @$data[3] =~s/\|/\&verbar\;/g;
	  
	  
	  @$data[4] =~s/\s+$//;
	  @$data[4] =~s/\|/\&verbar\;/g;
	  
	  @$data[5] =~s/\s+$//;
	  @$data[5] =~s/\|/\&verbar\;/g;
	  
	  @$data[6] =~s/\s+$//;
	  @$data[6] =~s/\|/\&verbar\;/g;
	  
	  @$data[7] =~s/\s+$//;
	  @$data[7] =~s/\|/\&verbar\;/g;
	  
	  @$data[8] =~s/\s+$//;
	  @$data[8] =~s/\|/\&verbar\;/g;
	  
	  @$data[9] =~s/\s+$//;
	  #@$data[9] =~s/<br>/\n/g;
	  @$data[9] =~s/\|/\&verbar\;/g;
	  
	  @$data[10] =~s/\s+$//;
	  #@$data[10] =~s/<br>/\n/g;
	  @$data[10] =~s/\|/\&verbar\;/g;
 	  
	  if (@$data[1]) {$datacenter=@$data[1]};
	  if (@$data[2]) {$location=@$data[2]};
	  if (@$data[3]) {$name=@$data[3]};
	  if (@$data[4]) {$os=@$data[4]};
	  if (@$data[5]) {$serverip1=@$data[5]};
	  if (@$data[6]) {$serverip2=@$data[6]};
	  if (@$data[7]) {$ilo=@$data[7]};
	  if (@$data[8]) {$soft=@$data[8]};
	  if (@$data[9]) {$sysinfo=@$data[9]};
	  if (@$data[10]) {$comments=@$data[10]};
	  if (@$data[11]) {$date=@$data[11]};
	 }
	
 $form = q(%TABLE{ sort="off" tablewidth="100%"}%<form name="soft_request_rates" action="%SCRIPTURLPATH{view}%/%WEB%/%TOPIC%" method="post">
| *DataCenter*  | *SysInfo* | *Name* |
 | <literal><input type="text" name="datacenter" value=");
 $form .= "$datacenter"; 
 
 $form .= q(" size="60" class="twikiInputField"  /></literal> | <literal><input type="text" name="location" value=");
 $form .= "$location";
 
 $form .= q(" size="50" class="twikiInputField" /></literal> | <literal><input type="text" name="name" value=");
 $form .= "$name";
 
 $form .= q(" size="62" class="twikiInputField" /></literal> | 
  | *OS*  | *ServerIP1* | *ServerIP2* |
  |<literal><input type="text" name="opsys" value=");
 $form .= "$os";
  
 $form .= q(" size="60" class="twikiInputField" /></literal> | <literal><input type="text" name="serverip1" value=");
  $form .= "$serverip1";

  $form .= q(" size="50" class="twikiInputField" /></literal> | <literal><input type="text" name="serverip2" value=");
  $form .= "$serverip2";
  
  $form .= q(" size="62" class="twikiInputField" /></literal> | 
  | *iLo* |*Funct* | *HardWare* |
  | <literal><input type="text" name="ilo" value=");
  $form .= "$ilo";
  
  $form .= q(" size="60" class="twikiInputField" /></literal> |);

  $form .= q( <literal><input type="text" name="soft" value=");
  $form .= "$soft";
  $form .= q(" size="50" class="twikiInputField" /></literal> |);
  
  $form .= q(<literal><textarea cols="60" rows="3" name="sysinfo" class="twikiInputField">);
  $form .= "$sysinfo";
  
  $form .= q(</textarea></literal> |);
  
  
  $form .= q( 
  | *Comments* | ** | ** |
  | <literal><textarea cols="60" rows="5" name="comments" class="twikiInputField">);
  $form .= "$comments";
  
  $form .= q(</textarea></literal> |||
  <input type="hidden" name="update" value=");
  $form .= "$ServerIndex_id";
  $form .= q("><input type="submit" class="twikiSubmit" value="Submit" /></form>);
  $twisty_show="show";
  }
else
  {
  $form = <<MENU;
  %TABLE{ sort="off" tablewidth="100%"}%<form name="soft_request_rates" action="%SCRIPTURLPATH{view}%/%WEB%/%TOPIC%" method="post">
| *DataCenter*  | *SysInfo* | *Name* |
 | <input type="text" name="datacenter" value="%URLPARAM{"datacenter" encode="entity"}%" size="60" class="twikiInputField"  /> | <input type="text" name="location" value="%URLPARAM{"location" encode="entity"}%" size="50" class="twikiInputField" /> | <input type="text" name="name" value="%URLPARAM{"name" encode="entity"}%" size="62" class="twikiInputField" /> |
  | *OS*  | *ServerIP1* | *ServerIP2* |
  | <input type="text" name="opsys" value="%URLPARAM{"opsys" encode="entity"}%" size="60" class="twikiInputField" /> | <input type="text" name="serverip1" value="%URLPARAM{"serverip1" encode="entity"}%" size="50" class="twikiInputField" /> | <input type="text" name="serverip2" value="%URLPARAM{"serverip2" encode="entity"}%" size="62" class="twikiInputField" /> |  
  | *iLo* | *Funct* | *HardWare* |
  | <input type="text" name="ilo" value="%URLPARAM{"ilo" encode="entity"}%" size="60" class="twikiInputField" /> | <input type="text" name="soft" value="%URLPARAM{"soft" encode="entity"}%" size="50" class="twikiInputField" /> | <textarea cols="60" rows="3" name="sysinfo" class="twikiInputField">%URLPARAM{"sysinfo" encode="entity"}%</textarea> |
  | *Comments* | ** | ** |  
  | <textarea cols="55" rows="3" name="comments" class="twikiInputField">%URLPARAM{"comments" encode="entity"}%</textarea> |
<input type="hidden" name="insert" value="1">
<input type="submit" class="twikiSubmit" value="Submit" />
</form>
MENU
  }
    	
	if (($ServerIndex_datacenter) and ($ServerIndex_update eq '0'))
	{
	 push(@dump,"%RED%new value - pushed%ENDCOLOR%");
     #my $updated =`date +%Y%m%d%H%M`;
	 #my $updated_untained =~ /(\d+)/;
 	 #`/bin/touch -m $updated_untained $file`;	 
	 
	 #update twiki revision time--------------------------------------------------------------------------vvv
	 my ( $oopsUrl, $loginName, $unlockTime ) = TWiki::Func::checkTopicEditLock( $theWeb, $theTopic );
        if( $oopsUrl ) {
        push(@dump,"%RED%this is being edited by $loginName now. Unlock time: $unlockTime%ENDCOLOR%");
        return;
       } 
	 my $text = TWiki::Func::readTopicText( $theWeb, $theTopic);
	 $oopsUrl = TWiki::Func::saveTopicText( $theWeb, $theTopic, $text );
	 #update twiki revision time--------------------------------------------------------------------------^^^
	 
	
     $sql = "INSERT INTO [HelpDesk].[dbo].[ServerIndex] ([datacenter],[location],[name],[os],[serverip1],[serverip2],[ilo],[soft],[sysinfo],[comments]) VALUES ('$ServerIndex_datacenter','$ServerIndex_location','$ServerIndex_name','$ServerIndex_os','$ServerIndex_serverip1','$ServerIndex_serverip2','$ServerIndex_ilo','$ServerIndex_soft','$ServerIndex_sysinfo','$ServerIndex_comments');";
	
	 my $sth = $dbh->prepare("$sql");
	 $sth->execute();
    }
	
	#push(@dump," -$ServerIndex_update- -$ServerIndex_delete- -$ServerIndex_id- ");
	if ($ServerIndex_update ne '0')
	{
     #my $updated =`date +%Y%m%d%H%M`;
	 #my $updated_untained =~ /(\d+)/;
 	 #`/bin/touch -m $updated_untained $file`;
	 
	 #update twiki revision time--------------------------------------------------------------------------vvv
	 my ( $oopsUrl, $loginName, $unlockTime ) = TWiki::Func::checkTopicEditLock( $theWeb, $theTopic );
        if( $oopsUrl ) {
        push(@dump,"%RED%this is being edited by $loginName now. Unlock time: $unlockTime%ENDCOLOR%");
        return;
       } 
	 my $text = TWiki::Func::readTopicText( $theWeb, $theTopic);
	 $oopsUrl = TWiki::Func::saveTopicText( $theWeb, $theTopic, $text );
	 #update twiki revision time--------------------------------------------------------------------------^^^
	 
	 push(@dump,"%RED%id $ServerIndex_update - updated%ENDCOLOR%");
     $sql = "update [HelpDesk].[dbo].[ServerIndex] set [datacenter]= '$ServerIndex_datacenter' ,[location]='$ServerIndex_location',[name]='$ServerIndex_name',[os]='$ServerIndex_os',[serverip1]='$ServerIndex_serverip1', [serverip2]='$ServerIndex_serverip2', [ilo]='$ServerIndex_ilo', [soft]='$ServerIndex_soft', [sysinfo]='$ServerIndex_sysinfo',[comments]='$ServerIndex_comments', date=getdate() where id = $ServerIndex_update ;";
	 my $sth = $dbh->prepare("$sql");
	 $sth->execute();
	 $twisty_show="hide";
    }
	elsif (($ServerIndex_delete eq '1') and ($ServerIndex_id ne '0'))
	{
	 #update twiki revision time--------------------------------------------------------------------------vvv
	 my ( $oopsUrl, $loginName, $unlockTime ) = TWiki::Func::checkTopicEditLock( $theWeb, $theTopic );
        if( $oopsUrl ) {
        push(@dump,"%RED%this is being edited by $loginName now. Unlock time: $unlockTime%ENDCOLOR%");
        return;
       } 
	 my $text = TWiki::Func::readTopicText( $theWeb, $theTopic);
	 $oopsUrl = TWiki::Func::saveTopicText( $theWeb, $theTopic, $text );
	 #update twiki revision time--------------------------------------------------------------------------^^^
	
	
	 push(@dump,"%RED%id $ServerIndex_id - deleted%ENDCOLOR%");
     $sql = "delete from [HelpDesk].[dbo].[ServerIndex] where id = $ServerIndex_id ;";
	 my $sth = $dbh->prepare("$sql");
	 $sth->execute();
	}
#-----------------------MENU-------------------------------------------------------------------------vvv
	my $twisty=q(%TWISTY{ id="menu" mode="div" start=");
	$twisty.=$twisty_show;
	$twisty.=q(" remember="on" showlink="Show menu&nbsp;" hidelink="Hide menu&nbsp;"
showimgright="%ICONURLPATH{toggleopen-small}%" 
hideimgright="%ICONURLPATH{toggleclose-small}%"}%);
push(@dump,"$twisty");
    $twisty = q(<noautolink>field length - DataCenter: 200, Location: 500, Name: 100, OS: 100, ServerIP1: 150, ServerIP2: 150, iLO: 50, Soft: 200, SysInfo: 1000, Comments: 1000; <br>Sorting - ORDER BY DataCenter, ServerIP1, Date DESC</noautolink>);
    push(@dump,"$twisty");	
	push(@dump,"$form");
	$twisty = q(%ENDTWISTY%);
	push(@dump,"$twisty");
	
	#push (@dump,'<literal><a href="javascript:void(0);" onclick="fnShowHide(11);">Toggle column 11 - "Date"<br></a></literal>');
#-----------------------MENU-------------------------------------------------------------------------^^^
	
	$sql = q(SELECT TOP 1000 [id],[DataCenter],[Location],[Name],[OS],[ServerIP1],[ServerIP2],[iLO],[Soft],[SysInfo],[Comments],CAST(CONVERT(DATETIME, [date], 101) AS date)  FROM [HelpDesk].[dbo].[ServerIndex] ORDER BY DataCenter, ServerIP1, Date DESC;);

	
	#Sort table after inserting or updating---------------------------vvv
    #my $sorting= '';
	#if (($ServerIndex_id ne '') or ($ServerIndex_insert ne '0') or ($ServerIndex_update ne '0'))
	#{
	# $sorting= q(%TABLE{ sort=\"off\" tablewidth=\"100%\"  cellpadding=\"1\" cellspacing=\"0\"  columnwidths=\"2%,5%,3%,10%,3%,4%,4%,4%,15%,15%,15%,6%,1%\"}%);
	#}
	#else
	#{
	 #$sorting= q(%TABLE{ sort=\"on\" tablewidth=\"100%\" cellpadding=\"1\" cellspacing=\"0\"  columnwidths=\"2%,5%,3%,10%,3%,4%,4%,4%,15%,15%,15%,6%,1%\"}%);
	#}
	#Sort table after inserting or updating---------------------------vvv
	
	
	my $sth = $dbh->prepare("$sql");
	$sth->execute();
	
    push(@dump,'<noautolink>');	
	eval
     {
     $SIG{'ALRM'} = sub { die 'Timeout' };
     alarm(120);
	 
	 my $RmSps=qr/\s+$/;
	 my $first_time_flag=1;
	 
	 
	 #----------------------
	 push(@dump, "<literal><table cellspacing='0' id='example' class='display dataTable' cellpadding='0' border='0'><thead><tr></literal><literal><th>id</th><th>DC</th><th>Name</th><th>SysInfo</th><th>OS</th><th>ServerIP1</th><th>ServerIP2</th><th>iLo/iDRAC</th><th>Funct</th><th>HardWare</th><th>Comments</th><th>Date</th><th>X</th></tr></thead><tbody></literal>");
	 #----------------------
	 
     while(my $data = $sth->fetchrow_arrayref) 
     {
	  my $id=@$data[0];
	  
		  
	  @$data[0] = "<literal><a href=\"http://nagios.otkritie.com/twiki/bin/view/OSL/</literal>" . "$theTopic?id=$id" . "<literal>\"></literal>" . "%ICON{wri}%" . '<literal></a><a name="</literal>' . @$data[5] . '<literal>"></a></literal>';
	  @$data[1] =~s/$RmSps//;
	  
	  @$data[3] = '%RED%' .  @$data[3] . '%ENDCOLOR%', if (@$data[4] =~ /linux|RHEL|Debian|RedHat/i );
	  @$data[4] = $twisty2 .  @$data[4] .  $twisty3, if (@$data[4]);
	  @$data[7] = '<literal><a target="_blank" href="https://</literal>' . @$data[7] . '<literal>" title="ilo"></literal>' . @$data[7] . '<literal></a></literal>';	  
      @$data[9] =~s/\n/<br>/g, @$data[9] = $twisty2 .  @$data[9] .  $twisty3, if (@$data[9]); 
	  @$data[10] =~s/\n/<br>/g, @$data[10] = $twisty2 .  @$data[10] .  $twisty3, if (@$data[10]);
	  
	  push(@dump, "<literal><tr><td></literal>");
    
	  
	  push(@dump, "@$data[0]</td><td>@$data[1]</td><td>@$data[3]</td><td>@$data[2]</td><td>@$data[4]</td><td>@$data[5]</td><td>@$data[6]</td><td>@$data[7]</td><td>@$data[8]</td><td>@$data[9]</td><td>@$data[10]</td><td>@$data[11]</td>");
	  
	  
	  push(@dump, "<literal><td align=\"center\"><a href=\"javascript:decision(\'Are you shure?\', \'http://nagios.otkritie.com/twiki/bin/view/OSL/</literal>" . "$theTopic?id=$id&delete=1" . "<literal>\')\"></literal>" . '%ICON{choice-no}%' . "<literal></a></td></tr></literal>");
      }
      alarm(0);
     };
	 push(@dump, "<literal></tbody></table></literal>");
	 push(@dump,'</noautolink>');
	 
my $jscript= <<JAVA_SCRIPT;
<!-- <pre> -->
<SCRIPT LANGUAGE="Javascript">
<!---
function decision(message, url){
if(confirm(message)) location.href = url;
}
// --->
</SCRIPT>
</script>
<!-- </pre> -->
JAVA_SCRIPT
push(@dump,"$jscript");

return "@dump";

}
