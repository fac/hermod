require "minitest_helper"

module Hermod
  describe XmlSection do

    DateTimeXml = XmlSection.build(formats: {datetime: "%Y-%m-%d %H:%M:%S"}) do |builder|
      builder.datetime_node :published
      builder.datetime_node :redacted, optional: true
    end

    describe "Date nodes" do
      subject do
        DateTimeXml.new do |dummy|
          dummy.published DateTime.new(2015, 3, 14, 12, 30, 56)
        end
      end

      it "should format the datetime with the given format string" do
        value_of_node("Published").must_equal "2015-03-14 12:30:56"
      end

      it "should raise an error if given something that isn't a date" do
        proc { subject.redacted "yesterday" }.must_raise InvalidInputError
      end

      it "should ignore blank dates if the date is optional" do
        subject.redacted nil
        nodes("Redacted").must_be_empty
      end
    end
  end
end
