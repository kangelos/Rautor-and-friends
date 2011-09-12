

#all: Rautor_com.exe rrs.exe UnsetProxy.exe Rau_web.exe Rau_Proxy.exe kidns.exe
all: kidns.exe dadns.exe Rau_web.exe UnsecureEavesDrop.exe Rautor_com.exe rrs.exe

PP=c:\\perl\\site\\bin\\pp.bat
COMPRESS=9
VERBOSE=-v 3
VERBOSE=
VERSION=2.5


Rau_web.exe: rau_web.pl
	perlapp --icon bull_lined.ico \
		--bind bull_lined.ico[extract] \
		--bind redbull.ico[extract] \
		--shared private \
		--lib ..\\common \
		--force \
		--gui \
		--exe $@ $<

UnsecureEavesDrop.exe: UnsecureEavesDrop.pl
	perlapp --icon bull_lined.ico \
		--bind bull_lined.ico[extract] \
		--bind dot.ico[extract] \
		--shared private \
		--lib ..\\common \
		--norunlib \
		--dyndll \
		--force \
		--gui \
		--exe $@ $<


Rautor_com.exe: Rautor_com.pl ..\\common\\Keymap.pl ..\\common\\rreg.pl ..\\common\\Rau_init.pl ..\\common\\setproxy.pl
	perlapp --icon bull.ico \
		--lib ..\common \
		--bind bull.ico[file=bull.ico,mode=666] \
		--bind libeay32.dll[file=libeay32.dll,mode=666] \
		--bind msg.dll[file=msg.dll,mode=666] \
		--bind SSLeay.dll[file=SSLeay.dll,mode=666] \
		--bind ssleay32.dll[file=ssleay32.dll,mode=666] \
		--shared private \
		--force \
		--gui \
		--exe Rautor_Com.exe \
		--perl C:\Perl\bin\perl.exe Rautor_Com.pl


rrs.exe: rrs.pl
	perlapp --icon bull.ico \
	         --shared private \
	         --lib ..\\common \
	         --norunlib \
	         --dyndll \
	         --force \
	         --gui \
	         --exe $@ $<


UnsetProxy.exe:  UnsetProxy.pl
	perlapp --icon daemon.ico \
		--shared private \
		--norunlib \
		--dyndll \
		--lib ..\\common \
		--gui \
		--force \
		--exe $@ $<

Rau_Proxy.exe:  proxy.pl
	perlapp --icon bull.ico \
		--shared private \
		--norunlib --dyndll \
		--gui \
		--lib ..\\common \
		--force \
		--exe $@ $<

kidns.exe: kidns.pl daemon_ico.pl
	perlapp --icon daemon2.ico \
		--norunlib --dyndll \
		--lib ..\\common \
		--gui \
		--force \
		--info "CompanyName=unix.gr;LegalCopyright=2010 Angelos Karageorgiou;OriginalFilename=kidns;ProductName=Kidns;ProductVersion=1.2" \
		--exe kidns.exe \
		--perl C:\Perl\bin\perl.exe kidns.pl
#kidns.exe: kidns.pl
#	 $(PP) $(VERBOSE) --gui          \
#		-N FileVerion=$(VERSION)        \
#		-N ProductVerion=$(VERSION)     \
#		-N LegalCopyright=Unix.gr       \
#		-N ProductName=kidns         \
#		-a daemon.ico                     \
#		-i deamon.ico                     \
#		-o $@ $<
#	perl version.pl $@
#
#
#
#
dadns.exe: dadns.pl
	perlapp --icon dot.ico \
		--norunlib \
		--dyndll  \
		--lib ..\\common \
		--gui \
		--force \
		--info "CompanyName=unix.gr;LegalCopyright=2010 Angelos Karageorgiou;OriginalFilename=kidns;ProductName=Kidns;ProductVersion=1.2" \
		--exe $@ \
		--perl C:\Perl\bin\perl.exe $<
