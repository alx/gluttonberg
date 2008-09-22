migration 1, :add_dialects_locales_table  do
  up do
    create_table :dialects_locales do
      column :dialect_id, Integer
      column :locale_id,  Integer
    end
  end

  down do
    drop_table :dialects_locales
  end
end
