class DocumentViewerController < ApplicationController

  before_filter :login_required
  before_filter :is_expired?

   def index
     learner = Learner.find(params[:id])
     logger.info"learner #{learner.inspect}"
     @course = Course.find_by_id(learner.course_id)
     @course_url = '/'+@course.url
     if learner.type_of_test_taker == "learner"
#      learner = Learner.find_by_user_id_and_course_id(current_user.id,params[:id])
      learner.update_attribute(:lesson_status,"completed")
     end
   end  

end