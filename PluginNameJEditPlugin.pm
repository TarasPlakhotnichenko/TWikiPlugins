package TWiki::Plugins::PluginNameJEditPlugin;
use strict;
use DBI;
use vars qw( $VERSION $RELEASE $SHORTDESCRIPTION $debug $pluginName $NO_PREFS_IN_TOPIC );
$VERSION = '$Rev: 1 (2013-04-04) $';
$RELEASE = '2013-04-04';

$SHORTDESCRIPTION = 'Plugin Name JEdit plugin - template';
$NO_PREFS_IN_TOPIC = 0;
$pluginName = 'PluginNameJEditPlugin';


#this is plugin template for edit MS DB table in TWiki

=comment

SE [HelpDesk]
GO

/****** Object:  Table [dbo].[TableName]    Script Date: 08/02/2013 10:46:15 ******/
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


-----------------------Topic contents----------------------vvvv

<sticky>
<!-- <pre> -->

 <style type="text/css" title="currentStyle">
 @import "/twiki/pub/TWiki/JQueryPlugin/DataTables-1.9.4/media/css/jquery.dataTables.css";
</style>


<link href="/twiki/pub/TWiki/JQueryPlugin/themes/smoothness/jquery-ui-1.8.10.custom.css" media="screen" rel="stylesheet" type="text/css"/>
<script type="text/javascript"   src="/twiki/pub/TWiki/JQueryPlugin/JEditableDatapicker/jquery-ui-1.8.12.custom.min.js"></script>
<script type="text/javascript" src="/twiki/pub/TWiki/JQueryPlugin/DataTables-1.9.4/media/js/jquery.dataTables.js"></script>
<script type="text/javascript"   src="/twiki/pub/TWiki/JQueryPlugin/JEditable/jquery.jeditable.mini.js"></script>


<script type="text/javascript" charset="utf-8">
$(document).ready(function() {

    /* Init DataTables */
    var oTable = $('#example').dataTable({
    "bPaginate": false,
     "oLanguage": {
     "sSearch": "Filter: "
     },

    "aoColumns": [
    { "sWidth": "2%" }, 
    { "sWidth": "90%" },
    { "sWidth": "6%" },  
   { "sWidth": "2%" }, 
   ],
});

    
 /* Apply the jEditable handlers to the table */


oTable.$('td:not(.readonly)').editable( 'http://nagios.otkritie.com/cgi-bin/PluginNameJEdit.cgi', { 
 /* oTable.$('td').editable( "disable", { */
    type    : 'textarea',
    cancel    : 'Cancel',
    submit    : 'OK',  
    indicator : 'Saving...',
    tooltip   : 'Click to edit...',
   indicator : '<img src="img/indicator.gif">',

    "callback": function( sValue, y ) {
            var aPos = oTable.fnGetPosition( this );
            oTable.fnUpdate( sValue, aPos[0], aPos[1] );
        },

     "submitdata": function ( value, settings ) {
            return {
                "row_id": this.parentNode.getAttribute('id'),
                "column": oTable.fnGetPosition( this )[2]
            };

        },
        "height": "44px",
        "width": "100%"
    } );


} );

/*  vvv DatePicker vvv  */

$(document).ready(function() {
    jQuery.editable.addInputType('datepicker', {
        element: function(settings, original) {
 
            var input = jQuery('<input size=8 />');
 
            // Catch the blur event on month change
            settings.onblur = function(e) {
            };
 
            input.datepicker({
                dateFormat: 'yy-mm-dd',
                onSelect: function(dateText, inst) {
                    jQuery(this).parents("form").submit();
                },
                onClose: function(dateText, inst) {
                    jQuery(this).parents("form").submit();
                }
 
            });
 
            input.datepicker('option', 'showAnim', 'slide');
 
            jQuery(this).append(input);
            return (input);
        }
    });
 
    $('.editabledatepicker').editable(function(value, settings) {
        return (value);
    }, {
        type: 'datepicker',
        onblur: 'submit',
        tooltip: "Click to edit...."
    });
});


/*  ^^^ DatePicker ^^^  */


/*  vvv DatePicker vvv  */

$( document ).ready( function() {
 
  var date = $( '.editable' );
 
  $('.editable').editable('http://nagios.otkritie.com/cgi-bin/PluginNameJEdit.cgi', {
         indicator : 'Saving...',
         tooltip   : 'Click to edit...',
         cancel    : 'Cancel',
         type: 'datepicker'
     }); 
} );
/*  ^^^ DatePicker ^^^  */


</script>
<!-- </pre> --></sticky>

---++ Test

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

%PluginNameJEdit{id="%ID%" param="%PARAM%" insert="%INSERT%" update="%UPDATE%" delete="%DELETE%" page="%PAGE%" search="%SEARCH%"}%

-----------------------Topic contents----------------------^^^^

