class SessionsController < ApplicationController
  def new
    redirect_to home_path if current_user
  end
  def create
    user = User.where(email: params[:email]).first
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:notice] = 'You are signed in!'
      redirect_to home_path 
    else 
      flash[:error] = "Invalid email or passwod."
      redirect_to sign_in_path 
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "You are signed out"
  end
end 
