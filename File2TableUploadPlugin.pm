package TWiki::Plugins::File2TableUploadPlugin;

use vars qw( $VERSION $RELEASE $SHORTDESCRIPTION $debug $pluginName $NO_PREFS_IN_TOPIC );
use Error;
use POSIX qw(strftime);

use Text::Iconv;




$VERSION = '$Rev: 4 (2013-01-31) $';
$RELEASE = '2013-01-15';

$SHORTDESCRIPTION = 'File2TableUpload plugin';
$NO_PREFS_IN_TOPIC = 0;
$pluginName = 'File2TableUploadPlugin';
#=================================================================================================================
#<!--
#      * Set ALLOWTOPICVIEW = TarasPlakhotnichenko
#      * Set TABLEATTRIBUTES = tablewidth="100%"  dataalign="left" headeralign="left" tableborder="0"  cellpadding="1" cellspacing="0"
#-->
#%File2TableUpload{}%
#<!--ATTACHMENTS-->%EDITTABLE{ format="| textarea,1x80|textarea,1x85|  date,10,  ,%Y-%m-%d"  changerows="on"  buttonrow="top" }%%TABLE{ id="Quik" sort="on" tablewidth="100%" cellpadding="1" cellspacing="0"  columnwidths="47%,47%,6%"}%<!--ATTACHMENTS-->


#OR

#%File2TableUpload{tag="TEST"}%
#<!--TEST-->%EDITTABLE{ format="| textarea,1x65|textarea,1x65|  date,10,  ,%Y-%m-%d"  changerows="on"  buttonrow="top" }%%TABLE{ id="Quik" sort="on" tablewidth="100%" cellpadding="1" cellspacing="0"  columnwidths="47%,47%,6%"}%<!--TEST-->
#=================================================================================================================


sub initPlugin {
    my( $topic, $web, $user, $installWeb ) = @_;
	TWiki::Func::registerTagHandler( 'File2TableUpload', \&_File2TableUpload );
	$debug = 0;
    return 1;
}

