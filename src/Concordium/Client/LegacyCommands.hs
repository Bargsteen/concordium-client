module Concordium.Client.LegacyCommands
  ( LegacyCmd(..)
  , legacyProgramOptions
  ) where

import Concordium.Types
import Data.Text
import Options.Applicative

data LegacyCmd
  = SendTransaction
      { legacySourceFile :: !FilePath
      , legacyNetworkId  :: !Int
      } -- ^ Loads a transaction in the context of the local database and sends it to the specified RPC server
  | GetTransactionStatus
      { legacyTransactionHash :: !Text
      } -- ^ Queries the gRPC for the information about the execution of a transaction
  | GetTransactionStatusInBlock
      { legacyTransactionHash :: !Text,
        legacyBlockHash' :: !Text
      } -- ^ Queries the gRPC for the information about the execution of a transaction
  | GetAccountNonFinalized {
      legacyAddress :: !Text
      } -- ^Get non finalized transactions for a given account.
  | GetNextAccountNonce {
      legacyAddress :: !Text
      } -- ^Get non finalized transactions for a given account.
  | GetConsensusInfo -- ^ Queries the gRPC server for the consensus information
  | GetBlockInfo
      { legacyEvery     :: !Bool,
        legacyBlockHash :: !(Maybe Text)
      } -- ^ Queries the gRPC server for the information of a specific block
  | GetBlockSummary
      { legacyBlockHash :: !(Maybe Text)
      } -- ^ Queries the gRPC server for the information of a specific block and its transactions.
  | GetBlocksAtHeight
      { legacyBlockHeight :: !BlockHeight,
        legacyFromGenesisIndex :: !(Maybe GenesisIndex),
        legacyRestrictToGenesis :: !(Maybe Bool)
      } -- ^ Queries the gRPC server for the list of blocks with a given height.
  | GetAccountList
      { legacyBlockHash :: !(Maybe Text)
      } -- ^ Queries the gRPC server for the list of accounts on a specific block
  | GetInstances
      { legacyBlockHash :: !(Maybe Text)
      } -- ^ Queries the gRPC server for the list of instances on a specific block
  | GetAccountInfo
      { legacyAddress   :: !Text
      , legacyBlockHash :: !(Maybe Text)
      } -- ^ Queries the gRPC server for the information of an account on a specific block
  | GetInstanceInfo
      { legacyContractAddress :: !Text,
        legacyBlockHash       :: !(Maybe Text)
      } -- ^ Queries the gRPC server for the information of an instance on a specific block
  | GetRewardStatus
      { legacyBlockHash :: !(Maybe Text)
      } -- ^ Queries the gRPC server for the reward status on a specific block
  | GetBirkParameters
      { legacyBlockHash :: !(Maybe Text)
      } -- ^ Queries the gRPC server for the Birk parameters on a specific block
  | GetModuleList
      { legacyBlockHash :: !(Maybe Text)
      } -- ^ Queries the gRPC server for the list of modules on a specific block
  | GetNodeInfo -- ^Queries the gRPC server for the node information.
  | GetPeerData
      { legacyIncludeBootstrapper :: !Bool -- ^Whether to include bootstrapper node in the stats or not.
      } -- ^Get all data as pertaining to the node's role as a member of the P2P network.
  | StartBaker
  | StopBaker
  | PeerConnect
      { legacyIp     :: !Text
      , legacyPortPC :: !Int
      }
  | PeerDisconnect
      { legacyIp     :: !Text
      , legacyPortPC :: !Int
      }
  | GetPeerUptime
  | BanNode
      { legacyNodeId   :: !(Maybe Text)
      , legacyNodeIp   :: !(Maybe Text)
      }
  | UnbanNode
      { legacyNodeId   :: !(Maybe Text)
      , legacyNodeIp   :: !(Maybe Text)
      }
  | JoinNetwork
      { legacyNetId :: !Int
      }
  | LeaveNetwork
      { legacyNetId :: !Int
      }
  | GetAncestors
      { legacyAmount    :: !Int,
        legacyBlockHash :: !(Maybe Text) -- defaults to last finalized block
      }
  | GetBranches
  | GetBannedPeers
  | Shutdown
  | DumpStart
  | DumpStop
  | GetIdentityProviders
    { legacyBlockHash :: !(Maybe Text) }
  | GetAnonymityRevokers
    { legacyBlockHash :: !(Maybe Text) }
  | GetCryptographicParameters
    { legacyBlockHash :: !(Maybe Text) }
  deriving (Show)

