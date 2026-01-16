# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Usar UUID como primary key por padrão
  # Configurar no migration: create_table :nome, id: :uuid
end
