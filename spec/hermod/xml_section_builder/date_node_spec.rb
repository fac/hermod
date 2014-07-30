# Copyright 2014 FreeAgent Central Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "minitest_helper"

module Hermod
  describe XmlSection do

    DateXml = XmlSection.build(formats: {date: "%Y-%m-%d"}) do |builder|
      builder.date_node :date_of_birth
      builder.date_node :anniversary
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
    end
  end
end
