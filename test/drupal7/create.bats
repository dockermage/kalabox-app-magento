#!/usr/bin/env bats

#
# Basic tests to verify Drupal 7 creates
#
# NOTE: Let's not use any `kbox` commands here if we can. This way
# we aren't getting failed tests because the kbox part of the commands are
# failing vs the actual passed through commands aka
#
# BAD   : $KBOX mysql -e 'SHOW TABLES;' pantheon
# GOOD  : $DOCKER exec ${PHP_DRUPAL7_NAME}_appserver_1 mysql -e 'SHOW TABLES;' pantheon

# Load up environment
load ../env

# Check to see if our site exists already
EXISTS=$("$KBOX" list | grep "$PHP_DRUPAL7_NAME" > /dev/null && echo $? || true)

#
# Setup some things
#
# Create a directory to put our test builds
#
setup() {
  mkdir -p "$KBOX_APP_DIR"
}

#
# Create tests
#

# Create a drupal7 site
@test "Create a Drupal 7 site without an error." {

  # Run the create command if our site doesn't already exist
  if [ ! $EXISTS ]; then

    # Create a drupal 7 site
    run $KBOX create drupal7 \
      -- \
      --name $PHP_DRUPAL7_NAME \
      --dir $KBOX_APP_DIR \
      --from $TRAVIS_BUILD_DIR/app

    # Check status code
    [ "$status" -eq 0 ]

  # We already have what we need so lets skip
  else
    skip "Looks like we already have a D7 site ready to go!"
  fi

}

#
# Verify that services are all in the correct state
#

# Check that the data container exists and is in the correct state.
@test "Check that the data container exists and is in the correct state." {
  $DOCKER inspect ${PHP_DRUPAL7_NAME}_data_1 | grep "\"Status\": \"exited\""
}

# Check that the terminus container exists and is in the correct state.
@test "Check that the cli container exists and is in the correct state." {
  $DOCKER inspect ${PHP_DRUPAL7_NAME}_cli_1 | grep "\"Status\": \"exited\""
}

# Check that the terminus container exists and is in the correct state.
@test "Check that the drush container exists and is in the correct state." {
  $DOCKER inspect ${PHP_DRUPAL7_NAME}_drush_1 | grep "\"Status\": \"exited\""
}

# Check that the appserver container exists and is in the correct state.
@test "Check that the appserver container exists and is in the correct state." {
  $DOCKER inspect ${PHP_DRUPAL7_NAME}_appserver_1 | grep "\"Status\": \"running\""
}

# Check that the db container exists and is in the correct state.
@test "Check that the db container exists and is in the correct state." {
  $DOCKER inspect ${PHP_DRUPAL7_NAME}_db_1 | grep "\"Status\": \"running\""
}

#
# Verify some basic things about the install
#

# Check that we have a git repo and its in a good spot
@test "Check that site shows up in $KBOX list with correct properties" {

  # Grep a bunch of things
  $KBOX list | grep "\"name\": \"$PHP_DRUPAL7_NAME\""
  $KBOX list | grep "\"url\": \"http://${PHP_DRUPAL7_NAME}.kbox\""
  $KBOX list | grep "\"type\": \"php\""
  $KBOX list | grep "\"version\": \"0.12\""
  $KBOX list | grep "\"location\": \"${KBOX_APP_DIR}/${PHP_DRUPAL7_NAME}\""
  $KBOX list | grep "\"running\": true"

}

# Check that we have drupal code.
@test "Check that we have drupal code." {
  cd $KBOX_APP_DIR/$PHP_DRUPAL7_NAME/code
  stat ./index.php
}

# Check that we have the correct DNS entry
@test "Check that we have the correct DNS entry." {
  $DOCKER exec kalabox_proxy_1 redis-cli -p 8160 lrange frontend:http://${PHP_DRUPAL7_NAME}.kbox 0 5 | grep 10.13.37.100
}

#
# BURN IT TO THE GROUND!!!!
#
teardown() {
  echo;
  #$KBOX $PHP_DRUPAL7_NAME destroy -- -y
  #rm -rf $KBOX_APP_DIR
}