#!/usr/bin/env bash
#
# FreeContributor: Enjoy a safe and faster web experience
# (c) 2016 by TBDS
# https://github.com/tbds/FreeContributor
#
# FreeContributor is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Simple script that pulls ad blocking host files from different providers
# and combines them to use as a DNS resolver file.
#
# Dependencies:
#  * GNU bash
#  * GNU coreutils (sed, grep)
#  * GNU wget or cURL
#
## Global Variables------------------------------------------------------------
FREECONTRIBUTOR_VERSION='0.5.0'
REDIRECTIP4="${REDIRECTIP4:=0.0.0.0}"
REDIRECTIP6="${REDIRECTIP6:=::}"

TARGET="${TARGET:=$REDIRECTIP4}"
FORMAT="${FORMAT:=dnsmasq}"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# make temp files
TMP=$(mktemp /tmp/data.XXXXX)
DOMAINS=$(mktemp /tmp/domains.XXXXX)

## ----------------------------------------------------------------------------

welcome()
{
cat << EOF

     _____               ____            _        _ _           _
    |  ___| __ ___  ___ / ___|___  _ __ | |_ _ __(_) |__  _   _| |_ ___  _ __
    | |_ | '__/ _ \/ _ \ |   / _ \| '_ \| __| '__| | '_ \| | | | __/ _ \| '__|
    |  _|| | |  __/  __/ |__| (_) | | | | |_| |  | | |_) | |_| | || (_) | |
    |_|  |_|  \___|\___|\____\___/|_| |_|\__|_|  |_|_.__/ \__,_|\__\___/|_|


    Enjoy a safe and faster web experience

    FreeContributor - http://github.com/tbds/FreeContributor
    Released under the GPLv3 license
    (c) 2016 tbds and contributors

EOF
}

usage()
{
cat << EOF


    FreeContributor is a script to extract and convert domains lists from various sources.

    USAGE:

      $ $0 [-f format]  [-o out] [-t target]

       -f format: specify an output format:

          none        Extract domains only
          hosts       Use hosts format
          dnsmasq     dnsmasq as DNS resolver
          unbound     unbound as DNS resolver
          pdnsd       pdnsd as DNS resolver

       -o out: specify an output file

       -t target: specify the target

          default:     $TARGET
                       $REDIRECTIP6
                       NXDOMAIN
                       custom (e.g. 192.168.1.20)

       -help: show this help


    EXAMPLES:

      $ $0 -f hosts -t 0.0.0.0 -o blacklist.conf

      $ $0 -f dnsmasq -t NXDOMAIN -o blacklist.conf

EOF
}


check_dependencies()
{
  programs=( sed grep curl )

  for prg in "${programs[@]}"
  do
    echo -e "\n\t Checking if $prg is installed ..."
    type -P $prg &>/dev/null || (echo -e "\tmissing: $prg"; exit 1)
  done
}


##
## See FilterLists for a comprehensive list of filter lists from all over the web
## https://filterlists.com/
##

