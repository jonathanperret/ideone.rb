# ideone.rb

A quick hack of a command-line client for [ideone](http://ideone.com).

## Requirements

 * Ruby 1.9.2
 * [savon](http://rubygems.org/gems/savon)

## Using it

 * Register on [ideone](http://ideone.com). Make sure you set up an API password.
 * Write some code in a file.
 * Add a "language:..." comment within your source file to specify which of the ideone languages you are using. Any substring will do; if you miss the script will list the languages the site offers. For example:
    // language:C++0x
 * Run it like this:
    IDEONE_USER=your_user_name IDEONE_PASSWORD=your_api_password ruby ideone.rb your_file.cpp

Remember the free accounts at ideone are limited to 1000 submissions a month.

