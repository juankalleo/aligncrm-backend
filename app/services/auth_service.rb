# frozen_string_literal: true

# Serviço de Autenticação JWT
class AuthService
  class << self
    # Autenticar requisição via header Authorization
    def authenticate(auth_header)
      return nil unless auth_header.present?
      
      token = auth_header.split(" ").last
      decoded = decode_token(token)
      
      return nil unless decoded
      
      Usuario.find_by(id: decoded[:usuario_id], ativo: true)
    rescue JWT::DecodeError, JWT::ExpiredSignature
      nil
    end

    # Login de usuário
    def login(email:, senha:, ip: nil)
      usuario = Usuario.find_by(email: email.to_s.downcase)

      unless usuario&.authenticate(senha)
        return { success: false, error: "Email ou senha inválidos" }
      end

      unless usuario.ativo?
        return { success: false, error: "Conta desativada" }
      end

      token = generate_token(usuario)
      usuario.atualizar_ultimo_login!

      Historico.registrar!(
        acao: :login,
        entidade: :usuario,
        entidade_id: usuario.id,
        entidade_nome: usuario.nome,
        usuario: usuario,
        ip: ip
      )

      {
        success: true,
        data: {
          token: token,
          usuario: UsuarioSerializer.new(usuario).as_json,
          expiresIn: JwtConfig::EXPIRATION_TIME.to_i
        }
      }
    end

    # Registro de novo usuário
    def register(nome:, email:, senha:, ip: nil)
      usuario = Usuario.new(
        nome: nome,
        email: email,
        password: senha,
        role: :user
      )

      unless usuario.save
        return {
          success: false,
          error: "Erro ao criar conta",
          errors: usuario.errors.full_messages
        }
      end

      token = generate_token(usuario)

      Historico.registrar!(
        acao: :criar,
        entidade: :usuario,
        entidade_id: usuario.id,
        entidade_nome: usuario.nome,
        usuario: usuario,
        ip: ip
      )

      {
        success: true,
        data: {
          token: token,
          usuario: UsuarioSerializer.new(usuario).as_json,
          expiresIn: JwtConfig::EXPIRATION_TIME.to_i
        }
      }
    end

    private

    def generate_token(usuario)
      payload = {
        usuario_id: usuario.id,
        email: usuario.email,
        role: usuario.role,
        exp: JwtConfig::EXPIRATION_TIME.from_now.to_i,
        iat: Time.current.to_i,
        iss: JwtConfig::ISSUER
      }

      JWT.encode(payload, JwtConfig::SECRET_KEY, JwtConfig::ALGORITHM)
    end

    def decode_token(token)
      decoded = JWT.decode(
        token,
        JwtConfig::SECRET_KEY,
        true,
        {
          algorithm: JwtConfig::ALGORITHM,
          iss: JwtConfig::ISSUER,
          verify_iss: true
        }
      )

      HashWithIndifferentAccess.new(decoded.first)
    rescue JWT::DecodeError
      nil
    end
  end
end
