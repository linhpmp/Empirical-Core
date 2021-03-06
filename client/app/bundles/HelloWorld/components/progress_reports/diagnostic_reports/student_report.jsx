import React from 'react'
import ProgressReport from '../progress_report.jsx'
import LoadingSpinner from '../../shared/loading_indicator.jsx'
import StudentReportBox from './student_report_box.jsx'
import $ from 'jquery'
import _ from 'underscore'
export default React.createClass({

	getInitialState: function() {
		return {loading: true, questions: null}
	},


  componentDidMount: function () {
    this.getStudentData()
  },

	selectedStudent: function(students){
		let {studentId} = this.props.params;
		if (studentId) {
			return students.find(s => s.id === parseInt(studentId))
		} else {
			return students[0]
		}
	},

  getStudentData: function(){
    const that = this;
		const p = this.props.params;
    $.get(`/teachers/progress_reports/students_by_classroom/u/${p.unitId}/a/${p.activityId}/c/${p.classroomId}`, (data) => {
      that.setState({students: data.students, loading: false})
    })
  },

  studentBoxes: function(){
		let concept_results = _.sortBy(this.selectedStudent(this.state.students).concept_results, 'question_number')
    return concept_results.map((question, index) => {
			return <StudentReportBox key={index} boxNumber={index+1} questionData={question}/>
		})
  },

	render: function() {
		let content;
		if (this.state.loading) {
			content = <LoadingSpinner/>
		} else {
			content = (
				<div className='individual-student-activity-view'>
          {this.studentBoxes()}
				</div>
			)
		}
		return content
	}
});
