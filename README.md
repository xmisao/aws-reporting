# AWS-Reporting

![AWS Reporting](http://aws-reporting.xmisao.com/logo.png)

## Introduction

AWS-Reporting is AWS performance reporting tool.

AWS-Reporting fetches data from Amazon CloudWatch, and generates awesome HTML report like this:

![Screenshot](http://aws-reporting.xmisao.com/screenshot.png)

## Demo

A sample report is here: [http://aws-reporting.xmisao.com/demo/](http://aws-reporting.xmisao.com/demo/)

## Installation

~~~~
gem install aws-reporting
~~~~

## Usage

### Configuration

Run `aws-reporting config` command, setting up your access key id and secret access key interactively. IAM is available.

~~~~
aws-reporting config
~~~~

### Generating Report

Run `aws-reporting run` command, AWS-Reporting fetches data from Amazon CloudWatch, and saves report as HTML to `/path/to/report`.

~~~~
aws-reporting run /path/to/report
~~~~

### Serve Report locally

If you use Fiefox, you can open a report directly without a HTTP server.
For other browsers, AWS-Reporting includes a HTTP server.

Run `aws-reporting serve` command, serve report locally.
Default URL is `http://localhost:23456/`.

~~~~
aws-reporting serve /path/to/report
~~~~

## Tips

### Schedule report generating using cron

Setting up daily reporting in `crontab` like this:

~~~~
0 0 * * * aws-reporting run /path/to/report/`date +"\%Y\%m\%d"`
~~~~

A report is saved as like `/path/to/report/20140824`.

### Serve a report using your favorite HTTP Server

For example, virtual host setting in nginx like this:

~~~~
server {
  listen 80;
  server_name your.domain;

  root /path/to/report;
  index index.html;
}
~~~~

## License

This software is distributed under the MIT license.
