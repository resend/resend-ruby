# Resend Ruby and Rails SDK

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