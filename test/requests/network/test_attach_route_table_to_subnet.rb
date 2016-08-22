require File.expand_path '../../test_helper', __dir__

# Test class for Attach Route Table to Subnet Request
class TestAttachRouteTableToSubnet < Minitest::Test
  def setup
    @service = Fog::Network::AzureRM.new(credentials)
    client = @service.instance_variable_get(:@network_client)
    @subnets = client.subnets
    @promise = Concurrent::Promise.execute do
    end
  end

  def test_attach_route_table_to_subnet_success
    mocked_response = ApiStub::Requests::Network::Subnet.create_subnet_response
    expected_response = Azure::ARM::Network::Models::Subnet.serialize_object(mocked_response.body)
    @promise.stub :value!, mocked_response do
      @subnets.stub :create_or_update, @promise do
        assert_equal @service.attach_route_table_to_subnet('fog-test-rg', 'fog-test-subnet', 'fog-test-virtual-network', '10.1.0.0/24', 'nsg-id', 'table-id'), expected_response
      end
    end
  end

  def test_attach_route_table_to_subnet_failure
    response = -> { raise MsRestAzure::AzureOperationError.new(nil, nil, 'error' => { 'message' => 'mocked exception' }) }
    @promise.stub :value!, response do
      @subnets.stub :create_or_update, @promise do
        assert_raises RuntimeError do
          @service.attach_route_table_to_subnet('fog-test-rg', 'fog-test-subnet', 'fog-test-virtual-network', '10.1.0.0/24', 'nsg-id', 'table-id')
        end
      end
    end
  end
end