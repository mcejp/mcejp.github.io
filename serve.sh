#!/bin/sh
set -ex

bundle install
#bundle update
bundle exec jekyll serve
