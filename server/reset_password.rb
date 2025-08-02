user = User.find_by(email: 'itiger4649@gmail.com')
user.password = 'password123'
user.password_confirmation = 'password123'
user.save!
puts "Password updated successfully for #{user.email}"