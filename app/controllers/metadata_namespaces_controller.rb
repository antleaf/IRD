class MetadataNamespacesController < ApplicationController
  before_action :set_metadata_namespace, only: %i[ show edit update destroy ]
  after_action :verify_authorized

  # GET /metadata_namespaces or /metadata_namespaces.json
  def index
    authorize :metadata_namespace
    @metadata_namespaces = MetadataNamespace.all
    @page_title = "Metadata Namespaces"
  end

  # GET /metadata_namespaces/1 or /metadata_namespaces/1.json
  def show
    authorize @metadata_namespace
    @page_title = "Metadata Namespace"
  end

  # GET /metadata_namespaces/new
  def new
    authorize :metadata_namespace
    @metadata_namespace = MetadataNamespace.new
    @page_title = "New Metadata Namespace"
  end

  # GET /metadata_namespaces/1/edit
  def edit
    authorize @metadata_namespace
    @page_title = "Editing Metadata Namespace"
  end

  # POST /metadata_namespaces or /metadata_namespaces.json
  def create
    authorize :metadata_namespace
    @metadata_namespace = MetadataNamespace.new(metadata_namespace_params)

    respond_to do |format|
      if @metadata_namespace.save
        format.html { redirect_to @metadata_namespace, notice: "Metadata namespace was successfully created." }
        format.json { render :show, status: :created, location: @metadata_namespace }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @metadata_namespace.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /metadata_namespaces/1 or /metadata_namespaces/1.json
  def update
    authorize @metadata_namespace
    respond_to do |format|
      if @metadata_namespace.update(metadata_namespace_params)
        format.html { redirect_to @metadata_namespace, notice: "Metadata namespace was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @metadata_namespace }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @metadata_namespace.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /metadata_namespaces/1 or /metadata_namespaces/1.json
  def destroy
    authorize @metadata_namespace
    @metadata_namespace.destroy!

    respond_to do |format|
      format.html { redirect_to metadata_namespaces_path, notice: "Metadata namespace was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_metadata_namespace
      @metadata_namespace = MetadataNamespace.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def metadata_namespace_params
      params.expect(metadata_namespace: [ :metadata_format_id ])
    end
end
