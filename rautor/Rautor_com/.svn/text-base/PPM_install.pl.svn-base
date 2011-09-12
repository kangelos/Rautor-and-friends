open my $fh, '<', 'PPM_modules.txt' or die "Oops: $!\n";
while ( <$fh> ) {
  chomp;
  print "Installing $_...\n";
  system ( "ppm", "install", $_ );
}
