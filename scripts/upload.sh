#!/bin/bash

artifact=$(ls ./releases | sort -V | tail -1)
echo "Uploading $artifact"
scp ./releases/$artifact adhockonturio@adhoc.kontur.io:/home/adhockonturio/www/temp/