#!/usr/bin/perl
#
# DirectoryPass version 1.6 (22nd October 2009)
# http://www.DirectoryPass.com/
#
# DirectoryPass is an Open Source multi-platform .htaccess file management
# tool for use with the Apache web server software. 
# Copyright (C) 2009 ionix Limited
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# DirectoryPass support and assistance is available via the web site:
# http://www.DirectoryPass.com/
#
# Originally developed by Neil Skirrow, Locked-Area.com and ionix Limited.
# Version 1.4 released under GPL license June 2007.
# GNU GPL License: http://www.opensource.org/licenses/gpl-license.php
#

use CGI qw(:standard);
$query = new CGI;
# CGI.pm

# use CGI::Carp qw(fatalsToBrowser);
# fatals to browser, used if returns software error and if available on server
# remove hash to uncomment and enable fatals to browser for error detection

print "Content-type: text/html\n\n";
# set header

$self =  $ENV{'SCRIPT_NAME'};
# scripts filename/location for forms and links in output

$envref = $ENV{'HTTP_REFERER'};
# referring URL, used for 'Return to' links in output

my $tab = param("t");
# t query string input, selects 'browse' or 'manage' mode

if ("$tab" eq "") { $tab = "browse"; }
# default tab 'browse'

my $qrydir = param("d");
if ("$qrydir" eq "") { $qrydir = param("d"); }
# directory user is working, either browsing or managing

my $return = param("r");
if ("$return" eq "") { $return = param("r"); }
# r query string input, specifies a return URL to go back when using the software (may not be needed since v1.2)

my $protect = param("p");
if ("$qrydir" eq "") { $protect = param("p"); }
# p query string input, when equals 1 opens 'Enable' or 'Disable Password Protection' facility (to add or remove .htaccess file)

$action = param("action");
# action post input, used to specify whether adding or removing a user etc...

$first_install = param("first_install");
# first_install post input, used when script is first run and password is being set

if ("$serveros" eq "") { $serveros = param("serveros"); }
# if serveros variable not set, check for post input serveros

$actionpass = param("actionpass");
# actionpass post input, used when setting password and when entering the password for all administrative actions

$areaname = param("areaname");
# areaname post input, used for 'Member's Area Name' when using 'Enable Password Protection' facility

$username = param("username");
# username post input, used when adding new user

$password = param("password");
# password post input, used when adding new user

$confirmpassword = param("confirmpassword");
# confirmpassword post input, comfirmation password used when adding new user

my $qrylang = param("lang");
if ("$qrylang" eq "") { $qrylang = param("lang"); }
# language selection, input e.g. 'en' - English, 'fr' - French
if ("$qrylang" eq "") { $qrylang = "en"; } # default English

