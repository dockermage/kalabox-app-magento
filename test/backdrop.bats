#!/usr/bin/env bats

#
# Basic tests to verify Backdrop creates
#
# NOTE: Let's not use any `kbox` commands here if we can. This way
# we aren't getting failed tests because the kbox part of the commands are
# failing vs the actual passed through commands aka
#
# BAD   : $KBOX mysql -e 'SHOW TABLES;' pantheon
# GOOD  : $DOCKER exec ${PHP_BACKDROP_NAME}_appserver_1 mysql -e 'SHOW TABLES;' pantheon

# Load up environment
load env

#
# Setup some things
#
# Create a directory to put our test builds
#
setup() {

  # Make sure we have a clean dir
  mkdir -p "$KBOX_APP_DIR"

  # Versions to check
  BACKDRUSH_VERSION="This command is not supported yet by Backdrop."
  BOWER_VERSION=1.
  COMPOSER_VERSION=1.
  GIT_VERSION=2.
  GRUNT_VERSION=1.
  GULP_VERSION=1.
  MYSQL_CLIENT_VERSION=14.
  NODE_VERSION=4.
  NPM_VERSION=2.
  PHP_VERSION=7.
  RSYNC_VERSION=3.1

  # We need to actually go into this app dir until
  # https://github.com/kalabox/kalabox/issues/1221
  # is resolved
  if [ -d "$KBOX_APP_DIR/$PHP_BACKDROP_NAME" ]; then
    cd $KBOX_APP_DIR/$PHP_BACKDROP_NAME
  fi

}

#
# Create tests
#

# Create a drupal7 site
@test "Create a Backdrop site without an error." {

  # Check to see if our site exists already
  Backdrop_SITE_EXISTS=$("$KBOX" list | grep "$PHP_BACKDROP_NAME" > /dev/null && echo $? || true)

  # Run the create command if our site doesn't already exist
  if [ ! $Backdrop_SITE_EXISTS ]; then

    # Create a Backdrop site
    run $KBOX create backdrop \
      -- \
      --name $PHP_BACKDROP_NAME \
      --dir $KBOX_APP_DIR \
      --from $TRAVIS_BUILD_DIR/app

    # Check status code
    [ "$status" -eq 0 ]

  # We already have what we need so lets skip
  else
    skip "Looks like we already have a Backdrop site ready to go!"
  fi

}

#
# Verify that services are all in the correct state
#

#
# Check that the data container exists and is in the correct state.
#
@test "Check that the data container exists and is in the correct state." {
  $DOCKER inspect ${PHP_BACKDROP_NAME}_data_1 | grep "\"Status\": \"exited\""
}

#
# Check that the terminus container exists and is in the correct state.
#
@test "Check that the cli container exists and is in the correct state." {
  $DOCKER inspect ${PHP_BACKDROP_NAME}_cli_1 | grep "\"Status\": \"exited\""
}

#
# Check that the terminus container exists and is in the correct state.
#
@test "Check that the drush container exists and is in the correct state." {
  $DOCKER inspect ${PHP_BACKDROP_NAME}_drush_1 | grep "\"Status\": \"exited\""
}

#
# Check that the appserver container exists and is in the correct state.
#
@test "Check that the appserver container exists and is in the correct state." {
  $DOCKER inspect ${PHP_BACKDROP_NAME}_appserver_1 | grep "\"Status\": \"running\""
}

#
# Check that the db container exists and is in the correct state.
#
@test "Check that the db container exists and is in the correct state." {
  $DOCKER inspect ${PHP_BACKDROP_NAME}_db_1 | grep "\"Status\": \"running\""
}

#
# Verify some basic things about the install
#

#
# Check that we have a git repo and its in a good spot
#
@test "Check that site shows up in $KBOX list with correct properties" {

  # Grep a bunch of things
  $KBOX list | grep "\"name\": \"$PHP_BACKDROP_NAME\""
  $KBOX list | grep "\"url\": \"http://${PHP_BACKDROP_NAME}.kbox\""
  $KBOX list | grep "\"type\": \"php\""
  $KBOX list | grep "\"location\": \"${KBOX_APP_DIR}/${PHP_BACKDROP_NAME}\""
  $KBOX list | grep "\"running\": true"

}

#
# Check that we have drupal code.
#
@test "Check that we have drupal code." {
  cd $KBOX_APP_DIR/$PHP_BACKDROP_NAME/code
  stat ./index.php
}

#
# Check that we have the correct DNS entry
#
@test "Check that we have the correct DNS entry." {
  $DOCKER exec kalabox_proxy_1 redis-cli -p 8160 lrange frontend:http://${PHP_BACKDROP_NAME}.kbox 0 5
}

