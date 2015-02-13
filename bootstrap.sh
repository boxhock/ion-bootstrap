#!/bin/bash
date=`date -u`
blocks=`darkcoind getinfo | grep blocks | cut -d " " -f 7 | cut -d "," -f 1`
blocksTestnet=`darkcoind_testnet -conf=/root/.darkcoin/darkcoin-testnet.conf getinfo | grep blocks | cut -d " " -f 7 | cut -d "," -f 1`
date_fmt=`date -u +%Y%m%d`
file="bootstrap.dat"
file_zip="$file.$date_fmt.zip"
file_md5="md5.txt"
file_sha256="sha256.txt"
header=`cat header.md`
prevLinks=`head links.md`
prevLinksTestnet=`head linksTestnet.md`
footer=`cat footer.md`
#mainnet
cat ~/.darkcoin/blocks/blk0000* > $file
zip $file_zip $file
touch $file_md5 $file_sha256
md5sum $file $file_zip > $file_md5
sha256sum $file $file_zip > $file_sha256
size=`ls -lh $file_zip | awk -F" " '{ print $5 }'`
url=`curl --upload-file $file_zip https://transfer.sh/$file_zip`
url_md5=`curl --upload-file $file_md5 https://transfer.sh/$file_md5`
url_sha256=`curl --upload-file $file_sha256 https://transfer.sh/$file_sha256`
newLinks="$blocks $date [$url]($url) ($size) [MD5]($url_md5) [SHA256]($url_sha256)\n\n$prevLinks"
echo -e "$newLinks" > links.md
rm $file $file_zip $file_md5 $file_sha256
#testnet
cat ~/.darkcoin/testnet3/blocks/blk0000* > $file
zip $file_zip $file
touch $file_md5 $file_sha256
md5sum $file $file_zip > $file_md5
sha256sum $file $file_zip > $file_sha256
size=`ls -lh $file_zip | awk -F" " '{ print $5 }'`
url=`curl --upload-file $file_zip https://transfer.sh/$file_zip`
url_md5=`curl --upload-file $file_md5 https://transfer.sh/$file_md5`
url_sha256=`curl --upload-file $file_sha256 https://transfer.sh/$file_sha256`
newLinksTestnet="$blocksTestnet $date [$url]($url) ($size) [MD5]($url_md5) [SHA256]($url_sha256)\n\n$prevLinksTestnet"
echo -e "$newLinksTestnet" > linksTestnet.md
rm $file $file_zip $file_md5 $file_sha256
#construct README.md
echo -e "$header\n\n####For mainnet:\n\n$newLinks\n\n####For testnet:\n\n$newLinksTestnet\n\n$footer" > README.md
#push
git commit -am "$date - autoupdate"
git push
