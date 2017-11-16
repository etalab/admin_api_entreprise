class TokensController < ApplicationController
  def create
    result = Token::Create.(params)

    if result.success?
      render json: result['model'], status: 201

    else
      errors = (result['result.contract.params'].errors.empty? ?
                result['manual_errors'] :
                result['result.contract.params'].errors)
      render json: { errors: errors }, status: 422
    end
  end
end