#
# Basic non-interactive action verification
#
#   config           Display the kbox application's configuration.
#   restart          Stop and then start a running kbox application.
#   services         Display connection info for services.
#   start            Start an installed kbox application.
#   stop             Stop a running kbox application.
#

#
# Run `kbox config`
#
@test "Check that we can run '$KBOX config' without an error." {
  $KBOX $PHP_BACKDROP_NAME config
}

#
# Run `kbox stop`
#
@test "Check that we can run '$KBOX stop' without an error." {
  $KBOX $PHP_BACKDROP_NAME stop
}

#
# Run `kbox start`
#
@test "Check that we can run '$KBOX start' without an error." {
  $KBOX $PHP_BACKDROP_NAME start
}

#
# Run `kbox restart`
#
@test "Check that we can run '$KBOX restart' without an error." {
  $KBOX $PHP_BACKDROP_NAME restart
}

#
# Run `kbox services`
#
@test "Check that we can run '$KBOX services' without an error." {
  $KBOX $PHP_BACKDROP_NAME services
}


#
# Command sanity checks
#
#  bower            Run a bower command
#  composer         Run a composer cli command
#  drush            Run a drush 8 command on your codebase
#  git              Run a git command on your codebase
#  grunt            Run a grunt command
#  gulp             Run a gulp command
#  mysql            Drop into a mysql shell
#  node             Run a node command
#  npm              Run a npm command
#  php              Run a php cli command
#  rsync            Run a rsync command on your files directory
#

#
# BOWER
#
@test "Check that '$KBOX bower' returns the correct major version without an error." {
  run $KBOX bower --version
  [ "$status" -eq 0 ]
  [[ $output == *"$BOWER_VERSION"* ]]
}

#
# COMPOSER
#
@test "Check that '$KBOX composer' returns the correct major version without an error." {
  run $KBOX composer --version
  [ "$status" -eq 0 ]
  [[ $output == *"$COMPOSER_VERSION"* ]]
}

#
# DRUSH
#
@test "Check that '$KBOX drush' returns the correct major version without an error." {
  run $KBOX drush --version
  [ "$status" -eq 0 ]
  [[ $output == *"$BACKDRUSH_VERSION"* ]]
}

#
# GIT
#
@test "Check that '$KBOX git' returns the correct major version without an error." {
  run $KBOX git --version
  [ "$status" -eq 0 ]
  [[ $output == *"$GIT_VERSION"* ]]
}

#
# GRUNT
#
@test "Check that '$KBOX grunt' returns the correct major version without an error." {
  run $KBOX grunt --version
  [ "$status" -eq 0 ]
  [[ $output == *"$GRUNT_VERSION"* ]]
}

#
# GULP
#
@test "Check that '$KBOX gulp' returns the correct major version without an error." {
  run $KBOX gulp --version
  [ "$status" -eq 0 ]
  [[ $output == *"$GULP_VERSION"* ]]
}

#
# MYSQL
#
@test "Check that '$KBOX mysql' returns the correct major version without an error." {
  run $KBOX mysql --version
  [ "$status" -eq 0 ]
  [[ $output == *"$MYSQL_CLIENT_VERSION"* ]]
}

#
# NODE
#
@test "Check that '$KBOX node' returns the correct major version without an error." {
  run $KBOX node --version
  [ "$status" -eq 0 ]
  [[ $output == *"$NODE_VERSION"* ]]
}

#
# NPM
#
@test "Check that '$KBOX npm' returns the correct major version without an error." {
  run $KBOX npm --version
  [ "$status" -eq 0 ]
  [[ $output == *"$NPM_VERSION"* ]]
}

#
# PHP
#
@test "Check that '$KBOX php' returns the correct major version without an error." {
  run $KBOX php --version
  [ "$status" -eq 0 ]
  [[ $output == *"$PHP_VERSION"* ]]
}

#
# RSYNC
#
@test "Check that '$KBOX rsync' returns the correct major version without an error." {
  run $KBOX rsync --version
  [ "$status" -eq 0 ]
  [[ $output == *"$RSYNC_VERSION"* ]]
}

#
# Basic destroy action verification
#

#
# Run `kbox rebuild`
#
@test "Check that we can run '$KBOX rebuild' without an error." {
  $KBOX $PHP_BACKDROP_NAME rebuild
}

#
# Run `kbox destroy`
#
@test "Check that we can run '$KBOX destroy' without an error." {
  $KBOX $PHP_BACKDROP_NAME destroy -- -y
}

#
# BURN IT TO THE GROUND!!!!
#
teardown() {
  sleep 1
}
