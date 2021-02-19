from connector import *
import discord
import sys
import json

config = {}
with open('config.json','r') as f:
    config = json.load(f)

client = discord.Client()
TOKEN = config['token']
c = connector(config['infuraID'],config['abiPath'],config['contractAddress'])

iceData = 'iceData.json'
addressData ='addressData.json'
iceCount = {}
addresses = {}

def loadAddresses():
    global addresses
    with open(addressData,'r') as f:
        addresses = json.load(f)
    print(addresses)

def getAddress(message,len):
    person = message.content[len+4:-1]
    print(person)
    try:
        return(addresses[person])
    except:
        return("invalid person")
        print(addresses[person])


with open(iceData,'r') as f:
    iceCount = json.load(f)

loadAddresses()

@client.event
async def on_ready():
    print('We have logged in as {0.user}'.format(client))

@client.event
async def on_message(message):
    if message.author == client.user:
        return

    if message.content == "!supply":        
        await message.channel.send(c.getSupply()/10**18)

    if message.content.startswith("!balance"):
        address = message.content[9:]
        if not address.startswith('0x'):
            address = getAddress(message,8)
        try:
            await message.channel.send(c.getBalance(address)/10**18)
        except:
            print(sys.exc_info())
            await message.channel.send("Invalid address :(")



    if "ice" in message.content:
        author = str(message.author)
        if(author in iceCount):
            iceCount[author] = iceCount[author] + 1
        else:
            iceCount[author] = 1
        
        try:
            await message.channel.send(author[:-5]+". You how have: "+str(iceCount[author])+" ice")
        except:
            pass
        with open(iceData, 'w') as f:
            json.dump(iceCount,f)

    if message.content.startswith('!setAddress'):
        author = str(message.author.id)
        address = str(message.content[12:])

        addresses[author] = address
        await message.channel.send("address set for "+str(message.author)+" as: "+address)

        with open(addressData, 'w') as f:
            json.dump(addresses,f)

        loadAddresses()
    if message.content.startswith('!getAddress'):
        await message.channel.send(getAddress(message,11))
client.run(TOKEN)
