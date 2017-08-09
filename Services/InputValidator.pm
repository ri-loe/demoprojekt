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

    #remove html tags
    $name_input =s/<([^>]|\n)*>//g;
    $name_input = $self->trim($name_input);

    return $name_input;
}

sub validate_capacity_input {
    my ($self, $cap_input) = @_;

    # trim html tags
    $cap_input =s/<([^>]|\n)*>//g;
    $cap_input = $self->trim($cap_input);

    # only didgets
    my @matches = $cap_input=~m/(\d+)/g;
    $cap_input = join('', @matches);
    return $cap_input;
}

# trim leading and trailing whitespaces
sub trim {
    my ($self, $string) = @_;

    $string =~s/\s+$//;
    return $string;
}


1;