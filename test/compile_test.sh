#!/bin/bash

. "$BUILDPACK_TEST_RUNNER_HOME/lib/test_utils".sh
TMPDIR=$(mktemp -d)

cleanup() {
  rm -r $TMPDIR
}
trap cleanup EXIT

compile_with_fixture() {
  FIXTURE_DIR="$BUILDPACK_HOME/test/fixtures/$1"
  rm -r "$TMPDIR/build" "$TMPDIR/env" "$TMPDIR/cache" 2>/dev/null || true
  cp -r "$FIXTURE_DIR/build" $TMPDIR 2>/dev/null || mkdir "$TMPDIR/build"
  cp -r "$FIXTURE_DIR/cache" $TMPDIR 2>/dev/null || mkdir "$TMPDIR/cache"
  cp -r "$FIXTURE_DIR/env" $TMPDIR 2>/dev/null || mkdir "$TMPDIR/env"
  capture "$BUILDPACK_HOME/bin/compile" "$TMPDIR/build" "$TMPDIR/cache" "$TMPDIR/env"
}

test_simple() {
  compile_with_fixture simple
  assertCapturedSuccess
  assertCaptured "Installing ejson"
  assertCaptured "Loading keypair from environment variables"
  assertCaptured "Enumerating and decrypting *.ejson files"
  assertCaptured "Done. Successfully decrypted 1 different ejson file(s)"
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
  assertCaptured "Decryption failed: couldn't read key file"
}
