require "minitest_helper"

module Hermod
  describe XmlSection do

    IntegerXml = XmlSection.build do |builder|
      builder.integer_node :day_of_the_week, range: {min: 1, max: 7}
    end

    describe "Integer nodes" do
      subject do
        IntegerXml.new
      end

      it "should accept a valid number" do
        subject.day_of_the_week 7
        value_of_node("DayOfTheWeek").must_equal "7"
      end

      it "should raise an error if the number is above the maximum" do
        proc { subject.day_of_the_week 8 }.must_raise InvalidInputError
      end

      it "should raise an error if the number is below the minimum" do
        proc { subject.day_of_the_week 0 }.must_raise InvalidInputError
      end
    end
  end
end
