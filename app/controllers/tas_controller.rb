class TasController < ApplicationController
  before_filter :get_board
  before_filter :get_ta, :only => [:update, :show, :destroy]
  before_filter :authenticate_ta!, :except => [:create]

  respond_to :json, :xml

  def show
    respond_with @ta
  end

  def create 
=begin
    if params[:queue_password] != @board.password
      respond_with do |f|
        f.json { render :json => { :error => "Invalid password" }, :status => :unauthorized }
      end
      return
    end
=end
    @ta = @board.tas.new(params[:ta].merge( :password => params[:queue_password]))

    respond_with do |f|
      if @ta.save
        session['user_id'] = @ta.id if request.format == 'html'
        f.html { redirect_to board_path @board }
        f.json { render :json => { token: @ta.token, id: @ta.id, username: @ta.username }, :status => :created }
        f.xml  { render :xml => { token: @ta.token, id: @ta.id, username: @ta.username }, :status => :created }
      else
        f.html { flash[:errors] = @ta.errors.full_messages; redirect_to board_login_path @board }
        f.json { render :json => @ta.errors, :status => :unprocessable_entity }
        f.json { render :xml => @ta.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @ta.update_attributes(params[:ta])
    if params[:accept_student] != nil
      unless @ta.student.nil?
        student = @ta.student
        student.in_queue = false
        student.ta = nil
        student.save
        @ta.save
      end
      @ta.student = @board.students.where(:_id => params[:accept_student]).first
    end
    @ta.save

    respond_with do |f|
      f.json { render :json => @ta }
    end
  end

  def destroy
    @ta.destroy
    if request.format == "html"
      session.delete 'user_id'
    end
    respond_with do |f|
      f.html { redirect_to board_login_path @board }
    end
  end

  private

    def get_ta
      @ta = @board.tas.find(params[:id])
    end
end
