require 'rails/generators'

class BaseGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('swagger/templates', __dir__)

  protected

  def singular_plural_name
    plural_name.singularize
  end

  def scope
    class_path[0]
  end

  def properties
    columns.map do |column|
      "#{column.name}: { type: :#{column.type}, description: '#{column.name}'}"
    end.join(",\n          ")
  end

  def request_params
    columns.map do |column|
      "#{column.name}: '#{column.name}'" if column.name != 'id'
    end.compact.join(",\n            ")
  end

  def columns
    singular_plural_name.camelize.constantize.columns
  end

  def generate_example(example)
    example.metadata[:response][:examples] = {'application/json' => JSON.parse(response.body, symbolize_names: true)}
  end
end
