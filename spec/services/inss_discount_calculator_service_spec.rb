require 'rails_helper'

describe InssDiscountCalculatorService do
  describe '#perform' do
    let(:calculator) { described_class.new }

    it 'returns the discount' do
      expect(calculator.perform(1045)).to eq(78.37) # Faixa salarial 1
      expect(calculator.perform(3000)).to eq(281.62) # Faixa salarial 2
      expect(calculator.perform(3500)).to eq(348.93) # Faixa salarial 3
      expect(calculator.perform(6101.06)).to eq(713.08) # Faixa salarial 4
      expect(calculator.perform(6800)).to eq(713.08) # Acima do teto
    end
  end
end
