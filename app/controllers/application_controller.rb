class ApplicationController < ActionController::API
  before_action :set_jsonapi_content_type

  private

  def set_jsonapi_content_type
    response.content_type = "application/vnd.api+json"
  end
end
