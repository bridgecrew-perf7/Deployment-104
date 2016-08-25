# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

Rails.application.config.assets.digest = true

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.paths << Rails.root.join("app", "vendor/plugins")

Rails.application.config.assets.precompile << /(^[^_\/]|\/[^_])[^\/]*$/
#
# Rails.application.config.assets.precompile << /\.(?:svg|eot|woff|ttf)\z/
Rails.application.config.assets.precompile += %w( *.svg *.eot *.woff *.ttf *.gif *.png *.ico )
# Rails.application.config.assets.precompile += %w( *.js *.css *.scss *.less )
Rails.application.config.assets.precompile += %w( client/core.css )
Rails.application.config.assets.precompile += %w( client/core.js )
