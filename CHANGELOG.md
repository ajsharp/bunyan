Version 0.3.0
=============
* Can now specify and connect a remote host and alternate port

Version 0.2.2
=============
* No longer pass messages to the collection if a Mongo connection could not be established
* Bunyan now uses the new bson_ext c extension, per version 0.20.0 of the ruby driver

Version 0.2.1
=============
* Bunyan now fails silently when a connection error occurs

Version 0.2.0
=============
* Moved all configuration-related stuff to the Config class
* Added ability to set the collection size in configuration block
* Bunyan attributes (:connection, :collection, :db) now map directly to mongo counterparts
