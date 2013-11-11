all: bin/freebayes bin/glia

bin/freebayes:
	cd freebayes && $(MAKE)
	cp freebayes/bin/freebayes bin/

bin/glia:
	cd glia && $(MAKE)
	cp glia/glia bin/

.PHONY: clean
clean:
	cd freebayes && make clean
	cd glia && make clean
	rm bin/glia bin/freebayes
