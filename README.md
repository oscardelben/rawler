### rawler

Rawler is a Ruby library that crawls your website and checks the status code for each of your links. Useful for finding dead links.

Rawler will only parse pages with content type 'text/html', but it will check for the response code of every link.

### SYNOPSIS:

  rawler http://example.com [options]

      where [options] are:
        --username, -u <s>:   HTTP Basic Username
        --password, -p <s>:   HTTP Basic Password
            --wait, -w <f>:   Seconds to wait between requests, may be fractional e.g. '1.5' (default: 3.0)
                 --log, -l:   Log results to file rawler_log.txt
         --logfile, -o <s>:   Specify logfile, implies --log (default: rawler_log.txt)
                 --css, -c:   Check CSS links
            --skip, -s <s>:   Skip URLs that match a regexp
           --iskip, -i <s>:   Skip URLs that match a case insensitive regexp
             --include <s>:   Only include URLs that match a regexp
            --iinclude <s>:   Only include URLs that match a case insensitive regexp
               --local <s>:   Restrict to the given URL and below
             --version, -v:   Print version and exit
                --help, -h:   Show this message

### INSTALL:

gem install rawler

### CONTRIBUTORS:

Many. See [https://github.com/oscardelben/rawler/contributors](https://github.com/oscardelben/rawler/contributors)

### LICENSE:

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
