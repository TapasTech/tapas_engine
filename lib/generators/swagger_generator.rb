class SwaggerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('swagger/templates', __dir__)

  def create_swagger_file

    create_file "spec/integration/#{scope}/#{plural_name}_spec.rb", <<-FILE
require 'api_spec_helper'

describe '#{plural_name} API', type: :request, swagger_doc: '#{scope}/#{scope}-swagger.json' do
  before do
    login_as_admin
    let(:financer) {create(:financer)}
    let(:Authorization) {financer.auth_token}
  end

  path "/#{scope}/#{plural_name}" do

    get '#{singular_plural_name} 列表' do
      tags '#{plural_name}'
      consumes 'application/json'
      parameter name: :Authorization, description: '用户认证', in: :header, type: :string

      response 200, '请求成功' do
        let(:#{singular_plural_name}) { create(:#{singular_plural_name}) }

        before do
          #{singular_plural_name}
        end

        after do |example|
          example.metadata[:response][:examples] = { 'application/json' => JSON.parse(response.body, symbolize_names: true) }
        end

        run_test! do
          expect_json_sizes(data: 1)
        end
      end
    end

    get '创建 #{singular_plural_name}' do
    tags '#{plural_name}'
      produces 'application/json'
      consumes 'application/json'

      parameter name: :request_params, in: :body, schema: {
        type: :object,
        properties: {
          #{properties}
        }
      }

      response '200', '请求成功' do
        let(:request_params) {
          {
            #{request_params}
          }
        }

        after do |example|
          example.metadata[:response][:examples] = { 'application/json' => JSON.parse(response.body, symbolize_names: true) }
        end

        run_test!
      end
    end
  end

  path "/#{scope}/#{plural_name}/{id}" do
    get '#{plural_name} 详情' do
      tags '#{plural_name}'
      consumes 'application/json'

      parameter name: :id, in: :path, type: :string, description: 'id'
      parameter name: :Authorization, description: '用户认证', in: :header, type: :string

      response 200, '请求成功' do
        let(:#{singular_plural_name}) { create(:#{singular_plural_name}) }
        let(:id) { #{singular_plural_name}.id }

        after do |example|
          example.metadata[:response][:examples] = { 'application/json' => JSON.parse(response.body, symbolize_names: true) }
        end

        run_test!
      end
    end

    delete '删除 #{plural_name}' do
      tags '#{plural_name}'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string, description: 'id'

      response 204, '请求成功' do
        let(:#{singular_plural_name}) { create(:#{singular_plural_name}) }
        let(:id) { #{singular_plural_name}.id }

        run_test!
      end
    end
  end

  path "/#{scope}/#{plural_name}/{id}" do
    put '更新 #{plural_name}' do
      tags '#{plural_name}'
      produces 'application/json'
      consumes 'application/json'

      parameter name: :id, in: :path, type: :string, description: 'id'
      parameter name: :request_params, in: :body, schema: {
        type: :object,
        properties: {
          #{properties}
        }
      }

      response '200', '请求成功' do
        let(:id){ create(:#{singular_plural_name}).id }
        let(:request_params) {
          {
            #{request_params}
          }
        }

        after do |example|
          example.metadata[:response][:examples] = { 'application/json' => JSON.parse(response.body, symbolize_names: true) }
        end

        run_test!
      end
    end
  end

end

        FILE
  end

  private

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
end
