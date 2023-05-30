# frozen_string_literal: true

RSpec.describe "on #destroy" do
  subject { record.destroy }
  
  context "with model without scopes" do
    before do
      create_list(:basic_model, 5)
    end
    
    context "when destroying last record" do
      let!(:record) { create(:basic_model, position: 0) }
      
      it "decreases the position of other records by 1" do
        expect { subject }
        .to change { BasicModel.ordered.pluck(:name, :position).to_h }
        .from(
          {
            "e" => 5,
            "d" => 4,
            "c" => 3,
            "b" => 2,
            "a" => 1,
            "f" => 0
          }
        ).to(
          {
            "e" => 4,
            "d" => 3,
            "c" => 2,
            "b" => 1,
            "a" => 0
          }
        )
      end
    end
    
    context "when destroying middle record" do
      let!(:record) { create(:basic_model, position: 3) }
      
      it "adjust other records properly" do
        expect { subject }
        .to change { BasicModel.ordered.pluck(:name, :position).to_h }
        .from(
          {
            "e" => 5,
            "d" => 4,
            "f" => 3,
            "c" => 2,
            "b" => 1,
            "a" => 0
          }
        ).to(
          {
            "e" => 4,
            "d" => 3,
            "c" => 2,
            "b" => 1,
            "a" => 0
          }
        )
      end
    end

    context "when destroying last record" do
      let!(:record) { create(:basic_model, position: 5) }
      
      it "adjust other records properly" do
        expect { subject }
        .to change { BasicModel.ordered.pluck(:name, :position).to_h }
        .from(
          {
            "f" => 5,
            "e" => 4,
            "d" => 3,
            "c" => 2,
            "b" => 1,
            "a" => 0
          }
        ).to(
          {
            "e" => 4,
            "d" => 3,
            "c" => 2,
            "b" => 1,
            "a" => 0
          }
        )
      end
    end
    
    context "when destroying all records" do
      subject { BasicModel.destroy_all }
      
      it "adjust other records properly" do
        expect { subject }
        .to change { BasicModel.count }
        .from(5).to(0)
      end
    end
  end

  context "model with many scopes" do
    before do
      create_list(:model_with_many_scopes, 3, group: "first")
    end

    context "when destroying record in other scope" do
      let!(:record) { create(:model_with_many_scopes, position: 0, group: "second") }
      
      it "destroy record and doesn't touch other records" do
        expect { subject }
        .to change { ModelWithManyScopes.ordered.pluck(:name, :position, :group) }
        .from(
          [
            ["c", 2, "first"],
            ["b", 1, "first"],
            ["a", 0, "first"],
            ["d", 0, "second"]
          ]
        )
        .to(
          [
            ["c", 2, "first"],
            ["b", 1, "first"],
            ["a", 0, "first"],
          ]
        )
      end
    end

    context "when destroying record inside a scope" do
      before do
        create(:model_with_many_scopes, position: 0, group: "second")
      end
      
      let!(:record) { create(:model_with_many_scopes, position: 2, group: "first") }
      
      it "destroy record and adjust other scope's records" do
        expect { subject }
        .to change { ModelWithManyScopes.ordered.pluck(:name, :position, :group) }
        .from(
          [
            ["c", 3, "first"],
            ["e", 2, "first"],
            ["b", 1, "first"],
            ["a", 0, "first"],
            ["d", 0, "second"]
          ]
        )
        .to(
          [
            ["c", 2, "first"],
            ["b", 1, "first"],
            ["a", 0, "first"],
            ["d", 0, "second"]
          ]
        )
      end
    end
  end
end
