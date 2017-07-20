class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = User.new
    @user.body_pic = params[:image]
    @user.name = params[:name]
    @user.save

    @fetch = Typhoeus::Request.post(
      "https://api-us.faceplusplus.com/humanbodypp/beta/detect",
      :body => {"api_key"=>"#{ENV['faceKey']}",
                "api_secret"=>"#{ENV['faceSecret']}",
                "image_url"=> "#{@user.body_pic}"},
      :headers=>{"Content-type"=>"application/x-www-form-urlencoded"}
      )

    @width = JSON.parse(@fetch.body)["humanbodies"][0]["humanbody_rectangle"]["width"]


    open("#{@user.body_pic}", 'rb') do |fh|
      @size = ImageSize.new(fh)
    end

    open('image.png', 'wb') do |file|
      file << open("#{@user.body_pic}").read
      @img = file
    end

    credentials = Aws::Credentials.new(
      ENV['AWSAccessKeyId'],
      ENV['AWSSecretKey']
    )
    client = Aws::Rekognition::Client.new(credentials: credentials)
    resp = client.detect_faces(
             image: { bytes: File.read(@img) }
           )

    @leyeX = resp.face_details[0].landmarks[0].x.to_f.round(3)
    @leyeY = resp.face_details[0].landmarks[0].y.to_f.round(3)
    @reyeX = resp.face_details[0].landmarks[1].x.to_f.round(3)
    @reyeY = resp.face_details[0].landmarks[1].y.to_f.round(3)

    eyeLength = Math.sqrt(((@leyeX - @reyeX)*@size.w)**2 + ((@leyeY - @reyeY)*@size.h)**2)

    average = 417 * eyeLength / 49.92
    if @width < average + 5 && @width > average - 5
      @status = 'fit'
    elsif @width >= average + 5
      @status = 'fat'
    elsif @width <= average - 5
      @status = 'skinny'
    else
      @status = 'no'
    end
    @user.status = @status

    # @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:body_pic)
    end
end
