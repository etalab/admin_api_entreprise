# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.

# application.js was not precompiled for some reason. might be a misconfig issue.
# useful to add stubbed (non-global) javascript assets
Rails.application.config.assets.precompile += %w(
  application.js
  utils/generate_anchor_icons.js
  utils/auto_open_accordeon.js
)
