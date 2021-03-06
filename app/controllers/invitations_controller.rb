class InvitationsController < ApplicationController
  before_filter :require_user
  def new
    @invitation = Invitation.new
  end

  def create
    @invitation = Invitation.new(invitation_params)
    if @invitation.save
      AppMailer.delay.send_invitation_email(@invitation.id)
      flash[:notice] = "You have successfully invited #{ @invitation.recipient_name }"
      redirect_to new_invitation_path
    else
      flash[:error] = "Invalid info."
      render :new
    end
  end

  private 
  def invitation_params
    params.require(:invitation).permit!.merge!(inviter_id: current_user.id)
  end
end
