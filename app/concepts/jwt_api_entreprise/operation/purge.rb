module JwtApiEntreprise::Operation
  class Purge < Trailblazer::Operation
    step :delete_expired_tokens


    def delete_expired_tokens(_, **)
      JwtApiEntreprise.where("exp < ?", Time.zone.now.to_i).destroy_all
    end
  end
end
