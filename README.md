# HyperactiveRecord
HyperactiveRecord is a tool designed for object-relational mapping similar to Rails's Active Record. A SQLBase object in HyperactiveRecord is associated with a table in a given database (more on how to associate a database below) and includes a number of appropriate getter and setter methods for that table.

## Setting Up A Database
This repository includes a SQLite3 database called Plants and a file (lib/db_connection.rb) to associate that database with the project. To include HyperactiveRecord in your project, simply include the library in your project directory, initialize a SQL database in your project, and modify the db_connection.rb file with the name of your .db file (replacing 'plants.db').


## Methods

### SQLBase

* `::table_name`: Returns the table name for the associated model
* `::all`: Returns all instances of that model
* `::columns`: Returns all the column names associated with that model
* `::find`: Takes an id as a parameter and returns the first entry in the database of that model with the given id
* `#where`: Takes query parameters (in the form "col_name: value") and returns a Relation object, which allows for chaining of #where calls. The Relation is executed when another, non-chainable method is called on it.
* `#attributes` and `#attribute_values`: Return the names and values, respectively, of the attributes of the given model
* `#insert`: Adds a model to the database
* `#update`: Updates the entries in the database associated with the given model with its current attribute values
* `#validates`: Takes column names and options for validating presence and length
* `#has_many`: Takes a table name and optional `class_name`, `foreign_key`, and `primary_key` values and associates the SQLBase object with the given table in a "has many" relationship.
* `#belongs_to`: Takes a table `name` and optional `class_name`, `foreign_key`, and `primary_key` values and associates the SQLBase object with the given table in a "belongs to" relationship.
* `#has_many_through`: Takes a table `name`, a `through_name`, and a `source_name` and associates the given SQLBase object with the table given by `name` through a previously associated table (given by `through_name`), which has an association with the desired table (`source_name`).