download_sources()
{

sources=(
##
## Use StevenBlack/hosts mirrors to save bandwidth from original servers
## https://github.com/StevenBlack/hosts/tree/master/data
##  'https://adaway.org/hosts.txt'
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/adaway.org/hosts'
##  'http://www.malwaredomainlist.com/hostslist/hosts.txt'
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/malwaredomainlist.com/hosts'
##  'http://winhelp2002.mvps.org/hosts.txt'
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/mvps.org/hosts'
##  'http://someonewhocares.org/hosts/hosts'
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/someonewhocares.org/hosts'
##  'http://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext'
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/yoyo.org/hosts'
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/extensions/gambling/hosts'
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/tyzbit/hosts'
    'https://raw.githubusercontent.com/gorhill/uMatrix/master/assets/umatrix/blacklist.txt'
    'https://raw.githubusercontent.com/quidsup/notrack/master/trackers.txt'
    'https://raw.githubusercontent.com/Dawsey21/Lists/master/main-blacklist.txt'
    'http://sysctl.org/cameleon/hosts'
    'http://malwaredomains.lehigh.edu/files/justdomains'
    'https://isc.sans.edu/feeds/suspiciousdomains_High.txt'
    'https://raw.githubusercontent.com/zant95/hosts/master/hosts'
    'https://www.dshield.org/feeds/suspiciousdomains_Low.txt'
    'https://feodotracker.abuse.ch/blocklist/?download=domainblocklist'
    'https://palevotracker.abuse.ch/blocklists.php?download=domainblocklist'
    'https://ransomwaretracker.abuse.ch/downloads/RW_DOMBL.txt'
    'https://ransomwaretracker.abuse.ch/downloads/CW_C2_DOMBL.txt'
    'https://ransomwaretracker.abuse.ch/downloads/CW_PS_DOMBL.txt'
    'https://ransomwaretracker.abuse.ch/downloads/TC_C2_DOMBL.txt'
    'https://ransomwaretracker.abuse.ch/downloads/TC_PS_DOMBL.txt'
    'https://ransomwaretracker.abuse.ch/downloads/LY_C2_DOMBL.txt'
    'https://ransomwaretracker.abuse.ch/downloads/LY_PS_DOMBL.txt'
    'https://ransomwaretracker.abuse.ch/downloads/TL_C2_DOMBL.txt'
    'https://ransomwaretracker.abuse.ch/downloads/TL_PS_DOMBL.txt'
    'https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist'
    'http://adblock.gjtech.net/?format=unix-hosts'
#    'http://hostsfile.mine.nu/Hosts'
##
## https://github.com/crazy-max/WindowsSpyBlocker
##
#    'https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/blob/master/hosts/windows10_extra.txt'
#    'https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/blob/master/hosts/windows10_spy.txt'
#    'https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/blob/master/hosts/windows10_update.txt'
##
## Terms of Use of hpHosts
## This service is free to use, however, any and ALL automated use is
## strictly forbidden without express permission from ourselves
##    'http://hosts-file.net/ad_servers.txt'
##    'http://hosts-file.net/hphosts-partial.txt'


## error 'http://securemecca.com/Downloads/hosts.txt'
#    'http://www.joewein.net/dl/bl/dom-bl.txt'
#    'http://adblock.mahakala.is/'
#    'http://mirror1.malwaredomains.com/files/justdomains'
#    'https://raw.githubusercontent.com/CaraesNaur/hosts/master/hosts.txt'
#SSL cerificate 'https://elbinario.net/wp-content/uploads/2015/02/BloquearPubli.txt'
#
#    'https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
#    'https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt'
#    'https://s3.amazonaws.com/lists.disconnect.me/simple_malware.txt'
#    'https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt'
#
# https://github.com/brucebot/pisoft
#
#    'http://code.taobao.org/svn/adblock/trunk/hosts.txt'
#    'http://hostsfile.org/Downloads/BadHosts.unx.zip'
#    'http://support.it-mate.co.uk/downloads/HOSTS.txt'
#    'https://hosts.neocities.org/'
#    'https://publicsuffix.org/list/effective_tld_names.dat'
#    'http://cdn.files.trjlive.com/hosts/hosts-v8.txt'
#    'http://tcpdiag.dl.sourceforge.net/project/adzhosts/HOSTS.txt'
#    'http://optimate.dl.sourceforge.net/project/adzhosts/HOSTS.txt'
#    'https://openphish.com/feed.txt'
#    'https://easylist-downloads.adblockplus.org/rolist+easylist.txt'
#    'http://www.shallalist.de/Downloads/shallalist.tar.gz'
#    'http://support.it-mate.co.uk/downloads/HOSTS.txt'
#    'https://raw.githubusercontent.com/reek/anti-adblock-killer/master/anti-adblock-killer-filters.txt'
#    'http://www.sa-blacklist.stearns.org/sa-blacklist/sa-blacklist.current'
#    'https://easylist-downloads.adblockplus.org/malwaredomains_full.txt'
#    'https://easylist-downloads.adblockplus.org/easyprivacy.txt'
#    'https://easylist-downloads.adblockplus.org/easylist.txt'
#    'https://easylist-downloads.adblockplus.org/fanboy-annoyance.txt'
#    'http://www.fanboy.co.nz/adblock/opera/urlfilter.ini'
#    'http://www.fanboy.co.nz/adblock/fanboy-tracking.txt'
)

  echo -e "\n\t FreeContributor is downloading data ..."
  for item in ${sources[*]}
  do
     echo -e "\n\t :: Downloading from URL: $item"
     curl -s $item >> $TMP || { echo -e "\n\t Error downloading $item"; exit 1; }
  done
}

