# Keeptrying

tool for KPT note

## Installation

    $ gem install keeptrying

## Usage

### show KPT entries

	$ kpt show [-k|p|t] [days] (or kpt s)

### write a KPT entry (if omit message, open editor)

	$ kpt write -k|p|t [message] (or kpt w)

### mark with "done" flag.

	$ kpt done [days] (or kpt d)

### show entries (includes "done" entries)

	$ kpt all [-k|-p|-t] [days] (or kpt a)

### delete old entries (only with "done" flag)

	$ kpt truncate days (or kpt t)

## other options

### specify database file

	$ KPT_DB=~/databases/kpt.sqlite kpt show

### specify editor

	$ EDITOR=emacs kpt write -k

### uninstall

	unlink ~/.kpt directory (or specified database file)

## Contributing

1. Fork it ( http://github.com/<my-github-username>/keeptrying/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
