require "minitest_helper"

module Hermod
  describe XmlSection do

    MonetaryXml = XmlSection.build(formats: {money: "%.2f"}) do |builder|
      builder.monetary_node :pay
      builder.monetary_node :tax, optional: true
      builder.monetary_node :ni, xml_name: "NI", negative: false
      builder.monetary_node :pension, whole_units: true
      builder.monetary_node :student_loan, zero: false, negative: false
    end

    describe "Monetary nodes" do
      subject do
        MonetaryXml.new do |dummy|
          dummy.pay 123.45
          dummy.tax 0
        end
      end

      it "should format values with the provided format string" do
        value_of_node("Pay").must_equal "123.45"
      end

      it "should not include optional nodes if they're zero" do
        number_of_nodes("Tax").must_equal 0
      end

      it "should use xml_name as the node name if provided" do
        subject.ni 100
        number_of_nodes("NI").must_equal 1
      end

      it "should raise an error if given a negative number for a field that cannot be negative" do
        ex = proc { subject.ni -100 }.must_raise InvalidInputError
        ex.message.must_equal "ni cannot be negative"
      end

      it "should allow negative numbers for fields by default" do
        subject.pension(-100)
        value_of_node("Pension").must_equal "-100.00"
      end

      it "should not allow decimal values for whole unit nodes" do
        ex = proc { subject.pension BigDecimal("12.34") }.must_raise InvalidInputError
        ex.message.must_equal "pension must be in whole units"
      end

      it "should not allow zero for nodes that disallow it" do
        ex = proc { subject.student_loan 0 }.must_raise Hermod::InvalidInputError
        ex.message.must_equal "student_loan cannot be zero"
      end

      it "should treat blank nodes as zero nodes" do
        subject.ni nil
        value_of_node("NI").must_equal "0.00"

        subject.tax nil
        nodes("Tax").must_be_empty
      end
    end
  end
end
