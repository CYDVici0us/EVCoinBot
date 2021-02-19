from web3 import Web3
import json


class connector():
    def __init__(self,infuraID,abiPath,contractAddress):
        self.w3 = Web3(Web3.HTTPProvider('https://ropsten.infura.io/v3/'+infuraID))
        with open(abiPath) as f:
            info_json = json.load(f)
        abi = info_json["abi"]
        ca = self.w3.toChecksumAddress(contractAddress)
        self.evCoin = self.w3.eth.contract(address=ca, abi = abi)

    def getBalance(self,who):
        address = self.w3.toChecksumAddress(who)
        return self.evCoin.functions.balanceOf(address).call()

    def getSupply(self):
        return self.evCoin.functions.totalSupply().call()





