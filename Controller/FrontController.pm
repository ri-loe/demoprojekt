package FrontController;
use strict;
use warnings FATAL => 'all';
use DDP;
    #(output => 'stdout');
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
    my ($self) = @_;
    my $cgi = $self->{cgi};
    my $template = HTML::Template->new(filename => 'Templates/storage_showall.tmpl');
    my $dbh = $self->{dbh};

    my $prep_query = $dbh->prepare("SELECT id, name, capacity, cast(created_at as timestamp(0))" .
        ", cast(updated_at as timestamp(0)) FROM storages ORDER BY id ASC;");
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
    if ($cgi->param('action') and $cgi->param('id')) {
        if($cgi->param('action') eq 'new') {
            my $message = ('Storage ' . $cgi->param('id') . ' created!');
            $template->param(result_message => $message);
        } elsif ($cgi->param('action') eq 'delete') {
            my $message = ('Storage ' . $cgi->param('id') . ' deleted!');
            $template->param(result_message => $message);
        } else {
            my $message = ('Storage ' . $cgi->param('id') . ' edited!');
            $template->param(result_message => $message);
        }
    }
    $template->param(all_storages => $all_storages);

    print $self->{cgi}->header(-type => 'text/html', -charset => 'utf-8');
    print $template->output;
}

# creates a new storage obj from from input data in the database
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
        print $self->{cgi}->redirect(-location => '/index.pl/storage/showall?action=new&id=' . $last_id);
    } else {
        print $self->{cgi}->header(-type => 'text/html', -charset => 'utf-8');
        print $template->output;
    }

}

# deletes a storage by GET id
sub _storage_delete {
    my ($self) = @_;
    my $cgi = $self->{cgi};
    my $dbh = $self->{dbh};

    if ( $cgi->request_method eq 'GET') {
        my $id = $cgi->param('id');

        my $prep_query = $dbh->prepare("DELETE FROM storages WHERE id = " . $id);
        $prep_query->execute();
        $dbh->commit();
        print $self->{cgi}->redirect(-location => '/index.pl/storage/showall?action=delete&id=' . $id);
    }
}

sub _storage_edit {
    my ($self) = @_;
    my $dbh = $self->{dbh};
    my $cgi = $self->{cgi};
    my $template = HTML::Template->new(filename => 'Templates/storage_edit.tmpl');

    my $storage = Storage->new;

    if ( $cgi->request_method eq 'GET') {
        my $id = $cgi->param('id');

        my $prep_query = $dbh->prepare("SELECT * FROM storages WHERE id = " . $id);
        $prep_query->execute();
        my @matches  = $prep_query->fetchrow_array;

        $storage->set_storage_id($matches[0]);
        $storage->set_storage_name($matches[1]);
        $storage->set_capacity($matches[2]);
        $storage->set_created_at($matches[3]);
        $storage->set_updated_at($matches[4]);

        # fill the form with data
        $template->param(id => $storage->get_storage_id);
        $template->param(name => $storage->get_storage_name);
        $template->param(capacity => $storage->get_capacity);
    }
    if ( $cgi->request_method eq 'POST') {
        $storage->set_storage_id($cgi->param('ipt_id'));
        $storage->set_storage_name($cgi->param('ipt_name'));
        $storage->set_capacity($cgi->param('ipt_capacity'));

        my $prep_query = $dbh->prepare("UPDATE storages SET "
            . "name='" . $storage->get_storage_name
            . "', capacity=" . $storage->get_capacity
            . " WHERE id=" . $storage->get_storage_id);
        $prep_query->execute();
        $dbh->commit();

        print $self->{cgi}->redirect(-location => '/index.pl/storage/showall?action=edit&id=' . $storage->get_storage_id);
    } else {
        print $self->{cgi}->header(-type => 'text/html', -charset => 'utf-8');
        print $template->output;
    }
}

# home screen
sub _index {
    my ($self) = @_;
    my $template = HTML::Template->new(filename => 'Templates/index.tmpl');
    print $self->{cgi}->header(-type => 'text/html', -charset => 'utf-8');
    print $template->output;
}

# show error screen
sub _show_errorpage {
    my ($self) = @_;
    my $template = HTML::Template->new(filename => 'Templates/error.tmpl');
    print $template->output;
}


1;
