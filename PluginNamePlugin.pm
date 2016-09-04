package TWiki::Plugins::PluginNamePlugin;
use strict;
use DBI;
use vars qw( $VERSION $RELEASE $SHORTDESCRIPTION $debug $pluginName $NO_PREFS_IN_TOPIC );
$VERSION = '$Rev: 1 (2013-04-04) $';
$RELEASE = '2013-04-04';

$SHORTDESCRIPTION = 'Plugin Name plugin - template';
$NO_PREFS_IN_TOPIC = 0;
$pluginName = 'PluginNamePlugin';


#this is plugin template for edit MS DB table in TWiki

=comment

DB table:

USE [HelpDesk]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TableName](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[param] [varchar](50) NULL,
	[date_field] [datetime] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[TableName] ADD  CONSTRAINT [DF_TableName_date_field]  DEFAULT (getdate()) FOR [date_field]
GO

<!--
      * Set STARTSMALL=<span style="font-size:95%;">
      * Set ENDSMALL=</span>

      * Set ID = %URLPARAM{"id"  default=""}%
      * Set PARAM = %URLPARAM{"param"   default=""}%
      * Set INSERT = %URLPARAM{"insert" default=""}%
      * Set UPDATE = %URLPARAM{"update" default=""}%
      * Set DELETE = %URLPARAM{"delete" default=""}%
      * Set PAGE=%URLPARAM{"page" default="0"}%
      * Set SEARCH=%URLPARAM{"search"  default=""}%
//-->



%PluginName{id="%ID%" param="%PARAM%" insert="%INSERT%" update="%UPDATE%" delete="%DELETE%" page="%PAGE%" search="%SEARCH%"}%

FreeTDS -  freetds.conf:

[mssql_68]
host = x.x.x.x
port = 1433
tds version = 7.2
client charset = KOI8-R


=cut


sub initPlugin {
    my( $topic, $web, $user, $installWeb ) = @_;
	TWiki::Func::registerTagHandler( 'PluginName', \&_PluginName );
    return 1;
}


sub _PluginName {
    my($session, $params, $theTopic, $theWeb) = @_;
    my $sql = '';
    my $data_source = q/dbi:ODBC:mssql_68/;
    my $user = q/nagios/;
    my $password = q/Nag4Read/;
	my $dbh = DBI->connect($data_source, $user, $password);

	$dbh->{'LongTruncOk'} = 1;
    $dbh->{'LongReadLen'} = 200;

	my $id = $params->{id} || '';
	my $param = $params->{param} || '';
	#my $edit = $params->{edit} || '';
	my $insert = $params->{insert} || '0';
	my $update = $params->{update} || '0';
	my $delete = $params->{delete} || '0';
	my $page   = $params->{page}   || '0';
	my $search = $params->{search} || '';	
	my @dump=();

	my $twisty_show='hide';
	my $form = '';
	my $today =`date +%Y-%m-%d`;
	
	
	
    #push(@dump," -$edit- ");	

    if  (($delete eq '0') and !($id eq ''))
	{
	
#------------sql request for edit menu---------------------------------------------------------------vvv
	$sql = qq(SELECT [id],[param], CAST(CONVERT(DATETIME, [date_field], 111) AS date) as [date_field]  FROM [HelpDesk].[dbo].[TableName] where id=$id;);    
	my $sth = $dbh->prepare("$sql");
	$sth->execute();
	my $param='';

	if (my $data = $sth->fetchrow_arrayref)
	 {
	  if (@$data[1]) {$param=@$data[1]};
      $sth->finish;	  
	 }
#------------sql request for edit menu---------------------------------------------------------------^^^


#------------edit menu form--------------------------------------------------------------------------vvv
$form = qq(<noautolink>%TABLE{ sort="off" tablewidth="100%" headeralign="left" tableborder="0" cellpadding="1" cellspacing="0"}%<form name="edit" action="%SCRIPTURLPATH{view}%/%WEB%/%TOPIC%" method="post">
| *Param*  | *Param1* | *Param2* | 
| <pre><input type="text" name="param" value="$param" size="50" class="twikiInputField"></pre> | | |
<input type="hidden" name="update" value="$id"><input type="hidden" name="page" value="$page"><input type="submit" class="twikiSubmit" value="Submit" /></form></noautolink>);
 $twisty_show="show";
  }
else
  {
$form = q(<noautolink>%TABLE{ sort="off" tablewidth="100%" headeralign="left" tableborder="0" cellpadding="1" cellspacing="0"}%<form name="edit" action="%SCRIPTURLPATH{view}%/%WEB%/%TOPIC%" method="post">
| *Param*  | *Param1* | *Param2* | 
| <pre><input type="text" name="param" value="%URLPARAM{"param"}%" size="50" class="twikiInputField"></pre> | | |
<input type="hidden" name="insert" value="1"><input type="submit" class="twikiSubmit" value="Submit" /></form></noautolink>);

  }
  
#------------edit menu form--------------------------------------------------------------------------^^^  


#------------update,insert,delete--------------------------------------------------------------------vvv
		
	if (($param) and ($update eq '0'))
	{
	 push(@dump,"%RED%new value -$param- pushed%ENDCOLOR% "); 
     $sql = "INSERT INTO [HelpDesk].[dbo].[TableName] ([param]) VALUES ('$param');";
	 my $sth = $dbh->prepare("$sql");
	 $sth->execute();
	 	 
	 
	my $query = TWiki::Func::getCgiQuery();
    TWiki::Func::redirectCgiQuery(undef, TWiki::Func::getScriptUrl($theWeb, $theTopic, 'view'), 0);
 
    }
	
	#push(@dump," -$update- -$delete- -$param- ");

	
	if ($update ne '0')
	{
	 push(@dump,"%RED%id $update - updated%ENDCOLOR%");
	 $sql = "update [HelpDesk].[dbo].[TableName] set [param]= '$param'  where id = $update ;";
	 
	 my $sth = $dbh->prepare("$sql");
	 $sth->execute();
    }
	elsif (($delete eq '1') and ($id ne '0'))
	{
	 push(@dump,"%RED%id $id - deleted%ENDCOLOR%");
     $sql = "delete from [HelpDesk].[dbo].[TableName] where id = $id ;";
	 my $sth = $dbh->prepare("$sql");
	 $sth->execute();
	}
#------------update,insert,delete--------------------------------------------------------------------^^^	
	
#-----------------------drawing menu-----------------------------------------------------------------vvv

my $search_form = <<SEARCH_FORM;
<form name="topic_search" action="%SCRIPTURLPATH{view}%/%WEB%/%TOPIC%" method="post"><pre>
<input type="text" name="search" value="%URLPARAM{"search"}%" size="50" class="twikiInputField" />
</pre>
<input type="submit" class="twikiSubmit" value="Search" />
</form> <--  search on param 

SEARCH_FORM



push(@dump,"$search_form\n\n"); 


	my $twisty=q(%TWISTY{ id="menu" mode="div" start=");
	$twisty.=$twisty_show;
	$twisty.=q(" remember="on" showlink="Show edit menu&nbsp;" hidelink="Hide menu&nbsp;"
showimgright="%ICONURLPATH{toggleopen-small}%" 
hideimgright="%ICONURLPATH{toggleclose-small}%"}%);
push(@dump,"$twisty");
    $twisty = q(<noautolink>field length - Param:100;  <br>Sorting - ORDER BY Param DESC</noautolink>);
    push(@dump,"$twisty");	
	push(@dump,"$form");
	$twisty = q(%ENDTWISTY%);
	push(@dump,"$twisty");
#-----------------------drawing menu-----------------------------------------------------------------^^^



#-----------------------pager------------------------------------------------------------------------vvv
	if ($search)
	{
	 $sql = 'SELECT   COUNT(id)  FROM [HelpDesk].[dbo].[TableName]  where param like \'%';
	 $sql .= $search . '%\';';
	 }
	 else
	 {
	 $sql = 'SELECT   count(id)  FROM [HelpDesk].[dbo].[TableName];';
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
	push(@dump,"[[http://nagios.open.ru/twiki/bin/view/OSL/$theTopic?page=$i&search=$search][(%RED%$i%ENDCOLOR%)]]");
	
	}
	else
	{
	push(@dump,"[[http://nagios.open.ru/twiki/bin/view/OSL/$theTopic?page=$i&search=$search][($i)]]");
	}
	}
	push(@dump,"; Selected: %RED%$max_rows%ENDCOLOR%\n");
	
	my $pager=$page*100;

#-----------------------pager------------------------------------------------------------------------^^^	


#-----------------------sql for main output----------------------------------------------------------vvv
	# the second param "top" alters as following: 0 100 200 ... 
	if ($search)
	{
	 $sql = 'SELECT  top 100 [id],[param],CAST(CONVERT(DATETIME, [date_field], 101) AS date)  as [date_field]  FROM [HelpDesk].[dbo].[TableName]   where [id] NOT IN ( select  top ';
	 $sql .= $pager;
	 $sql .= ' [id] FROM [HelpDesk].[dbo].[TableName]  where  param like \'%';
	 $sql .= $search . '%\' order by id,param) and param like \'%' . $search . '%\' order by id,param;';
	 
	}
	else
	{
	$sql = qq(SELECT  top 100 [id],[param],CAST(CONVERT(DATETIME, [date_field], 101) AS date)  as [date_field]  FROM [HelpDesk].[dbo].[TableName]   where [id] NOT IN ( select  top $pager  [id] FROM [HelpDesk].[dbo].[TableName] order by id )  order by id;)
	
	
	}
#-----------------------sql for main output----------------------------------------------------------^^^	



#------------------Sort table after inserting orupdating---------------------------------------------vvv
    my $sorting= '';
	if (($id ne '') or ($insert ne '0') or ($update ne '0'))
	{
	 $sorting= q(%TABLE{ sort="off" tablewidth="100%" headeralign="left" tableborder="0" cellpadding="1" cellspacing="0" columnwidths="1%,65%,3%,1%" }%);
	}
	else
	{
	 $sorting= q(%TABLE{ sort="on" tablewidth="100%" headeralign="left" tableborder="0" cellpadding="1" cellspacing="0" columnwidths="1%,65%,3%,1%" }%);

	}
#------------------Sort table after inserting orupdating---------------------------------------------^^^


#------------------table header----------------------------------------------------------------------vvv
    push(@dump, "%STARTSMALL%<noautolink>\n\n$sorting\n| *id* | *param*  | *date* | *X* |\n");	
#------------------table header----------------------------------------------------------------------^^^	





#------------------main output-----------------------------------------------------------------------vvv
$sth = $dbh->prepare("$sql");
$sth->execute();
	
eval
 {
 $SIG{'ALRM'} = sub { die 'Timeout' };
 alarm(120);
 while(my $data = $sth->fetchrow_arrayref) 
 {
  unless  (@$data[1]) {@$data[1]=''};
  unless  (@$data[2]) {@$data[2]=''};
  
  my $id=@$data[0];
  @$data[0] = "[[http://nagios.open.ru/twiki/bin/view/OSL/$theTopic?id=$id;page=$page][$id]]";
 
  push(@dump, "| ");
  push(@dump, join (' | ',@$data[0],@$data[1],@$data[2])); 
  push(@dump, qq( | <literal><a href="javascript:decision('Are you shure?', 'http://nagios.open.ru/twiki/bin/view/OSL/$theTopic?id=$id&delete=1')"></literal>%ICON{choice-no}%<literal></a></literal> |\n));
  }
 alarm(0); 
 };
 
push(@dump, "</noautolink>"); 
#------------------main output-----------------------------------------------------------------------^^^	 




#------------------jscript delete confirmation menu--------------------------------------------------vvv
	 
my $jscript=q(<pre>
<SCRIPT LANGUAGE="Javascript">
<!---
function decision(message, url){
if(confirm(message)) location.href = url;
}
// --->
</SCRIPT>
</script>
</pre>
);

push(@dump,"$jscript");
#------------------jscript delete confirmation menu--------------------------------------------------^^^	
	
	
return "@dump";

}





