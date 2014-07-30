# Copyright 2014 FreeAgent Central Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'hermod'

require 'minitest/autorun'
require 'pry-rescue/minitest'

require 'nokogiri'

# Public: Returns the value of a given node from an xml payload.
#
# node_name - xml node name, for example: FinalSubmission
#
# Returns a String
def value_of_node(node_name)
  value_of_nodes(node_name).first
end

# Public: Returns an array of the values of nodes in an xml payload.
#
# node_name - xml node name, for example: NIletter
#
# Returns an Array
def value_of_nodes(node_name)
  ns = nodes(node_name)
  ns.map do |n|
    raise "failed to find #{node_name.inspect} in #{subject.inspect}" if n.nil?
    n.content
  end
end

# Public: Returns the number of nodes with the given name in the payload
#
# node_name - xml node name, for example: NIletters
#
# Returns an Integer
def number_of_nodes(node_name)
  nodes(node_name).count
end

# Public: Returns the Nokogiri.XML node for the given name.
#
# node_name - xml node name, for example: FinalSubmission
#
# Returns a Nokogiri::XML::Node
def node(node_name)
  nodes(node_name).first
end

# Public: Returns a list of Nokogiri.XML nodes for the given name.
#
# node_name - xml node name, for example: NIletter
#
# Returns an Array of Nokogiri::XML::Node objects
def nodes(node_name)
  Nokogiri.XML(subject.to_xml.to_s).remove_namespaces!.css(node_name)
end

# Public: Get the nth node in the document
#
# index - the zero-based index of the node you wish to retrieve
#
# Returns an XML::Node (from LibXML)
def node_by_index(index)
  subject.to_xml.to_a[index]
end

# Public: Returns a hash of attributes on the node with the given name
#
# node_name - xml node name, for example: NIletter
#
# Returns a Hash
def attributes_for_node(node_name)
  node(node_name).attributes
end
