# == Schema Information
#
# Table name: api_keys
#
#  id           :integer          not null, primary key
#  access_token :string
#  expires_at   :datetime
#  user_id      :integer
#  active       :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_api_keys_on_access_token  (access_token) UNIQUE
#  index_api_keys_on_user_id       (user_id)
#

FactoryGirl.define do
  factory :api_key do
    access_token "MyString"
    expires_at "2016-10-21 09:15:40"
    user_id 1
    active false
  end
end
