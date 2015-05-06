class NumbersController < ApplicationController
  before_action :set_number, only: [:show, :edit, :update, :destroy]

  # GET /numbers
  # GET /numbers.json
  def index
    @numbers = Number.all
  end

  # GET /numbers/1
  # GET /numbers/1.json
  def show
  end

  # GET /numbers/new
  def new
    @number = Number.new
  end

  # GET /numbers/1/edit
  def edit
  end

  # POST /numbers
  # POST /numbers.json
  def create
    @number = Number.new(number_params)

    if !@number.business_number.blank?
      @number.business_number = "+1"+Phony.normalize(@number.business_number)          
    end

    begin 

        numbers = Bandwidth::AvailableNumber.search_local({:area_code => @number.area_code[1..3]})
        
        if numbers.count > 0
          number = Bandwidth::PhoneNumber.create({:number => numbers[0][:number]})
          @number.tracking_number = number.number
          @number.bw_id = number.id
        else
          flash[:notice] = "Area Code Not Available."
          raise "Area Code Not Available."    
        end

    rescue StandardError => e
        puts "ERROR: "+e.message
        raise "There was a problem setting up your number. Try again."    
    end 

    respond_to do |format|
      if @number.save
        format.html { redirect_to numbers_url, notice: 'Number was successfully created.' }
        format.json { render :show, status: :created, location: @number }
      else
        format.html { render :new }
        format.json { render json: @number.errors, status: :unprocessable_entity }
      end
    end
  end


  # get /numbers/:id/calls
  def show_calls
    @calls = Call.where(:number_id => params[:id])

  end


  # PATCH/PUT /numbers/1
  # PATCH/PUT /numbers/1.json
  def update

    if !params[:number][:business_number].blank?
      params[:number][:business_number] = "+1"+Phony.normalize(params[:number][:business_number])
    end

    if !params[:number][:tracking_number].blank?
      params[:number][:tracking_number] = "+1"+Phony.normalize(params[:number][:tracking_number])
    end

    respond_to do |format|
      if @number.update(number_params)
        format.html { redirect_to numbers_url, notice: 'Number was successfully updated.' }
        format.json { render :show, status: :ok, location: @number }
      else
        format.html { render :edit }
        format.json { render json: @number.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /numbers/1
  # DELETE /numbers/1.json
  def destroy

    begin 

        Bandwidth::PhoneNumber.get(@number.bw_id).delete        
        
    rescue StandardError => e
        puts "ERROR: "+e.message    
    end 

    @number.destroy

    respond_to do |format|
      format.html { redirect_to numbers_url, notice: 'Number was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_number
      @number = Number.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def number_params
      params.require(:number).permit(:area_code, :tracking_number, :business_number)
    end
end
