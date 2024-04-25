#!/usr/bin/env bash

generateArtifacts() {
  printHeadline "Generating basic configs" "U1F913"

  printItalics "Generating crypto material for UniGov" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-unigov.yaml" "peerOrganizations/unigov.com" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating crypto material for UniA" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-unia.yaml" "peerOrganizations/unia.com" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating crypto material for UniB" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-unib.yaml" "peerOrganizations/unib.com" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating genesis block for group thesisportal" "U1F3E0"
  genesisBlockCreate "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config" "ThesisportalGenesis"

  # Create directory for chaincode packages to avoid permission errors on linux
  mkdir -p "$FABLO_NETWORK_ROOT/fabric-config/chaincode-packages"
}

startNetwork() {
  printHeadline "Starting network" "U1F680"
  (cd "$FABLO_NETWORK_ROOT"/fabric-docker && docker-compose up -d)
  sleep 4
}

generateChannelsArtifacts() {
  printHeadline "Generating config for 'thesis-portal-channel'" "U1F913"
  createChannelTx "thesis-portal-channel" "$FABLO_NETWORK_ROOT/fabric-config" "ThesisPortalChannel" "$FABLO_NETWORK_ROOT/fabric-config/config"
}

installChannels() {
  printHeadline "Creating 'thesis-portal-channel' on UniA/peer0" "U1F63B"
  docker exec -i cli.unia.com bash -c "source scripts/channel_fns.sh; createChannelAndJoin 'thesis-portal-channel' 'UniAMSP' 'peer0.unia.com:7041' 'crypto/users/Admin@unia.com/msp' 'orderer0.thesisportal.unigov.com:7030';"

  printItalics "Joining 'thesis-portal-channel' on  UniB/peer0" "U1F638"
  docker exec -i cli.unib.com bash -c "source scripts/channel_fns.sh; fetchChannelAndJoin 'thesis-portal-channel' 'UniBMSP' 'peer0.unib.com:7061' 'crypto/users/Admin@unib.com/msp' 'orderer0.thesisportal.unigov.com:7030';"
}

installChaincodes() {
  if [ -n "$(ls "$CHAINCODES_BASE_DIR/./components/thesis-portal-chaincode")" ]; then
    local version="1.0.0"
    printHeadline "Packaging chaincode 'thesis-portal-chaincode'" "U1F60E"
    chaincodeBuild "thesis-portal-chaincode" "node" "$CHAINCODES_BASE_DIR/./components/thesis-portal-chaincode" "16"
    chaincodePackage "cli.unia.com" "peer0.unia.com:7041" "thesis-portal-chaincode" "$version" "node" printHeadline "Installing 'thesis-portal-chaincode' for UniA" "U1F60E"
    chaincodeInstall "cli.unia.com" "peer0.unia.com:7041" "thesis-portal-chaincode" "$version" ""
    chaincodeApprove "cli.unia.com" "peer0.unia.com:7041" "thesis-portal-channel" "thesis-portal-chaincode" "$version" "orderer0.thesisportal.unigov.com:7030" "OR('UniAMSP.member','UniBMSP.member')" "false" "" "collections/thesis-portal-chaincode.json"
    printHeadline "Installing 'thesis-portal-chaincode' for UniB" "U1F60E"
    chaincodeInstall "cli.unib.com" "peer0.unib.com:7061" "thesis-portal-chaincode" "$version" ""
    chaincodeApprove "cli.unib.com" "peer0.unib.com:7061" "thesis-portal-channel" "thesis-portal-chaincode" "$version" "orderer0.thesisportal.unigov.com:7030" "OR('UniAMSP.member','UniBMSP.member')" "false" "" "collections/thesis-portal-chaincode.json"
    printItalics "Committing chaincode 'thesis-portal-chaincode' on channel 'thesis-portal-channel' as 'UniA'" "U1F618"
    chaincodeCommit "cli.unia.com" "peer0.unia.com:7041" "thesis-portal-channel" "thesis-portal-chaincode" "$version" "orderer0.thesisportal.unigov.com:7030" "OR('UniAMSP.member','UniBMSP.member')" "false" "" "peer0.unia.com:7041,peer0.unib.com:7061" "" "collections/thesis-portal-chaincode.json"
  else
    echo "Warning! Skipping chaincode 'thesis-portal-chaincode' installation. Chaincode directory is empty."
    echo "Looked in dir: '$CHAINCODES_BASE_DIR/./components/thesis-portal-chaincode'"
  fi

}