legacyProgramOptions :: Parser LegacyCmd
legacyProgramOptions =
  hsubparser
    (sendTransactionCommand <>
     getTransactionStatusCommand <>
     getTransactionStatusInBlockCommand <>
     getConsensusInfoCommand <>
     getBlockInfoCommand <>
     getBlockSummaryCommand <>
     getBlocksAtHeightCommand <>
     getAccountListCommand <>
     getInstancesCommand <>
     getAccountInfoCommand <>
     getAccountNonFinalizedCommand <>
     getNextAccountNonceCommand <>
     getInstanceInfoCommand <>
     getRewardStatusCommand <>
     getBirkParametersCommand <>
     getModuleListCommand <>
     getNodeInfoCommand <>
     getPeerDataCommand <>
     startBakerCommand <>
     stopBakerCommand <>
     peerConnectCommand <>
     peerDisconnectCommand <>
     getPeerUptimeCommand <>
     banNodeCommand <>
     unbanNodeCommand <>
     joinNetworkCommand <>
     leaveNetworkCommand <>
     getAncestorsCommand <>
     getBranchesCommand <>
     getBannedPeersCommand <>
     shutdownCommand <>
     dumpStartCommand <>
     dumpStopCommand <>
     getIdentityProvidersCommand <>
     getAnonymityRevokersCommand <>
     getCryptographicParametersCommand
    )

getPeerDataCommand :: Mod CommandFields LegacyCmd
getPeerDataCommand =
  command
    "GetPeerData"
    (info
       (GetPeerData <$> switch (long "bootstrapper" <> help "Include the bootstrapper in the peer data."))
       (progDesc "Query the gRPC server for the node information."))

getNodeInfoCommand :: Mod CommandFields LegacyCmd
getNodeInfoCommand =
  command
    "GetNodeInfo"
    (info
       (pure GetNodeInfo)
       (progDesc "Query the gRPC server for the node information."))

sendTransactionCommand :: Mod CommandFields LegacyCmd
sendTransactionCommand =
  command
    "SendTransaction"
    (info
       (SendTransaction <$>
        strArgument
          (metavar "TX-SOURCE" <> help "JSON file with the transaction") <*>
        argument
          auto
          (metavar "NET-ID" <>
           help "Network ID for the transaction to be sent through" <>
           value 100 <>
           showDefault))
       (progDesc
          "Parse transaction in current context and send it to the baker."))

getTransactionStatusCommand :: Mod CommandFields LegacyCmd
getTransactionStatusCommand =
  command
    "GetTransactionStatus"
    (info
       (GetTransactionStatus <$>
        strArgument
          (metavar "TX-HASH" <> help "Hash of the transaction to query for"))
       (progDesc
          "Query the gRPC for the information about the execution of a transaction."))

getTransactionStatusInBlockCommand :: Mod CommandFields LegacyCmd
getTransactionStatusInBlockCommand =
  command
    "GetTransactionStatusInBlock"
    (info
       (GetTransactionStatusInBlock <$>
        strArgument
          (metavar "TX-HASH" <> help "Hash of the transaction to query for") <*>
        strArgument
          (metavar "BLOCK-HASH" <> help "Hash of the block.")
       )
       (progDesc
          "Query the gRPC for the information about the execution of a transaction in a specific block."))


getConsensusInfoCommand :: Mod CommandFields LegacyCmd
getConsensusInfoCommand =
  command
    "GetConsensusInfo"
    (info
       (pure GetConsensusInfo)
       (progDesc "Query the gRPC server for the consensus information."))

getBlockInfoCommand :: Mod CommandFields LegacyCmd
getBlockInfoCommand =
  command
    "GetBlockInfo"
    (info
       (GetBlockInfo <$>
        switch (short 'a' <> long "all" <> help "Traverse all parent blocks and get their info as well.") <*>
        optional (strArgument (metavar "BLOCK-HASH" <> help "Hash of the block to query"))
       )
       (progDesc "Query the gRPC server for a specific block."))

getBlockSummaryCommand :: Mod CommandFields LegacyCmd
getBlockSummaryCommand =
  command
    "GetBlockSummary"
    (info
       (GetBlockSummary <$>
        optional (strArgument (metavar "BLOCK-HASH" <> help "Hash of the block to query"))
       )
       (progDesc "Query the gRPC server for a specific block and its transactions."))

getBlocksAtHeightCommand :: Mod CommandFields LegacyCmd
getBlocksAtHeightCommand =
  command
    "GetBlocksAtHeight"
    (info
      (GetBlocksAtHeight <$>
       argument auto (metavar "HEIGHT" <> help "Height of the blocks to query.") <*>
       optional (option auto (long "genesis-index" <> metavar "GENINDEX" <> help "Base genesis index")) <*>
       flag Nothing (Just True) (long "restrict" <> help "Restrict to specified genesis index")
      )
      (progDesc "Query the gRPC server for all blocks at the given height."))

