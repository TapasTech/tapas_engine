require_relative 'base_generator'

class SwaggerOperationGenerator < Rails::Generators::NamedBase
  include BaseGenerator

  source_root File.expand_path('swagger/templates', __dir__)

  class_option :name, type: :string, default: 'plural_name'

  def create_swagger_file
    create_file "spec/integration/#{scope}/#{plural_name}_spec.rb", <<-FILE
require 'api_spec_helper'

describe '#{chinese_name} API', type: :request, swagger_doc: '#{scope}/golden-funnel-operator-swagger.json' do
  before do
    login_as_admin
  end

  let(:#{singular_plural_name}) { create(:#{singular_plural_name}) }
  let(:id) { #{singular_plural_name}.id }

  path "/#{scope}/#{plural_name}" do
    get '#{chinese_name} 列表' do
      tags '#{chinese_name}'
      produces 'application/json'
      consumes 'application/json'

      response 200, '请求成功' do
        before do
          #{singular_plural_name}
        end

        after do |example|
          generate_example(example)
        end

        run_test! do
          expect_json_sizes(data: 1)
        end
      end
    end

    post '创建 #{chinese_name}' do
      tags '#{chinese_name}'
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
          generate_example(example)
        end

        run_test! do
          expect_json('data', #{columns.first.name}: '#{columns.first.name}')
        end
      end
    end
  end

  path "/#{scope}/#{plural_name}/{id}" do
    get '#{chinese_name} 详情' do
      tags '#{chinese_name}'
      produces 'application/json'
      consumes 'application/json'

      parameter name: :id, in: :path, type: :string, description: 'id'

      response 200, '请求成功' do
        after do |example|
          generate_example(example)
        end

        run_test!
      end
    end

    delete '删除 #{chinese_name}' do
      tags '#{chinese_name}'
      produces 'application/json'
      consumes 'application/json'
      
      parameter name: :id, in: :path, type: :string, description: 'id'

      response 204, '请求成功' do
        run_test!
      end
    end

    put '更新 #{chinese_name}' do
      tags '#{chinese_name}'
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
        let(:request_params) {
          {
            #{request_params}
          }
        }

        after do |example|
          generate_example(example)
        end

        run_test! do
          expect_json('data', #{columns.first.name}: '#{columns.first.name}')
        end
      end
    end
  end
end
        FILE
  end
end
