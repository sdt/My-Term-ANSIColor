#!/usr/bin/perl -Tw
#
# t/config.t -- testing the optional config file functionality
#
use strict;
use Test::More tests => 22;

my $got_unknown_color_warning;

BEGIN {
    $ENV{TERM_ANSICOLOR_CONFIG} = 't/config.rc';
    delete $ENV{ANSI_COLORS_DISABLED};

    local $SIG{__WARN__} = sub {
        if ($_[0] =~ /Ignoring unknown color unknown at /) {
            $got_unknown_color_warning = 1;
        }
        else {
            warn $_[0];
        }
    };

    use_ok 'Term::ANSIColor',
            qw/color colored uncolor colorvalid/;
}

# Check the custom colors all get assigned. They use varying line formats
# in the config file and should all parse correctly.
for my $original (qw( black red green blue )) {
    my $custom = 'custom_' . $original;
    ok (colorvalid ($custom), "custom $original is valid");
    is (color ($custom), color ($original),
        "custom $custom matches $original with color()");
    is (colored ('test', $custom), colored ('test', $original),
        "custom $custom matches $original with colored()");
    is ((uncolor(color($custom)))[0], $original,
        "uncolor works for $custom back to $original");
}

# custom_unknown is mapped to an unknown color and should not appear
my $output = eval { color('custom_unknown') };
is ($output, undef, 'unknown color mapping fails');
ok ($got_unknown_color_warning, '... with a parse warning');
like ($@, qr/^Invalid attribute name custom_unknown at /,
    ' ...with the right error');

# Check that the commented out colors don't get mapped
for (1 .. 2) {
    my $custom = 'custom_' . $_;
    ok (!colorvalid ($custom), "commented out $custom is not valid");
}
