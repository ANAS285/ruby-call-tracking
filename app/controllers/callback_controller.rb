class CallbackController < ApplicationController
 
  after_filter :set_header
 
  skip_before_action :verify_authenticity_token
 
  def call_tracking
    
    #puts "Inbound Number: "+params[:to]
    #puts "Inbound Tag: "+params[:tag]

     if (params[:eventType] == 'answer' and params[:tag] is nil)

      @number = Number.where(:tracking_number => params[:to]).first

      puts "LOG - Number - "+@number 

      puts "LOG - Call Id - "+params[:callId]

      @call = Call.where(:call_id => params[:callId]).first_or_create

      @call.number_id = @number.id
      @call.call_id = params[:callId]
      @call.to = params[:to]
      @call.from = params[:from]
      @call.state = "ringing"

      Bandwidth::Call.get(params[:callId]).update({:tag => params[:callId], :state=>'transferring', :transferTo=>@number.business_number, :callbackUrl=> ENV["BANDWIDTH_VOICE_URL"]})

     elsif (params[:eventType] == 'answer' and params[:tag] != '')

          @call = Call.where(:call_id => params[:tag]).first
          @call.start_time = params[:time]
          @call.state = "answered"

     elsif (params[:eventType] == 'hangup' and params[:tag] != '')

          @call = Call.where(:call_id => params[:tag]).first
          @call.end_time = params[:time]
          @call.duration = (@call.start_time - @call.end_time).to_i
          @call.state = "completed"

     else 

          return
          render nothing: true

     end

    if @call.save    

        render status: 200
   
    else

      render status: 500

    end

  end
end
