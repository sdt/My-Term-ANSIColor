#!/usr/bin/perl -Tw
#
# t/config.t -- testing the optional config file functionality
#
use strict;
use Test::More tests => 19;

BEGIN {
    $ENV{TERM_ANSICOLOR_CONFIG} = 't/config.rc';
    delete $ENV{ANSI_COLORS_DISABLED};

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
    is ((uncolor(color($custom)))[0], $custom,
        "uncolor works for $custom");
}

# Check that the commented out colors don't get mapped
for (1 .. 2) {
    my $custom = 'custom_' . $_;
    ok (!colorvalid ($custom), "commented out $custom is not valid");
}
