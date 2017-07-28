#!/Users/c5261164/perl5/perlbrew/perls/perl-5.24.0/bin/perl
use strict;
use warnings FATAL => 'all';

use HTML::Template;
use Services::DbConnector;
use CGI;
use DDP;
use Controller::FrontController;

CGI::initialize_globals;

# open the html template
my $template = HTML::Template->new(filename => 'Templates/index.tmpl');
my $db = DbConnector->new();
my $dbh = $db->connect();
my $cgi = CGI->new();

my $front = FrontController->new($cgi, $dbh, $template);
$front->_handle_request;

print $cgi->header(-type => 'text/html', -charset => 'utf-8'),
    $template->output,
    $cgi->end_html;


