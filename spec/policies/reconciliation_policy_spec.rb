# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReconciliationPolicy, type: :policy do
  subject { described_class.new(user, reconciliation) }

  let(:user) { create(:user) }
  let(:reconciliation) { create(:reconciliation, user: owner) }

  describe "when user owns the reconciliation" do
    let(:owner) { user }

    it { is_expected.to be_index }
    it { is_expected.to be_show }
    it { is_expected.to be_create }
    it { is_expected.to be_update }
    it { is_expected.to be_destroy }
  end

  describe "when user does not own the reconciliation" do
    let(:owner) { create(:user) }

    it { is_expected.to be_index }      # Can list (but won't see this one)
    it { is_expected.not_to be_show }   # Cannot view
    it { is_expected.to be_create }     # Can create new ones
    it { is_expected.not_to be_update } # Cannot update
    it { is_expected.not_to be_destroy } # Cannot delete
  end

  describe "when user is nil (unauthenticated)" do
    let(:user) { nil }
    let(:owner) { create(:user) }

    it { is_expected.not_to be_index }
    it { is_expected.not_to be_show }
    it { is_expected.not_to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
  end

  describe ReconciliationPolicy::Scope do
    subject(:resolved_scope) { described_class.new(user, Reconciliation).resolve }

    let!(:user_reconciliation) { create(:reconciliation, user:) }
    let!(:other_reconciliation) { create(:reconciliation) }

    it "returns only reconciliations belonging to the user" do
      expect(resolved_scope).to include(user_reconciliation)
      expect(resolved_scope).not_to include(other_reconciliation)
    end
  end
end
