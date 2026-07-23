unit module Toolkit::CLI::Color;

=begin pod

=head1 SYNOPSIS

    use Toolkit::CLI::Color;

    say color-status('OPEN');
    say color-title('Incident #1234');
    say color-url('https://example.test/ticket/1234');
    say color-company('Acme Corp');

=end pod

use Terminal::ANSIColor;

sub color-status(Str:D $status --> Str:D) is export {
    given $status {
        when 'OPEN'     { colored($status, 'bold green') }
        when 'PENDING'  { colored($status, 'bold yellow') }
        when 'RESOLVED' { $status }
        when 'CLOSED'   { $status }
        default         { colored($status, 'cyan') }
    }
}

sub color-title(Str:D $title --> Str:D) is export {
    colored($title, 'bold');
}

sub color-url(Str:D $url --> Str:D) is export {
    colored($url, 'blue');
}

sub color-company(Str:D $name --> Str:D) is export {
    colored($name, 'cyan');
}
