
'use strict';

module.exports = function(kbox, frameworks) {

  // Npm modulez
  var _ = require('lodash');

  // Add options for each framework
  _.forEach(frameworks, function(framework) {

    // Allow user to specify a name
    kbox.create.add(framework, {
      option: {
        name: 'name',
        weight: -75,
        task: {
          kind: 'string',
          description: 'The name of your app.',
        },
        inquire: {
          type: 'input',
          message: 'What will you call this monster you have created',
          validate: function(value) {
            var domain = kbox.core.deps.get('globalConfig').domain;
            var kebabMe = kbox.util.domain.modKebabCase(value);
            return kbox.util.domain.validateDomain([kebabMe, domain].join('.'));
          },
          filter: function(value) {
            if (value) {
              return kbox.util.domain.modKebabCase(value);
            }
          },
          default: function(answers) {
            var options = kbox.core.deps.get('argv').options;
            return options.site || answers.site || 'Magento Store';
          }
        },
        conf: {
          type: 'global'
        }
      }
    });

    // Allow user to specify an optional version
    kbox.create.add(framework, {
      option: {
        name: 'version',
        weight: -55,
        task: {
          kind: 'string',
          description: 'The Magento version you want to install (leave empty to bring your own code).',
        },
        inquire: {
          type: 'input',
          message: 'What Magento version do you want (leave empty to bring your own code)',
          choices: function() {
            return [
              '',
              '1.9.2.4',
              '1.7.0.0'
            ];
          },
          default: function(answers) {
            return '';
          }
        },
        conf: {
          type: 'global'
        }
      }
    });

  });

};
