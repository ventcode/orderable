# frozen_string_literal: true

require 'support/database_helper'
require 'support/models'
require 'factories/basic_model'

RSpec.describe 'Configuration option :default_push_last' do
  context 'when :default_push_last is set to true' do
    context 'without other records' do
      subject { create(:basic_model) }

      it 'should push a record to position zero' do
        expect(subject.position).to eq(0)
      end
    end

    context 'with some records' do
      before { create_list(:basic_model, 2) }

      subject { BasicModel.create(name: 'c') }

      it 'pushes entry with undefined position to the end' do
        expect(subject.position).to eq(2)
      end
    end
  end

  context 'when :default_push_last is set to false' do
    context 'without records' do
      it 'raises error without position specified' do
        expect { create(:no_default_push_last_model, position: nil) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'with records' do
      before { create_list(:basic_model, 2) }

      it 'raises error without position specified' do
        expect { create(:no_default_push_last_model, position: nil) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
