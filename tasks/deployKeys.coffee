###
 * grunt-deploy-keys
 * https://github.com/cray0000/grunt-deploy-keys
 *
 * Copyright (c) 2014 Pavel Zhukov
 * Licensed under the MIT license.
###


path = require 'path'
userhome = require 'userhome'
superagent = require 'superagent'
async = require 'async'
prompt = require 'prompt'
_ = require 'lodash'
exec = require('child_process').exec

bashCommandTemplate = "ssh -t -t <%= host %> \'bash -c \"if" +
    " [ ! -e <%= sshKeyPath %> ] ;" +
    " then ssh-keygen ; fi\"\' &&" +
    " scp <%= host %>:<%= sshKeyPath %> /tmp && echo \'key copied\' && exit;"

execCommand = (cmd, cb) ->
  cp = exec cmd, ((err, stdout, stderr) ->
    cb()
  ).bind(this)

  captureOutput = (child, output) ->
    child.pipe output
  captureOutput cp.stdout, process.stdout
  captureOutput cp.stderr, process.stderr
  process.stdin.resume()
  process.stdin.setEncoding 'utf-8'
  process.stdin.pipe cp.stdin

parseRepoOwner = (url = '') ->
  if /^git\+ssh/ig.test url
    user = url.match(/^git\+ssh:\/\/.*\/([\w\-]+)\//)[1]
    throw "Error getting user name from repo #{url}" unless user?
    user

parseRepoName = (url = '') ->
  if /^git\+ssh/ig.test url
    repo = url.match(/\/([\w\-]+)\.git$/)[1]
    throw "Error getting repo name from repo #{url}" unless repo?
    repo

module.exports = (grunt) ->

  grunt.registerMultiTask 'deployKeys', ->
    options = @options
      sshKeyPath: '~/.ssh/id_rsa.pub'

    config = grunt.file.readJSON path.resolve('package.json')
    throw 'No package.json found' unless config?
    done = @async()

    # Get key from remote host if needed
    ((cb) ->
      if options.host
        console.log "Connect to host #{options.host} to grab the key"
        bashCommand = _.template bashCommandTemplate, options
        execCommand bashCommand, ->
          filename = path.basename options.sshKeyPath
          options.sshKeyPath = path.join '/tmp', filename
          cb()
      else
        cb()
    ) (err) ->
      console.log 'Start prompt'
      prompt.start()

      prompt.get [
        name: 'username'
        required: true
      ,
        name: 'password'
        hidden: true
        conform: (-> true)

      ], (err, credentials) ->

        sshKeyPath = options.sshKeyPath
        if /^~\//gi.test sshKeyPath
          sshKeyPath = sshKeyPath.replace '~/', ''
          sshKeyPath = path.join userhome(), sshKeyPath
        unless grunt.file.exists sshKeyPath
          grunt.fail.warn "#{sshKeyPath} key wasn\'t found. Generate one by " +
              'running \'ssh-keygen\''
        sshKey = grunt.file.read sshKeyPath

        repos = {}
        dependencies = _.merge {}, (config['dependencies'] || {}), \
          (config['devDependencies'] || {}), \
          (config['peerDependencies'] || {})

        for repo, url of dependencies
          user = parseRepoOwner url
          repos[repo] = user if user?
        url = config.repository?.url
        user = parseRepoOwner url
        repo = parseRepoName url
        if user? and repo?
          repos[repo] = user

        async.forEach _.keys(repos), (repo, cb) ->
          url = "https://bitbucket.org/api/1.0/repositories/" +
              "#{ repos[repo] }/#{ repo }/deploy-keys/"
          superagent.post(url)
            .auth( credentials.username, credentials.password )
            .type('form')
            .send(key: sshKey)
            .end do (url = url) -> (res) ->
              grunt.log.writeln()
              grunt.log.ok url
              grunt.log.writeln res.text if res.text?
              grunt.log.writeln res.error if res.error
              cb()
        , (err) ->
          done()
