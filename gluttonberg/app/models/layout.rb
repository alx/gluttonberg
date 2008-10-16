module Gluttonberg
  class Layout
    include DataMapper::Resource

    property :id,       Serial
    property :name,     String, :length => 100, :nullable => false
    property :filename, String, :length => 100, :nullable => false

    has n, :pages
  end
end
