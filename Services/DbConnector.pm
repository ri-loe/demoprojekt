use strict;
use warnings FATAL => 'all';

use DBI;
use DDP;


package DbConnector;

my $singleton;

# DB Infos
my $db_host = 'dev.local';
my $db_user = 'c5261164';
my $db_pass = '';
my $db_name = 'demo_db';


sub new {
    my $class = shift;
    $singleton ||= bless {}, $class;
}

sub connect {
    my ($self) = @_;
    if (not exists $self->{dbh}) {
        # establish DB connection
        my $db = "DBI:Pg:dbname=${db_name};host=${db_host}";
        $self->{dbh} = DBI->connect($db, $db_user, $db_pass, { RaiseError => 1, AutoCommit => 0 })
            || die "Error connecting to the database: $DBI::errstr\n";
    }
    return $self->{dbh};
}

1;