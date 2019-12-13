module User::Operation
  class Index < Trailblazer::Operation
    AllowedFilters = [:email, :context]

    step :load_user_list

    def load_user_list(ctx, params:, **)
      constraints = params.select { |k, _| AllowedFilters.include?(k.to_sym) }
      ctx[:user_list] = User.where(constraints)
    end
  end
end
