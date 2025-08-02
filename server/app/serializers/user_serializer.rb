class UserSerializer
  include JSONAPI::Serializer
  
  attributes :id, :email, :total_points, :created_at
end