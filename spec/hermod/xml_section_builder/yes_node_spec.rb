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

require "minitest_helper"

module Hermod
  describe XmlSection do

    YesXml = XmlSection.build do |builder|
      builder.yes_node :awesome
    end

    describe "Yes Only Nodes" do
      describe "when true" do
        subject do
          YesXml.new do |yes_xml|
            yes_xml.awesome true
          end
        end

        it "should include the node with yes as the contents" do
          value_of_node("Awesome").must_equal "yes"
        end
      end

      describe "when not true" do
        subject do
          YesXml.new do |yes_xml|
            yes_xml.awesome false
          end
        end

        it "should not include the node" do
          number_of_nodes("Awesome").must_equal 0
        end
      end
    end
  end
end
