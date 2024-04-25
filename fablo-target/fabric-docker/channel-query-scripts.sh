#!/usr/bin/env bash

source "$FABLO_NETWORK_ROOT/fabric-docker/scripts/channel-query-functions.sh"

set -eu

channelQuery() {
  echo "-> Channel query: " + "$@"

  if [ "$#" -eq 1 ]; then
    printChannelsHelp

  elif [ "$1" = "list" ] && [ "$2" = "unia" ] && [ "$3" = "peer0" ]; then

    peerChannelList "cli.unia.com" "peer0.unia.com:7041"

  elif
    [ "$1" = "list" ] && [ "$2" = "unib" ] && [ "$3" = "peer0" ]
  then

    peerChannelList "cli.unib.com" "peer0.unib.com:7061"

  elif

    [ "$1" = "getinfo" ] && [ "$2" = "thesis-portal-channel" ] && [ "$3" = "unia" ] && [ "$4" = "peer0" ]
  then

    peerChannelGetInfo "thesis-portal-channel" "cli.unia.com" "peer0.unia.com:7041"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "thesis-portal-channel" ] && [ "$4" = "unia" ] && [ "$5" = "peer0" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfig "thesis-portal-channel" "cli.unia.com" "$TARGET_FILE" "peer0.unia.com:7041"

  elif [ "$1" = "fetch" ] && [ "$3" = "thesis-portal-channel" ] && [ "$4" = "unia" ] && [ "$5" = "peer0" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlock "thesis-portal-channel" "cli.unia.com" "${BLOCK_NAME}" "peer0.unia.com:7041" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "thesis-portal-channel" ] && [ "$3" = "unib" ] && [ "$4" = "peer0" ]
  then

    peerChannelGetInfo "thesis-portal-channel" "cli.unib.com" "peer0.unib.com:7061"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "thesis-portal-channel" ] && [ "$4" = "unib" ] && [ "$5" = "peer0" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfig "thesis-portal-channel" "cli.unib.com" "$TARGET_FILE" "peer0.unib.com:7061"

  elif [ "$1" = "fetch" ] && [ "$3" = "thesis-portal-channel" ] && [ "$4" = "unib" ] && [ "$5" = "peer0" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlock "thesis-portal-channel" "cli.unib.com" "${BLOCK_NAME}" "peer0.unib.com:7061" "$TARGET_FILE"

  else

    echo "$@"
    echo "$1, $2, $3, $4, $5, $6, $7, $#"
    printChannelsHelp
  fi

}

printChannelsHelp() {
  echo "Channel management commands:"
  echo ""

  echo "fablo channel list unia peer0"
  echo -e "\t List channels on 'peer0' of 'UniA'".
  echo ""

  echo "fablo channel list unib peer0"
  echo -e "\t List channels on 'peer0' of 'UniB'".
  echo ""

  echo "fablo channel getinfo thesis-portal-channel unia peer0"
  echo -e "\t Get channel info on 'peer0' of 'UniA'".
  echo ""
  echo "fablo channel fetch config thesis-portal-channel unia peer0 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer0' of 'UniA'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> thesis-portal-channel unia peer0 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer0' of 'UniA'".
  echo ""

  echo "fablo channel getinfo thesis-portal-channel unib peer0"
  echo -e "\t Get channel info on 'peer0' of 'UniB'".
  echo ""
  echo "fablo channel fetch config thesis-portal-channel unib peer0 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer0' of 'UniB'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> thesis-portal-channel unib peer0 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer0' of 'UniB'".
  echo ""

}
