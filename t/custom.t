#!/usr/bin/perl -Tw
#
# t/config.t -- testing the custom user colors functionality
#
use strict;
use Test::More tests => 23;

my @expected_warnings;
my @unexpected_warnings;

BEGIN {
    $ENV{TERM_ANSICOLOR_CUSTOM_COLORS} = join(',',
        ' custom_black = black',
        'custom_red= red',
        'custom_green =green ',
        'custom_blue=blue',
        'custom_unknown=unknown',
        '=no_new',
        'no_old=',
        'no_equals',
    );
    delete $ENV{ANSI_COLORS_DISABLED};

    # Test::Warn instead maybe?
    local $SIG{__WARN__} = sub {
        my ($msg) = @_;
        if ($msg =~ /(?:Bad|Unknown) color mapping/) {
            push(@expected_warnings, $msg);
        }
        else {
            warn $msg;
            push(@unexpected_warnings, $msg);
        }
    };

    use_ok 'Term::ANSIColor',
            qw/color colored uncolor colorvalid/;
}

# Check that the appropriate warnings got issued
ok(grep(/Unknown color mapping "unknown"/, @expected_warnings),
    'Got unknown old color warning');
for my $bad (qw( =no_new no_old= no_equals )) {
    ok(grep(/Bad color mapping "$bad"/, @expected_warnings),
        "Got warning for \"$bad\"");
}
is(scalar @unexpected_warnings, 0, "No unexpected warnings");


# Check the custom colors all get assigned. They use various spacing formats
# and should all parse correctly.
for my $original (qw( black red green blue )) {
    my $custom = 'custom_' . $original;
    ok (colorvalid ($custom), "$custom is valid()");
    is (color ($custom), color ($original),
        "custom $custom matches $original with color()");
    is (colored ('test', $custom), colored ('test', $original),
        "custom $custom matches $original with colored()");
    is ((uncolor(color($custom)))[0], $original,
        "uncolor works for $custom back to $original");
}


# custom_unknown is mapped to an unknown color and should not appear
ok(! colorvalid('custom_unknown'), 'unknown color mapping fails');
