$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'hermod'

require 'minitest/autorun'
require 'pry-rescue/minitest'

require 'nokogiri'

# Public: Returns the value of a given node from an xml payload.
#
# xml_payload - The XMLSection object you want to test
# node_name   - xml node name, for example: FinalSubmission
def value_of_node(node_name)
  value_of_nodes(node_name).first
end

# Public: Returns an array of the values of nodes in an xml payload.
#
# xml_payload - The XMLSection object you want to test
# node_name   - xml node name, for example: NIletter
def value_of_nodes(node_name)
  ns = nodes(node_name)
  ns.map do |n|
    raise "failed to find #{node_name.inspect} in #{xml_payload.inspect}" if n.nil?
    n.content
  end
end

# Public: Returns the number of nodes with the given name in the payload
#
# xml_payload - The XMLSection object you want to test
# node_name   - xml node name, for example: NIletters
def number_of_nodes(node_name)
  nodes(node_name).count
end

# Public: Returns the Nokogiri.XML node for the given name.
#
# xml_payload - The XMLSection object you want to test
# node_name   - xml node name, for example: FinalSubmission
def node(node_name)
  nodes(node_name).first
end

# Public: Returns a list of Nokogiri.XML nodes for the given name.
#
# xml_payload - The XMLSection object you want to test
# node_name   - xml node name, for example: NIletter
def nodes(node_name)
  xml_payload = ( subject.respond_to?(:to_xml) ? subject.to_xml : subject )
  Nokogiri.XML(xml_payload.to_s).remove_namespaces!.css(node_name)
end

# Public: Returns a hash of attributes on the node with the given name
#
# xml_payload - The XMLSection object you want to test
# node_name   - xml node name, for example: NIletter
def attributes_for_node(node_name)
  node(node_name).attributes
end
