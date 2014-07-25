require "minitest_helper"

module HMRC
  module GovTalk
    ParentXml = XmlSection.build do |builder|
      builder.parent_node :inner
    end

    InnerXml = XmlSection.build do |builder|
      builder.string_node :inside
    end

    describe XmlSection do
      describe "Parent XML nodes" do
        subject do
          ParentXml.new do |outer|
            outer.inner(InnerXml.new do |inner|
              inner.inside "layered like an onion"
            end)
          end
        end

        it "should correctly wrap the inner XML" do
          expected = "<ParentXml>\n  <InnerXml>\n    <Inside>layered like an onion</Inside>\n  </InnerXml>\n</ParentXml>"
          subject.to_xml.to_s.must_equal expected
        end
      end
    end
  end
end
