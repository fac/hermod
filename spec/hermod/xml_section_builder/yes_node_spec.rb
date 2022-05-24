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
          expect(value_of_node("Awesome")).must_equal "yes"
        end
      end

      describe "when not true" do
        subject do
          YesXml.new do |yes_xml|
            yes_xml.awesome false
          end
        end

        it "should not include the node" do
          expect(number_of_nodes("Awesome")).must_equal 0
        end
      end
    end
  end
end
