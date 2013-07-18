class DebugCaibaiController < ApplicationController
	def index
		@recorders = CanbaiRewardRecorder.all

		respond_to do |format| 
			format.html 
	 	end
	end 

	def edit
		@recorder = CanbaiRewardRecorder.find(params[:id])

		respond_to do |format|
			format.html
		end
	end 

	def delete
		if CanbaiRewardRecorder.delete(params[:id])
			redirect_to action: "index"
		else
			redirect_to action: "index"
		end
	end 

	def save
		@recorder = CanbaiRewardRecorder.find(params[:id])
		if params[:is_canbai] == '1'
			@recorder.last_canbai_time = Time.now.to_date
		else
			@recorder.last_canbai_time = Time.now.to_date.yesterday
		end
		
		@recorder.r_type = params[:post][:r_type]
		@recorder.accumulated_continuous_time = params[:post][:accumulated_continuous_time]

		if @recorder.save
			redirect_to action: "index" 
		else
			redirect_to action: "edit"
		end 
	end
end
