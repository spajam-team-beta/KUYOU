class PostSerializer
  include JSONAPI::Serializer
  
  attributes :id, :nickname, :content, :category, :status, 
             :sympathy_count, :created_at, :updated_at
  
  attribute :reply_count do |post|
    post.replies.count
  end
  
  attribute :is_resolved do |post|
    post.resolved?
  end
  
  attribute :is_mine do |post, params|
    params[:current_user] && post.user_id == params[:current_user].id
  end
  
  attribute :has_sympathized do |post, params|
    params[:current_user] && post.sympathies.exists?(user: params[:current_user])
  end
end