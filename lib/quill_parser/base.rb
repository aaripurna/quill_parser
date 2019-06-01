require 'yaml'

module QuillParser
  class Base

    def self.ops
      self.load_ops
    end

    private

    def self.load_ops
      @@ops ||= YAML.load_file("lib/quill_parser/ops/delta_ops.yml")
    end
  end
end
