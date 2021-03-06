class FormsController < ApplicationController
  before_action :authenticate_user!, except: [:new]
  before_action :set_form, only: [:show, :edit, :update, :destroy]

  def index
    @forms = Form.all
  end

  def new
    @products = Product.all
    @form = Form.new
    @products.each{ |product| @form.form_products.build(form: @form, product: product) }
    1.times { @form.surgeon_contacts.build }
    5.times { @form.dme_contacts.build }
    5.times { @form.pt_contacts.build }
  end

  def create
    @form = Form.new(form_params)
    form_params[:form_products_attributes].each do |attribute|
      @form.form_products.new(product: Product.find(attribute[1][:product_id]))
    end
    @form.save!
    # Tell the UserMailer to send a welcome email after save
    FormMailer.with(reciepient: @form.email, form: @form).welcome_email.deliver
    redirect_to @form
  end

  def show
    @form = Form.find(params[:id])
  end

  def edit
    @products = Product.all
  end

  def update
    @form.update(form_params)
    redirect_to forms_path
  end

  def destroy
    @form.surgeon_contacts.destroy_all
    @form.dme_contacts.destroy_all
    @form.pt_contacts.destroy_all
    @form.destroy
    redirect_to forms_path
  end

  private

  def set_form
    @form = Form.find(params[:id])
  end

  def form_params
    params.require(:form).permit(
      :email,
      :region,
      :joint_replacement,
      :sports_medicine,
      :orthopedic_trauma,
      :non_surgical_orthopedic,
      :spine,
      :other_conditions,
      :substitutions,
      :signature,
      :date,
      surgeon_contacts_attributes: [
        :name,
        :primary,
        :phone,
        :street,
        :city,
        :state,
        :zip,
      ],
      dme_contacts_attributes: [
        :name,
        :primary,
        :phone,
        :street,
        :city,
        :state,
        :zip,
      ],
      pt_contacts_attributes: [
        :name,
        :primary,
        :phone,
        :street,
        :city,
        :state,
        :zip,
      ],
      form_products_attributes: [
        :amount,
        :product_id,
      ]
    )
  end

end
