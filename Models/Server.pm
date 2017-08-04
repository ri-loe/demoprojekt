package Server;
use strict;
use warnings FATAL => 'all';

sub new {
    my ($class) = @_;
    my $self = bless {}, $class;
    return $self;
}

sub get_os {
    return $_[0]->{os};
}
sub set_os {
    my ($self, $new_value) = @_;
    $$self{os} = $new_value;
    return $self;
}
sub get_checksum {
    return $_[0]->{checksum};
}
sub set_checksum {
    my ($self, $new_value) = @_;
    $$self{checksum} = $new_value;
    return $self;
}
sub get_name {
    return $_[0]->{name};
}
sub set_name {
    my ($self, $new_value) = @_;
    $$self{name} = $new_value;
    return $self;
}
sub get_id {
    return $_[0]->{id};
}
sub set_id {
    my ($self, $new_value) = @_;
    $$self{id} = $new_value;
    return $self;
}
sub get_storage {
    return $_[0]->{storage};
}
sub set_storage {
    my ($self, $new_value) = @_;
    $$self{storage} = $new_value;
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
sub get_created_at {
    return $_[0]->{created_at};
}
sub set_created_at {
    my ($self, $new_value) = @_;
    $$self{created_at} = $new_value;
    return $self;
}

1;