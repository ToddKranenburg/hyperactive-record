# HyperactiveRecord
HyperactiveRecord is a library that implements much of the same functionality as active record: it serves as an intermediary between a model in an MVC framework and the database with which that model is associated with. HyperactiveRecord was built to work specifically with Sqlite3, but could be extrapolated to work with any relational database.

## Methods

### AttrObject::my_attr_reader
Similar to the active record attr_reader method: takes a column name and defines a method for the associated Object (which must inherit from AttrObject) to retrieve the data in that column from the database
### AttrObject::my_attr_writer
Similar to the active record attr_writer method: takes a column name and defines a method for the associated Object (which must inherit from AttrObject) to assign data in that column in the database
### AttrObject::my_attr_accessor
Provides both setter and getter methods for the given column name

### SQLBase#where
Takes query parameters (in the form "col_name: value") and returns a Relation object, which allows for chaining of #where calls. The Relation is executed when another, non-chainable method is called on it.

### SQLBase::table_name
### SQLBase::all
### SQLBase::columns
### SQLBase::find
### SQLBase#attributes && #attribute_values
### SQLBase#insert
### SQLBase#update
### SQLBase#save
