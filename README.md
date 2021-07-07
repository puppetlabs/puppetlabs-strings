Puppet Strings
==============
[![Build Status](https://travis-ci.org/puppetlabs/puppet-strings.png?branch=main)](https://travis-ci.org/puppetlabs/puppet-strings) [![Gem Version](https://badge.fury.io/rb/puppet-strings.svg)](https://badge.fury.io/rb/puppet-strings)

Puppet Strings generates documentation for Puppet code and extensions written in Puppet and Ruby. Strings processes code and YARD-style code comments to create documentation in HTML, Markdown, or JSON formats.


|                |                                                                 |
| -------------- |---------------------------------------------------------------- |
| *Code*         | [GitHub][repo]                                                  |
| *Issues*       | [GitHub issues][issues]                                         |
| *License*      | [Apache 2.0][LICENSE]                                           |
| *Change log*   | [CHANGELOG.md][changelog]                                       |
| *Contributing* | [CONTRIBUTING.md][contributing] and [COMMITTERS.md][committers] |

## Installing Puppet Strings

### Requirements

  * Ruby 2.1.9 or newer
  * Puppet 4.0.0 or newer

### Install Puppet Strings

Installation instructions vary slightly depending on how you have installed Puppet:

#### Installing Puppet Strings with [`puppet-agent`](https://puppet.com/docs/puppet/6.4/about_agent.html#what-puppet-agent-and-puppetserver-are) package

Install the `puppet-strings` gem into the `puppet-agent` environment:

```
sudo /opt/puppetlabs/puppet/bin/gem install puppet-strings
```

#### Installing Puppet Strings with standalone `puppet` gem

Install the `puppet-strings` gem into the same Ruby installation where you have installed the `puppet` gem:

```
gem install puppet-strings
```

### Configure Puppet Strings (Optional)

 To use YARD options with Puppet Strings, specify a `.yardopts` file in the same directory in which you run `puppet strings`. Puppet Strings supports the Markdown format and automatically sets the YARD `markup` option to `markdown`.

 To see a list of available YARD options, run `yard help doc`. For details about YARD options configuration, see the [YARD docs](http://www.rubydoc.info/gems/yard/file/docs/GettingStarted.md#config).

## Generating documentation with Puppet Strings

By default, Puppet Strings outputs documentation as HTML, or you can specify JSON or Markdown output instead. You can also specify [JSON Schema](https://json-schema.org/) format to produce a JSON
Schema document.

Strings generates reference documentation based on the code and Strings code comments in all Puppet and Ruby source files under the `./manifests/`, `./functions/`, `./lib/`, `./types/`, and `./tasks/` directories.

Strings outputs HTML of the reference information and the module README to the module's `./doc/` directory. This output can be rendered in any browser.

JSON and Markdown output include the reference documentation only. Strings sends JSON output to either STDOUT or to a file. Markdown output is written to a REFERENCE.md file in the module's main directory.

JSON Schema output includes only class parameter documentation to support validation of keys specified for Automatic Parameter Lookup. It also includes documentation for any data type aliases, as those may be referenced as data types in the class parameters. The JSON Schema is generated with VSCode extensions to support Markdown formatting in the hover information.

See the [Puppet Strings documentation](https://puppet.com/docs/puppet/latest/puppet_strings.html) for complete instructions for generating documentation with Strings. For code comment style guidelines and examples, see the [Puppet Strings style guide](https://puppet.com/docs/puppet/5.5/puppet_strings_style.html).

### Additional Resources

Here are a few other good resources for getting started with documentation:

  * [Module README Template](https://puppet.com/docs/puppet/latest/puppet_strings.html)
  * [YARD Getting Started Guide](http://www.rubydoc.info/gems/yard/file/docs/GettingStarted.md)
  * [YARD Tags Overview](http://www.rubydoc.info/gems/yard/file/docs/Tags.md)

## Developing and Contributing

We love contributions from the community!

If you'd like to contribute to `puppet-strings`, check out [CONTRIBUTING.md](https://github.com/puppetlabs/puppet-strings/blob/main/CONTRIBUTING.md) to get information on the contribution process.

### Running Specs

If you plan on developing features or fixing bugs in Puppet Strings, it is essential that you run specs before opening a pull request.

To run specs, run the `spec` rake task:

    $ bundle install --path .bundle/gems
    $ bundle exec rake spec

### Running Acceptance Tests

We are experimenting with a new tool for running acceptance tests. It's name is [puppet_litmus](https://github.com/puppetlabs/puppet_litmus) and replaces beaker as the test runner.

An example of running the acceptance tests locally with Docker:

1. Ensure [Docker](https://www.docker.com/products/docker-desktop) is installed and running.

2. Install Ruby gems. This step can be skipped if you have already followed the [Running Specs](#running-specs) instructions

``` text
    $ bundle install --path .bundle/gems
```

3. Provision a docker container, in this case CentOS 7

``` text
    $ bundle exec rake 'litmus:provision[docker, centos:7]'
```

4. Install test items; Puppet Agent, our test module, and the puppet-strings gem built from this source code

``` text
    $ bundle exec rake 'litmus:install_agent[puppet6]'
    $ bundle exec rake 'litmus:install_modules_from_directory[./spec/fixtures/acceptance/modules]'
    $ bundle exec rake litmus:install_gems
```

5. Run the acceptance tests. These tests can be run more than once without the need to run the provisioning steps again

``` text
    $ bundle exec rake litmus:acceptance:parallel
```

6. Remove any test containers

``` text
    $ bundle exec rake litmus:tear_down
```

The [Litmus Wiki](https://github.com/puppetlabs/puppet_litmus/wiki) contains more indepth information about Litmus. There is also a tutorial on using Litmus with an example [Puppet Module](https://github.com/puppetlabs/puppet_litmus/wiki/Tutorial:-use-Litmus-to-execute-acceptance-tests-with-a-sample-module-(MoTD)#install-the-necessary-gems-for-the-module)


An example of run the acceptance tests follow the instructions [here].

## Support

Please log issues in [GitHub issues][issues]. Check out [CONTRIBUTING.md][contributing] for tips on writing _the best_ issues.

A [mailing list](https://groups.google.com/forum/?fromgroups#!forum/puppet-users) is available for asking questions and getting help from others.

There is also an active community on the [Puppet community Slack][] in the #forge-modules channel.

We use semantic version numbers for our releases and recommend that users upgrade to patch releases and minor releases as they become available.

Bug fixes and ongoing development will occur in minor releases for the current major version. Security fixes will be ported to a previous major version on a best-effort basis, until the previous major version is no longer maintained.


[repo]: https://github.com/puppetlabs/puppet-strings
[issues]: https://github.com/puppetlabs/puppet-strings/issues
[LICENSE]: https://github.com/puppetlabs/puppet-strings/blob/main/LICENSE
[changelog]: https://github.com/puppetlabs/puppet-strings/blob/main/CHANGELOG.md
[contributing]: https://github.com/puppetlabs/puppet-strings/blob/main/CONTRIBUTING.md
[committers]: https://github.com/puppetlabs/puppet-strings/blob/main/COMMITTERS.md
[Puppet community Slack]: https://slack.puppet.com
