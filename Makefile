LLVM_ROSETTE ?= racket $(shell ./find-serval.rkt)/serval/bin/serval-llvm.rkt
#TOCK_ROOT ?= `echo ${TOCK_ROOT}`
#LIST_LIB ?= $(TOCK_ROOT)/kernel/src/common/list_lib

all: tockverif.ll.rkt

tockverif.o: src/main.rs
	rustc --edition=2018 --crate-name tockverif $< --crate-type lib -C opt-level=3 -C panic=abort -C debuginfo=1 --emit=obj -C relocation-model=static -C link-dead-code
#cargo rustc -- -v --emit=obj -C relocation-model=static -C link-dead-code -o $@


tockverif.ll: src/main.rs
	rustc --edition=2018 --crate-name tockverif $< --crate-type lib -C opt-level=3 -C panic=abort -C debuginfo=0 -Clink-arg=-nostartfiles --emit=llvm-ir -C relocation-model=static -C link-dead-code
#cargo rustc -- -v --emit=llvm-ir -C relocation-model=static -C link-dead-code

tockverif.map: tockverif.o
	nm -S -C --size-sort $< > $@
	#nm --print-size --numeric-sort $< > $@

tockverif.map.rkt: tockverif.map
	echo "#lang reader serval/lang/nm" > $@ && \
		cat $< >> $@

tockverif.globals.rkt: tockverif.o
	echo "#lang reader serval/lang/dwarf" > $@
	objdump --dwarf=info $< >> $@

tockverif.ll.rkt: tockverif.ll
	$(LLVM_ROSETTE) < $< > $@

verify: tockverif.ll.rkt tockverif.globals.rkt tockverif.map.rkt
	raco test spec.rkt

.PHONY: clean
clean:
	rm -rf tockverif.ll tockverif.ll.rkt tockverif.o tockverif.map tockverif.map.rkt tockverif.globals.rkt
	cargo clean
