package TWiki::Plugins::SoftRequestRatesCRMPlugin;
use strict;
use DBI;
use vars qw( $VERSION $RELEASE $SHORTDESCRIPTION $debug $pluginName $NO_PREFS_IN_TOPIC );
$VERSION = '$Rev: 1 (2013-03-26) $';
$RELEASE = '2013-03-26';

$SHORTDESCRIPTION = 'Soft RequestRates CRM plugin';
$NO_PREFS_IN_TOPIC = 0;
$pluginName = 'SoftRequestRatesCRMPlugin';


sub initPlugin {
    my( $topic, $web, $user, $installWeb ) = @_;
	TWiki::Func::registerTagHandler( 'SoftRequestRatesCRM', \&_SoftRequestRatesCRM );
    return 1;
}


sub _SoftRequestRatesCRM {
    my($session, $params, $theTopic, $theWeb) = @_;
    my $sql = '';
    my $data_source = q/dbi:ODBC:mssql_68/;
    my $user = q/nagios/;
    my $password = q/Nag4Read/;
	my $dbh = DBI->connect($data_source, $user, $password);

	$dbh->{'LongTruncOk'} = 1;
    $dbh->{'LongReadLen'} = 200;


	my $page = $params->{page} || '0';
	my $search = $params->{search} || '';	
	my @dump=();
	#my $twisty_show='hide';
	my $form = '';

    #push(@dump," -$update- | -$delete- | -$id- ");	
	#push(@dump," -$search- ");	
	
#-----------------------MENU-------------------------------------------------------------------------vvv

my $search_form = <<SEARCH_FORM;
<form name="topic_search" action="%SCRIPTURLPATH{view}%/%WEB%/%TOPIC%" method="post"><pre>
<input type="text" name="search" value="%URLPARAM{"search" encode="entity"}%" size="50" class="twikiInputField" />
</pre>
<input type="submit" class="twikiSubmit" value="Search" />
</form> <--  search on Client Name 

SEARCH_FORM

push(@dump,"$search_form\n\n"); 

#-----------------------MENU-------------------------------------------------------------------------^^^
	if ($search)
	{
$sql = 'select count(*) from ( select row_number() OVER (order by clnt) AS num, clnt as client, software, software_count, monthly, total_monthly, or_md from  (select distinct p.software, r.clnt, count(p.software) over(partition by p.id, r.clnt, r.or_md) as \'Software_count\',p.monthly,sum(p.monthly) over(partition by p.id, r.or_md,r.or_md) * case when p.type_of_price = 3 then 41 else 1 end as \'Total_monthly\',r.disabled, r.or_md, r.end_date, p.type_of_price from  [HelpDesk].[dbo].[SoftRequestRates_new] as r  left join [HelpDesk].[dbo].[SoftRequestRatesPrice] as p on r.id_software=p.id  where r.clnt like \'%';
$sql .= $search . '%\'  and (r.end_date is null or  r.end_date > GETDATE())  and (r.disabled=\'no\' or r.disabled is NULL)) as t  ) as c;';	 

     }
	 else
	 {
$sql = 'select  COUNT(*) from ( select row_number() OVER (order by clnt) AS num, clnt as client, software, software_count, monthly, total_monthly, or_md from  (select distinct p.software, r.clnt, count(p.software) over(partition by p.id, r.clnt, r.or_md) as \'Software_count\',p.monthly,sum(p.monthly) over(partition by r.clnt,r.id_software,r.or_md) * case when p.type_of_price = 3 then 41 else 1 end as \'Total_monthly\',r.disabled, r.or_md, r.end_date, p.type_of_price from  [HelpDesk].[dbo].[SoftRequestRates_new] as r  left join [HelpDesk].[dbo].[SoftRequestRatesPrice] as p on r.id_software=p.id where (r.end_date is null or  r.end_date > GETDATE())  and (r.disabled=\'no\' or r.disabled is NULL)  ) as t  ) as c';
	 }
	
	
    my $sth = $dbh->prepare("$sql");
	$sth->execute();
	my $data = $sth->fetchrow_arrayref;
	my $max_rows=@$data[0];
	push(@dump,"Pages: ");
	my $page_num=$max_rows / 100;
	my $remainder=$max_rows % 100;
	for (my $i = 0; $i <= $page_num; $i++) 
	{
	if ($i == $page)
	{
	push(@dump,"[[http://nagios.otkritie.com/twiki/bin/view/OSL/$theTopic?page=$i&search=$search][(%RED%$i%ENDCOLOR%)]]");
	
	}
	else
	{
	push(@dump,"[[http://nagios.otkritie.com/twiki/bin/view/OSL/$theTopic?page=$i&search=$search][($i)]]");
	}
	}
	push(@dump,"; Selected: %RED%$max_rows%ENDCOLOR%\n");
	
	my $pager=$page*100;


		
	#New 2013/04/02:
	#select distinct r.clnt, p.software,   count(p.software) over(partition by r.clnt,r.id_software) as 'Software_count' , p.monthly,  sum(p.monthly) over(partition by r.clnt,r.id_software) * case when p.type_of_price = 3 then 41 else 1 end as 'Total_monthly',  r.disabled, r.or_md, r.end_date, p.type_of_price   from  [HelpDesk].[dbo].[SoftRequestRates_new] as r left join [HelpDesk].[dbo].[SoftRequestRatesPrice]    as p on r.id_software=p.id 
	
	if ($search)
	{
	 $sql = 'select top 100 * from ( select row_number() OVER (order by clnt) AS num, clnt as client, software, software_count, monthly, total_monthly, or_md from  (select distinct p.software, r.clnt, count(p.software) over(partition by p.id, r.clnt, r.or_md) as \'Software_count\',p.monthly,sum(p.monthly) over(partition by r.clnt,r.id_software,r.or_md) * case when p.type_of_price = 3 then 41 else 1 end as \'Total_monthly\',r.disabled, r.or_md, r.end_date, p.type_of_price from  [HelpDesk].[dbo].[SoftRequestRates_new] as r  left join [HelpDesk].[dbo].[SoftRequestRatesPrice] as p on r.id_software=p.id  where r.clnt like \'%';
     $sql .= $search . '%\' and (r.end_date is null or  r.end_date > GETDATE())  and (r.disabled=\'no\' or r.disabled is NULL) ) as t   ) as c where num > ';
	 
	 #compute sum(Total_monthly)
	 #$sql .= qq( $pager );
	 $sql .= qq( $pager compute sum\(Total_monthly\) );
	 
	}
	else
	{
	$sql = qq(select top 100 * from ( select row_number() OVER (order by clnt) AS num, clnt as client, software, software_count, monthly, total_monthly, or_md from  (select distinct p.software, r.clnt, count(p.software) over(partition by p.id, r.clnt, r.or_md) as \'Software_count\',p.monthly,sum(p.monthly) over(partition by r.clnt,r.id_software,r.or_md) * case when p.type_of_price = 3 then 41 else 1 end as \'Total_monthly\',r.disabled, r.or_md, r.end_date, p.type_of_price from  [HelpDesk].[dbo].[SoftRequestRates_new] as r  left join [HelpDesk].[dbo].[SoftRequestRatesPrice] as p on r.id_software=p.id where (r.end_date is null or  r.end_date > GETDATE())  and (r.disabled=\'no\' or r.disabled is NULL) ) as t   ) as c where num > $pager);
	}
	
    
	push(@dump,'%TABLE{ sort="on" tablewidth="100%" headeralign="left" dataalign="left" tableborder="0" cellpadding="1" cellspacing="0" }%');
    push(@dump, "%STARTSMALL%<noautolink>\n\n| *Client name*  | *Software* | *Count* |  *Monthly* | *Total monthly* | *OR_MD* |\n");	
		
	$sth = $dbh->prepare("$sql");
	$sth->execute();
		
	eval
     {
     $SIG{'ALRM'} = sub { die 'Timeout' };
     alarm(120);
	 #do {
     while(my $data = $sth->fetchrow_arrayref ) 
     {
	  unless  (@$data[1]) {@$data[1]=''};
	  unless  (@$data[2]) {@$data[2]=''};
	  unless  (@$data[3]) {@$data[3]=''};
	  unless  (@$data[4]) {@$data[4]=''};
  	  unless  (@$data[5]) {@$data[5]=''};
	  unless  (@$data[6]) {@$data[6]=''};
	 
	  push(@dump, "| ");
      
	  push(@dump, join (' | ',@$data[1],@$data[2],@$data[3],@$data[4],@$data[5],@$data[6]));
      push(@dump, "|\n");	  
 
     }
	 #$sth->more_results();
	 #$data = $sth->fetchrow_arrayref;
	 #push(@dump, "Sum: %RED% @$data[0] %ENDCOLOR%");
	 #} while ($sth->more_results)
     alarm(0);
     };
	 
	 if ($data = $sth->{odbc_more_results})
	 {
	 $data = $sth->fetchrow_arrayref;
	 push(@dump, "Sum: %RED% @$data[0] %ENDCOLOR%");
	 }
	
	 push(@dump, "</noautolink>");
	 

	
	return "@dump";
}
