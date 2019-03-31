#!/usr/bin/env python3

import grpc

import concordium_pb2
import concordium_pb2_grpc

import subprocess

import argparse

import base58 # pip3 install base58

def callHaskell(args):
    return subprocess.Popen(['./stack', 'run', 'simple-client', '--'] + args,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE,
                            stdin=subprocess.PIPE)

BAKER = 'localhost:11100'

def setup():
    parser = argparse.ArgumentParser(description='Talk to nodes.')
    parser.add_argument('command', metavar='COMMAND', type=str,
                    help='what do you want to do')
    parser.add_argument('--index',
                        metavar='INDEX',
                        type=int,
                        help='Contract index',
                        dest='index')
    parser.add_argument('--version',
                        metavar='VERSION',
                        type=int,
                        help='Contract version.',
                        dest='version')
    parser.add_argument('--account',
                        metavar='ADDRESS',
                        type=str,
                        help='Account address.',
                        dest='account')
    parser.add_argument('--source',
                        metavar='FILENAME',
                        type=str,
                        help='Source file of transaction or module.',
                        dest='source')
    parser.add_argument('--baker',
                        metavar='BAKER',
                        type=str,
                        dest='baker')
    
    args = parser.parse_args()

    if args.baker:
        global BAKER
        BAKER = args.baker

    if args.command == 'GetInstanceState':
       subp = callHaskell(['--get-final-contract-state'])

       res = runContractState(args.index.to_bytes(8, byteorder='big') + args.version.to_bytes(8, byteorder='big'))

       out, errs = subp.communicate(input=res)
       if not errs:
           print("Success.")
           print(out.decode())
       else:
           print("Command failed.")
           print(errs.decode())

    elif args.command == 'GetAccountState':
       res = runAccountState(base58.b58decode(args.account))

       subp = callHaskell(['--get-final-account-state'])
       out, errs = subp.communicate(input=res, timeout=5)

       if not errs:
           print("Success.")
           print(out.decode())
       else:
           print("Command failed.")
           print(errs.decode())

    elif args.command == 'GetAccountList':
       subp = callHaskell(['--get-final-account-list'])
       x = runAccountList()

       out, errs = subp.communicate(input=x, timeout=5)

       print(out.decode())
       print(errs.decode())

    elif args.command == 'GetInstanceList':
       subp = callHaskell(['--get-final-contract-list'])
       x = runInstanceList()

       out, errs = subp.communicate(input=x, timeout=5)

       if not errs:
           print("Success.")
           print(out.decode())
       else:
           print(errs.decode())

    elif args.command == 'LoadModule':
       supb = callHaskell(['--load-module', args.source])
       out, errs = subp.communicate(timeout=5)
       if not errs:
           print("Success.")
           print(out.decode())
       else:
           print("Command failed.")
           print(errs.decode())
                 

    elif args.command == 'ListModules':
       supb = callHaskell(['--list-modules'])
       out, errs = subp.communicate(timeout=5)
       if not errs:
           print("Success.")
           print(out.decode())
       else:
           print("Command failed.")
           print(errs.decode())

    elif args.command == 'SendTransaction':

       subp = callHaskell(['--send-transaction', args.source])

       out, errs = subp.communicate(timeout=5)

       if not errs:
          res = runSendTransaction(out)
          if res:
              print("Transaction received.")
          else:
              print("Baker: Error decoding transaction.")
       else: 
          print(errs.decode())
    else:
       print("Unknown command.")

def runAccountList():
    with grpc.insecure_channel(BAKER) as channel:
        stub = concordium_pb2_grpc.P2PStub(channel)
        response = stub.GetLastFinalAccountList(request = concordium_pb2.Empty(), metadata=[('authentication', 'rpcadmin')])
    return response.payload


def runInstanceList():
    with grpc.insecure_channel(BAKER) as channel:
        stub = concordium_pb2_grpc.P2PStub(channel)
        response = stub.GetLastFinalInstances(request = concordium_pb2.Empty(), metadata=[('authentication', 'rpcadmin')])
    return response.payload


def runAccountState(acc):
    with grpc.insecure_channel(BAKER) as channel:
        stub = concordium_pb2_grpc.P2PStub(channel)
        response = stub.GetLastFinalAccountInfo(request = concordium_pb2.AccountAddress(payload=acc), metadata=[('authentication', 'rpcadmin')])
    return response.payload


def runContractState(arg):
    with grpc.insecure_channel(BAKER) as channel:
        stub = concordium_pb2_grpc.P2PStub(channel)
        response = stub.GetLastFinalInstanceInfo(request = concordium_pb2.ContractInstanceAddress(payload=arg), metadata=[('authentication', 'rpcadmin')])
    return response.payload


def runSendTransaction(arg):
    with grpc.insecure_channel(BAKER) as channel:
        stub = concordium_pb2_grpc.P2PStub(channel)
        response = stub.SendTransaction(request = concordium_pb2.SendTransactionRequest(network_id=1000, payload=arg),
                                        metadata=[('authentication', 'rpcadmin')])
    return response.value

def runGetConsensusStatus():
    with grpc.insecure_channel(BAKER) as channel:
        stub = concordium_pb2_grpc.P2PStub(channel)
        response = stub.GetConsensusStatus(request = concordium_pb2.Empty(),
                                           metadata=[('authentication', 'rpcadmin')])
    return response.json_value
    


if __name__ == '__main__':
   pass

setup()

