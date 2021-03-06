class Teachers::ClassroomsController < ApplicationController
  respond_to :json, :html
  before_filter :teacher!
  before_filter :authorize!

  def index
    if current_user.classrooms_i_teach.empty?
      redirect_to new_teachers_classroom_path
    else
      @classrooms = current_user.classrooms_i_teach
      @classroom = @classrooms.first
    end
  end

  def new
    # just here to render the new view, then react takes care of everything
  end

  def classrooms_i_teach
    @classrooms = current_user.classrooms_i_teach
    render json: @classrooms.order(:updated_at)
  end

  def classrooms_i_teach_with_students
    classrooms = current_user.classrooms_i_teach.includes(:students)
    classrooms_with_students = classrooms.map do |classroom|
      classroom_h = classroom.attributes
      classroom_h[:students] = classroom.students
      classroom_h
    end
    render json: classrooms_with_students
  end

  def regenerate_code
    cl = Classroom.new
    cl.generate_code
    render json: {code: cl.code}
  end

  def create
    @classroom = Classroom.create(classroom_params.merge(teacher: current_user))
    if @classroom.valid?
      ClassroomCreationWorker.perform_async(@classroom.id)
      render json: {classroom: @classroom, toInviteStudents: current_user.students.empty?}
    else
       render json: {errors: @classroom.errors.full_messages }, status: 422
    end
  end

  def update
    @classroom.update_attributes(classroom_params)
    # this is updated from the students tab of the scorebook, so will make sure we keep user there
    redirect_to teachers_classroom_students_path(@classroom.id)
  end

  def destroy
    @classroom.destroy
    redirect_to teachers_classrooms_path
  end

  def hide
    classroom = Classroom.find(params[:id])
    classroom.visible = false #
    classroom.save(validate: false)
    respond_to do |format|
      format.html{redirect_to teachers_classrooms_path}
      format.json{render json: classroom}
    end
  end

  def unhide
    # can't use param[:id] here or else rails magic looks up a classroom with that id
    # kicks an active record error (because it is out of the default scope), and returns a 404
    classroom = Classroom.unscoped.find(params[:class_id])
    classroom.update(visible: true)
    render json: classroom
  end



private

  def classroom_params
    params[:classroom].permit(:name, :code, :grade)
  end

  def authorize!
    return unless params[:id].present?
    @classroom = Classroom.find(params[:id])
    auth_failed unless @classroom.teacher == current_user
  end
end
