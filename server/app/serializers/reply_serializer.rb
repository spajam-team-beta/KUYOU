class ReplySerializer
  include JSONAPI::Serializer
  
  attributes :id, :content, :is_best, :created_at, :updated_at
  
  attribute :user_nickname do |reply|
    "智者##{reply.user_id.to_s.rjust(4, '0')}"
  end
  
  attribute :is_mine do |reply, params|
    params[:current_user] && reply.user_id == params[:current_user].id
  end
end