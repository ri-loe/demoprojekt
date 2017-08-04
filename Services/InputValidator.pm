package InputValidator;
use strict;
use warnings FATAL => 'all';

# constructor
sub new {
    # class = class name
    my ($class) = @_;
    # second parameter module name
    my $self = bless {}, $class;
    return $self;
}


sub validate_name_input {
    my ($self, $name_input) = @_;

    $name_input =s/<([^>]|\n)*>//g;




    return $name_input;
}

sub validate_capacity_input {
    my ($self, $cap_input) = @_;

    $cap_input =s/<([^>]|\n)*>//g;


    return $cap_input;
}


1;