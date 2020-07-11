#!/usr/bin/perl
# check_identifiers.pl: Check use of reserved identifiers in C source code.
#
#    Copyright (C) 2020 University of Glasgow.
#
#    Author: John Marshall <John.W.Marshall@glasgow.ac.uk>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

use strict;
use warnings;

my %reserved;
while (<DATA>) {
    chomp;
    s/#.*//;
    $reserved{$_}++ if /\S/;
}

my $errors = 0;

foreach my $fname (@ARGV) {
    # Ignore klib headers
    next if $fname =~ m{/k(hash|list|seq|sort|string)\.h$};
    next if $fname =~ m{^k(netfile|string).c$};

    $_ = slurp_oneline($fname);
    s{/\*([^*]|\*[^/])*\*/}{}g;  # Remove multi-line /*...*/ comments
    s{//[^@]*@}{}g;  # Remove single-line // comments
    s{"([^"]|\\")*"}{}g;  # Remove string literals
    s{'[^']'}{}g;  # Remove char literals

    # Remove false positives due to token-pasting
    s/PLUGIN_GLOBAL\([^)]*\)//g;
    s/(KSORT_INIT\w*|ks_introsort)\([^,]*//g;

    my %bad;
    foreach (/\b_[A-Za-z0-9_]*/g) {
        $bad{$_}++ unless exists $reserved{$_} || exists $reserved{"$fname:$_"};
    }

    foreach (sort keys %bad) {
        print "$fname: $_\n";
        $errors++;
    }
}

exit ($errors > 0)? 1 : 0;

sub slurp_oneline
{
    my ($fname) = @_;

    my $text = "";
    open my $in, '<', $fname or die "$0: can't open '$fname': $!\n";
    while (<$in>) {
        s/[\r\n]*$/@/;
        $text .= $_;
    }
    close $in;
    return $text;
}

__DATA__
# Compiler/OS predefined macros and builtins
__builtin_clz
__clang__
__clang_major__
__cplusplus
__CYGWIN__
_DARWIN_USE_64_BIT_INODE
__FILE__
__func__
__GNUC__
__GNUC_MINOR__
__LINE__
__linux__
__MINGW32__
__MINGW_PRINTF_FORMAT
_MSC_VER
__MSYS__
__sun__
__svr4__
__SUNPRO_C
__VA_ARGS__
_WIN32

# Exceptions for particular identifiers at non-file scope in particular files
htslib/khash_str2int.h:_hash
htslib/kfunc.h:_left
htslib/kfunc.h:_right
htslib/synced_bcf_reader.h:_readers
bgzf.c:_dst
hts.c:_n
kfunc.c:_left
kfunc.c:_right
probaln.c:_beg
probaln.c:_end

# For hts_defs.h et al
__attribute__
__declspec
__deprecated__
__format__
__global
__has_attribute
__nonstring__
__noreturn__
__printf__
__unused__
__visibility__
__warn_unused_result__

# For hts_endian.h
__AAARCHEB__
__AARCH64EL__
__ARMEB__
__ARMEL__
__BIG_ENDIAN__
__BYTE_ORDER__
__LITTLE_ENDIAN__
_MIPSEB
_MIPSEL
__MIPSEB
__MIPSEB__
__MIPSEL
__MIPSEL__
__ORDER_BIG_ENDIAN__
__ORDER_LITTLE_ENDIAN__
__THUMBEB__
__THUMBEL__
__aligned__
__amd64
__amd64__
__i386
__i386__
__i686
__i686__
__x86_64
__x86_64__

# Windows functions etc
_chsize
_fileno
_get_osfhandle
_pclose
_popen
_O_BINARY
_O_TEXT
_setmode
