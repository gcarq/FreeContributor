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
#
# Simple script that pulls ad blocking host files from different providers
# and combines them to use as a DNS resolver file.
#
# Dependencies:
#  * GNU bash
#  * GNU awk
#  * GNU coreutils (sed, grep, touch)
#  * cURL
#
set -e
## Global Variables-------------------------------------------------------------------
FREECONTRIBUTOR_VERSION='0.6.0'
WORKING_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SUPPORTED_FORMATS=("none" "hosts" "dnsmasq" "unbound" "pdnsd")
DEPENDENCIES=("sed" "grep" "curl")
DOMAINLIST_CONF="${WORKING_DIR}/domainlist.conf"

# Set default values
REDIRECTIP4="${REDIRECTIP4:=127.0.1.1}"
REDIRECTIP6="${REDIRECTIP6:=::1}"
TARGET="${TARGET:=$REDIRECTIP4}"
FORMAT="${FORMAT:=none}"

# Maximum threads (used for fetching and converting)
THREADS=2

# Make temp files
TMP_DOMAINS_RAW=$(mktemp /tmp/freecontribute-raw-domains.XXXXX)
TMP_DOMAINS=$(mktemp /tmp/freecontribute-domains.XXXXX)

# Contains all domainlist URIs loaded from DOMAINLIST_CONF
DOMAINLIST_URIS=()
##------------------------------------------------------------------------------------

panic() {
  show_usage
  printf "    ERROR: %s\n\n" "${1}" 1>&2
  exit 1
}
export -f panic  # export function to sub shells

check_dependencies() {
  printf "    Checking dependencies...\n"

  for prg in "${DEPENDENCIES[@]}"; do
    type -P $prg &>/dev/null || \
      panic "Unable to find executable \"${prg}\" in PATH. (Make sure it is installed properly)"
  done
}

