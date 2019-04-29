# Hermod

[![Code
Climate](https://codeclimate.com/github/fac/hermod/badges/gpa.svg)](https://codeclimate.com/github/fac/hermod)
[![Build Status](https://travis-ci.org/fac/hermod.svg?branch=master)](https://travis-ci.org/fac/hermod)

This gem makes it easier to talk to HMRC through the [Government Gateway][1] by
providing a DSL you can use to create Ruby classes to build the XML required in
a form that meets HMRC's specification.

It ensures that nodes appear in the correct order with the correct formatting
and allows you to preprocess values and apply validations at submission time.

[1]: http://www.hmrc.gov.uk/schemas/GatewayDocumentSubmissionProtocol_V3.1.pdf "HMRC's specification"

## Installation

Add this line to your application's Gemfile:

    gem 'hermod'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hermod

## Usage

This gem allows you to describe classes that represent a section of XML that
will be sent to HMRC. This description includes type, validation, and format
information as well as any runtime mutations that should be applied to inputs
you provide.

### Supported Types

The following types of XML node are supported:

* Strings
* Integers
* Dates
* Yes/No
* Yes only
* Monetary values
* Parent XML

#### Global Options

There are some options that can be passed to all or some of the different node
types.

**XML Name**

By default the name used for the XML node is generated by converting the node
name from `snake_case` to `TitleCase`. For example, the `date_of_birth` node in
the example above would become `DateOfBirth`. By providing an `xml_name` you
can override this, thus changing it to `BirthDate`

*Building an XmlSection*
```ruby
Example = Hermod::XmlSection.build do |builder|
  builder.string_node :ni_number, xml_name: "NINumber"
end
```

*Using that XmlSection*
```ruby
Example.new do |example|
  example.ni_number "AB123456C"
end
```

*The Resulting XML*
```xml
<Example>
  <NINumber>AB123456C</NINumber>
</Example>
```

**Attributes**

Any node can have attributes which are defined by passing a `Hash` of symbol,
string pairs. The symbol is used to refer to the attribute when setting the
value of the node and the string is the form that will be sent to HMRC.

*Building an XmlSection*
```ruby
Example = Hermod::XmlSection.build do |builder|
  builder.string_node :tax_code, attributes: {week_1_month_1: "WeekOneMonthOne"}
end
```

*Using that XmlSection*
```ruby
Example.new do |example|
  example.tax_code "1000L", week_1_month_1: true
end
```

*The Resulting XML*
```xml
<Example>
  <TaxCode WeekOneMonthOne="yes">1000L</TaxCode>
</Example>
```

**Optional**

Not all nodes allow this but for those that do (String, Date and Monetary nodes)
if a node is marked as optional then any blank values (like nil or an empty
string) will be ignored.

*Building an XmlSection*
```ruby
Example = Hermod::XmlSection.build do |builder|
  builder.string_node :middle_name, optional: true
end
```

*Using that XmlSection*
```ruby
Example.new do |example|
  example.middle_name nil
end
```

*No XML will be produced*

#### String Nodes

String nodes handle a wide variety of cases and can take regular expressions
and lists of values to restrict the provided values. If they are marked as
optional then the node will be excluded if the value given is blank
(`nil` or the empty string).

**Regular Expressions**

The `matches` option allows you to provide a regular expression that is used to
validate the input. If you try to pass a value that doesn't match the expression
a `Hermod::InvalidInputError` will be raised.

*Building an XmlSection*
```ruby
Example = Hermod::XmlSection.build do |builder|
  builder.string_node :ni_number, matches: /\A[A-Z]{2}[0-9]{6}[A-D ]\z/
end
```

*Using that XmlSection*
```ruby
Example.new do |example|
  example.ni_number "I can't remember it"
end
```

*A `Hermod::InvalidInputError` will be raised*


**Allowable Values**

The `allowable_values` lets you specify a list of string that are allowed for
this node. Passing a value not in this list will raise
a `Hermod::InvalidInputError`.

*Building an XmlSection*
```ruby
Example = Hermod::XmlSection.build do |builder|
  builder.string_node :mood, allowable_values: %w(Happy Sad Hangry)
end
```

*Using that XmlSection*
```ruby
Example.new do |example|
  example.gender "Wrathful"
end
```

*A `Hermod::InvalidInputError` will be raised*

**Input Mutator**

The `input_mutator` option allows you to provide a lambda that is provided with
two arguments, the value assigned to the node and the `Hash` of attributes (if
any). This can be used to change either or both of these and the lambda must
return both the value and the attributes as an array (`[value, attributes]`)
after they've been modified.

*Building an XmlSection*
```ruby
Example = Hermod::XmlSection.build do |builder|
  builder.string_node :ni_number, xml_name: "NINO", optional: true, matches: /\A[A-Z]{2}[0-9]{6}[A-D ]\z/,
    input_mutator: (lambda { |value, attrs| [value.delete(' ').upcase, attrs] })
end
```

*Using that XmlSection*
```ruby
Example.new do |example|
  example.ni_number "AB 12 34 56 C"
end
```

*The Resulting XML*
```xml
<Example>
  <NiNumber>AB123456C</NiNumber>
</Example>
```

#### Integer Nodes

Integer nodes let you provide a whole number that won't be formatted as
a monetary value.

**Range**

You can specify a `range` option as a hash with a `min` and `max` value. If you
provide a value outwith the range (inclusive) then
a `Hermod::InvalidInputError` exception will be raised.

*Building an XmlSection*
```ruby
Example = Hermod::XmlSection.build do |builder|
  builder.integer_node :day_of_the_week, range: {min: 1, max: 7}
end
```

*Using that XmlSection*
```ruby
Example.new do |example|
  example.day_of_the_week 8
end
```

*A `Hermod::InvalidInputError` will be raised*

#### Date Nodes

Date nodes let you send through a date to HMRC. It will be converted to the
given date format which you can specify as a format string in the `formats`
option passed to the `Hermod::XmlSection.build` call. Anything that responds to
`strftime` can be passed to the node. Anything else will cause an
`Hermod::InvalidInputError` exception to be raised.

*Building an XmlSection*
```ruby
Example = Hermod::XmlSection.build(formats: {date: "%Y-%m-%d"}) do |builder|
  builder.date_node :date_of_birth
end
```

*Using that XmlSection*
```ruby
Example.new do |example|
  example.date_of_birth Date.new(1988, 8, 13)
end
```

*The Resulting XML*
```xml
<Example>
  <DateOfBirth>1988-08-13</DateOfBirth>
</Example>
```

#### DateTime Nodes

Datetime nodes let you send through a date and a time to HMRC. It will be
converted to the given datetime format which you can specify as a format
string in the `formats` option passed to the `Hermod::XmlSection.build`
call. Anything that responds to `strftime` can be passed to the node.
Anything else will cause an `Hermod::InvalidInputError` exception to be raised.

*Building an XmlSection*
```ruby
Example = Hermod::XmlSection.build(formats: {datetime: "%Y-%m-%d %H:%M:%S"}) do |builder|
  builder.datetime_node :published
end
```

*Using that XmlSection*
```ruby
Example.new do |example|
  example.published DateTime.new(2014, 9, 3, 10, 42, 50)
end
```

*The Resulting XML*
```xml
<Example>
  <Published>2014-09-03 10:42:50</Published>
</Example>
```

#### Yes Nodes

Yes nodes allow you to send a boolean value to HMRC provided that value is
true. Nothing will be sent if the value is false. This pattern is commonly used
by HMRC for optional boolean nodes. They're known as "yes nodes" because HMRC
use "yes" and "no" in place of true and false in their XML.

*Building an XmlSection*
```ruby
Example = Hermod::XmlSection.build do |builder|
  builder.yes_node :verily
  builder.yes_node :nae
end
```

*Using that XmlSection*
```ruby
Example.new do |example|
  example.verily true
  example.nae false
end
```

*The Resulting XML*
```xml
<Example>
  <Verily>yes</Verily>
</Example>
```

#### Yes/No Nodes

This works in a similar fashion to the yes nodes described above but if a false
value is provided a "no" will be sent instead of the node being excluded.

*Building an XmlSection*
```ruby
Example = Hermod::XmlSection.build do |builder|
  builder.yes_no_node :verily
  builder.yes_no_node :nae
end
```

*Using that XmlSection*
```ruby
Example.new do |example|
  example.verily true
  example.nae false
end
```

*The Resulting XML*
```xml
<Example>
  <Verily>yes</Verily>
  <Nae>no</Nae>
</Example>
```

#### Monetary Nodes

Monetary nodes let you send through monetary values to HMRC. They will be
converted to the given monetary format which you can specify as a format string
in the `formats` option passed to the `Hermod::XmlSection.build` call. Values
passed to monetary nodes should be BigDecimal objects.

**Negative**

By default negative numbers are allowed. If you need to prevent them you can
set the `negative` option to false.

*Building an XmlSection*
```ruby
Example = Hermod::XmlSection.build(formats: {money: "%.2f"}) do |builder|
  builder.monetary_node :taxable_pay, negative: false
end
```

*Using that XmlSection*
```ruby
Example.new do |example|
  example.taxable_pay BigDecimal.new("-300")
end
```

*A `Hermod::InvalidInputError` will be raised*

**Whole Units**

Sometimes HMRC require that you send through a value as a whole unit. If this
is the case you can set the `whole_units` option to true and if an invalid
value is passed a `Hermod::InvalidInputError` exception will be raised.

*Building an XmlSection*
```ruby
Example = Hermod::XmlSection.build(formats: {money: "%.2f"}) do |builder|
  builder.monetary_node :lower_earnings_limit, whole_units: true
end
```

*Using that XmlSection*
```ruby
Example.new do |example|
  example.lower_earnings_limit BigDecimal.new("153.49")
end
```

*A `Hermod::InvalidInputError` will be raised*

**Optional**

For monetary nodes the `optional` option will also prevent zero values from
being submitted.

*Building an XmlSection*
```ruby
Example = Hermod::XmlSection.build(formats: {money: "%.2f"}) do |builder|
  builder.monetary_node :taxable_pay
  builder.monetary_node :tax, optional: true
end
```

*Using that XmlSection*
```ruby
Example.new do |example|
  example.taxable_pay BigDecimal.new("1000")
  example.tax BigDecimal.new("0")
end
```

*The Resulting XML*
```xml
<Example>
  <TaxablePay>1000.00</TaxablePay>
</Example>
```

#### Parent Nodes

Parent nodes are the way you specify that the contents of this node is another
`XmlSection`. The `xml_name` is ignored (whether you supply it or rely on the
default) so the given `symbolic_name` is just the name of the method you call
to add content. Instead the node name is picked up from the class name of the
XmlSection you add as a child.

*Building an XmlSection*
```ruby
Example = Hermod::XmlSection.build do |builder|
  builder.parent_node :inner
end

Inside = Hermod::XmlSection.build do |builder|
  builder.string_node :text"
end
```

*Using that XmlSection*
```ruby
Example.new do |example|
  example.inner(Inside.new do |inside|
    inside.text "Hello, World"
  end)
end
```

*The Resulting XML*
```xml
<Example>
  <Inside>
    <Text>Hello, World</Text>
  </Inside>
</Example>
```

### Full Example

This is all explained in more detail below but a reasonably complex XML section
may be described as follows.

```ruby
Details = Hermod::XmlSection.build(xml_name: "EmployeeDetails", formats: Payroll::RTI::FORMATS) do |builder|
  builder.string_node :ni_number, xml_name: "NINO", optional: true, matches: /\A[A-Z]{2}[0-9]{6}[A-D ]\z/,
  input_mutator: (lambda do |value, attrs|
  [value.delete(' ').upcase, attrs]
  end)
  builder.parent_node :name
  builder.parent_node :address
  builder.date_node   :date_of_birth, xml_name: "BirthDate", optional: true
  builder.string_node :gender, allowable_values: %w(Male Female),
  input_mutator: (lambda do |input, attrs|
  [input == AppConstants::MALE ? Payroll::RTI::MALE : Payroll::RTI::FEMALE, attrs]
  end)
end
```

This creates a class that can be used like so.

```ruby
xml = Payroll::RTI::Employee::Details.new do |details|
  details.name(Payroll::RTI::Name.new do |name|
    name.title employee.title
    employee.forenames.each do |forename|
      name.forename forename
    end
    name.surname employee.last_name
  end)
  details.gender employee.gender

  details.address(Address.new do |address|
    employee.address_lines.each do |line|
      address.line line
    end
    address.postcode profile.postcode
  end)

  details.ni_number employee.ni_number
  details.date_of_birth employee.date_of_birth
end)
```

Nodes are defined in the builder in the order they will be sent to HMRC. They
can then be called in any order when using the class. Calling the same method
multiple times will add multiple instances of that node and they will be output
in the order the calls were made in.

## Contributing

1. Fork it ( https://github.com/fac/hermod/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Build and release a new version

Once you're happy that there are enough new features to require a new release, you will need the following steps.

1. Update the `version.rb` file to a new version. This should be addressed with [semantic versioning](https://semver.org/spec/v2.0.0.html).
2. Update the CHANGELOG.md file to use the new version number where it said `Unreleased` previously. Add a new, empty `Unreleased` section.
3. Merge the change to `version.rb` to `master`; this will automatically trigger a release of the gem to the internal gem server. For more on this, see: [internal gems](https://www.notion.so/freeagent/Internal-gems-5c8098501fcc48e4921be31aa9b4d495#e2944d2de5ce4fd4a6c244a4697cc1fd).
4. To point your application to the newly released gem, use the following. This will modify your Gemfile.lock to reflect the latest version number

    ```ruby
    gem update sales_tax_calculator
    ```
