#!/usr/bin/env bats

#
# Basic tests to verify basic Backdrop app actions
#

# Load up environment
load ../env

#
# Setup some things
#
setup() {
  # Create a directory to put our test builds
  mkdir -p "$KBOX_APP_DIR"
}

#
# Basic destroy action verification
#
@test "Check that we can run '$KBOX rebuild' without an error." {
  $KBOX $PHP_BACKDROP_NAME rebuild
}
@test "Check that the app's directory exists before destroy is run." {
  if [ ! -d "$KBOX_APP_DIR/$PHP_BACKDROP_NAME" ]; then
    run foo
    [ "$status" -eq 0 ]
  else
    skip "OK"
  fi
}
@test "Check that we can run '$KBOX destroy' without an error." {
  $KBOX $PHP_BACKDROP_NAME destroy -- -y
}
@test "Check that the app's directory was removed." {
  if [ -d "$KBOX_APP_DIR/$PHP_BACKDROP_NAME" ]; then
    run foo
    [ "$status" -eq 0 ]
  else
    skip "OK"
  fi
}

#
# BURN IT TO THE GROUND!!!!
#
teardown() {
  echo;
  #$KBOX $PHP_BACKDROP_NAME destroy -- -y
  #rm -rf $KBOX_APP_DIR
}
