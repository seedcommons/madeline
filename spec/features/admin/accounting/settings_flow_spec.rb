require 'rails_helper'

feature 'settings flow', :accounting do
  let(:division) { Division.root }
  let(:user) { create_admin(division) }

  describe "authentication" do
    context "no qb connection" do
      #go to authenticate endpoint in ctrlr
      scenario do
        # user can click connect
        # assume connection is successful
        # user sees that qb is connected
        # qb fetch is pending
      end
    end
  end

  describe "initial page load and authentication" do


    context "qb connection exists but qb grant invalid" do
      scenario do
        # show that qb is currently disconnected & let user click 'connect'
      end
    end

    context "qb connection exists and qb grant is valid" do
      scenario do
        # user sees that qb is connected
      end
    end
  end

  describe "setting details" do
    # accounts
    # closed books date
    # read-only
    # submit form
  end

  describe "disconnect" do

  end
end
