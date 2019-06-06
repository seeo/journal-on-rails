class LogsController < ApplicationController
before_action :authenticate_user!, #:except => [ :show]

  def index
    if params[:search]
      @search_results_logs = Log.search_by_title_and_body(params[:search])
      respond_to do |format|
        format.js {render partial: 'search-results'}
      end
    else
      @logs = Log.where(:user_id => current_user.id).order('created_at DESC')
      @name = current_user.name

      #@logs = current_user.logs
      respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @logs }
      end
    end
  end

  def show
    @log = Log.find(params[:id])

    p @log
    respond_to do |format|
      format.html
      format.json { render json: @log }
    end
    p ENV['CLOUDINARY_URL']
  end

  def new
    if log_params
      #If data submitted already by the form we call the create method
      create
      return
    end

    @log = Log.new
    render 'new'  #calling the newly created log explicitly
  end

  def edit
    @log = Log.find(params[:id])
  end

  def create
    @log = Log.new(log_params)
    @user = current_user

    if !params[:log][:picture]
      #if no image uploaded, upload an empty string

      @log.attributes = {:image => " "}
      @log.attributes = {:user_id => current_user.id}

    else
      #else we upload the path of the image from cloudinary
      p 'uploaded file here'
      uploaded_file = params[:log][:picture].path
      p "params here:"
      p params
      p "uploaded file:"
      p uploaded_file
      cloudinary_file = Cloudinary::Uploader.upload(uploaded_file, :folder => "journal-on-rails")
      p "cloudinary file:"
      p cloudinary_file
      p "cloudinary_file public id:"
      p cloudinary_file["public_id"]
      #store this public_id value to the database
      @log.attributes = {:image => cloudinary_file["public_id"]}
      @log.attributes = {:user_id => current_user.id}

    end

    # render json: cloudinary_file
    # @song["public_id"] = cloudinary_file["public_id"]
    p @log
    respond_to do |format|
      if @log.save
        #redirect_to @log
        format.html { redirect_to @log, notice: "Entry created!" }
        p "Log saved!"
        #ExampleMailer.sample_email(@user).deliver_now
      else
        #render 'new'
        format.html { render action: 'new' }
      end
    end
  end

  def update
    @log = Log.find(params[:id])

    if params[:log][:picture]
      p "begin cloudinary upload if there is image: "
      uploaded_file = params[:log][:picture].path
      p "printing uploaded_file path below: "
      p uploaded_file
      p "printing cloudinary_file below: "
      cloudinary_file = Cloudinary::Uploader.upload(uploaded_file, :folder => "journal-on-rails")

      p "printing cloudinary_file below: "
      p cloudinary_file

      p "printing cloudinary_file url below: "
      p cloudinary_file["url"]


      @log.attributes = {:image => cloudinary_file["public_id"]}
    else
      log_params[:image] = @log.image
    end

# respond_to do |format|
#       if @log.save
#         #redirect_to @log
#         format.html { redirect_to @log, notice: "Entry created!" }
#         p "Log updated!"
#         #ExampleMailer.sample_email(@user).deliver_now
#       else
#         #render 'new'
#         format.html { render action: 'new' }
#       end
#     end

    respond_to do |format|
      if @log.update(log_params)
        format.html { redirect_to @log, notice: "Entry updated!" }
        p "Log updated!"
      else
        format.html { render action: 'logs/edit' }
      end
    end
  end

  def destroy
    @log = Log.find(params[:id])
    @log.destroy
    redirect_to logs_path
  end

  private

    def log_params
      if params[:log].nil? || params[:log].empty?
        return false
      else
        return params.require(:log).permit(:title, :content, :image)
      end
    end
  end
