local LCrypt = require('@wolfe-labs/LiteEncryptionLibrary:lib')

print('Please type your secret key:')
io.flush()
local secret = io.read()

print('Please type your message:')
io.flush()
local message = io.read()

local cyphertext = LCrypt.encrypt64(message, secret)
print('----------------------------');
print(cyphertext)