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
        unless ($self->{msg}) {
            my $message = ($self->{modelname} . ' with Id: ' . $self->{id} . ' created!');
            $template->param(result_message => $message);
        } else {
            $template->param(result_message => $self->_format_msg);
        }
    } elsif ($self->{action} eq 'delete') {
        unless ($self->{msg}) {
            my $message = ($self->{modelname} . ' with Id: ' . $self->{id} . ' deleted!');
            $template->param(result_message => $message);
        } else {
            $template->param(result_message => $self->_format_msg);
        }
    } else {
        unless ($self->{msg}) {
            my $message = ($self->{modelname} . ' with Id: ' . $self->{id} . ' edited!');
            $template->param(result_message => $message);
        } else {
            $template->param(result_message => $self->_format_msg);
        }
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

sub set_template {
    my ($self, $new_value) = @_;
    $$self{template} = $new_value;
    return $self;
}
sub set_action {
    my ($self, $new_value) = @_;
    $$self{action} = $new_value;
    return $self;
}
sub set_modelname {
    my ($self, $new_value) = @_;
    $$self{modelname} = $new_value;
    return $self;
}
sub set_id {
    my ($self, $new_value) = @_;
    $$self{id} = $new_value;
    return $self;
}

sub set_msg {
    my ($self, $new_value) = @_;
    $$self{msg} = $new_value;
    return $self;
}
1;