extract_domains()
{
# clean this code with better regex
# https://blog.mister-muffin.de/2011/11/14/adblocking-with-a-hosts-file/
# sed 's/\([^#]*\)#.*/\1/;s/[ \t]*$//;s/^[ \t]*//;s/[ \t]\+/ /g'
#

  echo -e "\n\t Extracting domains from previous lists ..."
  # remove empty lines and comments
  grep -Ev '^$' $TMP | \
  grep -o '^[^#]*'  | \
  # exclude locahost entries
  grep -v "localhost" | \
  # remove 127.0.0.1 and 0.0.0.0
  sed 's/127.0.0.1//;s/0.0.0.0//' | \
  # remove tab and spaces in the begining
  sed -e 's/^[ \t]*//' | \
  # remove ^M
  sed 's/\r//g' | grep -Ev '^$' | \
  sort | uniq > $DOMAINS

  echo -e "\n\t Domains extracted using ${FORMAT} format: $(cat ${DOMAINS} | wc -l )"

}

## none -------------------------------------------------------------------

domains()
{
  cp ${DOMAINS} > "${OUTPUTFILE}"
}

## hosts ------------------------------------------------------------------

hosts()
{
  #Generate hosts header
  ./utils/hosts.header.sh

  mv hosts.header "${OUTPUTFILE}"

  while read line; do
    echo "${TARGET} ${line}" >> "${OUTPUTFILE}"
  done < $DOMAINS

}


## dnsmasq -----------------------------------------------------------------

dnsmasq()
{
  if [ ${TARGET} = "NXDOMAIN" ]; then
    awk '{print "server=/"$1"/"}' $DOMAINS > "${OUTPUTFILE}"

  else
    awk -v var="${TARGET}" '{print "address=/"$1"/"var}' $DOMAINS > "${OUTPUTFILE}"
  fi
}

## unbound -----------------------------------------------------------------

unbound()
{
  if [ ${TARGET} = "NXDOMAIN" ]; then

#local-zone: "testdomain.test" static
#http://www.unixcl.com/2012/07/print-double-quotes-in-unix-awk.html

    awk '{print "local-zone: ""\x22"$1"\x22"" static"}' $DOMAINS > "${OUTPUTFILE}"

  else

#https://github.com/jodrell/unbound-block-hosts/
#https://pgl.yoyo.org/adservers/serverlist.php?hostformat=unbound
#local-zone: "example.tld" redirect
#local-data: "example.tld A 127.0.0.1"

    while read line; do
      echo "local-zone: \"${line}\" redirect" >> "${OUTPUTFILE}"
      echo "local-data: \"${line} A ${TARGET}\"" >> "${OUTPUTFILE}"
    done < $DOMAINS
  fi
}

## pdnsd -------------------------------------------------------------------

pdnsd()
{
#https://news.ycombinator.com/item?id=3035825
#https://pgl.yoyo.org/adservers/serverlist.php?hostformat=pdnsd
#neg { name=example.tld; types=domain; }

  awk '{print "neg { name="$1"; types=domain; }"}' $DOMAINS > "${OUTPUTFILE}"
}


finish()
{
cat <<'EOF'

    FreeContributor blocklist generated.
    Enjoy surfing in the web

    More info at https://tbds.github.io/FreeContributor/

EOF
}


## Main --------------------------------------------------------------------

welcome

#Check the number of arguments. If none are passed, print help and exit.
NUMARGS=$#

if [ $NUMARGS -eq 0 ]; then
  usage
  exit 1
fi


while getopts ":t:f:o:h" opt; do
  case $opt in
    h)
      usage
      exit 1
    ;;
    f)
      FORMAT="$OPTARG"
    ;;
    o)
      OUTPUTFILE="$OPTARG"
    ;;
    t)
      TARGET="$OPTARG"
    ;;
    \?)
      echo -e "\n\tInvalid option: -$OPTARG" >&2
      usage
      exit 1
    ;;
  esac
done

shift "$((OPTIND-1))"

if [ -z ${OUTPUTFILE+x} ]; then
  echo -e "\n\tYou must specify an output file"
  usage
  exit 1
fi

check_dependencies
download_sources
extract_domains

case "$FORMAT" in
  "none")
    domains
  ;;
  "hosts")
    hosts
  ;;
  "dnsmasq")
    dnsmasq
  ;;
  "unbound")
    unbound
  ;;
  "pdnsd")
    pdnsd
  ;;
   *)
    echo -e "\n\tInvalid option"
    usage
    exit 1
  ;;
esac

finish
