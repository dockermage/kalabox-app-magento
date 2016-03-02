'use strict';

module.exports = function(kbox) {

  kbox.whenAppRegistered(function(app) {

    // kbox services
    kbox.tasks.add(function(task) {

      // Task metadata
      task.path = [app.name, 'services'];
      task.category = 'appAction';
      task.description = 'Display connection info for services.';
      task.func = function(done) {

        // Node modules
        var path = require('path');

        // NPM mods
        var _ = require('lodash');

        // Kalabox modules
        var Promise = kbox.Promise;

        // Get our config info
        var config = kbox.util.yaml.toJson(path.join(app.root, 'kalabox.yml'));

        /*
         * Helper to parse services data into urls
         */
        var getServiceUrls = function(services) {

          return _.map(services, function(service) {

            // Get protocol
            var protocol = (service.secure) ? 'https://' : 'http://';

            // Get subdomain
            var sub = (service.hostname) ? service.hostname + '.' : '';

            // Get domain
            var domain = sub + app.hostname;

            // Return the urls
            return protocol + domain;

          });

        };

        /*
         * Helper to generate a summary from inspect data
         * @todo: maybe some more info here or an easier place to get it?
         */
        var getServiceSummary = function(container) {

          // Inspect the container
          return kbox.engine.inspect(container)

          // Return summary of info
          .then(function(data) {

            // Get service name =
            var name = data.Config.Labels['com.docker.compose.service'];
            var project = data.Config.Labels['com.docker.compose.project'];

            // Defaults
            var serviceSummary = {
              name: name,
              project: project
            };

            // See if these are proxied services
            var proxied = _.find(
              config.pluginconfig.services,
              function(data, key) {return key === name;}
            );
            if (!_.isEmpty(proxied)) {
              serviceSummary.url = getServiceUrls(proxied);
            }

            // Add in database credentials
            // @todo: get engine ip from provider.getIp()
            if (name === 'db') {

              // Get port from inspect data
              var portInfo = _.get(data, 'NetworkSettings.Ports.3306/tcp');

              // Build a creds array
              serviceSummary.credentials = {
                database: 'drupal',
                user: 'drupal',
                password: 'drupal',
                host: '10.13.37.100',
                port: portInfo[0].HostPort
              };
            }

            return serviceSummary;

          });

        };

        /*
         * Helper to get connection info about our services
         */
        var getServicesInfo = function() {

          // Check if our engine is up
          return kbox.engine.isUp()

          // If we are up check for containers running for an app
          // otherwise return false
          .then(function(isUp) {

            // Engine is up so lets check if the app has running containers
            if (isUp) {

              // Get list of containers
              return kbox.engine.list(app.name)

              // Return running containers
              .filter(function(container) {
                return kbox.engine.isRunning(container.id);
              });

            }

            // Engine is down so nothing can be running
            else {
              return {};
            }

          })

          // Generate information about services if we can
          .then(function(runningServices) {
            if (_.isEmpty(runningServices)) {
              return false;
            }
            else {
              return Promise.map(runningServices, function(service) {
                return getServiceSummary(service);
              });
            }
          });

        };

        // Get our services info
        return getServicesInfo()

        // And then print it
        .then(function(info) {
          if (info) {
            console.log(JSON.stringify(info, null, 2));
          }
          else {
            return kbox.core.log.warn('App is not running');
          }
        })

        // Finish
        .nodeify(done);

      };
    });

  });

};
