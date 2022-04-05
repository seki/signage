# -*- coding: utf-8 -*-
require 'tofu'
require 'pathname'
require 'pp'

module Tofu
  class Tofu
    def normalize_string(str_or_param)
      str ,= str_or_param
      return '' unless str
      str.force_encoding('utf-8').strip
    end
  end
end

module Signage
  class Session < Tofu::Session
    def initialize(bartender, hint='')
      super
      @base = BaseTofu.new(self)
      @signage = SignageTofu.new(self)
    end
    attr_reader :user
    
    def do_GET(context)
      context.res_header('cache-control', 'no-store')
      super(context)
    end

    def lookup_view(context)
      pp context.req.path_info
      case context.req.path_info
      when '/settings.html'
        @base
      else
        @signage
      end
    end
  end

  class BaseTofu < Tofu::Tofu
    set_erb(__dir__ + '/base.html')

    def initialize(session)
      super(session)
    end

    def tofu_id
      'base'
    end
  end

  class ImageTrack
    def initialize
      size = 12 # const
      src = %w(P4150004.jpg P4180002.jpg P4180005.jpg).map {|x|
        "https://www.druby.org/images/#{x}"
      }
      a, b = 12.divmod(src.size)
      @images = src * a + src[0, b]
      @fade = 4
      @display = 6
    end
    attr_reader :images, :fade, :display

    def total_time
      @images.size * (@fade + @display)
    end

    def phase_1
      @fade * 100 / total_time
    end

    def phase_2
      (@fade + @display) * 100 / total_time
    end

    def phase_3
      (@fade + @display + @fade) * 100 / total_time
    end
  end

  class TextTrack
    def initialize
      @text = ["こんにちは、世界。Hello, World.", "もう一度 Hello, Again."]
    end
    attr_reader :text

    def total_time
      @text.size * 10
    end
  end

  class SignageTofu < Tofu::Tofu
    set_erb(__dir__ + '/signage.html')

    def initialize(session)
      super(session)
      @image_track = ImageTrack.new
      @text_track = TextTrack.new
    end
    attr_reader :image_track, :text_track

    def tofu_id
      'signage'
    end
  end
end