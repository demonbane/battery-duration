battery-duration : src/header lib/battery-duration.awk src/footer
	cat src/header lib/battery-duration.awk src/footer > battery-duration
	chmod 755 battery-duration

clean :
	rm -f battery-duration
