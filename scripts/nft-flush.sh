#!/bin/bash
#
# Name: nft-flush
# Auth: Gavin Lloyd <gavinhungry@gmail.com>
# Date: 06 Mar 2014
# Desc: Flush and delete all nftables rules, chains and tables
#

NFT=/usr/bin/nft
FAMILIES="ip ip6 arp bridge"

for FAMILY in $FAMILIES; do
  TABLES=$($NFT list tables $FAMILY | grep "^table\s" | cut -d' ' -f2)
  
  for TABLE in $TABLES; do
    CHAINS=$($NFT list table $FAMILY $TABLE | grep "^\schain\s" | cut -d' ' -f2)

    for CHAIN in $CHAINS; do
      echo "Flushing chain: $FAMILY->$TABLE->$CHAIN"
      $NFT flush chain $FAMILY $TABLE $CHAIN
      $NFT delete chain $FAMILY $TABLE $CHAIN
    done

    echo "Flushing table: $FAMILY->$TABLE"
    $NFT flush table $FAMILY $TABLE
    $NFT delete table $FAMILY $TABLE
  done
done