sub _File2TableUpload {
my @dump=();
my($session, $params, $theTopic, $theWeb) = @_;

my $tag = $params->{tag} || '';

my $form = q(<form enctype="multipart/form-data" name="main" action="%SCRIPTURLPATH{save}%/%WEB%/%TOPIC%" method="post" onsubmit="return validateTWikiMandatoryFields(event)">);
$form .= q(File to upload: <INPUT type="file" class="twikiInputField"  name="upfile">&nbsp;&nbsp;Overwrite if exists: <input type='checkbox' name='overwrite' class="twikiInputField" value="1">&nbsp;&nbsp;Comment: <input type="text" name="file_comment" value="%URLPARAM{"client" encode="entity"}%" size="70" maxlength="120" class="twikiInputField" />&nbsp;&nbsp;<input type="submit" class="twikiSubmit" name="action_save" id="save" value="Submit" /><input type="hidden" name="tag" value=");
$form .= $tag;
$form .= q("></form>);



my $save_flag = TWiki::Func::getSessionValue('topic_saved');

push(@dump,"$form");
return "@dump";
}

sub afterSaveHandler {
    my ( $attrHashRef, $theTopic, $theWeb ) = @_;
    
	return, unless after_attach_proceed();
	return, unless after_save_proceed();
	
	

	my $cgiQuery = TWiki::Func::getCgiQuery();
	my $filename = $cgiQuery->param('upfile');
	my $filecomment = $cgiQuery->param('file_comment');
	my $overwrite = $cgiQuery->param('overwrite');
	my $stream = $cgiQuery->upload('upfile');
	my $tag = $cgiQuery->param('tag');
	
	if(defined($stream)){
	  TWiki::Func::writeDebug("- ${pluginName}::afterSaveHandler( $_[2].$_[1] - attachment:  $stream file name: $filename)") if $debug;
	}
	else
	{
	return 0;
	}
    
	my $workArea = TWiki::Func::getWorkArea($pluginName);
	my $randFileName = int( rand(1000000000));
    chdir($workArea);
	my $tempFile = "$workArea\/$randFileName";
	
     
	my $buffer;
	open (OUTFILE,">$tempFile");
	while (read($stream,$buffer,1024)) 
	{
		print OUTFILE $buffer;
	}
	my $filesize = (stat OUTFILE)[7];
	
	close(OUTFILE);
	close($stream);
	

    #TWiki::Func::writeDebug("--- $filename $filecomment $attExist---$overwrite");
    #use locale;
    #use POSIX qw (locale_h);
    #setlocale(LC_CTYPE, 'ru_RU.KOI8-R');
	#$converter = Text::Iconv->new("koi8-r", "windows-1251");
    #$filename = $converter->convert("$filename");
	
	$filename = lc($filename);
	$filename=k82tr($filename);
	#TWiki::Func::writeDebug("--- $filename");
	
	$filename =~ s/ /_/go;
	$filename =~ s/Ó/n/go;
	$filename =~ s/M/m/go;
	$filename = lc($filename);

	$filename =~ s/^.*\\.*\\//go;
	$filename =~ s/$TWiki::cfg{NameFilter}//goi;
	
	#TWiki::Func::writeDebug("--- $filename $filecomment $attExist---$overwrite");
	
	TWiki::Func::setSessionValue('file_upload_attachment', 1);
	my $attExist= TWiki::Func::attachmentExists($theWeb,$theTopic,$filename);
	
   
	if (!(defined($attExist)) or (defined($overwrite) and $overwrite == 1))
	{
	#TWiki::Func::writeDebug("--- $filename");
	TWiki::Func::saveAttachment( $theWeb, $theTopic, my $result = $filename,
		{
			file => $tempFile,
			#filepath   => $tempName,
			comment => '-',
			hide => 0,
			filedate => time(),
			filesize => $filesize,
		} );
    
    TWiki::Func::setSessionValue('file_upload_attachment',0);

  	if ( $result eq $filename ) {
            TWiki::Func::writeDebug("- ${pluginName}::afterSaveHandler( $_[2].$_[1] - attachment:  $stream file name: $filename)")  if $debug;
        }
        else {
            TWiki::Func::writeDebug("$pluginName - An error occurred while attaching $filename")  if $debug;
            die "An error occurred while attaching $filename";
        }	
	
	}

	unlink($tempFile) if( $tempFile && -e $tempFile );
	
	#--------debug------------------vvvv
	#my $flag = TWiki::Func::getSessionValue('topic_saved');
	#TWiki::Func::writeDebug("$theWeb $theTopic $filename $filecomment $attExist---$overwrite");
	#--------debug------------------^^^


    #----------Update topic---------------------------------------------------------------------------vvv
	#my $datestring = strftime "%F %H:%M", localtime;
	my $datestring = strftime "%F", localtime;
	unless ($attExist)
	{
    TWiki::Func::setSessionValue('topic_saved', 1);
    TWiki::Func::setTopicEditLock( $theWeb, $theTopic, 0 );
    my $text = TWiki::Func::readTopicText( $theWeb, $theTopic);
	
    #Getting table header to add--------------vvv
	
	
	if ($tag)
	{
	$tag = '<!--' . $tag . '-->';
    }
	else
	{
	$tag = '<!--ATTACHMENTS-->';
	}
	
	my $t = quotemeta($tag);
	$text =~ m/$t(.*)$t/g;
	
	my $tableHeader = $tag . $1 . $tag;
	
	#Getting table header to add--------------^^^
	#TWiki::Func::writeDebug("--$tag-- --$1--");
	
    #Adding row to table----------------------vvv	
	my $Pattern1 = "$tableHeader" . "\n" . '| [[%ATTACHURL%/'. "$filename" . '][' . "$filename" . ']]' . " | $filecomment | $datestring |";
	my $Pattern0 = $tag . $1 . $tag;
	$text =~ s/\Q$Pattern0/$Pattern1/;
	#Adding row to table----------------------^^^

	
    $oopsUrl = TWiki::Func::saveTopicText( $theWeb, $theTopic, $text );
    TWiki::Func::setSessionValue('topic_saved', 0);
	
	
	} else
	#overwrite the file
	{
	  if(defined($overwrite) and $overwrite == 1)
	  {
	   TWiki::Func::setSessionValue('topic_saved', 1);
       TWiki::Func::setTopicEditLock( $theWeb, $theTopic, 0 );
	   my $text = TWiki::Func::readTopicText( $theWeb, $theTopic);
	   
	   #update table once uploaded----------------------------------vvv
	   $datestring .= " |";
	   
	   #ToDo - test:  replace comment and date
	   #$text =~ s/(^\s*?|.*?%ATTACHURL%\/$filename.*?\]\[.*?\]\]\s*?\|\s*?)(.*?)\|.*?\d{4}-\d+-\d+.*?\|/$1$filecomment\|$datestring/g;
	   
	   #debug-----
	    #$text =~ m/(^\s*?|.*?%ATTACHURL%\/$filename.*?\]\[.*?\]\]\s*?\|\s*?)(.*?)\|.*?\d{4}-\d+-\d+.*?\|/g;
	    #TWiki::Func::writeDebug("---$1---$2---$filename---");
	   #debug-----
	   
	   
	   #replace date
	   $text =~ s/(^\s*?|.*?%ATTACHURL%\/$filename.*?\]\[.*?\]\].*?)\d{4}-\d+-\d+.*?\|/$1$datestring/g;
	   
	   #update table once uploaded----------------------------------^^^
       
	  
       $oopsUrl = TWiki::Func::saveTopicText( $theWeb, $theTopic, $text );
       TWiki::Func::setSessionValue('topic_saved', 0);
	  }
	}
    #----------Update topic---------------------------------------------------------------------------vvv

return;
}

 
sub after_save_proceed
{
	#otherwise we get stuck in the loop saveTopic -> afterSave -> saveA...
	my $save_flag = TWiki::Func::getSessionValue('topic_saved');
	if(defined($save_flag) and $save_flag == 1)
	{
		TWiki::Func::setSessionValue('topic_saved', 0);
		return 0;
	}
	return 1;
}

