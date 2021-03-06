module GoogleIntegration::Classroom::Creators::Classrooms

  def self.run(teacher, courses)
    courses.map{ |course| self.create_classroom(teacher, course) }
           .compact
  end

  private

  def self.create_classroom(teacher, course)
    classroom = ::Classroom.unscoped.find_or_initialize_by(google_classroom_id: course[:id])
    if classroom.new_record?
      classroom.attributes = {name: course[:name], teacher_id: teacher.id}
      classroom.save
    end
    classroom.reload
  end

end
