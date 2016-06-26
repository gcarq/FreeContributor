#!/usr/bin/env bash
#
# FreeContributor: Enjoy a safe and faster web experience
# (c) 2016 by TBDS
# (c) 2016 by gcarq
# https://github.com/tbds/FreeContributor
# https://github.com/gcarq/FreeContributor (forked)
#
# FreeContributor is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

show_header() {
cat <<'EOF'

     _____               ____            _        _ _           _
    |  ___| __ ___  ___ / ___|___  _ __ | |_ _ __(_) |__  _   _| |_ ___  _ __
    | |_ | '__/ _ \/ _ \ |   / _ \| '_ \| __| '__| | '_ \| | | | __/ _ \| '__|
    |  _|| | |  __/  __/ |__| (_) | | | | |_| |  | | |_) | |_| | || (_) | |
    |_|  |_|  \___|\___|\____\___/|_| |_|\__|_|  |_|_.__/ \__,_|\__\___/|_|
    (gcarq fork)

    Enjoy a safe and faster web experience

    FreeContributor - https://github.com/gcarq/FreeContributor
    Released under the GPLv3 license
    (c) 2016 tbds, gcarq and contributors

EOF
}

show_usage() {
cat <<EOF

    FreeContributor is a script to extract and convert domain lists from various sources.

    USAGE:
      $ ${0} -f <format> -o <out> [-t target]
       -f <format>      specify an output format:
                              none          Extract domains only (default)
                              hosts         Use hosts format
                              dnsmasq       dnsmasq as DNS resolver
                              unbound       unbound as DNS resolver
                              pdnsd         pdnsd as DNS resolver
       -o <out>         specify an output file
       -t <target>      specify the target
                              ${TARGET} (default)
                              ${REDIRECTIP6}
                              NXDOMAIN
                              custom (e.g. 192.168.1.20)
       -h               show this help

    EXAMPLES:
      $ $0 -f hosts -t 0.0.0.0 -o hosts.blacklist
      $ $0 -f dnsmasq -t NXDOMAIN -o dnsmasq.blacklist
      $ $0 -f unbound -t ::1 -o unbound-ipv6.blacklist

EOF
}
