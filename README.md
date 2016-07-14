# Heroku Buildpack for EJSON [![CircleCI](https://circleci.com/gh/Shopify/heroku-buildpack-ejson/tree/master.svg?style=shield)](https://circleci.com/gh/Shopify/heroku-buildpack-ejson/tree/master)

This is a [Heroku Buildback](http://devcenter.heroku.com/articles/buildpacks) that automates the decryption of [EJSON](https://github.com/Shopify/ejson) secrets on deploy.

## Keys

EJSON files are encrypted via a public-key cryptography scheme, the intention being that the non-secret public key
can safely be stored on developer machines and in source control, whereas the sensitive private key can be scoped
only to production infrastructure.

To generate an EJSON keypair, run `ejson keygen`. The public key returned should be used in your project's `.ejson` files
(by setting the `_public_key` attribute on the top level object and running `ejson encrypt`).
Then, having set `EJSON_PUBLIC_KEY` and `EJSON_PRIVATE_KEY` appropriately in your Heroku app's environment,
`heroku-buildpack-ejson` will be able to decrypt your `.ejson` files on deploy.

## Environments

The buildpack has a notion of environments, for instance to distinguish between `production` and `staging` secret configuration.
The environment is controlled via the Heroku environment variable `EJSON_ENVIRONMENT`.

If `EJSON_ENVIRONMENT` is blank or unset, then by default the buildpack will attempt to decrypt all `.ejson` files, excluding
those with a compound extensions specifying the environment (like `.production.ejson`). For example, in this case
`config/secrets.ejson` would be decrypted on deploy into `config/secrets.json`, but `config/secrets.staging.ejson`
would be left untouched.

If `EJSON_ENVIRONMENT` is set, then the buildpack will exclusively decrypt files with a compound extension of the form
`.$EJSON_ENVIRONMENT.ejson`. For instance, suppose `EJSON_ENVIRONMENT=production`. Then, `config/secrets.production.ejson`
would be decrypted into `config/secrets.json`, but `config/secrets.staging.ejson` and `config/other_secrets.ejson` would
be left untouched.

This scheme is intended to eliminate credential reuse. The intention is that each individual Heroku app is configured with
its own unique keypair; in particular, a `staging` app and a `production` app deployed from the same codebase should not
need to share.

Additionally, this strategy allows your app to be agnostic about its environment, with respect to configuration.
Suppose you commit a `secrets.json` for development use, a `secrets.staging.ejson` for a staging app,
and a `secrets.produciton.ejson` containing production credentials. Then, your app can read its configuration unconditionally
from `secrets.json`; in development it will read the original development credentials, and in production or staging
`secrets.json` will have been overwritten with whichever credential set was appropriate.
