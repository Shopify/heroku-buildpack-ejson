# Heroku Buildpack for EJSON [![Circle CI](https://circleci.com/gh/Shopify/heroku-buildpack-ejson.svg?style=shield&circle-token=a7492758934077f0e7dec1746a75c18149b4a8c1)](https://circleci.com/gh/Shopify/heroku-buildpack-ejson)

This is a [Heroku Buildback](http://devcenter.heroku.com/articles/buildpacks) that automates the decryption of [EJSON](https://github.com/Shopify/ejson) secrets on deploy.
It uses the keypair specified by the Heroku environment variables `EJSON_PUBLIC_KEY` and `EJSON_PRIVATE_KEY` to decrypt every `ejson` file in the given repo
(decrypting, for instance, the encrypted file `/foo/bar.ejson` into `/foo/bar.json`).
