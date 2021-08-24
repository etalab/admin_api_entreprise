class RecentlyCreatedUsersQuery
  def perform
    User.where('created_at > ?', 1.week.ago.beginning_of_week)
  end
end
