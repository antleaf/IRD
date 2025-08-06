class BatchesController < ApplicationController
  before_action :set_batch, only: %i[ show edit update destroy generate_csv_for_download]
  after_action :verify_authorized


  def generate_csv_for_download
    authorize @batch
    @systems = @batch.rp.responsibilities.publicly_viewable
    @filename = "ird_repositories_curated_by_#{@batch.rp.display_name.downcase}_#{Time.now.strftime('%Y-%m-%d')}.csv"
    @batch.filename = @filename
    @batch.locking = true
    @batch.save!
    respond_to do |format|
      format.csv do
        authorize :batch, :download_csv?
        send_data System.to_csv(@systems, true), filename: ActiveStorage::Filename.new(@filename).sanitized, content_type: 'text/csv'
      end
    end
  end



  # GET /batches or /batches.json
  def index
    authorize :batch
    @batches = Batch.all
  end

  # GET /batches/1 or /batches/1.json
  def show
    authorize @batch
  end

  # GET /batches/new
  def new
    authorize :batch
    @batch = Batch.new
    @page_title = "Create new #{self.controller_name.humanize}"
  end

  # GET /batches/1/edit
  def edit
    authorize @batch
  end

  # POST /batches or /batches.json
  def create
    authorize :batch
    @batch = Batch.new(batch_params)
    unless params[:user_id]
      @batch.user = User.system_user
    end

    respond_to do |format|
      if @batch.save
        format.html { redirect_to @batch, notice: "Batch was successfully created." }
        format.json { render :show, status: :created, location: @batch }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @batch.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /batches/1 or /batches/1.json
  def update
    authorize @batch
    respond_to do |format|
      if @batch.update(batch_params)
        format.html { redirect_to @batch, notice: "Batch was successfully updated." }
        format.json { render :show, status: :ok, location: @batch }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @batch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /batches/1 or /batches/1.json
  def destroy
    authorize @batch
    @batch.destroy!

    respond_to do |format|
      format.html { redirect_to batches_path, status: :see_other, notice: "Batch was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_batch
      @batch = Batch.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def batch_params
      params.expect(batch: [ :filename, :user_id, :rp_id, :locking, :notes ])
    end
end
