## Bandwidth Call Tracking Ruby on Rails Example

Bandwidth Voice & Messaging API Sample App for Call Tracking, see http://ap.bandwidth.com/

![App screenshot](https://github.com/BandwidthExamples/ruby-call-tracking/blob/master/Ruby-CT-App-Screenshot-1.png)
![App screenshot](https://github.com/BandwidthExamples/ruby-call-tracking/blob/master/Ruby-CT-App-Screenshot-2.png)

## Prerequisites

- You have a Bandwidth account
- You have a [Heroku](https://devcenter.heroku.com/articles/getting-started-with-php#introduction) account

## Getting Started & Installing on Heroku

Clone and create a new heroku app

```
$ git clone https://github.com/BandwidthExamples/ruby-call-tracking.git
$ cd ruby-call-tracking
$ bundle install
$ git init
$ git add -A
$ git commit -m "init"
$ heroku create
$ git push heroku master
$ heroku run rake db:migrate
```

Login to your Bandwidth App Platform account and setup an [application](http://ap.bandwidth.com/docs/how-to-guides/configuring-apps-incoming-messages-calls/)

Locate your user id, token and secret for your [Bandwidth App Platform account](http://ap.bandwidth.com/docs/security/)

Set the heroku environment vairables. 

```
$ heroku config:set BANDWIDTH_USER_ID='your user_id'
$ heroku config:set BANDWIDTH_API_TOKEN='your api token'
$ heroku config:set BANDWIDTH_API_SECRET='your api secret'
$ heroku config:set BANDWIDTH_VOICE_URL='http://xxxxxx-herokuapp.com/callback'
$ heroku config:set BANDWIDTH_APP_ID='a-1234567890abcd1234'
```

Open Heroku and create your first call tracking phone number

```
$ heroku open
```
