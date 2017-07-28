package FrontController;
use strict;
use warnings FATAL => 'all';
use DDP;


sub new {
    # class = class name
    my ($class, $cgi, $dbh, $template) = @_;

    # second parameter module name
    my $self = bless {
            cgi      => $cgi,
            dbh      => $dbh,
            template => $template,
        }, $class;
    return $self;
}

sub _handle_request {
    my ($self) = @_;

    # $self->get_path(); -> check for method -> load the method

    my $called_sub = $self->_get_called_sub();

    #checks if the called sub exists in Controller/FrontController.pm and calls it
    # or loads the error page
    if ($self->can($called_sub)) {
        $self->$called_sub;
    } else {
        $self->{template}->new(filename => 'Templates/error.tmpl');
    }
};

# gets the called sub from the GET params, returns "_index" if GET is empty;
sub _get_called_sub {
    my ($self) = @_;
    my $request_uri = $self->{cgi}->request_uri();

    my @matches = $request_uri =~m/(\w+)/g;

    # remove index and pl from matchlist
    splice(@matches, 0, 2);

    if (@matches) {
        my $called_sub = join('_', @matches);
        return '_' . $called_sub;
    } else {
        return '_index';
    }
}

# shows all storages
sub _storage_showall {
    my ($self) = @_;

    my $template = $self->{template};
    my $dbh = $self->{dbh};

    my $prep_query = $dbh->prepare("SELECT * FROM users ORDER BY id ASC;");
    $prep_query->execute();

    my $all_users;
    while (my @row = $prep_query->fetchrow_array()) {
        push @{$all_users},
        {
            user => $row[0],
            name => $row[1],
            first_name => $row[2],
            birthday => $row[3]
        }
        ;
    }
    $template->param(all_users => $all_users);
}

# home screen
sub _index {
    # home sweet home
}


1;