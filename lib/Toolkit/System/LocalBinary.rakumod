unit module Toolkit::System::LocalBinary;

=begin pod

=head1 SYNOPSIS

    use Toolkit::System::LocalBinary;

    my $rg = resolve-binary(:name('rg'));
    my $result = run-local-command($rg, :args(['--version']));

    say $result.exit-code;
    say $result.stdout;

=end pod

class LocalCommandResult {
    has Int $.exit-code is required;
    has Str $.stdout is required;
    has Str $.stderr is required;
    has Str $.binary is required;
    has @.args;
}

sub run-local-command(
    Str:D $binary,
    :@args = [],
    Bool :$allow-nonzero = False,
    --> LocalCommandResult:D
) is export {
    my $proc = run $binary, |@args, :out, :err;
    my $stdout = $proc.out.slurp-rest;
    my $stderr = $proc.err.slurp-rest;
    my $exit-code = $proc.exitcode;

    if !$allow-nonzero && $exit-code != 0 {
        die "Command failed with exit code $exit-code using binary '$binary':\n$stderr";
    }

    LocalCommandResult.new(
        :$exit-code,
        :$stdout,
        :$stderr,
        :$binary,
        :@args,
    );
}

sub resolve-binary(
    Str:D :$name,
    Str :$candidate,
    --> Str:D
) is export {
    if $candidate.defined {
        return $candidate.IO.absolute.Str;
    }

    my $which = run-local-command('which', :args([$name]), :allow-nonzero(True));

    if $which.exit-code == 0 {
        my $path = $which.stdout.trim;
        return $path if $path.chars;
    }

    die "Could not find $name on PATH. Provide :candidate explicitly or install $name so `which $name` succeeds.";
}
