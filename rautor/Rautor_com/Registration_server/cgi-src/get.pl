 use LWP::UserAgent;
      $ua = new LWP::UserAgent;
      $ua->agent("$0/0.1 " . $ua->agent);
       $ua->agent("Mozilla/8.0") # pretend we are very capable browser

      $req = new HTTP::Request 'GET' => 'http://10.10.11.135:13697/4492BEB7FBB7476ABBC3B2DDCD9730B9/monitor';
      $req->header('Accept' => 'text/html');

      # send request
      $res = $ua->request($req);

      # check the outcome
      if ($res->is_success) {
         print $res->content;
      } else {
         print "Error: " . $res->status_line . "\n";
      }


