### This is a Ruby on Rails Example

Clone and create a new heroku app

```
$ git clone https://github.com/jasommerset/call-tracking-app.git
$ cd call-tracking-app
$ bundle install
$ git init
$ git add -A
$ git commit -m "init"
$ heroku create
$ git push heroku master
$ heroku config:set BANDWIDTH_USER_ID='your user_id'
$ heroku config:set BANDWIDTH_API_TOKEN='your api token'
$ heroku config:set BANDWIDTH_API_SECRET='your api secret'
$ heroku config:set BANDWIDTH_VOICE_URL='http://xxxxxx-herokuapp.com/callback'
$ heroku config:set BANDWIDTH_APP_ID='a-1234567890abcd1234'
$ heroku run rake db:migrate
```

Open Heroku and Set-Up Your Phone Number
```
$ heroku open
```
