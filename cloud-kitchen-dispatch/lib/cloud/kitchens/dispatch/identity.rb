# frozen_string_literal: true

module Cloud
  module Kitchens
    module Dispatch
      # Gem identity information.
      module Identity
        NAME          = "kitchen-ctl"
        LABEL         = "Cloud Kitchens Dispatch"
        VERSION       = "0.1.2"
        VERSION_LABEL = "#{LABEL} #{VERSION}"
        COPYRIGHT     = '© 2020 Konstantin Gredeskoul, All rights reserved. '
        LICENSE       = 'MIT License'
        META          = [{ name: NAME, version: VERSION, copyright: COPYRIGHT, license: LICENSE, label: LABEL }].freeze
        HEADER        = ["#{NAME} (v#{VERSION})", COPYRIGHT + LICENSE].freeze
      end
    end
  end
end
