package FrontController;
use strict;
use warnings FATAL => 'all';
use DDP (output => 'stdout');
use HTML::Template;
use Models::Server;
use Models::OperatingSystem;
use Services::StorageService;
use Services::ResultResponse;

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

    my $all_storages = StorageService->new()->get_all_storages($dbh);

    if ($cgi->param('action') and $cgi->param('id')) {
        my $rp = ResultResponse->new('Storage', $template, $cgi->param('action'), $cgi->param('id'), 1);
        $rp->print_result_message;
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
        my $capacity = $cgi->param('ipt_capacity');

        #########################
        #   TODO:               #
        #   validate inserts    #
        #                       #
        #########################
        my $st_service = StorageService->new();
        my $storage = $st_service->fill(undef, $name, $capacity);
        $st_service->save_to_db($storage, $dbh);

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

        StorageService->new()->delete_by_id($id, $dbh);

        print $self->{cgi}->redirect(-location => '/index.pl/storage/showall?action=delete&id=' . $id);
    }
}

sub _storage_edit {
    my ($self) = @_;
    my $dbh = $self->{dbh};
    my $cgi = $self->{cgi};
    my $template = HTML::Template->new(filename => 'Templates/storage_edit.tmpl');

    my $st_service = StorageService->new();
    my $storage = $st_service->create;

    if ( $cgi->request_method eq 'GET') {
        my $id = $cgi->param('id');

        $storage = $st_service->get_storage_by_id($dbh, $id);

        # fill the form with data
        $template->param(id => $storage->get_storage_id);
        $template->param(name => $storage->get_storage_name);
        $template->param(capacity => $storage->get_capacity);
    }
    if ( $cgi->request_method eq 'POST') {
        $st_service->update_to_db($dbh, $st_service->{storage}, $cgi->param('ipt_id'),
            $cgi->param('ipt_name'), $cgi->param('ipt_capacity'));

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

sub _server_showall {
    my ($self) = @_;

    my $cgi = $self->{cgi};
    my $template = HTML::Template->new(filename => 'Templates/server_showall.tmpl');
    my $dbh = $self->{dbh};

    my $prep_query = $dbh->prepare("SELECT *
        FROM servers, operating_systems, storages
        WHERE operating_systems.id = servers.os_id AND storages.id = servers.storage_id");
    $prep_query->execute();

    my $all_servers;
    while (my @row = $prep_query->fetchrow_array()) {
        my $storage = Storage->new;
        $storage = StorageService->new($storage)->fill($row[9], $row[10], $row[11], $row[12], $row[13]);

        my $os = OperatingSystem->new;
        $os->set_id($row[7])
            ->set_name($row[8]);

        my $server = Server->new;
        $server = $server->set_id($row[0])->set_name($row[1])->set_storage($storage)->set_os($os)
            ->set_checksum($row[4])->set_created_at($row[5])->set_updated_at($row[6]);

        push @{$all_servers},
        {
            id => $server->get_id,
            name => $server->get_name,
            operating_system => $server->get_os->get_name,
            storage => $server->get_storage->get_storage_name,
            checksum => $server->get_checksum,
            created_at => $server->get_created_at,
            updated_at => $server->get_updated_at
        };
    }

    if ($cgi->param('action') and $cgi->param('id')) {
        my $rp = ResultResponse->new('Server', $template, $cgi->param('action'), $cgi->param('id'), 1);
        $rp->print_result_message;
    }

    $template->param(all_servers => $all_servers);

    print $self->{cgi}->header(-type => 'text/html', -charset => 'utf-8');
    print $template->output;

#    'SELECT servers.id,servers.name, storages.name AS storage, operating_systems.name AS operating_system,
#                        checksum, servers.created_at, servers.updated_at
#    FROM servers, operating_systems, storages
#    WHERE operating_systems.id = servers.os_id AND storages.id = servers.storage_id';
}

1;
