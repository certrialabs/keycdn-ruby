module KeyCDN
  class API
    def find_zone_by_name(name)
      zones = get('zones')

      zones.find(lambda { raise KeyCDN::API::Errors::ObjectNotFound.new("Zone named #{name} does not exist")}) { |zone| zone['name'] == name }
    end
  end
end
