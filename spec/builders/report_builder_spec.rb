require 'rails_helper'

describe ReportBuilder do
  let!(:user) { create(:user) }

  let(:first_group_salary) { rand(1..1044) }
  let(:second_group_salary) { rand(1046..2088) }
  let(:third_group_salary) { rand(2090..3133) }
  let(:fourth_group_salary) { rand(3135..6100) }

  before do
    create_list(:proponent, 2, user: user, salary: first_group_salary)
    create_list(:proponent, 5, user: user, salary: second_group_salary)
    create_list(:proponent, 10, user: user, salary: third_group_salary)
    create_list(:proponent, 8, user: user, salary: fourth_group_salary)
  end

  describe '#report_by_discount_group' do
    it 'returns the report for the current user' do
      report = described_class.new(user).report_by_discount_group
      expect(report[:first]).to eq(2)
      expect(report[:second]).to eq(5)
      expect(report[:third]).to eq(10)
      expect(report[:fourth]).to eq(8)
    end
  end
end
