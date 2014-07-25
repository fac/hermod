require "minitest_helper"

module Hermod

  NamedXML = XmlSection.build(xml_name: "Testing") { |builder| }
  UnnamedXML = XmlSection.build { |builder| }
  OrderingXML = XmlSection.build do |builder|
    builder.string_node :first
    builder.string_node :repeated
    builder.string_node :last
  end

  describe XmlSection do
    describe "building an XML generating class with no arguments" do
      subject do
        UnnamedXML.new {}
      end

      it "should use the class name as the XML node name" do
        subject.to_xml.name.must_equal "UnnamedXML"
      end
    end

    describe "building an XML generating class with a custom node name" do
      subject do
        NamedXML.new {}
      end

      it "should use the class name as the XML node name" do
        subject.to_xml.name.must_equal "Testing"
      end
    end

    describe "#to_xml" do
      subject do
        OrderingXML.new do |ordering|
          ordering.repeated "beta"
          ordering.last "epsilon"
          ordering.repeated "gamma"
          ordering.first "alpha"
        end
      end

      it "should order nodes by the order they were defined when the class was built" do
        node_by_index(0).name.must_equal "First"
        node_by_index(0).content.must_equal "alpha"

        node_by_index(1).name.must_equal "Repeated"
        node_by_index(1).content.must_equal "beta"

        node_by_index(-1).name.must_equal "Last"
        node_by_index(-1).content.must_equal "epsilon"
      end

      it "should order nodes called multiple times in the order they were called" do
        node_by_index(1).name.must_equal "Repeated"
        node_by_index(1).content.must_equal "beta"

        node_by_index(2).name.must_equal "Repeated"
        node_by_index(2).content.must_equal "gamma"
      end

      it "should order nodes at XML generation time, not at call time" do
        subject.repeated "delta"

        node_by_index(-2).name.must_equal "Repeated"
        node_by_index(-2).content.must_equal "delta"

        node_by_index(-1).name.must_equal "Last"
        node_by_index(-1).content.must_equal "epsilon"
      end
    end
  end
end
