package Storage;
use strict;
use warnings FATAL => 'all';


my $storage_id;
my $storage_name;
my $capacity;
my $created_at;
my $updated_at;


sub new {
    my ($class) = @_;
    my $self = bless {}, $class;
    return $self;
}

sub get_storage_id {
    return $_[0]->{storage_id};
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

sub get_updated_at {
    return $_[0]->{updated_at};
}

1;