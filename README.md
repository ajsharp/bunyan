Bunyan
======
![](http://img2.timeinc.net/ew/dynamic/imgs/080612/Paul-Bunyan-Blue-Ox_l.jpg)

Bunyan is a thin ruby wrapper around a MongoDB [capped collection](http://www.mongodb.org/display/DOCS/Capped+Collections), 
created with high-performance, flexible logging in mind.

Bunyan is not intended to be used as a drop-in replacement for the default
rails logger. If you need to do this, please see peburrows' [mongo\_db\_logger](http://github.com/peburrows/mongo_db_logger).

However, there is planned support for a flexible middleware component to drop in
to your rails app. 

Install
=======
    gem install bunyan

Configure
=========
The only configuration options required are the database and collection name.

For rails apps, put the following config block in an initializer.

    # config/initializers/bunyan.rb
    Bunyan::Logger.configure do |config|
      # required options
      config.database   'bunyan_logger'
      config.collection 'development_log'

      # optional
      config.host     'some.remote.host' # defaults to localhost
      config.port     '12345'            # defaults to 27017
      config.disabled true

      # other connection option
      # Specify a valid ruby driver connection object (single / pair)
      # if you do so, host / port are ignored 
      config.connection = $connection
    end

Usage
=====
You can access the bunyan logger anywhere is your app via Bunyan::Logger.
The Logger class is implemented as a singleton, and you can call any instance
method on the Logger class. This is implemented with some method_missing magic,
which is explained in a bit more detail below.

Internals
=========
Bunyan makes heavy usage of method\_missing both at the class and instance level.
At the class level, this is purely for convenience to pass missing class methods
to the singleton instance, which precludes us from needing to use Logger.instance
directly. At the instance level, method\_missing is used to provide a very thin
layer around MongoDB, via the Mongo driver.

The net effect of this is that there is no reason to muck around with 
calling methods directly on Bunyan::Logger.instance, because all methods that 
don't already exist at the class level will be sent to Bunyan::Logger.instance.

    Bunyan::Logger.count == Bunyan::Logger.instance.count # => true

Also, you can call any instance methods Bunyan::Logger that you would otherwise 
call on a Mongo collection object.

More
====
* [MongoDB Capped Collections](http://www.mongodb.org/display/DOCS/Capped+Collections)
* [Mongo Ruby Driver](http://github.com/mongodb/mongo-ruby-driver)

TODO
====
* Ability to specify auth creds for making mongo connection
* <del>Fail silently if no mongo server running</del>
* Ability to limit bunyan to only run in certain environments
* Add middleware client for easy drop-in to rails/rack apps
<del>* Add ability to connect to a remote mongo server</del>
* <del>Ability to configure size of capped collection</del>
