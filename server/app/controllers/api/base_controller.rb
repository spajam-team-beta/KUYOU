module Api
  class BaseController < ApplicationController
    before_action :authenticate_request!
    
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
    
    private
    
    def record_not_found(error)
      render json: { error: 'リソースが見つかりません' }, status: :not_found
    end
    
    def record_invalid(error)
      render json: { error: error.record.errors.full_messages }, status: :unprocessable_entity
    end
    
    def pagination_meta(collection)
      {
        current_page: collection.current_page,
        total_pages: collection.total_pages,
        total_count: collection.total_count,
        per_page: collection.limit_value
      }
    end
  end
end