if ("$qrylang" eq "tr") { # Turkish Language Interface (thanks Merdan!!!)
if (-e "tr_lang.pl") {
require "tr_lang.pl";
$text{'66'} = qq~Klasör yok~;
} else {
print "<center><B>PLEASE DOWNLOAD TURKISH LANGUAGE PACK<br></center>";
}
} elsif ("$qrylang" eq "jp") { # Japanese Language Interface (thanks Matt!!!)
if (-e "jp_lang.pl") {
require "jp_lang.pl";
} else {
print "<center><B>PLEASE DOWNLOAD JAPANESE LANGUAGE PACK<br></center>";
}
} elsif ("$qrylang" eq "fi") { # Finnish Language Interface
$text{'1'} = qq~Siirry haluamaasi kansioon ja klikkaa 'Lisää salasanasuojaus' linkistä. Tai jos olet jo tehnyt niin, siirry haluamaasi kansioon ja valitse 'Hallitse käyttäjiä' välilehti ylhäältä.~;
$text{'2'} = qq~Nykyinen kansio:~;
$text{'3'} = qq~Ei voi avata kansiota:~;
$text{'4'} = qq~Syy:~;
$text{'5'} = qq~Salasanasuojattu~;
$text{'6'} = qq~YLÖS~;
$text{'7'} = qq~Poista salasanasuojaus~;
$text{'8'} = qq~Tämä kansio on jo salasanasuojattu.~;
$text{'9'} = qq~Lisää salasanasuojaus~;
$text{'10'} = qq~Tämä kansio ei ole salasanasuojattu.~;
$text{'11'} = qq~Poistaaksesi salasanasuojauksen tästä kansiosta anna järjestelmänvalvojan salasana alla olevaan kenttään. Tämä poistaa <a href="http://www.htaccess-guide.com/" class="gen" target="new">.htaccess</a> tiedoston nykyisestä kansiosta.~;
$text{'12'} = qq~Järjestelmänvalvojan salasana:~;
$text{'13'} = qq~Kansioita yhteensä:~;
$text{'14'} = qq~Tiedostoja yhteensä:~;
$text{'15'} = qq~Poista .htaccess tiedosto~;
$text{'16'} = qq~Suojataksesi tämän kansion salasanalla, kirjoita suojausalueen nimi ja järjestelmänvalvojan salasana alla oleviin kenttiin. Tämä toiminto luo <a href="http://www.htaccess-guide.com/" class="gen" target="new">.htaccess</a> tiedoston nykyiseen kansioon.~;
$text{'17'} = qq~Suojausalueen nimi:~;
$text{'18'} = qq~Luo .htaccess tiedosto~;
$text{'19'} = qq~Ei voi luoda tiedostoa:~;
$text{'20'} = qq~Suojausalueen nimeä ei syötetty.~;
$text{'21'} = qq~Salasanasuojaus poistettu~;
$text{'22'} = qq~Salasanasuojaus käytössä~;
$text{'23'} = qq~Ei voitu poistaa .htaccess tiedostoa, ~;
$text{'24'} = qq~Ei voitu poistaa .htpasswd tiedostoa, ~;
$text{'25'} = qq~Nykyisen kansion salasanasuojaus on poistettu käytöstä.~;
$text{'26'} = qq~Palaa 'Selaa'-välilehdelle~;
$text{'27'} = qq~, varmista että kansion, jossa tiedosto sijaitsee, oikeudet on määritelty oikein (755 tai 777).~;
$text{'28'} = qq~Nykyisen kansion salasanasuojaus on otettu käyttöön. Voit nyt lisätä käyttäjiä 'Hallitse käyttäjiä'-välilehden kautta.~;
$text{'29'} = qq~'Hallitse käyttäjiä'~;
$text{'30'} = qq~Käyttäjänimen on oltava vähintään kuusi merkkiä pitkä.~;
$text{'31'} = qq~Salasanan on oltava vähintään kuusi merkkiä pitkä ja salasanan on oltava sama kuin 'vahvista salasana'-kenttään syötetty.~;
$text{'32'} = qq~Käyttäjänimi, ~;
$text{'33'} = qq~ on jo käytössä.~;
$text{'34'} = qq~Ei voi avata tiedostoa ~;
$text{'35'} = qq~ on lisätty tietokantaan.~;
$text{'36'} = qq~ on poistettu onnistuneesti.~;
$text{'37'} = qq~Lisätäksesi käyttäjiä, täytä sivun lopussa oleva lomake ja valitse 'Lisää uusi käyttäjä'. Poistaaksesi käyttäjiä, valitse poistettava käyttäjä ja valitse 'Poista käyttäjä'.~;
$text{'38'} = qq~Poista käyttäjä~;
$text{'39'} = qq~Käyttäjänimi:~;
$text{'40'} = qq~Ei käyttäjiä~;
$text{'41'} = qq~Tämä kansio on salasanasuojattu, mutta yhtään käyttäjää ei ole määritelty. Lisätäksesi käyttäjiä täytä alla oleva lomake ja valitse 'Lisää uusi käyttäjä'.~;
$text{'42'} = qq~Lisää uusi käyttäjä~;
$text{'43'} = qq~Salasana:~;
$text{'44'} = qq~Vahvista salasana:~;
$text{'45'} = qq~Ei salasanasuojausta~;
$text{'46'} = qq~Tämä kansio ei ole salasanasuojattu, lisää salasanasuojaus 'Selaa'-välilehden kautta ennen 'Hallitse käyttäjiä'-välilehden avaamista.~;
$text{'47'} = qq~Aloittaaksesi DirectoryPassin asennuksen, syötä järjestelmänvalvojan salasana. Tätä salasanaa käytetään muutosten vahvistamiseen ohjelmassa. Määritä myös palvelimen käyttöjärjestelmä, jossa DirectoryPassia ajetaan.~;
$text{'48'} = qq~Salasanan on oltava vähintään kuusi merkkiä pitkä.~;
$text{'49'} = qq~WWW-palvelimen käyttöjärjestelmä:~;
$text{'50'} = qq~Unix/Linux~;
$text{'51'} = qq~Windows~;
$text{'52'} = qq~Cobalt RAQ~;
$text{'53'} = qq~Asenna DirectoryPass~;
$text{'54'} = qq~Järjestelmänvalvojan salasana ei kelpaa~;
$text{'55'} = qq~Syöttämäsi järjestelmänvalvojan salasana on väärä.~;
$text{'56'} = qq~Palaa ~;
$text{'57'} = qq~ Järjestelmävirhe~;
$text{'58'} = qq~Selaa~;
$text{'59'} = qq~Hallitse käyttäjiä~;
$text{'60'} = qq~Kieli: ~;
$text{'61'} = qq~Powered by ~;
$text{'62'} = qq~, a product of ~;
$text{'63'} = qq~Copyright~;
$text{'64'} = qq~All Rights Reserved.~;
$text{'65'} = qq~Käyttäjiä yhteensä:~;
$text{'66'} = qq~Ei kansioita~; 
} elsif ("$qrylang" eq "nl") { # Dutch Language Interface (thanks Loek!!!)
$text{'1'} = qq~Kies de map die van een wachtwoord moet worden voorzien en selecteer dan de 'Wachtwoord instellen' link hieronder of wanneer dat al is gebeurd, zoek dan de betreffende map en selecteer 'Gebruikers' hierboven~;
$text{'2'} = qq~Huidige map:~;
$text{'3'} = qq~Map kan niet worden geopend:~;
$text{'4'} = qq~Reden:~;
$text{'5'} = qq~Met wachtwoord beveiligd~;
$text{'6'} = qq~Hoger~;
$text{'7'} = qq~Wachtwoord uitschakelen~;
$text{'8'} = qq~Deze map is al voorzien van een wachtwoord.~;
$text{'9'} = qq~Wachtwoord instellen~;
$text{'10'} = qq~Deze map is niet voorzien van een wachtwoord.~;
$text{'11'} = qq~Verwijder het onderstaande administrator wachtwoord om het wachtwoord voor deze map uit te schakelen.  Het bestand <a href="http://www.htaccess-guide.com/" class="gen" target="new">.htaccess</a> wordt verwijderd uit de huidige map.~;
$text{'12'} = qq~Administrator Wachtwoord:~;
$text{'13'} = qq~Aantal mappen:~;
$text{'14'} = qq~Aantal bestanden:~;
$text{'15'} = qq~Verwijder .htaccess bestand~;
$text{'16'} = qq~Geef de Groepsnaam en het administrator wachtwoord om een wachtwoord voor deze map te maken.  Het bestand <a href="http://www.htaccess-guide.com/" class="gen" target="new">.htaccess</a> wordt in de huidige map geplaatst.~;
$text{'17'} = qq~Groepsnaam:~;
$text{'18'} = qq~Maak .htaccess bestand~;
$text{'19'} = qq~Bestand kan niet worden gemaakt:~;
$text{'20'} = qq~Geen Groepsnaam opgegeven.~;
$text{'21'} = qq~Wachtwoord uitgeschakeld~;
$text{'22'} = qq~Wachtwoord ingeschakeld~;
$text{'23'} = qq~Niet mogelijk om bestand .htaccess te verwijderen, ~;
$text{'24'} = qq~Niet mogelijk om bestand .htpasswd te verwijderen, ~;
$text{'25'} = qq~Wachtwoord van de huidige map is met succes uitgeschakeld.~;
$text{'26'} = qq~Terug naar 'Bladeren'~;
$text{'27'} = qq~, zorg er voor dat de machtigingen voor de map met dit bestand ingesteld zijn op 755 of 777.~;
$text{'28'} = qq~Wachtwoord voor de huidige map met succes ingesteld.  Er kunnnen nu gebruikers worden toegevoegd via 'Gebruikers'.~;
$text{'29'} = qq~'Gebruikers'~;
$text{'30'} = qq~'Gebruiker' bestaat uit zes tekens of meer.~;
$text{'31'} = qq~'Wachtwoord' en 'Bevestig wachtwoord' moeten tenminste zes tekens bevatten en aan elkaar gelijk zijn.~;
$text{'32'} = qq~Gebruiker, ~;
$text{'33'} = qq~ komt reeds voor in de database.~;
$text{'34'} = qq~Kan het bestand niet openen ~;
$text{'35'} = qq~ is toegevoegd aan de database.~;
$text{'36'} = qq~, '$username' is met succes verwijderd.~;
$text{'37'} = qq~Gebruiker toevoegen: Vul het formulier aan het einde van deze pagina volledig in en kies 'Nieuwe gebruiker toevoegen'. Gebruiker verwijderen: Maak een keuze uit de selectie en selecteer 'Gebruiker verwijderen'.~;
$text{'38'} = qq~Gebruiker verwijderen~;
$text{'39'} = qq~Gebruikersnaam:~;
$text{'40'} = qq~Geen gebruikers~;
$text{'41'} = qq~Deze map is beveiligd met een wachtwoord maar er zijn geen gebruikers. Vul het onderstaande formulier volledig in om gebruikers toe te voegen.~;
$text{'42'} = qq~Nieuwe gebruiker toevoegen~;
$text{'43'} = qq~Wachtwoord:~;
$text{'44'} = qq~Bevestig wachtwoord:~;
$text{'45'} = qq~Geen wachtwoordbeveiliging~;
$text{'46'} = qq~Deze map is niet beveiligd met een wachtwoord. Schakel het wachtwoord in via 'Bladeren' voordat gebruikers worden toegevoegd met 'Gebruikers'.~;
$text{'47'} = qq~Geef het administrator wachtwoord voor de installatie van DirectoryPass.  Dit wachtwoord is noodzakelijk om de acties te controleren tijdens het gebruik van DirectoryPass.  Specificeer ook het operating system van de web server waarop DirectoryPass wordt gebruikt.~;
$text{'48'} = qq~Het wachtwoord bestaat uit zes of meer tekens.~;
$text{'49'} = qq~Web Server OS:~;
$text{'50'} = qq~Unix/Linux~;
$text{'51'} = qq~Windows~;
$text{'52'} = qq~Cobalt RAQ~;
$text{'53'} = qq~Setup DirectoryPass~;
$text{'54'} = qq~Onjuist Administrator Wachtwoord~;
$text{'55'} = qq~Het opgegeven administrator wachtwoord is niet juist.~;
$text{'56'} = qq~Terug naar ~;
$text{'57'} = qq~ Systeem Fout~;
$text{'58'} = qq~Bladeren~;
$text{'59'} = qq~Gebruikers~;
$text{'60'} = qq~Taal: ~;
$text{'61'} = qq~Powered by ~;
$text{'62'} = qq~, een product van ~;
$text{'63'} = qq~Copyright~;
$text{'64'} = qq~Alle rechten gereserveerd.~;
$text{'65'} = qq~Aantal Gebruikers:~;
$text{'66'} = qq~Geen mappen~;
} elsif ("$qrylang" eq "it") { # Italian Language Interface (thanks Giulio!!!)
$text{'1'} = qq~Entra all'inteno della cartella che vuoi proteggere con password e quindi seleziona il link 'Proteggi cartella con Password', o se la cartella è già protetta seleziona il link 'Gestione utenti'.~;
$text{'2'} = qq~Cartella corrente:~;
$text{'3'} = qq~Non è possibile aprire la cartella:~;
$text{'4'} = qq~Motivo:~;
$text{'5'} = qq~Protetto da Password~;
$text{'6'} = qq~SU~;
$text{'7'} = qq~Rimuovi la protezione Password~;
$text{'8'} = qq~Questa cartella è già protetta da password.~;
$text{'9'} = qq~Abilita protezione Password~;
$text{'10'} = qq~Questa cartella non è protetta da password.~;
$text{'11'} = qq~Per disabilitare la protezione su questa cartella, inserisci la password di amministratore qui sotto. Questo rimuoverà il file <a href="http://www.htaccess-guide.com/" class="gen" target="new">.htaccess</a> file dalla cartella corrente.~;
$text{'12'} = qq~Password Amministratore:~;
$text{'13'} = qq~Cartelle Totali:~;
$text{'14'} = qq~File Totali:~;
$text{'15'} = qq~Cancella il file .htaccess~;
$text{'16'} = qq~Per abilitare la protezione con password su questa cartella, inserisci il nome di questa member's area e la tua password di amministratore.  Verrà creato il file <a href="http://www.htaccess-guide.com/" class="gen" target="new">.htaccess</a> in questa cartella.~;
$text{'17'} = qq~Nome Area degli Utenti:~;
$text{'18'} = qq~Crea file .htaccess ~;
$text{'19'} = qq~Creazione file fallita:~;
$text{'20'} = qq~Nessun nome per l'area degli utenti inserito.~;
$text{'21'} = qq~Protezione con Password Disabilitata~;
$text{'22'} = qq~Protezione con Password Abilitata~;
$text{'23'} = qq~Impossibile rimuovere il file .htaccess , ~;
$text{'24'} = qq~Impossibile rimuovere il file .htpasswd , ~;
$text{'25'} = qq~La protezione della cartella è stata rimossa correttamente.~;
$text{'26'} = qq~Ritorna a 'Navigazione'~;
$text{'27'} = qq~, verifica che la cartella abbia i permessi settati a  755 o 777.~;
$text{'28'} = qq~La protezione con password per questa cartella è stata abilitata con successo. Adesso puoi aggiungere degli utenti attraverso la seione 'Gestione Utenti'.~;
$text{'29'} = qq~'Gestione Utenti'~;
$text{'30'} = qq~Il nome utente deve essere lungo almeno 6 caratteri.~;
$text{'31'} = qq~La Password deve essere lunga almeno 6 caratteri e deve corrispondere a Conferma Password.~;
$text{'32'} = qq~Nome Utente, ~;
$text{'33'} = qq~ già presente nel database.~;
$text{'34'} = qq~Impossibile aprire il file ~;
$text{'35'} = qq~ è stato aggiunto alla base dati.~;
$text{'36'} = qq~, '$username' è stato rimosso correttamente.~;
$text{'37'} = qq~Per aggiungere un nuovo utente, completa il modulo presente alla fine di questa pagina e seleziona 'Aggiungi Nuovo Utene, per rimuovere un utente esistente selezionalo e poi premi 'Rimuovi Utente'.~;
$text{'38'} = qq~Rimuovi Utente~;
$text{'39'} = qq~Nome Utente:~;
$text{'40'} = qq~Nessun Utente~;
$text{'41'} = qq~La cartella è protetta con password, ma al momento non vi è nessu utente abilitato ad essa, per aggiungerlo completa il modulo sottostante.~;
$text{'42'} = qq~Aggiungi Nuovo Utente~;
$text{'43'} = qq~Password:~;
$text{'44'} = qq~Conferma Password:~;
$text{'45'} = qq~Non protetto da Password~;
$text{'46'} = qq~Questa cartella non è protetta da password, abilita la protezione attraverso la sezione 'Navigazione' prima si selezionare 'Gestione Utenti'.~;
$text{'47'} = qq~Per configurare la tua installazione di DirectoryPass, inserisci la password di amministratore. Potrai usare questa password per effettuare le azioni che desideri quando userai  DirectoryPass.  Specifica anche su quale sistema operativo sarà in esecuzione DirectoryPass.~;
$text{'48'} = qq~La tua password deve essere di almeno sei caratteri.~;
$text{'49'} = qq~Sistema operativo Server:~;
$text{'50'} = qq~Unix/Linux~;
$text{'51'} = qq~Windows~;
$text{'52'} = qq~Cobalt RAQ~;
$text{'53'} = qq~Configurazione DirectoryPass~;
$text{'54'} = qq~Password di Amministratore sbagliata~;
$text{'55'} = qq~La password di Amministratore inserita è errata.~;
$text{'56'} = qq~Ritorna a ~;
$text{'57'} = qq~ Errore di Sistema~;
$text{'58'} = qq~Navigazione~;
$text{'59'} = qq~Gestione utenti~;
$text{'60'} = qq~Lingua: ~;
$text{'61'} = qq~Powered by ~;
$text{'62'} = qq~, un prodotto di ~;
$text{'63'} = qq~Copyright~;
$text{'64'} = qq~Tutti i diritti riservati.~;
$text{'65'} = qq~Utenti Totali:~;
$text{'66'} = qq~N. Cartelle~;
} elsif ("$qrylang" eq "pt") { # Portuguese Language Interface (thanks Mestrini!!!)
$text{'1'} = qq~Navegue até à pasta que deseja proteger com palavra-passe e seleccione o atalho 'Directoria Protegida por Palavra-passe', ou se já o tiver feito procure a pasta respectiva e seleccione 'Gerir Utilizadores' em cima.~;
$text{'2'} = qq~Directoria actual:~;
$text{'3'} = qq~Não é possível abrir pasta:~;
$text{'4'} = qq~Motivo:~;
$text{'5'} = qq~Protegida com Palavra-passe~;
$text{'6'} = qq~CIMA~;
$text{'7'} = qq~Desactivar Protecção por Palavra-passe~;
$text{'8'} = qq~Esta pasta já está protegida por palavra-passe.~;
$text{'9'} = qq~Activar Protecção por Palavra-passe~;
$text{'10'} = qq~Esta pasta não está protegida por palavra-passe.~;
$text{'11'} = qq~Para desactivar a protecção por palavra-passe nesta directoria, por favor introduza a sua palavra-passe de administrador em baixo. Esta acção irá apagar o <a href="http://www.htaccess-guide.com/" class="gen" target="new">.htaccess</a> ficheiro da directoria actual.~;
$text{'12'} = qq~Palavra-passe Admin:~;
$text{'13'} = qq~Total Directorias:~;
$text{'14'} = qq~Total Ficheiros:~;
$text{'15'} = qq~Remover ficheiro .htaccess~;
$text{'16'} = qq~Para activar a protecção por palavra-passe nesta directoria, introduzir o nome da área deste membro e a sua palavra-passe de administração. Isto irá criar um <a href="http://www.htaccess-guide.com/" class="gen" target="new">.htaccess</a> ficheiro na directoria actual.~;
$text{'17'} = qq~Nome de Área do Membro:~;
$text{'18'} = qq~Criar Ficheiro .htaccess~;
$text{'19'} = qq~Não consigo criar ficheiro:~;
$text{'20'} = qq~Não foi introduzido nome de área do membro.~;
$text{'21'} = qq~Protecção por Palavra-passe Desactivada~;
$text{'22'} = qq~Protecção por Palavra-passe Activada~;
$text{'23'} = qq~Não consegui remover o ficheiro .htaccess, ~;
$text{'24'} = qq~Não consegui remover o ficheiro .htpasswd, ~;
$text{'25'} = qq~Protecção por Palavra-passe da directoria actual foi desactivada com sucesso.~;
$text{'26'} = qq~regressare a 'Browse'~;
$text{'27'} = qq~, certifique-se que a directoria com este ficheiro tem as permissões definidas para 755 ou 777.~;
$text{'28'} = qq~Protecção por Palavra-passe da directoria actual foi activada com sucesso. Já pode adicionar utilizadores através da secção 'Gerir Utilizadores'.~;
$text{'29'} = qq~'Gerir Utilizadores'~;
$text{'30'} = qq~Nome de utilizador tem que ter seis caracteres ou mais de comprimento.~;
$text{'31'} = qq~Palavra-passe e confirmação de palavra-passe têm que ter seis caracteres ou mais de comprimento e têm que ser iguais.~;
$text{'32'} = qq~Nome de utilizador, ~;
$text{'33'} = qq~ já existe na base de dados.~;
$text{'34'} = qq~Não consegui abrir ficheiro ~;
$text{'35'} = qq~ foi adicionado à base de dados.~;
$text{'36'} = qq~, '$username' foi removido com sucesso.~;
$text{'37'} = qq~Para adicionar novo utilizador, por favor complete o formulário no final desta página e seleccione  'Adicionar novo utilizador'. Para remover um utilizador existente efectuar a selecção apropriada em baixo e seleccionar 'Remover Utilizador'.~;
$text{'38'} = qq~Remover Utilizador~;
$text{'39'} = qq~Nome de utilizador:~;
$text{'40'} = qq~Sem utilizadores~;
$text{'41'} = qq~Esta directoria está protegida por palavra-passe, mas actualmente não contém utilizadores; para adicionar novos utilizadores por favor complete o formulário em baixo.~;
$text{'42'} = qq~Adicionar Novo Utilizador~;
$text{'43'} = qq~Palavra-passe:~;
$text{'44'} = qq~Confirmar Palavra-passe:~;
$text{'45'} = qq~Não protegida por Palavra-passe~;
$text{'46'} = qq~Esta directoria não está protegia por palavra-passe. Por favor active a protecção através da secção 'Browse' antes de seleccionar 'Gerir Utilizadores'.~;
$text{'47'} = qq~Para definir a sua instalação de DirectoryPass, por favor introduzir a palavra-passe de administração desejada. Irá usar esta palavra-passe para verificar as suas acções durante a utilização de DirectoryPass. Especifique também qual o sistema operativo (SO) do servidor no qual DirectoryPass está a correr.~;
$text{'48'} = qq~A sua palavra-passe tem que ter seis ou mais caracteres de comprimento.~;
$text{'49'} = qq~SO do Servidor Web:~;
$text{'50'} = qq~Unix/Linux~;
$text{'51'} = qq~Windows~;
$text{'52'} = qq~Cobalt RAQ~;
$text{'53'} = qq~Personalizar DirectoryPass~;
$text{'54'} = qq~Palavra-passe de Administrator incorrecta~;
$text{'55'} = qq~A palavra-passe de administrador que introduziu está incorrecta.~;
$text{'56'} = qq~Regressar a ~;
$text{'57'} = qq~ Erro de Sistema~;
$text{'58'} = qq~Browse~;
$text{'59'} = qq~Gerir Utilizadores~;
$text{'60'} = qq~Linguagem: ~;
$text{'61'} = qq~Powered by ~;
$text{'62'} = qq~, um producto de ~;
$text{'63'} = qq~Copyright~;
$text{'64'} = qq~Todos direitos reservados.~;
$text{'65'} = qq~Total Utilizadores:~;
$text{'66'} = qq~No directories~;
} elsif ("$qrylang" eq "es") { # Spanish Language Interface (thanks Moses!!!)
$text{'1'} = qq~Please navigate below to find the directory you wish to password protect then select the 'Password Protect Directory' link below, or if you have already done so please find the appropriate directory and select 'Manage Users' above.~;
$text{'2'} = qq~Directorio actual:~;
$text{'3'} = qq~No se puede abrir directorio:~;
$text{'4'} = qq~Razón:~;
$text{'5'} = qq~Protegido por contraseña~;
$text{'6'} = qq~UP~;
$text{'7'} = qq~Deshabilitar protección de contraseña~;
$text{'8'} = qq~Este directorio ya está protegido por contraseña.~;
$text{'9'} = qq~Habilitar protección por contraseña~;
$text{'10'} = qq~Este directorio no esta protegido por contraseña.~;
$text{'11'} = qq~Para deshabilitar protección por contraseña en este directorio, por favor escriba su contraseña de administrador abajo. Esto eliminará el archivo <a href="http://www.htaccess-guide.com/" class="gen" target="new">.htaccess</a> del directorio actual.~;
$text{'12'} = qq~Contraseña de administrador:~;
$text{'13'} = qq~Total de Directorios:~;
$text{'14'} = qq~Total de Archivos:~;
$text{'15'} = qq~Remover Archivo .htaccess~;
$text{'16'} = qq~Para habilitar protección por contraseña en este directorio, por favor introduzca el nombre de esta área para miembros y su contraseña de administrador. Esto creará un archivo<a href="http://www.htaccess-guide.com/" class="gen" target="new">.htaccess</a> en el directorio actual.~;
$text{'17'} = qq~Nombre de Area de Miembros:~;
$text{'18'} = qq~Crear archivo .htaccess~;
$text{'19'} = qq~No se puede crear archivo:~;
$text{'20'} = qq~No se introdujo nombre de Area de Miembros.~;
$text{'21'} = qq~Protección por Contraseña deshabilitada~;
$text{'22'} = qq~Protección por contraseña habilitada~;
$text{'23'} = qq~No se pudo eliminar archivo .htaccess, ~;
$text{'24'} = qq~No se pudo eliminar archivo .htpasswd, ~;
$text{'25'} = qq~La protección por contraseña del directorio actual se deshabilitó exitosamente..~;
$text{'26'} = qq~Regresar a 'Navegar'~;
$text{'27'} = qq~, asegúrese que el directorio donde se encuentra el archivo tenga permisos 755 or 777.~;
$text{'28'} = qq~La protección por contraseña del directorio actual ha sido habilitada exitosamente. Ahora puede agregar usuarios en la sección 'Administrar Usuarios'.~;
$text{'29'} = qq~'Administrar Usuarios'~;
$text{'30'} = qq~El Nombre de Usuario debe tener 6 o más caracteres.~;
$text{'31'} = qq~La Contraseña y su confirmación deben ser iguales y tener 6 o más caracteres.~;
$text{'32'} = qq~Nombre de Usuario, ~;
$text{'33'} = qq~ ya existe en la base de datos.~;
$text{'34'} = qq~No se pudo abrir archivo ~;
$text{'35'} = qq~ ha sido agregado a la base de datos.~;
$text{'36'} = qq~ ha sido eliminado exitosamnte.~;
$text{'37'} = qq~Para agregar un nuevo usuario, por favor complete el formulario al final de esta página y seleccione 'Agregar Nuevo Usuario', para remover un usuario existente por favor haga la selección correcta abajo y elija 'Remover Usuario'.~;
$text{'38'} = qq~Remover Usuario~;
$text{'39'} = qq~Nombre de Usuario:~;
$text{'40'} = qq~No hay Usuarios~;
$text{'41'} = qq~Este directorio está protegido por contraseña, pero actualmente no tiene usuarios, para agregar un nuevo usuario por favor complete el formulario de abajo.~;
$text{'42'} = qq~Agregar Nuevo Usuario~;
$text{'43'} = qq~Contraseña:~;
$text{'44'} = qq~Confirmar Contraseña:~;
$text{'45'} = qq~No está protegido por Contraseña~;
$text{'46'} = qq~Este directorio no esta progido por contraseña, por favor habilite la protección en la sección 'Navegar' antes de ir a 'Administrar Usuarios'.~;
$text{'47'} = qq~Para configurar su instalación de DirectoryPass, por favor introduzca una contraseña de administrador. Usted utilizará esta contraseña para autentificar sus acciones al utilizar DirectoryPass. Especifique también qué Sistema Operativo SO utiliza el servidor web donde correrá DirectoryPass.~;
$text{'48'} = qq~Su contraseña debe tener 6 o más caracteres.~;
$text{'49'} = qq~SO del servidor Web:~;
$text{'50'} = qq~Unix/Linux~;
$text{'51'} = qq~Windows~;
$text{'52'} = qq~Cobalt RAQ~;
$text{'53'} = qq~Configurar DirectoryPass~;
$text{'54'} = qq~Contraseña de Administrador Incorrecta~;
$text{'55'} = qq~La contraseña de administrador que ha introducido es incorrecta.~;
$text{'56'} = qq~Regresar a ~;
$text{'57'} = qq~ Error de Sistema~;
$text{'58'} = qq~Navegar~;
$text{'59'} = qq~Administrar Usuarios~;
$text{'60'} = qq~Idioma: ~;
$text{'61'} = qq~Powered by ~;
$text{'62'} = qq~, a product of ~;
$text{'63'} = qq~Copyright~;
$text{'64'} = qq~Todos los derechos reservados.~;
$text{'65'} = qq~Total de Usuarios:~;
$text{'66'} = qq~Sin Directorios~;
} elsif ("$qrylang" eq "fr") { # French Language Interface (thanks Claude!!!)
$text{'1'} = qq~Veuillez parcourir l'arborescence ci-dessous pour choisir le répertoire que vous souhaitez protéger par mot de passe et sélectionner ensuite le lien 'Password Protect Directory' ou bien, si vous l'avez déjà fait, veuillez sélectionner le répertoire voulu et sélectionner la section 'Gestion Utilisateurs'.~;
$text{'2'} = qq~Répertoire Courant:~;
$text{'3'} = qq~Impossible d'ouvrir le répertoire:~;
$text{'4'} = qq~Raison:~;
$text{'5'} = qq~Protégé par un mot de passe~;
$text{'6'} = qq~UP~;
$text{'7'} = qq~Désactiver la protection par mot de passe~;
$text{'8'} = qq~Ce répertoire est déjà protégé par un mot de passe.~;
$text{'9'} = qq~Activer la protection par mot de passe~;
$text{'10'} = qq~Ce répertoire n'est pas protégé par un mot de passe.~;
$text{'11'} = qq~Pour désactiver la protection par mot de passe sur ce répertoire, veuillez saisir ci-dessous le mot de passe administrateur. Ceci détruira le fichier <a href="http://www.htaccess-guide.com/" class="gen" target="new">.htaccess</a> du répertoire courant.~;
$text{'12'} = qq~Mot de passe administrateur:~;
$text{'13'} = qq~Nombre total de répertoires:~;
$text{'14'} = qq~Nombre total de fichiers:~;
$text{'15'} = qq~Supprimer le fichier .htaccess~;
$text{'16'} = qq~Pour activer la protection par mot de passe sur ce répertoire, veuillez saisir le nom de cette zone Membres ainsi que votre mot de passe administrateur. Ceci va créer un fichier <a href="http://www.htaccess-guide.com/" class="gen" target="new">.htaccess</a> dans le répertoire courant.~;
$text{'17'} = qq~Nom de la zone Membres :~;
$text{'18'} = qq~Créer le fichier .htaccess~;
$text{'19'} = qq~Impossible de créer le fichier:~;
$text{'20'} = qq~Pas de nom saisi pour la zone Membre.~;
$text{'21'} = qq~Protection par mot de passe désactivée~;
$text{'22'} = qq~Protection par mot de passe activée~;
$text{'23'} = qq~Impossible de supprimer le fichier .htaccess, ~;
$text{'24'} = qq~Impossible de supprimer le fichier .htpasswd, ~;
$text{'25'} = qq~La protection par mot de passe du répertoire courant a été désactivée avec succès.~;
$text{'26'} = qq~Retour à 'Visualiser'~;
$text{'27'} = qq~, assurez vous que le répertoire contenant ce fichier a bien les permissions positionnées à 755 ou 777.~;
$text{'28'} = qq~La protection par mot de passe du répertoire courant a été activée avec succès. Vous pouvez maintenant ajouter des utilisateurs via la section 'Gestion Utilisateurs'.~;
$text{'29'} = qq~'Gestion Utilisateurs'~;
$text{'30'} = qq~Le nom d'utilisateur doit avoir au moins 6 caractères.~;
$text{'31'} = qq~Le mot de passe et sa confirmation doivent avoir au moins 6 caractères et doivent correspondre.~;
$text{'32'} = qq~Nom d'utilisateur, ~;
$text{'33'} = qq~ existe déjà dans la base de données.~;
$text{'34'} = qq~Impossible d'ouvrir le fichier ~;
$text{'35'} = qq~ a été ajouté à la base de données.~;
$text{'36'} = qq~ a été supprimé avec succès.~;
$text{'37'} = qq~Pour ajouter un utilisateur, veuillez remplir le formulaire en bas de cette page et sélectionner 'Ajouter un nouvel utilisateur', pour supprimer un utilisateur existant, veuillez le sélectionner ci-dessous et continuer avec 'Supprimer un utilisateur'.~;
$text{'38'} = qq~Supprimer un utilisateur~;
$text{'39'} = qq~Nom d'utilisateur:~;
$text{'40'} = qq~Pas d'utilisateur~;
$text{'41'} = qq~Ce répertoire est protégé par un mot de passe mais ne contient pas encore d'utilisateurs. Pour ajouter un nouvel utilisateur, veuillez remplir le formulaire ci-dessous.~;
$text{'42'} = qq~Ajouter un nouvel utilisateur~;
$text{'43'} = qq~Mot de passe:~;
$text{'44'} = qq~Confirmer le mot de passe:~;
$text{'45'} = qq~Pas protégé par un mot de passe~;
$text{'46'} = qq~Ce répertoire n'est pas protégé par un mot de passe, veuillez activer la protection par mot de passe via la section 'Browse' avant de sélectionner 'Gestion Utilisateurs'.~;
$text{'47'} = qq~Pour configurer votre instance de DirectoryPass, veuillez choisir un mot de passe administrateur. Vous utiliserez ce mot de passe pour valider vos actions dans DirectoryPass. Veuillez également indiquer le système d'exploitation du serveur Web géré par DirectoryPass.~;
$text{'48'} = qq~Votre mot de passe doit avoir au moins 6 caractères.~;
$text{'49'} = qq~Système d'exploitation du serveur Web:~;
$text{'50'} = qq~Unix/Linux~;
$text{'51'} = qq~Windows~;
$text{'52'} = qq~Cobalt RAQ~;
$text{'53'} = qq~Configuration de DirectoryPass~;
$text{'54'} = qq~Mot de passe administrateur incorrect~;
$text{'55'} = qq~Le mot de passe administrateur que vous avez saisi est incorrect.~;
$text{'56'} = qq~Retour à ~;
$text{'57'} = qq~ Erreur Système~;
$text{'58'} = qq~Visualiser~;
$text{'59'} = qq~Gestion Utilisateurs~;
$text{'60'} = qq~Langue: ~;
$text{'61'} = qq~Powered by ~;
$text{'62'} = qq~, un produit de ~;
$text{'63'} = qq~Copyright~;
$text{'64'} = qq~Tous Droits Réservés.~;
$text{'65'} = qq~Nombre total d'utilisateurs:~; 
$text{'66'} = qq~No directories~;
} elsif ("$qrylang" eq "de") { # German Language Interface (thanks Julian!!!)
$text{'1'} = qq~Bitte suchen Sie den Ordner, den Sie mit einem Passwort schützen wollen. Dann klicken Sie auf 'Ordner schützen', oder falls Sie dies bereits getan haben, klicken Sie auf 'Benutzer verwalten'.~;
$text{'2'} = qq~Aktueller Ordner:~;
$text{'3'} = qq~Kann Ordner nicht öffnen:~;
$text{'4'} = qq~Grund:~;
$text{'5'} = qq~Passwortgeschützt~;
$text{'6'} = qq~Aufwärts~;
$text{'7'} = qq~Passwortschutz deaktivieren~;
$text{'8'} = qq~Dieser Ordner ist bereits passwortgeschützt.~;
$text{'9'} = qq~Passwortschutz aktivieren~;
$text{'10'} = qq~Dieser ordner ist nicht passwortgeschützt.~;
$text{'11'} = qq~Um den Passwortschutz zu deaktivieren, geben Sie unten bitte Ihr Administratorpasswort ein. Dies wird die <a href="http://www.htaccess-guide.com/" class="gen" target="new">.htaccess</a>-Datei löschen.~;
$text{'12'} = qq~Admin Passwort:~;
$text{'13'} = qq~Anzahl Ordner:~;
$text{'14'} = qq~Anzahl Dateien:~;
$text{'15'} = qq~.htaccess-Datei löschen~;
$text{'16'} = qq~Um den Passwortschutz zu aktivieren, geben Sie bitte den Namen des Bereichs sowie Ihr Administrationspasswort ein.  Dies wird eine <a href="http://www.htaccess-guide.com/" class="gen" target="new">.htaccess</a>-Datei erstellen.~;
$text{'17'} = qq~Name des Bereichs:~;
$text{'18'} = qq~.htaccess-Datei erstellen~;
$text{'19'} = qq~Kann Datei nicht erstellen:~;
$text{'20'} = qq~Kein Name eingegeben.~;
$text{'21'} = qq~Passwortschutz deaktiviert~;
$text{'22'} = qq~Passwortschutz aktiviert~;
$text{'23'} = qq~Konnte .htaccess-Datei nicht löschen, ~;
$text{'24'} = qq~Konnte .htpasswd-datei nicht löschen, ~;
$text{'25'} = qq~Passwortschutz wurde erfolgreich deaktiviert.~;
$text{'26'} = qq~Zum 'Browsen' zurückkehren~;
$text{'27'} = qq~, stellen Sie sicher, dass die Rechte dieses Ordners auf 777 oder 775 gestellt sind.~;
$text{'28'} = qq~Passwortschutz wurde erfolgreich aktiviert.  Sie können nun Benutzer mit 'Benutzer verwalten' hinzufügen.~;
$text{'29'} = qq~'Benutzer verwalten'~;
$text{'30'} = qq~Benutzername muss sechs Zeichen oder länger sein.~;
$text{'31'} = qq~Das Passwort sowie das bestätigte PAsswort müssen sechs oder mehr Zeichen lang sein und sich gleichen.~;
$text{'32'} = qq~Benutzername, ~;
$text{'33'} = qq~ befindet sich bereits in der Datenbank.~;
$text{'34'} = qq~Konnte Datei nicht öffnen ~;
$text{'35'} = qq~ wurde zur datnbank hinzugefügt.~;
$text{'36'} = qq~ wurde erfolgreich gelöscht.~;
$text{'37'} = qq~Um einen neuen Benutzer anzulegen, füllen Sie bitte das Formular am Ende der Seite aus und klicken 'benutzer hinzufügen', um einen Benutzer zu löschen, machen Sie bitte Ihre Auswahl unten und klicken Sie 'Benutzer löschen'.~;
$text{'38'} = qq~Benutzer löschen~;
$text{'39'} = qq~Benutzername:~;
$text{'40'} = qq~Keine Benutzer~;
$text{'41'} = qq~Dieser Ordner ist passwortgeschützt, hat im Moment allerdings noch keine Benutzer. Um einen anzulegen, füllen Sie bitte das Formular unten aus.~;
$text{'42'} = qq~Neuen Benutzer hinzufügen~;
$text{'43'} = qq~Passwort:~;
$text{'44'} = qq~Passwort bestätigen:~;
$text{'45'} = qq~Nicht passwortgeschützt~;
$text{'46'} = qq~Dieser Ordner ist noch nicht passwortgeschützt. Bitte schützen Sie ihn, bevor Sie Benutzer verwalten.~;
$text{'47'} = qq~Um DirectoryPass benutzen zu können, geben Sie bitte Ihr gewünschtes Administrationspasswort ein. Sie benötigen dieses PAsswort, um alle Aktionen mit DirectoryPass zu authorisieren. Bitte geben Sie außerdem ein, welches Betriebssystem ihr Server benutzt.~;
$text{'48'} = qq~Ihr Passwort muss sechs oder mehr Zeichen lang sein.~;
$text{'49'} = qq~Web-Server Betriebssystem:~;
$text{'50'} = qq~Unix/Linux~;
$text{'51'} = qq~Windows~;
$text{'52'} = qq~Cobalt RAQ~;
$text{'53'} = qq~DirectoryPass installieren~;
$text{'54'} = qq~Falsches Administratorpasswort~;
$text{'55'} = qq~Das Administrationspasswort, welches Sie eingegeben haben ist falsch.~;
$text{'56'} = qq~Zurückkehren zu ~;
$text{'57'} = qq~ Systemfehler~;
$text{'58'} = qq~Browsen~;
$text{'59'} = qq~Benutzer verwalten~;
$text{'60'} = qq~Sprache: ~;
$text{'61'} = qq~Powered by ~;
$text{'62'} = qq~, ein Produkt von ~;
$text{'63'} = qq~Copyright~;
$text{'64'} = qq~Alle Rechte vorbehalten.~;
$text{'65'} = qq~Anzahl Benutzer:~;
$text{'66'} = qq~Keine ordner vorhanden~;
} else { # Default English Language Interface
####### TEXT VARIABLES (translations please?) #######
$text{'1'} = qq~Please navigate below to find the directory you wish to password protect then select the 'Password Protect Directory' link below, or if you have already done so please find the appropriate directory and select 'Manage Users' above.~;
$text{'2'} = qq~Current Directory:~;
$text{'3'} = qq~Can't open directory:~;
$text{'4'} = qq~Reason:~;
$text{'5'} = qq~Password Protected~;
$text{'6'} = qq~UP~;
$text{'7'} = qq~Disable Password Protection~;
$text{'8'} = qq~This directory is already password protected.~;
$text{'9'} = qq~Enable Password Protection~;
$text{'10'} = qq~This directory is not password protected.~;
$text{'11'} = qq~To disable password protection on this directory, please enter your administrator password below.  This will delete the <a href="http://www.htaccess-guide.com/" class="gen" target="new">.htaccess</a> file from the current directory.~;
$text{'12'} = qq~Administrator Password:~;
$text{'13'} = qq~Total Directories:~;
$text{'14'} = qq~Total Files:~;
$text{'15'} = qq~Remove .htaccess File~;
$text{'16'} = qq~To enable password protection on this directory, please enter the name of this member's area and your administrator password.  This will create a <a href="http://www.htaccess-guide.com/" class="gen" target="new">.htaccess</a> file in the current directory.~;
$text{'17'} = qq~Member's Area Name:~;
$text{'18'} = qq~Create .htaccess File~;
$text{'19'} = qq~Can't create file:~;
$text{'20'} = qq~No member's area name entered.~;
$text{'21'} = qq~Password Protection Disabled~;
$text{'22'} = qq~Password Protection Enabled~;
$text{'23'} = qq~Couldn't remove .htaccess file, ~;
$text{'24'} = qq~Couldn't remove .htpasswd file, ~;
$text{'25'} = qq~Password protection of the current directory has been disabled successfully.~;
$text{'26'} = qq~Return to 'Browse'~;
$text{'27'} = qq~, make sure the directory containing this file has permissions set to 755 or 777.~;
$text{'28'} = qq~Password protection of the current directory has been enabled successfully.  You can now add users via the 'Manage Users' section.~;
$text{'29'} = qq~'Manage Users'~;
$text{'30'} = qq~Username must be six characters in length or more.~;
$text{'31'} = qq~Password and confirm password must be six characters in length or more and must match.~;
$text{'32'} = qq~Username, ~;
$text{'33'} = qq~ already exists in database.~;
$text{'34'} = qq~Couldn't open file ~;
$text{'35'} = qq~ has been added to the database.~;
$text{'36'} = qq~ has been removed successfully.~;
$text{'37'} = qq~To add a new users, please complete the form at the end of this page and select 'Add New User', to remove an existing user please make the appropriate selection below and select 'Remove User'.~;
$text{'38'} = qq~Remove User~;
$text{'39'} = qq~Username:~;
$text{'40'} = qq~No Users~;
$text{'41'} = qq~This directory is password protected, but currently does not have any users, to add a new users please complete the form below.~;
$text{'42'} = qq~Add New User~;
$text{'43'} = qq~Password:~;
$text{'44'} = qq~Confirm Password:~;
$text{'45'} = qq~Not Password Protected~;
$text{'46'} = qq~This directory is not password protected, please enable password protection via the 'Browse' section before selecting 'Manage Users'.~;
$text{'47'} = qq~To setup your installation of DirectoryPass, please enter your desired administration password.  You will use this password to verify your actions when using DirectoryPass.  Please also specify what operating system the web server you are using DirectoryPass on is running.~;
$text{'48'} = qq~Your password must be six or more characters in length.~;
$text{'49'} = qq~Web Server Operating System:~;
$text{'50'} = qq~Unix/Linux~;
$text{'51'} = qq~Windows~;
$text{'52'} = qq~Cobalt RAQ~;
$text{'53'} = qq~Setup DirectoryPass~;
$text{'54'} = qq~Incorrect Administrator Password~;
$text{'55'} = qq~The administrator password you have entered is incorrect.~;
$text{'56'} = qq~Return to ~;
$text{'57'} = qq~ System Error~;
$text{'58'} = qq~Browse~;
$text{'59'} = qq~Manage Users~;
$text{'60'} = qq~Language: ~;
$text{'61'} = qq~Powered by ~;
$text{'62'} = qq~, a product of ~;
$text{'63'} = qq~Copyright~;
$text{'64'} = qq~All Rights Reserved.~;
$text{'65'} = qq~Total Users:~;
$text{'66'} = qq~No directories~;
####### END TEXT VARIABLES #######
}

