# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :questionnaire do
    skip_create

    receiver_name "arthur"
    receiver_sex "male"
    location "paris"
    relationship "brother"
    trait_category "adventurous venturous"
    message_category "Happy Birthday"

    initialize_with { new( {"receiver_name" => receiver_name, "receiver_sex" => receiver_sex, "location" => location, "relationship" => relationship, "trait_category" => trait_category, "message_category" => message_category }) }
  end

end
