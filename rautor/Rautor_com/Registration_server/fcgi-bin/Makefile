all: admin_ips.fcgi  register.fcgi clear.exe clear_rautor.exe rautor_register.fcgi
#get.pl
#register.fcgi
#sessview.mysql
SRCDIR=../cgi-src
PP=pp  \
 -M DBI -M DBD::mysql -M CGI::Fast -M Crypt::Tea -M LWP::UserAgent \
-X DBD::SQLite -X DBD::CSV -X DBD::File -X DBD::Excel 

register.fcgi:	${SRCDIR}/register.fcgi
	${PP} -o $@ $<

rautor_register.fcgi:	${SRCDIR}/rautor_register.fcgi
	${PP} -o $@ $<

admin_ips.fcgi:	${SRCDIR}/admin_ips.fcgi
	${PP} -o $@ $<

clear.exe:	${SRCDIR}/clear.pl
	${PP} -o $@ $<

clear_rautor.exe:	${SRCDIR}/clear_rautor.pl
	${PP} -F Obfuscate=$< -o $@ $<
