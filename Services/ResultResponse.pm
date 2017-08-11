package ResultResponse;
use strict;
use warnings FATAL => 'all';
use DDP;

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
        my $message = ($self->{modelname} . ' with Id: ' . $self->{id} . ' created!');
        $template->param(result_message => $message);
    } elsif ($self->{action} eq 'delete') {
        unless ($self->{msg}) {
            my $message = ($self->{modelname} . ' with Id: ' . $self->{id} . ' deleted!');
            $template->param(result_message => $message);
        } else {
            $template->param(result_message => $self->_format_msg);
        }
    } else {
        my $message = ($self->{modelname} . ' with Id: ' . $self->{id} . ' edited!');
        $template->param(result_message => $message);
    }
}

sub format_error_msg {
    my ($self, $raw) = @_;
    my @matches = $raw =~ m/(\w+)/g;
    my $err_str = join('_', @matches);
    my @err_splice = $err_str =~m /(DETAIL\w+)/;
    my $msg = $err_splice[0];
    $msg =~s /DETAIL/Error/;
    return $msg;
}

sub _format_msg {
    my ($self) = @_;
    my $msg = $self->{msg};
    $msg =~s /_/ /g;
    return $msg;
}

1;