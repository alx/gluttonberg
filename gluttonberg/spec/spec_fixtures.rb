module Gluttonberg
  
  module Library
    Asset.fixture {{
      :name         => (1..3).of { /\w+/.gen }.join(" ").capitalize,
      :description  => (1..2).of { /[:paragraph:]/.generate }.join("\n\n"),
      :file         => Library.mock_file(File.join(File.dirname(__FILE__), "fixtures"))
    }}
    
    def self.mock_file(path)
      file = Dir.entries(path).reject{|c| c[0].chr == '.'}.map{ |c| path / c }.pick
      {
        :filename     => /\w+/.gen, 
        :content_type => /\w+\/\w+/.gen, 
        :size         => (300...8000).pick, 
        :tempfile     => file
      }
    end
  end
  
  Dialect.fixture {{
    :code => /\w{2}/.gen.downcase,
    :name => /\w+/.gen.capitalize
  }}

  Locale.fixture {{
    :name => /\w+/.gen.capitalize,
    :dialects => (1..3).of { Dialect.pick }
  }}

  Page.fixture(:no_templates) {{
    :name     => (name = (1..3).of { /\w+/.gen }.join(" ")).capitalize,
    :slug     => name.downcase.gsub(" ", "_")
  }}

  Page.fixture(:parent) {{
    :name     => (name = /\w+/.gen),
    :slug     => name.downcase.gsub(" ", "_"),
    :template => Template.pick(:view),
    :layout   => Template.pick(:layout)
  }}

  Page.fixture(:child) {{
    :parent     => Page.pick(:parent),
    :name       => (name = /\w+/.gen),
    :slug       => name.downcase.gsub(" ", "_"),
    :template   => Template.pick(:view),
    :layout     => Template.pick(:layout)
  }}

  PageLocalization.fixture {{
    :name => (name = (1..3).of { /\w+/.gen }).capitalize,
    :slug => name.downcase.gsub(" ", "_")
  }}

  RichTextContent::Localization.fixture {{
    :text => (3..5).of { /[:paragraph:]/.generate }.join("\n\n")
  }}
  
  PageType.fixture {{
    :name     => (1..3).of { /\w+/.gen }.join(" ").capitalize,
    :filename => /\w+/.gen
  }}
end

# 5.of { Dialect.generate }
# 3.of { Locale.generate }
# 3.of { Template.generate(:layout) }
# 8.of { Template.generate(:view) }
# 5.of { Page.generate(:parent) }
# 12.of { Page.generate(:child) }