$lang_select = qq~<table width=100% cellpadding=0 cellspacing=0 border=0><tr><td align=right><img src="http://www.directorypass.com/images/space.gif" width=~;
if ("$qrylang" eq "en") { $lang_select .= "150"; } else { $lang_select .= "100"; }
$lang_select .= qq~ height=1><font face="Verdana" size="1"><span class="gensmall">$text{'60'}<select name="lang" STYLE="font-size : 8pt" onchange='this.form.submit()'><option value="en"~;
if ("$qrylang" eq "en") { $lang_select .= " selected"; }
$lang_select .= qq~>English<option value="fr"~;
if ("$qrylang" eq "fr") { $lang_select .= " selected"; }
$lang_select .= qq~>Français<option value="de"~;
if ("$qrylang" eq "de") { $lang_select .= " selected"; }
$lang_select .= qq~>Deutsch<option value="it"~;
if ("$qrylang" eq "it") { $lang_select .= " selected"; }
$lang_select .= qq~>Italiano<option value="pt"~;
if ("$qrylang" eq "pt") { $lang_select .= " selected"; }
$lang_select .= qq~>Español<option value="pt"~;
if ("$qrylang" eq "pt") { $lang_select .= " selected"; }
$lang_select .= qq~>Português<option value="nl"~;
if ("$qrylang" eq "nl") { $lang_select .= " selected"; }
$lang_select .= qq~>Dutch<option value="fi"~;
if ("$qrylang" eq "fi") { $lang_select.=" selected"; }
$lang_select .= qq~>Suomi~;
if (-e "jp_lang.pl") {
$lang_select .= qq~<option value="jp"~;
if ("$qrylang" eq "jp") { $lang_select .= " selected"; }
$lang_select .= qq~>Japanese~;
}
if (-e "tr_lang.pl") {
$lang_select .= qq~<option value="tr"~;
if ("$qrylang" eq "tr") { $lang_select .= " selected"; }
$lang_select .= qq~>Turkish~;
}
$lang_select .= qq~</select></span></font></td></tr></table>~;


