
'use strict';

module.exports = function(kbox) {

  // NPM modules
  var _ = require('lodash');

  /*
   * Add some other important things to our kalabox.yml before
   * configin it
   */
  kbox.core.events.on('pre-create-configure', function(data) {

    // Grab the config from teh data
    var config = data.config;
    var results = data.results;
    var pkg = data.pkg;

    /*
     * Returns the filemount based on the framework
     */
    var getFilemount = function(framework) {
      switch (framework) {
        case 'magento1': return 'media';
        case 'magento2': return 'media';
      }
    };

    // Only run if this is a php app
    if (config.type === 'php') {

      // Get the created app type
      var created = results._type;

      // Get the framework and version in various ways
      // For magento 1
      if (created === 'magento1') {
        config.pluginconfig.php.framework = 'magento1';
        config.pluginconfig.php.version = results.version;
        config.pluginconfig.php.filemount = getFilemount(
          config.pluginconfig.php.framework
        );
        config.pluginconfig.php.image = [
          'dockermage/' + config.pluginconfig.php.framework,
          config.pluginconfig.php.version
        ].join(':');
      }

      // For mage2
      else if (created === 'magento2') {
        config.pluginconfig.php.framework = 'magento2';
        config.pluginconfig.php.version = results.version;
        config.pluginconfig.php.filemount = getFilemount(
          config.pluginconfig.php.framework
        );
        config.pluginconfig.php.image = 'mageinferno/magento2-nginx:1.10.1-0';
      }

      // Get the filemount from the framework and add it to our list of ignores
      // NOTE: on Pantheon apps the filemount should be a symlink ie "Name"
      // not "Path"
      var filemount = config.pluginconfig.php.filemount;
      var ignores = config.pluginconfig.sharing.ignore || [];
      ignores.push('Name ' + filemount);
      config.pluginconfig.sharing.ignore = ignores;

      // Set the version
      config.version = pkg.version;

    }

  });

};
