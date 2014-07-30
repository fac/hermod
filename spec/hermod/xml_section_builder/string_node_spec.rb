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

    StringXml = XmlSection.build do |builder|
      builder.string_node :greeting
      builder.string_node :name, optional: true
      builder.string_node :title, matches: /\ASir|Dame\z/, attributes: {masculine: "Male"}
      builder.string_node :required
      builder.string_node :gender, input_mutator: (lambda do |value, attributes|
        [value == "Male" ? "M" : "F", attributes]
      end)
      builder.string_node :mood, allowed_values: %w(Happy Sad Hangry)
    end

    describe "String nodes" do
      subject do
        StringXml.new do |string_xml|
          string_xml.greeting "Hello"
          string_xml.name "World"
        end
      end

      it "should set node contents correctly" do
        value_of_node("Greeting").must_equal "Hello"
      end

      it "should allow values that pass the regex validation" do
        subject.title "Sir"
        value_of_node("Title").must_equal "Sir"
      end

      it "should raise an error when the regex validation fails" do
        ex = proc { subject.title "Laird" }.must_raise InvalidInputError
        ex.message.must_equal %{Value "Laird" for title doesn't match /\\ASir|Dame\\z/}
      end

      it "should require all non-optional nodes to have content" do
        ex = proc { subject.required "" }.must_raise InvalidInputError
        ex.message.must_equal "required isn't optional but no value was provided"
      end

      it "should apply changes to the inputs if a input_mutator is provided" do
        subject.gender "Male"
        value_of_node("Gender").must_equal "M"
      end

      it "should restrict values to those in the list of allowed values if such a list is provided" do
        subject.mood "Hangry"
        value_of_node("Mood").must_equal "Hangry"
      end

      it "should raise an error if the value is not in the list of allowed values" do
        ex = proc { subject.mood "Jubilant" }.must_raise InvalidInputError
        ex.message.must_equal %{"Jubilant" is not in the list of allowed values for mood: ["Happy", "Sad", "Hangry"]}
      end

      it "should use the given keys for attributes" do
        subject.title "Sir", masculine: "no"
        attributes_for_node("Title").keys.first.must_equal "Male"
        attributes_for_node("Title")["Male"].value.must_equal "no"
      end

      it "should raise an error if given an attribute that isn't expected" do
        proc { subject.title "Sir", knight: "yes" }.must_raise KeyError
      end
    end
  end
end
