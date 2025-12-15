# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Reconciliations", type: :request do
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key, user:) }
  let(:auth_headers) { { "Authorization" => "Bearer #{api_key.raw_token}" } }

  describe "GET /api/v1/reconciliations" do
    context "with valid authentication" do
      let!(:older_reconciliation) { create(:reconciliation, user:) }
      let!(:newer_reconciliation) { create(:reconciliation, user:) }
      let!(:other_user_reconciliation) { create(:reconciliation) } # belongs to different user

      it "returns all reconciliations for current user" do
        get "/api/v1/reconciliations", headers: auth_headers

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json["reconciliations"].length).to eq(2)
      end

      it "does not return reconciliations from other users" do
        get "/api/v1/reconciliations", headers: auth_headers

        json = response.parsed_body
        ids = json["reconciliations"].pluck("id")
        expect(ids).to include(older_reconciliation.id, newer_reconciliation.id)
        expect(ids).not_to include(other_user_reconciliation.id)
      end

      it "returns reconciliations ordered by most recent first" do
        get "/api/v1/reconciliations", headers: auth_headers

        json = response.parsed_body
        expect(json["reconciliations"].first["id"]).to eq(newer_reconciliation.id)
      end
    end

    context "without authentication" do
      it "returns 401 Unauthorized" do
        get "/api/v1/reconciliations"

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to eq({ "error" => "Unauthorized" })
      end
    end

    context "with invalid token" do
      it "returns 401 Unauthorized" do
        get "/api/v1/reconciliations", headers: { "Authorization" => "Bearer invalid" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/v1/reconciliations/:id" do
    let!(:reconciliation) { create(:reconciliation, :completed, user:) }

    context "with valid authentication" do
      it "returns the reconciliation" do
        get "/api/v1/reconciliations/#{reconciliation.id}", headers: auth_headers

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json["reconciliation"]["id"]).to eq(reconciliation.id)
        expect(json["reconciliation"]["status"]).to eq("completed")
      end

      it "returns all serialized fields" do
        get "/api/v1/reconciliations/#{reconciliation.id}", headers: auth_headers

        json = response.parsed_body["reconciliation"]
        expect(json).to include(
          "id", "status", "matched_count", "bank_only_count",
          "processor_only_count", "discrepancy_count", "error_message",
          "processed_at", "created_at", "updated_at"
        )
      end
    end

    context "when reconciliation belongs to another user" do
      let(:other_user) { create(:user) }
      let(:other_reconciliation) { create(:reconciliation, user: other_user) }

      it "returns 404 Not Found" do
        get "/api/v1/reconciliations/#{other_reconciliation.id}", headers: auth_headers

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to eq({ "error" => "Not found" })
      end
    end

    context "when reconciliation does not exist" do
      it "returns 404 Not Found" do
        get "/api/v1/reconciliations/non-existent-id", headers: auth_headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context "without authentication" do
      it "returns 401 Unauthorized" do
        get "/api/v1/reconciliations/#{reconciliation.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /api/v1/reconciliations" do
    let(:valid_params) { { reconciliation: { status: "pending" } } }

    context "with valid authentication and params" do
      it "creates a new reconciliation" do
        expect do
          post "/api/v1/reconciliations", params: valid_params, headers: auth_headers
        end.to change(Reconciliation, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it "returns the created reconciliation" do
        post "/api/v1/reconciliations", params: valid_params, headers: auth_headers

        json = response.parsed_body
        expect(json["reconciliation"]["status"]).to eq("pending")
        expect(json["reconciliation"]["id"]).to be_present
      end

      it "assigns the reconciliation to the current user" do
        post "/api/v1/reconciliations", params: valid_params, headers: auth_headers

        json = response.parsed_body
        created = Reconciliation.find(json["reconciliation"]["id"])
        expect(created.user).to eq(user)
      end
    end

    context "with invalid params" do
      it "returns 422 with validation errors" do
        post "/api/v1/reconciliations", params: {}, headers: auth_headers

        expect(response).to have_http_status(:bad_request)
      end
    end

    context "without authentication" do
      it "returns 401 Unauthorized" do
        post "/api/v1/reconciliations", params: valid_params

        expect(response).to have_http_status(:unauthorized)
      end

      it "does not create a reconciliation" do
        expect do
          post "/api/v1/reconciliations", params: valid_params
        end.not_to change(Reconciliation, :count)
      end
    end
  end
end
