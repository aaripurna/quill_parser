require "quill_parser/base"
require "json"

module QuillParser
	class Delta < Base
    attr_accessor :delta

    def initialize(delta)
      @delta = JSON.parse(delta)["ops"]
      if @delta.nil?
        raise DeltaError.new "Invalid Delta file, it doesn't seem like a quill delta file"
      end
    end

    

  end	
end
