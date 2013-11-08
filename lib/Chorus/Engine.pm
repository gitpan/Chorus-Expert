package Chorus::Engine;

=head1 NAME

Chorus::Engine - A very light INFERENCE ENGINE combined with the FRAME model for knowledge representation.

=head1 VERSION

Version 0.01

=cut

=head1 INTRODUCTION

    Chorus-Engine makes possible to simply develop in Perl with an Articial Intelligence approach 
    by defining the knowledge with rules the inference engine will try to apply on your objects.
    
    Because inference engines use to waste a lot of time before finding interesting instanciations
    for rules, the property _SCOPE is used to optimise the space on which each rule must be tested.
    
    This not necessary but, uou can combinate Chorus::Engine with Chorus::Frame which gives a first level 
    for knowledge representation. The inference engine can then work on Frames using the function 'fmatch' 
    top optimise the _SCOPE for the rules which work on frames.  

=cut

=head1 SYNOPSIS

    use Chorus::Engine;

    my $agent = new Chorus::Engine();
    
    $agent->addrule(

      _SCOPE => {             # These arrays will be combinated as parameters (HASH) when calling _APPLY
             a => $subset,    # static array_ref
             b => sub { .. }  # returns an array ref
      },
      
      _APPLY => sub {
        my %opts = @_;        # provides $opt{a},$opt{b} (~ one combinaison of _SCOPE)

        if ( .. ) {
          ..                  
          return 1;           # rule could be applied (~ something has changed)
        }

        return undef;         # rule didn't apply
      }
    );
    
    $agent->loop();

=head1 SUBROUTINES/METHODS

=head2 addrule();
       Defines a new rule for the Chorus::Engine object
       
       arguments :
        
         _SCOPE : a hashtable defining the variables and their search scope for instanciation
                  Values must be SCALAR or ARRAY_REF
                                        
         _APPLY : function which will be called in a loop with all the possible 
                  combinaisons from scopes on a & b 
                  
       Ex. use Chorus::Engine;
           use Chorus::Frames;
           
           my $e=Chorus::Engine->new();
           
           $e->addrule(
                  
              _SCOPE => {

                  foo  => [ fmatch( .. ) ],         # selection of Frames bases on the filter 'fmatch' (static)
                  bar  => sub { [ fmatch( .. ) ] }, # same kind more dynamic 
                  baz  => [ .. ]                    # any other array (not only frames)

              },
                  
              _APPLY => {
                         my %opts = @_;          # provides $opt{foo},$opt{bar},$opt{baz}
        	             
                         return undef if ( .. ); # rule didn't apply

                         if ( .. ) {
                           ..             # some actions
                           return 1;      # rule could be applied
                         }
       
                         return undef;    # rule didn't apply (last instruction)
              });
             
       
=head2 loop();
       Tells the Chorus::Engine object to enter its inference loop.
       The loop will end only after all rules fail (~ return false) in the same iteration
       
           Ex. my $agent = new Chorus::Engine();
           
               $agent->addrule( .. ); # rule 1
               ..
               $agent->addrule( .. ); # rule n

               $agent->loop();

=head2 cut();
       Tells the Chorus::Engine object to go directly to the next rule (same loop). This will break 
       all nested instanciation loops on _SCOPE in the current rule.
       
           Ex. $agent->addrule(
             _SCOPE => { .. },
             _APPLY => sub {
              if ( .. ) {
                 $SELF->cut();                 # ~ exit this rule now
              }

              if ( .. ) {
                 $SELF->BOAD->{SOLVED} = 'Y' ; # ~ ends everything now
              }
           );


=head2 sleep();
       Disable a Chorus::Engine object until call to wakeup(). In this mode, the method loop() has no effect.
       This method can optimise the application by de-activating a Chorus::Engine object until it has 
       a good reason to work (ex. when a certain state is reached in the application ). 
       
=head2 wakeup();
       Enable a Chorus::Engine object -> will try again to apply its rules after next call to loop()
=cut

our $VERSION = '0.01';

use 5.006;
use strict;
use warnings;

use Chorus::Frame;

sub applyrules {
    my $stillworking = undef;
    return undef if $SELF->{_SLEEPING};
    foreach my $rule (@{$SELF->{_RULES}}) {
      my (%opts, $res);
      my %scope = map { 
      	  my $s = $rule->getN("_SCOPE $_");
      	  $_ => ref($s) eq 'ARRAY' ? $s : [$s || ()] 
      } grep { $_ ne '_KEY'} keys(%{$rule->{_SCOPE}});
      
      my $i = 0;
  	  my $head = 'LONGJUMP: {' . join("\n", map { $i++; 'foreach my $k' . $i . ' (@{$scope{' . $_ . '}})' . " {\n\t" . '$opts{' . $_ . '}=$k' . $i . ";" 
  	  }  keys(%scope)) . "\n";
  	  my $body = '$res = $rule->getN(\'_APPLY\', %opts); last LONGJUMP if ($SELF->{_BREAKING} or $SELF->BOARD->SOLVED)';
  	  my $tail = "\n}" x scalar(keys(%scope)) . '}';
      eval $head . $body . $tail; warn $@ if $@;
      $stillworking ||= $res;
      delete $SELF->{_BREAKING} if $SELF->{_BREAKING};
    }
    return $stillworking;
}

sub new {
	return Chorus::Frame->new(
	 _RULES  => [],
     cut     => sub { $SELF->{_BREAKING} = 'Y' },
     loop    => sub { do {} while(applyrules() and ! $SELF->BOARD->SOLVED) },      
     addrule => sub { push @{$SELF->{_RULES}}, Chorus::Frame->new(@_) },
     sleep   => sub { $SELF->{_SLEEPING} = 'Y' },
     wakeup  => sub { $SELF->delete('_SLEEPING')},
	)
}

=head1 AUTHOR

Christophe Ivorra, C<< <ch.ivorra at free.fr> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-chorus-engine at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Chorus-Engine>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Chorus::Engine


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Chorus-Engine>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Chorus-Engine>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Chorus-Engine>

=item * Search CPAN

L<http://search.cpan.org/dist/Chorus-Engine/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Christophe Ivorra.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Chorus::Engine
