require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Pinterest < OmniAuth::Strategies::OAuth2
      option :client_options, {
        :site => 'https://api.pinterest.com/',
        :authorize_url => 'https://pinterest.com/oauth/',
        :token_url => 'https://api.pinterest.com/v5/oauth/token',
        :token_method => :post
      }

      def request_phase
        options[:scope] ||= 'read_public'
        options[:response_type] ||= 'code'
        super
      end

      uid { raw_info['id'] }

      info { raw_info }

      def raw_info
        fields = 'first_name,id,last_name,url,account_type,username,bio,image'
        @raw_info ||= access_token.get("/v1/me/?fields=#{fields}").parsed['data']
      end

      def ssl?
        true
      end

       # You can pass +display+, +scope+, or +auth_type+ params to the auth request, if you need to set them dynamically.
      # You can also set these options in the OmniAuth config :authorize_params option.
      #
      # For example: /auth/facebook?display=popup
      def authorize_params
        super.tap do |params|
          %w[display scope auth_type].each do |v|
            if request.params[v]
              params[v.to_sym] = request.params[v]
            end
          end

          params[:scope] ||= DEFAULT_SCOPE
        end
      end

      def build_access_token
        options.token_params.merge!(headers: { 'Authorization' => basic_auth_header })
        super
      end

      def basic_auth_header
        auth = Base64.strict_encode64("#{options[:client_id]}:#{options[:client_secret]}")
        "Basic #{auth}"
      end

      def callback_url
        full_host + script_name + callback_path
      end

    end
  end
end
