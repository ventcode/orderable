# frozen_string_literal: true

RSpec.describe "Configuration option :direction" do
  describe "descending" do
    before do
      create_list(:desc_direction_model, 3)
    end

    context "#on_create" do
      subject { create(:desc_direction_model, **args) }
      let(:args) { {} }

      it "creates a new record with the lowest position" do
        expect(subject.position).to eq(7)
        expect(DescDirectionModel.ordered.pluck(:position))
          .to match_array([10, 9, 8, 7])
      end

      context "when position attribute given" do
        let(:args) do
          { position: 9 }
        end

        it "creates a new record with a correct position and shift others" do
          expect(subject.position).to eq(9)
          expect(DescDirectionModel.ordered.pluck(:position))
            .to match_array([10, 9, 8, 7])
        end

        context "position greater than from" do
          let(:args) do
            { position: 12 }
          end

          it "results in error" do
            expect { subject }.to raise_error(
              ActiveRecord::RecordInvalid,
              "Validation failed: Position must be less than or equal to 10"
            )
          end
        end
      end
    end

    context "#on_update" do
      subject { create(:desc_direction_model) }

      context "updating to higher position" do
        before do
          subject.update!(position: 9)
        end

        it "shifts records correctly" do
          expect(subject.position).to eq(9)
          expect(DescDirectionModel.ordered.pluck(:position))
            .to match_array([10, 9, 8, 7])
        end
      end
    end

    context "#on_destroy" do
      subject { create(:desc_direction_model, position: 8) }

      it "removes the record and shifts others correctly" do
        expect(subject.destroy).to be_present
        expect { subject.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect(DescDirectionModel.ordered.pluck(:position))
          .to match_array([10, 9, 8])
      end
    end
  end
end
