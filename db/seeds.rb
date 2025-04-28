user1 = User.create!(email: 'john@acme.inc', password: 'Password1!')
salary_list = [200.01, 1040.33, 1100.55, 2000, 2050.03, 2100, 3135, 7000, 36_532.22, 6_412_354.32]
10.times do |i|
  Proponent.create!({
                      user_id: user1.id,
                      name: Faker::Name.name,
                      cpf: CPF.generate,
                      birth_date: Faker::Date.birthday(min_age: 18, max_age: 65),
                      address_street: Faker::Address.street_name,
                      address_number: Faker::Address.building_number,
                      address_neighborhood: Faker::Address.community,
                      address_city: Faker::Address.city,
                      address_state: Faker::Address.state_abbr,
                      address_zipcode: Faker::Address.zip_code,
                      phones: {
                        personal: [
                          { phone: Faker::PhoneNumber.cell_phone_in_e164, description: 'Main phone' },
                          { phone: Faker::PhoneNumber.cell_phone_in_e164, description: 'Secondary phone' }
                        ],
                        reference: [
                          { phone: Faker::PhoneNumber.cell_phone_in_e164, description: 'Mother' },
                          { phone: Faker::PhoneNumber.cell_phone_in_e164, description: 'Father' },
                          { phone: Faker::PhoneNumber.cell_phone_in_e164, description: 'Any' }
                        ]
                      },
                      salary: salary_list[i]
                    })
end