sub after_attach_proceed
{
	#otherwise we get stuck in the loop saveAttachment -> afterSave -> saveA...
	my $attachment_flag = TWiki::Func::getSessionValue('file_upload_attachment');
	if(defined($attachment_flag) and $attachment_flag == 1)
	{
		TWiki::Func::setSessionValue('file_upload_attachment', 0);
		return 0;
	}
	return 1;
}

sub k82tr
     { ($_)=@_;
 
 #
 # Fonetic correct translit
 #
 
 s/Û»/S\'h/; s/”»/s\'h/; s/ÛË/S\'H/;
 s/˚/Sh/g; s/€/sh/g;
 
 s/Û√»/Sc\'h/; s/”√»/sc\'h/; s/Û„Ë/SC\'H/;
 s/˝/Sch/g; s/›/sch/g;
 
 s/„»/C\'h/; s/√»/c\'h/; s/„Ë/C\'H/;
 s/˛/Ch/g; s/ﬁ/ch/g;
 
 s/Í¡/J\'a/; s/ ¡/j\'a/; s/Í·/J\'A/;
 s/Ò/Ja/g; s/—/ja/g;
 
 s/Íœ/J\'o/; s/ œ/j\'o/; s/ÍÔ/J\'O/;
 s/≥/Jo/g; s/£/jo/g;
 
 s/Í’/J\'u/; s/ ’/j\'u/; s/Íı/J\'U/;
 s/‡/Ju/g; s/¿/ju/g;
 
 s/¸/E\'/g; s/‹/e\'/g;
 s/Â/E/g; s/≈/e/g;
 
 s/˙»/Z\'h/g; s/⁄»/z\'h/g; s/˙Ë/Z\'H/g;
 s/ˆ/Zh/g; s/÷/zh/g;
 
 

tr/¡¬◊«ƒ⁄… ÀÃÕŒœ–“”‘’∆»√ﬂŸÿ·‚˜Á‰˙ÈÍÎÏÌHÔÚÛÙıÊË„ˇ˘¯/abvgdzijklmnoprstufhc\"y\'ABVGDZIJKLMNOPRSTUFHC\"Y\'/;
 
 
 
 return $_;
 }
