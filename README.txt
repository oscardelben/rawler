= rawler

* http://github.com/oscardelben/rawler

== DESCRIPTION:

Rawler is a Ruby library that crawls your website and checks the status code for each of your links. Useful for finding dead links.

Rawler will only parse pages with content type 'text/html', but it will check for the response code of every link.

Rawler writes to $stdout and in the future it will be possible for which status code to notify.

Please note: I had to temporarily remove url encoding in order to resolve some issues, so if you find any issue, please let me know. I'm also going to use Mechanizer for parsing pages with the next release.

== SYNOPSIS:

  rawler http://example.com [options]

	where [options] are:
	  --username, -u <s>:   HTT Basic Username
	  --password, -p <s>:   HTT Basic Password
	       --version, -v:   Print version and exit
	          --help, -h:   Show this message

== INSTALL:

gem install rawler

== DEVELOPMENT:

You need fakeweb and rspec to run the tests. You can then run:

  rake test

To package and run the gem locally:

  rake package
  cd pkg
  gem install rawler-#{version}.gem

If you add files, run:
  
  rake check_manifest

== TODO

* Add logger levels
* Follow redirects, but still inform about them
* Respect robots.txt
* Export to html

== CONTRIBUTORS:

* bcoob
* Hugh Sasse
* Vesa Vänskä

See also https://github.com/oscardelben/rawler/contributors

== LICENSE:

(The MIT License)

Copyright (c) 2011 Oscar Del Ben

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.