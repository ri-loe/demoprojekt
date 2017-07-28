use strict;
use warnings FATAL => 'all';

package storage;

my $storage_id;
my $storage_name;
my $capacity;
my $created_at;
my $updated_at;


sub new {
    my ($proto) = @_;
    my $self = bless {}, $proto;
    return $self;
}

sub get_storage_id {
    return $_[0]->{storage_id};
}

sub set_storage_id {
    my ($self, $new_value) = @_;
    $$self{storage_id} = $new_value;
    return $self;
}

sub get_storage_name {
    return $_[0]->{storage_name};
}

sub set_storage_name {
    my ($self, $new_value) = @_;
    $$self{storage_name} = $new_value;
    return $self;
}

sub get_capacity {
    return $_[0]->{capacity};
}

sub set_capacity {
    my ($self, $new_value) = @_;
    $$self{capacity} = $new_value;
    return $self;
}

sub get_created_at {
    return $_[0]->{created_at};
}

sub set_created_at {
    my ($self, $new_value) = @_;
    $$self{created_at} = $new_value;
    return $self;
}
sub get_updated_at {
    return $_[0]->{updated_at};
}

sub set_updated_at {
    my ($self, $new_value) = @_;
    $$self{updated_at} = $new_value;
    return $self;
}

1;