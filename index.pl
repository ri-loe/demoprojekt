#!/Users/c5261164/perl5/perlbrew/perls/perl-5.24.0/bin/perl
use strict;
use warnings FATAL => 'all';

use Services::DbConnector;
use CGI;
use DDP;
use Controller::FrontController;

CGI::initialize_globals;

my $db = DbConnector->new;
my $dbh = $db->connect;
my $cgi = CGI->new;

my $front = FrontController->new($cgi, $dbh);
$front->_handle_request;