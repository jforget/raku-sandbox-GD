CC = gcc
CCOPT = -lgd -lpng -lz -ljpeg -lfreetype -lm

test.png: asym-pat
	./asym-pat

test.jpg: asym-pat
	./asym-pat

asym-pat: asym-pat.c
	$(CC) -o asym-pat asym-pat.c $(CCOPT)
