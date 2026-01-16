# Script para atualizar o storage_usado de todos os workspaces existentes
# Execute com: rails runner db/scripts/update_workspace_storage.rb

puts "Atualizando storage_usado de todos os workspaces..."

Workspace.find_each do |workspace|
  storage_usado = workspace.calcular_storage_usado
  workspace.update_column(:storage_usado, storage_usado)
  puts "Workspace #{workspace.nome}: #{storage_usado} bytes (#{(storage_usado / 1.megabyte.to_f).round(2)} MB)"
end

puts "\nAtualização concluída!"
