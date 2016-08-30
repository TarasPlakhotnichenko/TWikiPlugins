package TWiki::Plugins::SoftRequestRatesNewPlugin;
use strict;
use DBI;
use vars qw( $VERSION $RELEASE $SHORTDESCRIPTION $debug $pluginName $NO_PREFS_IN_TOPIC );
$VERSION = '$Rev: 2 (2013-09-03) $';
$RELEASE = '2013-03-27';

$SHORTDESCRIPTION = 'Soft RequestRates plugin';
$NO_PREFS_IN_TOPIC = 0;
$pluginName = 'SoftRequestRatesNewPlugin';



#SELECT *   FROM [HelpDesk].[dbo].[SoftRequestRates_new] where [date] > '2013-04-23' and [software] <>  'Quik Terminal'

sub initPlugin {
    my( $topic, $web, $user, $installWeb ) = @_;
	TWiki::Func::registerTagHandler( 'SoftRequestRatesNew', \&_SoftRequestRatesNew );
    return 1;
}


sub _SoftRequestRatesNew {
    my($session, $params, $theTopic, $theWeb) = @_;
    my $sql = '';
    my $data_source = q/dbi:ODBC:mssql_68/;
    my $user = q/nagios/;
    my $password = q/Nag4Read/;
	my $dbh = DBI->connect($data_source, $user, $password);

	$dbh->{'LongTruncOk'} = 1;
    $dbh->{'LongReadLen'} = 200;

	my $id = $params->{id} || '';
	my $clnt = $params->{clnt} || '';	
	my $software = $params->{software} || '';
	my $accnt = $params->{accnt} || '';	
	my $lgn = $params->{lgn} || '';
	my $pswd = $params->{pswd} || '';
	my $or_md = $params->{or_md} || '';
	my $add_info = $params->{add_info} || '';
	my $ip_svc = $params->{ip_svc} || '';
	my $ip_trgt_svc = $params->{ip_trgt_svc} || '';
	my $fix_cnct_info = $params->{fix_cnct_info} || '';
	my $dc = $params->{dc} || '';
	my $expiry_date = $params->{expiry_date} || '';
	
	my $begin_date = $params->{begin_date} || '';
	my $once = $params->{once} || '';	
	my $monthly = $params->{monthly} || '';		
	my $currency = $params->{currency} || '';
	my $syncid =  $params->{syncid} || '';
	
	my $insert = $params->{insert} || '0';
	my $update = $params->{update} || '0';
	my $delete = $params->{delete} || '0';
	#my $top = $params->{top} || '';
	my $page = $params->{page} || '0';
	my $search = $params->{search} || '';	
	my @dump=();
	my $twisty_show='hide';
	my $form = '';
	my $today =`date +%Y-%m-%d`;
	
	my $rows_for_page = 100;
	
	#remove spaces and carridge returns-----vvv
	$software =~s/\s+$//;
	$software =~s/\n/<BR>/g;
	$software =~s/\|/\&verbar\;/g;
	
	$accnt =~s/\|/\&verbar\;/g;
	
	$clnt =~s/\s+$//;
	$clnt =~s/\n/<BR>/g;
	$clnt =~s/\|/\&verbar\;/g;
	
	$or_md =~s/\s+$//;
	$or_md =~s/\n/<BR>/g;
	$or_md =~s/\|/\&verbar\;/g;
	#remove spaces and carridge returns-----^^^
		
	
    #push(@dump," -$update- | -$delete- | -$id- ");	

    if  (($delete eq '0') and !($id eq ''))
	{
	
	
#------------sql request for edit menu--------------------------------------------------------vvv
	#$sql = qq(SELECT [id],[clnt],[accnt],[lgn],[pswd],[or_md],[add_info],[ip_svc],[ip_trgt_svc],[fix_cnct_info],[dc],CAST(CONVERT(DATETIME, [end_date], 111) AS date) as [end_date], [id_software]  FROM [HelpDesk].[dbo].[SoftRequestRates_new] where id=$id;);
	$sql = qq(SELECT [id],[clnt],[accnt],[lgn],[pswd],[or_md],[add_info],[ip_svc],[ip_trgt_svc],[fix_cnct_info],[dc],CAST(CONVERT(DATETIME, [end_date], 111) AS date) as [end_date], [id_software], CAST(CONVERT(DATETIME, [begin_date], 111) AS date) as [begin_date], [monthly], [once], [currency],[uniquesyncID]  FROM [HelpDesk].[dbo].[SoftRequestRates_new] where id=$id;);    
	my $sth = $dbh->prepare("$sql");
	$sth->execute();
	
	my $clnt='';
	#my $software='';
	my $accnt='';
	my $lgn='';
	my $pswd='';
	my $or_md='';
	my $add_info='';
	my $ip_svc='';
	my $ip_trgt_svc='';
	my $fix_cnct_info='';
	my $dc='';
    my $expiry_date='';
    my $id_software='';
    my $begin_date='';
    my $once='';
    my $monthly='';
    my $currency='';
    my $syncid='';	
	
	if (my $data = $sth->fetchrow_arrayref)
	 {
	  
	  @$data[1] =~s/\s+$//;
	  @$data[1] =~s/\|/\&verbar\;/g;
	  
	  @$data[3] =~s/\|/\&verbar\;/g, if (@$data[3]);
	  @$data[4] =~s/\|/\&verbar\;/g, if (@$data[4]);
	  
	  if (@$data[9]) {
  	  @$data[9] =~s/\s+$//;
	  @$data[9] =~s/\|/\&verbar\;/g;
	  }
	  
	  if (@$data[1]) {$clnt=@$data[1]};
	  #if (@$data[2]) {$software=@$data[2]};
	  if (@$data[2]) {$accnt=@$data[2]};	  
	  if (@$data[3]) {$lgn=@$data[3]};
	  if (@$data[4]) {$pswd=@$data[4]};
	  if (@$data[5]) {$or_md=@$data[5]};
	  if (@$data[6]) {$add_info=@$data[6]};
	  if (@$data[7]) {$ip_svc=@$data[7]};	  
	  if (@$data[8]) {$ip_trgt_svc=@$data[8]};
	  if (@$data[9]) {$fix_cnct_info=@$data[9]};	  
	  if (@$data[10]) {$dc=@$data[10]};
      if (@$data[11]) {$expiry_date=@$data[11]};
	  if (@$data[12]) {$id_software=@$data[12]};

	  if (@$data[13]) {$begin_date=@$data[13]};
	  if (@$data[14]) {$monthly=@$data[14]};
	  if (@$data[15]) {$once=@$data[15]} else {$once=0};	  
	  if (@$data[16]) {$currency=@$data[16]};
	  if (@$data[17]) {$syncid=@$data[17]};	  
	  
      $sth->finish;	  
	 }
	 
#------------sql request for edit menu--------------------------------------------------------^^^

#------------sql request for dropdown list in edit  menu--------------------------------------vvv
$sql = qq(SELECT [id],[software],[disabled]  FROM [HelpDesk].[dbo].[SoftRequestRatesPrice] where disabled = 0;);    
$sth = $dbh->prepare("$sql");
$sth->execute();

my %dropdown_menu_hash = ();
while(my $data_dropdown = $sth->fetchrow_arrayref)
{
 $dropdown_menu_hash{ @$data_dropdown[0] } = @$data_dropdown[1];
}

my $dropdown_menu = '<select name="software"  width="340" style="width: 340px">';
foreach my $key (sort { $dropdown_menu_hash{$a} cmp $dropdown_menu_hash{$b} } keys %dropdown_menu_hash) {
my $value = $dropdown_menu_hash{$key};
$dropdown_menu .= '<option value="' . $key . '">' . $value . "</option>";
}

$dropdown_menu .= '<option selected value="' . $id_software . '">' . $dropdown_menu_hash{$id_software}  . "</option>";
$dropdown_menu .= '</select>';

$sth->finish;

#<pre><select name="software">
#<option value="1">Fresh Milk</option>
#<option value="2">Old Cheese</option>
#<option selected value="3">Hot Bread</option>
#</select><pre> 

#SELECT  t1.[id],t1.[clnt],t2.[software],t1.[lgn],t1.[pswd],t1.[or_md],t1.[add_info],t1.[ip_svc],t1.[ip_trgt_svc],t1.[fix_cnct_info],t1.[dc],t1.[date],t1.[accnt],t1.[id_quik],t1.[end_date],t1.[disabled],t1.[id_software]  FROM [HelpDesk].[dbo].[SoftRequestRates_new]  as t1 left join [HelpDesk].[dbo].[SoftRequestRatesPrice] as t2  on (t1.id_software=t2.id);


#------------sql request for dropdown list in edit  menu--------------------------------------^^^	
	
 $form = q(<noautolink>%TABLE{ sort="off" tablewidth="100%" headeralign="left" tableborder="0" cellpadding="1" cellspacing="0"}%<form name="soft_request_rates" action="%SCRIPTURLPATH{view}%/%WEB%/%TOPIC%" method="post">
| *Client name*  | *Software* | *Account* | 
| <literal><input type="text" name="clnt" value=");
 $form .= "$clnt"; 
 $form .= q(" size="50" class="twikiInputField"></literal> | <literal>);
 $form .= "$dropdown_menu";
 $form .= q(</literal> | <literal><input type="text" name="accnt" value=");
 
 $form .=  "$accnt";
 $form .= q(" size="50" class="twikiInputField" /></literal> | 
| *Login*  | *Password* | *OR/MD* | 
| <literal><input type="text" name="lgn" value=");
 $form .=  "$lgn";
 $form .= q(" size="50" class="twikiInputField" /></literal> | <literal><input type="text" name="pswd" value=");
 $form .= "$pswd";
 $form .= q(" size="50" class="twikiInputField" /></literal> | <literal><input type="text" name="or_md" value=");
 $form .= "$or_md";

 $form .= q(" size="50" class="twikiInputField" /></literal> | 
| *Additional info* |*IP of service* | *Target IP of service* |
| <literal><input type="text" name="add_info" value=");
 $form .= "$add_info";
 $form .= q(" size="50" class="twikiInputField" /></literal> | <literal><input type="text" name="ip_svc" value=");
 $form .= "$ip_svc";
 $form .= q(" size="50" class="twikiInputField" /></literal> | );
 $form .= q( <literal><input type="text" name="ip_trgt_svc" value=");
 $form .= "$ip_trgt_svc";
 $form .= q(" size="50" class="twikiInputField" /></literal> |);
  
 $form .= q( 
  | *Fix_conect_info* | *Data center* | *Start date/Expiry date* |
  | <literal><textarea cols="50" rows="3" name="fix_cnct_info" class="twikiInputField" />);
 $form .= "$fix_cnct_info";
 $form .= q(</textarea></literal> |);
 $form .= q( <literal><input type="text" name="dc" value=");
 $form .= "$dc";
 $form .= q(" size="50" class="twikiInputField" /></literal> | );
  
 $form .= q( <input type="text" size="12" name="begin_date" id="cal_val_here" value=");
 $form .= "$begin_date";
 $form .= q("><input type="image" src="%PUBURL%/%SYSTEMWEB%/JSCalendarContrib/img.gif" onclick="javascript: return showCalendar\('cal_val_here','%Y-%m-%d'\)" />&nbsp;&nbsp;<input type="text" size="12" name="expiry_date" id="cal_val_here2" value="); 
 $form .= "$expiry_date";
 $form .= q("><input type="image" src="%PUBURL%/%SYSTEMWEB%/JSCalendarContrib/img.gif" onclick="javascript: return showCalendar\('cal_val_here2','%Y-%m-%d'\)" /> | 
 );
 



 
 $form .= q(  | *Once* | *Monthly* | *Currency* | 
 | );

 $form .= q( <literal><input type="text" name="once" value=");
 $form .= "$once";
 $form .= q(" size="50" class="twikiInputField" /></literal> | );
  
 $form .= q( <literal><input type="text" name="monthly" value=");
 $form .= "$monthly";
 $form .= q(" size="50" class="twikiInputField" /></literal> |  );
 
 
 
 $form .= q( <literal><input type="text" name="currency" value=");
 $form .= "$currency";
 $form .= q(" size="50" class="twikiInputField" /></literal> | 
 );
 
 $form .= q(| *UniqsyncID* | ** | ** |  | 
 );
 
 $form .= q( | <literal><input type="text" name="syncid" value=");
 $form .= "$syncid";
 $form .= q(" size="50" class="twikiInputField" /></literal>  | | |
 );
 
 
 
 $form .= q(<input type="hidden" name="update" value="); 
 $form .= "$id";
 $form .= q("><input type="hidden" name="page" value=");
 $form .= "$page";
 
 $form .= q("><input type="hidden" name="search" value=");
 $form .= "$search";
 
 $form .= q("><input type="submit" class="twikiSubmit" value="Submit" /></form></noautolink>);
 $twisty_show="show";
  }
else
  {
  
#------------sql request for dropdown list in edit  menu--------------------------------------vvv
$sql = qq(SELECT [id],[software],[disabled]  FROM [HelpDesk].[dbo].[SoftRequestRatesPrice]  where disabled = 0 ;);    
my $sth = $dbh->prepare("$sql");
$sth->execute();

my %dropdown_menu_hash = ();
while(my $data_dropdown = $sth->fetchrow_arrayref)
{
 $dropdown_menu_hash{ @$data_dropdown[0] } = @$data_dropdown[1];
}

my $dropdown_menu = '<select name="software" width="340" style="width: 340px">';
foreach my $key (sort { $dropdown_menu_hash{$a} cmp $dropdown_menu_hash{$b} } keys %dropdown_menu_hash) {
my $value = $dropdown_menu_hash{$key};
$dropdown_menu .= '<option value="' . $key . '">' . $value . "</option>";
}


if ($software) 
{
$dropdown_menu .= '<option selected value="%URLPARAM{"software" encode="entity"}%">' . $dropdown_menu_hash{$software}  . "</option>";
}

$dropdown_menu .= '</select>';

$sth->finish;
#------------sql request for dropdown list in edit  menu--------------------------------------^^^
  
$form = q(<noautolink>
  %TABLE{ sort="off" tablewidth="100%" headeralign="left" tableborder="0" cellpadding="1" cellspacing="0"}%<form name="soft_request_rates" action="%SCRIPTURLPATH{view}%/%WEB%/%TOPIC%" method="post">
| *Client name*  | *Software* | *Account* |
 | <input type="text" name="clnt" value="%URLPARAM{"clnt" encode="entity"}%" size="50" class="twikiInputField"  /> |);

$form .= $dropdown_menu ;

$form .=  q( | <input type="text" name="accnt" value="%URLPARAM{"accnt" encode="entity"}%" size="50" class="twikiInputField" /> |
  | *Login*  | *Password* | *OR/MD* |
  | <input type="text" name="lgn" value="%URLPARAM{"lgn" encode="entity"}%" size="50" class="twikiInputField" /> | <input type="text" name="pswd" value="%URLPARAM{"pswd" encode="entity"}%" size="50" class="twikiInputField" /> | <input type="text" name="or_md" value="%URLPARAM{"or_md" encode="entity"}%" size="50" class="twikiInputField" /> |  
  | *Additional info* | *IP of service* | *Target IP of service* |
  | <input type="text" name="add_info" value="%URLPARAM{"add_info" encode="entity"}%" size="50" class="twikiInputField" /> |  <input type="text" name="ip_svc" value="%URLPARAM{"ip_svc" encode="entity"}%" size="50" class="twikiInputField" /> | <input type="text" name="ip_trgt_svc" value="%URLPARAM{"ip_trgt_svc" encode="entity"}%" size="50" class="twikiInputField" /> |
  | *Fix_conect_info* | *Data center* | *Start date* |  
  | <textarea cols="50" rows="3" name="fix_cnct_info" class="twikiInputField">%URLPARAM{"fix_cnct_info" encode="entity"}%</textarea> | <input type="text" name="dc" value="%URLPARAM{"dc" encode="entity"}%" size="50" class="twikiInputField" /> | <input type="text" size="12" name="begin_date" id="cal_val_here" /><input type="image" src="%PUBURL%/%SYSTEMWEB%/JSCalendarContrib/img.gif" onclick="javascript: return showCalendar('cal_val_here','%Y-%m-%d')" /> |
  | *UniqsyncID* | ** | ** |  
  | <input type="text" name="syncid" value="%URLPARAM{"syncid" encode="entity"}%" size="50" class="twikiInputField" /> |  |  |
<input type="hidden" name="insert" value="1">
<input type="submit" class="twikiSubmit" value="Submit" /><input type="hidden" name="search" value="%URLPARAM{"search" encode="entity"}%">
</form>
</noautolink>);

  }
		
	if (($clnt) and ($update eq '0'))
	{
	 push(@dump,"%RED%new value -$clnt- pushed%ENDCOLOR% "); 
	 
	 unless ($begin_date)
	 {
     $sql = "INSERT INTO [HelpDesk].[dbo].[SoftRequestRates_new] ([clnt],[id_software],[accnt],[lgn],[pswd],[or_md],[add_info],[ip_svc],[ip_trgt_svc],[fix_cnct_info],[dc],[end_date],[begin_date],[uniquesyncID]) VALUES ('$clnt','$software','$accnt','$lgn','$pswd','$or_md','$add_info','$ip_svc','$ip_trgt_svc','$fix_cnct_info','$dc', NULL, MULL,'$syncid' );";
	 }
	 else
	 {
	 $sql = "INSERT INTO [HelpDesk].[dbo].[SoftRequestRates_new] ([clnt],[id_software],[accnt],[lgn],[pswd],[or_md],[add_info],[ip_svc],[ip_trgt_svc],[fix_cnct_info],[dc],[end_date],[begin_date],[uniquesyncID]) VALUES ('$clnt','$software','$accnt','$lgn','$pswd','$or_md','$add_info','$ip_svc','$ip_trgt_svc','$fix_cnct_info','$dc',NULL, '$begin_date','$syncid');";
	 }

	 my $sth = $dbh->prepare("$sql");
	 $sth->execute();
    }
	
	#push(@dump," -$update- -$delete- -$add_info- ");
	
	if ($update ne '0')
	{
	 push(@dump,"%RED%id $update - updated%ENDCOLOR%");
	 
	 unless ($expiry_date)
	 {
	 $sql = "update [HelpDesk].[dbo].[SoftRequestRates_new] set [clnt]= '$clnt' ,[id_software]='$software',[accnt]='$accnt',[lgn]='$lgn',[pswd]='$pswd',[or_md]='$or_md',[add_info]='$add_info',[ip_svc]='$ip_svc',[ip_trgt_svc]='$ip_trgt_svc',[fix_cnct_info]='$fix_cnct_info',[dc]='$dc', [end_date]=NULL, [begin_date]='$begin_date', [once]='$once', [monthly]='$monthly', [currency]='$currency', date=getdate(),[uniquesyncID]='$syncid' where id = $update ;";
	 }
	 else
	 {
	 $sql = "update [HelpDesk].[dbo].[SoftRequestRates_new] set [clnt]= '$clnt' ,[id_software]='$software',[accnt]='$accnt',[lgn]='$lgn',[pswd]='$pswd',[or_md]='$or_md',[add_info]='$add_info',[ip_svc]='$ip_svc',[ip_trgt_svc]='$ip_trgt_svc',[fix_cnct_info]='$fix_cnct_info',[dc]='$dc', [end_date]='$expiry_date',[begin_date]='$begin_date', [once]='$once', [monthly]='$monthly', [currency]='$currency', date=getdate(),[uniquesyncID]='$syncid' where id = $update ;";
	 }
	 #push(@dump," -$sql- ");
	 my $sth = $dbh->prepare("$sql");
	 $sth->execute();
    }
	
#++++++++++++++++++++++++++++++++++++++	
	elsif (($delete eq '1') and ($id ne '0'))
	{
	 push(@dump,"%RED%id $id - deleted%ENDCOLOR%");
     $sql = "delete from [HelpDesk].[dbo].[SoftRequestRates_new] where id = $id ;";
	 my $sth = $dbh->prepare("$sql");
	 $sth->execute();
	}
	
	
#-----------------------MENU-------------------------------------------------------------------------vvv

my $search_form = <<SEARCH_FORM;
<form name="topic_search" action="%SCRIPTURLPATH{view}%/%WEB%/%TOPIC%" method="post"><literal><input type="text" name="search" value="%URLPARAM{"search" encode="entity"}%" size="50" class="twikiInputField" /></literal>&nbsp;<input type="submit" class="twikiSubmit" value="Search" /></form>&nbsp;&nbsp;&nbsp; Note: '+' = 'OR' condition applied to each column. Example: Quik Terminal + abc ; Double click within field = filter the table; Export to text file: [[SoftRequestRatesExport]]

SEARCH_FORM

push(@dump,"$search_form\n\n");

	my $twisty=q(%TWISTY{ id="menu" mode="div" start=");
	$twisty.=$twisty_show;
	$twisty.=q(" remember="on" showlink="Show edit menu&nbsp;" hidelink="Hide menu&nbsp;"
showimgright="%ICONURLPATH{toggleopen-small}%" 
hideimgright="%ICONURLPATH{toggleclose-small}%"}%);
push(@dump,"$twisty");
    $twisty = q(<noautolink>field length - Client name:100; Software:500; Account:200; Login:200; Password:100; OR/MD:100; Additional info:500; Ip of service:100; Target ip of service: 100; Fix_conect_info: 500; Data center:100 <br>Sorting - ORDER BY Client Name, id DESC</noautolink>);
    push(@dump,"$twisty");	
	push(@dump,"$form");
	$twisty = q(%ENDTWISTY%);
	push(@dump,"$twisty");
#-----------------------MENU-------------------------------------------------------------------------^^^
    
	


    #SELECT   count(t1.id)  FROM [HelpDesk].[dbo].[SoftRequestRates_new]  as t1 left join [HelpDesk].[dbo].[SoftRequestRatesPrice] as t2  on (t1.id_software=t2.id);
	#push(@dump,"$search");
	
	my @singles = ();
	if ($search)
	{
	
	$rows_for_page = 300;
	
	#----------google like search--------vvv
	if ($search =~m/.*\+.*/i) {
	
	 @singles = split('\+', $search);
	 $sql = 'SELECT   COUNT(t1.id)  FROM [HelpDesk].[dbo].[SoftRequestRates_new]  as t1 left join [HelpDesk].[dbo].[SoftRequestRatesPrice] as t2  on (t1.id_software=t2.id) where t1.clnt like \'%';
	  $singles[0] =~s/\s+$//;
	  $sql .= $singles[0] . '%\'';
	
	  for (my $i=1;$i <= $#singles; $i++) {
	    $singles[$i] =~s/\s+$//;
		$singles[$i] =~s/^\s+//;
	    $sql .= ' or t1.clnt like \'%' . "$singles[$i]" . '%\'';
	   }
	
	 for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t2.software like \'%' . "$singles[$i]" . '%\'';
	   }
	   
	  for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t1.lgn like \'%' . "$singles[$i]" . '%\'';
	   }

      for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t1.add_info like \'%' . "$singles[$i]" . '%\'';
	   }

      for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t1.dc like \'%' . "$singles[$i]" . '%\'';
	   }

      for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t1.ip_svc like \'%' . "$singles[$i]" . '%\'';
	   }

       for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t1.ip_trgt_svc like \'%' . "$singles[$i]" . '%\'';
	   }

	   for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t1.accnt like \'%' . "$singles[$i]" . '%\'';
	   }

	   
       for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t1.fix_cnct_info like \'%' . "$singles[$i]" . '%\'';
	   }	   
	  $sql .= ';';
	  #push(@dump,"$sql\n\n");

	
	}
	#----------google like search--------^^^
	else
	{
	
	#----------ordinary    search--------vvv
	$sql = 'SELECT   COUNT(t1.id) as count  FROM [HelpDesk].[dbo].[SoftRequestRates_new]  as t1 left join [HelpDesk].[dbo].[SoftRequestRatesPrice] as t2  on (t1.id_software=t2.id) where t1.clnt like \'%';
	
	$sql .= $search . '%\'';
	$sql .= ' or t2.software like \'%' . "$search" . '%\'';
	$sql .= ' or t1.lgn like \'%' . "$search" . '%\'';
	$sql .= ' or t1.add_info like \'%' . "$search" . '%\'';
	$sql .= ' or t1.dc like \'%' . "$search" . '%\'';
	$sql .= ' or t1.ip_svc like \'%' . "$search" . '%\'';
	$sql .= ' or t1.ip_trgt_svc like \'%' . "$search" . '%\'';
	$sql .= ' or t1.accnt like \'%' . "$search" . '%\'';
	$sql .= ' or t1.fix_cnct_info like \'%' . "$search" . '%\'';	 
	$sql .= ';';
	
	#----------ordinary    search--------^^^
	 }
	}
	else
	{
	 #$sql = 'SELECT COUNT(id) FROM [HelpDesk].[dbo].[SoftRequestRates_new]';
	 $sql = 'SELECT   count(t1.id)  FROM [HelpDesk].[dbo].[SoftRequestRates_new]  as t1 left join [HelpDesk].[dbo].[SoftRequestRatesPrice] as t2  on (t1.id_software=t2.id);';
	}
	
	
    my $sth = $dbh->prepare("$sql");
	$sth->execute();
	
	
	
	my $data = $sth->fetchrow_arrayref;
	my $max_rows=@$data[0];
	#push(@dump,"$sql");
	push(@dump,"Pages: ");
	my $page_num=$max_rows / $rows_for_page;
	my $remainder=$max_rows % $rows_for_page;
	for (my $i = 0; $i <= $page_num; $i++) 
	{
	my $encoded_search=$search;
	$encoded_search=~s/\+/%2b/;
	if ($i == $page)
	{
	
	push(@dump,"[[http://nagios.otkritie.com/twiki/bin/view/OSL/$theTopic?page=$i&search=$encoded_search][(%RED%$i%ENDCOLOR%)]]");
	
	}
	else
	{
	push(@dump,"[[http://nagios.otkritie.com/twiki/bin/view/OSL/$theTopic?page=$i&search=$encoded_search][($i)]]");
	}
	}
	push(@dump,"; Selected: %RED%$max_rows%ENDCOLOR%; ");
	push(@dump,'<literal><a href="javascript:void(0);" onclick="fnShowHide(14);">Toggle the last column X - show/hide<br></a></literal>'); 
	
	my $pager=$page*$rows_for_page;
	
	# the second param "top" alters as following: 0 100 200 ... 
	#SELECT  top 100 t1.[id],t1.[clnt],t2.[software],t1.[accnt],t1.[lgn],t1.[pswd],t1.[or_md],t1.[add_info],t1.[ip_svc],t1.[ip_trgt_svc],t1.[fix_cnct_info],t1.[dc],CAST(CONVERT(DATETIME, t1.[date], 101) AS date)  as [date],t1.[id_quik], CAST(CONVERT(DATETIME, t1.[end_date], 101) AS date) as [end_date],t1.[disabled]  FROM [HelpDesk].[dbo].[SoftRequestRates_new]  as t1 left join [HelpDesk].[dbo].[SoftRequestRatesPrice] as t2  on (t1.id_software=t2.id)   where t1.[id] NOT IN ( select  top 100 t1.[id] FROM [HelpDesk].[dbo].[SoftRequestRates_new]  as t1 left join [HelpDesk].[dbo].[SoftRequestRatesPrice] as t2  on (t1.id_software=t2.id) order by t1.clnt,t1.id ) order by t1.clnt,t1.id;
	
	
	if ($search)
	{
	
	  #----------google like search--------vvv
	  
	  if ($search =~m/.*\+.*/i) {
  
	  
	   $sql = 'SELECT  top 300 t1.[id],t1.[clnt],t2.[software],t1.[accnt],t1.[lgn],t1.[pswd],t1.[or_md],t1.[add_info],t1.[ip_svc],t1.[ip_trgt_svc],t1.[fix_cnct_info],t1.[dc],CAST(CONVERT(DATETIME, t1.[begin_date], 101) AS date)  as [date],t1.[id_quik], CAST(CONVERT(DATETIME, t1.[end_date], 101) AS date) as [end_date],t1.[disabled]  FROM [HelpDesk].[dbo].[SoftRequestRates_new]  as t1 left join [HelpDesk].[dbo].[SoftRequestRatesPrice] as t2  on (t1.id_software=t2.id)   where t1.[id] NOT IN ( select  top ';
	 
	   $sql .= $pager;
	   $sql .= ' t1.[id] FROM [HelpDesk].[dbo].[SoftRequestRates_new]  as t1 left join [HelpDesk].[dbo].[SoftRequestRatesPrice] as t2  on (t1.id_software=t2.id) where  t1.clnt like \'%';
	   $sql .= $singles[0] . '%\'';
	   
	  for (my $i=1;$i <= $#singles; $i++) {
	    $sql .= ' or t1.clnt like \'%' . "$singles[$i]" . '%\'';
	   }
	   
	   for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t2.software like \'%' . "$singles[$i]" . '%\'';
	   }
	  
	  
	   for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t1.lgn like \'%' . "$singles[$i]" . '%\'';
	   }
	  
	   for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t1.add_info like \'%' . "$singles[$i]" . '%\'';
	   }
	  
	   for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t1.dc like \'%' . "$singles[$i]" . '%\'';
	   }
	  
	  
	   for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t1.ip_svc like \'%' . "$singles[$i]" . '%\'';
	   }
	  
	   for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t1.ip_trgt_svc like \'%' . "$singles[$i]" . '%\'';
	   }
	   
	   for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t1.accnt like \'%' . "$singles[$i]" . '%\'';
	   }
	   	  
	   for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t1.fix_cnct_info like \'%' . "$singles[$i]" . '%\'';
	   }
	  	    
	  #---
	   
	   $sql .= ' order by t1.clnt,t1.id ) and ( clnt like \'%';
	   $sql .= $singles[0] . '%\'';
	   
	   for (my $i=1;$i <= $#singles; $i++) {
	    $sql .= ' or t1.clnt like \'%' . "$singles[$i]" . '%\'';
	   }
	  
	   for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t2.software like \'%' . "$singles[$i]" . '%\'';
	   }
	  
	   for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t1.lgn like \'%' . "$singles[$i]" . '%\'';
	   }
	  
	   for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t1.add_info like \'%' . "$singles[$i]" . '%\'';
	   }
	  
	   for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t1.dc like \'%' . "$singles[$i]" . '%\'';
	   }
	  
	   for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t1.ip_svc like \'%' . "$singles[$i]" . '%\'';
	   }
	  
	   for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t1.ip_trgt_svc like \'%' . "$singles[$i]" . '%\'';
	   }
	  
	  
	   for (my $i=0;$i <= $#singles; $i++) {
	    $sql .= ' or t1.fix_cnct_info like \'%' . "$singles[$i]" . '%\'';
	   }
	  
	   
	   $sql .= ') order by t1.clnt,t1.id;';
	   
	   
	  }
	  #----------google like search--------^^^
	  else
	  {
	  
	 #$sql = 'SELECT top 100 [id],[clnt],[accnt],[lgn],[pswd],[or_md],[add_info],[ip_svc],[ip_trgt_svc],[fix_cnct_info],[dc],CAST(CONVERT(DATETIME, [date], 101) AS date)  as [date],[id_quik], CAST(CONVERT(DATETIME, [end_date], 101) AS date) as [end_date],[disabled] FROM [HelpDesk].[dbo].[SoftRequestRates_new]  where ID NOT IN ( select top ';
	 
	 $sql = 'SELECT  top 300 t1.[id],t1.[clnt],t2.[software],t1.[accnt],t1.[lgn],t1.[pswd],t1.[or_md],t1.[add_info],t1.[ip_svc],t1.[ip_trgt_svc],t1.[fix_cnct_info],t1.[dc],CAST(CONVERT(DATETIME, t1.[begin_date], 101) AS date)  as [date],t1.[id_quik], CAST(CONVERT(DATETIME, t1.[end_date], 101) AS date) as [end_date],t1.[disabled]  FROM [HelpDesk].[dbo].[SoftRequestRates_new]  as t1 left join [HelpDesk].[dbo].[SoftRequestRatesPrice] as t2  on (t1.id_software=t2.id)   where t1.[id] NOT IN ( select  top ';
	 
	 $sql .= $pager;
	 $sql .= ' t1.[id] FROM [HelpDesk].[dbo].[SoftRequestRates_new]  as t1 left join [HelpDesk].[dbo].[SoftRequestRatesPrice] as t2  on (t1.id_software=t2.id) where  t1.clnt like \'%';
	 
	 $sql .= $search . '%\'';
	 $sql .= ' or t2.software like \'%' . "$search" . '%\'';
	 $sql .= ' or t1.lgn like \'%' . "$search" . '%\'';
	 $sql .= ' or t1.add_info like \'%' . "$search" . '%\'';
	 $sql .= ' or t1.dc like \'%' . "$search" . '%\'';
	 $sql .= ' or t1.ip_svc like \'%' . "$search" . '%\'';
	 $sql .= ' or t1.ip_trgt_svc like \'%' . "$search" . '%\'';
	 $sql .= ' or t1.fix_cnct_info like \'%' . "$search" . '%\'';	 
	 
	 $sql .= ' order by t1.clnt,t1.id ) and ( clnt like \'%';
	 $sql .= $search . '%\'';
	 $sql .= ' or t2.software like \'%' . "$search" . '%\'';
	 $sql .= ' or t1.lgn like \'%' . "$search" . '%\'';
	 $sql .= ' or t1.add_info like \'%' . "$search" . '%\'';
	 $sql .= ' or t1.dc like \'%' . "$search" . '%\'';
	 $sql .= ' or t1.ip_svc like \'%' . "$search" . '%\'';
	 $sql .= ' or t1.ip_trgt_svc like \'%' . "$search" . '%\'';
	 $sql .= ' or t1.accnt like \'%' . "$search" . '%\'';
	 $sql .= ' or t1.fix_cnct_info like \'%' . "$search" . '%\'';	 
	 $sql .= ') order by t1.clnt,t1.id;';
	 }
	 
	}
	else
	{
	#$sql = qq(SELECT top 100 [id],[clnt],[accnt],[lgn],[pswd],[or_md],[add_info],[ip_svc],[ip_trgt_svc],[fix_cnct_info],[dc],CAST(CONVERT(DATETIME, [date], 101) AS date) as [date],[id_quik], CAST(CONVERT(DATETIME, [end_date], 101) AS date) as [end_date],[disabled] FROM [HelpDesk].[dbo].[SoftRequestRates_new]  where ID NOT IN ( select top $pager id from [HelpDesk].[dbo].[SoftRequestRates_new] order by clnt,id ) order by clnt,id;);
	
	$sql = qq(SELECT  top 100 t1.[id],t1.[clnt],t2.[software],t1.[accnt],t1.[lgn],t1.[pswd],t1.[or_md],t1.[add_info],t1.[ip_svc],t1.[ip_trgt_svc],t1.[fix_cnct_info],t1.[dc],CAST(CONVERT(DATETIME, t1.[begin_date], 101) AS date)  as [date],t1.[id_quik], CAST(CONVERT(DATETIME, t1.[end_date], 101) AS date) as [end_date],t1.[disabled]  FROM [HelpDesk].[dbo].[SoftRequestRates_new]  as t1 left join [HelpDesk].[dbo].[SoftRequestRatesPrice] as t2  on (t1.id_software=t2.id)   where t1.[id] NOT IN ( select  top $pager t1.[id] FROM [HelpDesk].[dbo].[SoftRequestRates_new]  as t1 left join [HelpDesk].[dbo].[SoftRequestRatesPrice] as t2  on (t1.id_software=t2.id) order by t1.clnt,t1.id ) order by t1.clnt,t1.id;);
	
	
	}
	
	#push(@dump, $sql);
	
	#Sort table after inserting or updating---------------------------vvv
    #my $sorting= '';
	#if (($id ne '') or ($insert ne '0') or ($update ne '0'))
	#{
	# $sorting= q(%TABLE{ sort="off" tablewidth="100%" headeralign="left" tableborder="0" cellpadding="1" cellspacing="0" }%);
	 #columnwidths="1%,15%,20%,10%,3%,4%,15%,10%,10%,10%,10%,10%,1%"
	#}
	#else
	#{
	# $sorting= q(%TABLE{ sort="on" tablewidth="100%" headeralign="left" tableborder="0" cellpadding="1" cellspacing="0" }%);

	#}
	#Sort table after inserting or updating---------------------------vvv
    
	#<div style="WORD-BREAK:BREAK-ALL">
	#<div style="overflow-x: auto">
	
    #push(@dump, "%STARTSMALL%<noautolink>\n\n$sorting\n| *id* | *Client name*  | *Software* | *Account* |  *Login* | *Password* | *OR/MD* | *additional info* | *Ip of service* | *Target ip of service* | *Fix_conect_info* | *DC* | *Start* | *Expiry* | *X* |\n");	
	
	push(@dump, "<literal><table cellspacing='0' width=\"100%\" id='example' class='display dataTable' cellpadding='0' border='0' style=\"font-size:95%;\"><thead><tr></literal><literal><th>id</th><th>Client name</th><th>Software</th><th>Account</th><th>Login</th><th>Password</th><th>OR/MD</th><th>AdditionalInfo</th><th>ServiceIP</th><th>TargetIPServ</th><th>FixInfo</th><th>DC</th><th>Start</th><th>Expiry</th><th>X</th></tr></thead><tbody></literal>");
	
	
		
	$sth = $dbh->prepare("$sql");
	#push(@dump, "$sql");
	$sth->execute();
	push(@dump,'<noautolink>');	
	eval
     {
     $SIG{'ALRM'} = sub { die 'Timeout' };
     alarm(120);
	 
	 my $encoded_search=$search;
	 $encoded_search=~s/\+/%2b/;
	 
     while(my $data = $sth->fetchrow_arrayref) 
     {
	  my $id=@$data[0];
  	  
	  unless  (@$data[0]) {@$data[0]=''};
	  unless  (@$data[1]) {@$data[1]=''};
	  unless  (@$data[2]) {@$data[2]=''};
	  unless  (@$data[3]) {@$data[3]=''};
	  unless  (@$data[4]) {@$data[4]=''};
  	  unless  (@$data[5]) {@$data[5]=''};
	  unless  (@$data[6]) {@$data[6]=''};
	  unless  (@$data[7]) {@$data[7]=''};
	  unless  (@$data[8]) {@$data[8]=''};
	  unless  (@$data[9]) {@$data[9]=''};
	  unless  (@$data[10]) {@$data[10]=''};
  	  unless  (@$data[11]) {@$data[11]=''};
	  unless  (@$data[12]) {@$data[12]=''};
  	  unless  (@$data[14]) {@$data[14]=''};
   	  unless  (@$data[15]) {@$data[15]=''};
	  
	  @$data[1] =~s/\s+$//;
	  @$data[1] =~s/\|/\&verbar\;/g;
	  
	  @$data[4] =~s/\|/\&verbar\;/g;
	  @$data[6] =~s/\|/\&verbar\;/g;
	  
	
	  @$data[10]=~s/\n/<br>/g;
	  @$data[11]=~s/\n/<br>/g;
	  
	  
	  @$data[10] = '%TWISTY{start="hide"}%' .  @$data[10] .  '%ENDTWISTY%', if (@$data[10]);
	  
	  
	   
	  
	  if (@$data[13])
	  {
	   @$data[0] = '0';
	  }
	  else
	  {
	   #my $encoded_search=$search;
	   #$encoded_search=~s/\+/%2b/; 
	   @$data[0] = "<literal><a href=\"http://nagios.otkritie.com/twiki/bin/view/OSL/</literal>" . "$theTopic#$id"  .  "<literal>\"></a><a href=\"http://nagios.otkritie.com/twiki/bin/view/OSL/</literal>" . "$theTopic?id=$id;page=$page&search=$encoded_search" . "<literal>\"></literal>" . '%ICON{wri}%' . "<literal></a></literal>";
	   
	   #@$data[0] = '<a name="' . "$id"  .  '"></a>' . "<literal><a href=\"http://nagios.otkritie.com/twiki/bin/view/OSL/</literal>" . "$theTopic?id=$id;page=$page" . "<literal>\"></literal>" . "$id" . "<literal></a></literal>";
	   
	  }
	  
	  
	  
	  
	  #comment out clients who are blocked or expired--------------------vvv
	  if ((@$data[15] eq 'YES') and (@$data[13]))
	  {
	  @$data[1] = '<strike>' . @$data[1] . '</strike>';
	  }
	  elsif (@$data[14])
	  {
	   if (@$data[14] lt $today)
	   {
	    @$data[1] = '<strike>' . @$data[1] . '</strike>';
	   }
	  }
	  #comment out clients who are blocked or expired--------------------^^^
	  
	  #@$data[2] = '<pre style="color:#000000;font-family: Verdana, Helvetica, sans-serif;"><div id="divHeader" style="overflow:auto;width:105px;">' . @$data[2] . '</div></pre>';
	  
	   
      #@$data[10] = '<pre style="color:#000000;font-family: Verdana, Helvetica, sans-serif;"><div id="divHeader" style="overflow:auto;width:105px;">' . @$data[10] . '</div></pre>';
	 
	  #push(@dump, "| ");
	  
	  push(@dump, "<literal><tr><td></literal>");

      push(@dump, join ('<literal></td><td></literal>',@$data[0],@$data[1],@$data[2],@$data[3],@$data[4],@$data[5],@$data[6],@$data[7],@$data[8],@$data[9],@$data[10],@$data[11],@$data[12],@$data[14])); 	  
      
	  if (@$data[13])
	  {
	  push(@dump, "<literal><td align=\"center\"></literal>"  ."%ICON{choice-cancel}%" . "<literal></td></tr></literal>");
	  }
	  else
	  {
	  
	  push(@dump, "<literal><td align=\"center\"><a href=\"javascript:decision(\'The item will be deleted. Are you shure?\', \'http://nagios.otkritie.com/twiki/bin/view/OSL/</literal>" . "$theTopic?id=$id&delete=1&search=$encoded_search" . "<literal>\')\"></literal>" . '%ICON{choice-no}%' . "<literal></a></td></tr></literal>");

      }
	  
	  
     }
      alarm(0);
     };
	 push(@dump, "<literal></tbody></table></literal>");
	 push(@dump, "</noautolink>");
	 #push(@dump, "$sql");
	 
	 
	 my $jscript=q(<!-- <pre> -->
<SCRIPT LANGUAGE="Javascript">
<!---
function decision(message, url){
if(confirm(message)) location.href = url;
}
// --->
</SCRIPT>
<!-- </pre> -->
);
    push(@dump,"$jscript");
	 
	
	return "@dump";
}
