require "minitest_helper"

module HMRC
  module GovTalk
    describe XmlSection do
      describe "building an XML generating class with no arguments" do
        subject do
          DummyXML = XmlSection.build { |builder| }
          DummyXML.new {}
        end

        it "should use the class name as the XML node name" do
          subject.to_xml.name.must_equal "DummyXML"
        end
      end

      describe "building an XML generating class with a custom node name" do
        subject do
          DummyXML2 = XmlSection.build(xml_name: "Testing") { |builder| }
          DummyXML2.new {}
        end

        it "should use the class name as the XML node name" do
          subject.to_xml.name.must_equal "Testing"
        end
      end
    end
  end
end
