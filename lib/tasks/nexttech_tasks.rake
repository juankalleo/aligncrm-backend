namespace :nexttech do
  desc "Restaurar tarefas padrão no workspace 'NextTech'"
  task restore_tasks: :environment do
    workspace = Workspace.find_by(nome: 'NextTech')
    unless workspace
      puts "Workspace 'NextTech' não encontrado"
      next
    end

    proprietor = workspace.proprietario
    projeto = workspace.projetos.first

    unless projeto
      projeto = Projeto.create!(
        nome: 'Tarefas de Boas-vindas',
        descricao: 'Projeto criado automaticamente para restaurar tarefas',
        proprietario: proprietor,
        workspace: workspace
      )
      puts "Criado projeto #{projeto.nome} (#{projeto.id})"
    end

    sample = [
      { titulo: 'Configurar repositório', descricao: 'Clonar e configurar o repositório do projeto', prioridade: :alta },
      { titulo: 'Revisar backlog', descricao: 'Organizar as tarefas do backlog', prioridade: :media },
      { titulo: 'Configurar CI', descricao: 'Adicionar pipeline básico de CI', prioridade: :urgente },
      { titulo: 'Documentar ambiente', descricao: 'Escrever README com instruções locais', prioridade: :baixa }
    ]

    created = 0
    sample.each do |s|
      Tarefa.create!(
        titulo: s[:titulo],
        descricao: s[:descricao],
        prioridade: Tarefa.prioridades[s[:prioridade].to_s],
        projeto: projeto,
        criador: proprietor,
        status: :backlog
      )
      created += 1
    end

    puts "Criadas #{created} tarefas no workspace NextTech (projeto #{projeto.nome})"
  end
end
