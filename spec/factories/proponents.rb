FactoryBot.define do
  factory :proponent do
    user { create(:user) }
    name { Faker::Name.name }
    cpf { CPF.generate }
    birth_date { Faker::Date.birthday(min_age: 18, max_age: 65) }
    address_street { Faker::Address.street_name }
    address_number { Faker::Address.building_number }
    address_neighborhood { Faker::Address.community }
    address_city { Faker::Address.city }
    address_state { Faker::Address.state_abbr }
    address_zipcode { Faker::Address.zip_code }
    phones do
      {
        personal: [
          { phone: Faker::PhoneNumber.cell_phone_in_e164, description: 'Main phone' },
          { phone: Faker::PhoneNumber.cell_phone_in_e164, description: 'Secondary phone' }
        ],
        reference: [
          { phone: Faker::PhoneNumber.cell_phone_in_e164, description: 'Mother' },
          { phone: Faker::PhoneNumber.cell_phone_in_e164, description: 'Father' },
          { phone: Faker::PhoneNumber.cell_phone_in_e164, description: 'Any' }
        ]
      }
    end
    salary { Faker::Number.decimal(l_digits: 4, r_digits: 2) }

    Proponent.skip_callback(:commit, :after, :notify_user)
  end
end
