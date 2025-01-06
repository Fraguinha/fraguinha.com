.PHONY: all
all:
	hugo server -D

.PHONY: clean
clean:
	rm -rf public/ .hugo_build.lock
