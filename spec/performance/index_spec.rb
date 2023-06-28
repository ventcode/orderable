# frozen_string_literal: true

RSpec.describe "Performance with index" do
  before(:all) do
    attrs = (0...100_000).to_a.map do |position|
      "('#{SecureRandom.alphanumeric(8)}', #{position})"
    end

    BasicModel.connection.execute(<<-SQL)
      INSERT INTO basic_models (name, position)
      VALUES
        #{attrs.join(', ')};
    SQL
  end

  after(:all) { BasicModel.delete_all }

  describe "model without scope" do
    context "on #update" do
      subject { create(:basic_model).update!(position: position) }

      context "with position set as first value" do
        let(:position) { 0 }

        it "takes less than 1.25s" do
          expect(elapsed_time { subject }).to be < 1.25
        end
      end

      context "with position set as middle value" do
        let(:position) { 50_000 }

        it "takes less than 0.75s" do
          expect(elapsed_time { subject }).to be < 0.75
        end
      end

      context "with position set as last value" do
        let(:position) { 99_999 }

        it "takes less than 0.15s" do
          expect(elapsed_time { subject }).to be < 0.15
        end
      end
    end

    context "on #create" do
      subject { create(:basic_model, **attrs) }
      let(:attrs) { {} }

      context "without position specified" do
        it "takes less than 0.07s" do
          expect(elapsed_time { subject }).to be < 0.07
        end
      end

      context "with postion set as 3/4 of total count" do
        let(:attrs) { { position: 75_000 } }

        it "takes less than 0.35s" do
          expect(elapsed_time { subject }).to be < 0.35
        end
      end

      context "with position set as the middle value" do
        let(:attrs) { { position: 50_000 } }

        it "takes less than 0.8s" do
          expect(elapsed_time { subject }).to be < 0.8
        end
      end

      context "with position set as first value" do
        let(:attrs) { { position: 0 } }

        it "takes less than 1.5s" do
          expect(elapsed_time { subject }).to be < 1.5
        end
      end
    end

    context "on #destroy" do
      subject { record.destroy! }
      let!(:record) { create(:basic_model, **attrs) }

      context "with position set as last value" do
        let(:attrs) { { position: 100_000 } }

        it "takes less than 0.01s" do
          expect(elapsed_time { subject }).to be < 0.01
        end
      end

      context "with position set as middle value" do
        let(:attrs) { { position: 50_000 } }

        it "takes less than 0.85s" do
          expect(elapsed_time { subject }).to be < 0.85
        end
      end

      context "with position set as first value" do
        let(:attrs) { { position: 0 } }

        it "takes less than 1.5s" do
          expect(elapsed_time { subject }).to be < 1.5
        end
      end
    end
  end
end
