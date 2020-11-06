#!/bin/sh
set -ex
docker start -ia jekyll || docker run -it \
    --name jekyll \
    --volume=$PWD:/srv/jekyll \
    --env JEKYLL_ENV=production \
    -p 4000:4000 \
    jekyll/jekyll \
    sh /srv/jekyll/serve.sh
