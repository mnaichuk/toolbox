module Toolbox
  module Helpers
    def unique_email
      Faker::Internet.unique.email
    end

    def unique_uid
      @used_uids ||= [].to_set
      loop do
        uid = "UID#{SecureRandom.hex(5).upcase}"
        unless @used_uids.include?(uid)
          @used_uids << uid
          return uid
        end
      end
    end

    def api_v2_get(path, query: {}, headers: {}, jwt: nil)
      headers['Authorization'] = 'Bearer ' + jwt if jwt
      url = URI.join(@root_url, '/api/v2/', path.gsub(/\A\/+/, ''))
      Faraday.get(url, query, headers).assert_success!
    end

    def api_v2_post(path, data: {}, headers: {}, jwt: nil)
      headers['Authorization'] = 'Bearer ' + jwt if jwt
      headers['Content-Type']  = 'application/json'
      url = URI.join(@root_url, '/api/v2/', path.gsub(/\A\/+/, ''))
      Faraday.post(url, data.to_json, headers).assert_success!
    end

    def api_v2_jwt_for(user, payload = {})
      payload = payload.dup
      payload.merge!(user.slice(:email, :uid, :level, :state))
      payload.reverse_merge! \
      iat: Time.now.to_i,
      exp: 5.minutes.from_now.to_i,
      jti: SecureRandom.uuid,
      sub: 'session',
      iss: 'barong',
      aud: ['peatio']
      JWT.encode(payload, @api_v2_jwt_key, @api_v2_jwt_algorithm)
    end

    def print_options(config)
      Kernel.printf 'print_options not implemented yet.'
      # Use StressTrading::Config pring each value and key.
    end

    def register_user(user)
      api_v2_get('/members/me', jwt: api_v2_jwt_for(user))
    end
  end
end
