#!/usr/bin/awk -f
# vim: sw=4:ts=4
function clearvars() {
	#if (lastsleep > lastwake) {
		lastwake=0
		firstwake=0
	#}
	totaltime=0
	lastsleep=0
	days=0
	nextrun=0
}

function printreport() {
	if (!totaltime && firstwake)
		totaltime=unixtime()-firstwake
	if (totaltime) {
		while (totaltime>86400) {
			days++
			totaltime-=86400
		}
		if (days>1) {
			duration=days" days, "
		} else if (days) {
			duration=days" day, "
		} else {
			duration=""
		}
		printf("Awake for %s%s\n\n\n", duration, strftimef("%T", totaltime, 1))
	}
	clearvars()
}

function pp(myary, aryname) {
	if (!aryname)
		aryname="array"

	for (key in myary) {
		printf("%s[%s] = %s\n", aryname, key, myary[key])
	}
}

function unixtime(timestr) {
	if (!timestr)
		timestr=$1" "$2
	if (PROCINFO["version"])
		return mktime(gensub(/[:-]/," ","g",timestr))
	cmd="date -jf '%F %T' \""timestr"\" +%s"
	cmd | getline retval
	close(cmd)
	return retval
}

function localtime(timeint) {
	if (!timeint)
		timeint=$1" "$2
	return strftimef("%F %T", timeint)
}

function readcharge() {
	split($0,chargelevel,/Charge: ?/)
	split(chargelevel[2],charge,/%?\)/)
	return currentcharge=charge[1]
}

function strftimef(fmtstring,utime,flag) {
	if (PROCINFO["version"])
		return strftime(fmtstring,utime,flag)
	cmd="date -ur "utime" +\""fmtstring"\""
	cmd | getline retval
	close(cmd)
	return retval
}

function systimef(fmtstring,utime,flag) {
	if (PROCINFO["version"])
		return systime()
	cmd="date +%s"
	cmd | getline retval
	close(cmd)
	return retval
}

firstwake && /Using AC/ {
	if (lastsleep<lastwake) {
		totaltime+=unixtime()-lastwake
		lastsleep=unixtime()
		if (!quiet)
			printf("%s (%s%%)*\n",$2,readcharge())
	}
	if (!quiet)
		printf("--------------------\nCharging at %s (%s%%)\n", $2,readcharge())
	printreport()
}

/^[[:digit:]:\- ]{26}(Wake {2,}|Sleep ).*Using [Bb][Aa][Tt]{2} ?\(/ {
	readcharge()

	if (!lastwake && $4=="Wake") {
		firstwake=lastwake=unixtime()
		if ($1!=lastday)
			print lastday=$1
		if (!quiet)
			printf("Awake from %s (%s%%) to ",$2, currentcharge)
		lastmatch=$4
		nextrun=1
	}else if ($4=="Sleep" && lastmatch=="Wake") {
		lastsleep=unixtime()
		totaltime+=lastsleep-firstwake
		lastwake=0
		if (!quiet)
			printf("%s (%s%%)\n", $2, currentcharge)
		lastmatch=$4
	}
	next
}

/^[[:digit:]:\- ]{26}.*Using [Bb][Aa][Tt]{2} ?\(/ {
	if (!nextrun && lastmatch=="Wake") {
		lastwake=firstwake=unixtime()
		readcharge()
		nextrun=1
		if (!quiet)
			printf("Awake from %s (%s%%)* to ",$2, currentcharge)
	}
}

END {
	if (firstwake) {
		"pmset -g batt" | getline
		"pmset -g batt" | getline
		if (!quiet)
			printf("present (%i%%)*\n",$3)
		$1=strftimef("%F",systimef())
		$2=strftimef("%T",systimef())
		totaltime+=unixtime()-lastwake
		printreport()
	}
}
