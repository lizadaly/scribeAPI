class Admin::SubjectsController < Admin::AdminBaseController

  def show
    @subject = Subject.find params[:id]
  end

  def index
    @subjects = Subject.where(type: "root")
  end


  def toggle_done
    subject = Subject.root.by_subject_set(params[:subject_set_id])[0]
    if subject.status == "retired"
      subject.activate!
    elsif subject.status == "active"
      subject.retire!
    subject.save
    redirect_to :back
    end
  end

end
