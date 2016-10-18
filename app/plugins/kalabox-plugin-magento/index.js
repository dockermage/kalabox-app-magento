  'use strict';

  module.exports = function(kbox, app) {
    // Load events
    kbox.create.add('magento', {
      option: {
        name: 'name',
        weight: -99,
        task: {
          kind: 'string',
          description: 'The name of your app.',
        },
        inquire: {
          type: 'input',
          message: 'What will this app be called',
          validate: function(value) {
            // @todo some actual validation here
            return true;
          },
          filter: function(value) {
            return _.kebabCase(value);
          },
          default: 'My Magento'
        },
        conf: {
          type: 'global',
          key: 'appName'
        }
      }
    });

    require('./lib/events.js')(kbox, app);
    // Load the integrations
    //require('./lib/integrations.js')(kbox);
  };