if (("$qrydir" eq "") && ("$default_dir" ne "")) { $qrydir = $default_dir; } elsif ("$qrydir" eq "") { $qrydir = $ENV{'DOCUMENT_ROOT'}; }
# if query string directory input blank and default directory variable not blank, set query string directory input to equal default directory variable, else if query directory input blank (i.e. and default directory variable blank) then attempt to detect default directory (directory containing the dirpass.cgi file)

$up_dir = "$qrydir";
$up_dir=~s/(.*)\/.*//ig;
$up_dir=$1;
$up_dir = "$self?t=$tab&lang=$qrylang&d="."$up_dir&p=$protect";
# regular expression to find directory path for the parent directory which contains the query string input directory 

if (-e "dp_setup.pl") { require "dp_setup.pl"; } else { if ("$first_install" ne "") { &install; } else { &install; } }
# if dp_setup.pl (dirpass.cgi configuration) file exists, load it, else run install sub routine to set password and create dp_setup.pl

if ("$serveros" ne "2") { $actionpass = crypt($actionpass, "dP");
# if not on Windows server, encrypt the password

$salt = &salt(2);
# run salt subroutine to generate a random two character string for password encryption

if ("$password" ne "") { $password = crypt($password, "$salt"); }
# if password input not blank, encrypt it

if ("$confirmpassword" ne "") { $confirmpassword = crypt($confirmpassword, "$salt"); } }
# if confirm password input not blank, encrypt it

