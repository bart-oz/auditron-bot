# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      protected

      def current_user
        @current_api_key&.user
      end

      private

      def authenticate_api_key!
        token = extract_token_from_header
        api_key = ApiKey.authenticate(token) if token.present?

        if api_key.present? && !api_key.expired?
          @current_api_key = api_key
          @current_api_key.touch_last_used
        else
          render_unauthorized
        end
      end

      def extract_token_from_header
        auth_header = request.headers["Authorization"]
        return nil if auth_header.blank?

        auth_header.gsub(/^Bearer\s+/, "")
      end

      def render_unauthorized
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end
  end
end
