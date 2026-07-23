unit module Toolkit::CLI::Color;

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
