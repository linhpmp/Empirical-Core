require 'rails_helper'

describe 'GoogleIntegration::Classroom::Creators::Classrooms' do

  def subject(teacher, courses)
    x = GoogleIntegration::Classroom::Creators::Classrooms.run(teacher, courses)
    x.map{ |y| { name: y.name, google_classroom_id: y.google_classroom_id } }
  end

  let!(:teacher) {
    FactoryGirl.create(:user, role: 'teacher')
  }

  let!(:courses) {
    [
      {id: 1, name: 'class1'},
      {id: 2, name: 'class2'}
    ]
  }

  context 'no classroom has been created previously from one of the courses' do
    let!(:expected) {
      [
        {name: 'class1', google_classroom_id: 1},
        {name: 'class2', google_classroom_id: 2}
      ]
    }

    it 'produces 2 classrooms' do
      expect(subject(teacher, courses)).to eq(expected)
    end
  end

  context 'a classroom already exists for one of the courses' do
    let!(:extant) {
      FactoryGirl.create(:classroom, google_classroom_id: 1)
    }

    let!(:expected) {
      [{name: 'class2', google_classroom_id: 2}]
    }

    it 'produces 1 classroom' do
      pending("Syncing Google classrooms needs extra state management")
      expect(subject(teacher, courses)).to eq(expected)
    end
  end
end
