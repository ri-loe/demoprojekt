package OsService;
use strict;
use warnings FATAL => 'all';

use Models::OperatingSystem;

sub new {
    my ($class) = @_;
    my $self = bless {}, $class;
    return $self;
}

sub create {
    my ($self) = @_;
    $$self{op_system} = OperatingSystem->new;
    return $self->{op_system};
}

sub create_and_fill {
    my ($self, $id, $name) = @_;
    my $os = $self->create;
    $os->set_id($id)
        ->set_name($name);
    return $os;
}



sub get_all_os {
    my ($self, $dbh) = @_;
    my $prep_query = $dbh->prepare("SELECT *
        FROM operating_systems");
    $prep_query->execute();

    my $all_oss;
    while (my @row = $prep_query->fetchrow_array()) {
        my $os = $self->create_and_fill($row[0], $row[1]);

        push @{$all_oss},
            {
                os_id               => $os->get_id,
                os_name             => $os->get_name,
            };
    }
    return $all_oss;
}

sub get_os_by_id {
    my ($self, $dbh, $id) = @_;
    my $prep_query = $dbh->prepare("SELECT *
        FROM operating_systems WHERE id=" . $id);
    $prep_query->execute();

    my @matches  = $prep_query->fetchrow_array;

    return $self->create_and_fill($matches[0], $matches[1]);

}


1;