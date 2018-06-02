#!/bin/bash

# Some shell scripts that use gcloud and gsutils.  Mostly so I can remember
# what they do.
srcdir = ~/home/project/mojave-tropico/
files = index.html

dom = mojavetropicofilming.com
account = rusty@grumpyengineers.com
proj = mojave
url = http://$(dom)
bkt = $(dom)
bkturl = gs://$(bkt)

## Create the site
create_site() {
    gsutil mb gs://$(bkt) || echo "failed to make bucket"; exit(1)
}

upload() {
    gsutil cp $(files) $(bkturl) || echo "failed to upload, bye"; exit(2)
}

upload_sync() {
    gsutil rsync -r $(files) $(bkturl) || echo "failed to sync.."; exit(3)
}

share_files() {
    for f in $(files); do
        gsutil acl ch -u AllUsers:R $(bkturl)/$f || echo "Failed to share " $f
    done
}

set_web_pages() {
    gsutil web set -m index.html -e 404.html $(bkturl)
}

# TODO - figure this out
# https://cloud.google.com/storage/docs/access-control/create-manage-lists#defaultobjects
make_all_files_public() {
    gsutil defacl get $(bkturl)
}

# Change to our website directory
cd $srcdir

# Create the site, upload files and set perms
create_site || echo "site may already exist, let's try uploading ... "
upload || echo "FAILED upload - BAD - what to do? Panic and che - c - k - o ..."
share_files || echo "FAILED to share files - what is the point?  Good, Bye."
set_web_pages || echo "FAILED setting index.html and 404.html ..., gone."

# now test the site, make sure it is alive
wget -o index.live.html
