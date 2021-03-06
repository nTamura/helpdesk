class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :user_is_staff?
  before_action :find_ticket, only: [:show, :edit, :update, :destroy]

  def new
    @ticket = Ticket.new
  end

  def create
    @ticket = Ticket.new ticket_params
    @ticket.user = current_user

    if @ticket.save
      flash[:notice] = 'Ticket posted successfully'
      redirect_to ticket_path(@ticket)
    else
      flash[:alert] = 'Ticket not created'
      render :new
    end
  end

  def show
    @tickets = Ticket.last(20)
    @comment = Comment.new
    @staff = User.all.where(is_staff: true)
  end

  def index
    @tickets = Ticket.last(20)
    @staff = User.all.where(is_staff: true)
  end

  def edit
    redirect_to root_path, alert: 'Access denied!' unless can? :edit, @ticket
  end

  def update
    respond_to do |format|
      format.json do
        if @ticket.update(ticket_params)
          render json: { status: :success, message: "Ticket #{@ticket.id} Updated"}
        else
          render json: { status: :failure, message: "Problem updating ticket #{@ticket.id}"}
        end
      end

      format.html do
        if !(can? :edit, @ticket)
          redirect_to tickets_path, alert: 'access denied'
        elsif @ticket.update(ticket_params)
          redirect_to ticket_path(@ticket), notice: 'Ticket updated'
        end
      end
    end
  end

  def destroy
    if can? :destroy, @ticket
      @ticket.destroy
      redirect_to tickets_path, notice: 'Ticket Deleted'
    end
  end

  private

  def user_is_staff?
    unless current_user.is_staff?
      redirect_to root_path, alert: 'Unauthorized access'
    end
  end

  def find_ticket
    @ticket = Ticket.find params[:id]
  end

  def ticket_params
    params.require(:ticket).permit(:title, :body, :department_id, :rep, :status, :user, :flag)
  end
end
