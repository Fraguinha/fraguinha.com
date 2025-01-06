.PHONY: all clean

TEX_FILE=cv.tex
PDF_FILE=cv.pdf

all:
	cd cv && tectonic $(TEX_FILE)

clean:
	rm -f cv/*.pdf cv/*.out cv/*.xdv
