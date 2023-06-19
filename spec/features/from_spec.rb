# frozen_string_literal: true

RSpec.describe "Configuration option :from" do
  inject_orderable_context DefaultModel, :position, from: 100

  before do
    create_list(:default_model, 2)
  end

  context "#on_create" do
    subject { create(:default_model, **args) }
    let(:args) { {} }

    it "creates a new record with the highest position" do
      expect(subject.position).to eq(DefaultModel.maximum(:position))
      expect(DefaultModel.ordered.pluck(:position)).to eq([102, 101, 100])
    end

    context "when position attribute given" do
      let(:args) { { position: 101 } }

      it "creates a new record with a correct position" do
        expect(subject.position).to eq(101)
        expect(DefaultModel.ordered.pluck(:position)).to eq([102, 101, 100])
      end
    end
  end

  context "#on_update" do
    subject { create(:default_model) }

    context "updating to higher position" do
      before do
        subject.update!(position: 102)
      end

      it "shifts records correctly" do
        expect(DefaultModel.pluck(:position, :id).to_h).to include(
          {
            100 => a_kind_of(Integer),
            101 => a_kind_of(Integer),
            102 => subject.reload.id
          }
        )
      end
    end

    context "position less than 100" do
      it "results in error" do
        expect { subject.update!(position: 99) }
          .to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  context "#on_destroy" do
    subject { create(:default_model, position: 101) }

    it "removes the record and shifts others correctly" do
      expect(subject.destroy).to be_present
      expect { subject.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(DefaultModel.ordered.pluck(:position)).to eq([101, 100])
    end
  end
end
