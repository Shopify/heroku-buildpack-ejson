#!/bin/bash

. "$BUILDPACK_TEST_RUNNER_HOME/lib/test_utils".sh
export BUNDLE_GEMFILE="$BUILDPACK_HOME/Gemfile"

compile_with_fixture() {
  TMPDIR=$(mktemp -d)
  FIXTURE_DIR="$BUILDPACK_HOME/test/fixtures/$1"
  rm -r "$TMPDIR/build" "$TMPDIR/env" "$TMPDIR/cache" 2>/dev/null || true
  cp -r "$FIXTURE_DIR/build" $TMPDIR 2>/dev/null || mkdir "$TMPDIR/build"
  cp -r "$FIXTURE_DIR/cache" $TMPDIR 2>/dev/null || mkdir "$TMPDIR/cache"
  cp -r "$FIXTURE_DIR/env" $TMPDIR 2>/dev/null || mkdir "$TMPDIR/env"
  capture "$BUILDPACK_HOME/bin/compile" "$TMPDIR/build" "$TMPDIR/cache" "$TMPDIR/env"
  rm -r "$TMPDIR"
}

test_simple() {
  compile_with_fixture simple
  assertCapturedSuccess
  assertCaptured "Installing ejson"
  assertCaptured "Loading keypair from environment variables"
  assertCaptured 'EJSON_ENVIRONMENT is undefined or empty; enumerating and decrypting EJSON files of the form `*.ejson`'
  assertCaptured "Decrypting config.ejson --> config.json"
  assertCaptured "Done. Decrypted 1 different ejson file(s)"
}

test_missing_public_key() {
  compile_with_fixture missing_public_key
  assertCapturedError
  assertCaptured "Loading keypair from environment variables"
  assertCaptured 'EJSON_PUBLIC_KEY is undefined; make sure EJSON_PUBLIC_KEY and EJSON_PRIVATE_KEY are set (try `ejson keygen`)'
}

test_missing_private_key() {
  compile_with_fixture missing_private_key
  assertCapturedError
  assertCaptured "Loading keypair from environment variables"
  assertCaptured 'EJSON_PRIVATE_KEY is undefined; make sure EJSON_PUBLIC_KEY and EJSON_PRIVATE_KEY are set (try `ejson keygen`)'
}

test_bad_keypair() {
  compile_with_fixture bad_keypair
  assertCapturedError
  assertCaptured "Loading keypair from environment variables"
  assertCaptured "config.ejson: Decryption failed: couldn't read key file"
}

test_deeply_nested() {
  compile_with_fixture deeply_nested
  assertCapturedSuccess
  assertCaptured "Decrypting foo/bar/baz/launch_codes.ejson --> foo/bar/baz/launch_codes.json"
  assertCaptured "Done. Decrypted 1 different ejson file(s)"
}

test_many() {
  compile_with_fixture many
  assertCapturedSuccess
  assertCaptured "Decrypting foo0.ejson --> foo0.json"
  assertCaptured "Decrypting foo1.ejson --> foo1.json"
  assertCaptured "Decrypting foo2.ejson --> foo2.json"
  assertCaptured "Decrypting foo3.ejson --> foo3.json"
  assertCaptured "Decrypting foo4.ejson --> foo4.json"
  assertCaptured "Done. Decrypted 5 different ejson file(s)"
}

test_environment_set() {
  compile_with_fixture environment_set
  assertCapturedSuccess
  assertCaptured 'EJSON_ENVIRONMENT is `production`; enumerating and decrypting EJSON files of the form `*.production.ejson`'
  assertCaptured 'Decrypting config.production.ejson --> config.json'
  assertCaptured 'Done. Decrypted 1 different ejson file(s)'
}

test_environment_unset() {
  compile_with_fixture environment_unset
  assertCapturedSuccess
  assertCaptured 'EJSON_ENVIRONMENT is undefined or empty; enumerating and decrypting EJSON files of the form `*.ejson`'
  assertCaptured "Decrypting config.ejson --> config.json"
  assertCaptured "Done. Decrypted 1 different ejson file(s)"
}

test_overwrite() {
  compile_with_fixture overwrite
  assertCapturedSuccess
  assertCaptured 'EJSON_ENVIRONMENT is `production`; enumerating and decrypting EJSON files of the form `*.production.ejson`'
  assertCaptured 'Decrypting config.production.ejson --> config.json [overwriting existing file]'
}

test_overwrite_directory() {
  compile_with_fixture overwrite_directory
  assertCapturedError
  assertCaptured 'EJSON_ENVIRONMENT is `production`; enumerating and decrypting EJSON files of the form `*.production.ejson`'
  assertCaptured 'config.json: already exists but is not a regular file'
}
