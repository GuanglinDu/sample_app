require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end

  test "only activated users showed" do
    @non_admin.activated = false
    @non_admin.save # save to the db

    # /users
    log_in_as(@admin)
    get users_path
    assert_select 'a[href=?]', user_path(@admin), text: @admin.name
    assert_select 'a[href=?]', user_path(@non_admin), count: 0

    # /users/:id
    #get users_path(@admin.id)
    #puts response
    #assert_select 'h1', text: @admin.name, count: 1
  end
end
