package ServerService;
use strict;
use warnings FATAL => 'all';

use Models::Server;
use Digest::MD5 qw(md5_hex);


sub new {
    my ($class) = @_;
    my $self = bless {}, $class;
    return $self;
}

sub create_checksum {
    my ($self, $server_name, $os_id, $stor_id) = @_;

    my $string = $server_name . $os_id . $stor_id;
    return md5_hex($string);
}

sub create {
    my ($self) = @_;
    $$self{server} = Server->new;
    return $self->{server};
}

sub create_and_fill {
    my ($self, $id, $name, $os, $storage, $checksum, $created_at, $updated_at) = @_;
    my $server = $self->create;
    $server->set_id($id)
        ->set_name($name)
        ->set_os($os)
        ->set_storage($storage)
        ->set_checksum($checksum)
        ->set_created_at($created_at)
        ->set_updated_at($updated_at);
    return $server;
}

sub save_to_db {
    my ($self ,$dbh) = @_;
    my $server = $self->{server};
    eval {
        my $prep_query = $dbh->prepare("INSERT INTO servers (name, os_id, storage_id, checksum) VALUES ('"
            . $server->get_name . "', "
            . $server->get_os->get_id . ", "
            . $server->get_storage->get_id . ", '"
            . $server->get_checksum . "')");
        $prep_query->execute();
        $dbh->commit();
    };
    if ($@) {
        $self->{db_error} = $dbh->errstr;
    }
}


sub get_all_servers {
    my ($self, $dbh) = @_;
    my $all_servers;

    eval {
        my $prep_query = $dbh->prepare("SELECT *
            FROM servers, operating_systems, storages
            WHERE operating_systems.id = servers.os_id AND storages.id = servers.storage_id");
        $prep_query->execute();

        while (my @row = $prep_query->fetchrow_array()) {
            my $storage = StorageService->new->create_and_fill($row[9], $row[10], $row[11], $row[12], $row[13]);

            my $os = OsService->new->create_and_fill($row[7], $row[8]);

            my $server = $self->create_and_fill($row[0], $row[1], $os, $storage, $row[4], $row[5], $row[6]);

            push @{$all_servers},
                {
                    id               => $server->get_id,
                    name             => $server->get_name,
                    operating_system => $server->get_os->get_name,
                    storage          => $server->get_storage->get_name,
                    checksum         => $server->get_checksum,
                    created_at       => $server->get_created_at,
                    updated_at       => $server->get_updated_at
                };
        }
    };
    if ($@) {
        $self->{db_error} = $dbh->errstr;
    } else {
        return $all_servers;
    }
}

sub get_server_by_id {
    my ($self, $dbh, $id) = @_;
    my $result;
    eval {
        my $prep_query = $dbh->prepare("SELECT * FROM servers WHERE id = " . $id);
        $prep_query->execute();
        my @matches = $prep_query->fetchrow_array;

        my $sel_os   = OsService->new->get_os_by_id($dbh, $matches[2]);
        my $sel_stor = StorageService->new->get_storage_by_id($dbh, $matches[3]);

        $result = $self->create_and_fill($matches[0], $matches[1], $sel_os, $sel_stor,
            $matches[4], $matches[5], $matches[6]);
    };
    if ($@) {
        $self->{db_error} = $dbh->errstr;
    } else {
        return $result;
    }
}

sub delete_by_id {
    my ($self, $id, $dbh) = @_;
    eval {
        my $prep_query = $dbh->prepare("DELETE FROM servers WHERE id = " . $id);
        $prep_query->execute();
        $dbh->commit();
    };
    if ($@) {
        $self->{db_error} = $dbh->errstr;
    }
}

sub update_to_db {
    my ($self, $dbh, $server, $id, $name, $os, $storage) = @_;

    $server->set_name($name);
    $server->set_os($os);
    $server->set_storage($storage);
    $server->set_checksum($self->create_checksum($name, $os->get_id, $storage->get_id));
    eval {
        my $prep_query = $dbh->prepare("UPDATE servers SET "
            . "name='" . $server->get_name
            . "', os_id=" . $server->get_os->get_id
            . ", storage_id=" . $server->get_storage->get_id
            . ", checksum='" . $server->get_checksum . "'"
            . " WHERE id=" . $id);
        $prep_query->execute();
        $dbh->commit();
    };
    if ($@) {
        $self->{db_error} = $dbh->errstr;
    }
}

1;