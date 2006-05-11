package Output::Rewrite;

use warnings;
use strict;
use Carp;


tie *STDOUT, "Output::Rewrite";

my %rewrite_rule;

sub import {
	my $class = shift;
	my %fields = @_;
	if(ref $fields{rewrite_rule} eq 'HASH'){
		my %new_rewrite_rule = %{$fields{rewrite_rule}};
		%rewrite_rule = (%rewrite_rule, %new_rewrite_rule);
	}
	
}

sub TIEHANDLE {
	my $class = shift;
	my $form = shift;
	my $self;
	open($self, ">&STDOUT");
	#$$self->{hoge} = 'fuga';
	bless $self, $class;
}

sub PRINT {
	my $self = shift;
	my $string = join('', @_);
	
	print $self $self->_rewrite($string);
}

sub PRINTF {
	my $self = shift;
	my $format = shift;
	$self->PRINT( $self->_rewrite( sprintf($format, @_) ) );
}

sub WRITE {
	my $self = shift;
	my $string = shift;
	my $length = shift || length $string;
	my $offset = shift || 0;
	
	syswrite($self, $self->_rewrite($string), $length, $offset);
}

sub _rewrite {
	my $self = shift;
	my $string = shift;
	
	while(my($from, $to) = each %rewrite_rule){
		eval "\$string =~ s/$from/$to/g;";
		croak "Output::Rewrite Rewrite error:\n" . $@ if $@;
	}
	
	return $string;
}


=head1 NAME

Output::Rewrite - Rewrite your script output.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use Output::Rewrite (
        rewrite_rule => {
            hoge => "fuga",
        }
    );
    print "hoge hogehoge\n";
    # fuga fugafuga
    
    
    
    use Output::Rewrite (
        rewrite_rule => {
            '(?<=\b)hoge(?=\b)' => "fuga",
        }
    );
    print "hoge hogehoge\n";
    # fuga hogehoge
    
    
    
    use Output::Rewrite (
        rewrite_rule => {
            '(\d)' => '$1!',
        }
    );
    print "1234 I love Marine Corps!\n";
    # 1!2!3!4! I love Marine Corps!
    

=head1 DESCRIPTION

This module helps you to rewrite your script output.

Set rewrite_rule(regex)  when you load this module.

    use Output::Rewrite (
        rewrite_rule => {
            'from' => 'to',
        }
    );



=head1 FUNCTIONS

There is no function.

=head1 AUTHOR

Hogeist, C<< <mahito at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-output-rewrite at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Output-Rewrite>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Output::Rewrite

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Output-Rewrite>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Output-Rewrite>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Output-Rewrite>

=item * Search CPAN

L<http://search.cpan.org/dist/Output-Rewrite>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2006 Hogeist, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Output::Rewrite
