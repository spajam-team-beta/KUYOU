class ReplySerializer
  include JSONAPI::Serializer
  
  attributes :id, :content, :is_best, :created_at, :updated_at
  
  attribute :user_nickname do |reply|
    reply.user.display_nickname
  end
  
  attribute :is_mine do |reply, params|
    params[:current_user] && reply.user_id == params[:current_user].id
  end
end