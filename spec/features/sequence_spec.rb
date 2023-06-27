# frozen_string_literal: true

RSpec.describe "Configuration option :sequence" do
  describe "descending" do
    before do
      create_list(:decremental_sequence_model, 3)
    end

    context "#on_create" do
      subject { create(:decremental_sequence_model, **args) }
      let(:args) { {} }

      it "creates a new record with the lowest position" do
        expect(subject.position).to eq(7)
        expect(DecrementalSequenceModel.ordered.pluck(:position))
          .to eq([7, 8, 9, 10])
      end

      context "when position attribute given" do
        let(:args) do
          { position: 9 }
        end

        it "creates a new record with a correct position and shift others" do
          expect(subject.position).to eq(9)
          expect(DecrementalSequenceModel.ordered.pluck(:position))
            .to eq([7, 8, 9, 10])
        end

        context "position greater than from" do
          let(:args) do
            { position: 12 }
          end

          it "results in error" do
            expect { subject }.to raise_error(
              ActiveRecord::RecordInvalid,
              "Validation failed: Position must be less than or equal to 10, Position should be between 7 and 10"
            )
          end
        end
      end
    end

    context "#on_update" do
      subject { create(:decremental_sequence_model) }

      context "updating to higher position" do
        before do
          subject.update!(position: 9)
        end

        it "shifts records correctly" do
          expect(subject.position).to eq(9)
          expect(DecrementalSequenceModel.ordered.pluck(:position))
            .to eq([7, 8, 9, 10])
        end
      end
    end

    context "#on_destroy" do
      subject { create(:decremental_sequence_model, position: 8) }

      it "removes the record and shifts others correctly" do
        expect(subject.destroy).to be_present
        expect { subject.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect(DecrementalSequenceModel.ordered.pluck(:position))
          .to eq([8, 9, 10])
      end
    end
  end
end