installChaincode() {
  local chaincodeName="$1"
  if [ -z "$chaincodeName" ]; then
    echo "Error: chaincode name is not provided"
    exit 1
  fi

  local version="$2"
  if [ -z "$version" ]; then
    echo "Error: chaincode version is not provided"
    exit 1
  fi

  if [ "$chaincodeName" = "thesis-portal-chaincode" ]; then
    if [ -n "$(ls "$CHAINCODES_BASE_DIR/./components/thesis-portal-chaincode")" ]; then
      printHeadline "Packaging chaincode 'thesis-portal-chaincode'" "U1F60E"
      chaincodeBuild "thesis-portal-chaincode" "node" "$CHAINCODES_BASE_DIR/./components/thesis-portal-chaincode" "16"
      chaincodePackage "cli.unia.com" "peer0.unia.com:7041" "thesis-portal-chaincode" "$version" "node" printHeadline "Installing 'thesis-portal-chaincode' for UniA" "U1F60E"
      chaincodeInstall "cli.unia.com" "peer0.unia.com:7041" "thesis-portal-chaincode" "$version" ""
      chaincodeApprove "cli.unia.com" "peer0.unia.com:7041" "thesis-portal-channel" "thesis-portal-chaincode" "$version" "orderer0.thesisportal.unigov.com:7030" "OR('UniAMSP.member','UniBMSP.member')" "false" "" "collections/thesis-portal-chaincode.json"
      printHeadline "Installing 'thesis-portal-chaincode' for UniB" "U1F60E"
      chaincodeInstall "cli.unib.com" "peer0.unib.com:7061" "thesis-portal-chaincode" "$version" ""
      chaincodeApprove "cli.unib.com" "peer0.unib.com:7061" "thesis-portal-channel" "thesis-portal-chaincode" "$version" "orderer0.thesisportal.unigov.com:7030" "OR('UniAMSP.member','UniBMSP.member')" "false" "" "collections/thesis-portal-chaincode.json"
      printItalics "Committing chaincode 'thesis-portal-chaincode' on channel 'thesis-portal-channel' as 'UniA'" "U1F618"
      chaincodeCommit "cli.unia.com" "peer0.unia.com:7041" "thesis-portal-channel" "thesis-portal-chaincode" "$version" "orderer0.thesisportal.unigov.com:7030" "OR('UniAMSP.member','UniBMSP.member')" "false" "" "peer0.unia.com:7041,peer0.unib.com:7061" "" "collections/thesis-portal-chaincode.json"

    else
      echo "Warning! Skipping chaincode 'thesis-portal-chaincode' install. Chaincode directory is empty."
      echo "Looked in dir: '$CHAINCODES_BASE_DIR/./components/thesis-portal-chaincode'"
    fi
  fi
}

runDevModeChaincode() {
  local chaincodeName=$1
  if [ -z "$chaincodeName" ]; then
    echo "Error: chaincode name is not provided"
    exit 1
  fi

  if [ "$chaincodeName" = "thesis-portal-chaincode" ]; then
    local version="1.0.0"
    printHeadline "Approving 'thesis-portal-chaincode' for UniA (dev mode)" "U1F60E"
    chaincodeApprove "cli.unia.com" "peer0.unia.com:7041" "thesis-portal-channel" "thesis-portal-chaincode" "1.0.0" "orderer0.thesisportal.unigov.com:7030" "OR('UniAMSP.member','UniBMSP.member')" "false" "" "collections/thesis-portal-chaincode.json"
    printHeadline "Approving 'thesis-portal-chaincode' for UniB (dev mode)" "U1F60E"
    chaincodeApprove "cli.unib.com" "peer0.unib.com:7061" "thesis-portal-channel" "thesis-portal-chaincode" "1.0.0" "orderer0.thesisportal.unigov.com:7030" "OR('UniAMSP.member','UniBMSP.member')" "false" "" "collections/thesis-portal-chaincode.json"
    printItalics "Committing chaincode 'thesis-portal-chaincode' on channel 'thesis-portal-channel' as 'UniA' (dev mode)" "U1F618"
    chaincodeCommit "cli.unia.com" "peer0.unia.com:7041" "thesis-portal-channel" "thesis-portal-chaincode" "1.0.0" "orderer0.thesisportal.unigov.com:7030" "OR('UniAMSP.member','UniBMSP.member')" "false" "" "peer0.unia.com:7041,peer0.unib.com:7061" "" "collections/thesis-portal-chaincode.json"

  fi
}

