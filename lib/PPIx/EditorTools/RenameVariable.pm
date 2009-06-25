package PPIx::EditorTools::RenameVariable;

use strict;
use warnings;
use Carp;

use base 'PPIx::EditorTools'; 
use Class::XSAccessor;

our $VERSION = '0.04';

=head1 NAME

PPIx::EditorTools::RenameVariable - Lexically replace a variable name in Perl code

=head1 SYNOPSIS
    
    my $munged = PPIx::EditorTools::RenameVariable->new->rename(
        code        => $code,
        line        => 15,
        column      => 13,
        replacement => 'stuff',
    );
    my $code_as_strig = $munged->code;
    my $code_as_ppi   = $munged->ppi;
    my $location      = $munged->element->location;

=head1 DESCRIPTION

This module will lexically replace a variable name.

=head1 METHODS

=over 4

=item new()

Constructor. Generally shouldn't be called with any arguments.

=item rename( ppi => PPI::Document $ppi, line => Int, column => Int, replacement => Str )
=item rename( code => Str $code, line => Int, column => Int, replacement => Str )

Accepts either a C<PPI::Document> to process or a string containing
the code (which will be converted into a C<PPI::Document>) to process.
Renames the variable found at line, column with that supplied in the C<replacement>
parameter and returns a C<PPIx::EditorTools::ReturnObject> with the
new code available via the C<ppi> or C<code> accessors, as a 
C<PPI::Document> or C<string>, respectively. The C<PPI::Token> found at
line, column is available via the C<element> accessor.

Croaks with a "no token" exception if no token is found at the location.
Croaks with a "no declaration" exception if unable to find the declaration.

=back

=cut

sub rename {
    my ( $self, %args ) = @_;
    $self->process_doc( %args );
    my $replacement = $args{replacement} || croak "replacement required";
    my $column      = $args{column}      || croak "column required";
    my $line        = $args{line}        || croak "line required";

    my $doc = $self->ppi;
    $doc->index_locations();

    # TODO: can we find from inside the variable name?
    my $token = $doc->find_first(
        sub {
            my $elem = $_[1];
            return 0 if not $elem->isa('PPI::Token');
            my $loc = $elem->location;
            return 0
              if $loc->[0] != $line
                  or $loc->[1] != $column;
            return 1;
        },
    );
    die "no token found" unless defined $token;

    my $declaration = PPIx::EditorTools::find_variable_declaration($token);
    die "no declaration" unless defined $declaration;

    my $scope = $declaration;
    while ( not $scope->isa('PPI::Document')
        and not $scope->isa('PPI::Structure::Block') )
    {
        $scope = $scope->parent;
    }

    my $token_str = $token->content;
    my $varname   = $token->symbol;

    #warn "VARNAME: $varname";

    # TODO: This could be part of PPI somehow?
    # The following string of hacks is simply for finding symbols in quotelikes and regexes
    my $type = substr( $varname, 0, 1 );
    my $brace = $type eq '@' ? '[' : ( $type eq '%' ? '{' : '' );

    my @patterns;
    if ( $type eq '@' or $type eq '%' ) {
        my $accessv = $varname;
        $accessv =~ s/^\Q$type\E/\$/;
        @patterns = (
            quotemeta( _curlify($varname) ),
            quotemeta($varname),
            quotemeta($accessv) . '(?=' . quotemeta($brace) . ')',
        );
        if ( $type eq '%' ) {
            my $slicev = $varname;
            $slicev =~ s/^\%/\@/;
            push @patterns,
              quotemeta($slicev) . '(?=' . quotemeta($brace) . ')';
        } elsif ( $type eq '@' ) {
            my $indexv = $varname;
            $indexv =~ s/^\@/\$\#/;
            push @patterns, quotemeta($indexv);
        }
    } else {
        @patterns = (
            quotemeta( _curlify($varname) ),
            quotemeta($varname) . "(?![\[\{])"
        );
    }
    my %unique;
    my $finder_regexp =
      '(?:' . join( '|', grep { !$unique{$_}++ } @patterns ) . ')';

    $finder_regexp =
      qr/$finder_regexp/;    # used to find symbols in quotelikes and regexes
                             #warn $finder_regexp;

    $replacement =~ s/^\W+//;

    $scope->find(
        sub {
            my $node = $_[1];
            if ( $node->isa("PPI::Token::Symbol") ) {
                return 0 unless $node->symbol eq $varname;

                # TODO do this without breaking encapsulation!
                $node->{content} =
                  substr( $node->content(), 0, 1 ) . $replacement;
            }
            if ( $type eq '@' and $node->isa("PPI::Token::ArrayIndex") )
            {    # $#foo
                return 0
                  unless substr( $node->content, 2 ) eq substr( $varname, 1 );

                # TODO do this without breaking encapsulation!
                $node->{content} = '$#' . $replacement;
            } elsif ( $node->isa("PPI::Token") )
            {    # the case of potential quotelikes and regexes
                my $str = $node->content;
                if (
                    $str =~ s{($finder_regexp)([\[\{]?)}<
				        if ($1 =~ tr/{//) { substr($1, 0, ($1=~tr/#//)+1) . "{$replacement}$2" }
				        else              { substr($1, 0, ($1=~tr/#//)+1) . "$replacement$2" }
				    >ge
                  )
                {

                    # TODO do this without breaking encapsulation!
                    $node->{content} = $str;
                }
            }
            return 0;
        },
    );

    return PPIx::EditorTools::ReturnObject->new(
        ppi => $doc,
        element => $token, );
}

sub _curlify {
    my $var = shift;
    if ( $var =~ s/^([\$\@\%])(.+)$/${1}{$2}/ ) {
        return ($var);
    }
    return ();
}

1;

__END__

=head1 SEE ALSO

This class inherits from C<PPIx::EditorTools>. 
Also see L<App::EditorTools>, L<Padre>, and L<PPI>.

=head1 AUTHOR

Mark Grimes, E<lt>mgrimes@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Mark Grimes

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
