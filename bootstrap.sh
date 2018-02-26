#!/bin/bash
s3cmd="/usr/local/bin/s3cmd --config=/root/.s3cfg"
s3name="stke-bootstrap"
s3bucket="s3://$s3name"
file="bootstrap.dat"
file_zip="bootstrap.zip"
file_sha256="sha256.txt"

# pass network name as a param
do_the_job() {
  network=$1
  s3currentPath="$s3bucket/dash/"
  echo "$network job - Starting..."
  # process blockchain
  ./linearize-hashes.py linearize-$network.cfg > hashlist.txt
  ./linearize-data.py linearize-$network.cfg
  # compress
  zip $file_zip $file
  # calculate checksums
  sha256sum $file > $file_sha256
  sha256sum $file_zip >> $file_sha256
  # store
  $s3cmd put $file_zip $file_sha256 $s3currentPath --acl-public
  rm $file $file_zip $file_sha256 hashlist.txt
  echo "$network job - Done!"
}

# mainnet
#cat ~/.dash/blocks/blk0000* > $file
blocks=`dash-cli getblockcount`
do_the_job mainnet
