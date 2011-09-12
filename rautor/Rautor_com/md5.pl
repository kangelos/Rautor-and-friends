 use Digest::MD5;

my $file = shift || "/etc/passwd";
open(FILE, $file) or die "Can't open '$file': $!";
binmode(FILE);

$md5 = Digest::MD5->new;
while (<FILE>) {
$md5->add($_);
}
close(FILE);
print $md5->hexdigest, " $file\n";
