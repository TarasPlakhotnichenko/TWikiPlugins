package TWiki::Plugins::ActivityReportPlugin;
use strict;
use DBI;
use vars qw( $VERSION $RELEASE $SHORTDESCRIPTION $debug $pluginName $NO_PREFS_IN_TOPIC );
$VERSION = '$Rev: 1 (2012-08-23) $';
$RELEASE = '2012-08-23';

#192.168.215.68
#USE [interquik]
#GO
#declare @Date varchar(8) EXEC  dbo.ActivityReportForNAG @Date='20130228'

$SHORTDESCRIPTION = 'ActivityReport plugin';
$NO_PREFS_IN_TOPIC = 0;
$pluginName = 'ActivityReportPlugin';

sub initPlugin {
    my( $topic, $web, $user, $installWeb ) = @_;
	TWiki::Func::registerTagHandler( 'ActivityReport', \&_ActivityReport );

    return 1;
}

#%ActivityReport{"20120211" ActivityReportDate="20120823"}%

sub _ActivityReport {
    my($session, $params, $theTopic, $theWeb) = @_;
	my $ActivityReportDate = $params->{_DEFAULT};
	
	my @dump=();
	
	#my $default_date = $params->{_DEFAULT} || '';
	#my $ActivityReportDate = $params->{ActivityReportDate} || '';
	
	my $data_source = q/dbi:ODBC:mssql_68/;
    my $user = q/nagios/;
    my $password = q/Nag4Read/;
    
	
	if ($ActivityReportDate eq '-')
	{
	 return "";
	}
	else
	{
	 $ActivityReportDate =~ s/-//g; 
	 my $dbh = DBI->connect($data_source, $user, $password);
	 $dbh->{'LongTruncOk'} = 1;
     $dbh->{'LongReadLen'} = 200;
	
	 #my $sth = $dbh->prepare("declare \@Date varchar(8) EXEC  dbo.TestForNAG  \@Date=$ActivityReportDate");
     #$sth->execute(); 
     #my $data = $sth->fetchrow_arrayref;
	 #return "Parameter passed - $ActivityReportDate Returned: @$data[0]";
	 
	 my $line = "<noautolink>\n|*TradeDate* | *ClientCode* | *MarketName* | *Orders* | *Trades* |*percent* | *Volume* |\n";
	 push(@dump,$line);
	 my $sth = $dbh->prepare("declare \@Date varchar(8) EXEC  dbo.ActivityReportForNAG \@Date=$ActivityReportDate");
     $sth->execute(); 
     my $data = $sth->fetchrow_arrayref; 
     $line = join (' ',@$data) . "\n";
	 push(@dump,$line);
	 
     eval
     {
     $SIG{'ALRM'} = sub { die 'Timeout' };
     alarm(120);
     while($data = $sth->fetchrow_arrayref) 
     {
      $line = join (' ',@$data) . "\n";
	  push(@dump,$line);
     }
     alarm(0);
     };
	 
	 $line = "</noautolink>\n";
	 push(@dump,$line);
	 return "@dump";
	 
	}
}
