package FrontController;
use strict;
use warnings FATAL => 'all';
use DDP {
    output => 'stdout'
};
use HTML::Template;
use Models::Storage;

# constructor
sub new {
    # class = class name
    my ($class, $cgi, $dbh) = @_;

    # second parameter module name
    my $self = bless {
            cgi => $cgi,
            dbh => $dbh,
        }, $class;
    return $self;
}

sub _handle_request {
    my ($self) = @_;

    my $called_sub = $self->_get_called_sub();
    #checks if the called sub exists in Controller/FrontController.pm and calls it
    # or loads the error page
    if ($self->can($called_sub)) {
        $self->$called_sub;
    } else {
        $self->_show_errorpage();
    }
};

# gets the called sub from the GET params, returns "_index" if GET is empty;
sub _get_called_sub {
    my ($self) = @_;
    my $request_uri = $self->{cgi}->_name_and_path_from_env;
    my @matches = $request_uri =~m/(\w+)/g;

    # add _ at start for "private" method nameing
    if (@matches) {
        my $called_sub = join('_', @matches);
        return '_' . $called_sub;
    } else {
        return '_index';
    }
}

# shows all storages
sub _storage_showall {
    my ($self, $success_message) = @_;

    my $template = HTML::Template->new(filename => 'Templates/storage_showall.tmpl');
    my $dbh = $self->{dbh};

    my $prep_query = $dbh->prepare("SELECT * FROM storages ORDER BY id ASC;");
    $prep_query->execute();

    my $all_storages;
    while (my @row = $prep_query->fetchrow_array()) {
        push @{$all_storages},
        {
            id => $row[0],
            name => $row[1],
            capacity => $row[2],
            created_at => $row[3],
            updated_at => $row[4]
        }
        ;
    }
    if ($success_message) {
        $template->param(result_message => $success_message);
    }
    $template->param(all_storages => $all_storages);
    print $template->output;
}

# creates a new storage obj in the database
sub _storage_new {
    my ($self) = @_;
    my $dbh = $self->{dbh};
    my $template = HTML::Template->new(filename => 'Templates/storage_new.tmpl');
    my $cgi = $self->{cgi};

    if ( $cgi->request_method eq 'POST') {
        my $name = $cgi->param('ipt_name');
        my $capacity =scalar $cgi->param('ipt_capacity');

        #########################
        #   TODO:               #
        #   validate inserts    #
        #                       #
        #########################

        my $storage = Storage->new;
        $storage->set_storage_name($name);
        $storage->set_capacity($capacity);

        my $prep_query = $dbh->prepare("INSERT INTO storages (name, capacity) VALUES ('"
            .  $storage->get_storage_name . "', "
            . $storage->get_capacity . ")");
        $prep_query->execute();
        $dbh->commit();
        my $last_id = $dbh->last_insert_id(undef, undef, 'storages', undef);
        $self->_storage_showall('Storage ' . $last_id . ' successfully created!');
    }
    print $template->output;
}

# deletes a storage by id
sub _storage_delete {
    my ($self) = @_;
    my $cgi = $self->{cgi};
    my $dbh = $self->{dbh};

    if ( $cgi->request_method eq 'GET') {
        my $id = $cgi->param('id');

        my $prep_query = $dbh->prepare("DELETE FROM storages WHERE id = " . $id);
        $prep_query->execute();
        $dbh->commit();

        $self->_storage_showall('Storage ' . $id . ' deleted!');
    }
}

sub _storage_edit {
    my ($self) = @_;
    my $dbh = $self->{dbh};
    my $cgi = $self->{cgi};
    my $template = HTML::Template->new(filename => 'Templates/storage_edit.tmpl');

    if ( $cgi->request_method eq 'GET') {
        my $id = $cgi->param('id');

        my $prep_query = $dbh->prepare("SELECT * FROM storages WHERE id = " . $id);
        $prep_query->execute();
        my @matches  = $prep_query->fetchrow_array;

        my $storage = Storage->new;
        $storage->set_storage_id($matches[0]);
        $storage->set_storage_name($matches[1]);
        $storage->set_capacity($matches[2]);
        $storage->set_created_at($matches[3]);
        $storage->set_updated_at($matches[4]);

        $template->param(id => $storage->get_storage_id);
        $template->param(name => $storage->get_storage_name);
        $template->param(capacity => $storage->get_capacity);
    }
    print $template->output;
}

# home screen
sub _index {
    my ($self) = @_;
    my $template = HTML::Template->new(filename => 'Templates/index.tmpl');
    print $template->output;
}

# show error screen
sub _show_errorpage {
    my ($self) = @_;
    my $template = HTML::Template->new(filename => 'Templates/error.tmpl');
    print $template->output;
}

1;
