#!/bin/sh
set -ex
docker run --rm -it \
    --volume=$PWD:/srv/jekyll \
    --volume=$PWD/vendor/bundle:/usr/local/bundle \
    --env JEKYLL_ENV=production \
    -p 4000:4000 \
    jekyll/jekyll \
    sh /srv/jekyll/serve.sh
