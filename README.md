This project is still in **beta**! It currently works well, but some changes may be expected.

<!-- language: lang-none -->
      ______              _____            _        _ _           _             
     |  ____|            / ____|          | |      (_) |         | |            
     | |__ _ __ ___  ___| |     ___  _ __ | |_ _ __ _| |__  _   _| |_ ___  _ __
     |  __| '__/ _ \/ _ \ |    / _ \| '_ \| __| '__| | '_ \| | | | __/ _ \| '__|
     | |  | | |  __/  __/ |___| (_) | | | | |_| |  | | |_) | |_| | || (_) | |   
     |_|  |_|  \___|\___|\_____\___/|_| |_|\__|_|  |_|_.__/ \__,_|\__\___/|_|   


Enjoy a safe and faster web experience

TL:DR `cat domains-{ads,tracking,malware} > /dev/null`

## Intro

More and more people use "adblocker" plugins within their desktop browsers.
FreeContributor is an alternative for "ad blocking extensions" in your browser.

FreeContributor intends to extract domains lists from various sources.
It [blocks ads, malware, trackers at DNS level](https://en.wikipedia.org/wiki/DNSBL).

## Why

 - [Major sites including New York Times and BBC hit by 'ransomware' malvertising](http://www.theguardian.com/technology/2016/mar/16/major-sites-new-york-times-bbc-ransomware-malvertising)
 - [Adblocking: advertising 'accounts for half of data used to read articles'](http://www.theguardian.com/media/2016/mar/16/ad-blocking-advertising-half-of-data-used-articles)
 - [The Verge's web sucks](http://blog.lmorchard.com/2015/07/22/the-verge-web-sucks/) and [The web is Doom](https://mobiforge.com/research-analysis/the-web-is-doom)

## Why this fork?

This fork has the purpose to create a very simple dns-blacklist generator, so it just downloads all domain lists, merges them and generates a file in the specified format (`/etc/hosts`, `dnsmasq`, `unbound` and `pdnsd`), nothing more.

##### Differences between the original:
 - doesn't need any privileges besides writing access to the output file
 - doesn't install any package on the OS
 - doesn't modifies any system files
 - doesn't trigger the init-system to restart the dns server

## What the script does?

 - Download domain lists from various sources and generate a blacklist in data formats for `/etc/hosts`, `dnsmasq`, `unbound` and `pdnsd`.

## Benefits and Features

 - Low CPU and RAM usage.
 - **Speeds up your Internet** use since the local file is checked first, before send a DNS request.
 - **Data savings** since the ad content is never downloaded.
 - Stops ad tracking and protect your privacy.
 - Blocks spyware and malware. That increases the safety of your networking experience.
 - Not just for browsers, it blocks ads and malware across the entire operative system.


## Requirements

 - [GNU bash](http://www.gnu.org/software/bash/bash.html)
 - [GNU coreutils(grep, sed, touch)](http://www.gnu.org/software/coreutils)
 - [GNU awk](https://www.gnu.org/software/gawk/)
 - [cURL](http://curl.haxx.se/)


## Installation and Usage

```sh

git clone https://github.com/gcarq/FreeContributor
cd FreeContributor

```

```sh

 USAGE:
    $ ./FreeContributor.sh -f <format> -o <out> [-t target]
     -f <format>      specify an output format:
                            none          Extract domains only (default)
                            hosts         Use hosts format
                            dnsmasq       dnsmasq as DNS resolver
                            unbound       unbound as DNS resolver
                            pdnsd         pdnsd as DNS resolver
     -o <out>         specify an output file
     -t <target>      specify the target
                            127.0.1.1 (default)
                            ::1
                            NXDOMAIN
                            custom (e.g. 192.168.1.20)
     -h               show this help

  EXAMPLES:
    $ ./FreeContributor.sh -f hosts -t 0.0.0.0 -o hosts.blacklist
    $ ./FreeContributor.sh -f dnsmasq -t NXDOMAIN -o dnsmasq.blacklist
    $ ./FreeContributor.sh -f unbound -t ::1 -o unbound-ipv6.blacklist

```

## Contributing

FreeContributor is a community project, hence all contributions are more than welcome! For more information,
head to [CONTRIBUTING](https://github.com/gcarq/FreeContributor/blob/master/CONTRIBUTING.md)

## Sources

Inspired by [jmdugan's blocklists project](https://github.com/jmdugan/blocklists), FreeContributor project comes with a
[catalog of corporation domain names](https://github.com/tbds/FreeContributor/tree/master/data) that people may want to block.

FreeContributor also downloads external files, each has its own license, detailed in the list below.
Thanks to the people working hard to maintain the filter lists below that FreeContributor is using.

**You can also contribute with your own lists**, see [CONTRIBUTING](https://github.com/gcarq/FreeContributor/blob/master/CONTRIBUTING.md).


| URL                                                                              | Details                                                 | License |
| -------                                                                          | -------                                                 | ------- |
|[Adaway list](https://adaway.org/hosts.txt)                                       | Infrequent updates, approx. 400 entries                 | CC Attribution 3.0 |
|[Disconnect](https://disconnect.me/)                                              | Numerous updates on the same day, approx. 6.500 entries | ?                  |
|[MVPS Hosts](http://winhelp2002.mvps.org/hosts.htm)                               | Infrequent updates, approx. 15.000 entries              | CC Attribution-NonCommercial-ShareAlike 4.0 |
|[hpHosts’s ad and tracking servers‎](http://www.hosts-file.net/)                   |                                                         | *Read [Terms of Use](http://www.hosts-file.net/)* |
|[Peter Lowe’s Ad server list](http://pgl.yoyo.org/adservers/)                     | Weekly updates, approx. 2.500 entries                   | ? |
|[Dan Pollock’s hosts file](http://someonewhocares.org/hosts/)                     | Weekly updates, approx. 12.000 entries                  | non-commercial |
|[CAMELEON](http://sysctl.org/cameleon/)                                           | Weekly updates, approx. 21.000 entries                  | ? |
|[StevenBlack/hosts](https://github.com/StevenBlack/hosts/)                        |                                                         | ? |
|[Quidsup/notrack](https://github.com/quidsup/notrack)                             |                                                         | ? |
|[Gorhill's uMatrix Blocklist](https://github.com/gorhill/uMatrix)                 |                                                         | ? |
|[Malware Domain List](http://www.malwaredomainlist.com/)                          | Daily updates, approx. 1.500 entries                    | ? |
|[AdBlock filter](http://adblock.gjtech.net/)                                      |                                                         | CC Attribution 3.0 |
|[Hostfile project](http://hostsfile.org/hosts.html)                               |                                                         | LGPL as GPLv2 |
|[Airelle's host file](http://rlwpx.free.fr/WPFF/hosts.htm)                        |                                                         | CC Attribution 3.0 |
|[The Hosts File Project](http://hostsfile.mine.nu)                                |                                                         | LGPL |
|[Mahakala](http://adblock.mahakala.is/)                                           |                                                         | ? |
|[Secure Mecca](http://securemecca.com/)                                           |                                                         | LGPL as GPLv2 |
|[Spam404scamlist](http://spam404bl.com/)                                          | Infrequent updates, approx. 5.000 entries               | CC Attribution-ShareAlike 4.0 International |
|[Malwaredomains](http://www.malwaredomains.com)                                   | Daily updates, approx. 16.000 entries                   | ? |
|[Adzhosts](https://sourceforge.net/projects/adzhosts/)                            |                                                         | ? |
|[hosts.eladkarako.com](http://hosts.eladkarako.com/)                              |                                                         | ? |
|[Malekal](http://www.malekal.com/)                                                |                                                         | ? |
|[dshield](http://dshield.org/)                                                    | Daily updates, approx. 4.500 entries                    | NonCommercial-ShareAlike 2.5 Generic |
|[openphish](feodotracker)                                                         | Numerous updates on the same day, approx. 1.800 entries | ? |
|[Zeustracker](https://zeustracker.abuse.ch/)                                      | Daily updates, approx. 440 entries                      | ? |
|[Feodotracker](https://feodotracker.abuse.ch/)                                    | Daily updates, approx. 0-10 entries                     | ? |
|[Palevo tracker](https://palevotracker.abuse.ch/)                                 | Daily updates, approx. 15 entries                       | ? |
|[Ransomware tracker](https://ransomwaretracker.abuse.ch/)                         | Daily updates, approx. 150 entries                      | ? |
|[Shalla's Blacklists ](https://ransomwaretracker.abuse.ch/)                       | Daily updates, approx. 32.000 entries [description](http://www.shallalist.de/categories.html)  | ? |                     | ? |
|[Windows Spy Blocker](https://github.com/crazy-max/WindowsSpyBlocker)             | Infrequent updates, approx. 120 entries                 | ? |


## DNS 101

### Without an custom DNS Server

<!-- language: lang-none -->
    +----+      +------------+      +------------------+      +------------------------+
    | PC | <==> | DNS Server | <==> | Other DNS Server | <==> | example.tld = ip adress|
    +----+      +------------+      +------------------+      +------------------------+

    +----+      +-------------------------- +
    | PC | <==> | ip adress of example.tld  |
    +----+      +---------------------------+


### With a local DNS resolver

<!-- language: lang-none -->
    +----+      +----------------+      +------------------+      +------------------+
    | PC |      | DNS Server     | <==> | Other DNS Server | <==> | goodwebsite.tld  |
    +----+      +----------------+      +------------------+      +------------------+
      ^^             ^^                                  +------------+    ||
      ||             ||                                  | DNS cache  |  <= /
      vv             ||                                  +------------+
    +--------------------+      +----------------------------------------------------+
    | local DNS resolver | <==> | ads.example.tld = 127.0.0.1 or 0.0.0.0 or NXDOMAIN |
    +--------------------+      +----------------------------------------------------+

    future requests of goodwebsite.tld

    +----+      +--------------------+      +------------------------------------------+
    | PC | <==> | local DNS resolver | <==> | DNS cache of goodwebsite.tld = ip adress |
    +----+      +--------------------+      +------------------------------------------+



## Hosts vs DNS resolver

The hosts blocking method can not use wildcards (*) and and therefore someone must keep track
of each subdomain that should be blocked. Some DNS caching servers can block the domain and
subdomains with just one rule. For example `/etc/hosts`

    127.0.0.1 example.tld
    0.0.0.0 example.tld


Will redirect `example.tld` to the localhost, but not `ads.example.tld`. With a dns caching server,
such as Dnsmasq, for example `/etc/dnsmasq.conf`

    address=/example.tld/127.0.0.1
    address=/example.tld/0.0.0.0
    server=/example.tld/


Will redirect example.tld and all subdomains to 127.0.0.1 or 0.0.0.0. Better yet, it can
return NXDOMAIN.


## Comparison


| Program                                                         | Language      | Adblocking Method                              |
| :-------------                                                  | :-------------| :--------------------------------------------  |
| [FreeContributor (original)](https://github.com/tbds/FreeContributor)      | Bash          | DNS resolver (Dnsmasq, Unbound or Pdnsd)       |
| [FreeContributor (fork)](https://github.com/gcarq/FreeContributor)     | Bash          | Generates only blacklists (Hosts, Dnsmasq, Unbound or Pdnsd) |
| [Pi-Hole](https://pi-hole.net/)                                 | Bash, Php     | Dnsmasq                                        |
| [NoTrack](https://github.com/quidsup/notrack)                   | Bash, Php     | Dnsmasq                                        |
| [Hostsblock](https://gaenserich.github.io/hostsblock/)          | Bash          | Hosts with Dnsmasq (for cache only)            |
| [hBlock](https://github.com/zant95/hBlock)                      | Shell         | Hosts                                          |
| [dnsgate](https://github.com/jakeogh/dnsgate)                   | Python        | Hosts or Dnsmasq                               |
| [StevenBlack hosts](https://github.com/StevenBlack/hosts)       | Python        | Hosts                                          |
| [adsuck](https://github.com/conformal/adsuck)                   | C             | DNS server                                     |
| [dnswhisperer](https://github.com/apankrat/dnswhisperer)        | C             | DNS proxy                                      |
| [pfBlockerNG](https://forum.pfsense.org/index.php?topic=86212.0)| Shell, PHP    | DNS resolver: Unbound                          |
| [Hosts Updater](https://github.com/imanel/hosts_updater)        | Ruby          | Hosts                                          |
| [Rescached](https://github.com/shuLhan/rescached)               | C++           | Hosts                                          |
| [OpenWRT package](https://github.com/openwrt/packages/tree/master/net/adblock/files)   | Shell       | Dnsmasq                   |
| [grimd](https://github.com/looterz/grimd)                       | Go            | [goDNS](https://github.com/kenshinx/godns)     |
| [nss-block](https://github.com/dimkr/nss-block)                 | C             | DNS resolver                                   |


## Disclaimer

- **Read the script** to make sure it is what you need.
- I am not responsible for any damage or loss, always make backups.


## License

FreeContributor is licensed under the [General Public License (GPL) version 3](https://www.gnu.org/licenses/gpl.html)

The ASCII art logo at the top was made using [FIGlet](http://www.figlet.org/).
