# drudge-raku-toolbox

Reusable Raku modules for local command execution, ripgrep-backed search, and ANSI color formatting.

## Modules

- `Toolkit::System::LocalBinary`
- `Toolkit::Search::Ripgrep`
- `Toolkit::CLI::Color`

## Setup

1. Install dependencies:

```bash
zef install --deps-only .
```

2. Use modules via `-Ilib` during local development, or install with `zef install .`.

## Use In Another Project

1. Choose an install source.

From a local checkout:

```bash
zef install ../drudge-raku-toolbox
```

From git:

```bash
zef install git@github.com:drudgesentinel/drudge-raku-toolbox.git
```

2. Import modules in your project as needed.

```raku
use Toolkit::System::LocalBinary;
use Toolkit::Search::Ripgrep;
use Toolkit::CLI::Color;
```

3. For call examples, see the POD comments in each module.

## Notes

- Ripgrep binary resolution order:
  1. `:binary('/path/to/rg')` passed to `search-text`
  2. `which rg` on PATH
