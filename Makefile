.PHONY: all
all:
	hugo server -D

.PHONY: cv
cv:
	tectonic cv/cv.tex

.PHONY: clean
clean:
	rm -rf public/ .hugo_build.lock cv/*.pdf cv/*.out cv/*.xdv cv/*.aux cv/*.log
