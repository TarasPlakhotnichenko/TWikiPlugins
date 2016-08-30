package TWiki::Plugins::QuikNotesPlugin;
use strict;
use DBI;
use vars qw( $VERSION $RELEASE $SHORTDESCRIPTION $debug $pluginName $NO_PREFS_IN_TOPIC );
$VERSION = '$Rev: 2 (2012-04-09) $';
$RELEASE = '2012-02-05';

$SHORTDESCRIPTION = 'Quik Notes plugin';
$NO_PREFS_IN_TOPIC = 0;
$pluginName = 'QuikNotesPlugin';


sub initPlugin {
    my( $topic, $web, $user, $installWeb ) = @_;
	#$debug = TWiki::Func::getPluginPreferencesFlag("DEBUG");
	TWiki::Func::registerTagHandler( 'QuikNotes', \&_QuikNotes );
	
    return 1;
}

sub _QuikNotes {
    my($session, $params, $theTopic, $theWeb) = @_;
	
	my $login_name= TWiki::Func::getWikiName( );
	
    my $sql = '';
    my $data_source = q/dbi:ODBC:mssql_68/;
    my $user = q/nagios/;
    my $password = q/Nag4Read/;
	my $dbh = DBI->connect($data_source, $user, $password);

	$dbh->{'LongTruncOk'} = 1;
    $dbh->{'LongReadLen'} = 200;

	my $id = $params->{id} || '';
    my $topic_name = $params->{topic} || '';
    my $comments = $params->{comments} || '';
	my $insert = $params->{insert} || '0';
	my $update = $params->{update} || '0';
	my $delete = $params->{delete} || '0';
	my $page_qn = $params->{page_qn} || '0';
	my $search = $params->{search} || '';	
	my $top = $params->{top} || '';
	my $upfile = $params->{upfile} || '';
	
	
	
	#my $cgiQuery = TWiki::Func::getCgiQuery();
	#my $upfile2 = $cgiQuery->param('upfile') || '';
	
	my @dump=();
	my @client_list=();
	my @final_dump=();
	my $twisty_show='hide';
	my $form = '';
	my $section='';

	my $nolink='';
	my $twisty_start = q(%TWISTY{start="hide"}%);
    my $twisty_end = q(%ENDTWISTY%);
	
	
	#remove ending spaces and vertical bars-----vvv
	$topic_name =~s/\s+$//;
	$topic_name =~s/\|/\&verbar\;/g;

	$comments =~s/\s+$//;
	$comments =~s/\|/\&verbar\;/g;
	#remove ending spaces and vertical bars-----^^^
	
if  (($delete eq '0') and !($id eq ''))
	{
	$sql = qq(SELECT [id],[TopicName],[Comments],[LoginName]  FROM [HelpDesk].[dbo].[QuikNotes] where id=$id;);    
	my $sth = $dbh->prepare("$sql");
	$sth->execute();
	my $clnt='';
	my $cmnts='';
	my $lgn_name='';

	if (my $data = $sth->fetchrow_arrayref)
	{
	 if (@$data[1]) 
	 {
	  $clnt=@$data[1];
	  $clnt=~s/\s+$//;
	  $clnt=~s/\|/\&verbar\;/g;
	 };
	 
	 if (@$data[2]) 
	 {
	  $cmnts=@$data[2];
	  $cmnts=~s/\s+$//;
	  $cmnts=~s/\|/\&verbar\;/g;
	 };
	 
	 if (@$data[3]) 
	 {
	  $lgn_name=@$data[3];
	  $lgn_name=~s/\s+$//;
	  $lgn_name=~s/\|/\&verbar\;/g;
	 };
	 
    }
	
	#ENCTYPE="multipart/form-data"
	$form = q(%TABLE{ sort="off" tablewidth=\"100%\" }%<form name="quik_notes" action="%SCRIPTURLPATH{view}%/%WEB%/%TOPIC%" method="post" >
| *Comments*  | 
| <noautolink><textarea cols="230" rows="8" name="comments" class="twikiInputField">);



    $form .= "$cmnts";
	$form .= q(</textarea></noautolink> | );
	
    $form .= q(
	<input type="hidden" name="update" value=");
    $form .= $id; 
    
	#$form .= q(">File to upload (optional): <INPUT type="file" class="twikiInputField"  name="upfile" value="%UPFILE%">&nbsp;&nbsp;<input type="submit" class="twikiSubmit" value="Submit" /></form>);
	
	
    $form .= q("><input type="submit" class="twikiSubmit" value="Submit" /></form>);
    $twisty_show="show";
}
else
 {
 $form = q(%TABLE{ sort="off" tablewidth=\"100%\"}%<form name="quik_notes" action="%SCRIPTURLPATH{view}%/%WEB%/%TOPIC%" method="post">
| *Comments* |
| <noautolink><textarea cols="230" rows="8" name="comments" class="twikiInputField">%URLPARAM{"comments"}%</textarea></noautolink> | );

#File to upload (optional): <INPUT TYPE=FILE NAME="upfile">&nbsp;&nbsp;

$form .= q(
<input type="hidden" name="insert" value="1">
<input type="submit" class="twikiSubmit" value="Submit" />

</form>);
 }

#push(@dump,"%RED%---$upfile---%ENDCOLOR%"); 


#push(@dump,"%RED%---$deb $upfile---%ENDCOLOR%"); 
 

 
if (($comments) and ($update eq '0'))
	{
	
	 push(@dump,"%RED%new value - pushed%ENDCOLOR%<br>");

    #update twiki revision time--------------------------------------------------------------------------vvv
	 my ( $oopsUrl, $loginName, $unlockTime ) = TWiki::Func::checkTopicEditLock( $theWeb, $theTopic );
        if( $oopsUrl ) {
        push(@dump,"%RED%this is being edited by $loginName now. Unlock time: $unlockTime%ENDCOLOR%");
        return;
       } 
	 my $text = TWiki::Func::readTopicText( $theWeb, $theTopic);
	 $oopsUrl = TWiki::Func::saveTopicText( $theWeb, $theTopic, $text );
	 #update twiki revision time--------------------------------------------------------------------------^^^
	 
	 
     $sql = "INSERT INTO [HelpDesk].[dbo].[QuikNotes] ([TopicName],[Comments],[LoginName]) VALUES ('$topic_name','$comments','$login_name');";
	
	 my $sth = $dbh->prepare("$sql");
	 $sth->execute();
    }

if ($update ne '0')
	{
	
	#------------------------------------------------------------------------
	#my $workdir =  TWiki::Func::getWorkArea("RemoteFileAttachPlugin");
	#push(@dump,"%RED%---$upfile ---%ENDCOLOR%");
	
	#beforeAttachmentSaveHandler($upfile,$theTopic,$theWeb);
	
	#my $cgiQuery = TWiki::Func::getCgiQuery();
	#my $fileupload = $cgiQuery->param('upfile') || '';
	#TWiki::Func::writeDebug("$fileupload +++");
	
	#beforeAttachmentSaveHandler();
	
	#my $cgiQuery = TWiki::Func::getCgiQuery();
	#my $upfile = $cgiQuery->param('upfile') || '';
	#my $deb =  TWiki::writeDebug(join(", ", @_));
	
	#my $error = TWiki::Func::saveAttachment( $theWeb, $theTopic,  $upfile,
    #{ 
    #file => $upfile,
    #filepath => $upfile,
    #comment => 'Test'
    #} );
    #my $deb =  TWiki::writeDebug(join(", ", @_));
   #------------------------------------------------------------------------
	
	
  
	 #update twiki revision time--------------------------------------------------------------------------vvv
	 my ( $oopsUrl, $loginName, $unlockTime ) = TWiki::Func::checkTopicEditLock( $theWeb, $theTopic );
        if( $oopsUrl ) {
        push(@dump,"%RED%this is being edited by $loginName now. Unlock time: $unlockTime%ENDCOLOR%");
        return;
       } 
	 my $text = TWiki::Func::readTopicText( $theWeb, $theTopic);
	 $oopsUrl = TWiki::Func::saveTopicText( $theWeb, $theTopic, $text );
	 #update twiki revision time--------------------------------------------------------------------------^^^
	 
	 
	 push(@dump,"%RED%id $update - updated%ENDCOLOR%");
     $sql = "update [HelpDesk].[dbo].[QuikNotes] set [Comments]= '$comments', [LoginName]='$login_name', [date]=getdate() where id = $update ;";
	 my $sth = $dbh->prepare("$sql");
	 $sth->execute();
	 $twisty_show="hide";
    }
	elsif (($delete eq '1') and ($id ne '0'))
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
	
	 push(@dump,"%RED%id $id - deleted%ENDCOLOR%");
     $sql = "delete from [HelpDesk].[dbo].[QuikNotes] where id = $id ;";
	 my $sth = $dbh->prepare("$sql");
	 $sth->execute();
	}	

	
	#-----------------------MENU-------------------------------------------------------------------------vvv
my $search_form = <<SEARCH_FORM;
<form name="topic_search" action="%SCRIPTURLPATH{view}%/%WEB%/%TOPIC%#Quik Notes" method="post"><pre>
<input type="text" name="search" value="%URLPARAM{"search" }%" size="50" class="twikiInputField" />
</pre>
<input type="submit" class="twikiSubmit" value="Search" />
</form> <--  search all quik notes (clients and etc)

SEARCH_FORM
push(@dump,"$search_form\n\n"); 
	
	
	my $twisty=q(%TWISTY{id="quik_notes" mode="div" start=");
	$twisty.=$twisty_show;
	$twisty.=q(" remember="on" showlink="Add item&nbsp;" hidelink="Hide menu&nbsp;"
showimgright="%ICONURLPATH{toggleopen-small}%" 
hideimgright="%ICONURLPATH{toggleclose-small}%"}%);
    push(@dump,"$twisty");
    $twisty = q(<noautolink>Comments field length: 4000; Sorting: TopicName,id DESC</noautolink>);
    push(@dump,"$twisty");	
	push(@dump,"$form");
	$twisty = q(%ENDTWISTY%);
	push(@dump,"$twisty");
    #-----------------------MENU-------------------------------------------------------------------------^^^
	

	if ($search)
	{
	 $sql = 'SELECT COUNT(id) FROM [HelpDesk].[dbo].[QuikNotes] where TopicName like \'%';
	 $sql .= $search . '%\'';
	 $sql .= ' or Comments like \'%' . "$search" . '%\';';
	}
	else
	{
     $sql = "SELECT COUNT(id) FROM [HelpDesk].[dbo].[QuikNotes] where TopicName = \'$topic_name\'";
	}
	 
    my $sth = $dbh->prepare("$sql");
	$sth->execute();
	my $data = $sth->fetchrow_arrayref;
	my $max_rows=@$data[0];
	push(@dump,"Pages: ");
	my $page_num=$max_rows / 10;
	my $remainder=$max_rows % 10;
	for (my $i = 0; $i <= $page_num; $i++) 
	{
	if ($i == $page_qn)
	{
	push(@dump,"[[http://nagios.otkritie.com/twiki/bin/view/OSL/$theTopic?page_qn=$i&search=$search#Quik Notes][(%RED%$i%ENDCOLOR%)]]");
	}
	else
	{
	push(@dump,"[[http://nagios.otkritie.com/twiki/bin/view/OSL/$theTopic?page_qn=$i&search=$search#Quik Notes][($i)]]");
	}
	}
	push(@dump,"\n");
	
	my $pager=$page_qn*10;
   

    if ($search)
	{
	$sql = "SELECT top 10 [id],[TopicName],[Comments],[LoginName],CAST(CONVERT(DATETIME, [date], 101) AS date) FROM [HelpDesk].[dbo].[QuikNotes]  where ID NOT IN ( select top $pager id from [HelpDesk].[dbo].[QuikNotes] where TopicName like \'%$topic_name%\'  or Comments like \'%$search%\' ORDER BY TopicName,id DESC ) and (TopicName like \'%$search%\' or Comments like \'%$search%\') ORDER BY TopicName,id DESC;";
	}
	else
	{
	$sql = "SELECT top 10 [id],[TopicName],[Comments],[LoginName],CAST(CONVERT(DATETIME, [date], 101) AS date) FROM [HelpDesk].[dbo].[QuikNotes]  where ID NOT IN ( select top $pager id from [HelpDesk].[dbo].[QuikNotes] where TopicName = \'$topic_name\' ORDER BY TopicName,id DESC ) and TopicName = \'$topic_name\' ORDER BY TopicName,id DESC;";
	}
	
    
	
	
	#columnwidths="2%,90%,4%,3%,1%"
	
	 # headerbg=\"#edf4f9\" headercolor=\"#A3C8E3\"  cellpadding=\"1\" cellspacing=\"3\" columnwidths="2%,90%,4%,3%,1%"

	$sth = $dbh->prepare("$sql");
	$sth->execute();

	eval
     {
     $SIG{'ALRM'} = sub { die 'Timeout' };
     alarm(120);
     while(my $data = $sth->fetchrow_arrayref) 
     {
	  my $id=@$data[0];

	  #@$data[0] = "[[http://nagios.otkritie.com/twiki/bin/view/OSL/$theTopic?id=$id#Quik Notes][$id]]";
	  @$data[0] = "<literal><a href=\"http://nagios.otkritie.com/twiki/bin/view/OSL/</literal>" . "$theTopic?id=$id#Quik Notes" . "<literal>\"></literal>" . "%ICON{wri}%" . "<literal></a></literal>";
	  

	  @$data[1] =~s/\s+$//;

	  
	  if (@$data[2]) {
	  @$data[2] =~s/\n/<br>/g;
	  @$data[2] =~s/\&\#64\;/@/g;
	  }
	  
     if ($section ne @$data[1])
	  {
	  push(@dump, "\n\n---++++++ [[@$data[1]]]" . "\n" );
	  
	  $section = @$data[1];
	  push(@dump,  "<noautolink>\n\n%TABLE{ sort=\"off\" tablewidth=\"100%\" headerbg=\"#edf4f9\" headercolor=\"#A3C8E3\"  cellpadding=\"1\" cellspacing=\"0\"  columnwidths=\"1%,87%,4%,7%,1%\" }%\n| *id* | *Comments* | *User* | *Date* | *x* |\n" );
	  
	  }
	  
	  @$data[2] = '<noautolink>' . @$data[2] . '</noautolink>';
	  push(@dump,  '|' . @$data[0] .  '|' . @$data[2] . '|' . @$data[3] . '|' . @$data[4]  );
	  push(@dump, " | <literal><a href=\"javascript:decision(\'Are you shure?\',
\'http://nagios.otkritie.com/twiki/bin/view/OSL/$theTopic?id=$id&delete=1\')\"></literal>%ICON{choice-no}%<literal></a></literal> |\n");
      }
     push(@dump,  "</noautolink>");
     alarm(0);
     };
	 
	 if (($search) and !(@$data[0]))
     {
	 push(@dump,"%RED% - nothing found%ENDCOLOR%");
     }
	 
	 
my $jscript= <<JAVA_SCRIPT;
<noautolink>
<SCRIPT LANGUAGE="Javascript">
<!---
function decision(message, url){
if(confirm(message)) location.href = url;
}
// --->
</SCRIPT>
</noautolink>
JAVA_SCRIPT

push(@dump,"$jscript");	 

return "@dump";

}
	
#---------------------------------------	
