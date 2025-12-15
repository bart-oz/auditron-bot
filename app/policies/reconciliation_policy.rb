# frozen_string_literal: true

class ReconciliationPolicy
  attr_reader :user, :reconciliation

  def initialize(user, reconciliation)
    @user = user
    @reconciliation = reconciliation
  end

  # Can the user view a list of reconciliations?
  # Yes, if they are authenticated (user exists)
  def index?
    user.present?
  end

  # Can the user view this specific reconciliation?
  # Yes, if they own it
  def show?
    owner?
  end

  # Can the user create a new reconciliation?
  # Yes, if they are authenticated
  def create?
    user.present?
  end

  # Can the user update this reconciliation?
  # Yes, if they own it
  def update?
    owner?
  end

  # Can the user delete this reconciliation?
  # Yes, if they own it
  def destroy?
    owner?
  end

  private

  # Check if the user owns this reconciliation
  def owner?
    user.present? && reconciliation.user_id == user.id
  end

  # Scope class for filtering records the user can access
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    # Users can only see their own reconciliations
    def resolve
      scope.where(user_id: user.id)
    end
  end
end
