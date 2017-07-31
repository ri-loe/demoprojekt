package FrontController;
use strict;
use warnings FATAL => 'all';
use DDP {
    output => 'stdout'
};
use HTML::Template;

# constructor
sub new {
    # class = class name
    my ($class, $cgi, $dbh) = @_;

    # second parameter module name
    my $self = bless {
            cgi      => $cgi,
            dbh      => $dbh,
        }, $class;
    return $self;
}

sub _handle_request {
    my ($self) = @_;

    my $called_sub = $self->_get_called_sub();
    my %called_sub_with_param = _extract_get_param($called_sub);

    #checks if the called sub exists in Controller/FrontController.pm and calls it
    # or loads the error page
    if ($self->can($called_sub_with_param{'called_sub'})) {
        my $subcall = $called_sub_with_param{'called_sub'};
        # supply the get param if it exist
        if ($called_sub_with_param{'get_param'}) {
            $self->$subcall($called_sub_with_param{'get_param'});
        } else {
            $self->$subcall;
        }
    } else {
        _show_errorpage();
    }
};

# gets the called sub from the GET params, returns "_index" if GET is empty;
sub _get_called_sub {
    my ($self) = @_;
    my $request_uri = $self->{cgi}->request_uri();

    my @matches = $request_uri =~m/(\w+)/g;

    # remove index and pl from matchlist
    splice(@matches, 0, 2);

    # add _ at start for "private" method nameing
    if (@matches) {
        my $called_sub = join('_', @matches);
        return '_' . $called_sub;
    } else {
        return '_index';
    }
}

# extracts the "get" param from the URL, returns a hash with the called sub and the param (value or undef)
sub _extract_get_param {
    my ($request_string) = @_;

    my @match = $request_string =~m/(\_\d+)/;
    my $get_param = undef;
    if (@match) {
        # ommits the _ from the number
        $get_param = $match[0]=~ s/_//;
        # ommit the get param from the string
        $request_string =~ s/(\_\d+)//;
    }

    return ('called_sub' => $request_string, 'get_param' => $get_param);
}


# shows all storages
sub _storage_showall {
    my ($self) = @_;

    my $template = HTML::Template->new(filename => 'Templates/storage_showall.tmpl');
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
            birthday => $row[3],
            last_updated => $row[4]
        }
        ;
    }
    $template->param(all_users => $all_users);
    print $template->output;
}

# creates a new storage obj in the database
sub _storage_new {
    my ($self) = @_;
    my $dbh = $self->{dh};
    my $template = HTML::Template->new(filename => 'Templates/storage_new.tmpl');
    my $cgi = $self->{cgi};

    if ( $cgi->request_method eq 'POST') {
        my $name = $cgi->param('text_name');
        $template->param(test => $name);
    }
    # wenn POST dann
    # new Storage Obj ->setStuff



    print $template->output;
}

# deletes a storage by id
sub _storage_delete {
    my ($self, $id) = @_;

    my $template = HTML::Template->new(filename => 'Templates/test.tmpl');

    $template->param(test => $id);




    print $template->output;
}





# home screen
sub _index {
    my $template = HTML::Template->new(filename => 'Templates/index.tmpl');
    print $template->output;
}

# show error screen
sub _show_errorpage {
    my $template = HTML::Template->new(filename => 'Templates/error.tmpl');
    print $template->output;
}

1;
