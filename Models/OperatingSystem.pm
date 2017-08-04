package OperatingSystem;
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
1;