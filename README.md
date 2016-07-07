# Heroku Buildpack for EJSON [![CircleCI](https://circleci.com/gh/Shopify/heroku-buildpack-ejson/tree/master.svg?style=shield&circle-token=2b541d71a955da8094b3e09ffe62ce0061e4ac8d)](https://circleci.com/gh/Shopify/heroku-buildpack-ejson/tree/master)

This is a [Heroku Buildback](http://devcenter.heroku.com/articles/buildpacks) that automates the decryption of [EJSON](https://github.com/Shopify/ejson) secrets on deploy.
It uses the keypair specified by the Heroku environment variables `EJSON_PUBLIC_KEY` and `EJSON_PRIVATE_KEY` to decrypt every `ejson` file in the given repo
(decrypting, for instance, the encrypted file `/foo/bar.ejson` into `/foo/bar.json`).
