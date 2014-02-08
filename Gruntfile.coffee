###
 * grunt-deploy-keys
 * https://github.com/cray0000/grunt-deploy-keys
 *
 * Copyright (c) 2014 Pavel Zhukov
 * Licensed under the MIT license.
###

module.exports = (grunt) ->
  grunt.initConfig
    jshint:
      all: [
        'Gruntfile.js'
        'tasks/*.js'
        '<%= nodeunit.tests %>'
      ]
      options:
        jshintrc: '.jshintrc'

    clean:
      tests: ['tmp']

    deployKeys:
      default_options:
        options: {}
      custom_options:
        options:
          sshKeyPath: '~/.ssh/id_rsa.pub'
          host: 'idg'

    nodeunit:
      tests: ['test/*_test.js']

  grunt.loadTasks('tasks');

  grunt.loadNpmTasks('grunt-contrib-jshint')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-nodeunit')

  grunt.registerTask('test', ['clean', 'deploy_keys', 'nodeunit'])

  grunt.registerTask('default', ['jshint', 'test'])
