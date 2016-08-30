package TWiki::Plugins::SoftRequestRatesClientsCostPlugin;
use strict;
use DBI;
no strict 'refs';
use vars qw( $VERSION $RELEASE $SHORTDESCRIPTION $debug $pluginName $NO_PREFS_IN_TOPIC );
use Text::Iconv;

$VERSION = '$Rev: 4 (2013-10-14) $';
$RELEASE = '2013-05-10';

$SHORTDESCRIPTION = 'Soft Request Rates Clients Cost plugin';
$NO_PREFS_IN_TOPIC = 0;
$pluginName = 'SoftRequestRatesClientsCostPlugin';


sub initPlugin {
    my( $topic, $web, $user, $installWeb ) = @_;
	TWiki::Func::registerTagHandler( 'SoftRequestRatesClientsCost', \&_SoftRequestRatesClientsCost );
    return 1;
}


sub _SoftRequestRatesClientsCost {
    my($session, $params, $theTopic, $theWeb) = @_;
    my $sql = '';
    my $data_source = q/dbi:ODBC:mssql_68/;
    my $user = q/nagios/;
    my $password = q/Nag4Read/;
	my $dbh = DBI->connect($data_source, $user, $password);
	my $sth = '';

	$dbh->{'LongTruncOk'} = 1;
    $dbh->{'LongReadLen'} = 200;

	my $price_list = $params->{price_list} || 0;
	
	
	
	
#Output  w/o price list-----------------------------------------------------------vvvv

	if ($price_list == 0)
	{
    my @dump=();
	my $page = $params->{page} || '0';
	my $search = $params->{search} || '';
	my $search2 = $params->{search2} || '';
	my $software = $params->{software} || '';
	my $search_form='';
	my $search_form2='';
    
	
	
	my $begin_date = $params->{begin_date} || '';
	my $end_date = $params->{end_date} || '';
	
	my $pager_string='';
	my $data={};
	#my $twisty_show='hide';

	my $form = '';
	my $pager = 0;

    #push(@dump," -$update- | -$delete- | -$id- ");	
	
	
	
	my $descr1 = "Построение отчета по IT . затратам на клиента (необходимо указать название клиента и период построения отчета)";
	my $descr2 = "Просмотр информации по IT-Сервисам (в разрезе по клиентам или по конкретному клиенту и Сервису)";
    #my $converter = Text::Iconv -> new ('WINDOWS-1251','KOI8-R');
	#my $converter = Text::Iconv -> new ("utf-8","koi8-r");
	#my $descr1 = $converter->convert("ОПХБЕР");
	#push(@dump," -$descr1 $descr- ");
	

    
	
#-----------------------MENU-------------------------------------------------------------------------vvv

#------------sql request for dropdown list in software field-----------------vvv
$sql = qq(SELECT [id],[software],[disabled]  FROM [HelpDesk].[dbo].[SoftRequestRatesPrice]  where disabled = 0 ;);    
$sth = $dbh->prepare("$sql");
$sth->execute();

my %dropdown_menu_hash = ();
while(my $data_dropdown = $sth->fetchrow_arrayref)
{
 $dropdown_menu_hash{ @$data_dropdown[0] } = @$data_dropdown[1];
}
$dropdown_menu_hash{ 'x' } = '';

my $dropdown_menu = '<select name="software" width="340" style="width: 340px">';
foreach my $key (sort { $dropdown_menu_hash{$a} cmp $dropdown_menu_hash{$b} } keys %dropdown_menu_hash) {
my $value = $dropdown_menu_hash{$key};
$dropdown_menu .= '<option value="' . $key . '">' . $value . "</option>";
}


if ($software) 
{
$dropdown_menu .= '<option selected value="%URLPARAM{"software" encode="entity"}%">' . $dropdown_menu_hash{$software}  . "</option>";
}
else
{
$dropdown_menu .= '<option selected value="x"}%"></option>';
}

$dropdown_menu .= '</select>';

$sth->finish;
#------------sql request for dropdown list in software field -----------------^^^


$search_form = <<SEARCH_FORM;
%TABLE{ sort="off" tablewidth="100%" headeralign="left" tableborder="0" cellpadding="1" cellspacing="0" columnwidths="15%,15%,15%"}%
<form name="client_search" action="%SCRIPTURLPATH{view}%/%WEB%/%TOPIC%" method="post">
| *Client name*  | *Begin date* | *End date* |
| <input type="text" name="search" value="%URLPARAM{"search" encode="entity"}%" size="50" class="twikiInputField" /> | <input type="text" size="12" name="begin_date" id="cal_val_here0" value="%URLPARAM{"begin_date" encode="entity"}%"/><input type="image" src="%PUBURL%/%SYSTEMWEB%/JSCalendarContrib/img.gif" onclick="javascript: return showCalendar('cal_val_here0','%Y-%m-%d')" /> | <input type="text" size="12" name="end_date" id="cal_val_here1"  value="%URLPARAM{"end_date" encode="entity"}%" /><input type="image" src="%PUBURL%/%SYSTEMWEB%/JSCalendarContrib/img.gif" onclick="javascript: return showCalendar('cal_val_here1','%Y-%m-%d')" /> |
<input type="submit" class="twikiSubmit" value="Search" />
</form> 

SEARCH_FORM


$search_form2 = q(%TABLE{ sort="off" tablewidth="100%" headeralign="left" tableborder="0" cellpadding="1" cellspacing="0" columnwidths="15%,15%,15%"}%
<form name="client_search2" action="%SCRIPTURLPATH{view}%/%WEB%/%TOPIC%" method="post">
| *Client name*  | *Software* |
| <input type="text" name="search2" value="%URLPARAM{"search2" encode="entity"}%" size="50" class="twikiInputField" /> |);
$search_form2 .= $dropdown_menu;
$search_form2 .= q(|
<input type="submit" class="twikiSubmit" value="Search" />
</form>); 


#push(@dump,"$search_form\n\n---"); 
#push(@dump,"$search_form2\n\n");


push(@dump,"<literal><table border=\"0\" width='100%'><tr></literal>");
push(@dump,"<literal><tr><td valign=\"top\" width=\"45%\">$descr1</td><td valign=\"top\" width=\"45%\">$descr2</td></tr><tr><td  valign=\"top\" width=\"45%\"></literal>");
push(@dump,"$search_form"); 
push(@dump,"<literal></td><td valign=\"top\" width=\"45%\"></literal>");
push(@dump,"$search_form2");
push(@dump,"<literal></td></tr></table></literal>\n---");



#-----------------------MENU-------------------------------------------------------------------------^^^


#-----------------------PAGER------------------------------------------------------------------------vvv
#-----------------------SEARCH2------------vvv
if ($software or $search2)
{
    
    if ($software and $search2)
	{
	$sql = 'select COUNT(*) from (select * from [HelpDesk].[dbo].[software_count] as a where a.software like \'';
	$sql .= $dropdown_menu_hash{$software};
	$sql .= '%\' and a.clnt like \'';
	$sql .= $search2;
	$sql .= '%\') as b';
    }
	elsif ($software and !$search2)
	{
	#push(@dump,"$dropdown_menu_hash{$software}\n\n");
	$sql = 'select COUNT(*) from (select * from [HelpDesk].[dbo].[software_count] as a where a.software like \'';
	$sql .= $dropdown_menu_hash{$software};
	$sql .= '%\') as b';
	#push(@dump,"$sql\n\n");
	}
	elsif (!$software and $search2)
	{
	$sql = 'select COUNT(*) from (select * from [HelpDesk].[dbo].[software_count] as a where a.clnt like \'';
	$sql .= $search2;
	$sql .= '%\') as b';
	}
	
	
	$sth = $dbh->prepare("$sql");
	$sth->execute();
	my $data = $sth->fetchrow_arrayref;
	my $max_rows=@$data[0];
	
	my $page_num=$max_rows / 50;
	my $remainder=$max_rows % 50;
	for (my $i = 0; $i <= $page_num; $i++) 
	{
	if ($i == $page)
	{
	$pager_string .="[[http://nagios.otkritie.com/twiki/bin/view/OSL/$theTopic?page=$i&search2=$search2&software=$software][(%RED%$i%ENDCOLOR%)]]";
	}
	else
	{
	$pager_string .="[[http://nagios.otkritie.com/twiki/bin/view/OSL/$theTopic?page=$i&search2=$search2&software=$software][($i)]]";
	}
	}
	
	push(@dump,"Pages: $pager_string");
	push(@dump,"; Selected: %RED%$max_rows%ENDCOLOR%\n");
	
	$pager=$page*50;

}
#-----------------------SEARCH2------------^^^
else
#-----------------------SEARCH-------------vvv
{
   
	if ($search and $begin_date and $end_date)
	{
	#$sql = 'select COUNT(num) from [HelpDesk].[dbo].otchetzaperiodfunc(\'';
    #$sql .= $begin_date . '\',\'' . $end_date . '\',\'' . $search . '\')';
	
	$sql = 'select COUNT(*)   from (select row_number() OVER (order by t.total) AS num, * from (select distinct  clnt, software as \'DMA Service\', COUNT(software) over (partition by software, or_md, vendor) as \'Count \',or_md as \'OR/MD\', SUM(cost) over (partition by software, or_md, vendor) as \'Total\',vendor as \'Vendor of Service\',CostAllocation as \'To be debited\' from [HelpDesk].[dbo].Client_otchet_test(\'';
    $sql .= $begin_date . '\',\'' . $end_date . '\',\'' . $search . '\')) as t ) as b';
	
	
    }
	elsif ($search or $begin_date or $end_date)
	{
	}
    else
	{
     $sql = 'select  COUNT(*) from (select * from [HelpDesk].[dbo].[software_count] as a) as b';
	}
	
	
	if (($search and $begin_date and $end_date) or !($search or $begin_date or $end_date))
	{
    $sth = $dbh->prepare("$sql");
	$sth->execute();
	my $data = $sth->fetchrow_arrayref;
	my $max_rows=@$data[0];
	
	my $page_num=$max_rows / 50;
	my $remainder=$max_rows % 50;
	for (my $i = 0; $i <= $page_num; $i++) 
	{
	if ($i == $page)
	{
	$pager_string .="[[http://nagios.otkritie.com/twiki/bin/view/OSL/$theTopic?page=$i&search=$search&begin_date=$begin_date&end_date=$end_date][(%RED%$i%ENDCOLOR%)]]";
	#push(@dump,"[[http://nagios.otkritie.com/twiki/bin/view/OSL/$theTopic?page=$i&search=$search&begin_date=$begin_date&end_date=$end_date][(%RED%$i%ENDCOLOR%)]]");
	}
	else
	{
	$pager_string .="[[http://nagios.otkritie.com/twiki/bin/view/OSL/$theTopic?page=$i&search=$search&begin_date=$begin_date&end_date=$end_date][($i)]]";
	#push(@dump,"[[http://nagios.otkritie.com/twiki/bin/view/OSL/$theTopic?page=$i&search=$search&begin_date=$begin_date&end_date=$end_date][($i)]]");
	}
	}
	
	push(@dump,"Pages: $pager_string");
	push(@dump,"; Selected: %RED%$max_rows%ENDCOLOR%\n");
	
	$pager=$page*50;
	}
	else
	{
	push(@dump,"Selected: %RED% 0; All fields should be filled%ENDCOLOR%\n");
	}
}
#-----------------------SEARCH------------^^^

#-----------------------PAGER------------------------------------------------------------------------^^^



#-----------------------MAIN SQL---------------------------------------------------------------------vvv

#-----------------------SEARCH2------------vvv
if ($software or $search2)
{
    push(@dump,q(<noautolink>%TABLE{ sort="on" tablewidth="100%" headeralign="left" dataalign="left" tableborder="0" cellpadding="1" cellspacing="0" columnwidths="20%,30%,20%,20%,10%"}%));
	
    push(@dump, "\n\n| *Client name*  | *Software* | *Market* | *OR/MD* | *Software count* |\n");
	
	#push(@dump, "<noautolink><literal><table cellspacing='0' width=\"100%\" class='display dataTable' cellpadding='0' border='0' style=\"font-size:95%;\"><thead><tr></literal><literal><th>Client name</th><th>Software</th><th>OR/MD</th><th>Software count</th></tr></thead><tbody></literal>");
	
	
	if ($software and $search2)
	{
	$sql = 'select top 50 * from (select row_number() OVER (order by clnt) as num, clnt, software, market, or_md, software_count from [HelpDesk].[dbo].[software_count] as a where a.software like \'';
	$sql .= $dropdown_menu_hash{$software};
	$sql .= '%\' and a.clnt like \'';
	$sql .= $search2;
	$sql .= '%\') as b where b.num > ';
	$sql .= $pager;
    }
	elsif ($software and !$search2)
	{
	
	$sql = 'select top 50 * from (select row_number() OVER (order by clnt) as num, clnt, software, market, or_md,software_count from [HelpDesk].[dbo].[software_count] as a where a.software like \'';
	$sql .= $dropdown_menu_hash{$software};
	$sql .= '%\') as b where b.num > ';
	$sql .= $pager;
	#push(@dump,"$sql\n\n");
	}
	elsif (!$software and $search2)
	{
	$sql = 'select top 50 * from (select row_number() OVER (order by clnt) as num, clnt, software, market, or_md,software_count from [HelpDesk].[dbo].[software_count] as a where a.clnt like \'';
	$sql .= $search2;
	$$sql .= '%\') as b where b.num > ';
	$sql .= $pager;
	}
	#push(@dump,"$sql\n\n");
    $sth = $dbh->prepare("$sql");
	$sth->execute();	
}
#-----------------------SEARCH2------------^^^	
else
#-----------------------SEARCH-------------vvv
{
	
	if ($search and $begin_date and $end_date)
	{
	
	#select top 100 * from (select row_number() OVER (order by clnt) as num,* from [HelpDesk].[dbo].[year_price] as a  where clnt like '%ABC%' ) as b   where b.num > 0 compute sum(b.Total_cost_year)
	
	push(@dump,'%TABLE{ sort="on" tablewidth="100%" headeralign="left" dataalign="left" tableborder="0" cellpadding="1" cellspacing="0" }%');
    #push(@dump, "<noautolink>\n\n| *Client name*  | *Software* | *OR/MD* |  *Login* |  *Account* | *Start* | *Expire* | *Once* | *Monthly* | *Cost RUR* |\n");
	
	push(@dump, "<noautolink>\n\n| *Client name*  | *DMA Service* | *Count* | *OR/MD* |  *Total* |  *Vendor of Service* | *To be debited* |\n");
	
	 #For procedures
	 #$sth = $dbh->prepare("use HelpDesk; declare \@begin_date datetime, \@end_date datetime, \@clnt varchar(10), \@start int EXEC  dbo.otchet_za_period  \@clnt=\'Qua%\',  \@begin_date=\'$begin_date\', \@end_date=\'$end_date\', \@start=100");
	 
	 #select top 100 *  from dbo.otchetzaperiodfunc('2013-01-01','2013-06-04', 'Quants%') where num>0 compute sum(Cost_in_RUR)
	 
	 #$sql = 'select top 100 num,clnt,software,or_md,lgn,accnt,CAST(CONVERT(DATETIME, [begin_date], 101) AS date)  as [begin_date],CAST(CONVERT(DATETIME, [end_date], 101) AS date)  as [end_date],once,monthly,Cost_in_RUR  from [HelpDesk].[dbo].otchetzaperiodfunc(\'';
	 #$sql .= $begin_date . '\',\'' . $end_date . '\',\'' . $search . '\') where num > ' . $pager  . 'compute sum(Cost_in_RUR)';
	 
	 
	 $sql = 'select top 50 num, clnt, [DMA Service],[Count],[OR/MD], [Total], [Vendor of Service], [To be debited]   from (select row_number() OVER (order by t.total) AS num, * from (select distinct clnt, software as \'DMA Service\', COUNT(software) over (partition by software, or_md, vendor) as \'Count \',or_md as \'OR/MD\', SUM(cost) over (partition by software, or_md, vendor) as \'Total\',vendor as \'Vendor of Service\', CostAllocation as \'To be debited\' from [HelpDesk].[dbo].Client_otchet_test(\'';
	 $sql .= $begin_date . '\',\'' . $end_date . '\',\'' . $search . '\')) as t ) as b  where b.num > ' . $pager  . 'order by b.Total compute sum(b.Total)';
	 
	 
	 $sth = $dbh->prepare("$sql");
	 $sth->execute();

	}
	elsif ($search or $begin_date or $end_date)
	{
	}
	else
	{

	push(@dump,q(<noautolink>%TABLE{ sort="on" tablewidth="100%" headeralign="left" dataalign="left" tableborder="0" cellpadding="1" cellspacing="0" columnwidths="20%,30%,20%,20%,10%"}%));
    push(@dump, "\n\n| *Client name*  | *Software* | *Market* | *OR/MD* | *Software count* |\n");
	
	#$sql = qq(select top 100 * from (select  row_number() OVER (order by clnt) as num, clnt, SUM(Total_cost_year) as total  FROM [HelpDesk].[dbo].[year_price] as a group by clnt) as b where b.num > $pager);
	
	$sql = qq(select top 50 * from (select  row_number() OVER (order by clnt) as num, clnt, software, market, or_md, software_count  FROM [HelpDesk].[dbo].[software_count] as a ) as b where b.num > $pager);
	$sth = $dbh->prepare("$sql");
	$sth->execute();
	}
}
#-----------------------SEARCH-------------^^^	
	
#-----------------------MAIN SQL---------------------------------------------------------------------^^^
	
		
	eval
     {
	 
     $SIG{'ALRM'} = sub { die 'Timeout' };
     alarm(120);
	 
#-----------------------RETRIEVING DATA---------------------------------------------------------------vvv

#-----------------------SEARCH2------------vvv
if ($software or $search2)
{
     #push(@dump,"+++-$software- -$search2- $sql\n\n");
     while(my $data = $sth->fetchrow_arrayref ) 
     {
	  
	  unless  (@$data[1]) {@$data[1]=''};
	  unless  (@$data[2]) {@$data[2]=''};
	  unless  (@$data[3]) {@$data[3]=''};
	  unless  (@$data[4]) {@$data[4]=''};
	  unless  (@$data[5]) {@$data[5]=''};	  
	  
	  push(@dump, "| ");
	  push(@dump, join (' | ',@$data[1],@$data[2],@$data[3],@$data[4],@$data[5]));
      push(@dump, "|\n");
	  
	  #push(@dump, "<literal><tr><td></literal>");
	  #push(@dump, join ('<literal></td><td></literal>',@$data[1],@$data[2],@$data[3],@$data[4])); 
	  #push(@dump, "<literal></td></tr></literal>");
	  
	  
     }
	 #push(@dump, "<literal></tbody></table></literal></noautolink>");
	 push(@dump,"\nPages: $pager_string");
}
#-----------------------SEARCH2------------^^^
else
#-----------------------SEARCH------------vvv
{
 
	 if ($search and $begin_date and $end_date)
	 {
	 while(my $data = $sth->fetchrow_arrayref ) 
     {
	  unless  (@$data[1]) {@$data[1]=''};
	  unless  (@$data[2]) {@$data[2]=''};
	  unless  (@$data[3]) {@$data[3]=''};
	  unless  (@$data[4]) {@$data[4]=''};
  	  unless  (@$data[5]) {@$data[5]=''};
	  unless  (@$data[6]) {@$data[6]=''};
	  unless  (@$data[7]) {@$data[7]=''};
	  #unless  (@$data[8]) {@$data[8]=''};
	  #unless  (@$data[9]) {@$data[9]=''};
	  #unless  (@$data[10]) {@$data[10]=''};
	  push(@dump, "| ");
	  push(@dump, join (' | ',@$data[1],@$data[2],@$data[3],@$data[4],@$data[5],@$data[6],@$data[7],));
      push(@dump, "|\n");	  
     }
	 push(@dump,"\nPages: $pager_string");
	 }
	 elsif ($search or $begin_date or $end_date)
	 {
	 }
	 else
	 {
	 while($data = $sth->fetchrow_arrayref ) 
     {
	  unless  (@$data[1]) {@$data[1]=''};
	  unless  (@$data[2]) {@$data[2]=''};
	  unless  (@$data[3]) {@$data[3]=''};
	  unless  (@$data[4]) {@$data[4]=''};
	  unless  (@$data[5]) {@$data[5]=''};	  
	  push(@dump, "| ");
	  push(@dump, join (' | ',@$data[1],@$data[2],@$data[3],@$data[4],@$data[5]));
      push(@dump, "|\n");	  
     }
	 push(@dump,"\nPages: $pager_string");
	 }
}
#-----------------------SEARCH------------^^^
	 
#-----------------------RETRIEVING DATA---------------------------------------------------------------^^^
     	 
     alarm(0);
     };
	 
	 
	 
	 if ($data = $sth->{odbc_more_results})
	 {
	 $data = $sth->fetchrow_arrayref;
	 
	 push(@dump, "Sum: %RED% @$data[0] %ENDCOLOR%"), if (@$data[0]);
	 }
	 
	 $sth->finish;
	 
	 push(@dump,"<br><br>$sql");
	 
	 push(@dump,"\n---+++++ Price List");
	
	 push(@dump, "</noautolink>");
	 return "@dump";
	 
	}
#Output  w/o price list-----------------------------------------------------------^^^

    else

#Output  with price list----------------------------------------------------------vvv	
	{
	my @dump = ();
	push(@dump, "<noautolink><literal><table cellspacing='0' width=\"100%\" id='example' class='display dataTable' cellpadding='0' border='0' style=\"font-size:95%;\"><thead><tr></literal><literal><th>N</th><th>IT Service</th><th>Once</th><th>Monthly</th><th>Currency</th><th>Link</th></tr></thead><tbody></literal>");
	
	$sql=q(select row_number() OVER (order by software) AS num , software as 'IT Service', once 'Once', monthly as 'Monthly', Currency, Link from [HelpDesk].[dbo].[SoftRequestRatesPrice] where currency is not null  order by software;);
	
	
	$sth = $dbh->prepare("$sql");
	$sth->execute();
	

	eval
     {
     $SIG{'ALRM'} = sub { die 'Timeout' };
     alarm(120);
	 
     while(my $data = $sth->fetchrow_arrayref) 
     {
	  unless  (@$data[0]) {@$data[0]=''};
	  unless  (@$data[1]) {@$data[1]=''};
	  unless  (@$data[2]) {@$data[2]=''};
	  unless  (@$data[3]) {@$data[3]=''};
	  unless  (@$data[4]) {@$data[4]=''};
	  if (@$data[5])
	  {
	  @$data[5] = '[[' . @$data[5] . ']]';
	  }
	  else
	  {
	  @$data[5] = '';
	  }
  	  
	  push(@dump, "<literal><tr><td></literal>");
	  push(@dump, join ('<literal></td><td></literal>',@$data[0],@$data[1],@$data[2],@$data[3],@$data[4],@$data[5])); 
	  push(@dump, "<literal></td></tr></literal>");
	  
	  
	 }
	 
	 alarm(0);
     };
	 push(@dump, "<literal></tbody></table></literal></noautolink>");
	
	return "@dump";
	}
#Output  with price list----------------------------------------------------------^^^
	
	 
}
