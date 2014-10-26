package Chorus::Expert;

use 5.006;
use strict;
use warnings;

our $VERSION = '1.02';

=head1 NAME

Chorus::Expert - A simple skeleton of application using one or more Chorus::Engine objects (inference engines) 
                 working together on a common task.

=head1 VERSION

Version 1.02

=cut

=head1 SYNOPSIS

Chorus::Expert does 3 simple things :

  1 - Registers one or more Chorus::Engine objects
  2 - Provides to each of them a shared working area ($SELF->BOARD)
  3 - Enter an infinite loop on each inference engine until one of them declares the system as SOLVED.

   package A;
      
   use Chorus::Engine;
   our $agent = Chorus::Engine->new();
   $agent->addrule(...);

   # --
      
   package B;
   use Chorus::Engine;
   our $agent = Chorus::Engine->new();
   $agent->addrule(...);
   
   # --
     
   use Chorus::Expert;
   use A;
   use B;
   
   my $xprt = Chorus::Expert->new();
   $xprt->register($A::agent);
   $xprt->register($B::agent);
   
   $xprt->process();

=cut

use Chorus::Frame; 

my @agents = ();
my $board  = Chorus::Frame->new();

sub new {
  my $class = shift;
  return bless {}, $class;
}

=head1 SUBROUTINES/METHODS

=head2 register

   use Chorus::Expert;
   use Chorus::Engine;
   
   my $xprt = Chorus::Expert->new();

   my $e1 = Chorus::Engine->new();  # inference engine 1
   my $e2 = Chorus::Engine->new();  # inference engine 2

   $xprt->register($e1,$e2);        # $e1 and $2 added to the list of agents
                                    # providing to all of them a shared attribute named BOARD
   
=cut

sub register {
	my $this = shift;
	$_->set('BOARD', $board) for @_; 
	push @agents, @_;
	return $this;
}

=head2 process

   Tells the Chorus::Expert object to enter in an infinite loop until one of the engines 
   set the attribute $SELF->BOARD->{SOLVED} to something true. 
   The Chorus::Expert object will ask its agents, one after one, to test all its rules with all
   possible combinations of its _SCOPE attributes. An agent never ends while at least one of its rules 
   returns a true value in the same loop (see Chorus::Engine documentation).  
   
   $xprt->process();            # without argument
   $xprt->process($something);  # this argument will become $SELF->BOARD->INPUT for all agents
   
=cut

sub process {
  my ($this, $input) = @_;
  $board->set('INPUT', $input);
  do { 
  	   for (@agents) {
  	   $_->loop() unless $board->{SOLVED}; 
       } 
  } until ($board->{SOLVED});
  $board->delete('SOLVED');
}

=head1 AUTHOR

Christophe Ivorra, C<< <ch.ivorra at free.fr> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-chorus-expert at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Chorus-Expert>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Chorus::Expert


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Chorus-Expert>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Chorus-Expert>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Chorus-Expert>

=item * Search CPAN

L<http://search.cpan.org/dist/Chorus-Expert/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Christophe Ivorra.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

END { }

1; # End of Chorus::Expert
