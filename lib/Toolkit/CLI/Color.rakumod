unit module Toolkit::CLI::Color;

=begin pod

=head1 SYNOPSIS

    use Toolkit::CLI::Color;

    # Generic ANSI styling helper.
    say set-color('Warning', 'bold red');
    say set-color('Note', 'underline cyan');
    say set-color('Link', 'blue');

    # Mid-string coloring: only color one segment.
    say 'you have 3 ' ~ set-color('errors', 'red');

=end pod

use Terminal::ANSIColor;

sub set-color(Str:D $text, Str:D $style --> Str:D) is export {
    colored($text, $style);
}
