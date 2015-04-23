#!/bin/sh
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
# (c) pentestmonkey, Bernardo Damele A. G., Tim Brown, 2012-2015
# (c) pentestmonkey, 2007-2011

. lib/stdio

header () {
	VERSION="2.1-dev"
	printf "unix-privesc-check v${VERSION} (https://github.com/inquisb/unix-privesc-check)\n\n"
}

version () {
	header
	preamble
	printf "Brought to you by:\n"
	cat doc/AUTHORS
	exit 1
}

preamble () {
	printf "Shell script to build review and check for privilege escalation vectors on UNIX systems.\n\n"
}

usage () {
	header
	preamble
	printf "Usage: ${0}\n"
	printf "\n"
	printf "\t--help\tdisplay this help and exit\n"
	printf "\t--version\tdisplay version and exit\n"
	printf "\t--color\tenable output coloring\n"
	printf "\t--verbose\tverbose level (0-2, default: 1)\n"
	printf "\t--type\tselect from one of the following check types:\n"
	for checktype in checks/enabled/*
	do
		printf "\t\t`basename ${checktype}`\n"
	done
	printf "\t--checks\tprovide a comma separated list of checks to run, select from the following checks:\n"
	for check in checks/*
	do
		if [ "`basename \"${check}\"`" != "enabled" ]
		then
			printf "\t\t`basename ${check}`\n"
		fi
	done
	exit 1
}

# TODO make it use lib/validate
CHECKS=""
TYPE="all"
COLORING="0"
VERBOSE="1"
while [ -n "${1}" ]
do
	case "${1}" in
		--help|-h)
			usage
			;;
		--version|-v|-V)
			version
			;;
		--color)
			COLORING="1"
			;;
		--verbose)
			shift
			VERBOSE="${1}"
			;;
		--type|-t)
			shift
			TYPE="${1}"
			;;
		--checks|-c)
			shift
			CHECKS="${1}"
			;;
	esac
	shift
done
header
if [ "${VERBOSE}" != "0" -a "${VERBOSE}" != "1" -a "${VERBOSE}" != "2" ]
then
	stdio_message_error "upc" "the provided verbose level ${VERBOSE} is invalid - use 0, 1 or 2 next time"
	VERBOSE="1"
fi
if [ -n "${CHECKS}" ]
then
	for checkfilename in `printf "${CHECKS}" | tr -d " " | tr "," " "`
	do
		if [ ! -e "checks/${checkfilename}" ]
		then
			stdio_message_error "upc" "the provided check name '${checkfilename}' does not exist"
		else
			. "checks/${checkfilename}"
			`basename "${checkfilename}"`_init
			`basename "${checkfilename}"`_main
			`basename "${checkfilename}"`_fini
		fi
	done
else
	if [ ! -d "checks/enabled/${TYPE}" ]
	then
		stdio_message_error "upc" "the provided check type '${TYPE}' does not exist"
	else
		for checkfilename in checks/enabled/${TYPE}/*
		do
			. "${checkfilename}"
			`basename "${checkfilename}"`_init
			`basename "${checkfilename}"`_main
			`basename "${checkfilename}"`_fini
		done
	fi
fi
exit 0
