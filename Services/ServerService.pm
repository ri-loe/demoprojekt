package ServerService;
use strict;
use warnings FATAL => 'all';



sub new {
    my ($class, $dbh) = @_;
    my $self = bless {
            dbh => $dbh
        }, $class;
    return $self;
}


sub get_all_servers {
    my ($self, $dbh) = @_;
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
                id               => $server->get_id,
                name             => $server->get_name,
                operating_system => $server->get_os->get_name,
                storage          => $server->get_storage->get_storage_name,
                checksum         => $server->get_checksum,
                created_at       => $server->get_created_at,
                updated_at       => $server->get_updated_at
            };
    }
    return $all_servers;
}

1;