getAccountListCommand :: Mod CommandFields LegacyCmd
getAccountListCommand =
  command
    "GetAccountList"
    (info
       (GetAccountList <$>
        optional (strArgument (metavar "BLOCK-HASH" <> help "Hash of the block to query")))
       (progDesc "Query the gRPC server for the list of accounts."))

getInstancesCommand :: Mod CommandFields LegacyCmd
getInstancesCommand =
  command
    "GetInstances"
    (info
       (GetInstances <$>
        optional (strArgument (metavar "BLOCK-HASH" <> help "Hash of the block to query")))
       (progDesc "Query the gRPC server for the list of instances."))

getAccountInfoCommand :: Mod CommandFields LegacyCmd
getAccountInfoCommand =
  command
    "GetAccountInfo"
    (info
       (GetAccountInfo <$>
        strArgument (metavar "IDENTIFIER" <> help "Account address or credential id to be queried about.") <*>
        optional (strArgument (metavar "BLOCK-HASH" <> help "Hash of the block in which to do the query"))
       )
       (progDesc "Query the gRPC server for the information of an account."))

getAccountNonFinalizedCommand :: Mod CommandFields LegacyCmd
getAccountNonFinalizedCommand =
  command
    "GetAccountNonFinalized"
    (info
       (GetAccountNonFinalized <$>
        strArgument (metavar "ACCOUNT" <> help "Account to be queried about")
       )
       (progDesc "Query the gRPC server for the information on non-finalized transactions for an account."))

getNextAccountNonceCommand :: Mod CommandFields LegacyCmd
getNextAccountNonceCommand =
  command
    "GetNextAccountNonce"
    (info
       (GetNextAccountNonce <$>
        strArgument (metavar "ACCOUNT" <> help "Account to be queried about")
       )
       (progDesc "Query the gRPC server for the best guess on the next account nonce."))


getInstanceInfoCommand :: Mod CommandFields LegacyCmd
getInstanceInfoCommand =
  command
    "GetInstanceInfo"
    (info
       (GetInstanceInfo <$>
        strArgument (metavar "INSTANCE" <> help "Contract address to be queried about") <*>
        optional (strArgument (metavar "BLOCK-HASH" <>
                               help "Hash of the block in which to do the query"))
       )
       (progDesc "Query the gRPC server for the information of an instance."))

getRewardStatusCommand :: Mod CommandFields LegacyCmd
getRewardStatusCommand =
  command
    "GetRewardStatus"
    (info
       (GetRewardStatus <$>
        optional (strArgument (metavar "BLOCK-HASH" <> help "Hash of the block to query")))
       (progDesc "Query the gRPC server for the reward status."))

getBirkParametersCommand :: Mod CommandFields LegacyCmd
getBirkParametersCommand =
  command
    "GetBirkParameters"
    (info
       (GetBirkParameters <$>
        optional (strArgument (metavar "BLOCK-HASH" <> help "Hash of the block to query")))
       (progDesc "Query the gRPC server for the Birk parameters."))

getModuleListCommand :: Mod CommandFields LegacyCmd
getModuleListCommand =
  command
    "GetModuleList"
    (info
       (GetModuleList <$>
        optional (strArgument (metavar "BLOCK-HASH" <> help "Hash of the block to query")))
       (progDesc "Query the gRPC server for the list of modules."))

startBakerCommand :: Mod CommandFields LegacyCmd
startBakerCommand =
    command
     "StartBaker"
    (info
       (pure StartBaker)
       (progDesc "Start the baker."))

stopBakerCommand :: Mod CommandFields LegacyCmd
stopBakerCommand =
    command
     "StopBaker"
    (info
       (pure StopBaker)
       (progDesc "Stop the baker."))

peerConnectCommand :: Mod CommandFields LegacyCmd
peerConnectCommand =
    command
     "PeerConnect"
    (info
       (PeerConnect <$>
        strArgument (metavar "PEER-IP" <> help "IP of the peer we want to connect to") <*>
        argument
          auto
          (metavar "PEER-PORT" <> help "Port of the peer we want to connect to"))
       (progDesc "Connect to a specified peer."))

peerDisconnectCommand :: Mod CommandFields LegacyCmd
peerDisconnectCommand =
    command
     "PeerDisconnect"
    (info
       (PeerDisconnect <$>
        strArgument (metavar "PEER-IP" <> help "IP of the peer we want to disconnect from.") <*>
        argument
          auto
          (metavar "PEER-PORT" <> help "Port of the peer we want to disconnect from."))
       (progDesc "Disconnect from a specified peer."))

