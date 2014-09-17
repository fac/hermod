require "minitest_helper"

module Hermod
  describe XmlSection do

    TextXml = XmlSection.build do |builder|
      builder.text_node :greeting
      builder.text_node :name, optional: true
      builder.text_node :title, matches: /\ASir|Dame\z/, attributes: {masculine: "Male"}
      builder.text_node :required
      builder.text_node :gender, input_mutator: (lambda do |value, attributes|
        [value == "Male" ? "M" : "F", attributes]
      end)
      builder.text_node :mood, allowed_values: %w(Happy Sad Hangry)
      builder.text_node :biography, replace_newlines: true
      builder.text_node :telegram, replace_newlines: " STOP "
    end

    describe "Text nodes" do
      subject do
        TextXml.new do |text_xml|
          text_xml.greeting "Hello"
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
        ex.message.must_equal %(title "Laird" does not match /\\ASir|Dame\\z/)
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
        ex.message.must_equal "mood must be one of Happy, Sad, or Hangry, not Jubilant"
      end

      it "should use the given keys for attributes" do
        subject.title "Sir", masculine: "no"
        attributes_for_node("Title").keys.first.must_equal "Male"
        attributes_for_node("Title")["Male"].value.must_equal "no"
      end

      it "should raise an error if given an attribute that isn't expected" do
        proc { subject.title "Sir", knight: "yes" }.must_raise InvalidInputError
      end

      it "should not include empty, optional nodes" do
        subject.name ""
        nodes("Name").must_be_empty
      end

      it "should replace newlines with two spaces if replace_newlines is truthy and not a string" do
        subject.biography "I'm\na\nvery\nboring\nperson"
        value_of_node("Biography").must_equal "I'm  a  very  boring  person"
      end

      it "should replace newlines with the given text if replace_newlines is truthy and a string" do
        subject.telegram "Urgent\nEnemy troops en-route\nAttack at dawn\n"
        value_of_node("Telegram").must_equal "Urgent STOP Enemy troops en-route STOP Attack at dawn STOP "
      end
    end
  end
end
