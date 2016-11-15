merge-mongoid
==========

Easily merge two Mongoid documents.

## What it does
Let's say we have two Mongo Documents : document A and document B (same class).

When merging document B into document A, arrays and nested objects will be merged, but duplicate values are not kept. 

For the other data types we always keep Document A values, unless the A value is nil and the B is not.

## Example of data merge

Object A :

    {
    	_id : "507f1f77bcf86cd799439011",
    	a_string : "This is the A object"
        a_number : 100,
        a_boolean : true,
        array_simple_types : ["an","array","with","elements"],
        array_hashes : [{
          "id" : "507f191e810c19729de860ea",
          "attribute" : "yes there is one"
        },{
          "id" : "4f202e64e6fb1b56ff000000",
          "attribute" : "a value here too"
        }],
        a_hash : {
            "_id" : "5bf9f23d8ead0e1d32756346",
            "a string" : "hello",
            "a number" : 12
        }
    }

Object B :

    {
	    _id : "4f2030d9e6fb1b56ff000001",
    	a_string : "This is the B object"
        a_number : 8888,
        a_boolean : false,
        array_simple_types : ["an","array","with","cool","things"],
        array_hashes : [{
          "id" : "4af9f23d8ead0e1d32000000",
          "attribute" : "this is a different object"
        },{
          "id" : "4f202e64e6fb1b56ff000000",
          "attribute" : "this one was already there, but for some reason the attribute is different (which is weird BTW)"
        }],
        a_hash : {
            "_id" : "4af9f23d8ead0e1d32111111",
            "a string" : "another string value",
            "a number" : 40,
            "a third attribute" : true
        }
    }

Ruby method call

    A.merge! B

Now A contains these values : 

    {
    	_id : "507f1f77bcf86cd799439011",
    	a_string : "This is the A object"
        a_number : 100,
        a_boolean : true,
        array_simple_types : ["an","array","with","elements","cool","things"],
        array_hashes : [{
          "id" : "507f191e810c19729de860ea",
          "attribute" : "yes there is one"
        },{
          "id" : "4f202e64e6fb1b56ff000000",
          "attribute" : "a value here too"
        },{
          "id" : "4af9f23d8ead0e1d32000000",
          "attribute" : "this is a different object"
        }],
        a_hash : {
            "_id" : "5bf9f23d8ead0e1d32756346",
            "a string" : "hello",
            "a number" : 12,
            "a third attribute" : true
        }
    }



## Disclaimer
I am not a Ruby expert! I just happened to need this feature for a Rails app, so I developed a gem.

Probably a few things are not perfect or simply **ARE NOT WHAT YOU WOULD EXPECT** (ex : I don't keep duplicate values in arrays, but maybe you want to).

**I highly recommend to test** if the gem behaves correctly with your data before using it in production!

If you notice anything wrong, please feel free to send a Pull Request (including a fix + some tests).
Same thing if you enhance the gem with some cool features, I would be happy to merge. 

## Getting Started
Install the gem with: `gem install merge-mongoid` or add  `gem 'merge-mongoid', :git => 'https://github.com/fallanic/merge-mongoid'` to your Gemfile.

## Usage
You need to add one line in your Model :

<pre><code>class Myclass
  include Mongoid::Document
  include Mongoid::Timestamps
  <b>include Mongoid::Document::Mergeable</b>
  
  ...
end
</code></pre>

And then call :

    A.merge! B

B attributes will be merged into A. 

B is also destroyed after the merge has been successful.

## Testing

In the terminal, run `sudo mongod` to start the mongoDB connection

Open another tab and run `rspec`


That's all folks!

## License
Copyright (c) 2013 Fabien Allanic  
Licensed under the MIT license.
