class MakeUnfeaturedImagesFeatured < ActiveRecord::Migration[5.2]
  def up
    Loan.find_each do |loan|
      loan_images = loan&.media&.images_only
      loan_images&.first&.update(featured: true) if loan_images&.none?(&:featured)
    end
  end

  def down
    Loan.update_all(featured: false)
  end
end
