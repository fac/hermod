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
