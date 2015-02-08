package app;
use v5.14;
use Moo;

use db;
use zone;

has db => ( is => 'rw', builder => '_void');

has [qw/tmpdir database primarydnsserver secondarydnsserver/] 
=> qw/is ro required 1/;

sub _void { my $x = ''; \$x; }

sub BUILD {
    my ($self) = @_;
    $$self{db} = db->new(data => $self);
}

### users

sub auth {
    my ($self, $login, $passwd) = @_;
    ${$self->db}->auth($login, $passwd);
}

sub register_user {
    my ($self, $login, $passwd) = @_;
    ${$self->db}->register_user($login, $passwd);
}

sub toggle_admin {
    my ($self, $login) = @_;
    ${$self->db}->toggle_admin($login);
}

sub delete_user {
    my ($self, $login) = @_;
    my $domains = ${$self->db}->get_domains($login);
    $self->delete_domain($login, $_) foreach(@$domains);
    ${$self->db}->delete_user($login);
}

### domains 

sub _get_zone {
    my ($self, $domain) = @_; 
    zone->new( domain => $domain, data => $self );
}

sub add_domain {
    my ($self, $user, $domain) = @_; 
    $user->add_domain($domain);
    $self->_get_zone($domain)->addzone();
}

sub delete_domain {
    my ($self, $user, $domain) = @_; 
    $user->delete_domain($domain);
    $self->_get_zone($domain)->del();
}

sub modify_entry {
    my ($self, $domain, $entryToModify, $newEntry) = @_;
    $self->_get_zone($domain)->modify_entry( $entryToModify, $newEntry );
}

sub delete_entry {
    my ($self, $domain, $entryToDelete) = @_;
    $self->_get_zone($domain)->delete_entry( $entryToDelete );
}

sub update_domain_raw {
    my ($self, $zone, $domain) = @_; 
    $self->_get_zone($domain)->update_raw($zone);
}

sub update_domain {
    my ($self, $zone, $domain) = @_; 
    $self->_get_zone($domain)->update($zone);
}

sub get_domain {
    my ($self, $domain) = @_; 
    $self->_get_zone($domain)->get();
}

sub get_all_domains {
    my ($self) = @_; 
    # % domain login
    ${$self->db}->get_all_domains;
}

sub get_all_users {
    my ($self) = @_; 
    # % login admin
    ${$self->db}->get_all_users;
}

sub new_tmp {
    my ($self, $domain) = @_; 
    $self->_get_zone($domain)->new_tmp();
}

1;