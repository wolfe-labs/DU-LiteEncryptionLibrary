--[[
  -- Lite Encryption Library
  -- A very basic and potentially unsafe way to cypher stuff inside Dual Universe
  -- Use at your own risk!
]]

local b64 = require('util/b64')
local json = require('util/dkjson')

--[[
 -- IMPORTANT DISCLAIMER:
 -- The code below is NOT INTENDED to be a real crypto algorithm.
 -- It's only purpose is to have **some** safety when validating someone's ID in-game and on the website.
 -- This will be pretty much useless if someday we can do HTTP requests straight out of Lua.
 ]]--

local exports = {}

local function makeStreamKey (stream, secretRaw)
  -- This is our secret's byte array
  local secret = secretRaw

  -- Makes sure secret is a byte array
  if not ('table' == type(secretRaw)) then
    -- First convert it to a string and reset secret into an table
    secretRaw = tostring(secretRaw)
    secret = {}

    -- Now convert to bytes
    for i = 1, #secretRaw do
      table.insert(secret, secretRaw:sub(i, i):byte())
    end
  end

  -- We'll be outputting an array of bytes here
  local output = {}

  -- Processes the stream
  for i = 0, #stream do
    local index = 1 + (i % #secret)
    local byte0 = secret[index]
    local byte1 = secret[#secret + 1 - index]
    table.insert(output, (byte0 ~ byte1) % 256)
  end

  -- Done!
  return output
end

function exports.stringToBytes (str)
  local chars = tostring(str)
  local buffer = {}
  for i = 1, string.len(chars) do
    table.insert(buffer, chars:sub(i, i):byte())
  end
  return buffer
end

function exports.stringFromBytes (bytes)
  local buffer = ''
  for i = 1, #bytes do
    buffer = buffer .. string.char(bytes[i])
  end
  return buffer
end

function exports.encryptBytes (info, secret)  
  -- Gets the prepared stream key
  local key = makeStreamKey(info, secret)

  -- Does the first round, the XOR
  local round1 = {}
  for i = 1, #info do
    table.insert(round1, info[i] ~ key[#round1 + 1])
  end

  --Does the second round, the bit shifting
  local round2 = {}
  for i = 1, #round1 do
    -- Gets the byte value
    local byte = round1[i]

    -- Gets shift amount
    local amount = key[i] % 8

    -- Again, if the shift is 0, make it 4
    if 0 == amount then
      amount = 4
    end

    -- Breakdown the byte into high and low parts
    local high = byte >> amount
    local low = byte % (2 ^ amount)

    -- Combines both values into the result
    local result = (low << (8 - amount)) + high

    -- Done!
    table.insert(round2, result)
  end

  -- Done!
  return round2
end

function exports.decryptBytes (cypher, secret)
  -- Gets the prepared stream key
  local key = makeStreamKey(cypher, secret)

  -- In the first round, we reverse the bit shifting step
  local round1 = {}
  for i = 1, #cypher do
    -- Gets the byte and the shift amount
    local byte = cypher[i]
    local amount = key[i] % 8

    -- If shift amount is 0, consider it 4!
    if 0 == amount then
      amount = 4
    end

    -- Gets the "high" and "low" parts of the byte, separated at "amount"
    local high = byte % (2 ^ (8 - amount))
    local low = byte >> (8 - amount) % 8

    -- Gets the new value
    local result = ((high << amount) + low) % 256

    -- Done!
    table.insert(round1, result)
  end

  -- In the second round, we do a XOR to decode the bytes
  local round2 = {}
  for i = 1, #round1 do
    table.insert(round2, round1[i] ~ key[#round2 + 1])
  end

  -- Done!
  return round2
end

function exports.encrypt (info, secret)
  return exports.stringFromBytes(exports.encryptBytes(exports.stringToBytes(info)), secret)
end

function exports.encrypt64 (info, secret)
  return b64.encode(exports.encrypt(info, secret))
end

function exports.decrypt (info, secret)
  return exports.stringFromBytes(exports.decryptBytes(exports.stringToBytes(info)), secret)
end

function exports.decrypt64 (info, secret)
  return exports.decrypt(b64.decode(info), secret)
end

-- Exports the class
return exports