module Api
  module V1
    class RequestsController < ApplicationController
      def create
        request = Request.new(request_params)

        if request.save
          render json: {
            message: 'Request created successfully',
            request: request,
            product: request.product
          }, status: :created
        else
          render json: { error: request.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def index
        requests = Request.includes(:product)
        render json: requests.as_json(include: :product), status: :ok
      end

      def show
        request = Request.includes(:product).find_by(id: params[:id])
        if request
          render json: request.as_json(include: :product), status: :ok
        else
          render json: { error: 'Request not found' }, status: :not_found
        end
      end

      private

      def request_params
        params.require(:request).permit(:prompt)
      end
    end
  end
end
