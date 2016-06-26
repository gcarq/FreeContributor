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

cat <<EOF
#
# /etc/hosts
#
# Last updated: $(date +"%m-%d-%Y")
#
# This hosts file is a merged collection of hosts from reputable sources
# using FreeContributor
# (c) 2016 by TBDS
# https://github.com/tbds/FreeContributor
#
# All Credits:
# Peter Lowe - pgl [at] yoyo.org - https://pgl.yoyo.org/
# AdAway: Kicelo, Dominik Schuermann - https://free-software-for-android.github.io/AdAway/
# MalwareDomainList.com Hosts List - http://www.malwaredomainlist.com
# MVPS HOSTS - http://winhelp2002.mvps.org/hosts.htm
# Dan Pollock - hosts [at] someonewhocares.org - http://someonewhocares.org/hosts
# DShield.org Suspicious Domain List - info [at] dshield.org - http://www.dshield.org/
# Ransomware tracker - https://ransomwaretracker.abuse.ch/blocklist/
# Zeus tracker - https://zeustracker.abuse.ch/
# Palevo tracker - https://palevotracker.abuse.ch/
# Feodo tracker - https://feodotracker.abuse.ch/
# Airelle - http://rlwpx.free.fr/WPFF/hosts.htm
# Disconnect -  support [at] disconnect.me
# Spam404 - admin [at] spam404.com - http://www.spam404.com/
# AdBlock filter - http://www.gjtech.net/
# WindowsSpyBlocker - webmaster [at] crazyws.fr - https://github.com/crazy-max/WindowsSpyBlocker
#
#
#<ip-adress>    <hostname.domain.org>   <hostname>
127.0.0.1       localhost
127.0.0.1       $(hostname -f)    $(hostname)
127.0.0.1       localhost.localdomain
127.0.0.1       local
255.255.255.255 broadcasthost
#
# The following lines are desirable for IPv6 capable hosts
#
::1         localhost
fe80::1%lo0 localhost
::1         ip6-localhost ip6-loopback
fe00::0     ip6-localnet
ff00::0     ip6-mcastprefix
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
#
#
EOF
