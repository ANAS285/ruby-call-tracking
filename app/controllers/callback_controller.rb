class CallbackController < ApplicationController
  include Webhookable
 
  after_filter :set_header
 
  skip_before_action :verify_authenticity_token
 
  def call_tracking
    
   if params[:eventType] == 'answer' and params[:tag] == ''

    @number = Number.where(:tracking_number => params[:to]).first
    @call = Call.where(:call_id => params[:callId]).first_or_create

    @call.number_id = @number.id
    @call.call_id = params[:callId]
    @call.to = params[:to]
    @call.from = params[:from]
    @call.state = "ringing"

    Bandwidth::Call.get(params[:callId]).update({:tag => params[:callId], :state=>'transferring', :transferTo=>@number.business_number, :callbackUrl=> ENV["BANDWIDTH_VOICE_URL"]})

   elsif params[:eventType] == 'answer' and params[:tag] != ''

        @call = Call.where(:call_id => params[:tag]).first
        @call.start_time = params[:time]
        @call.state = "answered"

   elsif params[:eventType] == 'hangup' and params[:tag] != ''

        @call = Call.where(:call_id => params[:tag]).first
        @call.end_time = params[:time]
        @call.duration = (@call.start_time - @call.end_time).to_i
        @call.state = "completed"

   end

    if @call.save    

        render nothing: true
   
    else

      render status: 500

    end


  end
end
