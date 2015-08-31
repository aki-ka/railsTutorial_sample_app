require 'spec_helper'

describe "Static pages" do

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_content(heading) }
    it { should have_title(full_title(page_title)) }
  end

  describe "Home page" do
    before { visit root_path }
    let(:heading)    { 'Sample App' }
    let(:page_title) { '' }
    let(:user) { FactoryGirl.create(:user) }

    it_should_behave_like "all static pages"
    it { should_not have_title('| Home') }

    
    describe "for signed-in users" do
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          expect(page).to have_selector("li##{item.id}", text: item.content)
        end
      end
        it { should have_content(user.microposts.count) }
        it { should have_content("microposts") }
      
      describe "follower/following counts" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          other_user.follow!(user)
          visit root_path
        end

        it { should have_link("0 following", href: following_user_path(user)) }
        it { should have_link("1 followers", href: followers_user_path(user)) }
      end
    end
    
    describe "for signed-in users sigle post" do
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        sign_in user
        visit root_path
      end

      it { should have_content(user.microposts.count) }
      it { should have_content("micropost") }
      it { should_not have_content("microposts") }
    end

    describe "feed pagination" do
      before do
        35.times do |n|
          FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum #{n}")
          sign_in user
          visit root_path
        end
      end
      after { user.microposts.delete_all }
      
      it { should have_selector('div.pagination') }

      it "should list each post" do
        user.microposts.paginate(page: 1).each do |post|
          expect(page).to have_selector('li', text: post.content)
        end
      end
    end
    describe "not display delete link for other user's post" do
      let(:other_user) { FactoryGirl.create(:user) }
      let!(:other_post) { FactoryGirl.create(:micropost, user: other_user, content: "Foo") }
      before do
        sign_in user
        visit root_path
      end

      it { should_not have_link('delete', href: micropost_path(other_post)) }
    end
  end

  describe "Help page" do
    before { visit help_path }
    let(:heading)    { 'Help' }
    let(:page_title) { 'Help' }
    
    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before { visit about_path }
    let(:heading)    { 'About' }
    let(:page_title) { 'About Us' }

    it_should_behave_like "all static pages"
  end

  describe "Contact page" do
    before { visit contact_path }
    let(:heading)    { 'Contact' }
    let(:page_title) { 'Contact' }

    it_should_behave_like "all static pages"
  end
end
