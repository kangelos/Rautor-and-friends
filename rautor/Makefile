

all: bin/Rautor.exe bin/rrs.exe bin/GUIsalt.exe

PP=c:\\perl510\\site\\bin\\pp.bat


bin/Rautor.exe: Rautor3.pl Makefile keymap.pl Rreg.pl
	$(PP) -a splash.bmp -o $@	\
	--info=ProductVerion=1.12	\
	--info=LegalCopyright=Unix.gr	\
	--info=OriginalFilename=$@	\
	--info=ProductName=$@ 		\
	--verbose --gui --icon=bull.ico	\
	-l bin\\msg.dll \
	$<


bin/rrs.exe: rrs.pl Makefile
	$(PP) -a splash.bmp		\
	--info=ProductVerion=1.12	\
	--info=LegalCopyright=Unix.gr	\
	--info=OriginalFilename=$@	\
	--info=ProductName=$@ 		\
	--verbose --gui --icon=bull.ico	\
	-o $@  $<


bin/GUIsalt.exe: GUIsalt.pl Makefile
	$(PP) -a splash.bmp		\
	--info=ProductVerion=1.12	\
	--info=LegalCopyright=Unix.gr	\
	--info=OriginalFilename=$@	\
	--info=ProductName=$@ 		\
	--verbose --gui --icon=bull.ico	\
	-o $@ $< 


CreateLicense.exe: CreateLicense.pl Makefile
	pp -o $@ $<
