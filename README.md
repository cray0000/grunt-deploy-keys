# grunt-deploy-keys

> Automatically parses package.json and sets ```~/.ssh/id_rsa.pub``` as
> deploy key for all private bitbucket repositories using Bitbucket API

If `id_rsa.pub` is not present it runs ```ssh-keygen``` to generate one.

## Requirements

1. It will ask you for login/password to access those private repos so
    you have to have at least *read* permission for all of them

## Getting Started
This plugin requires Grunt `~0.4.0`

If you haven't used [Grunt](http://gruntjs.com/) before, be sure to check out the [Getting Started](http://gruntjs.com/getting-started) guide, as it explains how to create a [Gruntfile](http://gruntjs.com/sample-gruntfile) as well as install and use Grunt plugins. Once you're familiar with that process, you may install this plugin with this command:

```shell
npm install grunt-deploy-keys --save-dev
```

Once the plugin has been installed, it may be enabled inside your Gruntfile with this line of JavaScript:

```js
grunt.loadNpmTasks('grunt-deploy-keys');
```

## The "deployKeys" task

### Overview
In your project's Gruntfile, add a section named `deployKeys` to the data object passed into `grunt.initConfig()`.

```js
grunt.initConfig({
  deployKeys: {
    bitbucket: {
      options: {
        sshKeyPath: '~/.ssh/id_rsa.pub'
        host: 'ubuntu@192.168.1.1'
      }
    },
  },
});
```

### Options

#### options.host
Type: `String`

Default value: `undefined`

If present will connect to remote host via SSH to grab the key.

#### options.sshKeyPath
Type: `String`

Default value: `'~/.ssh/id_rsa.pub'`

Path to the public SSH key


## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

## Release History
_(Nothing yet)_
