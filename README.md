# HyperactiveRecord
HyperactiveRecord is a tool designed for object-relational mapping similar to Rails's Active Record. A SQLBase object in HyperactiveRecord is associated with a table in a given database (more on how to associate a database below) and includes a number of appropriate getter and setter methods for that table.

## Setting Up A Database
This repository includes a SQLite3 database called Plants and a file (lib/db_connection.rb) to associate that database with the project. To include HyperactiveRecord in your project, simply include the library in your project directory, initialize a SQL database in your project, and modify the db_connection.rb file with the name of your .db file (replacing 'plants.db').


## Methods

### SQLBase#where
Takes query parameters (in the form "col_name: value") and returns a Relation object, which allows for chaining of #where calls. The Relation is executed when another, non-chainable method is called on it.

### SQLBase::table_name
Returns the table name for the associated model
### SQLBase::all
Returns all instances of that model
### SQLBase::columns
Returns all the column names associated with that model
### SQLBase::find
Takes an id as a parameter and returns the first entry in the database of that model with the given id
### SQLBase#attributes && #attribute_values
Return the names and values, respectively, of the attributes of the given model
### SQLBase#insert
Adds the model to the database
### SQLBase#update
Updates the entries in the database associated with the given model with its current attribute values
### Validator#validates
Takes column names and options for validating presence and length
