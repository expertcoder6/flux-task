module Api
  module V1
    class RequestsController < ApplicationController
      before_action :set_request, only: [:show]

      # GET /api/v1/requests
      def index
        @requests = Request.includes(:product)
        respond_to do |format|
          format.html
          format.turbo_stream
          format.json { render json: @requests.as_json(include: :product), status: :ok }
        end
      end

      # POST /api/v1/requests
      def create
        @request = Request.new(request_params)

        if @request.save
          data = SendRequestDetails.call(@request)
          
          respond_to do |format|
            format.turbo_stream do
              render turbo_stream: [turbo_stream.append(
                'requests',
                partial: 'api/v1/requests/request',
                locals: { request: @request }
              ),
              turbo_stream.replace(
                'new_request_form',
                partial: 'api/v1/requests/form',
                locals: { request: Request.new }
              )]
            end
            format.html { redirect_to requests_path, notice: 'Request created successfully.' }
            format.json { render json: { message: 'Request created successfully', request: @request }, status: :created }
          end
        else
          respond_to do |format|
            format.turbo_stream do
              render turbo_stream: turbo_stream.replace(
                'new_request_form',
                partial: 'api/v1/requests/form',
                locals: { request: @request }
              )
            end
            format.html { render :index, status: :unprocessable_entity }
            format.json { render json: { error: @request.errors.full_messages }, status: :unprocessable_entity }
          end
        end
      end

      # GET /api/v1/requests/:id
      def show
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              dom_id(@request),
              partial: 'api/v1/requests/request_details',
              locals: { request: @request }
            )
          end
          format.html
          format.json { render json: @request.as_json(include: :product), status: :ok }
        end
      rescue ActiveRecord::RecordNotFound
        respond_to do |format|
          format.html { redirect_to requests_path, alert: 'Request not found.' }
          format.json { render json: { error: 'Request not found' }, status: :not_found }
        end
      end

      private

      def request_params
        params.require(:request).permit(:prompt)
      end

      def set_request
        @request = Request.find(params[:id])
      end
    end
  end
end
