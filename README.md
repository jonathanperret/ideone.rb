# ideone.rb

A quick hack of a command-line client for [ideone](http://ideone.com).

## Requirements

 * Ruby 1.9.2
 * [savon](http://rubygems.org/gems/savon)

## Using it

 * Register on [ideone](http://ideone.com). Make sure you set up an API password.
 * Write some code in a file.
 * Add a "language:..." comment within your source file to specify which of the ideone languages you are using. Any substring will do; if you miss, the script will list the languages the site offers. For example:
<pre>
// language:C++0x
</pre>
or
<pre>
# language:ruby-1.9
</pre>
 * Set up a couple environment variables (adapt for your shell of choice):
<pre>
export IDEONE_USER=your_user_name
export IDEONE_PASSWORD=your_api_password
</pre>
 * Run it like this:
<pre>
    ruby ideone.rb your_file.cpp
</pre>

Remember the free accounts at ideone are limited to 1000 submissions a month.