&print_home;
# run print_home subroutine, the basis for the script

sub print_home {
# fairly explanatory, if tab input equal browse or manage, run the appropriate sub routine.  runs the header subroutine before and footer subroutine after to include header and footer html output

&header;
if ("$tab" eq "browse") {
&browse;
} elsif ("$tab" eq "manage") {
&manage;
}
&footer;
exit;
}

#
# Message to anyone editing this file.  Apologies if you find the file messy.
# In an effort to maintain simplicity, it is intended this script be
# distributed as one file, and one file only.  We didn't want to split
# all the source code up and setup language files because then it wouldn't
# be so simple to just upload the file and use it.
#

sub browse {
if ("$action" ne "") { if ("$actionpass" ne "$adminpass") { &error(1); } }
# if action input not blank, actionpass input is required, if not equal to adminpass variable, run error subroutine with input 1

print qq~
<font face="Verdana" size="2"><span class="gen"><div align=justify>$text{'1'}</div>
<img src="http://www.directorypass.com/images/space.gif" width=20 height=12><br></span></font>
<font face="Verdana" size="3"><span class="genlarge"><b>$text{'2'}</b> $qrydir
<br><img src="http://www.directorypass.com/images/space.gif" width=20 height=12><br>
~;
# print beginning of browse html including current directory location

if ("$protect" eq "") {
# if not enabling or disabling password protection

$filecount=0;
$dircount=0;
opendir(DIR, "$qrydir") or &die_clean("<b>$text{'3'}</b> $qrydir<br><b>$text{'4'}</b> $!");
# open directory to retrieve listings

print qq~
<center><table width=96% cellpadding=0 cellspacing=0 border=0>
<tr><td valign=top align=left><table width=100% cellpadding=0 cellspacing=0 border=0>
~;
# start listings table

@dirlist = readdir(DIR);
closedir(DIR);
@sdir = sort @dirlist;
FILE: foreach (@sdir) {
next FILE if($_ eq '.');
next FILE if($_ eq '..');
($filesize, $filedate) = (stat("$qrydir/$_"))[7,9];
$filesize = &simple_size($filesize);
($filename, $fileext) = split(/\./, $_);
# get directory listings, sort, get file size, date, extension

if ("$fileext" eq "") { $anyaccess = ""; if (-e "$qrydir/$_/.htaccess") { $anyaccess = "<img src=\"http://www.directorypass.com/images/lock.gif\" alt=\"$text{'5'}\" hspace=4 vspace=0>"; }
# if no file extension, we have a directory (in theory), if a .htaccess file exists in the directory, we show a lock image in the listing

$result_data .= qq~
<tr><td width=25 height=23><table width=16 height=21 cellpadding=0 cellspacing=0 border=0><tr><td width=7 height=12><img src="http://www.directorypass.com/images/space.gif" width=1 height=12></td><td width=1 height=12 bgcolor="#000000"><img src="http://www.directorypass.com/images/space.gif" width=1 height=12></td><td width=8 height=12><img src="http://www.directorypass.com/images/space.gif" width=1 height=12></td></tr><tr><td width=7 height=1><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td><td width=1 height=1 bgcolor="#000000"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td><td width=8 height=1 bgcolor="#000000"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td></tr><tr><td width=7 height=10><img src="http://www.directorypass.com/images/space.gif" width=1 height=10></td><td width=1 height=10 bgcolor="#000000"><img src="http://www.directorypass.com/images/space.gif" width=1 height=10></td><td width=8 height=10><img src="http://www.directorypass.com/images/space.gif" width=1 height=10></td></tr></table></td><td nowrap valign=bottom><font face="Verdana" size="3"><span class="genlarge"><a href="$self?t=browse&lang=$qrylang&d=$qrydir/$_" class="genlarge">$_</a>&nbsp;$anyaccess</span></font></td></tr>
~;
# result_data variable used for directory records including tree bar

$dircount++; } else { $filecount++; } }

# counts directories and files

print qq~
<tr><td colspan=3><font face="Verdana" size="3"><span class="genlarge"><a href="$up_dir" class="genlarge"><b>$text{'6'}</b></a><br><img src="http://www.directorypass.com/images/space.gif" width=10 height=3></span></font></td></tr>
~;
# print parent directory up link for easier directory browsing, detected earlier

if ("$dircount" ne "0") { print "$result_data"; } else {
# if we have directories, print the listings from result_data variable, otherwise print no directories output

print qq~
<tr><td width=20><table width=16 height=21 cellpadding=0 cellspacing=0 border=0><tr><td width=7><img src="http://www.directorypass.com/images/space.gif" width=1 height=11></td><td width=1 bgcolor="#000000"><img src="http://www.directorypass.com/images/space.gif" width=1 height=11></td><td width=8><img src="http://www.directorypass.com/images/space.gif" width=1 height=11></td></tr><tr><td width=7><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td><td width=1 bgcolor="#000000"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td><td width=8 bgcolor="#000000"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td></tr><tr><td width=7><img src="http://www.directorypass.com/images/space.gif" width=1 height=9></td><td width=1 bgcolor="#000000"><img src="http://www.directorypass.com/images/space.gif" width=1 height=9></td><td width=8><img src="http://www.directorypass.com/images/space.gif" width=1 height=9></td></tr></table></td><td nowrap><font face="Verdana" size="3"><span class="genlarge">$text{'66'}</span></font></td></tr>
~;
}

if ($dircount<3) { $split_height=80; } else { $split_height=10; }
# silly code to make things pretty, makes the black vertical bar longer if less than 3 directories to print

print qq~
<tr><td width=20><table width=16 height=$split_height cellpadding=0 cellspacing=0 border=0>
<tr><td width=7 height=$split_height><img src="http://www.directorypass.com/images/space.gif" width=1 height=$split_height></td>
<td width=1 height=$split_height bgcolor="#000000"><img src="http://www.directorypass.com/images/space.gif" width=1 height=$split_height></td>
<td width=8 height=$split_height><img src="http://www.directorypass.com/images/space.gif" width=1 height=$split_height></td></tr></tr></table>
</td><td><font face="Verdana" size="3"><span class="genlarge"></span></font></td></tr>
</table></td>
<td valign=top align=right>
~;

if ($dircount>3) { print qq~&nbsp;<br><img src="http://www.directorypass.com/images/space.gif" height=30 width=30 alt="Space Holder"<br>~; } else { print qq~<br><img src="http://www.directorypass.com/images/space.gif" height=8 width=30 alt="Space Holder"<br>~; }
# if more than 3 directories, we can make this smaller to neaten everything

print qq~
<table cellpadding=1 cellspacing=0 border=0 bgcolor="#9B9F9B"><tr><td><table width=100% cellpadding=5 cellspacing=0 border=0 bgcolor="#f7f7f7">
<tr><td align=center><font face="Arial" size="3"><span class="genlarge">
~;

if (-e "$qrydir/.htaccess") {
$total_users="0";
open (READHT, "$qrydir/.htpasswd");
@htpw = <READHT>;
close (READHT);
foreach $passline (@htpw) {
$total_users++;
}
# if .htacess exists, get a user count for the directory from the .htpasswd file

if ("$total_users" ne "1") { $print_s = "s"; }
# good grammer, only prints s if 0 and more than 1 user, e.g. 1 users should be 1 user, 0 users and 2 users include s...

print qq~<b><a href="$self?t=$tab&lang=$qrylang&d=$qrydir&p=1" class="genlarge">$text{'7'}</b></a><br><img src="http://www.directorypass.com/images/space.gif" height=8 width=50 alt="Space Holder"><br></span></font><font face="Arial" size="2"><span class="gen">$text{'8'}<br><img src="http://www.directorypass.com/images/space.gif" height=8 width=50 alt="Space Holder"><br><a href="$self?t=manage&lang=$qrylang&d=$qrydir" class="gen"><b>$text{'59'}</b></a>~;
# .htaccess file exists, show option to remove

} else {
print qq~<a href="$self?t=$tab&lang=$qrylang&d=$qrydir&p=1" class="genlarge"><b>$text{'9'}</b></a><br><img src="http://www.directorypass.com/images/space.gif" height=8 width=50 alt="Space Holder"><br></span></font><font face="Arial" size="2"><span class="gen">$text{'10'}~;
# no .htaccess file, show option to create
}

print qq~
</span></font></td></tr></table></td></tr>
</table></td></tr></table>
<table width=96% cellpadding=0 cellspacing=0 border=0><tr><td colspan=2><table width=~;
if ("$qrylang" eq "en") { print "225"; } elsif ("$qrylang" eq "fr") { print "40"; } else { print "125"; } # width change for black bar before directory and file count, changes to fit language word length.
print qq~ cellpadding=0 cellspacing=0 border=0><tr><td width=7><img src="http://www.directorypass.com/images/space.gif" width=1 height=11></td><td width=1 bgcolor="#000000"><img src="http://www.directorypass.com/images/space.gif" width=1 height=11></td><td width=~;
if ("$qrylang" eq "en") { print "222"; } elsif ("$qrylang" eq "fr") { print "37"; } else { print "122"; }
print qq~><img src="http://www.directorypass.com/images/space.gif" width=1 height=11></td></tr><tr><td width=7><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td><td width=1 bgcolor="#000000"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td><td width=~;
if ("$qrylang" eq "en") { print "222"; } elsif ("$qrylang" eq "en") { print "222"; } elsif ("$qrylang" eq "fr") { print "37"; } else { print "122"; }
print qq~ bgcolor="#000000"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td></tr><tr><td width=7><img src="http://www.directorypass.com/images/space.gif" width=1 height=9></td><td width=1><img src="http://www.directorypass.com/images/space.gif" width=1 height=9></td><td width=~;
if ("$qrylang" eq "en") { print "222"; } elsif ("$qrylang" eq "fr") { print "37"; } else { print "122"; }
print qq~><img src="http://www.directorypass.com/images/space.gif" width=1 height=9></td></tr></table></td><td nowrap><font face="Verdana" size="3"><span class="genlarge"><b>$text{'13'} $dircount, $text{'14'} $filecount</b></span></font></td></tr>~;
# end tables, start new table for directory and file counts

} else {
# protect = 1

if ("$action" eq "") {
# not action, show initial output

print qq~
<center><table width=96% cellpadding=0 cellspacing=0 border=0>
<tr><td>
<table  width=100% cellpadding=1 cellspacing=0 border=0 bgcolor="#9B9F9B"><tr><td><table width=100% cellpadding=5 cellspacing=0 border=0 bgcolor="#f7f7f7">
<tr><td><font face="Arial" size="3"><span class="genlarge"><B>~;
if (-e "$qrydir/.htaccess") {
print "$text{'7'}";
} else {
print "$text{'9'}";
}
# .htaccess exists, we are enabling, else we are disabling

print qq~</B></b><br><img src="http://www.directorypass.com/images/space.gif" height=6 width=100 alt="Space Holder"<br></center></span></font><font face="Arial" size="2"><span class="gen"><div align=justify>~;
if (-e "$qrydir/.htaccess") {
print qq~$text{'11'}</div><img src="http://www.directorypass.com/images/space.gif" width=1 height=9>
<center><table width=450 cellpadding=6 cellspacing=0 border=0>
<tr><td width=200><font face="Verdana" size="2"><span class="gen"><b>$text{'12'}</b></span></font></td>
<td align=left><input type="password" name="actionpass" size=30></td></tr>
<tr><td></td><td align=right><img src="http://www.directorypass.com/images/space.gif" width=20 height=8><br><input type="submit" name="action" value="$text{'15'}"></td></tr></table></center>
~;
} else {
# no .htaccess file

print qq~$text{'16'}</div><img src="http://www.directorypass.com/images/space.gif" width=1 height=9>
<center><table width=450 cellpadding=6 cellspacing=0 border=0>
<tr><td width=200><font face="Verdana" size="2"><span class="gen"><b>$text{'17'}</b></span></font></td>
<td align=left><input type="text" name="areaname" size=40></td></tr>
<tr><td width=200><font face="Verdana" size="2"><span class="gen"><b>$text{'12'}</b></span></font></td>
<td align=left><input type="password" name="actionpass" size=30></td></tr>
<tr><td></td><td align=right><img src="http://www.directorypass.com/images/space.gif" width=20 height=8><br><input type="submit" name="action" value="$text{'18'}"></td></tr></table></center>
~;

}
print qq~<br><img src="http://www.directorypass.com/images/space.gif" height=2 width=100 alt="Space Holder"></span></font></td></tr></table></td></tr></table></td><tr>
~;

} else {
# action input, enable or disable .htaccess

if (-e "$qrydir/.htaccess") {
} else { if ("$areaname" eq "") {
# if we are enabling, do we have a member's area name (areaname) input

&die_clean("<b>$text{'19'}</b> $qrydir/.htaccess<br><b>$text{'4'}$text{'20'}</b>");
# no we don't, print error
} }

# else print response and disable or enable
print qq~
<table width=96% cellpadding=0 cellspacing=0 border=0>
<tr><td>
<table  width=100% cellpadding=1 cellspacing=0 border=0 bgcolor="#9B9F9B"><tr><td><table width=100% cellpadding=5 cellspacing=0 border=0 bgcolor="#f7f7f7">
<tr><td><font face="Arial" size="3"><span class="genlarge"><B>~;
if (-e "$qrydir/.htaccess") {
print "$text{'21'}";
} else {
print "$text{'22'}";
}
print qq~</B></b><br><img src="http://www.directorypass.com/images/space.gif" height=6 width=100 alt="Space Holder"<br></center></span></font><font face="Arial" size="2"><span class="gen"><div align=justify>~;
if (-e "$qrydir/.htaccess") {

unlink("$qrydir/.htaccess") or &die_clean("$text{'23'}$qrydir/.htaccess");
unlink("$qrydir/.htpasswd") or &die_clean("$text{'24'}$qrydir/.htpasswd");

# disable password protection. remove .htaccess and .htpasswd files from directory

print qq~$text{'25'}<p>
<ul><font face="Arial" size="3"><span class="genlarge"><a href="$self?t=$tab&lang=$qrylang&d=$qrydir" class="genlarge"><b>$text{'26'}</b></a></span></font></ul>
~;

} else {
# enable password protection, create .htaccess file

open (HTACCESS, ">>$qrydir/.htaccess") or &die_clean("$text{'19'} $qrydir/.htaccess$text{'27'}");
print HTACCESS "AuthType Basic\n";
print HTACCESS "AuthName \"$areaname\"\n";
print HTACCESS "AuthUserFile $qrydir/.htpasswd\n";
print HTACCESS "require valid-user\n";

if ("$serveros" eq "3") {
print HTACCESS "AuthPAM_Enabled off\n";
}
# cobalt raq servers need this

close (HTACCESS);
open (HTPASSWD, ">>$qrydir/.htpasswd") or &die_clean("$text{'19'} $qrydir/.htpasswd$text{'27'}");
close (HTACCESS);
# create .htpasswd file

print qq~$text{'28'}<p>
<ul><font face="Arial" size="3"><span class="genlarge"><a href="$self?t=$tab&lang=$qrylang&d=$qrydir" class="genlarge"><b>$text{'26'}</b></a> or <a href="$self?t=manage&lang=$qrylang&d=$qrydir" class="genlarge"><b>$text{'29'}</b></a></span></font></ul>
~;
}

print qq~<br><img src="http://www.directorypass.com/images/space.gif" height=2 width=100 alt="Space Holder"></span></font></td></tr></table></td></tr></table></td><tr>
~;
} }
print qq~</table></center><br><img src="http://www.directorypass.com/images/space.gif" width=20 height=1><br></span></font>
~;

# browse all done
}

