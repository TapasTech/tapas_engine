require 'kaminari'
require 'pg'

module TapasEngine
  class Engine < ::Rails::Engine
    isolate_namespace TapasEngine


    # config.autoload_paths << File.expand_path("../..", __FILE__)

    # def self.load_config
    #   engine_config_dir = Pathname.new(File.expand_path('../../../config', __FILE__))
    #   # Settings.add_source!(
    #   #     (engine_config_dir + "settings/#{Rails.env}.yml").to_s
    #   # )
    #   # Settings.add_source!(Rails.root.join('config',"settings/#{Rails.env}.yml").to_s)
    #   # Settings.reload!
    # end

    # initializer "my_engine" do
    #   Engine::load_config
    # end

    # config.to_prepare do
    #   Dir.glob(Rails.root + "app/overrides/**/*_override*.rb").each do |c|
    #     require_dependency(c)
    #   end
    # end
  end
end
