Keytar
======

**1.** A keyboard that is designed to be played standing up, like a guitar.  
**2.** A crazy simple, flexible ruby library for generating NOSQL keys.

It Builds Keys: 
--------
keytar auto-magically generates keys using method names ending in `"_key"` or simply "key"

    User.key #=> "user"
    User.friends_key #=> "user:friends"
    
    u = User.new
    u.last_web_access_cache_key #=> "users:last_web_access_cache"
    u.favorite_spots_key("some_argument") #=> "users:favorite_spots:some_argument"
    
    u = User.create(:id => 2)
    u.sweet_key #=> "users:sweet:2"
    

___quit___ littering your code with junk like this:

    class User
      def some_key_for_a_distributed_no_sql_datastore_key
        "foos:some_key_for_a_distributed_no_sql_datastore_key:#{self.id}"
      end
    end

Seriously, ___quit it___! Use Keytar instead ^_^


Installation
------------
In your Gemfile add

    gem 'keytar'

then run

    bundle install

Then drop `include Keytar` in any Ruby model you want and you're good to go



It's that simple

Define Keys
-------------
Keys should be pre-defined and configured by calling **define\_keys**:

    class User
      include Keytar
      define_keys :friend_ids, :email_subscriptions, :news_feed, :delimiter => "|", :version => "v2"
      define_keys :favorite_spots, :delimiter => "/", :version => 3, :key_prefix => "lol"
    end

    User.respond_to? :friend_ids_key #=> true
    User.friend_ids_key #=> "user|friend_ids|v2"

Where the first argument is the key (or keys) to be defined, and the second argument is a hash of configurations.


Global options can also be configured per class by passing in a hash to **key_config**:

    class User
      include Keytar
      key_config :delimiter => "/", :suffix => "after"
      define_keys :ignored_ids
    end

    User.ignored_ids_key #=> "user/ignored_ids/after"

Configuration Options Breakdown
------------------------
Here is a run down of what each does  

**delimiter** sets the separating argument in keys

    define_keys :favorite_spots, :delimiter => "|"
    User.favorite_spots_key #=> "user|favorite_spots"


**order** sets the location of key parts, if a symbol is omitted, it will not show up in the final key (note the location of "favorite_spots" and "user" is flipped)

    define_keys :favorite_spots, :order => [:name, :base]
    User.favorite_spots_key #=> "favorite_spots:user"
    
**unique** sets the unique value of the instance that is used to build the key

By default all instance keys have an identifying unique element included in the key, specifying `key_unique` allows you to change the field that is used to specify a unique key. (defaults to database backed id, but will not use id if object.id == object.object_id)

    User.create(:username => "Schneems", :id => 9)
    User.find(9).favorite_spots_key #=> "users:favorite_spots:9"

    define_keys :favorite_spots, :unique => "username"
    User.find(9).favorite_spots_key #=> "users:favorite_spots:schneems"

**prefix** adds some text to the beginning of your key for that class

    define_keys :favorite_spots, :prefix =>  "woot"
    User.favorite_spots_key #=> "woot:user:favorite_spots"
    
**suffix** adds some text to the end of your key for that class

    define_keys :favorite_spots, :suffix => "pow"
    User.favorite_spots_key #=> "user:favorite_spots:pow"

**`pluralize_instances`** allows you to toggle pluralizing instance keys (note the 's' in 'users' is not there)

    define_keys :favorite_spots, :pluralize_instances => false
    User.find(1).favorite_spots_key #=> "user:favorite_spots:1"
    

**plural** allows you to over-ride the default pluralize method with custom spelling

    define_keys :favorite_spots, :plural => "uzerz"
    User.find(1).favorite_spots_key #=> "uzerz:favorite_spots:1"

**case** allows you to specify the case of your key

    define_keys :favorite_spots, :case => :upcase
    User.favorite_spots_key #=> "USER:REDIS"


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


licensed under MIT License
Copyright (c) 2011 Schneems. See LICENSE.txt for
further details.
