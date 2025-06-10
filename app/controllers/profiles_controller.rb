# frozen_string_literal: true

class ProfilesController < ApplicationController
  include Authenticatable
  include Pundit

  # Ensure the user is authenticated before accessing any profile actions
  before_action :authorize_request
  before_action :set_profile, only: [ :show, :update, :destroy ]
  before_action :authorize_profile, only: [ :show, :update, :destroy ]

  def show
    render json: @profile
  end

  def update
    if @profile.update(profile_params)
      render json: @profile
    else
      render json: { errors: @profile.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @profile.destroy
    head :no_content
  end

  private

  def set_profile
    @profile = User.find(params[:id])
  end

  def authorize_profile
    authorize @profile
  end

  def profile_params
    params.permit(:email, :id)
  end
end
