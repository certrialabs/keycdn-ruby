# A simple Ruby wrapper for the KeyCDN API
Just a tiny wrapper for the KeyCDN API. This one differs from the vendor maintained lib in following:

* raises exceptions in case of HTTP or response issues - now you can safely wrap the API calls in ActiveRecord transactions
* based on the excon HTTP lib - fast and performant, also easily allowing extending the wrapper to API call retries and other cool stuff
* returns only the relevant data part of the responses (i.e. response['data']['zones'] when getting all zones, etc)
* leaves relevant places for extending the lib with specific calls, not included in the API - e.g. find_zone_by_name

## Usage

> Requires Ruby 1.9.2+

### Initialize

```ruby
require 'keycdn'

keycdn = KeyCDN::API.new(:api_key => YOURAPIKEY)
```

### Get zones

```ruby
zones = keycdn.get('zones')
zones.each do |zone|
  # Do something fun and profitable with the zone
end
```

### Create zone

```ruby
zone_params = {
  'name' => 'test',
  'type' => 'push'
}

keycdn.post('zones', zone_params)
```

### Delete a zones

```ruby
keycdn.delete('zones/5')
```

### Exception handling

Let's take it for example that you need to tie the zone with an ActiveRecord model being updated + an API call to another service
```ruby
begin
  SomeModel.transaction do
    self.save

    other_api.make_call()

    keycdn.create(..)
  end
rescue KeyCDN::API::Errors:Error
  other_api.revert_call()
end
```

### Extra functionality
Since zones are often referenced by name, a call to find the zone object by name
```ruby
zone = keycdn.find_zone_by_name(..)
zone['id']
```
