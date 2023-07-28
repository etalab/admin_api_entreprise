Gaffe.configure do |config|
  config.errors_controller = {
    %r[particulier] => 'APIParticulier::ErrorsController',
    %r[entreprise] => 'APIEntreprise::ErrorsController'
  }
end

Gaffe.enable!
