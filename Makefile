LLVM_ROSETTE ?= racket $(shell ./find-serval.rkt)/serval/bin/serval-llvm.rkt

all: tock.ll.rkt

simple: src/main.rs
	rustc --edition=2018 --crate-name tock $< -C opt-level=3 -C panic=abort -C debuginfo=1 --emit=obj -C relocation-model=static -C link-dead-code

tock.o: $(TOCK_ROOT)/kernel/src/common/list.rs
	rustc --edition=2018 --crate-name tock $< --crate-type lib -C opt-level=3 -C panic=abort -C debuginfo=1 --emit=obj -C relocation-model=static -C link-dead-code

tock.ll: $(TOCK_ROOT)/kernel/src/common/list.rs
	rustc --edition=2018 --crate-name tock $< --crate-type lib -C opt-level=3 -C panic=abort -C debuginfo=0 -Clink-arg=-nostartfiles --emit=llvm-ir -C relocation-model=static -C link-dead-code

tock.map: tock.o
	nm -S -C --size-sort $< > $@
	#nm --print-size --numeric-sort $< > $@

tock.map.rkt: tock.map
	echo "#lang reader serval/lang/nm" > $@ && \
		cat $< >> $@

tock.globals.rkt: tock.o
	echo "#lang reader serval/lang/dwarf" > $@
	objdump --dwarf=info $< >> $@

tock.ll.rkt: tock.ll
	$(LLVM_ROSETTE) < $< > $@

verify: tock.ll.rkt tock.globals.rkt tock.map.rkt
	raco test spec.rkt

.PHONY: clean
clean:
	rm -rf tock.ll tock.ll.rkt tock.o tock.map tock.map.rkt tock.globals.rkt
