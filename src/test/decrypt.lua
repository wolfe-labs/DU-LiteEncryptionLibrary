local LCrypt = require('@wolfe-labs/LiteEncryptionLibrary:lib')

print('Please type your secret key:')
io.flush()
local secret = io.read()

print('Please type your cyphertext:')
io.flush()
local cyphertext = io.read()

local message = LCrypt.decrypt64(cyphertext, secret)
print('----------------------------');
print(message)