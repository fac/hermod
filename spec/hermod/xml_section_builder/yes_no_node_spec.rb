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

    YesNoXml = XmlSection.build do |builder|
      builder.yes_no_node :awesome
    end

    describe "Yes/No nodes" do
      describe "when true" do
        subject do
          YesNoXml.new do |yes_no_xml|
            yes_no_xml.awesome true
          end
        end

        it "should include the node with yes as the contents" do
          value_of_node("Awesome").must_equal "yes"
        end
      end

      describe "when not true" do
        subject do
          YesNoXml.new do |yes_no_xml|
            yes_no_xml.awesome false
          end
        end

        it "should include the node with no as the contents" do
          value_of_node("Awesome").must_equal "no"
        end
      end
    end
  end
end
