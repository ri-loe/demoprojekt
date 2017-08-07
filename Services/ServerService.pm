package ServerService;
use strict;
use warnings FATAL => 'all';

use Models::Server;
use Digest::MD5 qw(md5_hex);


sub new {
    my ($class, $dbh) = @_;
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
    my $prep_query = $dbh->prepare("INSERT INTO servers (name, os_id, storage_id, checksum) VALUES ('"
        . $server->get_name . "', "
        . $server->get_os->get_id . ", "
        . $server->get_storage->get_id  . ", '"
        . $server->get_checksum . "')");
    $prep_query->execute();
    $dbh->commit();
}


sub get_all_servers {
    my ($self, $dbh) = @_;
    my $prep_query = $dbh->prepare("SELECT *
        FROM servers, operating_systems, storages
        WHERE operating_systems.id = servers.os_id AND storages.id = servers.storage_id");
    $prep_query->execute();

    my $all_servers;
    while (my @row = $prep_query->fetchrow_array()) {
        my $storage = StorageService->new->create_and_fill($row[9], $row[10], $row[11], $row[12], $row[13]);

        my $os = OsService->new->create_and_fill($row[7], $row[8]);

        my $server = $self->create;
        $server = $server->set_id($row[0])->set_name($row[1])->set_storage($storage)->set_os($os)
            ->set_checksum($row[4])->set_created_at($row[5])->set_updated_at($row[6]);

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
    return $all_servers;
}

1;