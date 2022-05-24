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
      builder.string_node :status, input_mutator: (lambda do |value, attributes, instance|
        adjective = case instance.nodes[:mood].first.value
        when "Happy"
          "joyously"
        when "Sad"
          "dejectedly"
        when "Hangry"
          "furiously"
        end
        ["#{value} #{adjective}", attributes]
      end)
      builder.string_node :mood, allowed_values: %w(Happy Sad Hangry)
    end

    describe "String nodes" do
      subject do
        StringXml.new do |string_xml|
          string_xml.greeting "Hello"
        end
      end

      it "should set node contents correctly" do
        expect(value_of_node("Greeting")).must_equal "Hello"
      end

      it "should allow values that pass the regex validation" do
        subject.title "Sir"
        expect(value_of_node("Title")).must_equal "Sir"
      end

      it "should raise an error when the regex validation fails" do
        ex = expect { subject.title "Laird" }.must_raise InvalidInputError
        expect(ex.message).must_equal %(title "Laird" does not match /\\ASir|Dame\\z/)
      end

      it "should require all non-optional nodes to have content" do
        ex = expect { subject.required "" }.must_raise InvalidInputError
        expect(ex.message).must_equal "required isn't optional but no value was provided"
      end

      it "should apply changes to the inputs if a input_mutator is provided" do
        subject.gender "Male"
        expect(value_of_node("Gender")).must_equal "M"
      end

      it "should allow input_mutators to access nodes the instance" do
        subject.mood "Hangry"
        subject.status "Eating cookies"
        expect(value_of_node("Status")).must_equal "Eating cookies furiously"
      end

      it "should restrict values to those in the list of allowed values if such a list is provided" do
        subject.mood "Hangry"
        expect(value_of_node("Mood")).must_equal "Hangry"
      end

      it "should raise an error if the value is not in the list of allowed values" do
        ex = expect { subject.mood "Jubilant" }.must_raise InvalidInputError
        expect(ex.message).must_equal "mood must be one of Happy, Sad, or Hangry, not Jubilant"
      end

      it "should be thread safe for validation" do
        subject1 = StringXml.new do |string_xml|
          string_xml.greeting "Hello"
        end

        Thread.new do
          subject1.mood "Hangry"
        end

        ex = expect { subject.mood "Jubilant" }.must_raise InvalidInputError
        expect(ex.message).must_equal "mood must be one of Happy, Sad, or Hangry, not Jubilant"
      end

      it "should use the given keys for attributes" do
        subject.title "Sir", masculine: "no"
        expect(attributes_for_node("Title").keys.first).must_equal "Male"
        expect(attributes_for_node("Title")["Male"].value).must_equal "no"
      end

      it "should raise an error if given an attribute that isn't expected" do
        expect { subject.title "Sir", knight: "yes" }.must_raise InvalidInputError
      end

      it "should not include empty, optional nodes" do
        subject.name ""
        expect(nodes("Name")).must_be_empty
      end
    end
  end
end
