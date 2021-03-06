class ProgressReports::Standards::Unit
  def initialize(teacher)
    @teacher = teacher
  end

  def results(filters)
    best_activity_sessions = ProgressReports::Standards::ActivitySession.new(@teacher).results(filters)
    ::Unit.with(best_activity_sessions: best_activity_sessions)
      .select("units.id as id, units.name as name")
      .joins('JOIN classroom_activities ON classroom_activities.unit_id = units.id')
      .joins('JOIN best_activity_sessions ON best_activity_sessions.classroom_activity_id = classroom_activities.id')
      .group('units.id')
      .order("units.created_at asc, units.name asc") # Try order by creation date, fall back to name)
  end  
end