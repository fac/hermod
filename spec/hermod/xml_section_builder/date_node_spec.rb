require "minitest_helper"

module Hermod
  describe XmlSection do

    DateXml = XmlSection.build(formats: {date: "%Y-%m-%d"}) do |builder|
      builder.date_node :date_of_birth
      builder.date_node :anniversary, optional: true
    end

    describe "Date nodes" do
      subject do
        DateXml.new do |dummy|
          dummy.date_of_birth Date.new(1988, 8, 13)
        end
      end

      it "should format the date with the given date string" do
        value_of_node("DateOfBirth").must_equal "1988-08-13"
      end

      it "should raise an error if given something that isn't a date" do
        proc { subject.anniversary "yesterday" }.must_raise InvalidInputError
      end

      it "should ignore blank dates if the date is optional" do
        subject.anniversary nil
        nodes("Anniversary").must_be_empty
      end
    end
  end
end
