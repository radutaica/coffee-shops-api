# frozen_string_literal: true

module GraphqlHelpers
  def graphql_headers(api_key: Rails.application.credentials.dig(:graphql, :api_key) || ENV["GRAPHQL_API_KEY"])
    {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{api_key}"
    }
  end

  def graphql_headers_without_auth
    { "Content-Type" => "application/json" }
  end
end
