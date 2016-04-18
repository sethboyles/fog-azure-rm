# rubocop:disable MethodLength
# rubocop:disable AbcSize
module Fog
  module Compute
    class AzureRM
      # This class is giving implementation of create/save and
      # delete/destroy for Availability Set.
      class AvailabilitySet < Fog::Model
        attribute :id
        identity  :name
        attribute :type
        attribute :location
        attribute :tags
        attribute :resource_group
        attribute :properties

        def save
          requires :name
          requires :location
          requires :resource_group
          # need to create the availability set
          Fog::Logger.debug "Creating Availability Set
                       '#{name}' in #{location} region."
          avail_set = get_avail_set_properties(location)
          service.create_availability_set(resource_group,
                                          name,
                                          avail_set)
          Fog::Logger.debug "Availability Set #{name} created successfully."
        end

        def destroy
          Fog::Logger.debug "Deleting Availability Set: #{name}."
          service.delete_availability_set(resource_group, name)
          Fog::Logger.debug "Availability Set #{name} deleted successfully."
        end

        # create the properties object for creating availability sets
        def get_avail_set_properties(location)
          avail_set_props =
            Azure::ARM::Compute::Models::AvailabilitySetProperties.new
          # At least two domain faults
          avail_set_props.platform_fault_domain_count = 2
          avail_set_props.platform_update_domain_count = 2
          # At this point we do not have virtual machines to include
          avail_set_props.virtual_machines = []
          avail_set_props.statuses = []
          avail_set = Azure::ARM::Compute::Models::AvailabilitySet.new
          avail_set.location = location
          avail_set.properties = avail_set_props
          avail_set
        end
      end
    end
  end
end
