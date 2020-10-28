# frozen_string_literal: true

module TapasEngine::Concerns::ErrorsPlugin
  extend ActiveSupport::Concern

  included do
    rescue_from Exception, with: :handle_system_error
    rescue_from CustomMessageError, with: :error_4xx
    rescue_from ActionController::ParameterMissing, with: :error_422
    rescue_from RailsParam::Param::InvalidParameterError, with: :error_422
    rescue_from ActiveRecord::RecordNotFound, with: :handle_404
    rescue_from ActiveRecord::RecordInvalid, with: :handle_record_error
    rescue_from ActiveRecord::RecordNotDestroyed, with: :handle_record_error
    rescue_from AASM::InvalidTransition, with: :handle_aasm
  end

  private

  # https://github.com/doorkeeper-gem/doorkeeper/wiki/Customizing-the-response-body-when-unauthorized
  # https://github.com/doorkeeper-gem/doorkeeper/blob/master/lib/doorkeeper/rails/helpers.rb
  def doorkeeper_unauthorized_render_options(_error)
    { json: { error: '令牌过期了，请刷新页面重试' } }
  end

  def error_4xx(e)
    render json: { error: e.message }.to_json, status: e.status
  end

  def error_422(e)
    render json: { error: e.message }.to_json, status: :unprocessable_entity
  end

  def handle_aasm(e)
    render json: { error: '状态错误' }.to_json, status: :unprocessable_entity
  end

  def handle_error(exception)
    Rails.logger.error exception.message
    Rails.logger.error exception.backtrace.join("\n").to_s
    render json: { error: exception.message }, status: exception.status
  end

  def handle_404(exception)
    Rails.logger.error exception.message
    Rails.logger.error exception.backtrace.join("\n").to_s
    render json: { error: exception.message.presence }, status: :not_found
  end

  def handle_system_error(exception)
    ExceptionNotifier.notify_exception(exception, env: request.env, data: { message: '505系统错误通知' })

    Rails.logger.error exception.message
    Rails.logger.error exception.backtrace.join("\n").to_s
    render json: { error: exception.message.presence || '系统开小差了哦，请稍后再试' }, status: :unprocessable_entity
  end

  def handle_record_error(exception)
    error_message = exception.record.errors.full_messages.first
    render json: { error: error_message.presence || '系统开小差了哦，请稍后再试' }, status: :unprocessable_entity
  end
end
