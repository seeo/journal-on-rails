class LogController < ApplicationController
before_action :authenticate_user!, #:except => [ :show]
def index
    @logs = current_user.logs
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @logs }
    end
  end

  def show
    @log = Log.find(params[:id])

    p @log
    respond_to do |format|
      format.html
      format.json { render json: @log }
    end
  end

  def new
    @log = Log.new
  end

  def edit
    @log = Log.find(params[:id])
  end

  def create
    @log = Log.new(log_params)
    @user = current_user
    uploaded_file = params[:log][:picture].path
    p params
    p uploaded_file
    cloudinary_file = Cloudinary::Uploader.upload(uploaded_file, :folder => "journal-on-rails")
    p cloudinary_file
    p cloudinary_file["public_id"]
    #store this public_id value to the database
    @log.attributes = {:image => cloudinary_file["public_id"]}
    @log.attributes = {:user_id => current_user.id}


    # render json: cloudinary_file
    # @song["public_id"] = cloudinary_file["public_id"]
    p @log
    if @log.save
      redirect_to @log
      #ExampleMailer.sample_email(@user).deliver_now
    else
      render 'new'
    end
  end

  def update
    @log = Log.find(params[:id])

    if params[:log][:picture]
      uploaded_file = params[:log][:picture].path
      p uploaded_file
      cloudinary_file = Cloudinary::Uploader.upload(uploaded_file, :folder => "journal-on-rails")

      p cloudinary_file
      p cloudinary_file["url"]

      @log.attributes = {:image => cloudinary_file["public_id"]}
    else
      log_params[:image] = @log.image
    end

    if @log.update(log_params)
      redirect_to @log
    else
      render 'logs/edit'
    end
  end

  def destroy
    @log = Log.find(params[:id])
    @log.destroy
    redirect_to logs_path
  end

  private
    def log_params
      params.require(:log).permit(:title, :content, :image) #
    end

end
