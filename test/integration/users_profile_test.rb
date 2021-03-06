require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar'
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'div.pagination'
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end

    # Tests that will_paginate appears only once.
    assert_select 'div.pagination', count: 1
  end

  test "stats on profile and home pages" do
    get login_path
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }
    assert_redirected_to @user # user profile page
    follow_redirect!
    assert_template 'users/show'
    assert_select "a>strong#following", text: "2"
    assert_select "a>strong#followers", text: "2"

    get root_path # user home page
    assert_template 'static_pages/home'
    assert_select "a>strong#following", text: "2"
    assert_select "a>strong#followers", text: "2"
  end
end
