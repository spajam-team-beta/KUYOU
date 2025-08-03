class UserSerializer
  include JSONAPI::Serializer
  
  attributes :id, :email, :nickname, :total_points, :created_at
end