require 'rails_helper'

describe ProponentFinder do
  let!(:user) { create(:user) }
  let(:uniq_id) { SecureRandom.uuid }
  let(:cpf) { CPF.generate }
  let(:params) do
    {
      cpf: nil,
      name: nil,
      discount_group: nil
    }
  end

  let(:first_group_salary) { rand(1..1044) }
  let(:second_group_salary) { rand(1046..2088) }
  let(:third_group_salary) { rand(2090..3133) }
  let(:fourth_group_salary) { rand(3135..6100) }

  before do
    create_list(:proponent, 2, user: user, salary: first_group_salary)
    create_list(:proponent, 3, user: user, salary: second_group_salary)
    create_list(:proponent, 4, user: user, salary: third_group_salary)
    create_list(:proponent, 5, user: user, salary: fourth_group_salary)
    create(:proponent, user: user, name: "Adriano-#{uniq_id}", salary: fourth_group_salary)
    create(:proponent, user: user, cpf: cpf, salary: fourth_group_salary)
  end

  describe '#perform' do
    it 'returns the proponents list without filters' do
      result = described_class.new(user, params).perform
      expect(result).to be_a(ActiveRecord::Relation)
      expect(result.count).to eq(Proponent.count)
    end

    it 'returns the proponents filtering by name' do
      params[:name] = "ano-#{uniq_id}"
      result = described_class.new(user, params).perform
      expect(result.count).to eq(1)
    end

    it 'returns the proponents filtering by CPF' do
      params[:cpf] = cpf
      result = described_class.new(user, params).perform
      expect(result.count).not_to eq(0)
    end

    it 'returns the proponents filtering by discount_group' do
      params[:discount_group] = :second
      result = described_class.new(user, params).perform
      expect(result.count).to eq(3)
    end
  end
end
