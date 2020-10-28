# frozen_string_literal: true

concern :ParamsPlugin do
  def per
    params[:per]&.to_i || 20
  end

  def page
    debugger
    params[:page]&.to_i || 1
  end

  def paginate(data)
    debugger
    @pagination =
      if data.try(:current_page).present?
        {
          current_page: data.current_page,
          total_pages: data.total_pages,
          next_page: data.next_page,
          total_count: data.total_count,
          per: per
        }
      end
  end
end
