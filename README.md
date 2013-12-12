merge-mongoid
==========

Easily merge two Mongoid documents.

## What it does
Let's say we have two Mongo Documents : document A and document B (same class).

When merging document B into document A, arrays and nested objects will be merged. 

For the other data types we keep Document A values.

## Disclaimer
I do not consider myself as a strong Ruby developer! I just happened to need this feature, so I developed a gem.

Probably a few things are wrong or could be done differently.

**I highly recommend to test** if the gem behaves correctly with your own data before using it in production!

If you notice anything wrong, please feel free to send a Pull Request (including fix + tests).
Same thing if you enhance the gem with some cool features which make sense, I would be happy to merge. 

## Getting Started
Install the gem with: `gem install merge-mongoid` or add it to your Gemfile.

## Usage
You need to add one line in your Model :

    class Myclass
      include Mongoid::Document
      include Mongoid::Timestamps
      **include Mongoid::Document::Mergeable**
      
      ...
    end

And then call :

    A.merge! B

B attributes will be merged into A. 

B is also destroyed after the merge has been successful.


That's all folks!

## License
Copyright (c) 2013 Fabien Allanic  
Licensed under the MIT license.