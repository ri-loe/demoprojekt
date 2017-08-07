package StorageService;
use strict;
use warnings FATAL => 'all';
use Models::Storage;
use DDP;

# constructor
sub new {
    # class = class name
    my ($class) = @_;
    # second parameter module name
    my $self = bless {
        }, $class;
    return $self;
}

sub create {
    my ($self) = @_;
    $$self{storage} = Storage->new;
    return $self->{storage};
}

sub create_and_fill {
    my ($self, $id, $name, $capacity, $created_at, $updated_at) = @_;
    my $storage = $self->create;
    $storage->set_id($id)
        ->set_name($name)
        ->set_capacity($capacity)
        ->set_created_at($created_at)
        ->set_updated_at($updated_at);
    return $storage;
}


sub save_to_db {
    my ($self ,$dbh) = @_;
    my $storage = $self->{storage};
    my $prep_query = $dbh->prepare("INSERT INTO storages (name, capacity) VALUES ('"
        . $storage->get_name . "', "
        . $storage->get_capacity . ")");
    $prep_query->execute();
    $dbh->commit();
}

sub update_to_db {
    my ($self, $dbh, $storage, $id, $name, $capacity) = @_;

    $storage->set_name($name);
    $storage->set_capacity($capacity);

    my $prep_query = $dbh->prepare("UPDATE storages SET "
        . "name='" . $storage->get_name
        . "', capacity=" . $storage->get_capacity
        . " WHERE id=" . $id);
    $prep_query->execute();
    $dbh->commit();
}

sub delete_by_id {
    my ($self, $id, $dbh) = @_;

    my $prep_query = $dbh->prepare("DELETE FROM storages WHERE id = " . $id);
    $prep_query->execute();
    $dbh->commit();

}

sub get_storage_by_id {
    my ($self, $dbh, $id) = @_;

    my $prep_query = $dbh->prepare("SELECT * FROM storages WHERE id = " . $id);
    $prep_query->execute();
    my @matches  = $prep_query->fetchrow_array;

    return $self->create_and_fill($matches[0], $matches[1], $matches[2], $matches[3], $matches[4]);
}


sub get_all_storages {
    my ($self, $dbh) = @_;

    my $prep_query = $dbh->prepare("SELECT id, name, capacity, cast(created_at as timestamp(0))" .
    ", cast(updated_at as timestamp(0)) FROM storages ORDER BY id ASC;");
    $prep_query->execute();

    my $all_storages;
    while (my @row = $prep_query->fetchrow_array()) {
        my $storage = $self->create_and_fill($row[0], $row[1], $row[2], $row[3], $row[4]);
        push @{$all_storages},
        {
            id => $storage->get_id,
            name => $storage->get_name,
            capacity => $storage->get_capacity,
            created_at => $storage->get_created_at,
            updated_at => $storage->get_updated_at
        };
    }
    return $all_storages;
}

1;