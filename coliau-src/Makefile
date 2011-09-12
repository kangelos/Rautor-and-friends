all:  coliau.exe

PP=c:\\perl\\site\\bin\\pp.bat

coliau.exe: coliau.pl rau_html.pl firewallopen.pl Keymap.pl firewallopen.pl dot_ico.pl bull_lined.pl
	$(PP)  --icon=bull_lined.ico	\
	--verbose=3 \
	--gui -o coliau.exe coliau.pl &&\
	perl version.pl $@ ..\\bull_lined.ico &&\
	copy coliau.exe c:\\temp

