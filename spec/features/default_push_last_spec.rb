# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Configuration option :default_push_last' do
  context 'when :default_push_last is set to true' do
    context 'without other records' do
      subject { BasicModel.create(name: 'a') }

      it 'should push a record to position zero' do
        expect(subject.position).to eq(0)
      end
    end

    context 'with some records' do
      before do
        BasicModel.insert_all [
          { name: 'a', position: 0 },
          { name: 'b', position: 1 }
        ]
      end

      subject { BasicModel.create(name: 'c') }

      it 'pushes entry with undefined position to the end' do
        expect(subject.position).to eq(2)
      end
    end
  end

  context 'when :default_push_last is set to false' do
    context 'without records' do
      it 'raises error without position specified' do
        expect { NoDefaultPushLastModel.create!(name: 'a') }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'with records' do
      before do
        NoDefaultPushLastModel.insert_all [
          { name: 'a', position: 0 },
          { name: 'b', position: 1 }
        ]
      end

      it 'raises error without position specified' do
        expect { NoDefaultPushLastModel.create!(name: 'c') }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
