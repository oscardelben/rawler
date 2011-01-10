= rawler

* http://github.com/#{github_username}/#{project_name}

== DESCRIPTION:

Rawler is a Ruby library that crawls your website and see the status code of each of your links. Useful for finding dead links.

== SYNOPSIS:

  rawler http://example.com

== INSTALL:

gem install rawler

== TODO

* Handle relative urls!
* Handle https (now returns 400). See http://stackoverflow.com/questions/1719809/ruby-on-rails-https-post-bad-request
* Export to html
* Handle multiple urls at once
* Add user agent

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