load_domainlist_conf() {
  # Check if domainlist conf is readable
  if [ ! -r "${DOMAINLIST_CONF}" ]; then
    panic "Unable to load domainlist config: \"${DOMAINLIST_CONF}\""
  fi

  # Load and sanitze and load URIs
  DOMAINLIST_URIS=($(sed -r "s/#.*$//;           \
                             s/^[[:space:]]*//;  \
                             /^[[:space:]]*$/d;  \
                             s/[[:space:]]*$//;  \
                            " ${DOMAINLIST_CONF} | awk '!x[$0]++'))

  printf "    Imported %d domain list URI(s).\n" ${#DOMAINLIST_URIS[@]}
}

fetch_domainlists() {
  printf "    Fetching lists (threads: %d)...\n" ${THREADS}

  printf '%s\n' ${DOMAINLIST_URIS[@]} | xargs -n1 -I{} -P ${THREADS} \
    bash -c "if ! curl -L '{}' 2>/dev/null >>'${TMP_DOMAINS_RAW}'; then panic 'Unable to fetch domain list: {}'; fi"

  printf "    Got $(wc -l < ${TMP_DOMAINS_RAW}) dns records.\n"
}

sanitize_merged_domainlist() {
  REGEX_IPV4_VALIDATION="^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.)\
{3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"

  ## Replacments are done in the following order:
  #   > transform everything to lowercase
  #   > strip comments starting with '#'
  #   > replace substr '127.0.0.1' with ''
  #   > replace substr '0.0.0.0' with ''
  #   > strip ^M (windows newline character)
  #   > ltrim tabs and whitespaces
  #   > rtrim tabs and whitespaces
  #   > remove lines which only contain an ipv4 addresses
  #   > remove 'localhost' lines
  #   > delete empty lines

  # Apply replacements
  sed -ir "s/\(.*\)/\L\1/;               \
           s/#.*$//;                     \
           s/127.0.0.1//;                \
           s/0.0.0.0//;                  \
           s/\^M//;                      \
           s/^[[:space:]]*//;            \
           s/[[:space:]]*$//;            \
           s/${REGEX_IPV4_VALIDATION}//; \
           /^localhost$/d;               \
           /^[[:space:]]*$/d;            \
          " ${TMP_DOMAINS_RAW}

  # Remove duplicate lines
  awk -i inplace '!x[$0]++' ${TMP_DOMAINS_RAW}

  # Remove invalid FQDNs (https://en.wikipedia.org/wiki/Fully_qualified_domain_name)
  grep -Po '(?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{1,63}(?<!-)\.)+[a-zA-Z]{2,63}$)' \
    ${TMP_DOMAINS_RAW} > ${TMP_DOMAINS}
}

gen_hosts_conf() {
  if [ ${TARGET} = "NXDOMAIN" ]; then
    # Not supported
    panic "hosts format does not support target NXDOMAIN."
  else
    # 127.0.1.1       example.tld
    ./misc/gen-hosts-header.sh > "${OUTPUTFILE}" # Generate hosts header
    printf "%s\n" $(cat ${TMP_DOMAINS}) | xargs -n1 -I{} -P ${THREADS} \
    printf "%s %s\n" "${TARGET}" "{}"  > "${OUTPUTFILE}"
  fi
}

gen_dnsmasq_conf() {
  if [ ${TARGET} = "NXDOMAIN" ]; then
    # server=/example.tld/
    printf "server=/%s/\n" $(cat ${TMP_DOMAINS})  > "${OUTPUTFILE}"
  else
    # address=/example.tld/127.0.1.1
    printf "%s\n" $(cat ${TMP_DOMAINS}) | xargs -n1 -I{} -P ${THREADS} \
      printf "address=/%s/%s\n" "{}" "${TARGET}" > "${OUTPUTFILE}"
  fi
}

gen_unbound_conf() {
  if [ ${TARGET} = "NXDOMAIN" ]; then
    # local-zone: "example.tld" static
    printf "local-zone: \"%s\" static\n" $(cat ${TMP_DOMAINS})  > "${OUTPUTFILE}"
  else
    # local-zone: "example.tld" redirect
    # local-data: "example.tld A 127.0.1.1"
    printf "%s\n" $(cat ${TMP_DOMAINS}) | xargs -n1 -I{} -P ${THREADS} \
      printf "local-zone: \"%s\" redirect\nlocal-data: \"%s A %s\"\n" \
        "{}" "{}" "${TARGET}" > "${OUTPUTFILE}"
  fi
}

gen_pdnsd_conf() {
  if [ ${TARGET} = "NXDOMAIN" ]; then
    # neg { name=example.tld; types=domain; }
    printf "neg { name=%s; types=domain; }\n" $(cat ${TMP_DOMAINS}) > "${OUTPUTFILE}"
  else
    # Not implemented
    panic "NXDOMAIN is currently the only implementation for pdnsd."
  fi
}

parse_arguments() {
  local OPTIND OPTARG
  # Match parameters
  while getopts ":t:f:o:h" opt; do
    case $opt in
      h)  show_usage; exit 0;;
      f)  FORMAT="${OPTARG}";;
      o)  OUTPUTFILE="${OPTARG}";;
      t)  TARGET="${OPTARG}";;
      \?) panic "Invalid option: -${OPTARG}";;
    esac
  done
  shift "$((OPTIND-1))"

  # Validate output argument
  if [ -z ${OUTPUTFILE+x} ]; then
    panic "You must specify an output file."
  else
    # Check if we have write access
    touch "${OUTPUTFILE}" > /dev/null 2>&1 || \
      panic "Unable to create to output file: ${OUTPUTFILE}"
  fi

  # Validate format argument
  if [[ ! " ${SUPPORTED_FORMATS[@]} " =~ " ${FORMAT} " ]]; then
    panic "format must be one of {none|hosts|dnsmasq|unbound|pdnsd}."
  fi
}

## Main ------------------------------------------------------------------------

# Include banners file
source "${WORKING_DIR}/misc/banners.sh"

show_header
parse_arguments "$@"
check_dependencies
load_domainlist_conf
fetch_domainlists
sanitize_merged_domainlist

# Generate list for specified format
case "${FORMAT}" in
  "none")    cp "${TMP_DOMAINS}" "${OUTPUTFILE}";;
  "hosts")   gen_hosts_conf;;
  "dnsmasq") gen_dnsmasq_conf;;
  "unbound") gen_unbound_conf;;
  "pdnsd")   gen_pdnsd_conf;;
esac
printf "\n    Domain list generated (format: %s, records: %s, filename: %s).\n" \
       "${FORMAT}" $(cat ${TMP_DOMAINS} | wc -l) "${OUTPUTFILE}"

printf "    Enjoy surfing in the web.\n\n"
