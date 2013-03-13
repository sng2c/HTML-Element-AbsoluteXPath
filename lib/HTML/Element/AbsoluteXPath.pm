use strict;
use warnings;
package HTML::Element::AbsoluteXPath;

# ABSTRACT: Add absolute XPath to HTML::Element support

# VERSION

sub HTML::Element::abs_xpath{
    my $self = shift;
    my @hint = @_;
   
    push(@hint,'_tag') unless grep{$_ eq '_tag'}@hint;

    my $r = $self->root();
    my @lin;
    my $ee = $self; 
    while( $ee->same_as($r)==0 ){
        my $p = $ee->parent();
        my %filters;
        foreach (sort @hint){
            $filters{$_} = $ee->attr($_) if $ee->attr($_);
        }   
        my @sib = $p->look_down(%filters);

        @sib = grep{$_->depth() == $ee->depth()}@sib;
        my $idx = 1;
        foreach (@sib){
            last if $_->same_as($ee);
            $idx++;
        }   

        my @attrs;
        foreach (keys %filters){
            next if $_ eq '_tag';
            my $v = $filters{$_};
            next unless $v; 
            my $pat = "\@$_='$v'";
            push(@attrs,$pat);
        }   
        my $_depth = '>' x $ee->depth();

        my $attr = ''; 
        $attr = "[".join(' and ',@attrs)."]" if @attrs;

        push(@lin, $ee->tag() . $attr . "[$idx]" );
        $ee = $p; 
    }   
    push(@lin, $ee->tag() );
    return '/'.join('/',reverse @lin);
}


=pod

=head1 SYSNOPSIS

    use HTML::Element;
    use HTML::Element::AbsoluteXPath;

    ...

    print $elem->abs_xpath;
    # output like '/html/body/div[0]'

more

    use 5.010;
    use HTML::TreeBuilder->new;
    use HTML::Element::AbsoluteXPath;
    
    my $root = HTML::TreeBuilder->new;
    my $html = <<END;
    <html>
        <body>
            <div id="test" class="testclass"></div>
            <div class="testclass"></div>
            <div>
                <div class="innerclass"></div>
                <div></div>
            </div>
        </body>
    </html>
    END
    $root->parse($html);
    $root->eof();

    # get abs xpath of root
    say $root->abs_xpath; # '/html' 
    
    my @found = $root->find_by_tag_name('div');
    
    # get abs xpath
    say $found[0]->abs_xpath; # '/html/body[1]/div[1]' 
    
    # get abs xpath with 'id' hint.
    say $found[0]->abs_xpath('id'); #, "/html/body[1]/div[\@id='test'][1]"
    
    # get abs xpath with 'id' and 'class' hints.
    say $found[0]->abs_xpath('id','class'); # "/html/body[1]/div[\@id='test' and \@class='testclass'][1]"
    
    # get abs xpath hints for elem has just 'class' attr.
    say $found[1]->abs_xpath('id','class'); # "/html/body[1]/div[\@class='testclass'][2]"
    
    # get abs xpath with hints for elem has no attrs
    say $found[2]->abs_xpath('id','class'); # "/html/body[1]/div[3]"
    
    # get abs xpath overwrapped one
    say $found[2]->content->[0]->abs_xpath('id','class'); # "/html/body[1]/div[3]/div[\@class='innerclass'][1]"
    
    # get abs xpath overwrapped sibling
    say $found[2]->content->[1]->abs_xpath('id','class'); # "/html/body[1]/div[3]/div[2]"

=head1 DESCRIPTION

HTML::Element::AbsoluteXPath adds ABSOLUTE XPath support to HTML::Element.
'abs_xpath' method is added.

It generates smarter XPath with HINTS which are attributes name of HTML element, like 'class','id','width','name'...


=head1 METHODS

=head3 abs_xpath( [ $hint, ... ] )

Returns absolute xpath of current HTML::Element object.

Hints are optional. Internally, '_tag' is added to hints.
With no hints, it generates a xpath with only ordinary expressions like "/html[1]/body[1]/div[1]", "/html[1]/body[1]/a[13]".
If you set 'class' as hint, it generates a smarter xpath like "/html[1]/body[1]/div[@class='SOME'][1]","/html[1]/body[1]/div[2]".

Hints work for being matched attribute names which have values.

=cut

=head1 SEE ALSO

=over

=item *

L<HTML::TreeBuilder>

=item *

L<HTML::TreeBuilder::XPath>

=item *

L<HTML::Element>

=back

=head1 SOURCE

L<https://github.com/sng2c/HTML-Element-AbsoluteXPath>

=cut

1;
