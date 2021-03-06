
 require 'spec_helper'

describe UsersController do
  describe "GET new" do
    it "sets @user" do
      get :new
      expect(assigns(:user)).to be_instance_of(User)
    end
  end
  
  describe "POST create" do
    context "with valid input" do

      before { post :create, user: Fabricate.attributes_for(:user) }
      it "creates the user" do
        expect(User.count).to eq(1)
      end
      it "redirects to the root page" do
        expect(response).to redirect_to root_path 
      end
      it "makes the user follow the inviter" do
        sam = Fabricate(:user) 
        invitation = Fabricate(:invitation, inviter: sam, recipient_email: 'vivian@example.com')
        post :create, user: { email: 'vivian@example.com', password: 'password', full_name: 'Vivian' }, invitation_token: invitation.token
        vivian = User.where(email: 'vivian@example.com').first
        expect(vivian.follows?(sam)).to be_true
      end

      it "makes the inviter follow the user" do
        sam = Fabricate(:user) 
        invitation = Fabricate(:invitation, inviter: sam, recipient_email: 'vivian@example.com')
        post :create, user: { email: 'vivian@example.com', password: 'password', full_name: 'Vivian' }, invitation_token: invitation.token
        vivian = User.where(email: 'vivian@example.com').first
        expect(sam.follows?(vivian)).to be_true
      end

      it "expires the invitation upon acceptance" do
        sam = Fabricate(:user) 
        invitation = Fabricate(:invitation, inviter: sam, recipient_email: 'vivian@example.com')
        post :create, user: { email: 'vivian@example.com', password: 'password', full_name: 'Vivian' }, invitation_token: invitation.token
        expect(Invitation.first.token).to be_nil
      end
    end

    context "with incalid input" do

      before do
        post :create, user: { password: "password", full_name: "Kevin Wang" }
      end
      it "does not create the user" do
        expect(User.count).to eq(0)
      end
      it "render the :new template" do
        expect(response).to render_template :new
      end
      it "sets @user" do
        expect(assigns(:user)).to be_instance_of(User)
      end
    end

    context "sending email" do

      before { ActionMailer::Base.deliveries.clear }

      it "sends out email to user with  valid input" do
        post :create, user: { email: "jenny@example.com", password: "password", full_name: "Jenny" } 
        expect(ActionMailer::Base.deliveries.last.to).to eq(['jenny@example.com'])
      end
      it "sends out email containing the user's name with valid input" do
        post :create, user: { email: "jenny@example.com", password: "password", full_name: "Jenny" } 
        expect(ActionMailer::Base.deliveries.last.body).to include('Jenny')
      end
      it "does not sends email to user with invalid input" do
        post :create, user: { password: "password", full_name: "Jenny" } 
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end

  describe "GET new_with_invitation_token" do
    it "sets @user with recipient's email" do
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: invitation.token
      expect(assigns(:user).email).to eq(invitation.recipient_email)
    end

    it "sets @invitation token" do
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: invitation.token
      expect(assigns(:invitation_token)).to eq(invitation.token)
    end

    it "redirets to expired token page for invalid tokens" do
      get :new_with_invitation_token, token: "12345"
      expect(response).to redirect_to expired_token_path
    end
  end
end
