# frozen_string_literal: true

RSpec.describe "Configuration option :auto_set" do
  context "when :auto_set is set to true" do
    subject(:record) { create(:basic_model) }

    context "without other records" do
      it "should move a record to position zero" do
        expect(record.position).to eq(0)
      end
    end

    context "with some other records" do
      before { create_list(:basic_model, 2) }

      it "moves a new record with undefined position to the end" do
        expect(record.position).to eq(2)
      end
    end
  end

  context "when :auto_set is set to false" do
    subject(:record) { create(:no_auto_set_model, position: position) }
    let(:position) { nil }

    context "without records" do
      it "raises error without position specified" do
        expect { record }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "with records" do
      before { create_list(:basic_model, 2) }

      it "raises error without position specified" do
        expect { record }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "when position property is passed" do
      let(:position) { 0 }

      it "sets correct position for a new record" do
        expect(record.position).to eq(0)
      end

      context "and another record already exists with the same position" do
        let!(:another_record) { create(:basic_model, position: 0) }

        it "sets correct position for a new record and move another one further" do
          expect(record.position).to eq(0)
          expect(another_record.reload.position).to eq(1)
        end
      end
    end
  end
end
