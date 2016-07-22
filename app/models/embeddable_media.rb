# == Schema Information
#
# Table name: embeddable_media
#
#  created_at      :datetime         not null
#  document_key    :string
#  end_cell        :string
#  height          :integer
#  html            :text
#  id              :integer          not null, primary key
#  original_url    :string
#  owner_attribute :string
#  owner_id        :integer
#  owner_type      :string
#  sheet_number    :string
#  start_cell      :string
#  updated_at      :datetime         not null
#  url             :string
#  width           :integer
#
# Indexes
#
#  index_embeddable_media_on_owner_type_and_owner_id  (owner_type,owner_id)
#

# Represents a link to a google spreadsheet

class EmbeddableMedia < ActiveRecord::Base

  belongs_to :owner, polymorphic: true

  delegate :division, :division=, to: :owner

  def ensure_migration
    unless document_key.present?
      parse_sheet_range_from_url
    end
  end

  def parse_sheet_range_from_url
    return unless url
    # This block of code matches the original PHP logic, but the implied functionalty actually
    # appears broken for all but the first few records in the system, and all of the applied
    # display parameters are simply ignored.
    parsed = /(.*)&single=true&range=(.*)%3A(.*)&output=html&gid=(.*)/.match(url)
    #puts "parsed: #{parsed.inspect}"
    raise "unable to parse sheet url: #{url}" unless parsed
    if parsed
      if parsed.size != 5
        raise "unexpected result size parsing sheet url: #{url}, size: #{parsed.size}"
      end
      if original_url.present?
        if parsed[1] != original_url
          raise "original_url mismatch - parsed: #{parsed[1]}, expected: #{original_url}}"
        else
          self.original_url = parsed[1]
        end
      end
      self.start_cell = parsed[2]
      self.end_cell = parsed[3]
    end
    parse_key_gid_from_original_url
    self
  end

  def parse_key_gid_from_original_url
    self.original_url ||= url  # There are a few records in legacy db without original_url

    # Extract document id from either new or old style document urls
    ccc_style = /.*spreadsheet\/ccc\?key=(\w*).*/.match(original_url)
    d_style = /.*spreadsheets\/d\/([\w-]*).*/.match(original_url)
    key_match = ccc_style || d_style
    self.document_key = key_match[1] if key_match

    # Extract the sheet number from the original url.
    # Note, the attempt to allow a user enter a sheet number or name in the popup form of the
    # legacy PHP system never worked.
    # That value was sipmly ignored and the gid from the orignal url actually being used.
    #puts "original_url: #{original_url}"
    gid_match = /.*gid=(\d*).*/.match(original_url)
    self.sheet_number = gid_match[1] if gid_match
    #puts "gid_match: #{gid_match.inspect}"
    #puts "sheet_number: #{sheet_number}"
    self
  end

  # To be discussed:
  #   Should we remove url, width & height from the database?

  # Display url logic from legacy PHP system
  # def display_url
  #   "#{original_url}&single=true&range=#{start_cell}%3A#{end_cell}&output=html&gid=#{sheet}"
  # end

  def display_url
    ensure_migration
    # Todo: confirm if any special behavior needed for Google Apps environments
    if /.*spreadsheet\/ccc\?.*/.match(original_url)
      "https://docs.google.com/spreadsheet/ccc?key=#{document_key}&gid=#{sheet_number}&single=true#{range_param}&output=html"
    elsif /.*spreadsheets\/d\/.*/.match(original_url)
      "https://docs.google.com/spreadsheets/d/#{document_key}/htmlembed?single=true&gid=#{sheet_number}#{range_param}&widget=false"
    else
      # Unexpected url format, just pass through
      original_url
    end
  end

  # In the php system, there used to be some logic dependent upon the range column count, but then
  # later hardcoded to 600.
  def display_width
    600
  end

  def display_height
    ensure_migration
    (end_row - start_row) * 20 + 100
  end

  def start_row
    row_from_cell(start_cell)
  end

  def end_row
    row_from_cell(end_cell)
  end

  private

  def range_param
    if start_cell.present? && end_cell.present?
      "&range=#{start_cell}%3A#{end_cell}"
    else
      ""
    end
  end

  def row_from_cell(cell)
    parsed = /\D+(\d+)/.match(cell)
    parsed ? parsed[1].to_i : 0
  end

end
