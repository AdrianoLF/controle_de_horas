require 'rails_helper'

RSpec.describe EventsFinder, type: :finder do
  let!(:team) { create(:team, name: 'Team A') }

  let!(:event_early)   { create(:event, team: team, occurred_at: 10.days.ago, title: 'Early') }
  let!(:event_middle)  { create(:event, team: team, occurred_at: 5.days.ago,  title: 'Middle') }
  let!(:event_recent)  { create(:event, team: team, occurred_at: 1.day.ago, title: 'Recent') }

  describe '#perform' do
    context 'without filters' do
      it 'returns events ordered by occurred_at desc by default' do
        result = described_class.new({}).perform
        expect(result.map(&:title)).to eq(%w[Recent Middle Early])
      end
    end

    context 'when filtering by date range' do
      it 'filters by occurred_from only (inclusive)' do
        result = described_class.new(occurred_from: 5.days.ago.to_date.to_s).perform
        expect(result.map(&:title)).to match_array(%w[Recent Middle])
      end

      it 'filters by occurred_to only (inclusive)' do
        result = described_class.new(occurred_to: 5.days.ago.to_date.to_s).perform
        expect(result.map(&:title)).to match_array(%w[Middle Early])
      end

      it 'filters by both occurred_from and occurred_to' do
        params = {
          occurred_from: 6.days.ago.to_date.to_s,
          occurred_to: 2.days.ago.to_date.to_s
        }
        result = described_class.new(params).perform
        expect(result.map(&:title)).to eq(['Middle'])
      end
    end

    context 'when sorting' do
      it 'sorts by occurred_at asc' do
        result = described_class.new(sort_by: 'occurred_at', sort_order: 'asc').perform
        expect(result.map(&:title)).to eq(%w[Early Middle Recent])
      end
    end
  end
end
