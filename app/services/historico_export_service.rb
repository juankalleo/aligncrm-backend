# frozen_string_literal: true

require "csv"

# Serviço para exportação de histórico
class HistoricoExportService
  class << self
    def to_csv(registros)
      CSV.generate(headers: true, col_sep: ";") do |csv|
        csv << headers

        registros.find_each do |registro|
          csv << row(registro)
        end
      end
    end

    private

    def headers
      [
        "ID",
        "Data/Hora",
        "Usuário",
        "Ação",
        "Entidade",
        "Nome da Entidade",
        "Detalhes",
        "IP"
      ]
    end

    def row(registro)
      [
        registro.id,
        registro.created_at.strftime("%d/%m/%Y %H:%M:%S"),
        registro.usuario.nome,
        traduzir_acao(registro.acao),
        traduzir_entidade(registro.entidade),
        registro.entidade_nome,
        registro.detalhes.to_json,
        registro.ip
      ]
    end

    def traduzir_acao(acao)
      {
        "criar" => "Criou",
        "atualizar" => "Atualizou",
        "excluir" => "Excluiu",
        "arquivar" => "Arquivou",
        "restaurar" => "Restaurou",
        "login" => "Login",
        "logout" => "Logout",
        "permissao_alterada" => "Alterou permissão"
      }[acao] || acao
    end

    def traduzir_entidade(entidade)
      {
        "projeto" => "Projeto",
        "tarefa" => "Tarefa",
        "usuario" => "Usuário",
        "arquivo" => "Arquivo",
        "link" => "Link",
        "fluxograma" => "Fluxograma",
        "evento" => "Evento"
      }[entidade] || entidade
    end
  end
end
