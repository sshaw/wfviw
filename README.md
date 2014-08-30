# WFVIW!?

_What Fucking Version is Where!?_ Keeps track of what's deployed, and where.

## Running

    bundle install
    bundle exec ruby wfviw.rb


A `config.ru` file is also included so it can be run via Rack.

### The Database

By default an SQLite database named `deployments.db` will be created in the current directory.
If you're not using SQLite you must add your DB lib to the `Gemfile` and remove `sqlite3`.

There are a couple of ways to specify [a DB connection string](http://sequel.jeremyevans.net/rdoc/files/doc/opening_databases_rdoc.html#label-Using+the+Sequel.connect+method).

#### Command Line

	bundle exec ruby wfviw.rb  # use default DB
	bundle exec ruby wfviw.rb 'postgres://sshaw@localhost/wfviw'

#### Environment Variable

Just set the `DATABASE_URL` environment variable.

	DATABASE_URL='postgres://sshaw@localhost/wfviw' bundle exec ruby wfviw.rb
 
## Adding Versions

Add something like following to your deployment script/hook/whatever:

    curl -d 'environment=production&name=website&version=v0.2.1' http://localhost:4567/deploy

The following parameters are accepted

Required:

  * `environment`
  * `name`
  * `version`

Optional:

  * `hostname`
  * `deployed_by`

## Other Ways to Track Deployments

* https://github.com/mydrive/capistrano-deploytags
* https://github.com/forward/capistrano-deploy-tagger
