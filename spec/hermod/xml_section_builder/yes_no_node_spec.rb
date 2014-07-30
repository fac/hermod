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
