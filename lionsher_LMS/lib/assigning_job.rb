class AssigningJob < Struct.new(:array_group_ids, :current_user_id, :assessment_course_id, :assessment_course)
  def perform
   case(assessment_course)
   when "assign_to_assessment" then
      assessment_obj = AssessmentsController.new
      assessment_obj.calculate_delayed_group_learners(array_group_ids,current_user_id,assessment_course_id)
    else
      course_obj = CoursesController.new
      course_obj.calculate_delayed_group_learners(array_group_ids,current_user_id,assessment_course_id)
    end
  end
end
