package Storage;
use strict;
use warnings FATAL => 'all';


sub new {
    my ($class) = @_;
    my $self = bless {}, $class;
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

sub get_name {
    return $_[0]->{name};
}

sub set_name {
    my ($self, $new_value) = @_;
    $$self{name} = $new_value;
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