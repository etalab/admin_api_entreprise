class TokensController < ApplicationController
  def create
    result = Token::Create.call(params)

    if result.success?
      render json: { new_token: result['created_token'].value }, status: 201

    else
      errors = retrieve_errors(result)
      render json: { errors: errors }, status: 422
    end
  end

  private

  def retrieve_errors(operation_result)
    if operation_result['result.contract.params'].errors.empty?
      operation_result['manual_errors']
    else
      operation_result['result.contract.params'].errors
    end
  end
end
