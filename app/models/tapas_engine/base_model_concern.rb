# frozen_string_literal: true

module TapasEngine::BaseModelConcern
  extend ActiveSupport::Concern

  module ClassMethods
    def params_permit(params, excepts = [], additions = [])
      excepts << model_name.i18n_key
      params.except(*excepts).permit(permit_params + additions)
    end

    def permit_params
      column_names.map(&:to_sym) - %i[id updated_at created_at]
    end

    def search_by_params(options = {})
      result = all
      if options.present?
        options.keys.map(&:to_s).each do |key|
          value = options[key]
          next unless value.present?
          result =
              # if key == 'order'
              #   result.handle_order(value)

              if key.include?('like_')
                attr_key = key.gsub('like_', '')
                result.handle_like(attr_key, value.upcase)

                # or || 兼容   'students.creator_id'的情况发生   可能传递多个，超过两个
              elsif key =~ /^or_/
                attr_key = key.gsub('or_', '')
                values = value.split(' ')

                result.handle_or(attr_key, values)

                # or一个value同时搜多个参数
              elsif key =~ /^compare_/
                attr_key = key.gsub(/^compare_/, '')
                result.handle_compare(attr_key, value.to_s)
              elsif key.to_s.include?('between_')
                attr_key = key.to_s.gsub('between_', '')
                attr_key = "#{self.name.tableize}.#{attr_key}" if !attr_key.include?('.')
                query_string = if value.is_a?(Array)
                                 value.map { |item|
                                   front, back = item.split(',')
                                   "#{attr_key} between #{front} and #{back}"
                                 }.join(' or ')
                               else
                                 front, back = value.split(',')
                                 "#{attr_key} between #{front} and #{back}"
                               end
              result.where(query_string)
              elsif key.include?('not_')
                attr_key = key.gsub('not_', '')
                result.where.not("#{attr_key} = ?", value)
              elsif column_for_attribute(key).type.present? && column_for_attribute(key).array #数组查询
                result.where("#{key} && ?", "{#{value}}")
              else
                if key.include?('.')
                  value = begin
                            JSON.parse(value)
                          rescue StandardError
                            value
                          end
                  result.where(key => value)
                else
                  return result unless attribute_names.include?(key)
                  result.where("#{name.tableize}.#{key}".to_sym => value)
                end
              end
        end
      end
      result
    end

    # def handle_order(value)
    #   value = [value] if !value.is_a?(Array)
    #   value.each do |value_item|
    #     orders = value_item.split(' ')
    #     if orders.length == 2
    #       self.order("#{orders[0]} #{orders[1].upcase} nulls last")
    #     else
    #       self.order(value)
    #     end
    #   end
    # end

    def handle_like(attr_key, value)
      return self.where("upper(#{attr_key}) like ?", "%#{value}%") if attr_key.include?('.')
      self.where("upper(#{name.tableize}.#{attr_key}) like ?", "%#{value}%") if attribute_names.include?(attr_key)
    end

    def handle_or(attr_key, values)
      search_key = if attr_key.include?('.')
                     attr_key
                   else
                     "#{name.tableize}.#{attr_key}" if attribute_names.include?(attr_key)
                   end
      query_string = ''
      values.each_with_index do |_v, index|
        query_string += "#{search_key} = '#{values[index]}' or "
      end
      query_string.chomp!(' or ')
      self.where(query_string)
    end

    def handle_compare(attr_key, value)
      query_hash = {}
      query_string = ''
      convert_key = attr_key.gsub(/^.t_/, '')
      convert_key = "#{name.tableize}.#{convert_key}" if !convert_key.include?('.')
      date_value = value.to_date if attr_key.include?('_at')
      if attr_key =~ /^lt_/
        #处理时间
        value = date_value.at_end_of_day if date_value
        query_hash = {value: value}
        query_string = "#{convert_key} <= :value "
        # elsif attr_key =~ /^bt_/
        #   attr_key.gsub!(/^bt_/, '')
        #   split = value.split
        #   query_hash = {min: split[0].to_s, max: split[1].to_s}
        #   query_string = "#{convert_key} >= :min and #{convert_key} <= :max "
      elsif attr_key =~ /^gt_/
        #处理时间
        value = date_value.at_beginning_of_day if date_value

        query_hash = {value: value}
        query_string = "#{convert_key} >= :value "
      end
      self.where(query_string, query_hash)
    end


  end
end