upgradeChaincode() {
  local chaincodeName="$1"
  if [ -z "$chaincodeName" ]; then
    echo "Error: chaincode name is not provided"
    exit 1
  fi

  local version="$2"
  if [ -z "$version" ]; then
    echo "Error: chaincode version is not provided"
    exit 1
  fi

  if [ "$chaincodeName" = "thesis-portal-chaincode" ]; then
    if [ -n "$(ls "$CHAINCODES_BASE_DIR/./components/thesis-portal-chaincode")" ]; then
      printHeadline "Packaging chaincode 'thesis-portal-chaincode'" "U1F60E"
      chaincodeBuild "thesis-portal-chaincode" "node" "$CHAINCODES_BASE_DIR/./components/thesis-portal-chaincode" "16"
      chaincodePackage "cli.unia.com" "peer0.unia.com:7041" "thesis-portal-chaincode" "$version" "node" printHeadline "Installing 'thesis-portal-chaincode' for UniA" "U1F60E"
      chaincodeInstall "cli.unia.com" "peer0.unia.com:7041" "thesis-portal-chaincode" "$version" ""
      chaincodeApprove "cli.unia.com" "peer0.unia.com:7041" "thesis-portal-channel" "thesis-portal-chaincode" "$version" "orderer0.thesisportal.unigov.com:7030" "OR('UniAMSP.member','UniBMSP.member')" "false" "" "collections/thesis-portal-chaincode.json"
      printHeadline "Installing 'thesis-portal-chaincode' for UniB" "U1F60E"
      chaincodeInstall "cli.unib.com" "peer0.unib.com:7061" "thesis-portal-chaincode" "$version" ""
      chaincodeApprove "cli.unib.com" "peer0.unib.com:7061" "thesis-portal-channel" "thesis-portal-chaincode" "$version" "orderer0.thesisportal.unigov.com:7030" "OR('UniAMSP.member','UniBMSP.member')" "false" "" "collections/thesis-portal-chaincode.json"
      printItalics "Committing chaincode 'thesis-portal-chaincode' on channel 'thesis-portal-channel' as 'UniA'" "U1F618"
      chaincodeCommit "cli.unia.com" "peer0.unia.com:7041" "thesis-portal-channel" "thesis-portal-chaincode" "$version" "orderer0.thesisportal.unigov.com:7030" "OR('UniAMSP.member','UniBMSP.member')" "false" "" "peer0.unia.com:7041,peer0.unib.com:7061" "" "collections/thesis-portal-chaincode.json"

    else
      echo "Warning! Skipping chaincode 'thesis-portal-chaincode' upgrade. Chaincode directory is empty."
      echo "Looked in dir: '$CHAINCODES_BASE_DIR/./components/thesis-portal-chaincode'"
    fi
  fi
}

notifyOrgsAboutChannels() {
  printHeadline "Creating new channel config blocks" "U1F537"
  createNewChannelUpdateTx "thesis-portal-channel" "UniAMSP" "ThesisPortalChannel" "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config"
  createNewChannelUpdateTx "thesis-portal-channel" "UniBMSP" "ThesisPortalChannel" "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config"

  printHeadline "Notyfing orgs about channels" "U1F4E2"
  notifyOrgAboutNewChannel "thesis-portal-channel" "UniAMSP" "cli.unia.com" "peer0.unia.com" "orderer0.thesisportal.unigov.com:7030"
  notifyOrgAboutNewChannel "thesis-portal-channel" "UniBMSP" "cli.unib.com" "peer0.unib.com" "orderer0.thesisportal.unigov.com:7030"

  printHeadline "Deleting new channel config blocks" "U1F52A"
  deleteNewChannelUpdateTx "thesis-portal-channel" "UniAMSP" "cli.unia.com"
  deleteNewChannelUpdateTx "thesis-portal-channel" "UniBMSP" "cli.unib.com"
}

printStartSuccessInfo() {
  printHeadline "Done! Enjoy your fresh network" "U1F984"
}

stopNetwork() {
  printHeadline "Stopping network" "U1F68F"
  (cd "$FABLO_NETWORK_ROOT"/fabric-docker && docker-compose stop)
  sleep 4
}

networkDown() {
  printHeadline "Destroying network" "U1F916"
  (cd "$FABLO_NETWORK_ROOT"/fabric-docker && docker-compose down)

  printf "Removing chaincode containers & images... \U1F5D1 \n"
  for container in $(docker ps -a | grep "dev-peer0.unia.com-thesis-portal-chaincode" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.unia.com-thesis-portal-chaincode*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer0.unib.com-thesis-portal-chaincode" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.unib.com-thesis-portal-chaincode*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done

  printf "Removing generated configs... \U1F5D1 \n"
  rm -rf "$FABLO_NETWORK_ROOT/fabric-config/config"
  rm -rf "$FABLO_NETWORK_ROOT/fabric-config/crypto-config"
  rm -rf "$FABLO_NETWORK_ROOT/fabric-config/chaincode-packages"

  printHeadline "Done! Network was purged" "U1F5D1"
}
