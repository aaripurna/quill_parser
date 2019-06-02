require "quill_parser/base"
require "json"

module QuillParser
	class Delta < Base
    attr_reader :delta

    def initialize(delta)
      @delta = JSON.parse(delta)["ops"]
    end

    def to_html
    end
    
    def self.parse(delta)
      self.new(delta).to_html
    end  

    # private

    def convert_to_lines
      lines = delta.inject([{block: :p, inlines: []}]) do |lines, item|
        if item["attributes"]&.keys&.include?("blackquote")
          lines.last[:block] = [ :p, :blackquote ]
          lines << { block: :p, inlines: [] }
        elsif item["attributes"]&.keys&.include?("code-block")
          lines.last = :pre
          lines << { block: :p, inlines: [] }
        else
          unless item["insert"] == "\n"
            converted = convert_inline(item["insert"], item["attributes"])
            p converted
          end
        end
      end
    end

    def convert_inline(text, attributes)
      attrs = []
      if attributes
        html = attributes.keys.map { |k| ops[k.to_s] }
        only_style = html.detect { |h| h["type"] == "tag" || h["type"] == "embed" }.nil?
        if only_style
          style = ""
          attributes.each do |key, value|
            style << %Q|#{ops[key.to_s]["prop"]}:#{value}; |
          end
          attrs << [%Q|<span style="#{style}">|, "</span>"]
        else
          has_style = !(html.detect { |h| h["type"] == "style"}.nil?)
          has_tag = !(html.detect { |h| h["type"] == "tag"}.nil?)
          has_embeded = !(html.detect { |h| h["type"] == "embed" }.nil?)
  
          if has_tag && !has_style
            attributes.each do |key, value|
              attrs << ["<#{ops[key.to_s]["tag"]}>", "</#{ops[key.to_s]["tag"]}>"]
            end
          elsif has_tag && has_style
            style = ""
            tags = []
            attributes.each do |key, value|
              if ops[key.to_s]["type"] == "style"
                style << %|#{ops[key.to_s]["prop"]}:#{value}; |
              elsif !boolean?(value)
                tags << [%Q|<#{ops[key.to_s]["tag"]} #{ops[key.to_s]["attribute"]}="#{value}">|, "</#{ops[key.to_s]["tag"]}>"]
              else
                tags << ["<#{ops[key.to_s]["tag"]}>", "</#{ops[key.to_s]["tag"]}>"]
              end
            end
            tags.first[0].insert(-2, %Q| style="#{style}" |)
            attrs.concat(tags)
          elsif has_embeded
            attrs << [%Q|<#{ops[key.to_s]['tag']} #{ops[key.to_s]['prop']}="#{value}" >|,"</#{ops[key.to_s]['tag']}>"]
          end
        end
      end
      {
        text: text,
        attrs: attrs
      }
    end

    def boolean?(value)
      value.is_a?(TrueClass) || value.is_a?(FalseClass)
    end

    def ops
      self.class.ops
    end
  end	
end
