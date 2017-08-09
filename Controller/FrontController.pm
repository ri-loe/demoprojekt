package FrontController;
use strict;
use warnings FATAL => 'all';
use DDP (output => 'stdout');
use HTML::Template;
use Models::Server;
use Models::OperatingSystem;
use Services::ResultResponse;
use Services::StorageService;
use Services::ServerService;
use Services::OsService;
use Services::InputValidator;

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
    my $request_path = $self->{cgi}->_name_and_path_from_env;
    my @matches = $request_path =~m/(\w+)/g;

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

    if ($cgi->param('error')) {
        my $err_str = $cgi->param('error');
        $err_str =~s /_/ /g;
        $template->param(result_message => $err_str);
    }

    if ( $cgi->request_method eq 'POST') {
        my $name = $cgi->param('ipt_name');
        my $capacity = $cgi->param('ipt_capacity');

        my $ipt_validator = InputValidator->new();
        $name = $ipt_validator->validate_name_input($name);
        $capacity = $ipt_validator->validate_capacity_input($capacity);

        my $st_service = StorageService->new();
        $st_service->create_and_fill(undef, $name, $capacity);
        $st_service->save_to_db($dbh);

        if ($st_service->{db_error}) {
        #    print $self->{cgi}->header(-type => 'text/html', -charset => 'utf-8');
            my @matches = $st_service->{db_error} =~m/(\w+)/g;
            my $err_str = join('_', @matches);
            print $self->{cgi}->redirect(-location => '/index.pl/storage/new?error=' . $err_str);
        } else {
            my $last_id = $dbh->last_insert_id(undef, undef, 'storages', undef);
            print $self->{cgi}->redirect(-location => '/index.pl/storage/showall?action=new&id=' . $last_id);
        }

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
        $template->param(id => $storage->get_id);
        $template->param(name => $storage->get_name);
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
    print $self->{cgi}->header(-type => 'text/html', -charset => 'utf-8');
    print $template->output;
}

sub _server_showall {
    my ($self) = @_;

    my $cgi = $self->{cgi};
    my $template = HTML::Template->new(filename => 'Templates/server_showall.tmpl');
    my $dbh = $self->{dbh};

    my $all_servers = ServerService->new()->get_all_servers($dbh);

    if ($cgi->param('action') and $cgi->param('id')) {
        my $rp = ResultResponse->new('Server ', $template, $cgi->param('action'), $cgi->param('id'), 1);
        $rp->print_result_message;
    }

    $template->param(all_servers => $all_servers);

    print $self->{cgi}->header(-type => 'text/html', -charset => 'utf-8');
    print $template->output;
}

sub _server_new {
    my ($self) = @_;
    my $dbh = $self->{dbh};
    my $template = HTML::Template->new(filename => 'Templates/server_new.tmpl');
    my $cgi = $self->{cgi};

    my $os_service = OsService->new;
    my $st_service = StorageService->new;

    if ($cgi->request_method eq 'POST') {
        my $server_name = $cgi->param('ipt_name');
        my $sel_os_id = $cgi->param('select_os');
        my $sel_stor_id = $cgi->param('select_storage');

        my $sel_os = $os_service->get_os_by_id($dbh, $sel_os_id);
        my $sel_stor = $st_service->get_storage_by_id($dbh, $sel_stor_id);

        my $serv_service = ServerService->new;
        my $checksum = $serv_service->create_checksum($server_name, $sel_os_id, $sel_stor_id);

        $serv_service->create_and_fill(undef, $server_name, $sel_os, $sel_stor, $checksum);
        $serv_service->save_to_db($dbh);

        my $last_id = $dbh->last_insert_id(undef, undef, 'servers', undef);
        print $self->{cgi}->redirect(-location => '/index.pl/server/showall?action=new&id=' . $last_id);
    }
    else {
        $template->param(all_oss => $os_service->get_all_os($dbh));
        $template->param(all_storages => $st_service->get_all_storages($dbh));
        print $self->{cgi}->header(-type => 'text/html', -charset => 'utf-8');
        print $template->output;
    }
}

sub server_edit {


}

sub server_delete {
    my ($self) = @_;
    my $cgi = $self->{cgi};
    my $dbh = $self->{dbh};

    if ( $cgi->request_method eq 'GET') {
        my $id = $cgi->param('id');

        ServerService->new()->delete_by_id($id, $dbh);

        print $self->{cgi}->redirect(-location => '/index.pl/server/showall?action=delete&id=' . $id);
    }
}

1;
