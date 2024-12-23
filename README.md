# Resend Ruby and Rails SDK

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
![Build](https://github.com/drish/resend-ruby/actions/workflows/build.yml/badge.svg)
[![Gem Version](https://badge.fury.io/rb/resend.svg)](https://badge.fury.io/rb/resend)

---

## Installation

To install Resend Ruby and Rails SDK, simply execute the following command in a terminal:

Via RubyGems:

```
gem install resend
```

Via Gemfile:

```
gem 'resend'
```

## Setup

First, you need to get an API key, which is available in the [Resend Dashboard](https://resend.com).

```ruby
require "resend"
Resend.api_key = ENV["RESEND_API_KEY"]
```

or

```ruby
require "resend"
Resend.configure do |config|
  config.api_key = ENV["RESEND_API_KEY"]
end
```

The `#api_key` method also accepts a block without arguments, which can be useful for lazy or dynamic loading of API keys.

```ruby
require "resend"
Resend.api_key = -> { ENV["RESEND_API_KEY"] }
```

```ruby
Resend.configure do |config|
  config.api_key = -> { Current.user.resend_api_key } # Assumes the user has a `resend_api_key` attribute.
end
```

## Example

```rb
require "resend"

Resend.api_key = ENV["RESEND_API_KEY"]

params = {
  "from": "from@email.io",
  "to": ["to@email.com", "to1@gmail.com"],
  "html": "<h1>Hello World</h1>",
  "subject": "Hey"
}
r = Resend::Emails.send(params)
puts r
```

You can view all the examples in the [examples folder](https://github.com/drish/resend-ruby/tree/main/examples)

# Rails and ActiveMailer support

This gem can be used as an ActionMailer delivery method, add this to your `config/environments/environment.rb` file.

```ruby
config.action_mailer.delivery_method = :resend
```

Create or update your mailer initializer file and replace the placeholder with your Resend API Key.

```rb
# /config/initializers/resend.rb
Resend.api_key = "re_123456"
```

After that you can deliver_now!, example below:

```ruby
#/app/mailers/user_mailer
class UserMailer < ApplicationMailer
  default from: 'you@yourdomain.io'
  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: ["example2@mail.com", "example1@mail.com"], subject: 'Hello from Resend')
  end
end

# anywhere in the app
u = User.new name: "derich"
mailer = UserMailer.with(user: u).welcome_email
mailer.deliver_now!
# => {:id=>"b8f94710-0d84-429c-925a-22d3d8f86916", from: 'you@yourdomain.io', to: ["example2@mail.com", "example1@mail.com"]}
```
