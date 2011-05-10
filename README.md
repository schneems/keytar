Keytar
======

**1.** A keyboard that is designed to be played standing up, like a guitar.  
**2.** A crazy simple ruby-on-rails library for making re-usable keys (the kind you use in key/value stores)

KeyBuilder
----------

Keytar is an amazingly easy way to auto-magically generate keys for all of your NOSQL key needs. Are you using Redis, Memcache, MongoDB, Cassandra, or another hot key-value store? Then use **keytar**! It automatically generates keys based on class name instead of cluttering model definitions with tons of redundant key method declarations. 

___quit___ littering your code with junk like this:

    class User
      def some_distributed_no_sql_datastore_key
        "foos:some_distributed_no_sql_datastore:#{self.id}"
      end
    end

Seriously, ___quit it___!


Installation
------------
In your Ruby on Rails Gemfile add

    gem 'keytar'

then run

    bundle install

now, you're good to go. Not using RoR? No worries, just drop `include Keytar` in any Ruby model you want.


Example: 
--------
keytar auto-magically generates keys using method names ending in `"_key"` or simply "key".

    User.key #=> "user"
    User.memcache_key #=> "user:memcache"
    
    u = User.new
    u.redis_key #=> "users:redis"
    u.redis_key("some_arguement") #=> "users:redis:some_arguement"
    
    u = User.create(:id => 2)
    u.sweet_key #=> "users:sweet:2"
    


It's that simple

Config
------

These options can be configured by passing in a hash to keyfig:

    class User < ActiveRecord::Base
      keyfig :key_delimiter => ":", :key_order => [:unique, :suffix], :key_prefix => "before"
    end

Or by calling class methods

    class User < ActiveRecord::Base
      key_delimiter ":"
      key_order [:prefix, :base, :name, :unique, :args, :suffix]
      key_prefix nil
    end

Config Options Breakdown
------------------------
Here is a run down of what each does  

**key_delimiter** sets the separating argument in keys

    User.key_delimiter "|"
    user.redis_key #=> "users|redis"


**key_order** sets the location of key parts, if a symbol is omitted, it will not show up in the final key

    User.key_order [:name, :base]
    user.redis_key #=> "redis:users"
    
**key_unique** sets the unique value of the instance that is used to build the key

By default all instance keys have an identifying unique element included in the key, specifying `key_unique` allows you to change the field that is used to specify a unique key. (defaults to database backed id, but will not use id if object.id == object.object_id)

    user = User.create(:username => "Schneems", :id => 9)
    user.id #=> 9
    user.redis_key #=> "users:redis:9"

    User.key_unique("username")
    user.redis_key #=> "users:redis:schneems"

**key_prefix** sets the a prefix to your key for that class

    User.key_prefix "woot"
    user.redis_key #=> "woot:users:redis"
    
**key_suffix** sets the a suffix to your key for that class

    User.key_suffix "slave"
    user.redis_key #=> "users:redis:slave"

**`key_pluralize_instances`** allows you to toggle pluralizing instance keys (note the 's' in 'users' is not there)

    User.key_pluralize_instances false
    user.redis_key #=> "user:redis"
    

**key_plural** allows you to over-ride the default pluralize method with custom spelling

    User.key_plural "uzerz"
    user.redis_key #=> "uzerz:redis"

**key_case** allows you to specify the case of your key

    User.key_case :upcase
    user.redis_key #=> "USERS:REDIS"

**`key_cache_methods`** will let you toggle whether or not keytar defines your key methods after being called. If you're calling
these methods over and over, this can give you a speed boost, however there is overhead associated with defining methods. The default
is on, however try it both ways on your app run some benchmarks and see what works the best.



Since this library is sooooo simple, here is a ASCII keytar for you. Thanks for checking it out.

                                                                         ,,,,     
                                                                        ,,:::,    
                                                                      ,,,,7::=    
                                                                     ,:~?MOZN~    
                                                                   ,,=~ONZDM      
                                                                 ,,,~,NMOM+       
                                                                :,,:~MNOM,        
                                                              ,,,:,,MO8M          
                                                             :,,,,:: NO           
                                                           ,:,~=~+,,:~            
                                                         ,:::+:I:=::,             
                                                        =?::::I::::               
                                                      ,~:,+7:::::~                
                                                     ~,,,,,,+~:::           ,,,   
                                                   ,:,,,,,=,,,7~:         ,::::,  
                                                 ,:,,:,,?~::=:,+=:,,,,,,,::::::   
                                                ::::,,:,,NMZ,=,,+=::,::::+::::    
                                               ~:,,,::,88=DNM:,:,:+~:::,MN~,~     
                                             ,:,,:,,,+=+MM==8MZ,=::::::?=:~~      
                                            ~,,: ,,=,7MN~OMM=?NM::~:$+:~:=        
                                          ~:,:,:,~7~:==MM?+ZM8~7::I~:+:::         
                                        ,:,,,,,~,:NM8:=~$MD?+M~::~~~~~~           
                                       ~,:,, +,+DO=?MM~,=~NM8:::I+:::~            
                                     ,~:,:,=:,:~+MM8=ZMD:~::::+:~::~              
                                    ~:,:,:,,?DZ:?~ONM=+MM:+~:I?~:~                
                                  ~~,,,~:,ZN=?MN~::~OMO~:NMM:,::~                 
                                ,~:,:~,,==+ZM8+8MZ:::~=+8D+,===,                  
                               ~:,~=,,=,$MD++MM~?MMO::ND8,===~                    
                             ,:,:,,:=:~:==MMD=OMO~Z=~=+?:===:                     
                            ~,:,,,=,:ZM8~=:=NN?+M+::I7+~==:                       
                          ~:::,,=,+DN=?MM~,=~ZM8:~7~::~~=                         
                        ,~::,:=,:~~~8MZ+OM8~,~::==::=~:,                          
                       ~:,: =,,?D$~~~+MN=+NMO::$~~~~~=                            
                      ~,,~,:,=+=DMZ~~~+NN==$,::?~~::=                             
                    ,,:~,::=,~NN+IMM$:+=8D,:::~~+~=                               
                   ~,::,::,=D8?OMZ??NN:~:::?I:~:~                                 
                 :,:,:,:,,+~=MN+?MDZ+DM::+7::~~=                                  
               ,::,,,~,:NN~~?~OM8+8MN:::N:~~:=,                                   
              :~,,:~,,$$+8MM~~~=MN==::=Z~~:~~                                     
            ,:,::,,,~,+MN+I8M$~+~Z,:==~~~~~                                       
           :,,,,,,=I\~+~DM$=?MN::::::~+~+                                         
         ~,::,,,=~=?M\~=~?MN7=O:::$~=:~,                                          
        :,~,,,=,~NN$+N\ :~:+MI::N:::~=                                            
      ,:=:,,+,=DZ?DMN+7M\:==,:~::=~=                                              
     ::::~::,::+MN+?DN7+N\,:~::=:=                                                
    ::::::,~::,?:DMN+?MN~~ :::~::                                                 
     :::::::,I:,~:+8NZ=,:=+I::~                                                   
       ,,:::::+:,,+:=$::$7::~                                                     
          :,:::,I:,,,:?7=:~~                                                      
          I:,:::::::$7I,:~                                                        
             ,::::~:,7:::                                                         


Contribution
============

Fork away. If you want to chat about a feature idea, or a question you can find me on the twitters [@schneems](http://twitter.com/schneems).  Put any major changes into feature branches. Make sure all tests stay green, and make sure your changes are covered. 


Copyright (c) 2011 Schneems. See LICENSE.txt for
further details.
