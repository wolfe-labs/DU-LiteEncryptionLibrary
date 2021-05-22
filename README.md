# Lite Encryption Library: Don't Roll Your Own Crypto

This is a very basic implementation of a cypher algorithm for use inside Dual Universe scripts.

**This is not suitable for any real-world usage!**

## Installation & Usage

You can install this in your project using [DU-Lua](https://github.com/wolfe-labs/DU-LuaC)'s CLI by running `du-lua import https://github.com/wolfe-labs/DU-LiteEncryptionLibrary` and then importing into your script by adding the line `local LCrypt = require('@wolfe-labs/LiteEncryptionLibrary:lib')` in the top of your file.

The library offers 3 pairs of encryption/decryption functions:

- `LCrypt.encrypt` and `LCrypt.decrypt` will work with raw strings and will potentially include invalid characters. Optimal for storage in DataBanks.
- `LCrypt.encrypt64` and `LCrypt.decrypt64` will work with base64 strings which can be safely printed and passed around. Optimal for user input and output.
- `LCrypt.encryptBytes` and `LCrypt.decryptBytes` are the most basic and will receive and return data as a byte array. Optimal for internal usage on script.

The arguments follow the same order, with the first argument being the input plaintext/cyphertext and the second argument being the secret key, which can be passed either as string or byte array.

## Demos

You can try the script out by cloning this repository and running `du-lua build` to compile for development and then running either `lua out/development/test/encrypt.lua` or `lua out/development/test/decrypt.lua` to play with encryption/decryption.
The demos use the base64 version of the functions for ease of use.