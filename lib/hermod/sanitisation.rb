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

module Hermod
  module Sanitisation
    # TODO: replace this module with something better
    # Any replacement should make it possible for both yes only attributes and
    # yes/no attributes to work correctly.

    private

    # Private: alters attributes so a true becomes "yes", a no isn't sent and
    # anything else gets turned into a String.
    #
    # value - the non-sanitised value
    #
    # Returns the sanitised value of the attribute ready for sending to HMRC.
    def sanitise_attribute(value)
      case value
      when true
        XmlSectionBuilder::YES
      when false
        nil # Attributes aren't included if they're false
      else
        value.to_s
      end
    end
  end
end