sub manage {
if (-e "$qrydir/.htaccess") { if ("$action" ne "") { if ("$actionpass" ne "$adminpass") { &error(1); }
# if .htaccess file exist and action not blank, check actionpass equals adminpass, if not load error subroutine input 1

if ("$action" eq $text{'42'}) {
if (length($username) < 6) { $username = ""; }
# adding new user, length of input username is less than 6 character, make blank to return error

if (length($password) < 6) { $password = ""; }
# length of input password is less than 6 character, make blank to return error

if (length($confirmpassword) < 6) { $confirmpassword = ""; }
# length of input confirmation password is less than 6 character, make blank to return error

if ("$password" ne "$confirmpassword") { $confirmpassword = ""; }
# if input password and confirmation password are not equal, blank confirm password

if ("$username" eq "") { $error_msg .= qq~$text{'30'}<br>~; }
# if username blank, add to error_msg variable for output

if ("$confirmpassword" eq "") { $error_msg .= qq~$text{'31'}<br>~; }
# if confirmation password blank, add to error_msg variable for output

open (DATABASEA, "$qrydir/.htpasswd");
@wholebasea = <DATABASEA>;
close (DATABASEA);
foreach $oldusera (@wholebasea) {
chomp ($olduser);
@usera = split(/\:/, $oldusera);
if ($username eq $usera[0]) { $error_msg = qq~$text{'32'}'$username'$text{'33'}<br>~; } }   
# open .htpasswd file, look through usernames and check if input username is already in use, add to error_msg variable if in use

if ("$error_msg" ne "") { $msg = qq~<ul><font color="#FF0000">$error_msg</font></ul>&nbsp;~; } else {
# if error_msg variable not blank, we're going to print it, else we can add the user

open (DATABASEADD, ">>$qrydir/.htpasswd") or &die_clean("$text{'34'}$qrydir/.htpasswd$text{'27'}");
print DATABASEADD "$username:$password\n";
close (DATABASEADD);
$msg = qq~<ul>'$username'$text{'35'}</ul>&nbsp;~;
# user added to .htpasswd file, message returned
}

} elsif ("$action" eq $text{'38'}) {
open (READHT, "$qrydir/.htpasswd") or &die_clean("$text{'34'}$qrydir/.htpasswd$text{'27'}");
@htpw = <READHT>;
close (READHT);
open (WRITEHT, ">$qrydir/.htpasswd");
flock (WRITEHT,2);
foreach $passline (@htpw) {
($htdbuser, $htdbpass) = split(/\:/, $passline);
if ("$htdbuser" eq "$username") {
} else {
print WRITEHT $passline;
} }
flock (WRITEHT,8);
close (WRITEHT);
# remove user, open .htpasswd file, store in array, regenerate .htpasswd file from array whilst looking through records, if username equal input username we do not add that record

$msg1 = qq~<ul>User, '$username' $text{'36'}</ul>&nbsp;~;
} }
# output message

$total_users="0";
open (READHT, "$qrydir/.htpasswd");
@htpw = <READHT>;
close (READHT);
foreach $passline (@htpw) {
$total_users++;
}
# get fresh user count and print output
print qq~
<font face="Verdana" size="2"><span class="gen"><div align=justify>$text{'37'}</div>
<img src="http://www.directorypass.com/images/space.gif" width=20 height=12><br></span></font>
<font face="Verdana" size="3"><span class="genlarge"><b>$text{'2'}</b> $qrydir<br>
<b>$text{'65'}</b> $total_users<br><img src="http://www.directorypass.com/images/space.gif" width=20 height=12><br>
~;

if (-e "$qrydir/.htaccess") {
if (-e "$qrydir/.htpasswd") {
# This directory is password protected and has users, we can show manage functions

print qq~
<table  width=100% cellpadding=1 cellspacing=0 border=0 bgcolor="#9B9F9B"><tr><td><table width=100% cellpadding=5 cellspacing=0 border=0 bgcolor="#f7f7f7">
<tr><td><font face="Arial" size="3"><span class="genlarge"><B>$text{'38'}</B></b><br><img src="http://www.directorypass.com/images/space.gif" height=12 width=100 alt="Space Holder"<br></center></span></font><font face="Arial" size="2"><span class="gen">
$msg1
<center><table width=96% cellpadding=1 cellspacing=0 border=0 bgcolor="f9f9f9">
<tr><td width=200><font face="Arial" size="2"><b>$text{'39'}</b></font></td><td><select name="username">
~;
open (DATA, "$qrydir/.htpasswd");
@indata = <DATA>;
close (DATA);
@indata = sort (@indata);
foreach $entries (@indata){
($dbusername, $dbpassword) = split(/\:/, $entries);
print "<option value=\"$dbusername\">$dbusername</option>\n";
}
# print usernames for remove user menu

print qq~
</select></td></tr><tr><td width=200><font face="Arial" size="2"><span class="gen"><b>$text{'12'}</b></span></font></td><td><input type=password name=actionpass size=30></td></tr>
<tr><td></td><td align=right><input type="submit" name="action" value="$text{'38'}"></td></tr>
</table></center><br><img src="http://www.directorypass.com/images/space.gif" width=20 height=1></td></tr></table></td></tr></table></center><br><img src="http://www.directorypass.com/images/space.gif" width=20 height=1>
~;

} else {
# no users to remove, print output

print qq~
<table  width=100% cellpadding=1 cellspacing=0 border=0 bgcolor="#9B9F9B"><tr><td><table width=100% cellpadding=5 cellspacing=0 border=0 bgcolor="#f7f7f7">
<tr><td><font face="Arial" size="3"><span class="genlarge"><B>$text{'40'}</B></b><br><img src="http://www.directorypass.com/images/space.gif" height=6 width=100 alt="Space Holder"<br></center></span></font><font face="Arial" size="2"><span class="gen"><div align=justify>
$text{'41'}</div>
</td></tr></table></td></tr></table></center><br><img src="http://www.directorypass.com/images/space.gif" width=20 height=1>
~;
}

# you can still add a user
print qq~
</form><form action="$self" method="post"><input type="hidden" name="p" value="$protect">
<input type="hidden" name="lang" value="$qrylang"><input type="hidden" name="d" value="$qrydir"><input type="hidden" name="t" value="$tab">
<table  width=100% cellpadding=1 cellspacing=0 border=0 bgcolor="#9B9F9B"><tr><td><table width=100% cellpadding=5 cellspacing=0 border=0 bgcolor="#f7f7f7">
<tr><td><font face="Arial" size="3"><span class="genlarge"><B>$text{'42'}</B></b><br><img src="http://www.directorypass.com/images/space.gif" height=12 width=100 alt="Space Holder"<br></center></span></font><font face="Arial" size="2"><span class="gen">
$msg
<center><table width=96% cellpadding=1 cellspacing=0 border=0 bgcolor="f9f9f9">
<tr><td width=200><font face="Arial" size="2"><span class="gen"><b>$text{'39'}</b></span></font></td><td><input type="text" name="username" value="$username" size=35></td></tr>
<tr><td width=200><font face="Arial" size="2"><span class="gen"><b>$text{'43'}</b></span></font></td><td ><input type="password" name="password" size=35></td></tr>
<tr><td width=200><font face="Arial" size="2"><span class="gen"><b>$text{'44'}</b></span></font></td><td><input type="password" name="confirmpassword" size=35></td></tr>
<tr><td width=200><font face="Arial" size="2"><span class="gen"><b>$text{'12'}</b></span></font></td><td><input type="password" name="actionpass" size=30></td></tr>
<tr><td width=200></td><td align=right><input type="submit" name="action" value="$text{'42'}"></td></tr></table></center>
<br><img src="http://www.directorypass.com/images/space.gif" width=20 height=1></td></tr></table></td></tr></table></center>
~;
}

print qq~</span></font>
~;

} else {
# no .htaccess file, go back to browse...

print qq~
<table  width=100% cellpadding=1 cellspacing=0 border=0 bgcolor="#9B9F9B"><tr><td><table width=100% cellpadding=5 cellspacing=0 border=0 bgcolor="#f7f7f7">
<tr><td><font face="Arial" size="3"><span class="genlarge"><B>$text{'45'}</B></b><br><img src="http://www.directorypass.com/images/space.gif" height=6 width=100 alt="Space Holder"<br></center></span></font><font face="Arial" size="2"><span class="gen"><div align=justify>
$text{'46'}</div>
<ul><font face="Arial" size="3"><span class="genlarge"><a href="$self?t=browse&lang=$qrylang&d=$qrydir" class="genlarge"><b>$text{'26'}</b></a></span></font></ul>
</td></tr></table></td></tr></table></center>
~;
} }



