# Represents a link to an online document, usually a google spreadsheet from a
# LoanResponse.
# Supercedes concept of 'EmbeddableMedia'
#
# Todo: create migration to drop obsolete embeddable_media table after merged to develop.

class LinkedDocument

  # Persisted data from LoanResponse value hash
  attr_accessor :url
  # Only relevant for google spreadsheets
  attr_accessor :start_cell
  attr_accessor :end_cell

  # Values parsed from url when a google spreadsheet
  attr_accessor :document_key
  attr_accessor :sheet_number

  def initialize(url, start_cell: nil, end_cell: nil)
    self.url = url
    self.start_cell = start_cell
    self.end_cell = end_cell
  end

  # Display url logic from legacy PHP system (which didn't seem to work as desired)
  #   "#{original_url}&single=true&range=#{start_cell}%3A#{end_cell}&output=html&gid=#{sheet}"

  def display_url
    parse_display_params_from_url
    # Todo: confirm if any special behavior needed for Google Apps environments
    if /.*spreadsheet\/ccc\?.*/.match(url)
      "https://docs.google.com/spreadsheet/ccc?key=#{document_key}&gid=#{sheet_number}&single=true"\
        "#{range_param}&output=html"
    elsif /.*spreadsheets\/d\/.*/.match(url)
      "https://docs.google.com/spreadsheets/d/#{document_key}/htmlembed?single=true"\
        "&gid=#{sheet_number}#{range_param}&widget=false"
    else
      # Just pass through URLs which are not google spreadsheets
      url
    end
  end

  def parse_display_params_from_url
    # Extract document id from either new or old style spreadsheet urls
    ccc_style = /.*spreadsheet\/ccc\?key=(\w*).*/.match(url)
    d_style = /.*spreadsheets\/d\/([\w-]*).*/.match(url)
    key_match = ccc_style || d_style
    self.document_key = key_match[1] if key_match

    # Extract the sheet number from the original url.
    # Note, the attempt to allow a user enter a sheet number or name in the popup form of the
    # legacy PHP system never worked.
    # That value was sipmly ignored and the gid from the orignal url actually being used.
    gid_match = /.*gid=(\d*).*/.match(url)
    self.sheet_number = gid_match[1] if gid_match
    self
  end

  # In the php system, there used to be some logic dependent upon the range column count, but then
  # later hardcoded to 600.
  def display_width
    600
  end

  # Beware, the calculated display hight does not seem to be currently honored.
  # Perhaps overridden by some CSS definition.
  def display_height
    if start_cell.present? && end_cell.present?
      (end_row - start_row) * 20 + 100
    else
      480
    end
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
