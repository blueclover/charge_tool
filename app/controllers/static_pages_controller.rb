class StaticPagesController < ApplicationController
  def home
    if user_signed_in?
      @surveys = current_user.surveys.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end
end
