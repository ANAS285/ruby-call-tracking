## Bandwidth Call Tracking Ruby Example

[![Build Status](https://travis-ci.org/BandwidthExamples/ruby-call-tracking.svg)](https://travis-ci.org/BandwidthExamples/ruby-call-tracking)

Bandwidth Voice API Sample App for Call Tracking, see http://ap.bandwidth.com/

## Prerequisites
- Configured Machine with Ngrok/Port Forwarding
  - [Ngrok](https://ngrok.com/)
- [Bandwidth Account](https://catapult.inetwork.com/pages/signup.jsf/?utm_medium=social&utm_source=github&utm_campaign=dtolb&utm_content=_)
- [Ruby 2.4+](https://www.ruby-lang.org)
- [MongoDb](http://www.mongodb.org/)
- [Git](https://git-scm.com/)


## Build and Deploy

### One Click Deploy

#### Settings Required To Run
* ```Bandwidth User Id```
* ```Bandwidth Api Token```
* ```Bandwidth Api Secret```

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## Run

### Directly

```bash
# Check first if mongodb is started and available
# Use DATABASE_URL to specify location of db collection if need

export BANDWIDTH_USER_ID=<YOUR-USER-ID>
export BANDWIDTH_API_TOKEN=<YOUR-API-TOKEN>
export BANDWIDTH_API_SECRET=<YOUR-API-SECRET>
npm install # to install dependencies
npm start
```

### Via Docker

```bash
# fill .env file with auth data first

# run the app (it will listen port 8080)
PORT=8080 docker-compose up -d
```