sub install {
if ("$first_install" ne "") { if (length($actionpass) < 6) { $first_install = ""; $password_short = "1"; &install; exit; } 
if ("$serveros" ne "2") { $actionpass = crypt($actionpass, "dP"); }
# if first_install not blank, we are setting password, check length of input password, if too short go back to choose password screen with error message, else if server os not Windows, encrypt password for dp_setup.pl

open (DPINSTALL, ">>dp_setup.pl") or &die_clean("$text{'19'} dp_setup.pl$text{'27'}");
print DPINSTALL "# DIRECTORYPASS CONFIGURATION FILE\n\n";
print DPINSTALL "\$adminpass = \"$actionpass\";\n";
print DPINSTALL "\$serveros = \"$serveros\";\n\n";
print DPINSTALL "1;";
flock (DPINSTALL, 8);

# create dp_setup.pl file, admin password, server operating system and default directory

&print_home;
# welcome to directorypass for the first time!

} else {
$hide_menu = "1";
# we are setting up, hide the menu

&header;
print qq~
<font face="Verdan" size="2"><span class="gen"><div align=justify>$text{'47'}</div><img src="http://www.directorypass.com/images/space.gif" width=1 height=9>~;
if ("$password_short" eq "1") { print qq~<ul><font color="#FF0000">$text{'48'}</font></ul>~; }
# you've been here before and you got it wrong

print qq~
<img src="http://www.directorypass.com/images/space.gif" width=1 height=9><center><table width=500 cellpadding=6 cellspacing=0 border=0>
<tr><td width=240><font face="Verdana" size="2"><span class="gen"><b>~;
if ("$password_short" eq "1") { print qq~<font color="#FF0000">~; }
print "$text{'12'}";
if ("$password_short" eq "1") { print qq~</font>~; }
# password was too short, make it red this time

print qq~</b></span></font></td><td align=left><input type="password" name="actionpass" size=30 style="font-size:14px;"></td></tr>
<tr><td width=240 valign=top><font face="Verdana" size="2"><span class="gen"><b>$text{'49'}</b></span></font></td><td align=left valign=top>
<font face="Verdana" size="2"><span class="gen">
<input type="radio" name="serveros" value="1" checked>$text{'50'}<br>
<input type="radio" name="serveros" value="2">$text{'51'}<br>
<input type="radio" name="serveros" value="3">$text{'52'}
</font></td></tr>
<tr><td></td><td align=right><img src="http://www.directorypass.com/images/space.gif" width=20 height=8><br><input type="submit" name="first_install" value="$text{'53'}" style="font-size:14px;"></td></tr></table></center></span></font>
~;
&footer;
}
exit;
}

sub simple_size { 
my $size = shift;
my $formatted_size = int($size / 1000) . " Kb";
$formatted_size == 0 ?
return "$size bytes" :
return $formatted_size;
# take an input in bytes and make it kilobytes, unless it's small then stick with bytes
}

