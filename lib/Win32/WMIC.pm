package Win32::WMIC;

use warnings;
use strict;

use DBIx::Simple;
use SQL::Abstract;

=head1 NAME

Win32::WMIC - Access to the MS Windows Management Instrumentation Utility!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

WMIC extends WMI for operation from several command-line interfaces and
through batch scripts. Understand?

Essentially, MS Windows captures a crap-load of information about the
system, users, hadware, etc and now makes it available via the wmic
command-line utility.

See this URL for more details: [last checked Mon Dec 28 21:42:44 2009 ]
http://technet.microsoft.com/en-us/library/bb742610.aspx

Use it in Perl...

    use Win32::WMIC;

    my $wmic = Win32::WMIC->new();
    my $csv  = $wmic->query('process list')->data; # get processes
    my $data = $wmic->parse;

=cut

=head1 METHODS

=head2 new

I<the `new` method is used to instantiate a new Win32-WMIC object>

new B<arguments>

no arguments

new B<usage and syntax>

    my $wmic = Win32::WMIC->new;
    
    takes 0 arguments
    
    example:
    my $wmic = Win32::WMIC->new;

=cut

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    return $self;
}

=head2 query

I<the `query` method is used to issue commands against the wmic utility>

query B<arguments>

=over 3

=item L<$query|/"$query">

=back

query B<usage and syntax>

    $wmic->query($query);
    
    takes 1 argument
        1st argument  - required
            $query    - a single valid wmic command string
    
    example:
    my $query = 'useraccount list breif';
    $wmic->query($query);

=cut

sub query {
    my ($self, $query, $produce) = @_;
    die "No query specified" unless $query;
    
    my  $output = '';
    
    # other formats disabled currently
    $produce = 'csv';
    
    if ($produce) {
        if    ($produce eq "csv") {
            $produce = "CSV";
            $output  = '/format:csv.xsl';
        }
        elsif ($produce eq "tab") {
            $produce = "Tab";
            $output  = '';
        }
        elsif ($produce eq "xml") {
            $produce = "XML";
            $output  = '/format:rawxml.xsl';
        }
        else {
            die "Formatting not supported, $query";
        }
    }
    else {
        $produce = 'Tab';
    }
    $self->{query}  = "$query $output";
    $self->{query}  =~ s/^\s+|\s+$//g;
    $self->{format} = $produce;
    $self->{data}   = eval {`wmic $self->{query}`};
    $self->{data}   =~ s/^[\r\n\s]+//g;
    
    return $self;
}

=head2 data

I<the `data` method is used to output the raw unprocessed resultset returned
from the wmic query>

data B<arguments>

no arguments

data B<usage and syntax>

    $wmic->data;
    
    takes 0 arguments
            
    example:
    my $raw_resultset = $wmic->data;

=cut

sub data {
    my $self = shift;
    die "No resultset exists" unless $self->{data};
    return $self->{data};
}

=head2 parse

I<the `parse` method is used to produce a perl object from the wmic query
resultset>

parse B<arguments>

=over 3

=item L<\%where|/"\%where">, L<\@order|/"\@order">

=back

parse B<usage and syntax>

    my $data = $wmic->parse;
    
    takes 2 arguments
        1st argument  - optional
            $where    - a SQL::Abstract hashref where-clause construct
        2nd argument  - optional
            $order    - a SQL::Abstract arrayref order-clause construct
    
    example:
    my $data = $wmic->parse;

=cut

sub parse {
    my ($self, $where, $order) = @_;
    die 'No data available to parse' if !$self->{data};
    die 'Format unknown' if !$self->{format};
    
    my $db = DBIx::Simple->connect('dbi:AnyData(RaiseError=>1):');
        $db->dbh->func( 'resultset', $self->{format}, [$self->data], 'ad_import');
    my $results = $db->select("resultset", "*", $where, $order);
    
    return $results->hashes;
}

=head1 AUTHOR

Al Newkirk, C<< <awncorp at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-win32-wmic at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Win32-WMIC>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Win32::WMIC

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Win32-WMIC>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Win32-WMIC>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Win32-WMIC>

=item * Search CPAN

L<http://search.cpan.org/dist/Win32-WMIC/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2009 Al Newkirk, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Win32::WMIC
