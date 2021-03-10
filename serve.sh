#!/bin/sh
set -ex

bundle install
bundle exec jekyll serve