sub salt {
my ($maxlen) = $_[0] || 2;
my (@vowel) = (qw (a a 2 e e e 3 i i i o o o u u 6 ai au ay ea ee eu ia ie io oa oi oo oy));
my (@consonant) = (qw (b c d f 2 h j k l m 6 p qu 8 s t v w x 9 th st sh ph ng nd));
my ($salt) = "";
srand;                 
my ($vowelnext) = int(rand(2));  # Initialise to 0 or 1 (ie true or false)
do { if ($vowelnext) { $salt .= $vowel[rand(@vowel)]; } else { $salt .= $consonant[rand(@consonant)]; }
$vowelnext = !$vowelnext; } 
until length($salt) >= $maxlen;
return $salt;
# loads of characters in an array, grab some, make a string, take two characters back for password encryption
}

sub error {
$string = shift;
if ("$string" ne "1") {
print qq~
<tr><td>
<table  width=100% cellpadding=1 cellspacing=0 border=0 bgcolor="#9B9F9B"><tr><td><table width=100% cellpadding=5 cellspacing=0 border=0 bgcolor="#f7f7f7">
<tr><td>~;
}
# if it's not an administrator password error, we've had a problem and a table is already open

if ("$tab" eq "browse") { $print_tab = "$text{'58'}"; } elsif ("$tab" eq "manage") { $print_tab = "$text{'59'}"; }
# which tab are we in, get name with capital

print qq~<font face="Arial" size="3"><span class="genlarge"><B>$text{'54'}</B></b><br><img src="http://www.directorypass.com/images/space.gif" height=6 width=100 alt="Space Holder"<br></center></span></font><font face="Arial" size="2"><span class="gen">
<font color="#FF0000">$text{'55'}</font></span></font>
<p><a href="$self?t=$tab&lang=$qrylang&d=$qrydir&p=$protect" class="genlarge"><b>$text{'56'}'$print_tab'</b></a>
<br><img src="http://www.directorypass.com/images/space.gif" height=2 width=100 alt="Space Holder"></span></font>
~;
# admin password incorrect error message

if ("$string" ne "1") {
print qq~</td></tr></table></td></tr></table></td><tr></table>
~;
}
&footer;
exit;
}

sub header {
$header_called="1";
# so we know this subroutine has been loaded

print qq~
<html><head><title>DirectoryPass</title>
<style type="text/css">
.dictionary		{ font-family : Verdana, Arial, Helvetica, sans-serif; font-size : 9px; color : #000000; }
a.dictionary		{ color: #000080; text-decoration: none; }
a.dictionary:hover	{ color: #000080; text-decoration: underline; }
.gensmall		{ font-family : Verdana, Arial, Helvetica, sans-serif; font-size : 11px; color : #000000; }
a.gensmall		{ color: #000080; text-decoration: none; }
a.gensmall:hover	{ color: #000080; text-decoration: underline; }
.gen			{ font-family : Verdana, Arial, Helvetica, sans-serif; font-size : 13px; color : #000000; }
a.gen			{ color: #000080; text-decoration: none; }
a.gen:hover		{ color: #000080; text-decoration: underline; }
.genlarge		{ font-family : Verdana, Arial, Helvetica, sans-serif; font-size : 14px; color : #333333; }
a.genlarge		{ color: #000080; text-decoration: none; }
a.genlarge:hover	{ color: #000080; text-decoration: underline; }
.gen_s			{ font-family : Verdana, Arial, Helvetica, sans-serif; font-size : 13px; color : #000000; }
a.gen_s			{ color: #000000; text-decoration: none; }
a.gen_s:hover		{ color: #000080; text-decoration: underline; }
.genlarge_s		{ font-family : Verdana, Arial, Helvetica, sans-serif; font-size : 14px; color : #333333; }
a.genlarge_s		{ color: #000000; text-decoration: none; }
a.genlarge_s:hover	{ color: #000080; text-decoration: underline; }
BODY 		{ SCROLLBAR-BASE-COLOR: #93B7D7; SCROLLBAR-ARROW-COLOR: #506060; }
</style>
</head>
<body topmargin="0" bgcolor="#a9cc66" text="#000000" link="#000070" vlink="#800000" alink="#800000">
<form action="$self" method="post" style="margin:0px"><input type="hidden" name="p" value="$protect">
<input type="hidden" name="d" value="$qrydir"><input type="hidden" name="t" value="$tab">
<center><table width=620 cellpadding=0 cellspacing=0 border=0>
<tr><td colspan=2 align=center><font face="Verdana, Arial" size="2">&nbsp;</font></td></tr>
<tr><td colspan=2 align=center>
<table with=620 cellpadding=0 cellspacing=0 border=0>
<tr><td width=620 align=left valign=top>
<table width=620 cellpadding=1 cellspacing=0 border=0>
<tr><td width=620 bgcolor="#111111"><table width=151 cellpadding=0 cellspacing=0 border=0 bgcolor="#FFFFFF">
<tr><td width=619 valign=top><img src="http://www.directorypass.com/images/space.gif" height=1 width=100 alt="Space Holder"><br>
<a href="http://www.directorypass.com/"><img src="http://www.directorypass.com/images/menu/menu_dp.gif" width=150 height=14 border=0 alt="DirectoryPass"></a><img src="http://www.directorypass.com/images/titles/blank.gif" width=469 height=14 border=0><br>
<table width=619 cellpadding=1 cellspacing=2 border=0>
<tr><td><font face="Verdana, Arial" size="2"><span class="gensmall">~;
if ("$hide_menu" ne "1") { print qq~<img src="http://www.directorypass.com/images/space.gif" height=12 width=100 alt="Space Holder"><br>~; }
print qq~
<center><table width=96% cellpadding=0 cellspacing=0 border=0>
~;

if ("$hide_menu" ne "1") {
# when installing we don't show this
print qq~
<tr><td height=1 colspan=3 bgcolor="#9B9F9B"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td height=1 width=2><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td height=1 colspan=3 bgcolor="#9B9F9B"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td height=1><img src="http://www.directorypass.com/images/space.gif" width=100 height=1></td>
<td height=1 width=1><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td></tr>
<tr><td width=1 bgcolor="#9B9F9B"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td align=center bgcolor="#F7F7F7"><table cellpadding=3 cellspacing=0 border=0><tr><td nowrap><font face="Verdana" size="3">&nbsp;<a href="$self?t=browse&lang=$qrylang&d=$qrydir" class="genlarge~;

if ("$tab" eq "browse") { print "_s\"><b>"; } else { print "\">"; }
# if this tab is selected, change css class and bold text

print "$text{'58'}";
if ("$tab" eq "browse") { print "</b>"; }
print qq~</a>&nbsp;</font></td></tr></table></td>
<td width=1 bgcolor="#9B9F9B"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td width=2><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td width=1 bgcolor="#9B9F9B"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td align=center bgcolor="#F7F7F7"><table cellpadding=3 cellspacing=0 border=0><tr><td nowrap><font face="Verdana" size="3">&nbsp;<a href="$self?t=manage&lang=$qrylang&d=$qrydir" class="genlarge~;

if ("$tab" eq "manage") { print "_s\"><b>"; } else { print "\">"; }
# if this tab is selected, change css class and bold text

print "$text{'59'}";
if ("$tab" eq "manage") { print "</b>"; }
print qq~</a>&nbsp;</font></td></tr></table></td>
<td width=1 bgcolor="#9B9F9B"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td>$lang_select</td>
<td width=1><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td></tr>
<tr><td height=1 width=1 bgcolor="#9B9F9B"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td height=1 bgcolor="#F7F7F7"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td height=1 width=1 bgcolor="#9B9F9B"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td height=1 width=2><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td height=1 width=1 bgcolor="#9B9F9B"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td height=1 bgcolor="#F7F7F7"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td height=1 width=1 bgcolor="#9B9F9B"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td height=1><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td height=1 width=1><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td></tr>
~;
} else {
$tab = "0";
# hiding menu
print qq~
<tr><td colspan=8 align=right>$lang_select</td></tr>
~;
}

print qq~
<tr><td height=1 width=1 bgcolor="#9B9F9B"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td height=1 bgcolor="~;
if ("$tab" eq "browse") { print "#F7F7F7"; } else { print "#9B9F9B"; }
# show line below tab, not if selected

print qq~"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td height=1 width=1 bgcolor="#9B9F9B"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td height=1 width=1 bgcolor="#9B9F9B"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td height=1 width=1 bgcolor="#9B9F9B"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td height=1 bgcolor="~;
if ("$tab" eq "manage") { print "#F7F7F7"; } else { print "#9B9F9B"; }
# show line below tab, not if selected

print qq~"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td height=1 width=1 bgcolor="#9B9F9B"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td height=1 bgcolor="#9B9F9B"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td>
<td height=1 width=1 bgcolor="#9B9F9B"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td></tr>
<tr><td width=1 bgcolor="#9B9F9B"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td><td colspan=7 bgcolor="#F7F7F7" valign=top align=center>
<center><table width=100% cellpadding=20 cellspacing=0 border=0><tr><td>
~;
}

sub footer {
$footer_called="1";
# so we know this subroutine has been loaded

print qq~
</td></tr></table></center>
</td><td width=1 bgcolor="#9B9F9B"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td></tr>
<tr><td height=1 colspan=9 bgcolor="#9B9F9B"><img src="http://www.directorypass.com/images/space.gif" width=1 height=1></td></tr>
</table><br><img src="http://www.directorypass.com/images/space.gif" height=2 width=100 alt="Space Holder"></center>
</span></font></td></tr></table></td>
<td width=1 bgcolor="#9B9F9B"><img src="http://www.directorypass.com/images/space.gif" height=10 width=1 alt="Space Holder"></td></tr>
<tr><td height=1 colspan=2 bgcolor="#9B9F9B"><img src="http://www.directorypass.com/images/space.gif" height=1 width=10 alt="Space Holder"></td></tr></table>
</td><td width=3><img src="http://www.directorypass.com/images/space.gif" height=10 width=4 alt="Space Holder"></td>
</tr></table><img src="http://www.directorypass.com/images/space.gif" height=6 width=10 alt="Space Holder"><br>
</td><td width=10><img src="http://www.directorypass.com/images/space.gif" height=10 width=1 alt="Space Holder"><br>
</td></tr></table></td></tr>
<tr><td colspan=2><font face="Verdana, Arial" size="1"><span class=dictionary><center><a href="http://www.ionix.ltd.uk/legal.php" target="new" class="dictionary">$text{'63'}</a> &copy; 2009 <a href="http://www.ionix.ltd.uk/" class="dictionary">ionix Limited</a>.  $text{'64'}&nbsp; $text{'61'}<a href="http://www.DirectoryPass.com/" target="new" class="dictionary">DirectoryPass .htaccess File Management</a>.</center></span></font></td></tr>
</table></center></form></body></html>
~;
}

sub die_clean {
($errmsg) = @_;
if ("$header_called" ne "1") { &header; }
print qq~
<font face="Verdana" size="3"><span class="genlarge"><b>DirectoryPass$text{'57'}</b></span></font><p>
<font face="Verdana" size="2"><span class="gen">
<ul>$errmsg</ul><br>
</span></font>
<a href="$self?t=browse&lang=$qrylang" class="genlarge"><b>$text{'26'}</b></a>
</span></font>~;
&footer;
exit;
# we've got a problem, print an error message
}
