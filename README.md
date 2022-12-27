# Resend Ruby and Rails SDK

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
![Build](https://github.com/drish/resend-ruby/actions/workflows/build.yml/badge.svg)
---

## Installation

To install Resend Ruby and Rails SDK, simply execute the following command in a terminal:

Via RubyGems:
```
gem install resend
```

Via Gemfile:
```
gem 'resend', '~>0.0.1'
```

## Setup

First, you need to get an API key, which is available in the [Resend Dashboard](https://resend.com).

```ruby
require "resend"
client = Resend::Client.new "re_YOUR_API_KEY"
```

## Example

```rb
require "resend"

client = Resend::Client.new "re_YOUR_API_KEY"

params = {
  "from": "team@recomendo.io",
  "to": "carlosderich@gmail.com",
  "html": "<h1>Hello World</h1>",
  "subject": "Hey"
}
r = client.send_email(params)
puts r
```