getPeerUptimeCommand :: Mod CommandFields LegacyCmd
getPeerUptimeCommand =
    command
     "GetPeerUptime"
    (info
       (pure GetPeerUptime)
       (progDesc "Get the node uptime."))


banNodeCommand :: Mod CommandFields LegacyCmd
banNodeCommand =
    command
     "BanNode"
    (info
       (BanNode <$>
        optional (strOption (long "node-id" <> metavar "NODE-ID" <> help "ID of the node to be banned")) <*>
        optional (strOption (long "ip" <> metavar "NODE-IP" <> help "IP of the node to be banned")))
       (progDesc "Ban a node. The node to ban can either be supplied via a node-id or via an IP and port, but not both."))

unbanNodeCommand :: Mod CommandFields LegacyCmd
unbanNodeCommand =
    command
     "UnbanNode"
    (info
       (UnbanNode <$>
        optional (strOption (long "node-id" <> metavar "NODE-ID" <> help "ID of the node to be unbanned")) <*>
        optional (strOption (long "ip" <> metavar "NODE-IP" <> help "IP of the node to be banned")))
       (progDesc "Unban a node. The node to unban can either be supplied via a node-id or via an IP."))

joinNetworkCommand :: Mod CommandFields LegacyCmd
joinNetworkCommand =
    command
     "JoinNetwork"
    (info
       (JoinNetwork <$>
        argument auto (metavar "NET-ID" <> help "ID of the network"))
       (progDesc "Join a network."))

leaveNetworkCommand :: Mod CommandFields LegacyCmd
leaveNetworkCommand =
    command
     "LeaveNetwork"
    (info
       (LeaveNetwork <$>
        argument auto (metavar "NET-ID" <> help "ID of the network"))
       (progDesc "Leave a network."))

getAncestorsCommand :: Mod CommandFields LegacyCmd
getAncestorsCommand =
    command
     "GetAncestors"
    (info
       (GetAncestors <$>
        argument
          auto
          (metavar "AMOUNT" <> help "How many ancestors") <*>
        optional (strArgument (metavar "BLOCK-HASH" <> help "Hash of the block to query"))
       )
       (progDesc "Get the ancestors of a block."))

getBranchesCommand :: Mod CommandFields LegacyCmd
getBranchesCommand =
    command
     "GetBranches"
    (info
       (pure GetBranches)
       (progDesc "Get branches in consensus."))

getBannedPeersCommand :: Mod CommandFields LegacyCmd
getBannedPeersCommand =
    command
     "GetBannedPeers"
    (info
       (pure GetBannedPeers)
       (progDesc "Get banned peers."))

shutdownCommand :: Mod CommandFields LegacyCmd
shutdownCommand =
    command
    "Shutdown"
    (info
       (pure Shutdown)
       (progDesc "Shutdown the node gracefully."))

dumpStartCommand :: Mod CommandFields LegacyCmd
dumpStartCommand =
    command
    "DumpStart"
    (info
       (pure DumpStart)
       (progDesc "Start dumping the packages."))

dumpStopCommand :: Mod CommandFields LegacyCmd
dumpStopCommand =
    command
    "DumpStop"
    (info
       (pure DumpStop)
       (progDesc "Stop dumping the packages."))


getIdentityProvidersCommand :: Mod CommandFields LegacyCmd
getIdentityProvidersCommand =
    command
    "GetIdentityProviders"
    (info
     (GetIdentityProviders <$>
        optional (strArgument (metavar "BLOCK-HASH" <> help "Hash of the block to query"))
       )
       (progDesc "Query the gRPC server for the identity providers in a specific block."))

getAnonymityRevokersCommand :: Mod CommandFields LegacyCmd
getAnonymityRevokersCommand =
    command
    "GetAnonymityRevokers"
    (info
     (GetAnonymityRevokers <$>
        optional (strArgument (metavar "BLOCK-HASH" <> help "Hash of the block to query"))
       )
       (progDesc "Query the gRPC server for the anonymity revokers in a specific block."))

getCryptographicParametersCommand :: Mod CommandFields LegacyCmd
getCryptographicParametersCommand =
    command
    "GetCryptographicParameters"
    (info
     (GetCryptographicParameters <$>
        optional (strArgument (metavar "BLOCK-HASH" <> help "Hash of the block to query"))
       )
       (progDesc "Query the gRPC server for the cryptographic parameters in a specific block."))
