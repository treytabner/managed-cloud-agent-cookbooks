begin
  require 'rackspace-monitoring'
rescue LoadError
  Chef::Log.warn("Missing gem 'rackspace-monitoring'")
end

module Rackspace
  module CloudMonitoring

    def cm

      apikey = new_resource.rackspace_api_key 
      username = new_resource.rackspace_username 
      @@cm ||= Fog::Monitoring::Rackspace.new(:rackspace_api_key => node['cloud_monitoring']['rackspace_api_key'], :rackspace_username => node['cloud_monitoring']['rackspace_username'],
                                              :raise_errors => node['cloud_monitoring']['abort_on_failure'])
      @@view ||= Hash[@@cm.entities.overview.map {|x| [x.identity, x]}]
      @@cm
    end

    def tokens
      @@tokens ||= Hash[cm.agent_tokens.all.map {|x| [x.identity, x]}]
    end

    def clear
      @@view = nil
    end

    def clear_tokens
      @@tokens = nil
    end

    def view
      cm
      @@view
    end

    def get_type(entity_id, type)
      if type == 'checks' then
        view[entity_id].checks
      elsif type == 'alarms' then
        view[entity_id].alarms
      else
        raise Exception, "type #{type} not found."
      end
    end

    def get_child_by_id(entity_id, id, type)
      objs = get_type entity_id, type
      obj = objs.select { |x| x.identity === id }
      if !obj.empty? then
        obj.first
      else
        nil
      end

    end

    def get_child_by_label(entity_id, label, type)
      objs = get_type entity_id, type
      obj = objs.select {|x| x.label === label}
      if !obj.empty? then
        obj.first
      else
        nil
      end
    end

    #####
    # Specific objects
    def get_entity_by_id(id)
      view[id]
    end

    def get_entity_by_label(label)
      possible = view.select {|key, value| value.label === label}
      possible = Hash[*possible.flatten(1)]

      if !possible.empty? then
        possible.values.first
      else
        nil
      end
    end

    def get_entity_by_ip(ip_addresses)
      possible = view.select {|key, value| value.ipaddresses === ip_addresses}
      possible = Hash[*possible.flatten(1)]

      if !possible.empty? then
        possible.values.first
      else
        nil
      end
    end

    def get_check_by_id(entity_id, id)
      get_child_by_id entity_id, id, 'checks'
    end

    def get_check_by_label(entity_id, label)
      get_child_by_label entity_id, label, 'checks'
    end

    def get_alarm_by_id(entity_id, id)
      get_child_by_id entity_id, id, 'alarms'
    end

    def get_alarm_by_label(entity_id, label)
      get_child_by_label entity_id, label, 'alarms'
    end

    def get_token_by_id(token)
      tokens[token]
    end

    def get_token_by_label(label)
      possible = tokens.select {|key, value| value.label === label}
      possible = Hash[*possible.flatten(1)]

      if !possible.empty? then
        possible.values.first
      else
        nil
      end
    end
  end
end
