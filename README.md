<div align="center">

# Bandwidth Call Tracking Ruby Example

<a href="http://dev.bandwidth.com"><img src="https://s3.amazonaws.com/bwdemos/BW_all.png"/></a>
</div>

[![Build Status](https://travis-ci.org/BandwidthExamples/ruby-call-tracking.svg)](https://travis-ci.org/BandwidthExamples/ruby-call-tracking)

A Call Tracking app for [Bandwidth Voice and Messaging APIs](http://dev.bandwidth.com/).

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## Table of Contents

* [What this Example Does](#what-this-example-does)
* [Prerequisites](#prerequisites)
    * [Env Variables](#env-variables)
* [Deploy Locally](#deploying-locally-with-ngrok)
    * [Directly](#directly)
    * [Docker](#via-docker)

## What this Example Does

![Landing Page](https://s3.amazonaws.com/bw-demo/bw-call-tracking.png)

The call tracking application lets you create trackable phone numbers for all your marketing needs. Create a new number by specifying the area code you'd like and the phone number you want the call to forward to.

Then for each incoming call you'll get a CNAM ([caller id](https://www.voip-info.org/wiki/view/CNAM)) lookup.  As well as the duration of the state of any on-going calls.

This app will:
* [Order Tns](http://dev.bandwidth.com/ap-docs/methods/availableNumbers/postAvailableNumbersLocal.html)
* [Create an application](http://dev.bandwidth.com/ap-docs/methods/applications/postApplications.html)
* [Handle incoming phone calls](http://dev.bandwidth.com/howto/incomingCallandMessaging.html)
* [Update Call](http://dev.bandwidth.com/ap-docs/methods/calls/postCallsCallId.html)
* [CNAM Lookup](http://dev.bandwidth.com/ap-docs/methods/numberInfo/getNumberInfo.html)

## Prerequisites

### Accounts and Machine Setup
* [Bandwidth Voice and Messaging APIs Account](http://dev.bandwidth.com)
    * [If you already have a Bandwidth Account](http://dev.bandwidth.com/security.html)
* [Ruby 2.4+](https://www.ruby-lang.org)
* [MongoDb](http://www.mongodb.org/)
* [Git](https://git-scm.com/)
* [Ngrok](https://ngrok.com/) **For local Deployment Only**
* [Heroku](https://signup.heroku.com/) **For Heroku Deployment Only**

### Env Variables
* `BANDWIDTH_USER_ID` - Something like `u-asdf`
* `BANDWIDTH_API_TOKEN` - Something like `t-asf234`
* `BANDWIDTH_API_SECRET` - Something like `asdf123asdf`
* `DATABASE_URL` - Connection path to MongoDB

## Deploying Locally with ngrok

[Ngrok](https://ngrok.com) is an awesome tool that lets you open up local ports to the internet.

![Ngrok how](https://s3.amazonaws.com/bw-demo/ngrok_how.png)

Once you have ngrok installed, open a new terminal tab and navigate to it's location on the file system and run:

```bash
./ngrok http 8080
```

You'll see the terminal show you information

![ngrok terminal](https://s3.amazonaws.com/bw-demo/ngrok_terminal.png)

### Installing and running

Once [ngrok](#deploying-locally-with-ngrok) is up and running. Open a new tab and clone the repo:

```bash
git clone https://github.com/BandwidthExamples/ruby-call-tracking.git
cd ruby-call-tracking
```

### Directly

```bash
# Check first if mongodb instance is available
# Use DATABASE_URL to specify location of db collection if need

export BANDWIDTH_USER_ID=<YOUR-USER-ID>
export BANDWIDTH_API_TOKEN=<YOUR-API-TOKEN>
export BANDWIDTH_API_SECRET=<YOUR-API-SECRET>
export DATABASE_URL=<YOUR-MONGO-PATH>
bundle install # to install dependencies

bundle exec puma -p 8080
```

### Via Docker

```bash
# fill .env file with auth data first

# run the app (it will listen port 8080)
PORT=8080 docker-compose up -d
```


### Open the app using the `ngrok` url

When the app runs for the first time, it setups the Bandwidth voice and messaging callbacks for the application for you.  It sets the callback urls based on the url visited!

Copy the `http://8a543f5f.ngrok.io` link and paste it into your browser.

> On first run, the application will create the Bandwidth callbacks and voice/messaging application for you.  Be sure you visit the `ngrok` url and not `localhost`. Bandwidth needs to be able to send callbacks.

![Landing Page](https://s3.amazonaws.com/bw-demo/bw-call-tracking.png)
