Dialect.fixture {{
  :code => /\w{2}/.gen.downcase,
  :name => /\w+/.gen.capitalize
}}

Locale.fixture {{
  :name => /\w+/.gen.capitalize,
  :dialects => 2.of { Dialect.pick }
}}

Template.fixture(:view) {{
  :name       => (label = /\w+/.gen),
  :file_name  => label.downcase.gsub(" ", "_"),
  :type       => :view,
  :sections   => (1..4).of { TemplateSection.generate} 
}}

Template.fixture(:layout) {{
  :name       => (label = /\w+/.gen),
  :file_name  => label.downcase.gsub(" ", "_"),
  :type       => :layout
}}

TemplateSection.fixture {{
  :label => (label = /\w+/.gen),
  :name  => label.downcase.gsub(" ", "_"),
  :type  => "rich_text_content"
}}

Page.fixture(:no_templates) {{
  :name     => (name = /\w+/.gen),
  :slug     => name.downcase.gsub(" ", "_")
}}

Page.fixture(:parent) {{
  :name     => (name = /\w+/.gen),
  :slug     => name.downcase.gsub(" ", "_"),
  :template => Template.pick(:view),
  :layout   => Template.pick(:layout)
}}

Page.fixture(:child) {{
  :parent_id  => Page.pick(:parent).id,
  :name       => (name = /\w+/.gen),
  :slug       => name.downcase.gsub(" ", "_"),
  :template   => Template.pick(:view),
  :layout     => Template.pick(:layout)
}}

PageLocalization.fixture {{
  :name => (name = /\w+/.gen),
  :slug => name.downcase.gsub(" ", "_")
}}

RichTextContent::Localization.fixture {{
  :text => (3..5).of { /[:paragraph:]/.generate }.join("\n\n")
}}