package ResultResponse;
use strict;
use warnings FATAL => 'all';

sub new {
    my ($class,$model_name , $template, $action, $id, $msg) = @_;
    my $self = bless {
            modelname      => $model_name,
            template => $template,
            action   => $action,
            id       => $id,
            msg  => $msg
        }, $class;
    return $self;
}

sub print_result_message {
    my ($self) = @_;
    my $template = $self->{template};

    if($self->{action} eq 'new') {
        my $message = ($self->{modelname} . ' ' . $self->{id} . ' created!');
        $template->param(result_message => $message);
        return 1;
    } elsif ($self->{action} eq 'delete') {
        my $message = ($self->{modelname} . ' ' . $self->{id} . ' deleted!');
        $template->param(result_message => $message);
        return 1;
    } else {
        my $message = ($self->{modelname} . ' ' . $self->{id} . ' edited!');
        $template->param(result_message => $message);
        return 1;
    }
}

1;