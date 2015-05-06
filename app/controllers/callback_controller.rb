class CallbackController < ApplicationController
  
  skip_before_action :verify_authenticity_token
 
  def call_tracking
    
    #puts "Inbound Number: "+params[:to]
    #puts "Inbound Tag: "+params[:tag]

     if (params[:eventType] == 'answer') && (params[:tag].nil?)

      @number = Number.where(:tracking_number => params[:to]).first
      @call = Call.where(:call_id => params[:callId]).first_or_create

      @call.number_id = @number.id
      @call.call_id = params[:callId]
      @call.to = params[:to]
      @call.from = params[:from]
      @call.fwd_to = @number.business_number
      @call.state = "ringing"
      @call.save   

      ## use REST API to update /calls/{id} to state transferring
      ## see http://ap.bandwidth.com/docs/rest-api/calls/#resource403
      Bandwidth::Call.get(params[:callId]).update({:tag => params[:callId], :state=>'transferring', :transferTo=>@number.business_number, :callbackUrl=> ENV["BANDWIDTH_VOICE_URL"]})

      # hangup event for the inbound call, update status not answered
      elsif (params[:eventType] == 'hangup') and (params[:tag].nil?)

          @call = Call.where(:call_id => params[:callId]).first
          
          @call.state = "not answered" unless @call.state == "completed" end
          @call.save   

     #
     elsif (params[:eventType] == 'answer') and (!params[:tag].nil?)

          @call = Call.where(:call_id => params[:tag]).first
          @call.start_time = params[:time]
          @call.state = "answered"
          @call.save   

     elsif (params[:eventType] == 'hangup') and (!params[:tag].nil?)

          @call = Call.where(:call_id => params[:tag]).first
          @call.end_time = params[:time]

          if !@call.start_time.nil?
            @call.call_duration = (@call.end_time - @call.start_time).to_i
            @call.state = "completed"
          end

          @call.save   
     
     else 

          render nothing: true
     end

  end
end
