class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do |e|
    json_response({ message: e.message }, status: :not_found)
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    json_response({ message: e.message }, status: :unprocessable_entity)
  end

  def json_response(json, status: :ok)
    render json: json, status: status
  end
end
