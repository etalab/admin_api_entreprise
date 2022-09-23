class APIParticulier::PublicTokenMagicLinksController < APIParticulierController
  include PublicTokenMagicLinksManagement

  def expiration_offset
    24.hours
  end
end
