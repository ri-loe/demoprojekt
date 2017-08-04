package FrontController;
use strict;
use warnings FATAL => 'all';
use DDP (output => 'stdout');
use HTML::Template;
use Models::Storage;
use Services::StorageService;

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

    my $storage = Storage->new();
    my $st_service = StorageService->new($storage);
    my $all_storages = $st_service->get_all_storages($dbh);

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
        my $name = $cgi->param('ipt_name') =s/<([^>]|\n)*>//g;
        my $capacity = $cgi->param('ipt_capacity') =s/<([^>]|\n)*>//g;

        #########################
        #   TODO:               #
        #   validate inserts    #
        #                       #
        #########################
        my $storage = Storage->new();
        my $st_service = StorageService->new($storage);
        $st_service->fill(undef, $name, $capacity, undef, undef)
            ->save_to_db($dbh);

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

    my $storage = Storage->new();
    my $st_service = StorageService->new($storage);

    if ( $cgi->request_method eq 'GET') {
        my $id = $cgi->param('id');

        $storage = $st_service->get_storage_by_id($dbh, $id);

        # fill the form with data
        $template->param(id => $storage->get_storage_id);
        $template->param(name => $storage->get_storage_name);
        $template->param(capacity => $storage->get_capacity);
    }
    if ( $cgi->request_method eq 'POST') {
        $st_service->update_to_db($dbh,$cgi->param('ipt_id'), $cgi->param('ipt_name'), $cgi->param('ipt_capacity'));

        print $self->{cgi}->redirect(-location => '/index.pl/storage/showall?action=edit&id=' . $cgi->param('ipt_id'));
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
