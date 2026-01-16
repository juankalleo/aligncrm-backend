# frozen_string_literal: true

namespace :tarefas do
  desc 'Arquiva automaticamente tarefas concluídas há mais de 5 dias'
  task arquivar_antigas: :environment do
    puts "Iniciando arquivamento de tarefas antigas..."
    
    # Busca tarefas concluídas há mais de 5 dias que ainda não foram arquivadas
    tarefas = Tarefa.concluidas_antigas
    count = 0

    tarefas.find_each do |tarefa|
      begin
        tarefa.arquivar!
        count += 1
        puts "  ✓ Tarefa ##{tarefa.id} arquivada (#{tarefa.titulo})"
      rescue => e
        puts "  ✗ Erro ao arquivar tarefa ##{tarefa.id}: #{e.message}"
      end
    end

    puts "Arquivamento concluído: #{count} tarefa(s) arquivada(s)"
  end

  desc 'Exibe estatísticas sobre tarefas arquivadas'
  task stats_arquivadas: :environment do
    total_tarefas = Tarefa.count
    total_arquivadas = Tarefa.arquivadas.count
    total_nao_arquivadas = Tarefa.nao_arquivadas.count
    total_concluidas = Tarefa.where(status: :concluida).count
    total_concluidas_arquivadas = Tarefa.where(status: :concluida).arquivadas.count
    total_concluidas_nao_arquivadas = Tarefa.where(status: :concluida).nao_arquivadas.count

    puts "\n=== Estatísticas de Tarefas ==="
    puts "Total de tarefas: #{total_tarefas}"
    puts "Tarefas arquivadas: #{total_arquivadas}"
    puts "Tarefas não arquivadas: #{total_nao_arquivadas}"
    puts "\nTarefas concluídas:"
    puts "  Total: #{total_concluidas}"
    puts "  Arquivadas: #{total_concluidas_arquivadas}"
    puts "  Não arquivadas: #{total_concluidas_nao_arquivadas}"
    puts "================================\n"
  end
end