=cut


sub initPlugin {
    my( $topic, $web, $user, $installWeb ) = @_;
	TWiki::Func::registerTagHandler( 'PluginNameJEdit', \&_PluginNameJEdit );
    return 1;
}


sub _PluginNameJEdit {
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
	
	
#-----------menu form-----------------vvv	
$form = q(<noautolink>%TABLE{ sort="off" tablewidth="100%" headeralign="left" tableborder="0" cellpadding="1" cellspacing="0"}%<form name="edit" action="%SCRIPTURLPATH{view}%/%WEB%/%TOPIC%" method="post">
| *Param*  |  
| <pre><input type="text" name="param" value="%URLPARAM{"param"}%" size="50" class="twikiInputField"></pre> |
<input type="hidden" name="insert" value="1"><input type="submit" class="twikiSubmit" value="Submit" /></form></noautolink>);
#-----------menu form-----------------^^^
	

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
	
	if (($delete eq '1') and ($id ne '0'))
	{
	 push(@dump,"%RED%id $id - deleted%ENDCOLOR%");
     $sql = "delete from [HelpDesk].[dbo].[TableName] where id = $id ;";
	 my $sth = $dbh->prepare("$sql");
	 $sth->execute();
	}
#------------update,insert,delete--------------------------------------------------------------------^^^	
	
#-----------------------drawing menu-----------------------------------------------------------------vvv

my $search_form = <<SEARCH_FORM;
<form name="topic_search" action="%SCRIPTURLPATH{view}%/%WEB%/%TOPIC%" method="post">
<input type="text" name="search" value="%URLPARAM{"search"}%" size="50" class="twikiInputField" />&nbsp;<input type="submit" class="twikiSubmit" value="Search" />
</form> 

SEARCH_FORM

push(@dump,"$search_form\n\n");

#-----------------------add value menu----------vvv
my $twisty=q(%TWISTY{ id="menu" mode="div" start=");
$twisty.=$twisty_show;
$twisty.=q(" remember="on" showlink="Show edit menu&nbsp;" hidelink="Hide menu&nbsp;"
showimgright="%ICONURLPATH{toggleopen-small}%" 
hideimgright="%ICONURLPATH{toggleclose-small}%"}%);
push(@dump,"$twisty");
$twisty = q(<noautolink>field length - Param:100</noautolink>);
push(@dump,"$twisty");	
push(@dump,"$form");
$twisty = q(%ENDTWISTY%);
push(@dump,"$twisty");
#-----------------------add value menu----------^^^

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
	push(@dump,"[[http://nagios.otkritie.com/twiki/bin/view/OSL/$theTopic?page=$i&search=$search][(%RED%$i%ENDCOLOR%)]]");
	
	}
	else
	{
	push(@dump,"[[http://nagios.otkritie.com/twiki/bin/view/OSL/$theTopic?page=$i&search=$search][($i)]]");
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


#------------------table header----------------------------------------------------------------------vvv
	push(@dump, "<literal><table cellspacing='0' width=\"100%\" id='example' class='display dataTable' cellpadding='0' border='0' style=\"font-size:95%;\"><thead><tr><th>id</th><th>param</th><th>date</th><th align=\"center\">X</th></tr></thead><tbody></literal>");	

#------------------table header----------------------------------------------------------------------^^^	


#------------------main output-----------------------------------------------------------------------vvv
$sth = $dbh->prepare("$sql");
$sth->execute();


my $row_count=0;	
eval
 {
 $SIG{'ALRM'} = sub { die 'Timeout' };
 alarm(120);
 while(my $data = $sth->fetchrow_arrayref) 
 {
  unless  (@$data[0]) {@$data[0]=''}
  unless  (@$data[1]) {@$data[1]=''};
  unless  (@$data[2]) {@$data[2]=''};

  
  my $id=@$data[0];
  push(@dump, "<literal><tr><td id=\"@$data[0].0\" class=\"readonly\">@$data[0]</td><td id=\"@$data[0].1\">@$data[1]</td><td  class=\"readonly\"><span id=\"@$data[0].2\" class=\"editable\">@$data[2]</span></td></literal>");
  
    
  push(@dump, "<literal><td class=\"readonly\" align=\"center\"><a href=\"javascript:decision(\'Are you shure?\', \'http://nagios.otkritie.com/twiki/bin/view/OSL/</literal>" . "$theTopic?id=$id&delete=1" . "<literal>\')\"></literal>" . '%ICON{choice-no}%' . "<literal></a></td></tr></literal>");
  $row_count++;
  }
 alarm(0); 
 };

push(@dump, "<literal></tbody></table></literal>"); 
 
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
</pre>
);

push(@dump,"$jscript");
#------------------jscript delete confirmation menu--------------------------------------------------^^^	
	
	
return "@dump";

}





